//+------------------------------------------------------------------+
//|                                                FannIndicator.mq5 |
//|                                                          pyroman |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "pyroman"
#property link      "http://www.mql5.com"
#property version   "1.00"

//#include <Fractals.mqh>

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot Label1
#property indicator_label1  "BuySignal"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label2  "SellSignal"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  Blue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         Label1Buffer[];
double         Label2Buffer[];
double         Show1Buffer[];
double         Show2Buffer[];

int h_fract=0;

double         up_line[];
double         down_line[];

input int BARS=200; //Количество баров для расчета
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   SetIndexBuffer(0,Show1Buffer,INDICATOR_DATA);
   ArrayInitialize(Show1Buffer,EMPTY_VALUE);
   ArraySetAsSeries(Show1Buffer,true);
   SetIndexBuffer(1,Show2Buffer,INDICATOR_DATA);
   ArrayInitialize(Show2Buffer,EMPTY_VALUE);
   ArraySetAsSeries(Show2Buffer,true);

   SetIndexBuffer(2,Label1Buffer,INDICATOR_CALCULATIONS);
   ArrayInitialize(Label1Buffer,EMPTY_VALUE);
   ArraySetAsSeries(Label1Buffer,true);
   SetIndexBuffer(3,Label2Buffer,INDICATOR_CALCULATIONS);
   ArrayInitialize(Label2Buffer,EMPTY_VALUE);
   ArraySetAsSeries(Label2Buffer,true);

   h_fract=iFractals(Symbol(),Period());

//   PlotIndexSetInteger(0,PLOT_SHIFT,5);
   Print("FarctalsIndicator инициализирован. h_fract="+(string)h_fract);

//---
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(h_fract);
   Print("FarctalsIndicator деинициализирован.");
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
   int i;

   CopyBuffer(h_fract,0,0,rates_total,up_line);
   CopyBuffer(h_fract,1,0,rates_total,down_line);
   ArraySetAsSeries(up_line,true);
   ArraySetAsSeries(down_line,true);

   int first=2,sec=0;
   double max_up=0; //актуальный максимум
   while((first<rates_total) && (first<BARS))
     {
      if((down_line[first])!=EMPTY_VALUE)
        {
         double max_up_tmp=0; //локальный максимум (между двумя точками)
         for(i=sec; i<first;i++)
           {
            if((up_line[i]!=EMPTY_VALUE) && (up_line[i]>max_up_tmp))
              {
               max_up_tmp=up_line[i];
              }
           }
         if(max_up_tmp>0)
           {
            max_up=max_up_tmp;
           }

         if(max_up>0)
           {
            if((max_up_tmp>0) || (down_line[first]<down_line[sec]))
              {
               Label1Buffer[first]=(max_up-down_line[first])/_Point;
              }
           }
         sec=first;
        }
      else
        {
         Label1Buffer[first]=EMPTY_VALUE;
        }
      first+=1;
     }

   first=2;
   sec=0;
   double min_down=0; //актуальный минимум
   while((first<rates_total) && (first<BARS))
     {
      if((up_line[first])!=EMPTY_VALUE)
        {
         double min_down_tmp=0; //локальный максимум (между двумя точками)
         for(i=sec; i<first;i++)
           {
            if((down_line[i]!=EMPTY_VALUE) && ((min_down_tmp==0) || (down_line[i]<min_down_tmp)))
              {
               min_down_tmp=down_line[i];
              }
           }
         if(min_down_tmp>0)
           {
            min_down=min_down_tmp;
           }

         if(min_down>0)
           {
            if((min_down_tmp>0) || (up_line[first]>up_line[sec]))
              {
               Label2Buffer[first]=(min_down-up_line[first])/_Point;
              }
           }
         sec=first;
        }
      else
        {
         Label2Buffer[first]=EMPTY_VALUE;
        }
      first+=1;
     }

