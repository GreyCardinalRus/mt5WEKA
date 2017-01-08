//+------------------------------------------------------------------+
//|                                              my_expert_class.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| ОБЪЯВЛЕНИЕ КЛАССА                                                |
//+------------------------------------------------------------------+
class MyExpert
  {
//--- закрытые члены (переменные) класса
private:
   int               Magic_No;   // Magic
   int               Chk_Margin; // Флаг необходимости проверки маржи перед размещением торгового запроса (1 или 0)
   double            LOTS;       // Количество лотов для торговли
   double            TradePct;   // Процент допустимой свободной маржи для торговли 
   double            ADX_min;    // Минимальное значение ADX
   int               ADX_handle; // Хэндл индикатора ADX
   int               MA_handle;  // Хэндл индикатора Moving Average
   double            plus_DI[];  // Массив для хранения значений +DI индикатора ADX
   double            minus_DI[]; // Массив для хранения значений -DI индикатора ADX
   double            MA_val[];   // Массив для хранения значений индикатора Moving Average
   double            ADX_val[];  // Массив для хранения значений индикатора ADX
   double            Closeprice; // Переменная для хранения цены закрытия предыдущего бара 
   MqlTradeRequest   trequest;   // Стандартная структура торгового запроса для отправки наших торговых запросов
   MqlTradeResult    tresult;    // Стандартная структура ответа торгового сервера для получения результатов торговых запросов
   string            symbol;     // Переменная для хранения имени текущего инструмента
   ENUM_TIMEFRAMES   period;     // Переменная для хранения текущего таймфрейма
   string            Errormsg;   // Переменная для хранения наших сообщений об ошибке
   int               Errcode;    // Переменная для хранения наших кодов ошибок
//--- Открытые члены/функции (public)
public:
   void              MyExpert();                                  //Конструктор класса
   void              setSymbol(string syb){symbol = syb;}         //Функция установки текущего символа
   void              setPeriod(ENUM_TIMEFRAMES prd){period = prd;}//Функция установки периода текущего символа
   void              setCloseprice(double prc){Closeprice=prc;}   //Функция установки цены закрытия предыдущего бара
   void              setchkMAG(int mag){Chk_Margin=mag;}          //Функция установки значения переменной Chk_Margin
   void              setLOTS(double lot){LOTS=lot;}               //Функция установки размера лота для торговли
   void              setTRpct(double trpct){TradePct=trpct/100;}  //Функция установки процента свободной маржи, используемой в торговле
   void              setMagic(int magic){Magic_No=magic;}         //Функция установки Magic number эксперта
   void              setadxmin(double adx){ADX_min=adx;}          //Функция установки минимального значения ADX
   void              doInit(int adx_period,int ma_period);        //Функция, которая будет использоваться при инициализации советника
   void              doUninit();                                  //Функция, которая будет использоваться при деинициализации советника
   bool              checkBuy();                                  //Функция для проверки условий покупки
   bool              checkSell();                                 //Функция для проверки условий продажи
   void              openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,
                             double TP,int dev,string comment="");   //Функция для открытия позиций на покупку
   void              openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,
                              double TP,int dev,string comment="");  //Функция для открытия позиций на продажу

   //--- Защищенные члены класса
protected:
   void              showError(string msg, int ercode);    //Функция для отображения сообщений об ошибках
   void              getBuffers();                        //Функция для получения индикаторных буферов
   bool              MarginOK();                          //Функция проверки наличия достаточного количества маржи
  };   // конец объявления класса
//+------------------------------------------------------------------+
// Определение функций-членов нашего класса
//+------------------------------------------------------------------+
/*
 Конструктор
*/
void MyExpert::MyExpert()
  {
   //инициализация всех необходимых переменных
   ZeroMemory(trequest);
   ZeroMemory(tresult);
   ZeroMemory(ADX_val);
   ZeroMemory(MA_val);
   ZeroMemory(plus_DI);
   ZeroMemory(minus_DI);
   Errormsg="";
   Errcode=0;
  }
//+------------------------------------------------------------------+
// Функция вывода сообщения об ошибке
//+------------------------------------------------------------------+
void MyExpert::showError(string msg,int ercode)
  {
   Alert(msg,"-ошибка:",ercode,"!!"); // display error
  }
