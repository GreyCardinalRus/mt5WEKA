//+------------------------------------------------------------------+
//|                                                        GCANN.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
input int inp_MACD1=300,inp_MACD2=30,inp_MACD3=120,int_MATrendPeriod=280; //
#include <GC\Oracle.mqh>
//#include <GC\OracleDummy_fc.mqh>
#include <GC\CurrPairs.mqh> // пары
//#include <GC\Watcher.mqh>
//CWatcher          Watcher;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CiMACD *MyExpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   MyExpert=new CiMACD();
   if(MQLInfoInteger(MQL_OPTIMIZATION)) MyExpert.Init("",inp_MACD1,inp_MACD2,inp_MACD3,int_MATrendPeriod);
   else if(_Symbol=="EURUSD")    MyExpert.Init("",300,30,120,280);
   else if(_Symbol=="GPBUSD")    MyExpert.Init("",240,160,150,290);
//   if(_NEDATA_>_ShiftNEDATA_)
//     {
//      MyExpert.ExportHistoryENCOG(_Symbol,"",0,_NEDATA_,_ShiftNEDATA_,0,0);
//
//      Print("Indicator data exported.");
//     }

   CPInit();
   if(_TrailingPosition_) Trailing();
   return(0); 
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExportHistory("res_oracle.csv");
   DelTrash();
   delete MyExpert;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//   static double lastf=0;
   int SymbolIdx;
   double f;
//Watcher.Run();//
   if(_TrailingPosition_) Trailing();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(isNewBar())
     {
      datetime Time[]; ArraySetAsSeries(Time,true);

      for(SymbolIdx=0; SymbolIdx<MaxSymbols;SymbolIdx++)
        {
         CopyTime(SymbolsArray[SymbolIdx],0,0,3,Time);
         f=MyExpert.forecast(SymbolsArray[SymbolIdx],0,false);
 //        MqlDateTime tm;

 //        TimeToStruct(Time[0],tm);
         //if(__Debug__) Print("Oracle Encog say: "+DoubleToString(f,3));
 //        NewOrder(SymbolsArray[SymbolIdx],f,DoubleToString(f,3)+" "+(string)tm.hour+":"+(string)tm.min+":"+(string)tm.sec);
         NewOrder(SymbolsArray[SymbolIdx],f,DoubleToString(f,3));
        }

     }
  }
//+------------------------------------------------------------------+