//Дискретизация 
   for(i=0;(i<BARS) && (i<rates_total); i++)
     {
      if(Label1Buffer[i]!=EMPTY_VALUE)
        {
         if((Label1Buffer[i]>0) && (Label1Buffer[i]<=30)) Label1Buffer[i]=0;
         else if((Label1Buffer[i]>30) && (Label1Buffer[i]<=60)) Label1Buffer[i]=1;
         else if((Label1Buffer[i]>60) && (Label1Buffer[i]<=100)) Label1Buffer[i]=2;
         else if((Label1Buffer[i]>100) &&(Label1Buffer[i]<=150)) Label1Buffer[i]=3;
         else if(Label1Buffer[i]>150) Label1Buffer[i]=4;
        }
      if(Label2Buffer[i]!=EMPTY_VALUE)
        {
         if((Label2Buffer[i]<0) && (Label2Buffer[i]>=-30)) Label2Buffer[i]=0;
         else if((Label2Buffer[i]<-30) && (Label2Buffer[i]>=-60)) Label2Buffer[i]=-1;
         else if((Label2Buffer[i]<-60) && (Label2Buffer[i]>=-100)) Label2Buffer[i]=-2;
         else if((Label2Buffer[i]<-100) &&(Label2Buffer[i]>=-150)) Label2Buffer[i]=-3;
         else if(Label2Buffer[i]<-150) Label2Buffer[i]=-4;
        }
     }
/*ArrayCopy(Show1Buffer,Label1Buffer);
ArrayCopy(Show2Buffer,Label2Buffer);*/
//Приведение к нормальному распределению
//Счетчики количества значений
   int plus[5];
   ArrayInitialize(plus,0);
   for(i=0;(i<BARS) && (i<rates_total); i++)
     {
      if(Label1Buffer[i]!=EMPTY_VALUE)
        {
         if(Label1Buffer[i]==0) plus[0]+=1;
         else if(Label1Buffer[i]==1) plus[1]+=1;
         else if(Label1Buffer[i]==2) plus[2]+=1;
         else if(Label1Buffer[i]==3) plus[3]+=1;
         else if(Label1Buffer[i]==4) plus[4]+=1;
        }
     }
   int plus_total=plus[0]+plus[1]+plus[2]+plus[3]+plus[4];

//Вычисление значений   
   double a=0,b=0;
   double plus_value[5];
   for(i=0; i<5; i++)
     {
      a=(double)plus[i]/(double)plus_total;
      plus_value[i]=(a/2)+b;
      b+=a;
     }
   //Print("a=",a);
   //Print("plus[0]=",plus[0]);
   //Print("plus[1]=",plus[1]);
   //Print("plus[2]=",plus[2]);
   //Print("plus[3]=",plus[3]);
   //Print("plus[4]=",plus[4]);
   //Print("plus_total=",plus_total);
   //Print("plus_value[0]=",plus_value[0]);
   //Print("plus_value[1]=",plus_value[1]);
   //Print("plus_value[2]=",plus_value[2]);
   //Print("plus_value[3]=",plus_value[3]);
   //Print("plus_value[4]=",plus_value[4]);

   int minus[5];
   ArrayInitialize(minus,0);
   for(i=0;(i<BARS) && (i<rates_total); i++)
     {
      if(Label2Buffer[i]!=EMPTY_VALUE)
        {
         if(Label2Buffer[i]==0) minus[0]+=1;
         else if(Label2Buffer[i]==-1) minus[1]+=1;
         else if(Label2Buffer[i]==-2) minus[2]+=1;
         else if(Label2Buffer[i]==-3) minus[3]+=1;
         else if(Label2Buffer[i]==-4) minus[4]+=1;
        }
     }
   int minus_total=minus[0]+minus[1]+minus[2]+minus[3]+minus[4];
//Вычисление значений   
   a=0;
   b=0;
   double minus_value[5];
   for(i=0; i<5; i++)
     {
      a=(double)minus[i]/(double)minus_total;
      minus_value[i]=b-(a/2);
      b-=a;
     }

   //Print("a=",a);
   //Print("minus[0]=",minus[0]);
   //Print("minus[1]=",minus[1]);
   //Print("minus[2]=",minus[2]);
   //Print("minus[3]=",minus[3]);
   //Print("minus[4]=",minus[4]);
   //Print("minus_total=",minus_total);
   //Print("minus_value[0]=",minus_value[0]);
   //Print("minus_value[1]=",minus_value[1]);
   //Print("minus_value[2]=",minus_value[2]);
   //Print("minus_value[3]=",minus_value[3]);
   //Print("minus_value[4]=",minus_value[4]);

//Замена значений в буферах   
   for(i=0;(i<BARS) && (i<rates_total); i++)
     {
      if(Label1Buffer[i]!=EMPTY_VALUE)
        {
         Show1Buffer[i]=plus_value[Label1Buffer[i]];
         //            Show1Buffer[i]=Label1Buffer[i];
        }
      if(Label2Buffer[i]!=EMPTY_VALUE)
        {
         Show2Buffer[i]=minus_value[-Label2Buffer[i]];
         //            Show2Buffer[i]=Label2Buffer[i];
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
