//+-----------------------------------------------------------------------------------------------+
//|                                                                             MultiInfo.v.1.mq4 |
//|                                                                             Beta Version: 101 |
//|                                                         Copyright © 2010, Shara-Telecom, Ltd. |
//+-----------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2010, Shara-Telecom, Ltd."
#property link      "kreks@mail.ru"
 
#property indicator_separate_window
 
extern string Currency = "EUR";
 
string str_window = "MultiInfo";
int int_pairs;
string str_ind_macd;
 
string str_sym_pair[5][5] = {"EURUSD", "EURGBP", "EURJPY", "EURAUD", "EURCAD",
                             "EURUSD", "GBPUSD", "USDJPY", "AUDUSD", "USDCAD",
                             "GBPUSD", "EURGBP", "GBPJPY", "GBPCHF", "GBPAUD",
                             "USDJPY", "EURJPY", "GBPJPY", "CHFJPY", "AUDJPY",
                             "USDCHF", "EURCHF", "CHFJPY", "GBPCHF", "AUDCHF"};
 
color color_ind;
 
int init() {
   //IndicatorShortName("MultiInfo");
   
   if(Currency=="EUR"){int_pairs=0;}
   if(Currency=="USD"){int_pairs=1;}
   if(Currency=="GBP"){int_pairs=2;}
   if(Currency=="JPY"){int_pairs=3;}
   if(Currency=="CHF"){int_pairs=4;}
   
   return (0);
}
 
int deinit() {
   ObjectsDeleteAll(1, OBJ_LABEL);
   return (0);
}
 
