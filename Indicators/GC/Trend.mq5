//+------------------------------------------------------------------+
//|                                                         Fann.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//#include <GC\MT5FANN.mqh>
#include <GC\GetVectors.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_color1  Yellow
#property indicator_color2  Blue
#property indicator_label1  "Price High"
#property indicator_label2  "Price Low"
//---- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
input int _TREND_=20;// на сколько смотреть вперед
input int  _limit_=3000;// на сколько баров уходить назад

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int)

  {
  DelTrash();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//---- arrow shifts when drawing
//   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ExtArrowShift);
//   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ExtArrowShift);
//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initialization done
   ArraySetAsSeries(ExtUpperBuffer,true);
   ArraySetAsSeries(ExtLowerBuffer,true);
//mt5fann.debug=true;

//   if(!mt5fannHigh.Init("High")) Print("Init error");
//   if(!mt5fannLow.Init("Low")) Print("Init error");
   //Print("SYMBOL_SPREAD=",SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)," SYMBOL_TRADE_STOPS_LEVEL =",SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL));
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int i,limit;
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);

//---
   if(rates_total<1)
      return(0);
      if(prev_calculated==rates_total)return(rates_total);
//---
   if(prev_calculated<1)
     {
      limit=_limit_;
      //--- clean up arrays
      ArrayInitialize(ExtUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer,EMPTY_VALUE);
     }
   else limit=100;
   double res;

   DelTrash();

   for(i=1;i<_limit_;i++)
     {
      res=GetTrend(_TREND_,_Symbol,0,i,true);
    }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
