//+------------------------------------------------------------------+
//|                                                      Candels.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#include <gc\Candels.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
input int ComeBack=1000;// Сколько баров назад
int OnInit()
  {
//--- indicator buffers mapping
//---
      for(int i=ObjectsTotal(0);i>=0;i--)
         if(StringSubstr(ObjectName(0,i),0,4)=="cnd_") ObjectDelete(0,ObjectName(0,i));


   return(0);
  }
void OnDeinit(const int reason)
{
      for(int i=ObjectsTotal(0);i>=0;i--)
         if(StringSubstr(ObjectName(0,i),0,4)=="cnd_") ObjectDelete(0,ObjectName(0,i));


}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
//---
//--- return value of prev_calculated for next call
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   int i;
   int needcalk=rates_total-prev_calculated;
   if(needcalk>ComeBack) needcalk=ComeBack;
   if(needcalk<1) return(prev_calculated);
   //Print(needcalk++);
   int dist=PeriodSeconds(_Period)/60;
   for(i=1;i<needcalk;i++)
    { // бежим по истории...
     Candel_Type ct=IsCandel(_Symbol,_Period,i);
     switch(ct)
     { 
      case CT_None:// ничего
       break;
      // buy
      case CT_HangingMan:// белое эскимо
        ObjectCreate(0,"cnd_HM_"+(string)time[i],OBJ_ARROW_BUY,0,time[i],high[i]+SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
      case CT_BlackEscimo:// черное эскимо
        ObjectCreate(0,"cnd_BE_"+(string)time[i],OBJ_ARROW_BUY,0,time[i],high[i]+SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
      case CT_BlackHummer:// черное эскимо
        ObjectCreate(0,"cnd_BH_"+(string)time[i],OBJ_ARROW_BUY,0,time[i],high[i]+SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
      case CT_WhiteEscimo:// белое эскимо
        ObjectCreate(0,"cnd_WE_"+(string)time[i],OBJ_ARROW_BUY,0,time[i],high[i]+SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
      case CT_WhiteHummer:// белое эскимо
        ObjectCreate(0,"cnd_WH_"+(string)time[i],OBJ_ARROW_BUY,0,time[i],high[i]+SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
      // sell
      case CT_ShootingStar:// белое эскимо
        ObjectCreate(0,"cnd_SS_"+(string)time[i],OBJ_ARROW_SELL,0,time[i],low[i]-SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
      case CT_RBlackEscimo:// черное эскимо
        ObjectCreate(0,"cnd_RBE_"+(string)time[i],OBJ_ARROW_SELL,0,time[i],low[i]-SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
      case CT_RBlackHummer:// черное эскимо
        ObjectCreate(0,"cnd_RBH_"+(string)time[i],OBJ_ARROW_SELL,0,time[i],low[i]-SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
      case CT_RWhiteEscimo:// белое эскимо
        ObjectCreate(0,"cnd_RWE_"+(string)time[i],OBJ_ARROW_SELL,0,time[i],low[i]-SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
      case CT_RWhiteHummer:// белое эскимо
        ObjectCreate(0,"cnd_RWH_"+(string)time[i],OBJ_ARROW_SELL,0,time[i],low[i]-SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
      case CT_Doji:// белое эскимо
  //      ObjectCreate(0,"cnd_DJ_"+(string)time[i],OBJ_ARROW,0,time[i],low[i]); 
       break;
      default: 
       ObjectCreate(0,"cnd_IDK_"+(string)time[i],OBJ_ARROW_LEFT_PRICE,0,time[i],low[i]-SymbolInfoDouble(_Symbol,SYMBOL_POINT)*dist); 
       break;
     }
   //  Print(time[i]," ",ct);
   }
   return(rates_total);
  }
//+------------------------------------------------------------------+
