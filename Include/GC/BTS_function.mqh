//Версия  Апрель 2008
//+==================================================================+
//|                                                 BTS_function.mqh |
//|                                                            Kadet | 
//|                                                                  | 
//+==================================================================+


//Глобальные переменные


//+==================================================================+
//| Фукнкция MACD                                                    |
//+==================================================================+
double MACD_func (int n_bar ) {
//----+
   double Rezult        = 0.0;
   double oscil         = 0.0;
   double pMACD_1         = 12;
   double pMACD_2         = 26;
   double pMACD_3         = 9;
   double MACDOpenLevel   = 3;
   double pMA             = 7;
   double MacdCurrent, MacdPrevious, SignalCurrent;
   double SignalPrevious, MaCurrent, MaPrevious;
//--------------------------------------------
   MacdCurrent=iMACD(NULL,0,pMACD_1,pMACD_2,pMACD_3,PRICE_CLOSE,MODE_MAIN,n_bar);
   MacdPrevious=iMACD(NULL,0,pMACD_1,pMACD_2,pMACD_3,PRICE_CLOSE,MODE_MAIN,n_bar+1);
   SignalCurrent=iMACD(NULL,0,pMACD_1,pMACD_2,pMACD_3,PRICE_CLOSE,MODE_SIGNAL,n_bar);
   SignalPrevious=iMACD(NULL,0,pMACD_1,pMACD_2,pMACD_3,PRICE_CLOSE,MODE_SIGNAL,n_bar+1);
   MaCurrent=iMA(NULL,0,pMA,0,MODE_EMA,PRICE_CLOSE,n_bar);
   MaPrevious=iMA(NULL,0,pMA,0,MODE_EMA,PRICE_CLOSE,n_bar+1);
//--------------------------------------------
   oscil = 100000*((-1)*(MacdCurrent) + 
         (MacdCurrent-SignalCurrent) + 
          (-1)*(MacdPrevious-SignalPrevious) + 
            (MathAbs(MacdCurrent)-(MACDOpenLevel*Point)) + 
              (MaCurrent-MaPrevious));
//--------------------------------------------
   if( MathAbs(oscil) > 600 ) oscil = 0.0;
   oscil = (oscil-122)/500;
   Rezult = (oscil);
//--------------------------------------------
   return(Rezult);
//----+
 }


//+==================================================================+
//| Фукнкция MA                                                      |
//+==================================================================+
double MA_func (int bar ) {
//----+
   double Rezult  = 0.0;
   double oscil   = 0.0;
   double pMA_2   = 21;
//--------------------------------------------
   oscil = 25000*(Close[bar] - iMA(NULL,0,pMA_2,0,MODE_SMA,PRICE_CLOSE,bar));
//--------------------------------------------
   if( MathAbs(oscil) > 400 ) oscil = 0.0;
   oscil = (oscil)/350;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
 }


//+==================================================================+
//| Фукнкция CCI                                                     |
//+==================================================================+
double CCI_func (int bar ) {
//----+
   double Rezult  = 0.0;
   double oscil   = 0.0;
   double pCCI    = 8;
//--------------------------------------------
   oscil = iCCI(NULL,0,pCCI,0,bar);
//--------------------------------------------
   if( MathAbs(oscil) > 400 ) oscil = 0.0;
   oscil = (oscil)/270;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
 }



//+==================================================================+
//| Фукнкция SAR                                                     |
//+==================================================================+
double SAR_func (int bar ) {
//----+
   double Rezult  = 0.0;
   double oscil   = 0.0;
   double pSAR    = 0.014;
//--------------------------------------------
   oscil = 20000*(Close[bar] - iSAR(NULL,0,pSAR,0.2,bar));
//--------------------------------------------
   if( MathAbs(oscil) > 400 ) oscil = 0.0;
   oscil = (oscil)/400;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
 }




//+==================================================================+
//| Фукнкция WPR                                                     |
//+==================================================================+
double WPR_func (int bar ) {
//----+
   double Rezult  = 0.0;
   double oscil   = 0.0;
   double pWPR    = 16;
//--------------------------------------------
   oscil = 6*(50+iWPR(NULL,0,pWPR,bar));
//--------------------------------------------
   if( MathAbs(oscil) > 400 ) oscil = 0.0;
   oscil = (oscil)/300;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
 }



