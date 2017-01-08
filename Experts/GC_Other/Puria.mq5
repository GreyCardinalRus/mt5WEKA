//+------------------------------------------------------------------+
//|                                                        Puria.mq5 |
//|                                       Copyright 2010, AM2 Group. |
//|                                         http://www.am2_group.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, AM2 Group."
#property link      "http://www.am2_group.net"
#property version   "1.00"

//--- входные параметры
input int      StopLoss=14;      // Stop Loss
input int      TakeProfit=15;    // Take Profit
input int      MA1_Period=75;    // Период Moving Average
input int      MA2_Period=85;    // Период Moving Average
input int      MA3_Period=5;     // Период Moving Average
input int      EA_Magic=12345;   // Magic Number советника
input double   Lot=0.1;          // Количество лотов для торговли
//--- глобальные переменные
int macdHandle;    // хэндл индикатора MACD
int ma75Handle;    // хэндл индикатора Moving Average
int ma85Handle;    // хэндл индикатора Moving Average
int ma5Handle;     // хэндл индикатора Moving Average
double macdVal[5]; // статический массив для хранения численных значений индикатора MACD
double ma75Val[5]; // статический массив для хранения значений индикатора Moving Average
double ma85Val[5]; // статический массив для хранения значений индикатора Moving Average 
double ma5Val[5];  // статический массив для хранения значений индикатора Moving Average 
double p_close;    // переменная для хранения значения close бара
int STP,TKP;       // будут использованы для значений Stop Loss и Take Profit
bool BuyOne = true, SellOne = true; // только один ордер
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Достаточно ли количество баров для работы
   if(Bars(_Symbol,_Period)<60) // общее количество баров на графике меньше 60?
     {
      Alert("На графике меньше 60 баров, советник не будет работать!!");
      return(-1);
     }
//--- Получить хэндл индикатора MACD
   macdHandle=iMACD(NULL,0,15,26,1,PRICE_CLOSE);
//---Получить хэндл индикатора Moving Average
   ma75Handle=iMA(_Symbol,_Period,75,0,MODE_LWMA,PRICE_LOW);
   ma85Handle=iMA(_Symbol,_Period,85,0,MODE_LWMA,PRICE_LOW);
   ma5Handle=iMA(_Symbol,_Period,5,0,MODE_EMA,PRICE_CLOSE);
      
//--- Нужно проверить, не были ли возвращены значения Invalid Handle
   if(macdHandle<0 || ma75Handle<0|| ma85Handle<0|| ma5Handle<0)
     {
      Alert("Ошибка при создании индикаторов - номер ошибки: ",GetLastError(),"!!");
      return(-1);
     }

