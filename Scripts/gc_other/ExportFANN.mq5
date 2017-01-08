//+------------------------------------------------------------------+
//|                                                ExportHistory.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                           History_in_MathCAD.mq5 |
//|                                                    Привалов С.В. |
//|                           https://login.mql5.com/ru/users/Prival |
//+------------------------------------------------------------------+
#property copyright "Привалов С.В."
#property link      "https://login.mql5.com/ru/users/Prival"
#property version   "1.08"
//#include <Fractals.mqh>
#include <GC\GetVectors.mqh>
#include <GC\CurrPairs.mqh> // пары
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

input int _Pers_=5;//Период анализа
input int _Shift_=5;//на сколько периодов вперед прогноз
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
CPInit();                                                     //WriteFile( 1,5,2010); // день, месяц, год 
   Write_File(10000,50,_Pers_); //
   Print("Files created...");
   return;// работа скрипта завершена
  }
//+------------------------------------------------------------------+
int Write_File(int train_qty,int test_qty,int Pers)
  {
   int shift=0;
// test
   shift=Write_File_fann_data("Forex_test.test",test_qty,Pers,shift);
   shift=Write_File_fann_data("Forex_train.train",train_qty,Pers,shift);
// чето ниже не работает :(
   FileCopy("Forex_test.test",FILE_COMMON,"Forex_test.dat",FILE_REWRITE);
   FileCopy("Forex_train.train",FILE_COMMON,"Forex_train.dat",FILE_REWRITE);
//\
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
   MqlDateTime tm;
   ArraySetAsSeries(rates,true);
   string outstr;
   int SymbolIdx;
   FileHandle=FileOpen(FileName,FILE_WRITE|FILE_ANSI|FILE_TXT,' ');
   needcopy=qty;   

   if(FileHandle!=INVALID_HANDLE)
     {
      FileWrite(FileHandle,// записываем в файл шапку
                needcopy,// 
 //               2+(1+Pers)*MaxSymbols,
                2+Pers*MaxSymbols,
                MaxSymbols);
      for(SymbolIdx=0; SymbolIdx<MaxSymbols;SymbolIdx++)
        {
         int bars=Bars(SymbolsArray[SymbolIdx],_Period);
         //Print("Баров в истории = ",bars);
         for(i=0;i<needcopy&&shift<bars;shift++)
            if(GetVectors(IB,OB,Pers,1,"Fractals",SymbolsArray[SymbolIdx],_Period,shift))
              {
               i++;
               copied=CopyRates(SymbolsArray[SymbolIdx],_Period,shift,3,rates);
               TimeToStruct(rates[2].time,tm);
               //               outstr=""+(string)tm.mon+" "+(string)tm.day+" "+(string)tm.day_of_week+" "+(string)tm.hour+" "+(string)tm.min;
               outstr=""+(string)((double)tm.day_of_week/7)+" "+(string)((double)tm.hour/24);
               //// news
               //for(int ibj=0;ibj<MaxSymbols;ibj++)
               //  {
               //   outstr=outstr+" 0";
               //  }
               //// data
               for(int ibj=0;ibj<Pers;ibj++)
                 {
                  outstr=outstr+" "+(string)(IB[ibj]);
                 }

               FileWrite(FileHandle,outstr);       // 
               FileWrite(FileHandle,OB[0]); // 
              }
        }
     }
   FileClose(FileHandle);

   return(shift);
  }
string fTimeFrameName(int arg)
  {
   int v;
   if(arg==0)
     {
      v=_Period;
     }
   else
     {
      v=arg;
     }
   switch(v)
     {
      case PERIOD_M1:    return("M1");
      case PERIOD_M2:    return("M2");
      case PERIOD_M3:    return("M3");
      case PERIOD_M4:    return("M4");
      case PERIOD_M5:    return("M5");
      case PERIOD_M6:    return("M6");
      case PERIOD_M10:   return("M10");
      case PERIOD_M12:   return("M12");
      case PERIOD_M15:   return("M15");
      case PERIOD_M20:   return("M20");
      case PERIOD_M30:   return("M30");
      case PERIOD_H1:    return("H1");
      case PERIOD_H2:    return("H2");
      case PERIOD_H3:    return("H3");
      case PERIOD_H4:    return("H4");
      case PERIOD_H6:    return("H6");
      case PERIOD_H8:    return("H8");
      case PERIOD_H12:   return("H12");
      case PERIOD_D1:    return("D1");
      case PERIOD_W1:    return("W1");
      case PERIOD_MN1:   return("MN1");
      default:    return("?");
     }
  } // end fTimeFrameName


//+------------------------------------------------------------------+
//| Заполняем вектор ! вначале -выходы -потом вход                   |
//| просто разница                                                   |
//+------------------------------------------------------------------+