//+==================================================================+
//| Фукнкция ADX                                                     |
//+==================================================================+
double ADX_func (int bar ) {
//----+
   double Rezult  = 0.0;
   double oscil   = 0.0;
   double pADX    = 14;
//--------------------------------------------
   oscil = 15*(iADX(NULL, 0, pADX, PRICE_CLOSE, MODE_MAIN, bar)-35);
//--------------------------------------------
   if( MathAbs(oscil) > 600 ) oscil = 0.0;
   Rezult = oscil/600;
//--------------------------------------------
   return(Rezult);
//----+
 }



//+==================================================================+
//| Фукнкция AC                                                      |
//+==================================================================+
double AC_func (int bar ) {
//----+
   double Rezult = 0.0;
   double oscil = 0.0;
//--------------------------------------------
   oscil = 100000*iAC(NULL, 0, bar);
//--------------------------------------------
   if( MathAbs(oscil) > 400 ) oscil = 0.0;
   Rezult = (oscil)/400;
//--------------------------------------------
   return(Rezult);
//----+
 }



//+==================================================================+
//| Фукнкция DM                                                      |
//+==================================================================+
double DM_func (int bar ) {
//----+
   double Rezult  = 0.0;
   double oscil   = 0.0;
   double pDMr    = 27;
//--------------------------------------------
   oscil = 200*(5*iDeMarker(NULL,0,pDMr,bar)-2);
//--------------------------------------------
   if( MathAbs(oscil) > 500 ) oscil = 0.0;
   oscil = (oscil-33)/440;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
 }



//+==================================================================+
//| Фукнкция MFI                                                     |
//+==================================================================+
double MFI_func (int bar ) {
//----+
   double Rezult  = 0.0;
   double oscil   = 0.0;
   double pMFI    = 11;
//--------------------------------------------
   oscil = 8*(iMFI(NULL,0,pMFI,bar)-50);      
//--------------------------------------------
   if( MathAbs(oscil) > 500 ) oscil = 0.0;
   oscil = (oscil)/400;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
 }


//+==================================================================+
//| Фукнкция Input                                                   |
//+==================================================================+
double Input( int bar){
//--------------------------------------------
   if( Close[bar+1] !=0)
      double Rezult = (Close[bar]-Close[bar+1])/Close[bar+1];
//--------------------------------------------
   Rezult = (Rezult)/75;
//--------------------------------------------
   return(Rezult/Point);
//----+
}


//+==================================================================+
//| Фукнкция Moving                                                  |
//+==================================================================+
double Moving( int bar){
//--------------------------------------------
   int Timeframe  = 0;
   int FastEMA    = 12;  // период быстрой EMA
   int SlowEMA    = 26;  // период медленной EMA
   int SignalSMA  = 9;  // период сигнальной SMA
   double Rezult  = 0.0;
//--------------------------------------------
   double Osc1 = iCustom(NULL, Timeframe, 
                        "5c_OsMA", FastEMA, SlowEMA,
                                               SignalSMA, 5, bar);
   double Osc2 = iCustom(NULL, Timeframe, 
                        "5c_OsMA", FastEMA, SlowEMA,
                                               SignalSMA, 5, bar+1);
//--------------------------------------------
   Rezult = (Osc1-Osc2)/Point;
   if( MathAbs(Rezult) > 10 ) Rezult = 0.0;
   Rezult = (Rezult)/8;
//--------------------------------------------
   return(Rezult);
//----+
}
                                

