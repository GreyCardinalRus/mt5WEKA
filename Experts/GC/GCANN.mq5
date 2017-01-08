//+------------------------------------------------------------------+
//|                                                        GCANN.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <GC\gc_ann.mqh>
#include <GC\GetVectors.mqh>
//#include <GC\CommonFunctions.mqh>
CGCANN *MyExpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   MyExpert=new CGCANN;
   MyExpert.Load("GCANN");
   //MyExpert.debug=true;
//   MyExpert.Save("GCANN_new");
   Print("Neurons="+(string)MyExpert.Neurons.Total());
//   double f=MyExpert.forecast();
//   Print("f="+(string)f);
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete MyExpert;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static double lastf=0;
   if(_TrailingPosition_) Trailing();
   if(isNewBar())
     {
      //Print("NB");
      double f=MyExpert.forecast(_Symbol,0,false);
      if(lastf!=f)
        {
         lastf=f;
         //Print((string)SeriesInfoInteger(_Symbol,0,SERIES_LASTBAR_DATE)+" f="+(string)f);
        }
      NewOrder(_Symbol,f*1.1,(string)f);
     }
  }
//+------------------------------------------------------------------+
