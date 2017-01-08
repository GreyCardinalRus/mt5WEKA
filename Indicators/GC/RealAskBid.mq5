//+------------------------------------------------------------------+
//|                                               Price_Channell.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_type1   DRAW_FILLING
#property indicator_type2   DRAW_LINE
#property indicator_color1  Red,Blue
#property indicator_color2  Purple
#property indicator_label1  "Channel Buy;Channel Sell"
#property indicator_label2  "Channel median"
//--- input parameters
input int InpChannelPeriod=1; // Periody
//--- indicator buffers
double    ExtHighBuffer[];
double    ExtLowBuffer[];
double    ExtMiddBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtMiddBuffer,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpChannelPeriod);
//---- line shifts when drawing
   PlotIndexSetInteger(0,PLOT_SHIFT,1);
   PlotIndexSetInteger(1,PLOT_SHIFT,1);
//--- name for DataWindow and indicator label
   IndicatorSetString(INDICATOR_SHORTNAME,"Price Channel("+string(InpChannelPeriod)+")");
   PlotIndexSetString(0,PLOT_LABEL,"Channel("+string(InpChannelPeriod)+") upper;Channel("+string(InpChannelPeriod)+") lower");
   PlotIndexSetString(1,PLOT_LABEL,"Median("+string(InpChannelPeriod)+")");
//--- set drawing line empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- initialization done
  }
//+------------------------------------------------------------------+
//| get highest value for range                                      |
//+------------------------------------------------------------------+
double Highest(const double &array[],int range,int fromIndex,double TS)
  {
   double res;
   int i;
//---
   res=array[fromIndex]-TS;
   for(i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res<(array[i]-TS)) res=array[i]-TS;
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| get lowest value for range                                       |
//+------------------------------------------------------------------+
double Lowest(const double &array[],int range,int fromIndex,double TS)
  {
   double res;
   int i;
//---
   res=array[fromIndex]+TS;
   for(i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res>(array[i]+TS)) res=array[i]+TS;
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| Price Channell                                                   |
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
   double  TS,_NumTS_=1;
        TS=SymbolInfoDouble(_Symbol,SYMBOL_POINT)*(_NumTS_*SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL));

//--- check for rates
   if(rates_total<InpChannelPeriod)
      return(0);
//--- preliminary calculations
   if(prev_calculated==0)
      limit=InpChannelPeriod;
   else limit=prev_calculated-1;
//--- the main loop of calculations
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtHighBuffer[i]=Highest(high,InpChannelPeriod,i,TS);
      ExtLowBuffer[i]=Lowest(low,InpChannelPeriod,i,TS);
      if(ExtLowBuffer[i]>ExtHighBuffer[i]) ExtLowBuffer[i]=ExtHighBuffer[i];
      ExtMiddBuffer[i]=(ExtHighBuffer[i]+ExtLowBuffer[i])/2.0;;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
