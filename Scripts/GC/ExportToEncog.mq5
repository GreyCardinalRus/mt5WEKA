//+------------------------------------------------------------------+
//|                                                ExportToEncog.mq5 |
//|                                      Copyright 2011, Investeo.pl |
//|                                                http:/Investeo.pl |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, Investeo.pl"
#property link      "http:/Investeo.pl"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

// Export Indicator values for NN training by ENCOG
#include <GC\Oracle.mqh>
#include <GC\CommonFunctions.mqh>
//COracleTemplate *Oracles[];


void OnStart()
  {
//__Debug__ = true;
   COracleTemplate* MyOracles=new COracleENCOG("Encog");//OracleTemplate;
//   MyOracles.Init();
   MyOracles.ExportHistoryENCOG(_Symbol,"",0,_NEDATA_,_ShiftNEDATA_,0,0);
   delete  MyOracles;
   Print("Data exported."); 
  }
//+------------------------------------------------------------------+