//--- Для работы с брокерами, использующими 3-х и 5-ти значные котировки,
//--- умножаем на 10 значения SL и TP
   STP = StopLoss;
   TKP = TakeProfit;
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Освобождаем хэндлы индикаторов
   IndicatorRelease(ma75Handle);
   IndicatorRelease(ma85Handle);
   IndicatorRelease(ma5Handle);
   IndicatorRelease(macdHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

// Для сохранения значения времени бара мы используем static-переменную Old_Time.
// При каждом выполнении функции OnTick мы будем сравнивать время текущего бара с сохраненным временем.
// Если они не равны, это означает, что начал строится новый бар.

   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar=false;

// копируем время текущего бара в элемент New_Time[0]
   int copied=CopyTime(_Symbol,_Period,0,1,New_Time);
   if(copied>0) // ok, успешно скопировано
     {
      if(Old_Time!=New_Time[0]) // если старое время не равно
        {
         IsNewBar=true;   // новый бар
         if(MQL5InfoInteger(MQL5_DEBUGGING)) Print("Новый бар",New_Time[0],"старый бар",Old_Time);
         Old_Time=New_Time[0];   // сохраняем время бара
        }
     }
   else
     {
      Alert("Ошибка копирования времени, номер ошибки =",GetLastError());
      ResetLastError();
      return;
     }

//--- советник должен проверять условия совершения новой торговой операции только при новом баре
   if(IsNewBar==false)
     {
      return;
     }

//--- Имеем ли мы достаточное количество баров на графике для работы
   int Mybars=Bars(_Symbol,_Period);
   if(Mybars<60) // если общее количество баров меньше 60
     {
      Alert("На графике менее 60 баров, советник работать не будет!!");
      return;
     }

//--- Объявляем структуры, которые будут использоваться для торговли
   MqlTick latest_price;       // Будет использоваться для текущих котировок
   MqlTradeRequest mrequest;   // Будет использоваться для отсылки торговых запросов
   MqlTradeResult mresult;     // Будет использоваться для получения результатов выполнения торговых запросов
   MqlRates mrate[];           // Будет содержать цены, объемы и спред для каждого бара
   
   mrequest.action = TRADE_ACTION_DEAL;        // немедленное исполнение
   mrequest.type_filling = ORDER_FILLING_AON;  // тип исполнения ордера - все или ничего   
   mrequest.symbol = _Symbol;                  // символ
   mrequest.volume = Lot;                      // количество лотов для торговли
   mrequest.magic = EA_Magic;                  // Magic Number 
   mrequest.deviation=5;                       // проскальзывание от текущей цены
   
/*
     Установим индексацию в массивах котировок и индикаторов 
     как в таймсериях
*/
// массив котировок
   ArraySetAsSeries(mrate,true);
// массив значений индикатора MACD
   ArraySetAsSeries(macdVal,true);
// массив значений индикатора MA
   ArraySetAsSeries(ma75Val,true);
   ArraySetAsSeries(ma85Val,true);
   ArraySetAsSeries(ma5Val,true);

//--- Получить текущее значение котировки в структуру типа MqlTick
   if(!SymbolInfoTick(_Symbol,latest_price))
     {
      Alert("Ошибка получения последних котировок - ошибка:",GetLastError(),"!!");
      return;
     }

//--- Получить исторические данные последних 3-х баров
   if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
     {
      Alert("Ошибка копирования исторических данных - ошибка:",GetLastError(),"!!");
      return;
     }

//--- Копируем значения индикаторов в массивы
      
   if(CopyBuffer(ma75Handle,0,0,3,ma75Val)<0 || CopyBuffer(ma85Handle,0,0,3,ma85Val)<0
      || CopyBuffer(ma5Handle,0,0,3,ma5Val)<0)
     {
      Alert("Ошибка копирования буферов индикатора MACD - номер ошибки:",GetLastError(),"!!");
      return;
     }
   if(CopyBuffer(macdHandle,0,0,3,macdVal)<0)
     {
      Alert("Ошибка копирования буферов индикатора Moving Average - номер ошибки:",GetLastError());
      return;
     }

// Скопируем текущую цену закрытия предыдущего бара (это бар 1)
   p_close=mrate[1].close;  // цена закрытия предыдущего бара

/*
    1. Проверка условий для покупки : MA-5 пересекает MA-75 и MA-85 снизу вверх, 
       предыдущая цена закрытия бара больше MA-5, индикатор MACD больше 0.
*/

//--- объявляем переменные типа boolean, они будут использоваться при проверке условий для покупки
   bool Buy_Signal=(ma5Val[1]>ma75Val[1]) && (ma5Val[1]>ma85Val[1]      // MA-5 пересекает MA-75 и MA-85 снизу вверх
                 && p_close > ma5Val[1]                                 // предыдущая цена закрытия выше скользяшей средней MA-5
                 && macdVal[1]>0);                                      // индикатор MACD больше 0
/*
    2. Проверка условий для продажи : MA-5 пересекает MA-75 и MA-85 сверху вниз, 
       предыдущая цена закрытия бара меньше MA-5, индикатор MACD меньше 0.
*/

//--- объявляем переменные типа boolean, они будут использоваться при проверке условий для продажи
   bool Sell_Signal = (ma5Val[1]<ma75Val[1]) && (ma5Val[1]<ma85Val[1]       //MA-5 пересекает MA-75 и MA-85 сверху вниз
                    && p_close < ma5Val[1]                                  // предыдущая цена закрытия ниже MA-5
                    && macdVal[1]<0);                                       // индикатор MACD меньше 0


//--- собираем все вместе
   if(Buy_Signal &&                                                         // покупаем если есть сигнал на покупку
      PositionSelect(Symbol())==false &&                                    // ордер закрыт
      BuyOne)                                                               // при условии на покупку ставим только один ордер
     {
      mrequest.type = ORDER_TYPE_BUY;                                       // ордер на покупку
      mrequest.price = NormalizeDouble(latest_price.ask,_Digits);           // последняя цена ask
      mrequest.sl = NormalizeDouble(latest_price.ask - STP*_Point,_Digits); // Stop Loss
      mrequest.tp = NormalizeDouble(latest_price.ask + TKP*_Point,_Digits); // Take Profit 
      OrderSend(mrequest,mresult);                                          // отсылаем ордер 
      BuyOne = false;                                                       // на покупку только один ордер                                                   
      SellOne = true;                                                       // меняем флаг одного ордера на продажу           
     }
     
//--- собираем все вместе
   else if(Sell_Signal &&                                                   // продаем если есть сигнал на продажу
           PositionSelect(Symbol())==false &&                               // ордер закрыт
           SellOne)                                                         // при условии на продажу ставим только один ордер
     {   
      mrequest.type= ORDER_TYPE_SELL;                                       // ордер на продажу
      mrequest.price = NormalizeDouble(latest_price.bid,_Digits);           // последняя цена Bid
      mrequest.sl = NormalizeDouble(latest_price.bid + STP*_Point,_Digits); // Stop Loss
      mrequest.tp = NormalizeDouble(latest_price.bid - TKP*_Point,_Digits); // Take Profit
      OrderSend(mrequest,mresult);                                          // отсылаем ордер
      SellOne = false;                                                      // на продажу только один ордер                                             
      BuyOne = true;                                                        // меняем флаг одного ордера на покупку                   
     }         
   return;
  }
//+------------------------------------------------------------------+
