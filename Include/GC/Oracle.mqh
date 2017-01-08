//+------------------------------------------------------------------+
//|                                                       Oracle.mqh |
//|                        Copyright 2010-2015, GreyCardinal .       |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Trade\SymbolInfo.mqh>
#include <GC\GetVectors.mqh>
bool _ResultAsString_=true;
int _OutputVectors_=4;

int _PercentNormalization=1; // 100/5 = 20%, but data *5
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COracleTemplate
  {
private:

   string            filename;

public:
   string            smb;
   ENUM_TIMEFRAMES   TimeFrame;
   bool              IsInit;
   int               errorFile;
   int               AgeHistory;
   double            HistoryInputVector[];
   double            InputVector[];
   double            OutputVector[];
   bool              debug;
   string            templateTimeFrames;
   string            InputSignals;

   string            InputSignal[];
   string            templateInputSignals;
   int               num_repeat;
   ENUM_TIMEFRAMES   TimeFrames[];
   int               num_input_signals;
   int               num_output_signals;
                     COracleTemplate(string ip_smbl="",ENUM_TIMEFRAMES  ip_tf=0){IsInit=false; if(ip_smbl=="") smb=_Symbol; else smb=ip_smbl; if(ip_tf==0) TimeFrame=Period(); else TimeFrame=ip_tf; };
                    ~COracleTemplate(){DeInit();};
   virtual void      Init(string FileName="",bool ip_debug=false);
   virtual void              DeInit();
   virtual double    forecast(string smbl,ENUM_TIMEFRAMES tf,int shift,bool train,string comment){Print("Please overwrite (int) in ",Name()); return(0);};
   virtual double    forecast(string smbl,ENUM_TIMEFRAMES tf,datetime startdt,bool train,string comment){Print("Please overwrite (datetime) in ",Name()); return(0);};
   virtual string    Name(){return(filename);/*return("Prpototype");*/};
   bool              ExportHistoryENCOG(string smbl,string fname,ENUM_TIMEFRAMES tf,int num_train,int num_test,int num_valid,int num_work);
   bool              ExportVectorsForANN();//string smbl,string fname,ENUM_TIMEFRAMES tf,int num_train,int num_test,int num_valid,int num_work);
   bool              loadSettings(string filename);
   bool              saveSettings(string filename);
   string            GetInputAsString(string smbl,int shift);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  COracleTemplate::Init(string FileName="",bool ip_debug=false)
  {
   IsInit=true;
   debug=ip_debug; AgeHistory=0;//errorFile=INVALID_HANDLE;
   if(""!=FileName) filename=FileName;
   else  filename="Prototype";

   loadSettings(filename+".ini");
   ArrayResize(InputVector,num_input_signals);
   ArrayResize(InputSignal,num_input_signals);
   ArrayResize(HistoryInputVector,_TREND_*num_input_signals);
   ArrayInitialize(HistoryInputVector,0);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  COracleTemplate::DeInit()
  {
   //saveSettings(filename+".ini");
   for(int i=0;i<ArraySize(IndHandles);i++)
     {
      IndicatorRelease(IndHandles[i].hid);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string COracleTemplate::GetInputAsString(string smbl,int shift)
  {

   double Result=GetVectors(InputVector,InputSignals,smbl,0,shift);
   if(-100==Result) return("");
   string outstr=""+smbl+",M1,";
   for(int j=0;j<num_input_signals;j++)
     {
      outstr+=DoubleToString(InputVector[j],_Precision_)+",";
     }
   return(StringSubstr(outstr,0,StringLen(outstr)-1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool COracleTemplate::ExportHistoryENCOG(string smbl,string fname,ENUM_TIMEFRAMES tf,int num_train,int num_test=0,int num_valid=0,int num_work=0)
  {
   if(num_train==0 && 0==num_test && 0==num_valid && 0==num_work) return(false);
   if(""==smbl) smbl=_Symbol;
   if(""==fname) fname=Name();
   int FileHandle=-1;
   int i,j,shift=_TREND_;
   string outstr;
   double Result=0;
   int num_vals,prev_prg=0;
   string fnm="";
   MqlRates rates[];
   MqlDateTime tm;
   if(num_work>0) shift=0;
//double IV[50],OV[10];
   ArraySetAsSeries(rates,true);
   TimeToStruct(TimeCurrent(),tm);
   int cm=tm.mon;int FileHandleOC=INVALID_HANDLE;int FileHandleStat=INVALID_HANDLE;
   int QPRF=0,QS=0,QCB=0,QZ=0,QCS=0,QB=0,Q=0;
   for(int ring=0;ring<4;ring++)
     {
      switch(ring)
        {
         case 0: num_vals=num_test;fnm=fname+"_"+smbl+"_M1_test_data.csv";  break;
         case 1: num_vals=num_valid;fnm=fname+"_"+smbl+"_M1_valid_data.csv";  break;
         case 2: num_vals=num_train;fnm=fname+"_"+smbl+"_"+TimeFrameName(tf)+".csv";  break;
         case 3: num_vals=num_work;fnm=fname+"_"+smbl+"_M1_prediction_data.csv";  break;
         default: num_vals=0;
        }
      if(num_vals>0)
        {
         if(num_train>0 && ring==2)
           {
            FileHandleOC=FileOpen("OracleDummy_fc.mqh",FILE_WRITE|FILE_ANSI,' ');
            if(FileHandleOC==INVALID_HANDLE)
              {
               Print("Error open file for write OracleDummy_fc.mqh");
               return(false);
              }
            FileHandleStat=FileOpen("stat.csv",FILE_WRITE|FILE_ANSI|FILE_CSV,';');
            if(FileHandleStat==INVALID_HANDLE)
              {
               Print("Error open file for write stat.csv");
               return(false);
              }
            FileWrite(FileHandleStat,// записываем в файл шапку
                      //                "Symbol","DayOfWeek","Hours","Minuta","Signal","QS","QWS","QW","QWB","QB");
                      "Symbol","SumTotalInSpread","QPRF","QS","QCB","QZ","QCS","QB","Q","MQS","MQCB","MQZ","MQCS","MQB");

           }
         FileHandle=FileOpen(fnm,FILE_CSV|FILE_ANSI|FILE_WRITE|FILE_REWRITE,",");
         if(FileHandle!=INVALID_HANDLE)
           {
            // Header
            outstr="";

            outstr=InputSignals;StringReplace(outstr," ",",");StringReplace(outstr,"-","_");
            if(_OutputVectors_==4 && !_ResultAsString_)
               outstr+=",IsBuy,IsCloseSell,IsCloseBuy,IsSell";//,"+outstr;            //outstr+=",Result";
            else if(_OutputVectors_==2 && !_ResultAsString_)
               outstr+=",IsBuy,IsSell";//,"+outstr;            //outstr+=",Result";
            else outstr+=",prediction";//,"+outstr;            //outstr+=",Result";
            if(_debug_time) outstr="NormalTime,"+outstr;
            FileWrite(FileHandle,outstr);
            bool need_exp=true;
            int copied=CopyRates(_Symbol,tf,0,shift+num_vals,rates);
            if(num_train>0 && FileHandleOC!=INVALID_HANDLE)
              {
               FileWrite(FileHandleOC,"double od_forecast(datetime time,string smb)  ");
               FileWrite(FileHandleOC," {");

              }
            //calc statistic
            for(i=shift;i<(shift+num_vals);i++)
              {
               Result=GetVectors(InputVector,InputSignals,smbl,0,i);
               if(Result>1 || Result<-1) continue;
               need_exp=true;
               if(2==ring)
                 {
                  if(Result>=-1 && FileHandleOC!=INVALID_HANDLE && (Result>0.4 || Result<-0.4))
                    {
                     FileWrite(FileHandleOC,"  if(smb==\""+smbl+"\" && time==StringToTime(\""+(string)rates[i].time+"\")) return("+(string)Result+");");
                    }

                  if(Result>0.66) QB++;
                  else if(Result>.49) QCS++;
                  //else if(res>0.1) QWCS++;
                  else if(Result>-0.49) QZ++;
                  //else if(res>-.49) QWCB++;
                  else if(Result>-.66) QCB++;
                  else QS++;
                 }
              }

            int maxRepeat=0,nr;
            for(i=shift;QZ>0 && i<(shift+num_vals);i++)
              {
               Result=GetVectors(InputVector,InputSignals,smbl,0,i);
               if(Result>1 || Result<-1) continue;

               outstr="";
               if(_debug_time) outstr+=(string)rates[i].time+",";
               for(j=0;j<num_input_signals;j++)
                 {
                  outstr+=DoubleToString(InputVector[j],_Precision_)+",";
                 }
               outstr=FormOut(outstr,Result);

               // repeat for normalization
               if(Result>0.66) maxRepeat=_PercentNormalization*QZ/QB;
               else if(Result>.49) maxRepeat=_PercentNormalization*QZ/QCS;
               //else if(res>0.1) QWCS++;
               else if(Result>-0.49) maxRepeat=_PercentNormalization*QZ/QZ;
               //else if(res>-.49) QWCB++;
               else if(Result>-.66) maxRepeat=_PercentNormalization*QZ/QCB;
               else maxRepeat=_PercentNormalization*QZ/QS;

               for(nr=0;nr<maxRepeat;nr++)
                  FileWrite(FileHandle,outstr);
              }
            FileClose(FileHandle);
            if(FileHandleOC!=INVALID_HANDLE)
              {
               FileWrite(FileHandleOC,"  return(0);");
               FileWrite(FileHandleOC," }");
               FileClose(FileHandleOC);
               Q=QS+QCB+QZ+QCS+QB;
               if(Q>0)
                  FileWrite(FileHandleStat,
                            smbl,0,_NumTS_,QS,QCB,QZ,QCS,QB,Q,
                            -1+(double)QS/Q,-1+2*(double)QS/Q+(double)QCB/Q
                            //,-1+2*(double)(QS+QCB)/Q+(double)QWCB/Q
                            ,0
                            //,1-2*(double)(QB+QCS)/Q-(double)QWCS/Q
                            ,1-2*(double)QB/Q-(double)QCS/Q,
                            1-(double)QB/Q);//,(string)tm.day+"/"+(string)tm.mon+"/"+(string)tm.year);
               FileClose(FileHandleStat);
              }
            if(ring==3 && Result!=0)
              {
               FileDelete(fnm);
              }
            else Print("Created.",fnm);
           }
         else
           {Print("Error open for write ",fnm);}
         shift+=num_vals;
        }
     }

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FormOut(string outstr,double Result)
  {
   if(_ResultAsString_ && _OutputVectors_==4)
     {
      if(Result>0.66) outstr+="""Buy""";
      else if(Result>0.49) outstr+="""CloseSell""";
      else if(Result>-0.49) outstr+="""Wait""";
      else if(Result>-0.66) outstr+="""CloseBuy""";
      else outstr+="""Sell""";
     }
   else
   if(_ResultAsString_ && _OutputVectors_==2)
     {
      if(Result>0.66) outstr+="""Buy""";
      else if(Result>0.49) outstr+="""Wait""";
      else if(Result>-0.49) outstr+="""Wait""";
      else if(Result>-0.66) outstr+="""Wait""";
      else outstr+="""Sell""";
     }
   else
   if(_OutputVectors_==4)
     {
      if(Result>0.66) outstr+="1,0,-1,-1";
      else if(Result>0.49) outstr+="0,1,-1,-1";
      else if(Result>-0.49) outstr+="-1,0,0,-1";
      else if(Result>-0.66) outstr+="-1,0,1,0";
      else outstr+="-1,-1,0,1";
     }
   else  if(_OutputVectors_==2)
     {
      if(Result>0.66) outstr+="1,-1";
      else if(Result>0.49) outstr+="0,0";
      else if(Result>-0.49) outstr+="0,0";
      else if(Result>-0.66) outstr+="0,0";
      else outstr+="-1,1";
     }
   else
      outstr+=DoubleToString(Result,_Precision_);

   return outstr;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COracleTemplate::loadSettings(string _filename)
  {
   if(""==_filename) _filename=Name()+".ini";
   int FileHandle=FileOpen(_filename,FILE_READ|FILE_ANSI|FILE_CSV,'=');
   string fr;//,tfs="";
   if(FileHandle==INVALID_HANDLE)
   {
     FileHandle=FileOpen(_filename,FILE_WRITE|FILE_ANSI|FILE_CSV,'=');
   if(FileHandle!=INVALID_HANDLE)
     {

      FileWrite(FileHandle,"//How to use"," fill string separate space. Format TT-functionName_Paramm1_ParamX");
      FileWrite(FileHandle,"//Where TT"," shift on timeframe");
      FileWrite(FileHandle,"//example","ROC 5-ROC 10-ROC_13");
      FileWrite(FileHandle,"//Num_repeat","3 eqv ROC 1-ROC 2-ROC");

      FileWrite(FileHandle,"//Bad Signals= IMA CCI AO Envelopes BearsPower BullsPower Force DeMarkerS MomentumS");
      FileWrite(FileHandle,"//Available Signals= DayOfWeek Hour CCIS Minute OpenClose TriX RVI ATR DeMarker OsMA Momentum OHLCClose HighLow ADX ADXWilder RSI StochasticS StochasticK StochasticD MACD WPR AMA Ichimoku Chaikin ROC");
      FileWrite(FileHandle,"//inputSignals=DayOfWeek Hour Minute MomentumS_5 MomentumS_8 MomentumS_13 MomentumS_21 MomentumS_34 MomentumS_55 MomentumS_89 CCIS_5 CCIS_8 CCIS_13 CCIS_21 CCIS_34 CCIS_55 CCIS_89 StochasticS StochasticS_13_8_8 StochasticS_21_13_13 StochasticS_34_21_21 StochasticS_55_34_34 StochasticK StochasticK_13_8_8 StochasticK_21_13_13 StochasticK_34_21_21 StochasticK_55_34_34 StochasticD StochasticD_21_13_13 StochasticD_34_21_21 StochasticD_55_34_34 WPR_5 WPR_8 WPR_13 WPR_21 WPR_34 WPR_55 WPR_89 DeMarkerS_5 DeMarkerS_8 DeMarkerS_13 DeMarkerS_21 DeMarkerS_34 DeMarkerS_55 DeMarkerS_89");

      FileWrite(FileHandle,"inputSignals=DayOfWeek Hour CCI CCIS Minute OpenClose TriX RVI ATR DeMarker OsMA Momentum OHLCClose HighLow ADX ADXWilder RSI StochasticS StochasticK StochasticD MACD WPR AMA Ichimoku Chaikin ROC");
      FileWrite(FileHandle,"Num_repeat=1");
      FileWrite(FileHandle,"TimeFrames=M1 M5 M15 M30 H1");
      FileClose(FileHandle);
     }
     }
   FileHandle=FileOpen(_filename,FILE_READ|FILE_ANSI|FILE_CSV,'=');
   if(FileHandle!=INVALID_HANDLE)
   
     {
      while(""!=(fr=FileReadString(FileHandle)))
        {
         if("inputSignals"==fr)
           {
            templateInputSignals=FileReadString(FileHandle);
           }
         if("Num_repeat"==fr)
           {
            num_repeat=(int)StringToInteger(FileReadString(FileHandle));
           }
         if("TimeFrames"==fr)
           {
            templateTimeFrames=FileReadString(FileHandle);
           }
        }
      FileClose(FileHandle);
      int start_pos=0,end_pos=0,shift_pos=0;
      StringReplace(templateInputSignals,"  "," ");      StringReplace(templateInputSignals,"  "," ");      StringReplace(templateInputSignals,"  "," ");
      StringReplace(templateTimeFrames,"  "," ");      StringReplace(templateTimeFrames,"  "," ");      StringReplace(templateTimeFrames,"  "," ");
      start_pos=0;end_pos=0;shift_pos=0;
      end_pos=StringFind(templateTimeFrames," ",start_pos);
      string tfn_name;
      int ntf=0;
      do //while(end_pos>0)
        {
         tfn_name=StringSubstr(templateTimeFrames,start_pos,end_pos-start_pos);
         ntf++; ArrayResize(TimeFrames,ntf);
         if("DayOfWeek"==tfn_name || "Hour"==tfn_name || "Minute"==tfn_name)
           {
            //InputSignals+=fn_name+" "; InputSignal[num_input_signals-1]=fn_name;
            break;
           }
         else
           {
            //               InputSignals+=(string)i+"-"+fn_name+" ";
            TimeFrames[ntf-1]=NameTimeFrame(tfn_name);
           }

         start_pos=end_pos+1;    end_pos=StringFind(templateTimeFrames," ",start_pos);
         if(start_pos==0 || start_pos==-1) break;
        }
      while(true);
      if(ntf==0)
        {
         ntf++; ArrayResize(TimeFrames,ntf);TimeFrames[ntf-1]=NameTimeFrame("");
        }
      if(0==num_repeat) num_repeat=1;
      start_pos=0;end_pos=0;shift_pos=0;
      end_pos=StringFind(templateInputSignals," ",start_pos);
      string fn_name;InputSignals="";
      do //while(end_pos>0)
        {
         fn_name=StringSubstr(templateInputSignals,start_pos,end_pos-start_pos);
         if("DayOfWeek"==fn_name || "Hour"==fn_name || "Minute"==fn_name)
           {
            num_input_signals++; ArrayResize(InputSignal,num_input_signals);
            InputSignals+=fn_name+" "; InputSignal[num_input_signals-1]=fn_name;
           }
         else
           {
            for(int j=0;j<ntf;j++)
              {
               for(int i=0;i<num_repeat;i++)
                 {
                  num_input_signals++; ArrayResize(InputSignal,num_input_signals);
                  InputSignal[num_input_signals-1]=((i==0)?"":((string)i+"-"))+TimeFrameName(TimeFrames[j])+"_"+fn_name;
                  InputSignals+=InputSignal[num_input_signals-1]+" ";
                 }
              }
           }
         start_pos=end_pos+1;    end_pos=StringFind(templateInputSignals," ",start_pos);
         if(start_pos==0 || start_pos==-1) break;
        }
      while(true);
      InputSignals=StringSubstr(InputSignals,0,StringLen(InputSignals)-1);

      //Print(Name()," inputSignals=",inputSignals," ",num_input_signals);
      //      if(0!=num_repeat) num_input_signals*=num_repeat;     
     }
   else
     {
      //      FileHandle=FileOpen(filename,FILE_WRITE|FILE_ANSI|FILE_CSV|FILE_COMMON,'=');
      //      if(FileHandle!=INVALID_HANDLE)
      //        {
      //         FileWrite(FileHandle,"inputSignals",inputSignals);
      //
      //         FileClose(FileHandle);
      //        }
     }
   Print(Name()," ready! IS: (",num_input_signals,")",InputSignals);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COracleTemplate::saveSettings(string _filename)
  {
   if(""==_filename) _filename=Name()+".ini";
   int FileHandle=FileOpen(_filename,FILE_WRITE|FILE_ANSI|FILE_CSV,'=');
//string fr;
   if(FileHandle!=INVALID_HANDLE)
     {
      string AS,BS;
      for(int i=0;i<ArraySize(VectorFunctions);i++) AS=AS+" "+VectorFunctions[i];
      for(int i=0;i<ArraySize(BadVectorFunctions);i++) BS=BS+" "+BadVectorFunctions[i];
      FileWrite(FileHandle,"//How to use"," fill string separate space. Format TT-functionName_Paramm1_ParamX");
      FileWrite(FileHandle,"//Where TT"," shift on timeframe");
      FileWrite(FileHandle,"//example","ROC 5-ROC 10-ROC_13");
      FileWrite(FileHandle,"//Num_repeat","3 eqv ROC 1-ROC 2-ROC");

      FileWrite(FileHandle,"//Bad Signals",BS);
      FileWrite(FileHandle,"//Available Signals",AS);
      FileWrite(FileHandle,"//inputSignals=DayOfWeek Hour Minute MomentumS_5 MomentumS_8 MomentumS_13 MomentumS_21 MomentumS_34 MomentumS_55 MomentumS_89 CCIS_5 CCIS_8 CCIS_13 CCIS_21 CCIS_34 CCIS_55 CCIS_89 StochasticS StochasticS_13_8_8 StochasticS_21_13_13 StochasticS_34_21_21 StochasticS_55_34_34 StochasticK StochasticK_13_8_8 StochasticK_21_13_13 StochasticK_34_21_21 StochasticK_55_34_34 StochasticD StochasticD_21_13_13 StochasticD_34_21_21 StochasticD_55_34_34 WPR_5 WPR_8 WPR_13 WPR_21 WPR_34 WPR_55 WPR_89 DeMarkerS_5 DeMarkerS_8 DeMarkerS_13 DeMarkerS_21 DeMarkerS_34 DeMarkerS_55 DeMarkerS_89");

      FileWrite(FileHandle,"inputSignals",templateInputSignals);
      FileWrite(FileHandle,"Num_repeat",num_repeat);
      FileWrite(FileHandle,"TimeFrames",templateTimeFrames);
      FileClose(FileHandle);
     }
   return(true);
  }

COracleTemplate *AllOracles[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Neuron
  {

   string            numNode;
   double            Threshold;
   string            activationfn;
   bool              isCalculated;
   //  bool              isInput;
   double            Value;

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Weight
  {
   string            numNodeFrom;
   string            numNodeTo;
   int               NeuronFrom;
   int               NeuronTo;
   double            weight;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COracleMLP_WEKA:public COracleTemplate
  {
private:
   Neuron            neurons[];
   Weight            weights[];
   string            OutputSignals;
   string            OutputSignal[];
   string            _FILENAME;
   int               neuronCount;
   int               weightCount;
   void              ActivationTANH(double val);
   void              ActivationSigmoid(double val);
   //   void              ActivationElliottSymmetric(int numnode);
   //   void              ActivationElliott(int numnode);
public:
   double            ComputeNeuron(string numNeuron);
   void              Compute(double &_input[],double &_output[]);
                     COracleMLP_WEKA(string FileName=""){Init(FileName);}
   virtual string    Name(){return("MLP_WEKA");};
   void              Init(string FileName="",bool ip_debug=false);
   virtual void      DeInit();
   virtual double    forecast(string smbl,ENUM_TIMEFRAMES,int shift,bool train,string coment);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COracleMLP_WEKA::ComputeNeuron(string numNeuron)
  {
   for(int i=0;i<neuronCount;i++)
     {
      if(neurons[i].numNode==numNeuron)
        {
         if(neurons[i].isCalculated) return neurons[i].Value;
         double NSums=0;
         for(int j=0;j<weightCount;j++)
           {
            if(weights[j].numNodeFrom==neurons[i].numNode)
              {
               NSums+=ComputeNeuron(weights[j].numNodeTo)*weights[j].weight;
              }
           }
         if(neurons[i].activationfn=="Sigmoid")
           {
            neurons[i].Value=Sigmoid(NSums+neurons[i].Threshold);
            neurons[i].isCalculated=true;
            return neurons[i].Value;

           }
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COracleMLP_WEKA::forecast(string smbl,ENUM_TIMEFRAMES tf,int shift,bool train,string comment)
  {

   if(""==smbl) smbl=_Symbol;
   double sig=GetVectors(InputVector,InputSignals,smbl,0,shift);
   if(sig<-1||sig>1) return 0;
   if(0==neuronCount)
      sig=0;
   else
     {
      Compute(InputVector,OutputVector);

      string outSignal="";double maxSignal=0;
      for(int i=0;i<num_output_signals;i++)
        {
         if(maxSignal<OutputVector[i])
           {
            if(maxSignal==-1) maxSignal=-1;
            else if(maxSignal>0.5 && 
               !(
                 (outSignal=="Sell" && OutputSignal[i]=="CloseBuy")
                 ||(outSignal=="CloseBuy"&&OutputSignal[i]=="Sell")
                 ||(outSignal=="Buy"&&OutputSignal[i]=="CloseSell")
                 ||(outSignal=="CloseSell"&&OutputSignal[i]=="Buy")
                 ))
                 {

                  maxSignal=-1;
                 }
               else
                 {
                  maxSignal=OutputVector[i];
                  outSignal=OutputSignal[i];
                 }
           }
        }
      if(maxSignal<0.8) outSignal="Wait";
      if(num_output_signals==5)
        {
         // if(OutputVector[0]>0.5||OutputVector[1]>0.5||OutputVector[2]>0.5||OutputVector[3]>0.5)
         //if(__Debug__&&false==MQLInfoInteger(MQL_TESTER)) 
         if(maxSignal==-1)
           {
            // Print(outSignal,"! ",OutputSignal[0],"=",DoubleToString(OutputVector[0],3),"  ",OutputSignal[1],"=",DoubleToString(OutputVector[1],3),"  ",OutputSignal[2],"=",DoubleToString(OutputVector[2],3),"  ",OutputSignal[3],"=",DoubleToString(OutputVector[3],3),"  ",OutputSignal[4],"=",DoubleToString(OutputVector[4],3),"  ");
            if(INVALID_HANDLE!=errorFile)
              {
               FileWrite(errorFile,TimeCurrent()," ",outSignal,"! ",OutputSignal[0],"=",DoubleToString(OutputVector[0],3),"  ",OutputSignal[1],"=",DoubleToString(OutputVector[1],3),"  ",OutputSignal[2],"=",DoubleToString(OutputVector[2],3),"  ",OutputSignal[3],"=",DoubleToString(OutputVector[3],3),"  ",OutputSignal[4],"=",DoubleToString(OutputVector[4],3),"  ");
              }
           }
        }

      if("Sell"==outSignal) sig=-1;
      else if("Buy"==outSignal) sig=1;
      else if("CloseBuy"==outSignal) sig=-0.5;
      else if("CloseSell"==outSignal) sig=0.5;
     }
   return sig;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COracleMLP_WEKA::Compute(double &_input[],double &_output[])
  {
   int i,j;
   for(i=0;i<neuronCount;i++)
     {
      neurons[i].isCalculated=false;
      neurons[i].Value=0;
     }
   ArrayCopy(InputVector,_input);
   for(i=0;i<num_input_signals;i++)
     {
      for(j=0;j<neuronCount;j++)
        {
         if(neurons[j].numNode==InputSignal[i])
           {
            neurons[j].Value=InputVector[i];
            neurons[j].isCalculated=true;
           }
        }
     }
   for(i=0;i<neuronCount;i++)
     {
      ComputeNeuron(neurons[i].numNode);
      if(neurons[i].isCalculated==false) Print(neurons[i].numNode," not calk");
      //     if(neurons[i].Value==0) Print(neurons[i].numNode," Val=0");

     }
   for(i=0;i<num_output_signals;i++)
     {
      for(j=0;j<neuronCount;j++)
        {
         if(neurons[j].numNode==OutputSignal[i])
           {
            OutputVector[i]=neurons[j].Value;
            //neurons[j].isCalculated=true;
           }
        }
     }
   ArrayCopy(_output,OutputVector);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COracleMLP_WEKA::Init(string FileName="",bool ip_debug=false)
  {
  IsInit=false;
//TimeFrame=PERIOD_M1;
//   COracleTemplate::Init(FileName,ip_debug);
   errorFile=INVALID_HANDLE;
   errorFile=FileOpen("errors.txt",FILE_WRITE|FILE_ANSI|FILE_CSV,' ');
   FileWrite(errorFile,"debug info ");
   TimeFrame=_Period;
   if(""!=FileName) _FILENAME=FileName;
   else  _FILENAME=Name()+"_"+smb+"_"+TimeFrameName(TimeFrame);

   string _filename=_FILENAME+".mlp_weka";
   string inputString;
   ArrayResize(neurons,1);
   ArrayResize(weights,1);
//   _layerCount=0; //int tempar
   neuronCount=0;num_input_signals=0;weightCount=0;num_output_signals=0;
   int FileHandle=FileOpen(_filename,FILE_COMMON|FILE_READ|FILE_ANSI|FILE_TXT);
   string fr; int str_pos=0,i,j;
   if(FileHandle!=INVALID_HANDLE)
     {
      while(!FileIsEnding(FileHandle))
        {
         fr=FileReadString(FileHandle);
         if(StringFind(fr,"Attributes:   ")==0)
           {
            StringReplace(fr,"  "," ");StringReplace(fr,"  "," ");StringReplace(fr,"  "," "); str_pos=StringFind(fr," ");

            num_input_signals=(int)StringToInteger(StringSubstr(fr,str_pos))-1;
            ArrayResize(InputSignal,num_input_signals);
            InputSignals="";
            for(i=0;i<num_input_signals;i++)
              {
               fr=FileReadString(FileHandle);StringTrimLeft(fr);
               if(StringFind(fr,"[list of attributes omitted]")==0) break;
               InputSignals+=fr+" ";
               InputSignal[i]=fr;
               neuronCount++; ArrayResize(neurons,neuronCount);
               neurons[neuronCount-1].activationfn="Input";
               StringReplace(fr,"  "," ");StringReplace(fr,"  "," ");StringReplace(fr,"  "," ");
               neurons[neuronCount-1].numNode=fr;
              }
            //InputSignals=StringSubstr(InputSignals,0,StringLen(InputSignals)-1);
           }
         if("=== Classifier model (full training set) ==="==fr)
           {
            fr=FileReadString(FileHandle);
            while(""!=(fr=FileReadString(FileHandle)))
              {
               if(StringFind(fr,"Sigmoid Node")==0)
                 {
                  neuronCount++; ArrayResize(neurons,neuronCount);
                  neurons[neuronCount-1].activationfn="Sigmoid";
                  StringReplace(fr,"  "," ");StringReplace(fr,"  "," ");StringReplace(fr,"  "," ");
                  neurons[neuronCount-1].numNode=StringSubstr(fr,StringLen("Sigmoid Node "));
                  fr=FileReadString(FileHandle);fr=FileReadString(FileHandle);
                  neurons[neuronCount-1].Threshold=(double)StringToDouble(StringSubstr(fr,StringLen("    Threshold    ")));
                 }
               if(StringFind(fr,"    Node ")==0)
                 {
                  weightCount++; ArrayResize(weights,weightCount);
                  weights[weightCount-1].numNodeFrom=neurons[neuronCount-1].numNode;
                  inputString=StringSubstr(fr,StringLen("    Node "));
                  StringReplace(inputString,"  "," ");StringReplace(inputString,"  "," ");StringReplace(inputString,"  "," ");
                  str_pos=StringFind(inputString," ");

                  //    Node 3    -7.166206697817879
                  weights[weightCount-1].numNodeTo=StringSubstr(inputString,0,str_pos);
                  weights[weightCount-1].weight=(double)StringToDouble(StringSubstr(inputString,str_pos));
                 }
               if(StringFind(fr,"    Attrib ")==0)
                 {
                  weightCount++; ArrayResize(weights,weightCount);
                  weights[weightCount-1].numNodeFrom=neurons[neuronCount-1].numNode;

                  inputString=StringSubstr(fr,StringLen("    Attrib "));
                  StringReplace(inputString,"  "," ");StringReplace(inputString,"  "," ");StringReplace(inputString,"  "," ");
                  str_pos=StringFind(inputString," ");

                  weights[weightCount-1].weight=(double)StringToDouble(StringSubstr(inputString,str_pos));
                  inputString=StringSubstr(inputString,0,str_pos);
                  StringTrimLeft(inputString);StringTrimRight(inputString);
                  weights[weightCount-1].numNodeTo=inputString;
                  for(i=0;i<num_input_signals && InputSignal[i]!=NULL && InputSignal[i]!=weights[weightCount-1].numNodeTo;i++);
                  if(InputSignal[i]!=weights[weightCount-1].numNodeTo)
                    {
                     InputSignal[i]=weights[weightCount-1].numNodeTo;
                     InputSignals+=InputSignal[i]+" ";
                    }
                 }
               if(StringFind(fr,"Class")==0)
                 {
                  num_output_signals++; ArrayResize(OutputSignal,num_output_signals);
                  inputString=StringSubstr(fr,StringLen("Class "));
                  StringReplace(inputString,"  "," ");StringReplace(inputString,"  "," ");StringReplace(inputString,"  "," ");
                  StringTrimLeft(inputString);StringTrimRight(inputString);
                  OutputSignal[num_output_signals-1]=inputString;
                  //               str_pos=StringFind(inputString," ");
                  fr=FileReadString(FileHandle);fr=FileReadString(FileHandle);
                  inputString=StringSubstr(fr,StringLen("    Node "));
                  StringReplace(inputString,"  "," ");StringReplace(inputString,"  "," ");StringReplace(inputString,"  "," ");
                  for(i=0;i<neuronCount;i++)
                    {
                     if(neurons[i].numNode==inputString)
                       {
                        for(j=0;j<weightCount;j++)
                          {
                           if(weights[j].numNodeFrom==neurons[i].numNode) weights[j].numNodeFrom=OutputSignal[num_output_signals-1];
                           //                          if(weights[j].numNodeTo==neurons[i].numNode) weights[j].numNodeTo=OutputSignal[num_output_signals-1];
                          }
                        neurons[i].numNode=OutputSignal[num_output_signals-1];
                        break;
                       }
                    }
                 }
              }
           }
        }
      for(i=0;i<num_input_signals;i++)
        {
         for(j=0;j<neuronCount && InputSignal[i]!=neurons[j].numNode;j++);
         if(j==neuronCount || InputSignal[i]!=neurons[j].numNode)
           {
            neuronCount++; ArrayResize(neurons,neuronCount);
            neurons[neuronCount-1].activationfn="Input";
            neurons[neuronCount-1].Threshold=0;
            neurons[neuronCount-1].isCalculated=false;
            neurons[neuronCount-1].numNode=InputSignal[i];
            neurons[neuronCount-1].Value=0;
           }
        }

      for(j=0;j<weightCount;j++)
         for(i=0;i<neuronCount;i++)
           {
            if(weights[j].numNodeFrom==neurons[i].numNode) weights[j].NeuronFrom=i;
            if(weights[j].numNodeTo==neurons[i].numNode)weights[j].NeuronTo=i;
           }
      FileClose(FileHandle);
      if(false)
        {
         FileHandle=FileOpen("new_"+_filename,FILE_WRITE|FILE_ANSI|FILE_TXT);
         for(i=0;i<neuronCount;i++)
           {
            FileWrite(FileHandle,neurons[i].activationfn," ",neurons[i].numNode);
            FileWrite(FileHandle,"     Inputs    Weights");
            FileWrite(FileHandle,"     Threshold ",neurons[i].Threshold);
            for(j=0;j<weightCount;j++)
              {
               if(weights[j].numNodeFrom==neurons[i].numNode)
                 {
                  FileWrite(FileHandle,"     ",weights[j].numNodeTo," ",weights[j].weight);
                 }
              }

           }
         FileClose(FileHandle);
        }

      //      if(num_input_signals!=_inputCount)
      //        {
      //         Print("ini not for this eg!");_layerCount=0;
      //        }
      //      //num_input_signals=_inputCount;
      ArrayResize(InputVector,num_input_signals);
      ArrayResize(OutputVector,num_output_signals);
      //
      StringTrimRight(InputSignals);
      Print(Name()," ready! IS: (",num_input_signals,")",InputSignals);
      IsInit=true;
     }
   else
      Print("not found ",_filename);
////_layerCount=ArraySize(_weightIndex);
//   ArrayResize(_layerSums,_neuronCount);
//   ClearTraning=false;
//
//   int i;
//   for(i=0;i<ArraySize(VectorFunctions) && VectorFunctions[i]!=NULL && VectorFunctions[i]!="";i++)
//     {
//      Functions_Array[i]=VectorFunctions[i];
//      Functions_Count[i]=0;
//     }
//
//   if(_layerCount==0) GetVectors(InputVector,InputSignals,smb,0,1);
//   else GetVectors(InputVector,templateInputSignals,smb,0,1);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COracleENCOG:public COracleTemplate
  {
private:
   string            Functions_Array[50];
   int               Functions_Count[50];

   string            File_Name;
   // begin Encog main config
   string            _FILENAME;
   int               _neuronCount;
   int               _layerCount;
   int               _contextTargetOffset[];
   int               _contextTargetSize[];
   bool              _hasContext;
   int               _inputCount;
   int               _layerContextCount[];
   int               _layerCounts[];
   int               _layerFeedCounts[];
   int               _layerIndex[];
   double            _layerOutput[];
   double            _layerSums[];
   int               _outputCount;
   int               _weightIndex[];
   double            _weights[];
   int               _activation[];
   double            _p[];
   // end Encog main config

   void              ActivationTANH(double &x[],int start,int size);
   void              ActivationSigmoid(double &x[],int start,int size);
   void              ActivationElliottSymmetric(double &x[],int start,int size);
   void              ActivationElliott(double &x[],int start,int size);

   //  void              Compute(double &_input[],double &_output[]);
   double Norm(double x,double normalizedHigh,double normalizedLow,double dataHigh,double dataLow)
     {
      return (((x - dataLow)
              /(dataHigh-dataLow))
              *(normalizedHigh-normalizedLow)+normalizedLow);
     }

   double DeNorm(double x,double normalizedHigh,double normalizedLow,double dataHigh,double dataLow)
     {
      return (((dataLow - dataHigh) * x - normalizedHigh
              *dataLow+dataHigh*normalizedLow)
              /(normalizedLow-normalizedHigh));
     }

public:
   void              Compute(double &_input[],double &_output[]);
   void              ComputeLayer(int currentLayer);
   virtual string    Name(){return("Encog");};
   bool              ClearTraning;
   //   double            InputVector[];

                     COracleENCOG(string FileName=""){Init(FileName);}
   //                 ~COracleENCOG(){DeInit();}
   bool              GetVector(string smbl="",int shift=0,bool train=false);
   //  bool              debug;
   void              Init(string FileName="",bool ip_debug=false);
   virtual void      DeInit();
   //   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   bool              Load(string file_name);
   bool              Save(string file_name="");

   int               ExportDataWithTest(int train_qty,int test_qty,string &Symbols_Array[],string FileName="");
   int               ExportData(int qty,int shift,string &Symbols_Array[],string FileName,bool test=false);
   virtual bool      CustomLoad(int file_handle){return(false);};
   virtual bool      CustomSave(int file_handle){return(false);};
   virtual bool      Draw(int window,datetime &time[],int w,int h){return(true);};
   int               num_input();
   virtual double    forecast(string smbl,ENUM_TIMEFRAMES,int shift,bool train,string coment);
   virtual double    forecast(string smbl,ENUM_TIMEFRAMES,datetime startdt,bool train,string coment);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COracleENCOG::Init(string FileName="",bool ip_debug=false)
  {
//TimeFrame=PERIOD_M1;
   COracleTemplate::Init(FileName,ip_debug);
   if(""!=FileName) _FILENAME=FileName;
   else  _FILENAME=Name();

   string _filename=_FILENAME+"_"+smb+"_"+TimeFrameName(TimeFrame)+".eg";
   string inputString;
   ArrayResize(OutputVector,1);
   _layerCount=0; //int tempar
   _neuronCount=0;
   int FileHandle=FileOpen(_filename,FILE_READ|FILE_ANSI|FILE_CSV,'=');
   string fr;
   if(FileHandle!=INVALID_HANDLE)
     {
      while(""!=(fr=FileReadString(FileHandle)))
        {
         _layerCount=0;
         if("contextTargetOffset"==fr)
           {
            inputString=FileReadString(FileHandle);
            int start_pos=0,end_pos=0,shift_pos=0;
            end_pos=StringFind(inputString,",",start_pos);
            do
              {
               _layerCount++; ArrayResize(_contextTargetOffset,_layerCount);
               _contextTargetOffset[_layerCount-1]=(int)StringToInteger(StringSubstr(inputString,start_pos,end_pos-start_pos));
               start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
              }
            while(start_pos>0);
           }
         else if("contextTargetSize"==fr)
           {
            inputString=FileReadString(FileHandle);
            int start_pos=0,end_pos=0,shift_pos=0;
            end_pos=StringFind(inputString,",",start_pos);
            do
              {
               _layerCount++; ArrayResize(_contextTargetSize,_layerCount);
               _contextTargetSize[_layerCount-1]=(int)StringToInteger(StringSubstr(inputString,start_pos,end_pos-start_pos));
               start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
              }
            while(start_pos>0);
           }
         else if("layerContextCount"==fr)
           {
            inputString=FileReadString(FileHandle);
            int start_pos=0,end_pos=0,shift_pos=0;
            end_pos=StringFind(inputString,",",start_pos);
            do
              {
               _layerCount++; ArrayResize(_layerContextCount,_layerCount);
               _layerContextCount[_layerCount-1]=(int)StringToInteger(StringSubstr(inputString,start_pos,end_pos-start_pos));

               start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
              }
            while(start_pos>0);
           }
         else if("layerCounts"==fr)
           {
            inputString=FileReadString(FileHandle);
            int start_pos=0,end_pos=0,shift_pos=0;
            end_pos=StringFind(inputString,",",start_pos);
            do
              {
               _layerCount++; ArrayResize(_layerCounts,_layerCount);
               _layerCounts[_layerCount-1]=(int)StringToInteger(StringSubstr(inputString,start_pos,end_pos-start_pos));
               _neuronCount+=_layerCounts[_layerCount-1];
               start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
              }
            while(start_pos>0);
           }
         else if("layerFeedCounts"==fr)
           {
            inputString=FileReadString(FileHandle);
            int start_pos=0,end_pos=0,shift_pos=0;
            end_pos=StringFind(inputString,",",start_pos);
            do
              {
               _layerCount++; ArrayResize(_layerFeedCounts,_layerCount);
               _layerFeedCounts[_layerCount-1]=(int)StringToInteger(StringSubstr(inputString,start_pos,end_pos-start_pos));
               start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
              }
            while(start_pos>0);
           }
         else if("layerContextCount"==fr)
           {
            inputString=FileReadString(FileHandle);
            int start_pos=0,end_pos=0,shift_pos=0;
            end_pos=StringFind(inputString,",",start_pos);
            do
              {
               _layerCount++; ArrayResize(_layerContextCount,_layerCount);
               _layerContextCount[_layerCount-1]=(int)StringToInteger(StringSubstr(inputString,start_pos,end_pos-start_pos));
               start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
              }
            while(start_pos>0);
           }
         else if("layerIndex"==fr)
           {
            inputString=FileReadString(FileHandle);
            int start_pos=0,end_pos=0,shift_pos=0;
            end_pos=StringFind(inputString,",",start_pos);
            do
              {
               _layerCount++; ArrayResize(_layerIndex,_layerCount);
               _layerIndex[_layerCount-1]=(int)StringToInteger(StringSubstr(inputString,start_pos,end_pos-start_pos));
               start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
              }
            while(start_pos>0);
           }
         else if("inputCount"==fr)
           {
            inputString=FileReadString(FileHandle);
            _inputCount=(int)StringToInteger(inputString);
           }
         else if("outputCount"==fr)
           {
            inputString=FileReadString(FileHandle);
            _outputCount=(int)StringToInteger(inputString);
           }
         else if("hasContext"==fr)
           {
            inputString=FileReadString(FileHandle);

            _hasContext=("t"==inputString);
           }
         else if("output"==fr)
           {
            inputString=FileReadString(FileHandle);
            int start_pos=0,end_pos=0,shift_pos=0;
            end_pos=StringFind(inputString,",",start_pos);
            do
              {
               _layerCount++; ArrayResize(_layerOutput,_layerCount);
               _layerOutput[_layerCount-1]=(int)StringToInteger(StringSubstr(inputString,start_pos,end_pos-start_pos));
               start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
              }
            while(start_pos>0);
           }
         else if("weightIndex"==fr)
           {
            inputString=FileReadString(FileHandle);
            int start_pos=0,end_pos=0,shift_pos=0;
            end_pos=StringFind(inputString,",",start_pos);
            do
              {
               _layerCount++; ArrayResize(_weightIndex,_layerCount);
               _weightIndex[_layerCount-1]=(int)StringToInteger(StringSubstr(inputString,start_pos,end_pos-start_pos));
               start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
              }
            while(start_pos>0);
           }

         else if(StringFind(fr,"weights")!=-1)
           {
            int _weightsSize=_weightIndex[ArraySize(_weightIndex)-1];
            ArrayResize(_weights,_weightsSize,100);
            inputString=FileReadString(FileHandle);
            if("##0"==inputString) continue;
            int start_pos=0,end_pos=0,shift_pos=0;
            end_pos=StringFind(inputString,",",start_pos);
            do
              {
               _layerCount++; string ss=StringSubstr(inputString,start_pos,end_pos-start_pos);StringTrimLeft(ss);
               _weights[_layerCount-1]=(double)StringToDouble(ss);
               start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
              }
            while(start_pos>0);
           }
         else if(StringFind(fr,"##double")!=-1)
           {
            int _weightsSize=ArraySize(_weights);
            //           ArrayResize(_weights,_weightsSize,100);
            do
              {
               inputString=FileReadString(FileHandle);
               int start_pos=0,end_pos=0,shift_pos=0;
               end_pos=StringFind(inputString,",",start_pos);
               do
                 {
                  _layerCount++; string ss=StringSubstr(inputString,start_pos,end_pos-start_pos);StringTrimLeft(ss);
                  _weights[_layerCount-1]=(double)StringToDouble(ss);
                  start_pos=end_pos+1;    end_pos=StringFind(inputString,",",start_pos);
                 }
               while(start_pos>0);
              }
            while(_weightsSize>_layerCount);
            inputString=FileReadString(FileHandle);
           }
         else if(StringFind(fr,"[BASIC:ACTIVATION]")!=-1)
           {

            _layerCount=ArraySize(_weightIndex);
            ArrayResize(_activation,_layerCount); ArrayResize(_p,_layerCount);
            for(int i=0;i<_layerCount;i++)
              {
               inputString=FileReadString(FileHandle);
               _activation[i]=0;_p[i]=1;
               if(StringFind(inputString,"ActivationTANH")>0)_activation[i]=1;
              }
           }
         else if(StringFind(fr,"]")==-1) FileReadString(FileHandle);
        }
      FileClose(FileHandle);
      if(num_input_signals!=_inputCount)
        {
         Print("ini not for this eg!");_layerCount=0;
        }
      //num_input_signals=_inputCount;
      ArrayResize(InputVector,num_input_signals);

     }
   else
      Print("not found ",_filename);
//_layerCount=ArraySize(_weightIndex);
   ArrayResize(_layerSums,_neuronCount);
   ClearTraning=false;

   int i;
   for(i=0;i<ArraySize(VectorFunctions) && VectorFunctions[i]!=NULL && VectorFunctions[i]!="";i++)
     {
      Functions_Array[i]=VectorFunctions[i];
      Functions_Count[i]=0;
     }
   TimeFrame=_Period;
   if(_layerCount==0) GetVectors(InputVector,InputSignals,smb,0,1);
   else GetVectors(InputVector,templateInputSignals,smb,0,1);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COracleENCOG::ActivationTANH(double &x[],int start,int size)
  {
   for(int i=start; i<start+size; i++)
     {
      x[i]=2.0/(1.0+MathExp(-2.0*x[i]))-1.0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COracleENCOG::ActivationSigmoid(double &x[],int start,int size)
  {
   for(int i=start; i<start+size; i++)
     {
      x[i]=1.0/(1.0+MathExp(-1*x[i]));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COracleENCOG::ActivationElliottSymmetric(double &x[],int start,int size)
  {
   for(int i=start; i<start+size; i++)
     {
      double s=_p[0];
      x[i]=(x[i]*s)/(1+MathAbs(x[i]*s));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COracleENCOG::ActivationElliott(double &x[],int start,int size)
  {
   for(int i=start; i<start+size; i++)
     {
      double s=_p[0];
      x[i]=((x[i]*s)/2)/(1+MathAbs(x[i]*s))+0.5;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COracleENCOG::ComputeLayer(int currentLayer)
  {
   int x,y;
   int inputIndex=_layerIndex[currentLayer];
   int outputIndex=_layerIndex[currentLayer-1];
   int inputSize=_layerCounts[currentLayer];
   int outputSize=_layerFeedCounts[currentLayer-1];

   int index=_weightIndex[currentLayer-1];

   int limitX = outputIndex + outputSize;
   int limitY = inputIndex + inputSize;

// weight values
   for(x=outputIndex; x<limitX; x++)
     {
      double sum=0;
      for(y=inputIndex; y<limitY; y++)
        {
         sum+=_weights[index]*_layerOutput[y];
         index++;
        }

      _layerOutput[x]=sum;
      _layerSums[x]=sum;
     }

   switch(_activation[currentLayer-1])
     {
      case 0: // linear
         break;
      case 1:
         ActivationTANH(_layerOutput,outputIndex,outputSize);
         break;
      case 2:
         ActivationSigmoid(_layerOutput,outputIndex,outputSize);
         break;
      case 3:
         ActivationElliottSymmetric(_layerOutput,outputIndex,outputSize);
         break;
      case 4:
         ActivationElliott(_layerOutput,outputIndex,outputSize);
         break;
     }

// update context values
   int offset=_contextTargetOffset[currentLayer];

   for(x=0; x<_contextTargetSize[currentLayer]; x++)
     {
      _layerOutput[offset+x]=_layerOutput[outputIndex+x];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COracleENCOG::Compute(double &_input[],double &_output[])
  {
   int i,x;
   int sourceIndex=_neuronCount
                   -_layerCounts[_layerCount-1];

   ArrayCopy(_layerOutput,_input,sourceIndex,0,_inputCount);

   for(i=_layerCount-1; i>0; i--)
     {
      ComputeLayer(i);
     }

// update context values
   int offset=_contextTargetOffset[0];

   for(x=0; x<_contextTargetSize[0]; x++)
     {
      _layerOutput[offset+x]=_layerOutput[x];
     }

   ArrayCopy(_output,_layerOutput,0,0,_outputCount);
  }
//+------------------------------------------------------------------+
double COracleENCOG::forecast(string smbl,ENUM_TIMEFRAMES tf,int shift,bool train,string comment)
  {

   if(""==smbl) smbl=_Symbol;
   double sig=GetVectors(InputVector,InputSignals,smbl,0,shift);
   if(sig<-1||sig>1) return 0;
   if(0==_layerCount)
      sig=0;
   else
     {
      Compute(InputVector,OutputVector);
      if(_ResultAsString_ && _outputCount==2)
        {
         if(OutputVector[0]>OutputVector[1])
            sig=OutputVector[0];
         if(OutputVector[0]<OutputVector[1])
            sig=-OutputVector[1];

        }
      else if(_ResultAsString_ && _outputCount==4)
        {//"prediction","Buy","Buy",10998
         //"prediction","CloseBuy","CloseBuy",10335
         //"prediction","CloseSell","CloseSell",9990
         //"prediction","Sell","Sell",11050
         //"prediction","Wait","Wait",11142
         double MSig=MathMax(OutputVector[0],MathMax(OutputVector[1],MathMax(OutputVector[2],OutputVector[3])));
         if(OutputVector[0]==MSig)         sig=MSig;
         if(OutputVector[1]==MSig)         sig=MSig/2;
         if(OutputVector[2]==MSig)         sig=-MSig/2;
         if(OutputVector[3]==MSig)         sig=-MSig;
         if(MSig<0) sig=0;
         //comment=""+OutputVector[0]+" "+OutputVector[1]+" "+OutputVector[2]+" "+OutputVector[3];
        }
      else sig=OutputVector[0];
     }
//   int i,j;
//   //if(INVALID_HANDLE==errorFile)
//   //  {
//   //   errorFile=FileOpen("errors.txt",FILE_WRITE|FILE_ANSI|FILE_CSV,' ');
//   //   FileWrite(errorFile,"debug info ");
//   //  }
//
//   if(AgeHistory<_TREND_) AgeHistory++;
//   for(i=AgeHistory;i>1;i--)
//     {
//      for(j=0;j<num_input_signals;j++) HistoryInputVector[j+(i-1)*num_input_signals]=HistoryInputVector[j+(i-2)*num_input_signals];
//     }
//   for(j=0;j<num_input_signals;j++)
//      HistoryInputVector[j]=InputVector[j];
//
//   for(i=1;i<AgeHistory;i++)
//     {
//      GetVectors(InputVector,InputSignals,smbl,0,i+shift);
//      for(j=0;j<num_input_signals;j++)
//        {
//         if(HistoryInputVector[j+(i)*num_input_signals]!=InputVector[j])
//           {
//            FileWrite(errorFile,"not compare! ",InputSignal[j]," shift=",i," old= ",HistoryInputVector[j+(i)*num_input_signals]," new=",InputVector[j]);
//            //Print("not compare! ",InputSignal[j]," shift=",i);
//           }
//         //HistoryInputVector[j+(i-1)*num_input_signals]=InputVector[j];
//        }
//     }

   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double COracleENCOG::forecast(string smbl,ENUM_TIMEFRAMES tf,datetime startdt,bool train,string comment)
  {
   double sig=0;
//   double ind1_buffer[];
//   double ind2_buffer[];
//   int   h_ind1=iMA(smbl,PERIOD_M1,8,0,MODE_SMA,PRICE_CLOSE);
//   if(CopyBuffer(h_ind1,0,startdt,3,ind1_buffer)<3) return(0);
//   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);
//   int   h_ind2=iMA(smbl,PERIOD_M1,16,0,MODE_SMA,PRICE_CLOSE);
//   if(CopyBuffer(h_ind2,0,startdt,2,ind2_buffer)<2) return(0);
//   if(!ArraySetAsSeries(ind2_buffer,true))return(0);
//
////--- проводим проверку условия и устанавливаем значение для sig
//   if(ind1_buffer[2]<ind2_buffer[1] && ind1_buffer[1]>ind2_buffer[1])
//      sig=1;
//   else if(ind1_buffer[2]>ind2_buffer[1] && ind1_buffer[1]<ind2_buffer[1])
//      sig=-1;
//   else sig=0;
//   IndicatorRelease(h_ind1);   IndicatorRelease(h_ind2);
////--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class WekaJ48Node
  {
   string            Variable;
   double            Value;
   string            Result;
   WekaJ48Node      *IfLessOrEq;
   WekaJ48Node      *IfMore;
   WekaJ48Node      *Parient;
  }
;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CWekaJ48
  {
public:
   string            smbl;
   ENUM_TIMEFRAMES   tf;
   string            InputSignals;
   string            InputSignal[];
   int               num_input_signals;
   WekaJ48Node       Nodes[];
   int               Instances;
   WekaJ48Node      *rootNode;
   bool              Init(string FileName="",bool ip_debug=false);
   double            forecast(int shift,bool train);
  }
;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COracleWeka:public COracleTemplate
  {
   // private:

   CWekaJ48          wekaJ48[];
public:
   virtual double    forecast(string smbl,int shift,bool train,string comment);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("Weka");};
   virtual void      Init(string FileName="",bool ip_debug=false){};
   virtual void Init_EURUSD_M1(string FileName="",bool ip_debug=false) {};

   bool              GenerateFromFile(string filename);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double    COracleWeka::forecast(string smbl,int shift,bool train,string comment)
  {
   if(""==smbl) smbl=_Symbol;
// Search 
//  CWekaJ48 foundedWeka;
   int i;
   for(i=0;i<ArraySize(wekaJ48);i++)
     {
      if(wekaJ48[i].smbl==smbl) break;//foundedWeka=wekaJ48[i];
     }
   if(i==ArraySize(wekaJ48))
     {
      ArrayResize(wekaJ48,i+1);
      //wekaJ48[i]=new CWekaJ48();
      wekaJ48[i].smbl=smbl;
      //wekaJ48[i].tf =tv
      wekaJ48[i].Init();
     }
   double sig=GetVectors(InputVector,wekaJ48[i].InputSignals,smbl,0,shift);
//   if(sig<-1||sig>1) return 0;
//   Compute(InputVector,OutputVector);
//   if(_ResultAsString_ && _outputCount==2)
//     {
//      if(OutputVector[0]>OutputVector[1])
//         sig=OutputVector[0];
//      if(OutputVector[0]<OutputVector[1])
//         sig=-OutputVector[1];
//
//     }
//   else if(_ResultAsString_ && _outputCount==4)
//
   return sig;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWekaJ48::Init(string FileName="",bool ip_debug=false)
  {
   if(FileName=="") FileName="Weka_"+smbl+"_"+TimeFrameName(tf)+".j48";
   int FileHandleTemplate=FileOpen(FileName,FILE_READ|FILE_ANSI|FILE_TXT|FILE_SHARE_READ);
   if(FileHandleTemplate==INVALID_HANDLE)
     {
      Print("Error open file for read "+FileName);
      return(false);
     }
   string fr;
   string smbl_AS="",tf_AS=""; string fn_name;
   while(!FileIsEnding(FileHandleTemplate))
     {
      fr=FileReadString(FileHandleTemplate);
      int strl=StringLen(fr);
      if(StringFind(fr,"Relation:")==0)
        {
         int sp1= StringFind(fr,"_");
         int sp2= StringFind(fr,"_",sp1+1);

         smbl_AS=StringSubstr(fr,sp1+1,sp2-sp1-1);
         tf_AS=StringSubstr(fr,sp2+1);
        }
      if(StringFind(fr,"Attributes:")==0)
        {
         while(!FileIsEnding(FileHandleTemplate))
           {
            fr=FileReadString(FileHandleTemplate);
            if(StringFind(fr,"Test mode:")==0) break;
            fn_name=fr; StringTrimLeft(fn_name);
            if("prediction"==fn_name) continue;
            num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+=fn_name+" "; InputSignal[num_input_signals-1]=fn_name;
           }
         StringTrimRight(InputSignals);
        }
      if(StringFind(fr,"Instances:")==0) Instances=(int)StringToInteger(StringSubstr(fr,10));
      if(StringFind(fr,"J48 pruned tree")==0)
        {
         ArrayResize(Nodes,Instances);
         fr=FileReadString(FileHandleTemplate);
         fr=FileReadString(FileHandleTemplate);
         int currNode=0,newNode=0;
         while(!FileIsEnding(FileHandleTemplate))
           {
            fr=FileReadString(FileHandleTemplate);
            StringTrimLeft(fr);
            if(fr=="") break;

           }
         StringTrimRight(InputSignals);
        }

     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool COracleWeka::GenerateFromFile(string p_filename)
  {
   int FileHandleTemplate=FileOpen(p_filename,FILE_READ|FILE_ANSI|FILE_TXT|FILE_SHARE_READ);
   if(FileHandleTemplate==INVALID_HANDLE)
     {
      Print("Error open file for write OracleDummy_fc.mqh");
      return(false);
     }
   string fr;
   string smbl_AS="",tf_AS=""; string fn_name;
   int FileHandleOC=INVALID_HANDLE;
   while(!FileIsEnding(FileHandleTemplate))
     {
      fr=FileReadString(FileHandleTemplate);
      int strl=StringLen(fr);
      if(StringFind(fr,"Relation:")==0)
        {
         int sp1= StringFind(fr,"_");
         int sp2= StringFind(fr,"_",sp1+1);

         smbl_AS=StringSubstr(fr,sp1+1,sp2-sp1-1);
         tf_AS=StringSubstr(fr,sp2+1);
        }
      if(StringFind(fr,"Attributes:")==0)
        {
         FileHandleOC=FileOpen("OracleWekaJ48_"+smbl_AS+"_"+tf_AS+".mqh",FILE_WRITE|FILE_ANSI,' ');
         FileWrite(FileHandleOC,"void CWekaJ48::Init_"+smbl_AS+"_"+tf_AS+"(string FileName=\"\",bool ip_debug=false)  ");
         FileWrite(FileHandleOC,"{  ");
         while(!FileIsEnding(FileHandleTemplate))
           {
            fr=FileReadString(FileHandleTemplate);
            if(StringFind(fr,"Test mode:")==0) break;
            fn_name=fr; StringTrimLeft(fn_name);
            if("prediction"==fn_name) continue;
            FileWrite(FileHandleOC,"  num_input_signals++; ArrayResize(InputSignal,num_input_signals);InputSignals+=\""+fn_name+" \"; InputSignal[num_input_signals-1]=\""+fn_name+"\";");
           }
         FileWrite(FileHandleOC,"StringTrimRight(InputSignals);\n}  \n");
        }
     }
   FileWrite(FileHandleOC,"double CWekaJ48::forecast_"+smbl_AS+"_"+tf_AS+"(string smbl,int shift,bool train)  ");
   FileWrite(FileHandleOC," {");
   if(FileHandleOC!=INVALID_HANDLE)
     {
      FileWrite(FileHandleOC,"  return(0);");
      FileWrite(FileHandleOC," }");
      FileClose(FileHandleOC);
     }
   Print("Template generated.");
   FileClose(FileHandleTemplate);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CEasy:public COracleTemplate
  {
   //  virtual double    forecast(string smbl,int shift,bool train);
   // virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("Easy");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class CiMA:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iMA");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CiMA::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   double ind1_buffer[];
   double ind2_buffer[];
   int   h_ind1=iMA(smbl,PERIOD_M1,8,0,MODE_SMA,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);
   int   h_ind2=iMA(smbl,PERIOD_M1,16,0,MODE_SMA,PRICE_CLOSE);
   if(CopyBuffer(h_ind2,0,0,2,ind2_buffer)<2) return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))return(0);

//--- проводим проверку условия и устанавливаем значение для sig
   if(ind1_buffer[2]<ind2_buffer[1] && ind1_buffer[1]>ind2_buffer[1])
      sig=1;
   else if(ind1_buffer[2]>ind2_buffer[1] && ind1_buffer[1]<ind2_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);   IndicatorRelease(h_ind2);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CiMA::forecast(string smbl,datetime startdt,bool train)
  {
   double sig=0;
   double ind1_buffer[];
   double ind2_buffer[];
   int   h_ind1=iMA(smbl,PERIOD_M1,8,0,MODE_SMA,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,startdt,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);
   int   h_ind2=iMA(smbl,PERIOD_M1,16,0,MODE_SMA,PRICE_CLOSE);
   if(CopyBuffer(h_ind2,0,startdt,2,ind2_buffer)<2) return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))return(0);

//--- проводим проверку условия и устанавливаем значение для sig
   if(ind1_buffer[2]<ind2_buffer[1] && ind1_buffer[1]>ind2_buffer[1])
      sig=1;
   else if(ind1_buffer[2]>ind2_buffer[1] && ind1_buffer[1]<ind2_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);   IndicatorRelease(h_ind2);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class CiMACD:public COracleTemplate
  {
protected:
   double            m_adjusted_point;             // point value adjusted for 3 or 5 points
                                                   //CTrade            m_trade;                      // trading object
   //CSymbolInfo       m_symbol;                     // symbol info object
   //CPositionInfo     m_position;                   // trade position object
   //CAccountInfo      m_account;                    // account info wrapper
   string            symbol;
   //--- indicators
   int               m_handle_macd;                // MACD indicator handle
   int               m_handle_ema;                 // moving average indicator handle
   //--- indicator buffers
   double            m_buff_MACD_main[];           // MACD indicator main buffer
   double            m_buff_MACD_signal[];         // MACD indicator signal buffer
   double            m_buff_EMA[];                 // EMA indicator buffer
   int               pMACD1;
   int               pMACD2;
   int               pMACD3;
   int               pMATrendPeriod;
   //--- indicator data for processing
   double            m_macd_current;
   double            m_macd_previous;
   double            m_signal_current;
   double            m_signal_previous;
   double            m_ema_current;
   double            m_ema_previous;
   double            m_macd_open_level;
   double            m_macd_close_level;
public:
                     CiMACD(string FileName=""){Init();}
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iMACD");};
   bool              Init(string i_smbl="",int i_MACD1=0,
                          int i_MACD2=0,
                          int i_MACD3=0,
                          int i_MATrendPeriod=0);
protected:
   bool              InitCheckParameters(const int digits_adjust);
   bool              InitIndicators(void);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiMACD::Init(string i_smbl="",int i_MACD1=0,
                  int i_MACD2=0,
                  int i_MACD3=0,
                  int i_MATrendPeriod=0)
  {
   m_handle_macd=INVALID_HANDLE;
   m_handle_ema=INVALID_HANDLE;
   IsInit=true;
   symbol=i_smbl;
   pMACD1=i_MACD1;
   pMACD2=i_MACD2;
   pMACD3=i_MACD3;
   pMATrendPeriod=i_MATrendPeriod;
   if(""==symbol)symbol=Symbol();
   if(0==pMACD1) pMACD1 = 48;
   if(0==pMACD2) pMACD2 = 36;
   if(0==pMACD3) pMACD3 = 19;
   if(0==pMATrendPeriod) pMATrendPeriod = 160;

   CSymbolInfo       m_symbol;
//--- initialize common information
   m_symbol.Name(symbol);              // symbol
                                       //   m_trade.SetExpertMagicNumber(12345);  // magic
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- set default deviation for trading in adjusted points
   m_macd_open_level =3*m_adjusted_point;
   m_macd_close_level=2*m_adjusted_point;
//m_traling_stop    =i_TrailingStop*m_adjusted_point;
//m_take_profit     =i_TakeProfit*m_adjusted_point;
//--- set default deviation for trading in adjusted points
//  m_trade.SetDeviationInPoints(3*digits_adjust);
//---
//  if(!InitCheckParameters(digits_adjust))
//    return(false);
   ArraySetAsSeries(m_buff_MACD_main,true);
   ArraySetAsSeries(m_buff_MACD_signal,true);
   ArraySetAsSeries(m_buff_EMA,true);
   if(!InitIndicators())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of the indicators                                 |
//+------------------------------------------------------------------+
bool CiMACD::InitIndicators(void)
  {
//--- create MACD indicator
   if(m_handle_macd==INVALID_HANDLE)
      if((m_handle_macd=iMACD(NULL,0,pMACD1,pMACD2,pMACD3,PRICE_CLOSE))==INVALID_HANDLE)
        {
         printf("Error creating MACD indicator");
         return(false);
        }
//--- create EMA indicator and add it to collection
   if(m_handle_ema==INVALID_HANDLE)
      if((m_handle_ema=iMA(NULL,0,pMATrendPeriod,0,MODE_EMA,PRICE_CLOSE))==INVALID_HANDLE)
        {
         printf("Error creating EMA indicator");
         return(false);
        }
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CiMACD::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(!IsInit)
     {
      Print("Not Init!");
      return(0);
     }
   if(""==smbl) smbl=Symbol();

   if(BarsCalculated(m_handle_macd)<2 || BarsCalculated(m_handle_ema)<2)
      return(sig);
   if(CopyBuffer(m_handle_macd,0,0,2,m_buff_MACD_main)  !=2 ||
      CopyBuffer(m_handle_macd,1,0,2,m_buff_MACD_signal)!=2 ||
      CopyBuffer(m_handle_ema,0,0,2,m_buff_EMA)         !=2)
      return(sig);
//   m_indicators.Refresh();
//--- to simplify the coding and speed up access
//--- data are put into internal variables
   m_macd_current   =m_buff_MACD_main[0];
   m_macd_previous  =m_buff_MACD_main[1];
   m_signal_current =m_buff_MACD_signal[0];
   m_signal_previous=m_buff_MACD_signal[1];
   m_ema_current    =m_buff_EMA[0];
   m_ema_previous   =m_buff_EMA[1];
//--- check for long position (BUY) possibility
   if(m_macd_current<0)
      if(m_macd_current>m_signal_current && m_macd_previous<m_signal_previous)
         if(MathAbs(m_macd_current)>(m_macd_open_level) && m_ema_current>m_ema_previous)
           {
            sig=1;
           }
//--- check for short position (SELL) possibility
   if(m_macd_current>0)
      if(m_macd_current<m_signal_current && m_macd_previous>m_signal_previous)
         if(m_macd_current>(m_macd_open_level) && m_ema_current<m_ema_previous)
           {
            sig=-1;
           }
//--- it is important to enter the market correctly, 
//--- but it is more important to exit it correctly...   
//--- first check if position exists - try to select it
//   if(m_position.Select(smbl))
//     {
//      if(m_position.PositionType()==POSITION_TYPE_BUY)
//        {
//         //--- try to close or modify long position
//         if(LongClosed())
//            return(true);
//         if(LongModified())
//            return(true);
//        }
//      else
//        {
//         //--- try to close or modify short position
//         if(ShortClosed())
//            return(true);
//         if(ShortModified())
//            return(true);
//        }
//     }
////--- no opened position identified
//   else
//     {
//      //--- check for long position (BUY) possibility
//      if(LongOpened())
//         return(true);
//      //--- check for short position (SELL) possibility
//      if(ShortOpened())
//         return(true);
//     }
//--- exit without position processing
   return(sig);

//   double ind1_buffer[];double ind2_buffer[];
//   int   h_ind1=iMACD(smbl,PERIOD_M1,12,26,9,PRICE_CLOSE);
//
//   if(CopyBuffer(h_ind1,0,shift,2,ind1_buffer)<2) return(0);
//   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3) return(0);
//   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
//   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
//
////--- проводим проверку условия и устанавливаем значение для sig
//   if(ind2_buffer[2]>ind1_buffer[1] && ind2_buffer[1]<ind1_buffer[1])
//      sig=1;
//   else if(ind2_buffer[2]<ind1_buffer[1] && ind2_buffer[1]>ind1_buffer[1])
//      sig=-1;
//   else sig=0;
//
//   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CiMACD::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];double ind2_buffer[];
   int   h_ind1=iMACD(smbl,PERIOD_M1,12,26,9,PRICE_CLOSE);

   if(CopyBuffer(h_ind1,0,shift,2,ind1_buffer)<2) return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);

//--- проводим проверку условия и устанавливаем значение для sig
   if(ind2_buffer[2]>ind1_buffer[1] && ind2_buffer[1]<ind1_buffer[1])
      sig=1;
   else if(ind2_buffer[2]<ind1_buffer[1] && ind2_buffer[1]>ind1_buffer[1])
      sig=-1;
   else sig=0;

   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPriceChanel:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("Price Chanel");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPriceChanel::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double Close[];
   int   h_ind1=iCustom(smbl,PERIOD_M1,"Price Channel",22);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(CopyClose(Symbol(),Period(),0,2,Close)<2) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(!ArraySetAsSeries(Close,true)) return(0);

//--- проводим проверку условия и устанавливаем значение для sig
   if(Close[1]>ind1_buffer[2])
      sig=1;
   else if(Close[1]<ind2_buffer[2])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPriceChanel::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double Close[];
   int   h_ind1=iCustom(smbl,PERIOD_M1,"Price Channel",22);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(CopyClose(Symbol(),Period(),0,2,Close)<2) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(!ArraySetAsSeries(Close,true)) return(0);

//--- проводим проверку условия и устанавливаем значение для sig
   if(Close[1]>ind1_buffer[2])
      sig=1;
   else if(Close[1]<ind2_buffer[2])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiStochastic:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iStochastic");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiStochastic::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iStochastic(smbl,PERIOD_M1,5,3,3,MODE_SMA,STO_LOWHIGH);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<20 && ind1_buffer[1]>20)
      sig=1;
   else if(ind1_buffer[2]>80 && ind1_buffer[1]<80)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiStochastic::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iStochastic(smbl,PERIOD_M1,5,3,3,MODE_SMA,STO_LOWHIGH);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<20 && ind1_buffer[1]>20)
      sig=1;
   else if(ind1_buffer[2]>80 && ind1_buffer[1]<80)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiRSI:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iRSI");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiRSI::forecast(string smbl="",int shift=0,bool train=false)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iRSI(smbl,PERIOD_M1,14,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<30 && ind1_buffer[1]>30)
      sig=1;
   else if(ind1_buffer[2]>70 && ind1_buffer[1]<70)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiRSI::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iRSI(smbl,PERIOD_M1,14,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<30 && ind1_buffer[1]>30)
      sig=1;
   else if(ind1_buffer[2]>70 && ind1_buffer[1]<70)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiCGI:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iCGI");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiCGI::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iCCI(smbl,PERIOD_M1,14,PRICE_TYPICAL);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<-100 && ind1_buffer[1]>-100)
      sig=1;
   else if(ind1_buffer[2]>100 && ind1_buffer[1]<100)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiCGI::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iCCI(smbl,PERIOD_M1,14,PRICE_TYPICAL);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<-100 && ind1_buffer[1]>-100)
      sig=1;
   else if(ind1_buffer[2]>100 && ind1_buffer[1]<100)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiWPR:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iWPR");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiWPR::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iWPR(smbl,PERIOD_M1,14);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<-80 && ind1_buffer[1]>-80)
      sig=1;
   else if(ind1_buffer[2]>-20 && ind1_buffer[1]<-20)
      sig=-1;

   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiWPR::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iWPR(smbl,PERIOD_M1,14);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);

   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<-80 && ind1_buffer[1]>-80)
      sig=1;
   else if(ind1_buffer[2]>-20 && ind1_buffer[1]<-20)
      sig=-1;

   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiBands:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iBands");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiBands::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double Close[];
   int   h_ind1=iBands(smbl,PERIOD_M1,20,0,2,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(CopyClose(Symbol(),Period(),0,3,Close)<2) return(0);
   if(!ArraySetAsSeries(Close,true)) return(0);
   if(Close[2]<=ind2_buffer[1] && Close[1]>ind2_buffer[1])
      sig=1;
   else if(Close[2]>=ind1_buffer[1] && Close[1]<ind1_buffer[1])
                     sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiBands::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double Close[];
   int   h_ind1=iBands(smbl,PERIOD_M1,20,0,2,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(CopyClose(Symbol(),Period(),0,3,Close)<2) return(0);
   if(!ArraySetAsSeries(Close,true)) return(0);
   if(Close[2]<=ind2_buffer[1] && Close[1]>ind2_buffer[1])
      sig=1;
   else if(Close[2]>=ind1_buffer[1] && Close[1]<ind1_buffer[1])
                     sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNRTR:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("NRTR");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CNRTR::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];

   int   h_ind1=iCustom(smbl,PERIOD_M1,"NRTR",40,2.0);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);

   if(ind1_buffer[1]>0) sig=1;
   else if(ind2_buffer[1]>0) sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CNRTR::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];

   int   h_ind1=iCustom(smbl,PERIOD_M1,"NRTR",40,2.0);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);

   if(ind1_buffer[1]>0) sig=1;
   else if(ind2_buffer[1]>0) sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiAlligator:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iAlligator");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiAlligator::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double ind3_buffer[];
   int   h_ind1=iAlligator(smbl,PERIOD_M1,13,0,8,0,5,0,MODE_SMMA,PRICE_MEDIAN);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,2,shift,3,ind3_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind3_buffer,true))         return(0);

   if(ind3_buffer[1]>ind2_buffer[1] && ind2_buffer[1]>ind1_buffer[1])
      sig=1;
   else if(ind3_buffer[1]<ind2_buffer[1] && ind2_buffer[1]<ind1_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiAlligator::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double ind3_buffer[];
   int   h_ind1=iAlligator(smbl,PERIOD_M1,13,0,8,0,5,0,MODE_SMMA,PRICE_MEDIAN);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,2,shift,3,ind3_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind3_buffer,true))         return(0);

   if(ind3_buffer[1]>ind2_buffer[1] && ind2_buffer[1]>ind1_buffer[1])
      sig=1;
   else if(ind3_buffer[1]<ind2_buffer[1] && ind2_buffer[1]<ind1_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiAMA:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iAMA");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiAMA::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iAMA(smbl,PERIOD_M1,9,2,30,0,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<ind1_buffer[1])
      sig=1;
   else if(ind1_buffer[2]>ind1_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiAMA::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iAMA(smbl,PERIOD_M1,9,2,30,0,PRICE_CLOSE);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[2]<ind1_buffer[1])
      sig=1;
   else if(ind1_buffer[2]>ind1_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiAO:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iAO");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiAO::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iAO(smbl,PERIOD_M1);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[1]==0)
      sig=1;
   else if(ind1_buffer[1]==1)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiAO::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   int   h_ind1=iAO(smbl,PERIOD_M1);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);

   if(ind1_buffer[1]==0)
      sig=1;
   else if(ind1_buffer[1]==1)
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiIchimoku:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iIchimoku");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiIchimoku::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   int   h_ind1=iIchimoku(smbl,PERIOD_M1,9,26,52);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind2_buffer,true)) return(0);

   if(ind1_buffer[1]>ind2_buffer[1])
      sig=1;
   else if(ind1_buffer[1]<ind2_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiIchimoku::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   int   h_ind1=iIchimoku(smbl,PERIOD_M1,9,26,52);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind1_buffer,true)) return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3) return(0);
   if(!ArraySetAsSeries(ind2_buffer,true)) return(0);

   if(ind1_buffer[1]>ind2_buffer[1])
      sig=1;
   else if(ind1_buffer[1]<ind2_buffer[1])
      sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiEnvelopes:public COracleTemplate
  {
   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("iEnvelopes");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiEnvelopes::forecast(string smbl,int shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double Close[];
   int   h_ind1=iEnvelopes(smbl,PERIOD_M1,28,0,MODE_SMA,PRICE_CLOSE,0.1);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(CopyClose(Symbol(),Period(),0,3,Close)<2) return(0);
   if(!ArraySetAsSeries(Close,true)) return(0);

   if(Close[2]<=ind2_buffer[1] && Close[1]>ind2_buffer[1])
      sig=1;
   else if(Close[2]>=ind1_buffer[1] && Close[1]<ind1_buffer[1])
                     sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiEnvelopes::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;
   if(""==smbl) smbl=Symbol();
   double ind1_buffer[];
   double ind2_buffer[];
   double Close[];
   int   h_ind1=iEnvelopes(smbl,PERIOD_M1,28,0,MODE_SMA,PRICE_CLOSE,0.1);
   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
   if(CopyClose(Symbol(),Period(),0,3,Close)<2) return(0);
   if(!ArraySetAsSeries(Close,true)) return(0);

   if(Close[2]<=ind2_buffer[1] && Close[1]>ind2_buffer[1])
      sig=1;
   else if(Close[2]>=ind1_buffer[1] && Close[1]<ind1_buffer[1])
                     sig=-1;
   else sig=0;
   IndicatorRelease(h_ind1);
//--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMA_Crossover_ADX:public COracleTemplate
  {
   //   virtual double    forecast(string smbl,int shift,bool train);
   virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("MA_Crossover_ADX");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMA_Crossover_ADX::forecast(string smbl,datetime shift,bool train)
  {

   double sig=0;

//   double ind1_buffer[];
//   double ind2_buffer[];
//   double Close[];
//   int   h_ind1=iEnvelopes(smbl,PERIOD_M1,28,0,MODE_SMA,PRICE_CLOSE,0.1);
//   if(CopyBuffer(h_ind1,0,shift,3,ind1_buffer)<3)         return(0);
//   if(CopyBuffer(h_ind1,1,shift,3,ind2_buffer)<3)         return(0);
//   if(!ArraySetAsSeries(ind1_buffer,true))         return(0);
//   if(!ArraySetAsSeries(ind2_buffer,true))         return(0);
//   if(CopyClose(Symbol(),Period(),0,3,Close)<2) return(0);
//   if(!ArraySetAsSeries(Close,true)) return(0);
//
////--- условие 1: скользящая средняя возрастает на текущем и предыдущем баре 
//   bool Buy_Condition_1=(StateEMA(0)>0 && StateEMA(1)>0);
////--- условие 2: цена закрытия завершенного бара выше скользящей средней 
//   bool Buy_Condition_2=(StateClose(1)>0);
////--- условие 3: значение ADX на текущем баре больше минимально заданного 
//   bool Buy_Condition_3=(MainADX(0)>m_minimum_ADX);
////--- условие 4: на текущем баре значение DI+ больше, чем DI-
//   bool Buy_Condition_4=(StateADX(0)>0);
////--- условие 1: скользящая средняя убывает на текущем и предыдущем баре 
//   bool Sell_Condition_1=(StateEMA(0)<0 && StateEMA(1)<0);
////--- условие 2: цена закрытия завершенного бара ниже скользящей средней 
//   bool Sell_Condition_2=(StateClose(1)<0);
////--- условие 3: значение ADX на текущем баре больше минимально заданного 
//   bool Sell_Condition_3=(MainADX(0)>m_minimum_ADX);
////--- условие 4: на текущем баре DI- больше, чем DI+
//   bool Sell_Condition_4=(StateADX(0)<0);
//
//
//   if((Buy_Condition_1 && Buy_Condition_2 && Buy_Condition_3 && Buy_Condition_4)
//      sig=1;
//   else if(Sell_Condition_1 && Sell_Condition_2 && Sell_Condition_3 && Sell_Condition_4)
//                     sig=-1;
//   else sig=0;
//   IndicatorRelease(h_ind1);
////--- возвращаем торговый сигнал
   return(sig);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AllOracles()
  {
   ArrayResize(AllOracles,20);
   int nAllOracles=0;
   AllOracles[nAllOracles++]=new CiStochastic;
   AllOracles[nAllOracles++]=new CiMACD;
   AllOracles[nAllOracles++]=new CiMA;
   AllOracles[nAllOracles++]=new CPriceChanel;
   AllOracles[nAllOracles++]=new CiRSI;
   AllOracles[nAllOracles++]=new CiCGI;
   AllOracles[nAllOracles++]=new CiWPR;
   AllOracles[nAllOracles++]=new CiBands;
   AllOracles[nAllOracles++]=new CiAlligator;
   AllOracles[nAllOracles++]=new CiAO;
   AllOracles[nAllOracles++]=new CiIchimoku;
   AllOracles[nAllOracles++]=new CiEnvelopes;
   for(int i=0;i<nAllOracles;i++) AllOracles[i].Init();
   return(nAllOracles);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COracleANN:public COracleTemplate
  {
private:
   string            Functions_Array[50];
   int               Functions_Count[50];
   //int               Max_Functions;
   string            File_Name;
   bool              WithNews;
   bool              WithHours;
   bool              WithDayOfWeek;

public:
   bool              ClearTraning;
   //   double            InputVector[];

                     COracleANN(){Init();}
                    ~COracleANN(){DeInit();}
   bool              GetVector(string smbl="",int shift=0,bool train=false);
   //  bool              debug;
   virtual void      Init();
   //   virtual void              DeInit();
   //   virtual double    forecast(string smbl="",int shift=0,bool train=false);
   bool              Load(string file_name);
   bool              Save(string file_name="");
   //   int               ExportFANNDataWithTest(int train_qty,int test_qty,string &SymbolsArray[],string FileName="");
   //   int               ExportFANNData(int qty,int shift,string &SymbolsArray[],string FileName,bool test=false);
   int               ExportDataWithTest(int train_qty,int test_qty,string &Symbols_Array[],string FileName="");
   int               ExportData(int qty,int shift,string &SymbolsArray[],string FileName,bool test=false);
   virtual bool      CustomLoad(int file_handle){return(false);};
   virtual bool      CustomSave(int file_handle){return(false);};
   virtual bool      Draw(int window,datetime &time[],int w,int h){return(true);};
   int               num_input();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COracleANN::ExportDataWithTest(int train_qty,int test_qty,string &Symbols_Array[],string FileName="")
  {
   if(""==FileName) FileName=File_Name;
   int shift=0;
// test
   shift=ExportData(test_qty,shift,Symbols_Array,FileName+"_test",true);
   shift=ExportData(train_qty,shift,Symbols_Array,FileName+"_train",false);
// чето ниже не работает :(
//   FileCopy(FileName+"_test.test",FILE_COMMON,FileName+"_test.dat",FILE_REWRITE);
//   FileCopy(FileName+"_train.train",FILE_COMMON,FileName+"_train.dat",FILE_REWRITE);
//\
   return(shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COracleANN::ExportData(int qty,int shift,string &Symbols_Array[],string FileName,bool test)
  {
   int i,ma;
   int FileHandle=0;
   int FileHandleFANN=0;
   int needcopy=0;
   int copied=0;

// временно!
   test=true;
//\

   string outstr,trainstrstr;
   FileHandle=FileOpen(FileName+".csv",FILE_WRITE|FILE_ANSI|FILE_CSV,' ');
   FileHandleFANN=FileOpen(FileName+".dat",FILE_WRITE|FILE_ANSI|FILE_TXT,' ');
   needcopy=qty;int Max_Symbols=0;
   for(ma=0;ma<ArraySize(Symbols_Array);ma++) if(StringLen(Symbols_Array[ma])!=0)Max_Symbols++;
//GNGAlgorithm.forecast(SymbolsArray[ma],i,true);
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(FileHandle!=INVALID_HANDLE && FileHandleFANN!=INVALID_HANDLE)
     {// записываем в файл шапку
      FileWrite(FileHandleFANN,Max_Symbols*needcopy*((test)?1:2),num_input(),1);
      //     FileWrite(FileHandle,Max_Symbols*needcopy*((test)?1:2),num_input(),1);
      for(ma=0;ma<Max_Symbols;ma++)
        {
         Comment("Export ..."+FileName+" "+(string)((int)(100*((double)(1+ma)/Max_Symbols)))+"%");
         for(i=0;i<needcopy;shift++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            if(GetVector(Symbols_Array[ma],shift,true))
              {
               //              CopyRates(_Symbol,_Period,shift+10,3,rates);
               i++;
               outstr="";
               //              outstr+=(string)rates[0].time+" ";
               for(int ibj=0;ibj<num_input();ibj++)
                 {
                  outstr=outstr+(string)(InputVector[ibj])+" ";
                 }
               FileWrite(FileHandleFANN,outstr);       // 
               trainstrstr="";
               for(int ibj=0;ibj<1;ibj++)
                 {
                  trainstrstr=trainstrstr+(string)(OutputVector[ibj])+" ";
                 }
               FileWrite(FileHandle,outstr+trainstrstr);       // 
               FileWrite(FileHandleFANN,trainstrstr);       // 
                                                            //if(test) continue;
               //// сделаем еще и симметричный дубль
               //outstr="";
               //for(int ibj=0;ibj<num_input();ibj++)
               //  {
               //   outstr=outstr+(string)(InputVector[ibj])+" ";
               //  }
               ////FileWrite(FileHandle,outstr);       // 
               ////outstr="";
               //for(int ibj=0;ibj<1;ibj++)
               //  {
               //   outstr=outstr+(string)(OutputVector[ibj])+" ";
               //  }
               //FileWrite(FileHandle,outstr);       // 

              }
           }
        }
     }
   FileClose(FileHandle);
   FileClose(FileHandleFANN);
   Print("Created file "+FileName);
   return(shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COracleANN::GetVector(string smbl="",int shift=0,bool train=false)
  {// пара, период, смещение назад (для индикатора полезно)
//   double IB[],OB[];
//   ArrayResize(IB,num_input()+2);
//   ArrayResize(OB,1+2);
//   ArrayResize(InputVector,num_input());
//   ArrayResize(OutputVector,3);
//   int FunctionsIdx;
////int n_vectors=num_input();
//   int n_o_vectors=1;
//   int pos_in=0,pos_out=0,i;
//   if(""==smbl) smbl=_Symbol;
//   if(WithHours || WithDayOfWeek)
//     {
//      MqlRates rates[];
//      ArraySetAsSeries(rates,true);
//      MqlDateTime tm;
//      CopyRates(smbl,PERIOD_M1,shift,3,rates);
//      TimeToStruct(rates[1].time,tm);
//      if(WithDayOfWeek) InputVector[pos_in++]=((double)tm.day_of_week/7);
//      if(WithDayOfWeek) InputVector[pos_in++]=((double)tm.hour/24);
//     }
//   if(!train)n_o_vectors=0;
//
////n_vectors=(n_vectors-pos_in);
//   for(FunctionsIdx=0; FunctionsIdx<10;FunctionsIdx++)
//     {
//      if(Get_Vectors(IB,OB,Functions_Count[FunctionsIdx],0,Functions_Array[FunctionsIdx],smbl,PERIOD_M1,shift))
//        {
//         // приведем к общему знаменателю
//         double si=1;
//         //            for(i=0;i<Functions_Count[FunctionsIdx];i++) si+=IB[i]*IB[i]; si=MathSqrt(si);
//         for(i=0;i<Functions_Count[FunctionsIdx];i++) InputVector[pos_in++]=IB[i]/si;
//
//         // for(i=0;i<n_o_vectors;i++)
//         //   {
//         //    OutputVector[i]=OB[i];
//         //    if(OB[i]<-3) OutputVector[i]=-0.5;
//         //    if(OB[i]>3) OutputVector[i]=0.5;
//         //    //OutputVector[i]=1*(1/(1+MathExp(-1*OB[i]/5))-0.5);
//         //   }
//        }
//     }
//   if(train && Get_Vectors(IB,OB,0,n_o_vectors,"",smbl,PERIOD_M1,shift))
//     {
//      for(i=0;i<n_o_vectors;i++)
//        {
//         OutputVector[i]=OB[i];
//         //if(OB[i]<-3) OutputVector[i]=-0.5;
//         //if(OB[i]>3) OutputVector[i]=0.5;
//         //OutputVector[i]=1*(1/(1+MathExp(-1*OB[i]/5))-0.5);
//        }
//
//     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COracleANN::num_input(void)
  {
   int ret=0;
   for(int i=0;i<20;i++) ret+=Functions_Count[i];
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COracleANN::Save(string file_name)
  {
   if(""==file_name) file_name=File_Name;
   int file_handle;  string outstr="";

   file_handle=FileOpen(file_name+".gc_oracle",FILE_WRITE|FILE_ANSI|FILE_TXT,"= ");
// сделаем шаблончик
   if(file_handle!=INVALID_HANDLE)
     {
      FileWriteString(file_handle,"[Common]\n");
      FileWriteString(file_handle,"LastStart="+(string)TimeCurrent()+"\n");

      FileWriteString(file_handle,"[FunctionsArray]\n");
      int i;
      i=0;
      while(i<ArraySize(Functions_Array) && Functions_Array[i]!="" && Functions_Array[i]!=NULL)
        {
         FileWriteString(file_handle,Functions_Array[i]+"="+(string)Functions_Count[i]+"\n");
         i++;
        }
      FileWriteString(file_handle,"[Custom]\n");
      CustomSave(file_handle);
      FileClose(file_handle);
      return(true);
     }
   else return(false);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COracleANN::Load(string file_name)
  {
   int file_handle;  string outstr="";   int i=0,sp;
   File_Name=file_name;
   file_handle=FileOpen(file_name+".gc_oracle",FILE_READ|FILE_ANSI|FILE_TXT,"= ");
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(file_handle!=INVALID_HANDLE)
     {
      outstr=FileReadString(file_handle);//   [Common]
      outstr=FileReadString(file_handle);//   LastStart
      while(outstr!="[FunctionsArray]"){outstr=FileReadString(file_handle);}
      outstr=FileReadString(file_handle);
      while(outstr!="[Custom]" && outstr!="")
        {
         sp=1+StringFind(outstr,"=");
         for(i=0;i<50;i++)
            //+------------------------------------------------------------------+
            //|                                                                  |
            //+------------------------------------------------------------------+
           {
            if(Functions_Array[i]==StringSubstr(outstr,0,sp-1)) Functions_Count[i]=(int)StringToInteger(StringSubstr(outstr,sp));;
           }
         outstr=FileReadString(file_handle);
        }
      if(outstr=="[Custom]") CustomLoad(file_handle);
      FileClose(file_handle);
      return(true);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Print("Файл не найден в папке "+TerminalInfoString(TERMINAL_DATA_PATH));
      return(false);
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COracleANN::Init()
  {
   ClearTraning=false;
   debug=false;
   WithNews = false;
   WithHours= false;
   WithDayOfWeek=false;
   int i;
   for(i=0;i<ArraySize(VectorFunctions) && VectorFunctions[i]!=NULL && VectorFunctions[i]!="";i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      Functions_Array[i]=VectorFunctions[i];
      Functions_Count[i]=0;
     }
   TimeFrame=_Period;
  }
//+------------------------------------------------------------------+
