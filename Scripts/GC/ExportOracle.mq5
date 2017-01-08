//+------------------------------------------------------------------+
//|                                                 ExportOracle.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <GC\Oracle.mqh>
#include <GC\CommonFunctions.mqh>
//COracleTemplate *Oracles[];
input int _NEDATA_=5000;// cколько выгрузить
int nOracles;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnStart()
  {
   ArrayResize(AllOracles,20);
   nOracles=0;//AllOracles();
   AllOracles[nOracles++]=new COracleANN();//COracleTemplate;

 //  AllOracles[nOracles++]=new COracleENCOG("mt5");//COracleTemplate;
  // AllOracles[0].Init();
   AllOracles[0].ExportHistoryENCOG("","",_NEDATA_,0,0,0);
   for(int i=0;i<nOracles;i++) delete AllOracles[i];
    return(0);

  }
//+------------------------------------------------------------------+
