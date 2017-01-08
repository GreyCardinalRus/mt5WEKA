//+------------------------------------------------------------------+
//| ColorLine.mq5 |
//| Copyright 2009, MetaQuotes Software Corp. |
//| http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link "http://www.mql5.com"

#property indicator_chart_window
//#property indicator_separate_window

#property indicator_buffers 3
#property indicator_plots 3
//---- plot ColorLine
#property indicator_label1 "Curr1"
#property indicator_type1 DRAW_LINE
#property indicator_color1 Red,Green,Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Curr2"
#property indicator_type2 DRAW_LINE
#property indicator_color2 Green,Blue,Red
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Curr3"
#property indicator_type3 DRAW_LINE
#property indicator_color3 Blue,Red,Green
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
//--- indicator buffers
double LineBuffer0[],ColorsBuffer0[];
double LineBuffer1[],ColorsBuffer1[];
double LineBuffer2[],ColorsBuffer2[];
//---
string smbls[]={"EURUSD","GBPUSD","AUDUSD"};

int ExtMAHandle0,ExtMAHandle1,ExtMAHandle2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
void OnInit()
  {
   int rt=1000;
   int limit,copied0,copied1,copied2;
//--- indicator buffers mapping
   SetIndexBuffer(0,LineBuffer0,INDICATOR_DATA);
   SetIndexBuffer(1,LineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,LineBuffer2,INDICATOR_DATA);
   ArraySetAsSeries(LineBuffer0,true);
   ArraySetAsSeries(LineBuffer1,true);
   ArraySetAsSeries(LineBuffer2,true);

//  copied0=CopyClose(smbls[0],PERIOD_CURRENT,0,rt,LineBuffer0);
//  copied1=CopyClose(smbls[1],PERIOD_CURRENT,0,rt,LineBuffer1);
//  copied2=CopyClose(smbls[2],PERIOD_CURRENT,0,rt,LineBuffer2);
////--- now set line color for every bar
// Print("cp=",copied0,copied1,copied2);
//  for(int i=0;i<rt;i++)
//  {
//   LineBuffer1[i]=LineBuffer1[i]+LineBuffer0[0]-LineBuffer1[0];
//   LineBuffer2[i]=LineBuffer2[i]+LineBuffer0[0]-LineBuffer2[0];
//  }
//ChartRedraw();
// SetIndexBuffer(1,ColorsBuffer1,INDICATOR_COLOR_INDEX);
//SetIndexBuffer(3,LineBuffer2,INDICATOR_DATA);
//SetIndexBuffer(4,ColorsBuffer2,INDICATOR_COLOR_INDEX);
//--- get MA handle
// ExtMAHandle0=iMA(smbls[0],0,1,0,MODE_EMA,PRICE_CLOSE);
// ExtMAHandle1=iMA(smbls[0],0,2,0,MODE_EMA,PRICE_CLOSE);
//ExtMAHandle2=iMA(smbls[0],0,3,0,MODE_EMA,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
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
   static int ticks=0,modified=0;
   int rt;
   rt=rates_total;
   int limit,copied0,copied1,copied2;
//--- check data
// int calculated=BarsCalculated(ExtMAHandle0);
// int calculated1=BarsCalculated(ExtMAHandle1);
//int calculated2=BarsCalculated(ExtMAHandle2);
// Print("clc",calculated,calculated1,calculated2);
// if(calculated<rates_total)
// {
// Print("Not all data of ExtMAHandle is calculated (",calculated,"bars ). Error",GetLastError());
// return(0);
// }
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      //--- copy values of MA into indicator buffer ExtColorLineBuffer
      // CopyClose(smbls[0],0,0,shiftbars,EURUSD)
      copied0=CopyClose(smbls[0],PERIOD_CURRENT,0,rt,LineBuffer0);
      copied1=CopyClose(smbls[1],PERIOD_CURRENT,0,rt,LineBuffer1);
      copied2=CopyClose(smbls[2],PERIOD_CURRENT,0,rt,LineBuffer2);
      //--- now set line color for every bar
      // Print("cp=",copied0,copied1,copied2);
      double res;
      for(int i=1;i<rt;i++)
        {
         LineBuffer1[i]=LineBuffer1[i]+LineBuffer0[20]-LineBuffer1[20];
         LineBuffer2[i]=LineBuffer2[i]+LineBuffer0[20]-LineBuffer2[20];
        }
     }
   else
     {
      //--- we can copy not all data
      int to_copy;
      if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
      else
        {
         to_copy=rates_total-prev_calculated;
         if(prev_calculated>0) to_copy++;
        }
      to_copy=20;
      //--- copy values of MA into indicator buffer ExtColorLineBuffer
      copied0=CopyClose(smbls[0],0,0,to_copy,LineBuffer0);
      copied1=CopyClose(smbls[1],0,0,to_copy,LineBuffer1);
      copied2=CopyClose(smbls[2],0,0,to_copy,LineBuffer2);
      // Print("cp=",copied0,copied1,copied2);
      //double res;
      for(int i=1;i<to_copy;i++)
        {
         //Print(i,"]",res,"=",LineBuffer1[i],"+",LineBuffer0[0],"-",LineBuffer1[0]);
         LineBuffer1[i]=LineBuffer1[i]+LineBuffer0[to_copy]-LineBuffer1[to_copy];
         LineBuffer2[i]=LineBuffer2[i]+LineBuffer0[to_copy]-LineBuffer2[to_copy];
        }
     }
//--- return value of prev_calculated for next call
   ChartRedraw();
   return(rates_total);
  }
//+------------------------------------------------------------------+
