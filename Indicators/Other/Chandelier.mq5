#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2

#property indicator_label1  "Up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Blue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Dn"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//---- input parameters
input int     Length=5;
input int     ATRperiod=15;
input double  Kv=2.5;
input int     Shift=1;

//---- indicator buffers
double UpBuffer1[];
double DnBuffer1[];
double smin[];
double smax[];
double trend[];

int atr_handle;

//+------------------------------------------------------------------+
int OnInit() {

   SetIndexBuffer(0,UpBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,smin,INDICATOR_DATA);
   SetIndexBuffer(3,smax,INDICATOR_DATA);
   SetIndexBuffer(4,trend,INDICATOR_DATA);
   
   atr_handle = iATR(_Symbol,0,ATRperiod);
   
   return(0);
}
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
   int pos,start;
   double buf_atr[];
   
//--- starting calculation
   if(prev_calculated > 1) 
      pos = prev_calculated-1;
   else 
      pos = 0;
   
   CopyBuffer(atr_handle,0,0,rates_total-pos,buf_atr);

//--- main cycle
   for(int i=pos;i<rates_total;i++)
   {
      
      if(i-Shift-Length < 0) start=0;
      else  start = i-Shift-Length;
      
      smin[i]=high[ArrayMaximum(high, start,Length)] - Kv * buf_atr[i-pos];
      smax[i]=low[ArrayMinimum(low, start, Length)] + Kv * buf_atr[i-pos];
      
      if(i>0)  
      {        
         trend[i]=trend[i-1];
        
         if(close[i] > smax[i-1])trend[i]= 1;         
         if(close[i] < smin[i-1])trend[i]=-1;
         
         if(trend[i] >0)
           {
            if(smin[i]<smin[i-1])smin[i]=smin[i-1];
            UpBuffer1[i]=smin[i];
            DnBuffer1[i]=EMPTY_VALUE;
           }
         if(trend[i] <0)
           {
            if(smax[i]>smax[i-1])smax[i]=smax[i-1];
            UpBuffer1[i]=EMPTY_VALUE;
            DnBuffer1[i]=smax[i];
           }
      }
      
      if(1==2 && pos == rates_total - 1)
      {
         Print("smin[i]"+smin[i]);
      }
   }
   return(rates_total);
}
//+------------------------------------------------------------------+