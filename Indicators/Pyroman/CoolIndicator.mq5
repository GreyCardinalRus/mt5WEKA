//+------------------------------------------------------------------+
//|                                                FannIndicator.mq5 |
//|                                                          pyroman |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "pyroman"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label2  "Label2"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  Blue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         Label1Buffer[];
double         Label2Buffer[];

input int BARS=5; //Количество баров для расчета
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Label1Buffer,INDICATOR_DATA);
   ArraySetAsSeries(Label1Buffer,true);
   SetIndexBuffer(1,Label2Buffer,INDICATOR_DATA);
   ArraySetAsSeries(Label2Buffer,true);

//   PlotIndexSetInteger(0,PLOT_SHIFT,5);


//---
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

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
//---
   int i,r;

   ArraySetAsSeries(close,true);

   int weight;
   for(r=BARS; r<rates_total; r++)
     {
      double a=0,b=0,c=0;
      for(i=r,weight=BARS;i>r-BARS;i--,weight--)
        {

         c=weight*(close[i-1]-close[i]);
         a+=c;
         b+=MathAbs(c);

        }
      if (a>0) Label1Buffer[r]=a/b;
      else if (a<0) Label2Buffer[r]=a/b;
/*      if (a>0) Label1Buffer[r]=a/b;
      Label2Buffer[r]=1000*(close[r-1]-close[r]);*/
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
