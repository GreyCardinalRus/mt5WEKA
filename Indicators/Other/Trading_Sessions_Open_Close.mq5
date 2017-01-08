//+------------------------------------------------------------------+
//|                                  Trading Sessions Open Close.mq5 |
//|                                                Copyright VDVSoft |
//|                                                 vdv_2001@mail.ru |
//+------------------------------------------------------------------+
#property copyright "VDVSoft"
#property link      "vdv_2001@mail.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
//---- plot The Asian session
#property indicator_label1  "Asian session High; Asian session Low"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  MistyRose
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//---- plot The European session
#property indicator_label2  "European session High; European session Low"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  Lavender
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//---- plot The American session
#property indicator_label3  "American session"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  PaleGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

double      AsiaHigh[];
double      AsiaLow[];
double      EuropaHigh[];
double      EuropaLow[];
double      AmericaHigh[];
double      AmericaLow[];
//    Time constants are specified across Greenwich
const int   AsiaOpen=0;
const int   AsiaClose=9;
const int   AsiaOpenSummertime=1;   // The Asian session taking into account summer and winter time
const int   AsiaCloseSummertime=10; // Азиатская сесия смещается при переходе на летнее время
const int   EuropaOpen=6;
const int   EuropaClose=15;
const int   AmericaOpen=13;
const int   AmericaClose=22;
//    Global variable
int         ShiftTime;  //Displacement of the buffer for construction of the future sessions
                        //--- Смещение буфера для построения будущих сессий
double      HighForFutureSession;   // High for the future session| High - для будущей сессии
double      LowForFutureSession;    // Low for the future session|  Low - для будущей сессии
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- Verify Time Period
   if( PeriodSeconds(_Period)>=PeriodSeconds(PERIOD_H2) )
   {
      return(-1);
   }
//--- Displacement of the buffer for construction of the future sessions
//--- Смещение буфера для построения будущих сессий
   ShiftTime=PeriodSeconds(PERIOD_D1)/PeriodSeconds(_Period);
