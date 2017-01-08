//+------------------------------------------------------------------+
//|                                                         Fann.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//#include <GC\MT5FANN.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_color1  Yellow
#property indicator_color2  Blue
#property indicator_label1  "Price High"
#property indicator_label2  "Price Low"
//---- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//CMT5FANN mt5fannHigh;
//CMT5FANN mt5fannLow;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int)
  {
   DelTrash();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//---- arrow shifts when drawing
//   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ExtArrowShift);
//   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ExtArrowShift);
//---- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- initialization done
   ArraySetAsSeries(ExtUpperBuffer,true);
   ArraySetAsSeries(ExtLowerBuffer,true);
//mt5fann.debug=true;

//   if(!mt5fannHigh.Init("High")) Print("Init error");
//   if(!mt5fannLow.Init("Low")) Print("Init error");
   Print("SYMBOL_SPREAD=",SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)," SYMBOL_TRADE_STOPS_LEVEL =",SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL));
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
   int i,limit;
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);

//---
   if(rates_total<1)
      return(0);
//---
   if(prev_calculated<1)
     {
      limit=100;
      //--- clean up arrays
      ArrayInitialize(ExtUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer,EMPTY_VALUE);
     }
   else limit=rates_total-prev_calculated;
   limit=10;
   double res;


   for(i=ObjectsTotal(0);i>=0;i--)
      if(StringSubstr(ObjectName(0,i),0,3)=="GV_") ObjectDelete(0,ObjectName(0,i));

   for(i=1;i<limit;i++)
     {
      res=GetTrend(20,_Symbol,_Period,i);
      if(0!=res) Print(res);
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Удаляет мусорные объекты на графиках                             |
//+------------------------------------------------------------------+
void DelTrash()
  {
   for(int i=ObjectsTotal(0);i>=0;i--)
      if(StringSubstr(ObjectName(0,i),0,3)=="GV_") ObjectDelete(0,ObjectName(0,i));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTrend(int shift_history,string smb="",ENUM_TIMEFRAMES tf=0,int shift=0)
  {
   double mS=0,mB=0,S=0,B=0;
   double Close[]; ArraySetAsSeries(Close,true);
   double High[]; ArraySetAsSeries(High,true);
   double Low[]; ArraySetAsSeries(Low,true);
   datetime Time[]; ArraySetAsSeries(Time,true);
// копируем историю
   if(""==smb) smb=_Symbol;
   if(0==tf) tf=_Period;
   int maxcount=CopyHigh(smb,tf,shift,shift_history+3,High);
   maxcount=CopyClose(smb,tf,shift,shift_history+3,Close);
   maxcount=CopyLow(smb,tf,shift,shift_history+3,Low);
   maxcount=CopyTime(smb,tf,shift,shift_history+3,Time);
   double res=0;
   int is,ib;
   if((High[shift_history+1]>High[shift_history] && High[shift_history+1]>High[shift_history+2]) || (Low[shift_history+1]<Low[shift_history] && Low[shift_history+1]<Low[shift_history+2]))
     {
      S=Close[shift_history]; B=Close[shift_history];
      is=ib=shift_history;
      double  TS=SymbolInfoDouble(smb,SYMBOL_POINT)*(3*SymbolInfoInteger(smb,SYMBOL_TRADE_STOPS_LEVEL));

      for(int i=shift_history-1;i>0;i--)
        {
         if(0==mS)
           {
            if(Close[i]<(High[i]-TS))
              {
               mS=Close[shift_history]-S;
               //S=0;
              }
            else
              {
               if(S>Low[i]){S=Low[i];is=i;}
               ObjectCreate(0,"GV_S_"+(string)shift,OBJ_ARROWED_LINE,0,Time[shift_history],Close[shift_history],Time[is],S);
              }
           }
         if(0==mB)
           {
            if(Close[i]>(Low[i]+TS))
              {
               mB=B-Close[shift_history];
               //B=0;
              }
            else
              {
               if(B<High[i]) {B=High[i];ib=i;}
               ObjectCreate(0,"GV_B_"+(string)shift,OBJ_ARROWED_LINE,0,Time[shift_history],Close[shift_history],Time[ib],B);
              }
           }

        }
      mB=B-Close[shift_history];mS=Close[shift_history]-S;
      //=(prf-prl)/(SymbolInfoInteger(smbl,SYMBOL_SPREAD)*SymbolInfoDouble(smbl,SYMBOL_POINT));
      if(mS>mB) {res=-mS;ObjectDelete(0,"GV_B_"+(string)shift);}
      else      { res=mB;ObjectDelete(0,"GV_S_"+(string)shift);}
      res=res/(SymbolInfoInteger(smb,SYMBOL_TRADE_STOPS_LEVEL)*SymbolInfoDouble(smb,SYMBOL_POINT));
      res=1*(1/(1+MathExp(-1.5*res/5))-0.5);
     }
   return(res);

  }
