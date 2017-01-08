//+------------------------------------------------------------------+
//|                                                   PriceRange.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//#property indicator_chart_window

#property indicator_separate_window
#property indicator_plots   1
#property indicator_buffers 1

//--- plot Label1
#property indicator_label1  "Price range"
#property indicator_type1   DRAW_HISTOGRAM

#property indicator_color1  Red,Green
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1



#include <PriceRange.mqh>

double PriceRangeBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,PriceRangeBuffer,INDICATOR_DATA);
   ArraySetAsSeries(PriceRangeBuffer,true);
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

   ArraySetAsSeries(time,true);

   int needcalc;
   if(prev_calculated==0)
      needcalc=120;
   else
      needcalc=1;

   for(int i=0;i<needcalc;i++)
     { 
     //Print(time[i]);

      PriceRangeBuffer[i]=PriceRange(_Symbol,_Period,time[i], 8);

     }

//--- return value of prev_calculated for next call
   return(needcalc);
  }
//+------------------------------------------------------------------+