int start()
{
//static datetime dtM2 = 0;
//if (dtM2 != iTime(NULL, 2, 0))
//   {
//   dtM2 = iTime(NULL, 2, 0);
   DrawLegend();
//   }
//---
}
 
 
void DrawLegend()
{
//---- SYMBOL Section ------------------------------------------------------------+
int y_shift=30;
for(int i=0;i<5;i++)
   {  
   ObjectMakeLabel(str_sym_pair[int_pairs][i], 5, y_shift, WindowFind(str_window));
   ObjectSetText(str_sym_pair[int_pairs][i], str_sym_pair[int_pairs][i], 7, "Arial Bold", White);
   y_shift=y_shift+20;
   }    
//---- End of SYMBOL Section -----------------------------------------------------+
//---- Idicator Section -------------------------------------------------------+
//--- MACD
   ObjectMakeLabel("MACD", 60, 5, WindowFind(str_window));
   ObjectSetText("MACD", "MACD", 7, "Arial Bold", White);
   ObjectMakeLabel("MACDH4", 60, 15, WindowFind(str_window));
   ObjectSetText("MACDH4", "H4", 7, "Arial Bold", White);
   ObjectMakeLabel("MACDH1", 85, 15, WindowFind(str_window));
   ObjectSetText("MACDH1", "H1", 7, "Arial Bold", White);
   ObjectMakeLabel("MACDM30", 110, 15, WindowFind(str_window));
   ObjectSetText("MACDM30", "M30", 7, "Arial Bold", White);
   ObjectMakeLabel("MACDM15", 135, 15, WindowFind(str_window));
   ObjectSetText("MACDM15", "M15", 7, "Arial Bold", White);
   ObjectMakeLabel("MACDM5", 160, 15, WindowFind(str_window));
   ObjectSetText("MACDM5", "M5", 7, "Arial Bold", White);
 
y_shift=30;
for(i=0;i<5;i++)
   {
   TrendMACDresult(str_sym_pair[int_pairs][i], 240, 0, 60, y_shift);
   TrendMACDresult(str_sym_pair[int_pairs][i], 60, 0, 85, y_shift);
   TrendMACDresult(str_sym_pair[int_pairs][i], 30, 0, 110, y_shift);
   TrendMACDresult(str_sym_pair[int_pairs][i], 15, 0, 135, y_shift);
   TrendMACDresult(str_sym_pair[int_pairs][i], 5, 1, 160, y_shift);
   y_shift=y_shift+20;
   }
 
//--- Stochastic
   ObjectMakeLabel("Stochastic", 200, 5, WindowFind(str_window));
   ObjectSetText("Stochastic", "Stochastic", 7, "Arial Bold", White);
   ObjectMakeLabel("StochasticH4", 200, 15, WindowFind(str_window));
   ObjectSetText("StochasticH4", "H4", 7, "Arial Bold", White);  
   ObjectMakeLabel("StochasticH1", 225, 15, WindowFind(str_window));
   ObjectSetText("StochasticH1", "H1", 7, "Arial Bold", White);
   ObjectMakeLabel("StochasticM15", 250, 15, WindowFind(str_window));
   ObjectSetText("StochasticM15", "M15", 7, "Arial Bold", White);
   
y_shift=30;
for(i=0;i<5;i++)
   {
   Stochasticresult(str_sym_pair[int_pairs][i], 240, 0, 200, y_shift, 5, 3, 3);
   Stochasticresult(str_sym_pair[int_pairs][i], 60, 0, 225, y_shift, 6, 4, 3);
   Stochasticresult(str_sym_pair[int_pairs][i], 15, 0, 250, y_shift, 12, 6, 6);   
   y_shift=y_shift+20;
   }
   
//--- RSI
   ObjectMakeLabel("RSI", 285, 5, WindowFind(str_window));
   ObjectSetText("RSI", "RSI", 7, "Arial Bold", White);
   ObjectMakeLabel("RSIH4", 285, 15, WindowFind(str_window));
   ObjectSetText("RSIH4", "H4", 7, "Arial Bold", White);  
   ObjectMakeLabel("RSIH1", 310, 15, WindowFind(str_window));
   ObjectSetText("RSIH1", "H1", 7, "Arial Bold", White);
   ObjectMakeLabel("RSIM15", 335, 15, WindowFind(str_window));
   ObjectSetText("RSIM15", "M15", 7, "Arial Bold", White);
   
y_shift=30;
for(i=0;i<5;i++)
   {
   RSIresult(str_sym_pair[int_pairs][i], 240, 4, 285, y_shift);
   RSIresult(str_sym_pair[int_pairs][i], 60, 6, 310, y_shift);
   RSIresult(str_sym_pair[int_pairs][i], 15, 10, 335, y_shift);
   y_shift=y_shift+20;
   }
//--- ADX
   ObjectMakeLabel("ADX", 370, 5, WindowFind(str_window));
   ObjectSetText("ADX", "ADX", 7, "Arial Bold", White);
   ObjectMakeLabel("ADXH4", 370, 15, WindowFind(str_window));
   ObjectSetText("ADXH4", "H4", 7, "Arial Bold", White);    
   ObjectMakeLabel("ADXH1", 400, 15, WindowFind(str_window));
   ObjectSetText("ADXH1", "H1", 7, "Arial Bold", White);  
   ObjectMakeLabel("ADXM15", 430, 15, WindowFind(str_window));
   ObjectSetText("ADXM15", "M15", 7, "Arial Bold", White);
   
y_shift=30;
for(i=0;i<5;i++)
   {
   ADXresult(str_sym_pair[int_pairs][i], 240, 6, 370, y_shift);
   ADXresult(str_sym_pair[int_pairs][i], 60, 10, 400, y_shift);
   ADXresult(str_sym_pair[int_pairs][i], 15, 12, 430, y_shift);
   y_shift=y_shift+20;
   }
//---
}
 
//+----------------------------------------------------------------------------+
void TrendMACDresult(string sym, int timeframe, int a, int x_shift, int y_shift)
{
   TrendMACD(sym, timeframe, a);   
   ObjectMakeLabel(sym + "_" + timeframe + "_MACD_trend", x_shift, y_shift, WindowFind(str_window));
   ObjectSetText(sym + "_" + timeframe + "_MACD_trend", str_ind_macd, 7, "Arial Bold", color_ind);
//---
}  
 
