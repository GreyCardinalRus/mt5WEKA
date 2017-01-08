//+------------------------------------------------------------------+
//|                                                        iNRTR.mq5 |
//|                                        MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
//--- plot Support
#property indicator_label1  "Support"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  DodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Resistance
#property indicator_label2  "Resistance"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot UpTarget
#property indicator_label3  "UpTarget"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  RoyalBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot DnTarget
#property indicator_label4  "DnTarget"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  Crimson
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2


//--- input parameters
input int      period   =  40;   /*period*/  // ������ ATR � �����
input double   k        =  2.0;  /*k*/       // ���������� ��������� �������� ATR   

//--- indicator buffers
double         SupportBuffer[];
double         ResistanceBuffer[];
double         UpTargetBuffer[];
double         DnTargetBuffer[];
double         Trend[];
double         ATRBuffer[];
int Handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,SupportBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_ARROW,159);
   
   SetIndexBuffer(1,ResistanceBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_ARROW,159);
   
   SetIndexBuffer(2,UpTargetBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(2,PLOT_ARROW,158);
   
   SetIndexBuffer(3,DnTargetBuffer,INDICATOR_DATA);   
   PlotIndexSetInteger(3,PLOT_ARROW,158);
   
   SetIndexBuffer(4,Trend,INDICATOR_DATA);      
   
   SetIndexBuffer(5,ATRBuffer,INDICATOR_CALCULATIONS);  
   
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);   
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);   
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);   
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0); 
     
   Handle=iATR(_Symbol,PERIOD_CURRENT,period);
   
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime & time[],
                 const double & open[],
                 const double & high[],
                 const double & low[],
                 const double & close[],
                 const long & tick_volume[],
                 const long & volume[],
                 const int & spread[]
               ){
   static bool error=true;
   int start;
      if(prev_calculated==0){
         error=true;
      }
      if(error){
         ArrayInitialize(Trend,0);
         ArrayInitialize(UpTargetBuffer,0);         
         ArrayInitialize(DnTargetBuffer,0);         
         ArrayInitialize(SupportBuffer,0); 
         ArrayInitialize(ResistanceBuffer,0);       
         start=period;
         error=false;
      }
      else{
         start=prev_calculated-1;
      }
      if(CopyBuffer(Handle,0,0,rates_total-start,ATRBuffer)==-1){
         error=true;
         return(0);
      }
      for(int i=start;i<rates_total;i++){
         Trend[i]=Trend[i-1];
         UpTargetBuffer[i]=UpTargetBuffer[i-1];
         DnTargetBuffer[i]=DnTargetBuffer[i-1];
         SupportBuffer[i]=SupportBuffer[i-1];
         ResistanceBuffer[i]=ResistanceBuffer[i-1];
            switch((int)Trend[i]){
               case 2:
                  if(low[i]>UpTargetBuffer[i]){
                     UpTargetBuffer[i]=close[i];
                     SupportBuffer[i]=close[i]-k*ATRBuffer[i];
                  }  
                  if(close[i]<SupportBuffer[i]){
                     DnTargetBuffer[i]=close[i];
                     ResistanceBuffer[i]=close[i]+k*ATRBuffer[i];
                     Trend[i]=3;
                     UpTargetBuffer[i]=0;
                     SupportBuffer[i]=0;
                  }         
               break;
               case 3:
                  if(high[i]<DnTargetBuffer[i]){
                     DnTargetBuffer[i]=close[i];
                     ResistanceBuffer[i]=close[i]+k*ATRBuffer[i];
                  }  
                  if(close[i]>ResistanceBuffer[i]){
                     UpTargetBuffer[i]=close[i];
                     SupportBuffer[i]=close[i]-k*ATRBuffer[i];
                     Trend[i]=2;
                     DnTargetBuffer[i]=0;
                     ResistanceBuffer[i]=0;
                  }                                  
               break;            
               case 0:
                  UpTargetBuffer[i]=close[i];
                  DnTargetBuffer[i]=close[i];
                  Trend[i]=1;
               break;
               case 1:
                  if(low[i]>UpTargetBuffer[i]){
                     UpTargetBuffer[i]=close[i];
                     SupportBuffer[i]=close[i]-k*ATRBuffer[i];
                     Trend[i]=2;
                     DnTargetBuffer[i]=0;
                  }
                  if(high[i]<DnTargetBuffer[i]){
                     DnTargetBuffer[i]=close[i];
                     ResistanceBuffer[i]=close[i]+k*ATRBuffer[i];
                     Trend[i]=3;
                     UpTargetBuffer[i]=0;
                  }                  
               break;
         }
         
      }
   return(rates_total);               
}

//+------------------------------------------------------------------+
