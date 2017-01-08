//+------------------------------------------------------------------+
//|                                          ExportVectorsForANN.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <GC\Oracle.mqh>

//string exfname;
int exFileHandle=INVALID_HANDLE;
int exFileHandleStat=INVALID_HANDLE;
int exFileHandleOC=INVALID_HANDLE;

int curr_num_data=0;
int exQPRF=0,exQS=0,exQCB=0,exQZ=0,exQCS=0,exQB=0,exQ=0,AgeHistory=0;
double   HistoryInputVector[];
datetime HistoryDateTime[];

COracleTemplate *MyExpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   MyExpert=new COracleTemplate("Encog");
   MyExpert.Init();
   string fnm="ANN_"+_Symbol+"_"+TimeFrameName(0)+".csv";
   exFileHandle=FileOpen(fnm,FILE_CSV|FILE_ANSI|FILE_WRITE|FILE_REWRITE,",");
   ArrayResize(HistoryInputVector,(1+2*_TREND_)*(_OutputVectors_+MyExpert.num_input_signals));
   ArrayInitialize(HistoryInputVector,0);
   ArrayResize(HistoryDateTime,(1+2*_TREND_));
   ArrayInitialize(HistoryDateTime,0);
//---
   exFileHandleOC=FileOpen("OracleDummy_fc.mqh",FILE_WRITE|FILE_ANSI,' ');
   if(exFileHandleOC==INVALID_HANDLE)
     {
      Print("Error open file for write OracleDummy_fc.mqh");
      return(INIT_FAILED);
     }
   FileWrite(exFileHandleOC,"double od_forecast(datetime time,string smb)  ");
   FileWrite(exFileHandleOC," {");

   if(exFileHandle!=INVALID_HANDLE)
     {
      string outstr="";
      outstr="_prediction_,";
      outstr+=MyExpert.InputSignals; StringReplace(outstr," ",","); StringReplace(outstr,"-","_");
      if(MyExpert.num_input_signals==0) outstr+="TestData";
      if(_OutputVectors_==4 && !_ResultAsString_)
         outstr+=",IsBuy,IsCloseSell,IsCloseBuy,IsSell";//,"+outstr;            //outstr+=",Result";
      else if(_OutputVectors_==2 && !_ResultAsString_)
         outstr+=",IsBuy,IsSell";//,"+outstr;            //outstr+=",Result";
      else outstr+=",prediction";//,"+outstr;            //outstr+=",Result";
      FileWrite(exFileHandle,outstr);

      return(INIT_SUCCEEDED);
     }
   else
     {
      Print("Error open for write ",fnm);
      return(INIT_FAILED);
     }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

   FileClose(exFileHandle);
   FileWrite(exFileHandleOC,"  return(0);");
   FileWrite(exFileHandleOC," }");
   FileClose(exFileHandleOC);
   int maxRepeat=1;
   string outstr;
   string fnm="ANN_"+_Symbol+"_"+TimeFrameName(0)+".csv";
   exFileHandle=FileOpen(fnm,FILE_TXT|FILE_ANSI|FILE_READ);
   exFileHandleOC=FileOpen("ANN_"+_Symbol+"_"+TimeFrameName(0)+"_norm.csv",FILE_WRITE|FILE_ANSI,' ');
   double Result=0;
   int nr=0;
   int Qmax=0;
   int pos_s=0;
   while(""!=(outstr=FileReadString(exFileHandle)))
     {
     pos_s = StringFind(outstr,",");
      if(0==Qmax)
        {
         outstr = StringSubstr(outstr,pos_s+1);
         Qmax=MathMax(exQS,MathMax(exQCB,MathMax(exQZ,MathMax(exQCS,exQB))));
         FileWrite(exFileHandleOC,outstr);
         continue;
        }
      
      Result = (double) StringToDouble(StringSubstr(outstr,0,pos_s));
      if(Result>_levelEntry) maxRepeat=_PercentNormalization*Qmax/exQB;
      else if(Result>_levelClose) maxRepeat=_PercentNormalization*Qmax/exQCS;
      //else if(res>0.1) QWCS++;
      else if(Result>-_levelClose) maxRepeat=_PercentNormalization*Qmax/exQZ;
      //else if(res>-.49) QWCB++;
      else if(Result>-_levelEntry) maxRepeat=_PercentNormalization*Qmax/exQCB;
      else maxRepeat=_PercentNormalization*Qmax/exQS;
      outstr = StringSubstr(outstr,pos_s+1);
      for(nr=0;nr<maxRepeat;nr++)
         FileWrite(exFileHandleOC,outstr);
     }
   FileClose(exFileHandle);
   FileClose(exFileHandleOC);
   Print("Created.");
   delete MyExpert;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(curr_num_data>_NEDATA_)
     {
      //Print("all done");
     }
   if(!isNewBar()
   //||curr_num_data>_NEDATA_
   ) return;
   curr_num_data++;
   int i,j;//,shift=_TREND_;
   string outstr;
   double Result=0,ResultV=0;
// int num_vals,prev_prg=0;
   string fnm="";

// Result=GetTrend(_Symbol,0,0);

   ResultV=GetVectors(MyExpert.InputVector,MyExpert.InputSignals,_Symbol,0,0);
//if(ResultV>1 || ResultV<-1) return;

   if(AgeHistory<2*_TREND_+1) AgeHistory++;
   for(i=AgeHistory;i>1;i--)
     {
      HistoryDateTime[i-1]=HistoryDateTime[i-2];
      //if(ResultV<1 && ResultV>-1)
        {
         for(j=0;j<MyExpert.num_input_signals+_OutputVectors_;j++)
            HistoryInputVector[j+(i-1)*(MyExpert.num_input_signals+_OutputVectors_)]=HistoryInputVector[j+(i-2)*(MyExpert.num_input_signals+_OutputVectors_)];
        }
     }
   //if(ResultV<1 && ResultV>-1) 
   for(j=0;j<MyExpert.num_input_signals;j++)
      HistoryInputVector[j]=MyExpert.InputVector[j];
   HistoryDateTime[0]=TimeCurrent();
   if(AgeHistory==2*_TREND_+1)
     {
      Result=GetTrend(_Symbol,0,2*_TREND_,false,HistoryDateTime[2*_TREND_]);
      if(Result>1 || Result<-1) return;
      if(Result>_levelEntry) exQB++;
      else if(Result>_levelClose) exQCS++;
      //else if(res>0.1) QWCS++;
      else if(Result>-_levelClose) exQZ++;
      //else if(res>-.49) QWCB++;
      else if(Result>-_levelEntry) exQCB++;
      else exQS++;
      if(Result>=_levelEntry || Result<=-_levelEntry)
        {
         FileWrite(exFileHandleOC,"  if(smb==\""+_Symbol+"\" && time==StringToTime(\""+(string)HistoryDateTime[2*_TREND_]+"\")) return("+(string)Result+");");
        }
      outstr=(string)Result+",";

      for(j=0;j<MyExpert.num_input_signals;j++)
        {
         outstr+=DoubleToString(HistoryInputVector[(2*_TREND_)*(MyExpert.num_input_signals+_OutputVectors_)+j],_Precision_)+",";
        }
      if(MyExpert.num_input_signals==0) outstr+=""+(string)Result+",";
      outstr=FormOut(outstr,Result);

      FileWrite(exFileHandle,outstr);
     }
   return;
  }

//---

//+------------------------------------------------------------------+
