//+------------------------------------------------------------------+
//|                                                        Ticks.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Bid
#property indicator_label1  "Bid"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Blue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Ask
#property indicator_label2  "Ask"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input int      number_of_ticks=1000;
input int      points_indent=10;
//--- indicator buffers
double         BidBuffer[];
double         AskBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BidBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,AskBuffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//---
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
   static int ticks=0;
//---
   if(ticks==0)
     {
      ArrayInitialize(AskBuffer,0);
      ArrayInitialize(BidBuffer,0);
     }
   setMaxMinPrice(ticks,points_indent);
//---
   MqlTick last_tick;
   if(SymbolInfoTick(Symbol(),last_tick))
     {
      BidBuffer[ticks]=last_tick.bid;
      AskBuffer[ticks]=last_tick.ask;
      int shift=rates_total-1-ticks;
      ticks++;
      BidBuffer[rates_total-1]=last_tick.bid;
      AskBuffer[rates_total-1]=last_tick.ask;
      PlotIndexSetInteger(0,PLOT_SHIFT,shift);
      PlotIndexSetInteger(1,PLOT_SHIFT,shift);
      Comment("Bid =",last_tick.bid,"   Ask =",last_tick.ask);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| set Maximum and Minimum for an indicator window based on last values
//+------------------------------------------------------------------+
void setMaxMinPrice(int last_values,int indent)
  {
   int visiblebars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
   int depth=MathMin(last_values,visiblebars);
   int startindex=last_values-depth;
   if(startindex<0) startindex=0;
   int max_index=ArrayMaximum(AskBuffer,startindex,depth);
   max_index=max_index>=0?max_index:0;
   int min_index=ArrayMinimum(BidBuffer,startindex,depth);
   min_index=min_index>=0?min_index:0;
   double MaxPrice=AskBuffer[max_index]+indent*_Point;
   double MinPrice=BidBuffer[min_index]-indent*_Point;
   IndicatorSetDouble(INDICATOR_MAXIMUM,MaxPrice);
   IndicatorSetDouble(INDICATOR_MINIMUM,MinPrice);
  }
//+------------------------------------------------------------------+
