void CWekaJ48::Init_EURUSD_M1(string FileName="",bool ip_debug=false)  
{  
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="DayOfWeek "; InputSignal[num_input_signals-1]="DayOfWeek";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="Hour "; InputSignal[num_input_signals-1]="Hour";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_CCIS "; InputSignal[num_input_signals-1]="0_CCIS";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="Minute "; InputSignal[num_input_signals-1]="Minute";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_OpenClose "; InputSignal[num_input_signals-1]="0_OpenClose";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_TriX "; InputSignal[num_input_signals-1]="0_TriX";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_RVI "; InputSignal[num_input_signals-1]="0_RVI";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_ATR "; InputSignal[num_input_signals-1]="0_ATR";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_DeMarker "; InputSignal[num_input_signals-1]="0_DeMarker";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_OsMA "; InputSignal[num_input_signals-1]="0_OsMA";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_Momentum "; InputSignal[num_input_signals-1]="0_Momentum";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_OHLCClose "; InputSignal[num_input_signals-1]="0_OHLCClose";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_HighLow "; InputSignal[num_input_signals-1]="0_HighLow";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_ADX "; InputSignal[num_input_signals-1]="0_ADX";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_ADXWilder "; InputSignal[num_input_signals-1]="0_ADXWilder";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_RSI "; InputSignal[num_input_signals-1]="0_RSI";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_StochasticS "; InputSignal[num_input_signals-1]="0_StochasticS";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_StochasticK "; InputSignal[num_input_signals-1]="0_StochasticK";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_StochasticD "; InputSignal[num_input_signals-1]="0_StochasticD";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_MACD "; InputSignal[num_input_signals-1]="0_MACD";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_WPR "; InputSignal[num_input_signals-1]="0_WPR";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_AMA "; InputSignal[num_input_signals-1]="0_AMA";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_Ichimoku "; InputSignal[num_input_signals-1]="0_Ichimoku";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_Chaikin "; InputSignal[num_input_signals-1]="0_Chaikin";
  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+="0_ROC "; InputSignal[num_input_signals-1]="0_ROC";
StringTrimRight(InputSignals);
}  

double CWekaJ48::forecast_EURUSD_M1(string smbl,int shift,bool train)  
 {
  return(0);
 }
