//+------------------------------------------------------------------+
//|                                                    ShowTrend.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <GC\Oracle.mqh>
#include <GC\CommonFunctions.mqh>
#property indicator_separate_window
#property indicator_minimum -1.0
#property indicator_level1  -0.666
#property indicator_level2  -0.333
#property indicator_level3  0.333
#property indicator_level4  0.666
#property indicator_maximum 1.0
#property indicator_buffers 2 
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrBlack,clrRed,clrYellow,clrPurple,clrBlue,clrLime
#property indicator_style1  0
#property indicator_width1  1
//--- indicator buffers
double                    ExtVolumesBuffer[];
double                    ExtColorsBuffer[];

input int  _limit_=5000;// на сколько баров уходить назад
    
COracleENCOG* MyOracles;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  MyOracles =new COracleENCOG("Encog");
//---- buffers   
   SetIndexBuffer(0,ExtVolumesBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"GC Oracle encog trend");
//---- indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,3);
   ArraySetAsSeries(ExtVolumesBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);
    return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OnDeinit(const int reason)
  {
 //  MyOracles.DeInit();
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
     // ArrayInitialize(Label1Buffer,EMPTY_VALUE);
     // ArrayInitialize(Label2Buffer,EMPTY_VALUE);
     }
   else limit=100;
   double res;

  //// DelTrash();
   for(i=1;i<_limit_;i++)
     {
     //if(_TREND_>i) continue;
      res=MyOracles.forecast(_Symbol,i,true,"");
      ExtVolumesBuffer[i]=res;
      ExtColorsBuffer[i]=3.0;
      if(res<-0.66)
         ExtColorsBuffer[i]=1.0;
      else if(res<-0.33)
         ExtColorsBuffer[i]=2.0;
      else if(res<0.33)
         ExtColorsBuffer[i]=3.0;
      else if(res<0.66)
         ExtColorsBuffer[i]=4.0;
       else
         ExtColorsBuffer[i]=5.0;

     }
     //if (res>0)  Label1Buffer[i+_TREND_]=res;
      //else Label2Buffer[i+_TREND_]=res;
   // }
//--- OnCalculate done. Return new prev_calculated.

   return(rates_total);
  }
//+------------------------------------------------------------------+
