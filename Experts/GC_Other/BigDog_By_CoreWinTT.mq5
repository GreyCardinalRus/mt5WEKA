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
      // ������� � ������� ����� ��������� ����������� ��������� ��������� ��� ��������� ������
      Lowest=Lowest-StopLevel*Point();
      // ����� ���������� ������������ ����������� �������� ������ ������

      if((Higest-Lowest)/Point()<Limited)
        {
         MqlTradeRequest BigDogBuy;
         MqlTradeRequest BigDogSell;
         BigDogBuy.action=TRADE_ACTION_PENDING;
         // ������������� ���������� �����
         BigDogBuy.magic = MagicNumber;
         BigDogBuy.symbol=Symbol();
         BigDogBuy.price=Higest;
         //����, �� ������� ����� ���������� �����
         BigDogBuy.volume=Lots;
         BigDogBuy.sl=Lowest;
         //���� ���� ���� �� �����, �� ����� ������������� �� ���������
         BigDogBuy.tp=Higest+TakeProfit*Point();
         //������������� ���� ������
         BigDogBuy.deviation=dev;
         //����������� ���������� �� ����������� ����, 
         //�� ����, ��������� ���� ���������� ����� ���������� �� �������� ����
         BigDogBuy.type=ORDER_TYPE_BUY_STOP;
         //��� ������, ������� ����������� �� ��������� ���� ��� �� ���� ����� ��������
         //� ������ ������ ����� ����������� �� ���� ���� ��� ������ ��������� 
         //���� �� ��� ������ ��� buy_limit, �� �� �� ���������� 
         //�� ��������� ���� ��� �����, ���� ���������
         BigDogBuy.type_filling=ORDER_FILLING_AON;
         //������ �������� ����������, ��� ���� ���� ����� 
         //��� ��������� ���������� ������ 
         BigDogBuy.expiration=TimeTradeServer()+6*60*60;
         //�� ������ ��������� ���� ����� ������ ������ �� ������� ������� ����
         //��� ��� ����� �������� ������� ������ 2 ����, � ������� ���� � ��� 8 �����, �� 8-2 = 6
         BigDogSell.action=TRADE_ACTION_PENDING;

         // ������������� ���������� �����
         BigDogSell.magic = MagicNumber;
         BigDogSell.symbol=Symbol();
         BigDogSell.price=Lowest;
         //����, �� ������� ����� ���������� �����
         BigDogSell.volume=Lots;
         BigDogSell.sl=Higest;
         //���� ���� ������������� �� ���������
         BigDogSell.tp=Lowest-TakeProfit*Point();
         //������������� ���� ������
         BigDogSell.deviation=dev;
         //����������� ���������� �� ����������� ����, 
         //�� ����, ��������� ���� ��������� ����� ���������� �� �������� ����
         BigDogSell.type=ORDER_TYPE_SELL_STOP;
         //��� ������, ������� ����������� �� ��������� ���� ��� �� ���� ����� ��������
         //� ������ ������ ����� ������������ �� ���� ���� ��� ������ ��������� 
         //���� �� ��� ������ ��� buy_limit, �� �� �� ����������
         //�� ��������� ���� ��� ����� ���� ���������
         BigDogSell.type_filling=ORDER_FILLING_AON;
         //������ �������� ����������, ��� ���� ���� ����� 
         //��� ��������� ���������� ������ 
         BigDogSell.expiration=TimeTradeServer()+6*60*60;
         //�� ������ ��������� ���� ����� ������ ������ �� ������� ������� ����
         //��� ��� ����� �������� ������� ������ 2 ����, � ������� ���� � ��� 8 �����, �� 8-2 = 6
         MqlTradeResult ResultBuy,ResultSell;
         OrderSend(BigDogBuy,ResultBuy);
         OrderSend(BigDogSell,ResultSell);
        }
     }

// ���������� ���������
   int PosTotal=PositionsTotal();
   for(int i=PosTotal-1; i>=0; i--)
     {
      // ���������� �������� ������� � ������� ���� �� �������, ��������� ���� ����������.
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