//+----------------------------------------------------------------------------+
void Stochasticresult(string sym, int timeframe, int a, int x_shift, int y_shift, int K, int D, int S)
{
   string str_ind_stoch;
   if(iStochastic(sym, timeframe, K, D, S, 3, 1, 0, a)>iStochastic(sym, timeframe, K, D, S, 3, 1, 1, a)) {color_ind=Lime;}
   else {color_ind=Red;}
   if(iStochastic(sym, timeframe, K, D, S, 3, 1, 0, a)>90 || iStochastic(sym, timeframe, K, D, S, 3, 1, 0, a)<10) {color_ind=Yellow;}
   str_ind_stoch = DoubleToStr(iStochastic(sym, timeframe, K, D, S, 3, 1, 0, a), 1);     
   ObjectMakeLabel(sym + "_" + timeframe + "_Stochastic", x_shift, y_shift, WindowFind(str_window));
   ObjectSetText(sym + "_" + timeframe + "_Stochastic", str_ind_stoch, 7, "Arial Bold", color_ind);
//---
}
 
//+----------------------------------------------------------------------------+
void RSIresult(string sym, int timeframe, int period, int x_shift, int y_shift)
{
   string str_ind_rsi;
   if(iRSI(sym, timeframe, period, 0, 0)>iRSI(sym, timeframe, period, 0, 1)) {color_ind=Lime;}
   else {color_ind=Red;}
   if(iRSI(sym, timeframe, period, 0, 0)>80 || iRSI(sym, timeframe, period, 0, 0)<20) {color_ind=Yellow;}
   str_ind_rsi = DoubleToStr(iRSI(sym, timeframe, period, 0, 0), 1);     
   ObjectMakeLabel(sym + "_" + timeframe + "_RSI", x_shift, y_shift, WindowFind(str_window));
   ObjectSetText(sym + "_" + timeframe + "_RSI", str_ind_rsi, 7, "Arial Bold", color_ind);
//---
}
 
//+----------------------------------------------------------------------------+
void ADXresult(string sym, int timeframe, int period, int x_shift, int y_shift)
{
   color_ind=Gray;
   if(iADX(sym,timeframe,period,0,0,0)>20 &&
      iADX(sym,timeframe,period,0,0,0)>iADX(sym,timeframe,period,0,0,1) &&
     (iADX(sym,timeframe,period,0,2,0)>iADX(sym,timeframe,period,0,2,1) ||
      iADX(sym,timeframe,period,0,1,0)>iADX(sym,timeframe,period,0,1,1)))
      {   
      if(iADX(sym,timeframe,period,0,1,0)>iADX(sym,timeframe,period,0,2,0))
        {color_ind=Lime;}
      if(iADX(sym,timeframe,period,0,1,0)<iADX(sym,timeframe,period,0,2,0))
        {color_ind=Red;}
      }        
   ObjectMakeLabel(sym + "_" + timeframe + "_ADX_trend", x_shift, y_shift, WindowFind(str_window));
   ObjectSetText(sym + "_" + timeframe + "_ADX_trend", "Trend", 7, "Arial Bold", color_ind);
//---
}
 
