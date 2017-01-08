//+------------------------------------------------------------------+
//|                                                        Dummy.mq5 |
//|                                             Copyright 2010, alsu |
//|                                                 alsufx@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, alsu"
#property link      "alsufx@gmail.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 3
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1
#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double         DummyBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,DummyBuffer,INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME,"GNG_dummy");
//---
   return(0);
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
//--- пустой буфер
   ArrayInitialize(DummyBuffer,EMPTY_VALUE);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
