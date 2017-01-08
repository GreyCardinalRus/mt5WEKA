//+------------------------------------------------------------------+
//|                                                      MT5FANN.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property copyright "Mariusz Woloszyn"
#property link      ""
#include <GC\IniFile.mqh>
#include <GC\Fann2MQL5.mqh>
#include <GC\GetVectors.mqh>
//#include <GC\CurrPairs.mqh>
//train_RPROP
//hiden ELIOT_SYM
//out SIGMOID_SYM_STEPWISE!

//+------------------------------------------------------------------+
//|     CMT5FANN                                                     |
//+------------------------------------------------------------------+
class CMT5FANN
  {
private:
   string            Symbols_Array[30];
   int               Max_Symbols;
   string            Functions_Array[10];
   int               Functions_Count[10];
   int               Max_Functions;
   ENUM_TIMEFRAMES   TimeFrame;
   bool              WithNews;
   bool              WithHours;
   bool              WithDayOfWeek;
   int               FileHandle;
   int               num_in_vectors;
   int               num_out_vectors;
   string            File_Name;
   string            ffn_name;
   CIniFile          MyIniFile;                   // Создаем экземпляр класса
   CArrayString      Strings;                     // Необходим для работы с массивами данных
   int               ann;
   double            forecast;
public:
                     CMT5FANN(){Init();}
                    ~CMT5FANN(){DeInit();}
   double            forecast(int shift=0,bool train=false);
   double            InputVector[];
   double            OutputVector[];
   int               ann_create();
   int               ann_load(string path="");
   bool              ann_save(string path="");
   bool              ini_load(string path="");
   bool              ini_save(string path="");
   int               get_num_input(){return(num_in_vectors);};
   int               get_num_output(){return(num_out_vectors);};
   int               train(){return(f2M5_train(ann,InputVector,OutputVector));}
   int               run(){return((-1==ann)?-1:f2M5_run(ann,InputVector));}
   int               test(){return(f2M5_test(ann,InputVector,OutputVector));}
   int               reset_MSE(){return(f2M5_reset_MSE(ann));}
   double            get_MSE(){return(f2M5_get_MSE(ann));}
   bool              get_output();
   bool              debug;
   void              Init();
   bool              Init(string FileName,string smbl="");
   int               train_on_file(string path="",int max_epoch=5000,float desired_error=(float)0.001,bool resetprev=false);
   int               test_on_file(string path="");
   //   bool              Init(string FileName,string &SymbolsArray[],int MaxSymbols,int num_invectors,int num_outvectors,int new_num_layers);
   void              DeInit();
   bool              GetVector(int shift=0,bool train=false);
   int               ExportFANNDataWithTest(int train_qty,int test_qty,string FileName="");
   int               ExportFANNData(int qty,int shift,string FileName,bool test=false);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMT5FANN::ExportFANNDataWithTest(int train_qty,int test_qty,string FileName="")
  {
   if(""==FileName) FileName=File_Name;
   int shift=0;
// test
   shift=ExportFANNData(test_qty,shift,FileName+"_test.test",true);
   shift=ExportFANNData(train_qty,shift,FileName+"_train.train",false);
// чето ниже не работает :(
   FileCopy(FileName+"_test.test",FILE_COMMON,FileName+"_test.dat",FILE_REWRITE);
   FileCopy(FileName+"_train.train",FILE_COMMON,FileName+"_train.dat",FILE_REWRITE);
//\
   return(shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMT5FANN::ExportFANNData(int qty,int shift,string FileName,bool test)
  {
   int i;
   int FileHandle=0,FileStat=0;
   int needcopy=0;
   int copied=0;
   int QS=0,QWS=0,QW=0,QWB=0,QB=0;

   string outstr;
   FileHandle=FileOpen(FileName,FILE_WRITE|FILE_ANSI|FILE_TXT,' ');
   needcopy=qty;
   if (!test)
   {
   //FileStat = FileOpen("stat.csv",FILE_WRITE|FILE_ANSI|FILE_CSV,';');
   //   if(FileStat!=INVALID_HANDLE)
   //  {// записываем в файл шапку
   //    FileWrite(FileStat,// записываем в файл шапку
   //             "Signal","tanh");
   }
   if(FileHandle!=INVALID_HANDLE)
     {// записываем в файл шапку
      FileWrite(FileHandle,needcopy*((test)?1:1),num_in_vectors,num_out_vectors);
      for(i=0;i<needcopy;shift++)
        {
         if(GetVector(shift,true))
           {
            i++;
            
            outstr="";
            for(int ibj=0;ibj<num_in_vectors;ibj++)
              {
               outstr=outstr+(string)(InputVector[ibj])+" ";
   if (!test)
   {
   //FileStat = FileOpen("stat.csv",FILE_WRITE|FILE_ANSI|FILE_CSV,';');
   //   if(FileStat!=INVALID_HANDLE)
   //  {// записываем в файл шапку
   //    FileWrite(FileStat,// записываем в файл шапку
   //             "Signal","tanh");
   }
              }

            FileWrite(FileHandle,outstr);       // 
            outstr="";
            for(int ibj=0;ibj<num_out_vectors;ibj++)
              {
               outstr=outstr+(string)(OutputVector[ibj])+" ";
              }
            FileWrite(FileHandle,outstr);       // 
            //if(test) continue;
            //// сделаем еще и симметричный дубль
            //outstr="";
            //for(int ibj=0;ibj<num_in_vectors;ibj++)
            //  {
            //   outstr=outstr+(string)(InputVector[ibj])+" ";
            //  }
            //FileWrite(FileHandle,outstr);       // 
            //outstr="";
            //for(int ibj=0;ibj<num_out_vectors;ibj++)
            //  {
            //   outstr=outstr+(string)(OutputVector[ibj])+" ";
            //  }
            //FileWrite(FileHandle,outstr);       // 

           }
          else Print("Trouble...");
        }
     }
   FileClose(FileHandle);
   Print("Created file "+FileName);
   return(shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMT5FANN::get_output()
  {
   if(-1==ann) return(false);
   for(int i=0;i<num_out_vectors;i++)
      OutputVector[i]=f2M5_get_output(ann,i);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CMT5FANN::ini_save(string path="")
  {
   if(path=="") path=File_Name;
   path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+path+".ini";
   MyIniFile.Init(path);// Пишем 
   bool     resb;
   if(Max_Symbols==1);//&& Symbols_Array[0]==_Symbol);
   else
   for(int SymbolIdx=0; SymbolIdx<Max_Symbols;SymbolIdx++)
     {
      resb=MyIniFile.Write("SymbolsArray",Symbols_Array[SymbolIdx],"True");
      if(!resb)
        {
         //         if(debug) Print("Ok write string");
        }
      else
        {
         //       if(debug) Print("Error on write string");//return(false);
        }
     }
   for(int FunctionsIdx=0; FunctionsIdx<Max_Functions;FunctionsIdx++)
     {
      resb=MyIniFile.Write("FunctionsArray",Functions_Array[FunctionsIdx],Functions_Count[FunctionsIdx]);
      if(!resb)
        {
         //if(debug) Print("Ok write string");
        }
      else
        {
         //         if(debug) Print("Error on write string ",Functions_Array[FunctionsIdx]);//return(false);
        }
     }
   resb=MyIniFile.Write("Settings","TimeFrame",(int)TimeFrame);
   resb=MyIniFile.WriteBool("Settings","WithNews",WithNews);
   resb=MyIniFile.WriteBool("Settings","WithHours",WithHours);
   resb=MyIniFile.WriteBool("Settings","WithDayOfWeek",WithDayOfWeek);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMT5FANN::ini_load(string path="")
  {
   if(path=="") path=File_Name;
   path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+path+".ini";
   MyIniFile.Init(path);
// Проверяем, если секция существует, читаем ее KeyNames
   if(MyIniFile.SectionExists("SymbolsArray"))
     {
      MyIniFile.ReadSection("SymbolsArray",Strings);
      Max_Symbols=Strings.Total();
      for(int i=0; i<Strings.Total(); i++)
        {
         Symbols_Array[i]=Strings.At(i);//if(debug) Print(Strings.At(i));
        }
     }
   else
     {
      Max_Symbols=1;Symbols_Array[0]=_Symbol;
     }
   if(MyIniFile.SectionExists("FunctionsArray"))
     {
      MyIniFile.ReadSection("FunctionsArray",Strings);
      Max_Functions=Strings.Total();
      for(int i=0; i<Strings.Total(); i++)
        {
         Functions_Array[i]=Strings.At(i);
         Functions_Count[i]=(int)MyIniFile.ReadInteger("FunctionsArray",Functions_Array[i],1);
        }
     }
   else
     {
      Max_Functions=1;Functions_Array[0]=VectorFunctions[0];
     }
   TimeFrame=(ENUM_TIMEFRAMES)MyIniFile.ReadInteger("Settings","TimeFrame",_Period);
   WithNews=false;//MyIniFile.ReadBool("Settings","WithNews",false);
   WithHours=MyIniFile.ReadBool("Settings","WithHours",false);
   WithDayOfWeek=MyIniFile.ReadBool("Settings","WithDayOfWeek",false);
   //if(TimeFrame!= _Period) Print("TimeFrame not equals! Need ",TimeFrame);
   if(-1==(ann=ann_load()))
     {
      //File_Name="";
      return(false);
     }
// Print(ann);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMT5FANN::ann_save(string path="")
  {
   if(path=="") path=File_Name;
   path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+path+".net";
   if(f2M5_save(ann,path)<0)
     {
      if(debug)Print("ne shmogla ",path);
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMT5FANN::ann_create()
  {
/* Создание нейросети */
   ann=f2M5_create_standard(4,num_in_vectors,num_in_vectors,num_in_vectors/2+num_out_vectors,num_out_vectors);
   f2M5_set_act_function_hidden(ann,FANN_ELLIOT_SYMMETRIC);
   f2M5_set_act_function_output(ann,FANN_SIGMOID_SYMMETRIC_STEPWISE);
   f2M5_randomize_weights(ann,-0.99,0.99);
   return(ann);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CMT5FANN::ann_load(string path="")
  {
   if(path=="") path=File_Name;
   path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+path+".net";
   ann=f2M5_create_from_file(path);
   return(ann);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  CMT5FANN::train_on_file(string path,int max_epoch,float desired_error,bool resetprev)
  {
//char p[];
   if(path=="") path=File_Name+".train";
//path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+path;
//StringToCharArray(path,p);
//return(f2M_train_on_file(ann,p,max_epoch,desired_error));
   string tmpstr;
   int cnt=0;
   int i,j,epoch;
   int FileHandle=FileOpen(path,FILE_READ|FILE_ANSI|FILE_CSV,' ');
   if(FileHandle!=INVALID_HANDLE)
     {
      if(resetprev) f2M5_randomize_weights(ann,-1.0,1.0);
      for(epoch=0;epoch<max_epoch;epoch++)
        {
         FileSeek(FileHandle,0,SEEK_SET);
         cnt=(int)StringToInteger(FileReadString(FileHandle));
         if(StringToInteger(FileReadString(FileHandle))!=num_in_vectors)
           {
            Print("Size vectors not equals!");
            return(-1);
           }
         if(StringToInteger(FileReadString(FileHandle))!=num_out_vectors)
           {
            Print("Size vectors not equals!");
            return(-1);
           }
         for(i=0;i<cnt;i++)
           {
            ArrayInitialize(InputVector,EMPTY_VALUE);
            ArrayInitialize(OutputVector,EMPTY_VALUE);
            // input vectors
            for(j=0;j<num_in_vectors;j++)
              {
               InputVector[j]=StringToDouble(FileReadString(FileHandle));
              }
            FileReadString(FileHandle);// CR
                                       // output vectors
            for(j=0;j<num_out_vectors;j++)
              {
               OutputVector[j]=StringToDouble(FileReadString(FileHandle));
              }
            //Print(InputVector[0]," ",OutputVector[0]);
            train();FileReadString(FileHandle);// CR
           }
         //if(debug) Print("Epoch=",epoch," MSE=",get_MSE());
        }
      if(debug) Print(" MSE=",get_MSE());
     }
   return(cnt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  CMT5FANN::test_on_file(string path)
  {
//char p[];
   if(path=="") path=File_Name+".test";
//path=TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+path;
//StringToCharArray(path,p);
//return(f2M_train_on_file(ann,p,max_epoch,desired_error));
   string tmpstr;
   int cnt=0;
   int i,j;
   double need_output;
   int FileHandle=FileOpen(path,FILE_READ|FILE_ANSI|FILE_CSV,' ');
   if(FileHandle!=INVALID_HANDLE)
     {
      FileSeek(FileHandle,0,SEEK_SET);
      cnt=(int)StringToInteger(FileReadString(FileHandle));
      if(StringToInteger(FileReadString(FileHandle))!=num_in_vectors)
        {
         Print("Size vectors not equals!");
         return(-1);
        }
      if(StringToInteger(FileReadString(FileHandle))!=num_out_vectors)
        {
         Print("Size vectors not equals!");
         return(-1);
        }
      //tmpstr=FileReadString(FileHandle);// CR
      for(i=0;i<cnt;i++)
        {
         ArrayInitialize(InputVector,EMPTY_VALUE);
         ArrayInitialize(OutputVector,EMPTY_VALUE);
         // input vectors
         for(j=0;j<num_in_vectors;j++)
           {
            InputVector[j]=StringToDouble(FileReadString(FileHandle));
           }
         tmpstr=FileReadString(FileHandle);// CR
                                           // output vectors
         for(j=0;j<num_out_vectors;j++)
           {
            OutputVector[j]=StringToDouble(FileReadString(FileHandle));
           }
         tmpstr=FileReadString(FileHandle);// CR
                                           //        Print("in=",InputVector[0]," out=",OutputVector[0]);
         need_output=OutputVector[0];
         run();
         if(get_output()) Print(" out=",OutputVector[0]," need=",need_output);
        }
      //if(debug) Print("Epoch=",epoch," MSE=",get_MSE());

     }
   return(cnt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMT5FANN::Init()
  {
   debug=false;
   num_in_vectors=-1;
   num_out_vectors=-1;
   TimeFrame= _Period;
   WithNews = false;
   WithHours= false;
   WithDayOfWeek=false;
// Initialize Intel TBB threads
//  f2M_parallel_init();

//  ann=CreateAnn();
// Print("ann=",ann);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMT5FANN::DeInit()
  {
   if(-1!=ann)
     {
      ann_save();
      ini_save();
     }
   f2M5_destroy(ann);
//  f2M_parallel_deinit();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CMT5FANN::Init(string FileName,string smbl)
  {
   File_Name=FileName;
   ini_load();
   if(""!=smbl) {Max_Symbols=1;Symbols_Array[0]=smbl;}

   if(-1==(ann=ann_load()))
     {
      //File_Name="";
      return(false);
     }
   num_in_vectors=f2M5_get_num_input(ann);
   num_out_vectors=f2M5_get_num_output(ann);
   ArrayResize(InputVector,get_num_input());
   ArrayResize(OutputVector,get_num_output());
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CMT5FANN::GetVector(int shift,bool train)
  {// пара, период, смещение назад (для индикатора полезно)
   double IB[],OB[];
   ArrayResize(IB,num_in_vectors+2);
   ArrayResize(OB,num_out_vectors+2);
   int SymbolIdx,FunctionsIdx;
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   MqlDateTime tm;
   CopyRates(Symbols_Array[0],TimeFrame,shift,3,rates);
   TimeToStruct(rates[1].time,tm);
   int n_vectors=num_in_vectors;
   int n_o_vectors=num_out_vectors;
   int pos_in=0,pos_out=0,i;
   if(WithDayOfWeek) InputVector[pos_in++]=((double)tm.day_of_week/7);
   if(WithHours) InputVector[pos_in++]=((double)tm.hour/24);
   n_vectors=(n_vectors-pos_in)/Max_Symbols;
   n_o_vectors=(n_o_vectors)/Max_Symbols;
   if(!train)n_o_vectors=0;
//   if(train) n_o_vectors=1;
   for(SymbolIdx=0; SymbolIdx<Max_Symbols;SymbolIdx++)
     {
      for(FunctionsIdx=0; FunctionsIdx<Max_Functions;FunctionsIdx++)
        {
         if(GetVectors(IB,OB,n_vectors,n_o_vectors,Functions_Array[FunctionsIdx],Symbols_Array[SymbolIdx],TimeFrame,shift))
           {
            // приведем к общему знаменателю
            //double si=0;
            //for(i=0;i<n_vectors;i++) si+=IB[i]*IB[i]; si=MathSqrt(si);
            for(i=0;i<n_vectors;i++) InputVector[pos_in++]=IB[i];
            for(i=0;i<n_o_vectors;i++) 
            {
             OutputVector[i]=0;
             //if(OB[i]<-3) OutputVector[i]=-0.5;
             //if(OB[i]>3) OutputVector[i]=0.5;
             //OutputVector[i]=1*(1/(1+MathExp(-1*OB[i]/5))-0.5);
//             OutputVector[i]=tanh(OB[i]);
             OutputVector[i]=OB[i];
             
             }
            
           }
         else return(false);
        }
     }

//GetVectors(mt5fann.InputVector,mt5fann.OutputVector,5,1,"Fractals")
   return(true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  CMT5FANN::forecast(int shift,bool train)
  {
   if(GetVector(shift,train))
     {
      run();
      get_output();
      forecast=OutputVector[0];
      return(forecast-0.5);
     }
   else return(0);
  }
