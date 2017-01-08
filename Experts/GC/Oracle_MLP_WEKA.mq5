//+------------------------------------------------------------------+
//|                                                        GCANN.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <GC\Oracle.mqh>
//#include <GC\OracleDummy_fc.mqh>
#include <GC\CurrPairs.mqh> // пары
//#include <GC\Watcher.mqh>
//CWatcher          Watcher;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

COracleMLP_WEKA *MyExpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   MyExpert=new COracleMLP_WEKA();  
    if(!MyExpert.IsInit) return(INIT_FAILED);
         string comment="";
         MyExpert.forecast(_Symbol,0,0,false,comment);


   CPInit();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExportHistory("res_oracle.csv");
   delete MyExpert;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//   static double lastf=0;
  // int SymbolIdx;
   double f;
//Watcher.Run();//
   if(_TrailingPosition_) Trailing();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(isNewBar())
     {
 //     datetime Time[]; ArraySetAsSeries(Time,true);

//      for(SymbolIdx=0; SymbolIdx<MaxSymbols;SymbolIdx++)
  //      {
  //       CopyTime(SymbolsArray[SymbolIdx],0,0,3,Time);
         string comment="";
         f=MyExpert.forecast(_Symbol,0,0,false,comment);
  //       MqlDateTime tm;

  //       TimeToStruct(Time[0],tm);
         if(__Debug__&&false==MQLInfoInteger(MQL_TESTER)) Print("Oracle Encog say: "+DoubleToString(f,3));
         NewOrder(_Symbol,f,comment);
         
//         NewOrder(SymbolsArray[SymbolIdx],f,DoubleToString(f,3)+" "+(string)tm.hour+":"+(string)tm.min+":"+(string)tm.sec);
  //      }

     }
  }
//+------------------------------------------------------------------+
