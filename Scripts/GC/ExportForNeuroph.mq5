//+------------------------------------------------------------------+
//|                                             ExportForNeuroph.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
input int _Pers_=12;//ѕериод анализа
input int _Shift_=5;//на сколько периодов вперед прогноз
#include <GC\GetVectors.mqh>
#include <GC\CurrPairs.mqh> // пары
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
 CPInit();                                                     //WriteFile( 1,5,2010); // день, мес€ц, год 
   Write_File(5000,20,_Pers_); //
   Print("Files created...");
   return;// работа скрипта завершена
  }
//+------------------------------------------------------------------+
int Write_File(int train_qty,int test_qty,int Pers)
  {
   int shift=0;
   shift=Write_File_fann_data("Forex_test.csv",test_qty,Pers,shift);
   shift=Write_File_fann_data("Forex_train.csv",train_qty,Pers,shift);
   return(shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Write_File_fann_data(string FileName,int qty,int Pers,int shift)
  {
   int i;
   double IB[],OB[];
   ArrayResize(IB,Pers+2);
   ArrayResize(OB,Pers+2);
   int FileHandle=0;
   int needcopy=0;
   int copied=0;
   MqlRates rates[];
   //MqlDateTime tm;
   ArraySetAsSeries(rates,true);
   string outstr;
   int SymbolIdx;
   FileHandle=FileOpen(FileName,FILE_WRITE|FILE_ANSI|FILE_TXT,' ');
   needcopy=qty;   

   if(FileHandle!=INVALID_HANDLE)
     {
 //     FileWrite(FileHandle,// записываем в файл шапку
 //               needcopy,// 
 ////               2+(1+Pers)*MaxSymbols,
 //               Pers*MaxSymbols,
 //               MaxSymbols);
      for(SymbolIdx=0; SymbolIdx<MaxSymbols;SymbolIdx++)
        {
         int bars=Bars(SymbolsArray[SymbolIdx],_Period);
         //Print("Ѕаров в истории = ",bars);
         for(i=0;i<needcopy&&shift<bars;shift++)
            if(GetVectors(IB,OB,Pers,1,"Easy",SymbolsArray[SymbolIdx],PERIOD_M1,shift))
            //if(GetVectors(IB,OB,3,1,"Easy",SymbolsArray[SymbolIdx],PERIOD_M1,i))
              {
               i++;
               //copied=CopyRates(SymbolsArray[SymbolIdx],_Period,shift,3,rates);
               //TimeToStruct(rates[2].time,tm);
               //               outstr=""+(string)tm.mon+" "+(string)tm.day+" "+(string)tm.day_of_week+" "+(string)tm.hour+" "+(string)tm.min;
               outstr="";//(string)tm.day_of_week+" "+(string)tm.hour;

               for(int ibj=0;ibj<Pers;ibj++)
                 {
                  outstr=outstr+(string)(IB[ibj])+" ";
                 }
               outstr=outstr+(string)OB[0];
               FileWrite(FileHandle,outstr);       // 
               //FileWrite(FileHandle,OB[0]); // 
              }
        }
     }
   FileClose(FileHandle);

   return(shift);
  }