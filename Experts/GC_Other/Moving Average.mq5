//+------------------------------------------------------------------+
//|                                              Moving Averages.mq5 |
//|              Copyright Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

input double Lots               = 0.1;     // Trade Size by default
input double MaximumRisk        = 0.02;    // Maximum Risk in percentage
input double DecreaseFactor     = 3;       // Descrese factor
input int    MovingPeriod       = 12;      // Moving Average period
input int    MovingShift        = 6;       // Moving Average shift

//---
int    ExtHandle=0;
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double TradeSizeOptimized(void)
  {
//--- select lot size
   double lot=NormalizeDouble(AccountInfoDouble(ACCOUNT_FREEMARGIN)*MaximumRisk/1000.0,1);
//--- calculate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      int    orders=HistoryDealsTotal();  // total history deals
      int    losses=0;                    // number of losses orders without a break
      //---
      for(int i=orders-1;i>=0;i--)
        {
         ulong ticket=HistoryDealGetTicket(i);
         if(ticket==0)
           {
            Print("HistoryDealGetTicket failed, no trade history");
            break;
           }
         //--- check symbol
         if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol) continue;
         //--- check profit
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         if(profit>0.0) break;
         if(profit<0.0) losses++;
        }
      //---
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//--- return lot size
   return(lot<0.1 ? 0.1:lot);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   MqlRates rt[2];
//--- go trading only for first ticks of new bar
   if(CopyRates(_Symbol,_Period,0,2,rt)!=2)
     {
      Print("CopyRates of ",_Symbol," failed, no history");
      return;
     }
   if(rt[0].volume>1) return;
//--- get current Moving Average 
   double   ma[2];
   if(CopyBuffer(ExtHandle,0,0,1,ma)!=1)
     {
      Print("CopyBuffer from iMA failed, no data");
      return;
     }
//---- sell conditions
   if(rt[1].open>ma[0] && rt[1].close<ma[0])
     {
      CTrade trade;
      trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,TradeSizeOptimized(),SymbolInfoDouble(_Symbol,SYMBOL_BID),0,0);
      return;
     }
//---- buy conditions
   if(rt[1].open<ma[0] && rt[1].close>ma[0])
     {
      CTrade trade;
      trade.PositionOpen(_Symbol,ORDER_TYPE_BUY,TradeSizeOptimized(),SymbolInfoDouble(_Symbol,SYMBOL_ASK),0,0);

      //res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue);
      return;
     }
//----
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {
   MqlRates rt[2];
//--- go trading only for first ticks of new bar
   if(CopyRates(_Symbol,_Period,0,2,rt)!=2)
     {
      Print("CopyRates of ",_Symbol," failed, no history");
      return;
     }
   if(rt[0].volume>1) return;
//--- get current Moving Average 
   double   ma[2];
   if(CopyBuffer(ExtHandle,0,0,1,ma)!=1)
     {
      Print("CopyBuffer from iMA failed, no data");
      return;
     }
//--- positions already selected before
   long type=PositionGetInteger(POSITION_TYPE);

   if(type==POSITION_TYPE_BUY)
     {
      if(rt[1].open>ma[0] && rt[1].close<ma[0])
        {
         CTrade trade;
         trade.PositionClose(_Symbol,3);
         return;
        }
     }

   if(type==POSITION_TYPE_SELL)
     {
      if(rt[1].open<ma[0] && rt[1].close>ma[0])
        {
         CTrade trade;
         trade.PositionClose(_Symbol,3);
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ExtHandle=iMA(_Symbol,_Period,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE);
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- check for history and trading
   if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
      if(Bars(_Symbol,_Period)>100)
        {
         if(PositionSelect(_Symbol,50)) CheckForClose();
         else                           CheckForOpen();
        }
//---
  }
//+------------------------------------------------------------------+
