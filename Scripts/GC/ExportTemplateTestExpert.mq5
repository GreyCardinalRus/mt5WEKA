//+------------------------------------------------------------------+
//|                                     ExportTemplateTestExpert.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

//+------------------------------------------------------------------+
#include <GC\GetVectors.mqh>
#include <GC\CurrPairs.mqh> // пары
input int _CNT_=50000;//Сколько сигналов
input int _SHIFT_=100;//Сколько сдвиг
input int _TREND_=120;// на сколько смотреть вперед
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   CPInit();
   Write_File(_CNT_); //
                      //   Write_File(SymbolsArray,MaxSymbols,100,_Pers_); //
   Print("Files created...");
   return;// работа скрипта завершена
  }
//+------------------------------------------------------------------+
int Write_File(int qty)
  {
   int i;
   double res=0;
//string outstr;
   MqlRates rates[];
   MqlDateTime tm;
//double IV[50],OV[10];
   ArraySetAsSeries(rates,true);
   TimeToStruct(TimeCurrent(),tm);
   int cm=tm.mon;
   int FileHandle=FileOpen("OracleDummy_fc.mqh",FILE_WRITE|FILE_ANSI,' ');
   if(FileHandle!=INVALID_HANDLE)
     {
      int copied=CopyRates(_Symbol,PERIOD_M1,15+_SHIFT_-1,qty+1,rates);
      FileWrite(FileHandle,"double od_forecast(datetime time,string smb)  ");
      FileWrite(FileHandle," {");
      int SymbolIdx=0;
      //FileWrite(FileHandle,"if(smb!=\""+SymbolsArray[SymbolIdx]+"\") return(0);");
      //for(SymbolIdx=0; SymbolIdx<MaxSymbols;SymbolIdx++)
        {
         for(i=0; i<qty;i++)
           {
            TimeToStruct(rates[i].time,tm);
            if(tm.mon!=cm) break;
            res=GetTrend(_TREND_,SymbolsArray[SymbolIdx],PERIOD_M1,i+_SHIFT_,false);
            if(res!=0)
              {
               //   restanh=OV[0];
               res=tanh(res);
               //if(res<4 && res>-4) continue;
               //if(res>4) res=0.7;
               //else if(res>1) res=0.35;
               //else if(res>0.1) res=0;
               //else if(res>-0.1) res=0;
               //else if(res>-1) res=0;
               //else if(res>-4) res=-.35;
               //else res=-0.7;
               //               Print(tanh(res/5));
               // FileWrite(FileHandle," //" +(string)res+"="+restanh);
               FileWrite(FileHandle,"  if(smb==\""+SymbolsArray[SymbolIdx]+"\" && time==StringToTime(\""+(string)rates[i].time+"\")) return("+(string)res+");");
              }
           }
        }
      FileWrite(FileHandle,"  return(0);");
      FileWrite(FileHandle," }");
     }
   FileClose(FileHandle);
   return(0);
  }
//+------------------------------------------------------------------+
