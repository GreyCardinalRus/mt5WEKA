//+------------------------------------------------------------------+
//|                                                      Volumes.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Green,Red
#property indicator_style1  0
#property indicator_width1  1
#property indicator_minimum 0.0
//--- input data
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes
//---- indicator buffers
double                    ExtVolumesBuffer[];
double                    ExtColorsBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- buffers   
   SetIndexBuffer(0,ExtVolumesBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"GC Analizer");
//---- indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   ArraySetAsSeries(ExtVolumesBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);
//----
  }
//+------------------------------------------------------------------+
//|  Volumes                                                         |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(Close,true);

//---check for rates total
   if(rates_total<2)
      return(0);
//--- starting work
   int start=prev_calculated-1;
//--- correct position
   if(start<1) start=1;
//--- main cycle
   string smbl=_Symbol;double res;
   int      TrailingStop=(int)(2*SymbolInfoInteger(smbl,SYMBOL_SPREAD));
   if(TrailingStop<55) TrailingStop=55;
   //Print(TrailingStop);
   for(int i=start;i<rates_total;i++)
     {
      res=(High[i]-Low[i])/(TrailingStop*SymbolInfoDouble(smbl,SYMBOL_POINT));
      ExtVolumesBuffer[i]=res;
      if(res<1)
         ExtColorsBuffer[i]=0.0;
      else
         ExtColorsBuffer[i]=1.0;
     }

//   if(InpVolumeType==VOLUME_TICK)
//      CalculateVolume(start,rates_total,TickVolume);
//   else
//      CalculateVolume(start,rates_total,Volume);
////--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateVolume(const int nPosition,
                     const int nRatesCount,
                     const long &SrcBuffer[])
  {
   ExtVolumesBuffer[0]=SrcBuffer[0];
   ExtColorsBuffer[0]=0.0;
//---
   for(int i=nPosition;i<nRatesCount;i++)
     {
      //--- get some data from src buffer
      double dCurrVolume=SrcBuffer[i];
      double dPrevVolume=SrcBuffer[i-1];
      //--- calculate indicator
      ExtVolumesBuffer[i]=dCurrVolume;
      if(dCurrVolume>dPrevVolume)
         ExtColorsBuffer[i]=0.0;
      else
         ExtColorsBuffer[i]=1.0;
     }
//---
  }
//+------------------------------------------------------------------+