//+------------------------------------------------------------------+
// Получение индикаторных буферов
//+------------------------------------------------------------------+
void MyExpert::getBuffers()
  {
   if(CopyBuffer(ADX_handle,0,0,3,ADX_val)<0 || CopyBuffer(ADX_handle,1,0,3,plus_DI)<0
      || CopyBuffer(ADX_handle,2,0,3,minus_DI)<0 || CopyBuffer(MA_handle,0,0,3,MA_val)<0)
     {
      Errormsg ="Ошибка копирования индикаторных буферов";
      Errcode = GetLastError();
      showError(Errormsg,Errcode);
     }
  }
//+-----------------------------------------------------------------------+
// ОТКРЫТЫЕ(PUBLIC)ФУНКЦИИ НАШЕГО КЛАССА 
//+-----------------------------------------------------------------------+
/*
   Инициализация 
*/
void MyExpert::doInit(int adx_period,int ma_period)
  {
//--- Получаем хэндл индикатора ADX
   ADX_handle=iADX(symbol,period,adx_period);
//--- Получаем хэндл индикатора Moving Average
   MA_handle=iMA(symbol,period,ma_period,0,MODE_EMA,PRICE_CLOSE);
//--- Проверка корректности хэндлов
   if(ADX_handle<0 || MA_handle<0)
     {
      Errormsg="Error Creating Handles for indicators";
      Errcode=GetLastError();
      showError(Errormsg,Errcode);
     }
// Устанавливаем атрибут AsSeries для массивов
// для значений ADX
   ArraySetAsSeries(ADX_val,true);
// для значений +DI
   ArraySetAsSeries(plus_DI,true);
// для значений -DI
   ArraySetAsSeries(minus_DI,true);
// для значений MA
   ArraySetAsSeries(MA_val,true);
  }
//+------------------------------------------------------------------+
// Деинициализация
//+------------------------------------------------------------------+
void MyExpert::doUninit()
  {
//--- Release our indicator handles
   IndicatorRelease(ADX_handle);
   IndicatorRelease(MA_handle);
  }
//+------------------------------------------------------------------+
// Проверяет факт наличия достаточного количества маржи для торговли
//+------------------------------------------------------------------+
bool MyExpert::MarginOK()
  {
      double one_lot_price;                                                    //Маржа, требуемая для одного лота
   double act_f_mag     = AccountInfoDouble(ACCOUNT_FREEMARGIN);               //Размер свободной маржи на счете
   long   levrage       = AccountInfoInteger(ACCOUNT_LEVERAGE);                //Плечо данного счета
   double contract_size = SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE); //Размер контракта
   string base_currency = SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);       //Базовая валюта
                                                                                
   if(base_currency=="USD")
     {
      one_lot_price=contract_size/levrage;
     }
   else
     {
      double bprice= SymbolInfoDouble(symbol,SYMBOL_BID);
      one_lot_price=bprice*contract_size/levrage;
     }
   // Проверка условия того, чтобы требуемое количество маржи не превышало заданный процент
   if(MathFloor(LOTS*one_lot_price)>MathFloor(act_f_mag*TradePct))
     {
      return(false);
     }
   else
     {
      return(true);
     }
  }
