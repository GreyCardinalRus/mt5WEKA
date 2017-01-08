//+------------------------------------------------------------------+
//|                                                     EncogXOR.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <GC\Oracle.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   COracleMLP_WEKA *MyOracles;
   MyOracles=new COracleMLP_WEKA("XOR");
//   double sig;//=GetVectors(InputVector,InputSignals,smbl,0,shift);
   MyOracles.InputVector[0]=-1;MyOracles.InputVector[1]=-1;
   MyOracles.Compute(MyOracles.InputVector,MyOracles.OutputVector);
//   sig=MyOracles.OutputVector[0];
   Print(MyOracles.InputVector[0]," ",MyOracles.InputVector[1]," ",MyOracles.OutputVector[0]," ",MyOracles.OutputVector[1]);
   MyOracles.InputVector[0]=-1;MyOracles.InputVector[1]=1;
   MyOracles.Compute(MyOracles.InputVector,MyOracles.OutputVector);
   Print(MyOracles.InputVector[0]," ",MyOracles.InputVector[1]," ",MyOracles.OutputVector[0]," ",MyOracles.OutputVector[1]);
   MyOracles.InputVector[0]=1;MyOracles.InputVector[1]=-1;
   MyOracles.Compute(MyOracles.InputVector,MyOracles.OutputVector);
   Print(MyOracles.InputVector[0]," ",MyOracles.InputVector[1]," ",MyOracles.OutputVector[0]," ",MyOracles.OutputVector[1]);
   MyOracles.InputVector[0]=1;MyOracles.InputVector[1]=1;
   MyOracles.Compute(MyOracles.InputVector,MyOracles.OutputVector);
   Print(MyOracles.InputVector[0]," ",MyOracles.InputVector[1]," ",MyOracles.OutputVector[0]," ",MyOracles.OutputVector[1]);
  }
//+------------------------------------------------------------------+
