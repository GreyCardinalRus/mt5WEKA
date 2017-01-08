//+------------------------------------------------------------------+
//|                                                   PriceRange.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceRange(string smbl="",ENUM_TIMEFRAMES tf=0,datetime time=D'1970.01.01 00:00:00',int nomber_of_weeks=1)

  {

   if(""==smbl)
      smbl=_Symbol;

   if(0==tf)
      tf=_Period;

   if(tf>PERIOD_H1)
      return(0);

   double BufferDH[];
   double BufferDL[];
   double BufferHH[];
   double BufferHL[];

   datetime hour,day;

   double SumDay,SumHour;
   SumDay  = 0;
   SumHour = 0;


   for(int i=1; i<=nomber_of_weeks; i++)
     {
      hour = BeginOfHour(time-i*7*24*60*60);
      day  = BeginOfDay(time-i*7*24*60*60);


      if(CopyHigh(smbl,PERIOD_H1,hour,hour,BufferHH)<0)
        {
         continue;
        }
      else
        {
         CopyLow(smbl,PERIOD_H1,hour,hour,BufferHL);
         SumHour=SumHour+BufferHH[0]-BufferHL[0];
         CopyHigh(smbl,PERIOD_D1,day,day,BufferDH);
         CopyLow(smbl,PERIOD_D1,day,day,BufferDL);
         SumDay=SumDay+BufferDH[0]-BufferDL[0];
        }

      //Print("Day="+day+" H="+BufferDH[0]+" L="+BufferDL[0]+" Hour="+hour+" H="+BufferHH[0]+"L="+BufferHL[0]);

     }

   if(SumDay==0)
      return(0);
   else
      return(SumHour/SumDay*100);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeHourMQL(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.hour);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfWeekMQL(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayMQL(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MaxValue(double val1,double val2)
  {
   if(val1>val2) return val1;
   else return val2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MinValue(double val1,double val2)
  {
   if(val1<val2) return val1;
   else return val2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime BeginOfDay(datetime time)
  {
   return StringToTime(TimeToString(time,TIME_DATE)+" 00:00");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime BeginOfHour(datetime time)
  {
   return StringToTime(StringSubstr(TimeToString(time),0,13)+":00");
  }
//+------------------------------------------------------------------+
