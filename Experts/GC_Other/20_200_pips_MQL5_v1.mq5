//+------------------------------------------------------------------+
//|                                          20_200_pips_MQL5_v1.mq5 |
//|                                    Copyright 2010, Смирнов Павел |
//|                                          http://www.autoforex.ru |
//+------------------------------------------------------------------+

#property copyright "Copyright 2010, Смирнов Павел"
#property link      "http://www.autoforex.ru"
#property version   "1.00"

//Объявляем внешние переменные. Они будут доступны извне и их значения можно будет менять перед запуском тестера

input int      TakeProfit=200;
input int      StopLoss=2000;
input int      TradeTime=18;
input int      t1=7;
input int      t2=2;
input int      delta=70;
input double   lot=0.1;

bool cantrade=true;// флаг для разрешения или запрета торговли.
double Ask; // здесь будем хранить цену Ask для нового тика (так удобней)
double Bid; // здесь будем хранить цену Bid для нового тика (так удобней)

//Функция открытия длинной (Long) позиции. Указываем также значения переменных по умолчанию
int OpenLong(double volume=0.1,int slippage=10,string comment="EUR/USD 20 pips expert (Long)",int magic=0)
  {
   MqlTradeRequest my_trade;//объявляем структуру типа MqlTradeRequest для формирования запроса
   MqlTradeResult my_trade_result;//в этой структуре будет ответ сервера на запрос.
   
   //далее заполняеем все НЕОБХОДИМЫЕ поля структуры запроса.
   my_trade.action=TRADE_ACTION_DEAL;//Установить торговый ордер на немедленное совершение сделки с указанными 
                                     //параметрами (поставить рыночный ордер)
   my_trade.symbol=Symbol();//указываем в качестве валютной пары - текущую валютную пару 
                            //(ту, на которой запущен советник)
   my_trade.volume=NormalizeDouble(volume,1);//размер лота
   my_trade.price=NormalizeDouble(Ask,_Digits);//Цена, при достижении которой ордер должен быть исполнен. 
   //В нашем случае для TRADE_ACTION_DEAL это текущая цена и ее, согласно инструкции указывать не обязательно.
   my_trade.sl=NormalizeDouble(Ask-StopLoss*_Point,_Digits);//стоплосс ордера (цена при которой следует закрыть 
                                                            //убыточную сделку)
   my_trade.tp=NormalizeDouble(Ask+TakeProfit*_Point,_Digits);//тейкпрофит (цена при которой следует закрыть
                                                              // прибыльную сделку)
   my_trade.deviation=slippage;//проскальзывание в пунктах (при тестировании особой роли не играет, т.к. 
                               //проскальзывания не бывает на тестах)
   my_trade.type=ORDER_TYPE_BUY;//тип рыночного ордера (покупаем)
   my_trade.type_filling=ORDER_FILLING_AON;//Указываем как исполнять ордер. (All Or Nothing - все или ничего) 
   //Сделка может быть совершена исключительно в указанном объеме и по цене равной или лучше указанной в ордере.
   my_trade.comment=comment;//комментарий ордера
   my_trade.magic=magic;//магическое число ордера
   
   ResetLastError();//обнуляем код последней ошибки 
   if(OrderSend(my_trade,my_trade_result))//отправляем запрос на открытие позиции. При этом проверяем 
                                          //успешно ли прошла отправка запроса
     {
      // Если сервер принял ордер то смортрим на результат 
      Print("Код результата операции - ",my_trade_result.retcode);
     }
   else
     {
      //Сервер не принял ордер в нем есть ошибки, выводим их в журнал
      Print("Код результата операции - ",my_trade_result.retcode);
      Print("Ошибка открытия ордера = ",GetLastError());    
     }  
return(0);// Выходим из функции открытия ордера     
}

//функция открытия короткой (Short) позиции. Аналогична функции открытия длинной позиции.
int OpenShort(double volume=0.1,int slippage=10,string comment="EUR/USD 20 pips expert (Short)",int magic=0)
  {
   MqlTradeRequest my_trade;
   MqlTradeResult my_trade_result;
   my_trade.action=TRADE_ACTION_DEAL;
   my_trade.symbol=Symbol();
   my_trade.volume=NormalizeDouble(volume,1);
   my_trade.price=NormalizeDouble(Bid,_Digits);
   my_trade.sl=NormalizeDouble(Bid+StopLoss*_Point,_Digits);
   my_trade.tp=NormalizeDouble(Bid-TakeProfit*_Point,_Digits);
   my_trade.deviation=slippage;
   my_trade.type=ORDER_TYPE_SELL;
   my_trade.type_filling=ORDER_FILLING_AON;
   my_trade.comment=comment;
   my_trade.magic=magic;

   ResetLastError();  
   if(OrderSend(my_trade,my_trade_result))
     {
      Print("Код результата операции - ",my_trade_result.retcode);
     }
   else
     {
      Print("Код результата операции - ",my_trade_result.retcode);
      Print("Ошибка открытия ордера = ",GetLastError()); 
      }        
return(0);     
}

int OnInit()
  {
   return(0);
  }


void OnDeinit(const int reason){}

void OnTick()
   {
   double Open[];//массив где будут храниться цены открытия баров (включая Open[t1] и Open[t2])
   MqlDateTime mqldt;//в этой структуре храним текущее время.
   TimeCurrent(mqldt);//обновляем данные о текущем времени.
   int len;//переменная определяющая длинну массива Open[].
        
   MqlTick last_tick;//Здесь будут храниться цены последнего пришедшего тика
   SymbolInfoTick(_Symbol,last_tick);//заполняем структуру last_tick последними ценами текущего символа.
   Ask=last_tick.ask;//Обновляем переменные Ask и Bid для дальнейшего использования
   Bid=last_tick.bid;
   
   ArraySetAsSeries(Open,true);//для удобства работы определяем массив Open[] как таймсерию.
   
   //далее определим длину массива такую, чтобы обязательно вошли значения Open[t1] и Open[t2]
   if (t1>=t2)len=t1+1;//t1 и t2 - номера баров на которых сравниваются цены. Берем большее из них
   else len=t2+1;      //и добавляем 1 (т.к. есть еще и нулевой бар)

   CopyOpen(_Symbol,PERIOD_H1,0,len,Open);//заполняем массив Open[] актуальными значениями
   
   //Переключаем флаг cantarde на true, т.е. разрешим советнику снова открывать позиции
   if(((mqldt.hour)>TradeTime)) cantrade=true;
                 
   // проверяем возможность встать в позицию:
   if(!PositionSelect(_Symbol))// Если еще нет открытой позиции
   {
      if((mqldt.hour==TradeTime) && (cantrade))//Если пришло время торговать
        {
         if(Open[t1]>(Open[t2]+delta*_Point))//Проверяем условие для открытия короткой сделки (продажи)
           {                  
               OpenShort(lot,10,"EUR/USD 20 pips expert (Short)",1234);//открываем позицию Short 
               cantrade=false;// Переключаем флаг (запрещаем торговать), чтобы не откывал больше позиций до следующего дня                                         
               return;//выходим
           }
         if((Open[t1]+delta*_Point)<Open[t2])//Проверяем условие для открытия длинной сделки (покупки)
           {
               OpenLong(lot,10,"EUR/USD 20 pips expert (Long)",1234);//открываем позицию Long
               cantrade=false;// Переключаем флаг (запрещаем торговать), чтобы не откывал больше позиций до следующего дня                                           
               return;//выходим
           }
        }
   }
   return;
  }
//+------------------------------------------------------------------+
