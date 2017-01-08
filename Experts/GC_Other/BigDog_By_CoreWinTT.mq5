//+------------------------------------------------------------------+
//|                                          BigDog_By_CoreWinTT.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//--- input parameters
input int      America=16;
input double   Lots=0.1;
input int      TakeProfit=500;
input long     MagicNumber=665;
input int      Limited=600;
input int      TrailingStop=100;
int dev=30;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
bool time2trade(int TradeHour,int Number)
  {
   MqlDateTime time2trade;
   TimeTradeServer(time2trade);
   if(time2trade.hour!=TradeHour) return(false);
   time2trade.hour= 0;
   time2trade.min = 0;
   time2trade.sec = 1;
   for(int ii=OrdersTotal()-1;ii>=0;ii--)
     {
      OrderGetTicket(ii);
      long ordmagic=OrderGetInteger(ORDER_MAGIC);
      if(Number==ordmagic) return(false);
     }
   HistorySelect(StructToTime(time2trade),TimeTradeServer());
   for(int ii=HistoryOrdersTotal()-1;ii>=0;ii--)
     {
      long HistMagic=HistoryOrderGetInteger(HistoryOrderGetTicket(ii),ORDER_MAGIC);
      if(Number==HistMagic) return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(time2trade(America+2,MagicNumber))
     {
      int i;
      double Higest = 0;
      double Lowest = 0;
      MqlRates Range[];
      CopyRates(Symbol(),15,0,9,Range);
      Lowest=Range[1].low;
      for(i=0; i<9;i++)
        {
         if(Higest<Range[i].high) Higest=Range[i].high;//MathMax(,Higest);
         if(Lowest>Range[i].low)  Lowest=Range[i].low;
        }
      long StopLevel=SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL);
      Higest=Higest+StopLevel*Point();
      // добавим к текушим ценам установки минимальную возможную дистанцию для установки ордера
      Lowest=Lowest-StopLevel*Point();
      // чтобы обеспечить максимальную вероятность принятия нашего ордера

      if((Higest-Lowest)/Point()<Limited)
        {
         MqlTradeRequest BigDogBuy;
         MqlTradeRequest BigDogSell;
         BigDogBuy.action=TRADE_ACTION_PENDING;
         // Устанавливаем отложенный ордер
         BigDogBuy.magic = MagicNumber;
         BigDogBuy.symbol=Symbol();
         BigDogBuy.price=Higest;
         //Цена, по которой будет установлен ордер
         BigDogBuy.volume=Lots;
         BigDogBuy.sl=Lowest;
         //если стоп лосс не задан, то будем устанавливать по стратегии
         BigDogBuy.tp=Higest+TakeProfit*Point();
         //устанавливаем тейк профит
         BigDogBuy.deviation=dev;
         //минимальное отклонение от запрошенной цены, 
         //то есть, насколько цена исполенния может отличаться от заданной цены
         BigDogBuy.type=ORDER_TYPE_BUY_STOP;
         //тип ордера, который исполняется по указанной цене или по цене лучше указаной
         //в данном случае ордер установится по цене выше или равной указанной 
         //если бы тип ордера был buy_limit, то он бы исполнился 
         //по указанной цене или ценам, ниже указанной
         BigDogBuy.type_filling=ORDER_FILLING_AON;
         //данный параметр показывает, как ведёт себя ордер 
         //при частичном исполнения обьёма 
         BigDogBuy.expiration=TimeTradeServer()+6*60*60;
         //по тексту стратегии срок жизни ордера только на текуший рабочий день
         //так как после открытия америки прошло 2 часа, а рабочий день у нас 8 часов, то 8-2 = 6
         BigDogSell.action=TRADE_ACTION_PENDING;

         // Устанавливаем отложенный ордер
         BigDogSell.magic = MagicNumber;
         BigDogSell.symbol=Symbol();
         BigDogSell.price=Lowest;
         //Цена, по которой будет установлен ордер
         BigDogSell.volume=Lots;
         BigDogSell.sl=Higest;
         //Стоп лосс устанавливаем по стратегии
         BigDogSell.tp=Lowest-TakeProfit*Point();
         //устанавливаем тейк профит
         BigDogSell.deviation=dev;
         //Минимальное отклонение от запрошенной цены, 
         //то есть, насколько цена исполения может отличаться от заданной цены
         BigDogSell.type=ORDER_TYPE_SELL_STOP;
         //тип ордера, который исполняется по указанной цене или по цене лучше указаной
         //в данном случае ордер установиться по цене ниже или равной указанной 
         //если бы тип ордера был buy_limit, то он бы исполнился
         //по указанной цене или ценам ниже указанной
         BigDogSell.type_filling=ORDER_FILLING_AON;
         //данный параметр показывает, как ведёт себя ордер 
         //при частичном исполнения обьёма 
         BigDogSell.expiration=TimeTradeServer()+6*60*60;
         //по тексту стратегии срок жизни ордера только на текуший рабочий день
         //так как после открытие америки прошло 2 часа, а рабочий день у нас 8 часов, то 8-2 = 6
         MqlTradeResult ResultBuy,ResultSell;
         OrderSend(BigDogBuy,ResultBuy);
         OrderSend(BigDogSell,ResultSell);
        }
     }

// реализация трайлинга
   int PosTotal=PositionsTotal();
   for(int i=PosTotal-1; i>=0; i--)
     {
      // перебираем открытые позиции и смотрим есть ли позиции, созданные этим советником.
      if(PositionGetSymbol(i)==Symbol())
        {
         if(MagicNumber==PositionGetInteger(POSITION_MAGIC))
           {
            MqlTick lasttick;
            SymbolInfoTick(Symbol(),lasttick);
            if(PositionGetInteger(POSITION_TYPE)==0)
              { //buy
               if(TrailingStop>0
                  &&(((lasttick.bid-PositionGetDouble(POSITION_PRICE_OPEN))/Point())>TrailingStop)
                  && ((lasttick.bid-PositionGetDouble(POSITION_SL))/Point())>TrailingStop)
                 {
                  MqlTradeRequest BigDogModif;
                  BigDogModif.action= TRADE_ACTION_SLTP;
                  BigDogModif.symbol= Symbol();
                  BigDogModif.sl = lasttick.bid - TrailingStop*Point();
                  BigDogModif.tp = PositionGetDouble(POSITION_TP);
                  BigDogModif.deviation=3;
                  MqlTradeResult BigDogModifResult;
                  OrderSend(BigDogModif,BigDogModifResult);
                 }
              }
            if(PositionGetInteger(POSITION_TYPE)==1)
              {//sell
               if(TrailingStop>0
                  && ((PositionGetDouble(POSITION_PRICE_OPEN)-lasttick.ask)/Point()>TrailingStop)
                  && (PositionGetDouble(POSITION_SL)==0
                  || (PositionGetDouble(POSITION_SL)-lasttick.ask)/Point()>TrailingStop))
                 {
                  MqlTradeRequest BigDogModif;
                  BigDogModif.action= TRADE_ACTION_SLTP;
                  BigDogModif.symbol= Symbol();
                  BigDogModif.sl = lasttick.ask + TrailingStop*Point();
                  BigDogModif.tp = PositionGetDouble(POSITION_TP);
                  BigDogModif.deviation=3;
                  MqlTradeResult BigDogModifResult;
                  OrderSend(BigDogModif,BigDogModifResult);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+