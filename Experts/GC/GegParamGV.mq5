//+------------------------------------------------------------------+
//|                                                   GegParamGV.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <GC\GetVectors.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input int _param1=5;
//input int _param2=8;
//input int _param3=8;
ind_handles IndHandle;
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
     if(_TrailingPosition_) Trailing();
    if(isNewBar()){
 // double way=GetVector_CCIS(IndHandle,_Symbol,0,0,_param1);//,_param2,_param3);
    double way=GetVector_MomentumS(IndHandle,_Symbol,0,0,_param1);//,_param2,_param3);
  Print(way);
   NewOrder(_Symbol,way,"");
   }
  }
//+------------------------------------------------------------------+
