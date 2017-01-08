//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2010, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <GC\Oracle.mqh>
#include <GC\OracleEasySocket.mqh>
#include <GC\CommonFunctions.mqh>
//#include <GC\OracleSocket.mqh>
//#include <GC\WatcherICQ.mqh>
COracleTemplate *Oracles[];
input int _NEDATA_=1444;//0000;// cколько выгрузить
int nOracles;
//CWatcherICQ watcher;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(AllOracles,20);
   nOracles=0;//AllOracles();
   AllOracles[nOracles++]=new CEasySocket;//COracleTemplate;
   AllOracles[0].Init();
//   AllOracles[0].ExportHistoryENCOG("","",_NEDATA_,0,0,0);
 //  Print(AllOracles[0].GetInputAsString(_Symbol,0));
//for(int i=0;i<nOracles;i++) Print(AllOracles[i].Name()," Ready!");
//   double            InputVector[];ArrayResize(InputVector,20);
//   GetVectors(InputVector,AllOracles[0].inputSignals,_Symbol,0,0);

   //EventSetTimer(6);
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=0;i<nOracles;i++) delete AllOracles[i];
  }

void OnTimer()
  {
   int io;
   double   res=0;
   for(io=0;io<nOracles;io++)
     {
      res+=AllOracles[io].forecast(_Symbol,0,false);
      //watcher.AddNotify(AllOracles[io].GetInputAsString(_Symbol,0));
      //watcher.AddNotify("");
      //watcher.SendNotify();
     }

//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(_TrailingPosition_) Trailing();
   if(!isNewBar(_Symbol)) return;
//   if(__Debug__) Print("Fc?");
   int io;
   double   res=0;
   for(io=0;io<nOracles;io++)
     {
      res+=AllOracles[io].forecast(_Symbol,0,false);
      //watcher.AddNotify(AllOracles[io].GetInputAsString(_Symbol,0));
      //watcher.SendNotify();
     }

//
   NewOrder(_Symbol,res,""+(string)res);
  }