//+------------------------------------------------------------------+
// Проверка условий покупки
//+------------------------------------------------------------------+
bool MyExpert::checkBuy()
  {
  /*
    Проверка открытия длинной позиции: скользящая средняя (MA) возрастает, 
    цена закрытия предыдущего бара выше ее, ADX > ADX min, +DI > -DI
  */
   getBuffers();
   //--- Объявляем переменные типа bool для хранения результатов проверки наших условий покупки
   bool Buy_Condition_1 = (MA_val[0]>MA_val[1]) && (MA_val[1]>MA_val[2]); // MA растет
   bool Buy_Condition_2 = (Closeprice > MA_val[1]);         // Цена закрытия предыдущего больше MA
   bool Buy_Condition_3 = (ADX_val[0]>ADX_min);             // Текушее значение ADX больше заданного минимального(22)
   bool Buy_Condition_4 = (plus_DI[0]>minus_DI[0]);         // +DI больше чем -DI
//--- Собираем все вместе 
   if(Buy_Condition_1 && Buy_Condition_2 && Buy_Condition_3 && Buy_Condition_4)
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }
//+------------------------------------------------------------------+
// Проверка условий для продажи
//+------------------------------------------------------------------+
bool MyExpert::checkSell()
  {
  /*
    Проверка условий продажи : скользящая средняя (MA) падает, 
    цена закрытия предыдущего бара ниже ее, ADX > ADX min, -DI > +DI
  */
  getBuffers();
  //--- Объявляем переменные типа bool для хранения результатов проверки условий для продажи
   bool Sell_Condition_1 = (MA_val[0]<MA_val[1]) && (MA_val[1]<MA_val[2]);  // MA падает
   bool Sell_Condition_2 = (Closeprice <MA_val[1]);                         // цена закрытия предыдущего бара меньше MA-8
   bool Sell_Condition_3 = (ADX_val[0]>ADX_min);                            // Текущее значение ADX больше, чем минимальное (22)
   bool Sell_Condition_4 = (plus_DI[0]<minus_DI[0]);                        // -DI больше, чем +DI
   
  //--- Собираем все вместе

   if(Sell_Condition_1 && Sell_Condition_2 && Sell_Condition_3 && Sell_Condition_4)
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }
//+------------------------------------------------------------------+
// Открывает позицию на покупку
//+------------------------------------------------------------------+
void MyExpert::openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,double TP,int dev,string comment="")
  {
// если необходимо проверять маржу
   if(Chk_Margin==1)
     {
      if(MarginOK()==false)
        {
         Errormsg= "У вас нет достаточного количества средств для открытия позиции!!!";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
      else
        {
         trequest.action=TRADE_ACTION_DEAL;
         trequest.type=otype;
         trequest.volume=LOTS;
         trequest.price=askprice;
         trequest.sl=SL;
         trequest.tp=TP;
         trequest.deviation=dev;
         trequest.magic=Magic_No;
         trequest.symbol=symbol;
         trequest.type_filling=ORDER_FILLING_AON;
         // отсылаем запрос
         OrderSend(trequest,tresult);
         // проверяем результат
         if(tresult.retcode==10009 || tresult.retcode==10008) //Запрос успешно выполнен 
           {
            Alert("Ордер Buy успешно размещен, тикет ордера #:",tresult.order,"!!");
           }
         else
           {
            Errormsg= "Запрос на установку ордера Buy не выполнен.";
            Errcode =GetLastError();
            showError(Errormsg,Errcode);
           }
        }
     }
   else
     {
      trequest.action=TRADE_ACTION_DEAL;
      trequest.type=otype;
      trequest.volume=LOTS;
      trequest.price=askprice;
      trequest.sl=SL;
      trequest.tp=TP;
      trequest.deviation=dev;
      trequest.magic=Magic_No;
      trequest.symbol=symbol;
      trequest.type_filling=ORDER_FILLING_AON;
      // отсылаем запрос
      OrderSend(trequest,tresult);
      // проверяем результат
      if(tresult.retcode==10009 || tresult.retcode==10008) //Запрос успешно выполнен 
        {
         Alert("A Buy order has been successfully placed with Ticket#:",tresult.order,"!!");
        }
      else
        {
         Errormsg= "The Buy order request could not be completed";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
     }
  }
//+------------------------------------------------------------------+
// Открытие позиции на продажу
//+------------------------------------------------------------------+
void MyExpert::openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,double TP,int dev,string comment="")
  {
// Do check Margin if enabled
   if(Chk_Margin==1)
     {
      if(MarginOK()==false)
        {
         Errormsg= "У вас нет достаточного количества средств для открытия позиции!!!";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
      else
        {
         trequest.action=TRADE_ACTION_DEAL;
         trequest.type=otype;
         trequest.volume=LOTS;
         trequest.price=bidprice;
         trequest.sl=SL;
         trequest.tp=TP;
         trequest.deviation=dev;
         trequest.magic=Magic_No;
         trequest.symbol=symbol;
         trequest.type_filling=ORDER_FILLING_AON;
         // отсылаем запрос
         OrderSend(trequest,tresult);
         // проверяем результат
         if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed 
           {
            Alert("Ордер Sell успешно размещен, тикет ордера #:",tresult.order,"!!");
           }
         else
           {
            Errormsg= "Запрос на установку ордера Sell не выполнен";
            Errcode =GetLastError();
            showError(Errormsg,Errcode);
           }
        }
     }
   else
     {
      trequest.action=TRADE_ACTION_DEAL;
      trequest.type=otype;
      trequest.volume=LOTS;
      trequest.price=bidprice;
      trequest.sl=SL;
      trequest.tp=TP;
      trequest.deviation=dev;
      trequest.magic=Magic_No;
      trequest.symbol=symbol;
      trequest.type_filling=ORDER_FILLING_AON;
      // отсылаем запрос
      OrderSend(trequest,tresult);
      // проверяем результат
      if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed 
        {
         Alert("Ордер Sell был успешно помещен, тикет ордера #:",tresult.order,"!!");
        }
      else
        {
         Errormsg= "The Sell order request could not be completed";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
     }
  }
//+----------------------------------------------------------------+
