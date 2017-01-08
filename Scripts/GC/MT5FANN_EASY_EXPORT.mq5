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
#include <GC\CurrPairs.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   CMT5FANN mt5fann;
   mt5fann.debug=true;
   string fn_name="Easy";//"RSI";//"Fractals";
//   string fn_name="Fractals";
   if(!mt5fann.Init(fn_name)) Print("Init error");
   mt5fann.ExportFANNDataWithTest(10000,20,fn_name+"_"+_Symbol);
   //for (int i=0;i<10;i++)      Print(_Symbol," ",mt5fann.forecast());
  }
//+------------------------------------------------------------------+