//--- indicators
   SetIndexBuffer(0,AsiaHigh,INDICATOR_DATA);
   SetIndexBuffer(1,AsiaLow,INDICATOR_DATA);
   SetIndexBuffer(2,EuropaHigh,INDICATOR_DATA);
   SetIndexBuffer(3,EuropaLow,INDICATOR_DATA);
   SetIndexBuffer(4,AmericaHigh,INDICATOR_DATA);
   SetIndexBuffer(5,AmericaLow,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   PlotIndexSetInteger(0,PLOT_SHIFT,ShiftTime);
   PlotIndexSetInteger(1,PLOT_SHIFT,ShiftTime);
   PlotIndexSetInteger(2,PLOT_SHIFT,ShiftTime);
   PlotIndexSetInteger(3,PLOT_SHIFT,ShiftTime);
   PlotIndexSetInteger(4,PLOT_SHIFT,ShiftTime);
   PlotIndexSetInteger(5,PLOT_SHIFT,ShiftTime);
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
//--- auxiliary variables
   int  i=1;
   HighForFutureSession=MathMax(high[rates_total-1],high[rates_total-2]);
   LowForFutureSession=MathMin(low[rates_total-1],low[rates_total-2]);
   MqlDateTime time1, time2;
//--- set position for beginning
   if(prev_calculated==0)
   {
      i=ShiftTime+1;
      ArrayInitialize(AsiaHigh, 0.0);
      ArrayInitialize(AsiaLow, 0.0);
      ArrayInitialize(EuropaHigh, 0.0);
      ArrayInitialize(EuropaLow, 0.0);
      ArrayInitialize(AmericaHigh, 0.0);
      ArrayInitialize(AmericaLow, 0.0);
   }
   else
      i=prev_calculated-ShiftTime;
//--- start calculations
   while(i<rates_total)
   {
      TimeToStruct(time[i-1], time1);
      TimeToStruct(time[i], time2);
      if(time1.day!=time2.day)
      {
         DrawTimeZone(time[i],i);
      }
      i++;
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+--------------------------------------------------------------------+
// Summertime definition - is reserved for the future calculations
// Определение летнего времени - зарезервировано для будущих вычислений
//+--------------------------------------------------------------------+
bool Summertime(datetime time)
{
   if(TimeDaylightSavings()!=0)
      return(true);
   else
      return(false);
}
//+--------------------------------------------------------------------+
// Calculation and filling of buffers of time zones
// Расчет и заполнение буферов временных зон
//+--------------------------------------------------------------------+

void DrawTimeZone(datetime Start, int Index)
{
   int rates_total,shift,shift_end,_startIndex=Index-ShiftTime;
   double iHigh[], iLow[], HighSession, LowSession;
   datetime AsiaStart, AsiaEnd, EuropaStart, EuropaEnd, AmericaStart, AmericaEnd;
   datetime _start=Start+(TimeTradeServer()-TimeGMT());

// Processing of the Asian session
   AsiaStart=_start+(Summertime(Start)?AsiaOpenSummertime:AsiaOpen)*PeriodSeconds(PERIOD_H1);
   AsiaEnd=_start+(Summertime(Start)?AsiaCloseSummertime:AsiaClose)*PeriodSeconds(PERIOD_H1)-1;
   rates_total=CopyHigh(NULL,_Period,AsiaStart,AsiaEnd,iHigh);
   if(rates_total<=0)
      HighSession=HighForFutureSession;
   else
      HighSession=iHigh[ArrayMaximum(iHigh,0,rates_total)];
   rates_total=CopyLow(NULL,_Period,AsiaStart,AsiaEnd,iLow);
   if(rates_total<=0)
      LowSession=LowForFutureSession;
   else
      LowSession=iLow[ArrayMinimum(iLow,0,rates_total)];
   shift=int((AsiaStart-Start)/PeriodSeconds(_Period));
   shift_end=int((AsiaEnd-Start)/PeriodSeconds(_Period)+1);
   for(int i=shift; i<shift_end; i++)
   {
      AsiaHigh[_startIndex+i]=HighSession;
      AsiaLow[_startIndex+i]=LowSession;
   }

// Processing of the European session
   EuropaStart=_start+EuropaOpen*PeriodSeconds(PERIOD_H1);
   EuropaEnd=_start+EuropaClose*PeriodSeconds(PERIOD_H1)-1;
   rates_total=CopyHigh(NULL,_Period,EuropaStart,EuropaEnd,iHigh);
   if(rates_total<=0)
      HighSession=HighForFutureSession;
   else
      HighSession=iHigh[ArrayMaximum(iHigh,0,rates_total)];
   rates_total=CopyLow(NULL,_Period,EuropaStart,EuropaEnd,iLow);
   if(rates_total<=0)
      LowSession=LowForFutureSession;
   else
      LowSession=iLow[ArrayMinimum(iLow,0,rates_total)];
   shift=int((EuropaStart-Start)/PeriodSeconds(_Period));
   shift_end=int((EuropaEnd-Start)/PeriodSeconds(_Period)+1);
   for(int i=shift; i<shift_end; i++)
   {
      EuropaHigh[_startIndex+i]=HighSession;
      EuropaLow[_startIndex+i]=LowSession;
   }

// Processing of the American session
   AmericaStart=_start+AmericaOpen*PeriodSeconds(PERIOD_H1);
   AmericaEnd=_start+AmericaClose*PeriodSeconds(PERIOD_H1)-1;
   rates_total=CopyHigh(NULL,_Period,AmericaStart,AmericaEnd,iHigh);
   if(rates_total<=0)
      HighSession=HighForFutureSession;
   else
      HighSession=iHigh[ArrayMaximum(iHigh,0,rates_total)];
   rates_total=CopyLow(NULL,_Period,AmericaStart,AmericaEnd,iLow);
   if(rates_total<=0)
      LowSession=LowForFutureSession;
   else
      LowSession=iLow[ArrayMinimum(iLow,0,rates_total)];
   shift=int((AmericaStart-Start)/PeriodSeconds(_Period));
   shift_end=int((AmericaEnd-Start)/PeriodSeconds(_Period)+1);
   for(int i=shift; i<shift_end; i++)
   {
      AmericaHigh[_startIndex+i]=HighSession;
      AmericaLow[_startIndex+i]=LowSession;
   }
// Memory clearing
   ArrayResize(iHigh,0);
   ArrayResize(iLow,0);
}