//+==================================================================+
//| Фукнкция Flat                                                    |
//+==================================================================+
double Flat(datetime Tm, int timeframe, int bar, string symbol="NULL"){
//----
   datetime Step, Time_Pr;
   int bar_Pr;
   double Rezult  = 0.0;
//--------------------------------------------
   switch(timeframe){
      case PERIOD_M1 :  Step = 60;     break;
      case PERIOD_M5 :  Step = 300;    break;
      case PERIOD_M15:  Step = 900;    break;
      case PERIOD_M30:  Step = 1800;   break;
      case PERIOD_H1 :  Step = 3600;   break;
      case PERIOD_H4 :  Step = 14400;  break;
      case PERIOD_D1 :  Step = 86400;  break;
      default: Step = 0;               return(0);
   }

   Time_Pr = Step*MathFloor(Tm/Step);
   bar_Pr = iBarShift(symbol,timeframe,Time_Pr);
//--------------------------------------------
   if( iOpen(symbol,timeframe,(bar_Pr+1)) !=0)
      Rezult = (iOpen(symbol,timeframe,bar_Pr)-iOpen(symbol,timeframe,(bar_Pr+1)))/
                                 iOpen(symbol,timeframe,(bar_Pr+1));
//--------------------------------------------
// (Close[i]-Close[i+1])/Close[i+1]
//--------------------------------------------
/*
   double a1 = Close[0] - Open[p2];
   double a2 = Open[p2] - Open[p2 * 2];
   double a3 = Open[p2 * 2] - Open[p2 * 3];
   double a4 = Open[p2 * 3] - Open[p2 * 4];
*/
//--------------------------------------------
   return(Rezult);
//----+
}


//+==================================================================+
//| Фукнкция Flat_1                                                  |
//+==================================================================+
double Flat_1(datetime Tm, int timeframe, int bar, string symbol="NULL"){
//----
   datetime Step, Time_Pr;
   int bar_Pr;
   double Rezult  = 0.0;
//--------------------------------------------
   switch(timeframe){
      case PERIOD_M1 :  Step = 60;     break;
      case PERIOD_M5 :  Step = 300;    break;
      case PERIOD_M15:  Step = 900;    break;
      case PERIOD_M30:  Step = 1800;   break;
      case PERIOD_H1 :  Step = 3600;   break;
      case PERIOD_H4 :  Step = 14400;  break;
      case PERIOD_D1 :  Step = 86400;  break;
      default: Step = 0;               return(0);
   }

   Time_Pr = Step*MathFloor(Tm/Step);
   bar_Pr = iBarShift(symbol,timeframe,Time_Pr);
//--------------------------------------------
   Rezult = (iOpen(symbol,timeframe,bar_Pr)-iOpen(symbol,timeframe,(bar_Pr+1)));
//--------------------------------------------
// Close-Close[i+1]
//--------------------------------------------
   return(Rezult);
//----+
}




//+==================================================================+
//| Фукнкция Flat_Log                                                |
//+==================================================================+
double Flat_Log(datetime Tm, int timeframe, int bar, string symbol="NULL"){
//----
   datetime Step, Time_Pr;
   int bar_Pr;
   double Rezult  = 0.0;
//--------------------------------------------
   switch(timeframe){
      case PERIOD_M1 :  Step = 60;     break;
      case PERIOD_M5 :  Step = 300;    break;
      case PERIOD_M15:  Step = 900;    break;
      case PERIOD_M30:  Step = 1800;   break;
      case PERIOD_H1 :  Step = 3600;   break;
      case PERIOD_H4 :  Step = 14400;  break;
      case PERIOD_D1 :  Step = 86400;  break;
      default: Step = 0;               return(0);
   }

   Time_Pr = Step*MathFloor(Tm/Step);
   bar_Pr = iBarShift(symbol,timeframe,Time_Pr);
//--------------------------------------------
   if( iOpen(symbol,timeframe,(bar_Pr+1)) !=0)
      Rezult = MathLog(iOpen(symbol,timeframe,bar_Pr)/iOpen(symbol,timeframe,(bar_Pr+1)));
//--------------------------------------------
// log(Close[i]/Close[i+1]) 
//--------------------------------------------
   return(Rezult);
//----+
}


