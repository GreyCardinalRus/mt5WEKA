//+------------------------------------------------------------------+
//|                                               DivideZeroTest.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

double tanh(double x)
  {
   double x_=MathExp(x);
   double _x=MathExp(-x);
   Print((string)x+" "+(string)x_+" "+(string)_x);
   double ret=(x_-_x)/(x_+_x);Print("ret="+(string)ret);
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   double result=0;
   int FileHandle=FileOpen("Dummy.tst",FILE_WRITE|FILE_ANSI,' ');
   if(FileHandle!=INVALID_HANDLE)
     {
      for(double res=-9;res<10;res++)
        {
         result=tanh(res/5);
         Print((string)result);
         Print((string)res+" "+(string)result);
         FileWrite(FileHandle," //"+(string)res+"="+(string)result);
        }
      FileClose(FileHandle);
     }
   // вариант вызова ниже - "падает"
   FileHandle=FileOpen("Dummy2.tst",FILE_WRITE|FILE_ANSI,' ');
   if(FileHandle!=INVALID_HANDLE)
     {
      for(double res=-9;res<10;res++)
        {
         //result=tanh(res/5);
         Print((string)tanh(res/5));
         Print((string)res+" "+(string)tanh(res/5));
         FileWrite(FileHandle," //"+(string)res+"="+(string)tanh(res/5));
        }
      FileClose(FileHandle);
     }
    
  }
//+------------------------------------------------------------------+