//+----------------------------------------------------------------------------+
void TrendMACD(string sym, int timeframe, int a)
{
//--- Up Trend H4
if(Get_TrendMACD(0, sym, timeframe, a, 0)==10 || Get_TrendMACD(0, sym, timeframe, a, 0)==15 || Get_TrendMACD(0, sym, timeframe, a, 0)==17)
   {
   color_ind=Lime;
   str_ind_macd="100%";
   }
if(Get_TrendMACD(0, sym, timeframe, a, 0)==12 || Get_TrendMACD(0, sym, timeframe, a, 0)==14)
   {
   color_ind=Lime;
   str_ind_macd="75%";
   }
if(Get_TrendMACD(0, sym, timeframe, a, 0)==11 || Get_TrendMACD(0, sym, timeframe, a, 0)==16 || Get_TrendMACD(0, sym, timeframe, a, 0)==18)
   {
   color_ind=Lime;
   str_ind_macd="50%";
   }
   
//--- Down trend H4
if(Get_TrendMACD(0, sym, timeframe, a, 0)==20 || Get_TrendMACD(0, sym, timeframe, a, 0)==25 || Get_TrendMACD(0, sym, timeframe, a, 0)==27)
   {
   color_ind=Red;
   str_ind_macd="100%";
   }
if(Get_TrendMACD(0, sym, timeframe, a, 0)==22 || Get_TrendMACD(0, sym, timeframe, a, 0)==24)
   {
   color_ind=Red;
   str_ind_macd="75%";
   }
if(Get_TrendMACD(0, sym, timeframe, a, 0)==21 || Get_TrendMACD(0, sym, timeframe, a, 0)==26 || Get_TrendMACD(0, sym, timeframe, a, 0)==28)
   {
   color_ind=Red;
   str_ind_macd="50%";
   }
   
//---
}
 
//+----------------------------------------------------------------------------+
int ObjectMakeLabel(string str_label, int int_distX, int int_distY, int str_window)
   {
   ObjectCreate(str_label, OBJ_LABEL, str_window, 0, 0, 0);
   ObjectSet(str_label, OBJPROP_CORNER, 0);
   ObjectSet(str_label, OBJPROP_XDISTANCE, int_distX);
   ObjectSet(str_label, OBJPROP_YDISTANCE, int_distY);
   ObjectSet(str_label, OBJPROP_BACK, TRUE);
   return (0);
//----   
   }
 