//+==================================================================+
//| Фукнкция Flat                                                    |
//+==================================================================+
double Flat_P(datetime Tm, int timeframe, int bar, int p, string symbol="NULL"){
//----
   datetime Step, Time_Pr;
   int bar_Pr;
   double Rezult  = 0.0;
//--------------------------------------------
   switch(timeframe){
      case PERIOD_M1 :  Step = 60;     break;
      case PERIOD_M5 :  Step = 300;    break;
      case PERIOD_M15:  Step = 900;    break;
      case PERIOD_M30:  Step = 1800;   break;
      case PERIOD_H1 :  Step = 3600;   break;
      case PERIOD_H4 :  Step = 14400;  break;
      case PERIOD_D1 :  Step = 86400;  break;
      default: Step = 0;               return(0);
   }

   Time_Pr = Step*MathFloor(Tm/Step);
   bar_Pr = iBarShift(symbol,timeframe,Time_Pr);
//--------------------------------------------
   if( iOpen(symbol,timeframe,(p*2 + bar_Pr)) !=0)
      Rezult = (iOpen(symbol,timeframe,bar_Pr)-iOpen(symbol,timeframe,(p*2+bar_Pr+1)))/
                                 iOpen(symbol,timeframe,(p*2+bar_Pr+1));
//--------------------------------------------
/*
   double a1 = Close[0] - Open[p2];
   double a2 = Open[p2] - Open[p2 * 2];
   double a3 = Open[p2 * 2] - Open[p2 * 3];
   double a4 = Open[p2 * 3] - Open[p2 * 4];
*/
//--------------------------------------------
   return(Rezult);
//----+
}


//+==================================================================+
//| Фукнкция MAMA                                                    |
//+==================================================================+
double MAMA_func (int bar, double FastLimit = 0.5, double SlowLimit = 0.05 ) {
//----+
   double oscil;
   int Timeframe = 0;
   double Rezult  = 0.0;
//--------------------------------------------
   oscil = iCustom(NULL, Timeframe, "#MAMA", FastLimit, SlowLimit, 0, bar); // Buf = 0; 1; 
//--------------------------------------------
//   if( MathAbs(oscil) > 500 ) oscil = 0.0;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
}


//+==================================================================+
//| Фукнкция AMA                                                     |
//+==================================================================+
double AMA_func (int bar, int periodAMA = 9, int nfast = 2, int nslow = 30, double G = 2.0, double dK = 2.0 ) {
//----+
   double oscil;
   int Timeframe = 0;
   double Rezult  = 0.0;
//--------------------------------------------
   oscil = iCustom(NULL, Timeframe, "AMA", periodAMA, nfast, nslow, G, dK, 0, bar); // Buf = 0; 1; 2;
//--------------------------------------------
//   if( MathAbs(oscil) > 500 ) oscil = 0.0;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
}



//+==================================================================+
//| Фукнкция Awesome                                                 |
//+==================================================================+
double Awesome_func (int bar ) {
//----+
   double oscil;
   int Timeframe = 0;
   double Rezult  = 0.0;
//--------------------------------------------
   oscil = iCustom(NULL, Timeframe, "Awesome", 0, bar); // Buf = 0; 1; 2; Нет переменных
//--------------------------------------------
//   if( MathAbs(oscil) > 500 ) oscil = 0.0;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
}


//+==================================================================+
//| Фукнкция CoeffofLine                                             |
//+==================================================================+
double CoeffofLine_func (int bar, int ndot = 5, int CountBars = 300 ) {
//----+
   double oscil;
   int Timeframe = 0;
   double Rezult  = 0.0;
//--------------------------------------------
   oscil = iCustom(NULL, Timeframe, "CoeffofLine", ndot, CountBars, 0, bar); // Buf = 0;
//--------------------------------------------
//   if( MathAbs(oscil) > 500 ) oscil = 0.0;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
}



//+==================================================================+
//| Фукнкция Fractals                                                |
//+==================================================================+
double Fractals_func (int bar ) {
//----+
   double osc1,osc2;
   int Timeframe = 0;
   double Rezult  = 0.0;
//--------------------------------------------
   osc1 = iCustom(NULL, Timeframe, "Fractals", 0, bar); // Buf = 0; 1; Нет переменных
   osc2 = iCustom(NULL, Timeframe, "Fractals", 1, bar); // Buf = 0; 1; Нет переменных
//--------------------------------------------
//   if( MathAbs(oscil) > 500 ) oscil = 0.0;
//   Comment("покупка buy ", val1);
   if(osc1!=0 && osc2==0) Rezult = 1;
//   Comment("продажа sell ", val2);
   if(osc1==0 && osc2!=0) Rezult = 1;
//--------------------------------------------
   return(Rezult);
//----+
}



