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
   CWekaJ48* MyOracles=new CWekaJ48();//OracleTemplate;
//   MyOracles.Init();
   MyOracles.GenerateFromFile("Weka_EURUSD_M1.j48");
   delete  MyOracles; 
  }
//+------------------------------------------------------------------+
