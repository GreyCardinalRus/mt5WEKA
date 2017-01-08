//+------------------------------------------------------------------+
//|                                                 MT5FANN_TEST.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <GC\MT5FANN.mqh>
#include <GC\GetVectors.mqh>
// add comment!
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   CMT5FANN SineX;
   SineX.debug=true;
 //  double need_output;
   if(!SineX.Init("sinex")) Print("Init error");
   SineX.test_on_file();
   SineX.train_on_file();
  }
//+------------------------------------------------------------------+