//+==================================================================+
//| Фукнкция STLM_hist                                               |
//+==================================================================+
double STLM_hist_func (int bar, int CountBars = 300 ) {
//----+
   double oscil;
   int Timeframe = 0;
   double Rezult  = 0.0;
//--------------------------------------------
   oscil = iCustom(NULL, Timeframe, "STLM_hist", CountBars, 0, bar); // Buf = 0; 1;
//--------------------------------------------
//   if( MathAbs(oscil) > 500 ) oscil = 0.0;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
}


//+==================================================================+
//| Фукнкция SilverTrend                                             |
//+==================================================================+
double SilverTrend_func (int bar, int CountBars = 400, int SSP = 7, double Kmin = 1.6, double Kmax = 50.6, bool gAlert = True ) {
//----+
   double val1, val2;
   int Timeframe = 0;
   double Rezult  = 0.0;
//--------------------------------------------
   val1 = iCustom(NULL, Timeframe, "SilverTrend rewritten by CrazyChart", CountBars, SSP, Kmin, Kmax, gAlert, 0, bar); // Buf = 0; 1; // Filename changed to ForexOFFTrend.mq4
   val2 = iCustom(NULL, Timeframe, "SilverTrend rewritten by CrazyChart", CountBars, SSP, Kmin, Kmax, gAlert, 1, bar); // Buf = 0; 1; // Filename changed to ForexOFFTrend.mq4
//           Comment("покупка buy ", val1);
   if(val1 > val2) Rezult = 1;
//           Comment("продажа sell ", val2);
   if(val1 < val2) Rezult = -1;
//--------------------------------------------
//   if( MathAbs(oscil) > 500 ) oscil = 0.0;
//--------------------------------------------
   return(Rezult);
//----+
}


//+==================================================================+
//| Фукнкция TSI_MACD                                                |
//+==================================================================+
double TSI_MACD_hist_func (int bar, int Fast = 8, int Slow = 21, int Signal = 5, int First_R = 8, int Second_S = 5, int SignalPeriod = 5, int Mode_Smooth = 2 ) {
//----+
   double oscil;
   int Timeframe = 0;
   double Rezult  = 0.0;
//--------------------------------------------
   oscil = iCustom(NULL, Timeframe, "TSI_MACD", Fast, Slow, Signal, First_R, Second_S, SignalPeriod, Mode_Smooth, 0, bar); // Buf = 0...7;
//--------------------------------------------
//   if( MathAbs(oscil) > 500 ) oscil = 0.0;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
}


//+==================================================================+
//| Фукнкция ZigZag                                                  |
//+==================================================================+
double ZigZag_func (int bar, int ExtDepth=12, int ExtDeviation=5, int ExtBackstep=3 ) {
//----+
   double oscil;
   int Timeframe = 0;
   double Rezult  = 0.0;
//--------------------------------------------
   oscil = Close[bar] - iCustom(NULL, Timeframe, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep, 0, bar); // Buf = 0...2;
//--------------------------------------------
//   if( MathAbs(oscil) > 500 ) oscil = 0.0;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
}


//+==================================================================+
//| Фукнкция OsMA_5c                                                 |
//+==================================================================+
double OsMA_5c_func (int bar, int FastEMA=12, int SlowEMA=26, int SignalSMA=9 ) {
//----+
   double oscil;
   int Timeframe = 0;
   double Rezult  = 0.0;
//--------------------------------------------
   oscil = iCustom(NULL, Timeframe, "5c_OsMA", FastEMA, SlowEMA, SignalSMA, 5, bar); // Buf = 0...7; 
//--------------------------------------------
//   if( MathAbs(oscil) > 500 ) oscil = 0.0;
   Rezult = oscil;
//--------------------------------------------
   return(Rezult);
//----+
}