//+------------------------------------------------------------------+
int Get_TrendMACD(int Number, string sym, int timeframe, int a, bool msg)
  {
// для отключения сообщений (Alert-ов), надо: int msg = 0;"
   int b,c; b=a+1; c=b+1;
//----
  double Macd_h1_a= iMACD(sym,timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,a);
  double Macd_h1_b= iMACD(sym,timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,b);
  double Macd_h1_c= iMACD(sym,timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,c);
      
// ----------------------для MACD ниже оси-------------------------1--&
  if(Macd_h1_c<0.0&&Macd_h1_a<0.0&&Macd_h1_a<0.0) 
   {
//прирост "0" бара относительно первого
     double r1=MathAbs(MathAbs(Macd_h1_a)-MathAbs(Macd_h1_b));
//прирост "1" бара относительно "2" 
     double r2=MathAbs(MathAbs(Macd_h1_b)-MathAbs(Macd_h1_c));
// -- MACD внизу - тренд идет вниз
   if(Macd_h1_c>Macd_h1_b&&Macd_h1_b>Macd_h1_a)
    {
     if(r1>r2) 
     {
     if (msg){Alert("На ",a," баре MACD<0 = ",Macd_h1_a,"  Тренд идет вниз \\\'с ускорением");}
           return(27);
     }
    if(r1<r2) 
     {
     if (msg){Alert("На ",a," баре MACD<0 = ",Macd_h1_a,"  Тренд идет вниз \^ с замедлением");}
           return(28);
     }
    if((r1==r2)||MathAbs(r1-r2)<0.000015)
     {
     if (msg){Alert("На ",a," баре MACD<0 = ",Macd_h1_a,"  Тренд идет вниз равноускоренно");}
           return(22);
     }
    }
// -- MACD внизу - тренд идет вверх
   if(Macd_h1_c<Macd_h1_b&&Macd_h1_b<Macd_h1_a)
    {
    if(r1>r2) 
     {
     if (msg){Alert("На ",a," баре MACD<0 =",Macd_h1_a,"  Тренд идет вверх //''с ускорением");}
           return(17);
     }
    if(r1<r2) 
     {
     if (msg){Alert("На ",a," баре MACD<0 = ",Macd_h1_a,"  Тренд идет вверх /^ с замедлением");}
           return(18);
     }
    if((r1==r2)||MathAbs(r1-r2)<0.000015)
     {
     if (msg){Alert("На ",a," баре MACD<0 = ",Macd_h1_a,"  Тренд идет вверх равноускоренно");}
           return(12);
     }
    }
// --- MACD внизу -тренд разворачивается вниз    
   if(Macd_h1_c<Macd_h1_b&&Macd_h1_b>Macd_h1_a)
    {
    if(r1>r2) 
     {
     if (msg){Alert("На ",a," баре MACD<0 = ",Macd_h1_a,"  Тренд разворачивается вниз /\\'с ускорением");}
           return(20);
     }
    if(r1<r2)
     {
     if (msg){Alert("На ",a," баре MACD<0 = ",Macd_h1_a,"  Тренд разворачивается вниз //^ с замедлением");}
           return(21);
     }
    }
// --- MACD внизу -тренд разворачивается вверх
   if(Macd_h1_c>Macd_h1_b&&Macd_h1_b<Macd_h1_a)
    {
    if(r1>r2)
     {
     if (msg){Alert("На ",a," баре MACD<0 = ",Macd_h1_a,"  Тренд разворачивается вверх //''с ускорением");}
           return(10);
     }
     if(r1<r2) 
     {
     if (msg){Alert("На ",a," баре MACD<0 = ",Macd_h1_a,"  Тренд разворачивается вверх \/^ с замедлением");}
           return(11);
     }
    }
   if(MathAbs(MathAbs(Macd_h1_a)-MathAbs(Macd_h1_b))<0.0002 && 
      MathAbs(MathAbs(Macd_h1_c)-MathAbs(Macd_h1_b))<0.0002)
    {
    if (msg){Alert("На ",a," баре Флет! в диапазоне:  ",Macd_h1_c,"   ",Macd_h1_b,"   ",Macd_h1_a);}
          return(777);
    }
   }
// -------------------для MACD выше оси----------------------------2--&    
  if(Macd_h1_c>0.0 && Macd_h1_b>0.0 && Macd_h1_a>0.0)   
   {
    {
     r1=MathAbs(MathAbs(Macd_h1_a)-MathAbs(Macd_h1_b));
     r2=MathAbs(MathAbs(Macd_h1_c)-MathAbs(Macd_h1_b));
// MACD выше оси - тренд идет вверх     
    if(Macd_h1_c<Macd_h1_b&&Macd_h1_b<Macd_h1_a&&(r1>r2))
     {
     if (msg){Alert("На ",a," баре MACD >0 = ",Macd_h1_a,"  Тренд идет вверх //''с ускорением");}
           return(17);
     }
    if(Macd_h1_c<Macd_h1_b&&Macd_h1_b<Macd_h1_a&&(r1<r2))
     {
     if (msg){Alert("На ",a," баре MACD >'0'= ",Macd_h1_a,"  Тренд идет вверх /^ с замедлением");}
           return(18);
     }
    if(Macd_h1_c<Macd_h1_b&&Macd_h1_b<Macd_h1_a)
     {
    if((r1==r2)||MathAbs(r2-r1)<0.000015)
     {
     if (msg){Alert("На ",a," баре MACD >'0' = ",Macd_h1_a,"  Тренд идет вверх равноускоренно");}
           return(12);
     }
    }
   }
// MACD выше оси - тренд идет вниз
  if(Macd_h1_c>Macd_h1_b&&Macd_h1_b>Macd_h1_a)
   {
    if((r1==r2)||MathAbs(r1-r2)<0.000015)
     {
     if (msg){Alert("На ",a," баре MACD > 0 = ",Macd_h1_a," Тренд идет вниз равноускоренно");}
           return(22);    
     }
   if(r1>r2)
     {
     if (msg){Alert("На ",a," баре MACD > 0 = ",Macd_h1_a,"  Тренд идет вниз \\\'с ускорением");}
           return(27);  
     }
     if(r1<r2) 
     {
     if (msg){Alert("На ",a," баре MACD > 0 = ",Macd_h1_a,"  Тренд идет вниз \\^ с замедлением");}
           return(28); 
     } 
    }
// MACD выше оси - тренд разворачивается вниз
   if(Macd_h1_c<Macd_h1_b&&Macd_h1_b>Macd_h1_a)
    {
    if(r1>r2) 
     {
     if (msg){Alert("На ",a," баре MACD > 0 = ",Macd_h1_b,"  Тренд разворачивается вниз \\' с ускорением!");}
           return(20);            
     }
    if(r1<r2) 
     {
     if (msg){Alert("На ",a," баре MACD > 0 = ",Macd_h1_b,"  Тренд ", " разворачивается вниз \\^ с замедлением");}
           return(21); 
     }
    }
// MACD выше оси - тренд разворачивается вверх
  if(Macd_h1_c>Macd_h1_b&&Macd_h1_b<Macd_h1_a)
    {
    if(r1>r2) 
     {
     if (msg){Alert("На ",a," баре MACD > 0 ",Macd_h1_b,"  Тренд", " разворачивается вверх //'' с ускорением");}
           return(10); 
     }
    if(r1<r2) 
     {
     if (msg){Alert("На ",a," баре MACD  > 0 ",Macd_h1_b,"  Тренд", " разворачивается вверх //'' с замедлением");}
           return(11);
     }
    }
    if(MathAbs(MathAbs(Macd_h1_a)-MathAbs(Macd_h1_b))<0.0002 &&
       MathAbs(MathAbs(Macd_h1_b)-MathAbs(Macd_h1_c))<0.0002)     
    {
    if (msg){Alert("На ",a," баре Флет! в диапазоне:  ",Macd_h1_c,"   ",Macd_h1_b,"   ",Macd_h1_a);}
          return(777);
    }
   }
// ------------для перехода через ось снизу вверх------------------3--&
   if(Macd_h1_c<0.0 && Macd_h1_b<0.0 && Macd_h1_a>0&&  // c<0 b<0
      Macd_h1_c<Macd_h1_b&&Macd_h1_b<Macd_h1_a)  
    {
     r1=MathAbs(Macd_h1_a)+MathAbs(Macd_h1_b);
     r2=MathAbs(Macd_h1_c)-MathAbs(Macd_h1_b);
    if(MathAbs(r1)>MathAbs(r2))
     {
     if (msg){Alert("На ",a," баре Тренд пересекает ось снизу вверх //'' с ускорением!");}
            return(15);
     }
    if(MathAbs(r1)<MathAbs(r2))
     {
     if (msg){Alert("На ",a," баре Тренд пересекает ось снизу вверх /^ с замедлением");}
            return(16);
     }
    }
//---     
   if(Macd_h1_c<0.0 && Macd_h1_b>0.0 && Macd_h1_a>0&&  // b>0 a>0
      Macd_h1_c<Macd_h1_b&&Macd_h1_b<Macd_h1_a)
    {
     r1=MathAbs(Macd_h1_a)-MathAbs(Macd_h1_b);
     r2=MathAbs(Macd_h1_c)+MathAbs(Macd_h1_b);
    if(MathAbs(r1)>MathAbs(r2))
     {
     if (msg){Alert("На ",a," баре Тренд пересекает ось снизу вверх //''с ускорением");}
            return(15);
     }
    if(MathAbs(r1)<MathAbs(r2))
     {
     if (msg){Alert("На ",a," баре Тренд пересекает ось снизу вверх /^ с замедлением");}
            return(16);
     }
    }
// -------------для перехода через ось сверху вниз  ---------------4--&
    if(Macd_h1_c>0 && Macd_h1_b>0 && Macd_h1_a<0&&   // c>0 b>0
       Macd_h1_c>Macd_h1_b&&Macd_h1_b>Macd_h1_a) 
     {
      r1=MathAbs(Macd_h1_a)+MathAbs(Macd_h1_b);
      r2=MathAbs(Macd_h1_c)-MathAbs(Macd_h1_b);
   //--   
     if(MathAbs(r1)>MathAbs(r2))
      {
      if (msg){Alert("На ",a," баре Тренд пересекает ось сверху вниз \\\' с ускорением");}
            return(25);
      }
   //--   
     if(MathAbs(r1)<MathAbs(r2))
      {
      if (msg){Alert("На ",a," баре Тренд пересекает ось сверху вниз \\^ с замедлением");}
            return(26);
      }
     }
 //-----    
     if(Macd_h1_c>0 && Macd_h1_b<0 && Macd_h1_a<0&&   // b<0 a<0
        Macd_h1_c>Macd_h1_b&&Macd_h1_b>Macd_h1_a) 
     {
      r1=MathAbs(Macd_h1_a)-MathAbs(Macd_h1_b);
      r2=MathAbs(Macd_h1_c)+MathAbs(Macd_h1_b);
   //--      
     if(MathAbs(r1)>MathAbs(r2))
      {
      if (msg){Alert("На ",a," баре Тренд пересекает ось сверху вниз \\\' с ускорением");}
            return(25);
      }
   //--      
     if(MathAbs(r1)<MathAbs(r2))
      {
      if (msg){Alert("На ",a," баре Тренд пересекает ось сверху вниз \\^ с замедлением");}
            return(26);
      }
     }
// -----  когда MACD "1-го" бара = "0"    
     if(Macd_h1_c>0&&Macd_h1_b==0&&Macd_h1_a<0&&
        Macd_h1_c>Macd_h1_b&&Macd_h1_b>Macd_h1_a)
      {
       r1=MathAbs(Macd_h1_a);
       r2=MathAbs(Macd_h1_c);       
      if(MathAbs(r1)>MathAbs(r2))
       {
       if (msg){Alert("На  ",a," баре Тренд пересекает ось сверху вниз \\\' с ускорением" );}
            return(25); 
       }
      if(MathAbs(r1)<MathAbs(r2))
       {
       if (msg){Alert("На ",a," баре Тренд пересекает ось сверху вниз \\^ с замедлением" );}
            return(26); 
       }
//      if(MathAbs(r1)==MathAbs(r2)) // маловероятное совпадение! 
//      {   
//       Alert("На ",a," баре Тренд пересекает ось сверху вниз равноускоренно" );
//       } 
     }
     
// далее идут маловероятные события, хотя, на истории их можно встретить!
// ----------для разворота над осью с двойным пересечением --------5--&
    if(Macd_h1_c<0 && Macd_h1_b>=0 && Macd_h1_a<0)
     {
      {
      r1=MathAbs(MathAbs(Macd_h1_a)-MathAbs(Macd_h1_b));
      r2=MathAbs(MathAbs(Macd_h1_c)-MathAbs(Macd_h1_b));
      if(r1==r2)
       {
       if (msg){Alert("На ",a," баре Тренд над осью разворачивается вниз равноускоренно");}
            return(24);
       }
      if(r1>r2)
       {
       if (msg){Alert("На ",a," баре Тренд над осью разворачивается  вниз с ускорением!");}
            return(20);
       }
      if(r1<r2)
       {
       if (msg){Alert("На ",a," баре Тренд над осью разворачивается вниз с замедлением");}
            return(21);
       }
     }
// ----------для разворота под осью с двойным пересечением --------6--&
   if(Macd_h1_c>0 && Macd_h1_b<=0 && Macd_h1_a>0)
    {
     if(r1==r2)
      {
      if (msg){Alert("На ",a," баре Тренд под осью разворачивается вверх равноускоренно");}
            return(14);
      }
     if(r1>r2)
      {
      if (msg){Alert("На ",a," баре Тренд под осью разворачивается  вверх с ускорением!");}
            return(10);
      }
     if(r1<r2)
      {
      if (msg){Alert("На ",a," баре Тренд под осью разворачивается вверх с замедлением");}
            return(11);
      }
     }
    }
// ----------------------------------------------------------------7--&
   return(0);
  }
//--end---------------------------------------------------------------+