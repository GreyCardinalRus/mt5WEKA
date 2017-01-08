//+------------------------------------------------------------------+
//|                                           NeuralEncogAdvisor.mq5 |
//|                                      Copyright 2011, Investeo.pl |
//|                                                http:/Investeo.pl |
//+------------------------------------------------------------------+
//Из-за реализации в виде "двойной DLL-обертки под .NET", 
//файлы Cloo.dll, encog-core-cs.dll и log4net.dll нужно скопировать в каталог установки клиентского терминала. 
//Файл EncogNNTrainDLL.dll нужно скопировать в каталог папка_данных_клиентского_терминала\MQL5\Libraries\.

#property copyright "Copyright 2011, Investeo.pl"
#property link      "http:/Investeo.pl"
#property version   "1.00"


double neuralArr[];

double trend;
double Lots=0.3;

int INPUT_WINDOW=8;

int hNeural,hChandelier,hMA;

input int adxvar=30;
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArrayResize(neuralArr,INPUT_WINDOW);
   ArraySetAsSeries(neuralArr,true);
   ArrayInitialize(neuralArr,0.0);

   hNeural=iCustom(Symbol(),Period(),"NeuralEncogIndicator");
   Print("hNeural = ",hNeural,"  error = ",GetLastError());

   if(hNeural<0)
     {
      Print("The creation of ENCOG indicator has failed: Runtime error =",GetLastError());
      //--- forced program termination
      return(-1);
     }
   else  Print("ENCOG indicator initialized");

   hChandelier=iCustom(Symbol(),Period(),"Chandelier");
   Print("hChandelier = ",hChandelier,"  error = ",GetLastError());

   if(hChandelier<0)
     {
      Print("The creation of Chandelier indicator has failed: Runtime error =",GetLastError());
      //--- forced program termination
      return(-1);
     }
   else  Print("Chandelier indicator initialized");
//---
   return(0);
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
//---
   long tickCnt[1];
   int ticks=CopyTickVolume(Symbol(),0,0,1,tickCnt);
   if(tickCnt[0]==1)
     {
      if(!CopyBuffer(hNeural,0,0,INPUT_WINDOW,neuralArr)) { Print("Copy1 error"); return; }

      // Print("neuralArr[0] = "+neuralArr[0]+"neuralArr[1] = "+neuralArr[1]+"neuralArr[2] = "+neuralArr[2]);

      trend=0;

      if(neuralArr[0]<0 && neuralArr[1]>0) trend=-1;
      if(neuralArr[0]>0 && neuralArr[1]<0) trend=1;

      Trade();
     }
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---

//---
   return(0.0);
  }
//+------------------------------------------------------------------+

void Trade()
  {
   double bufChandelierUP[2];
   double bufChandelierDN[2];

   double bufMA[2];

   ArraySetAsSeries(bufChandelierUP,true);
   ArraySetAsSeries(bufChandelierUP,true);

   ArraySetAsSeries(bufMA,true);

   CopyBuffer(hChandelier,0,0,2,bufChandelierUP);
   CopyBuffer(hChandelier,1,0,2,bufChandelierDN);

   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(Symbol(),PERIOD_CURRENT,0,3,rates);

   bool strong_uptrend=neuralArr[0]>0 && neuralArr[1]>0 && neuralArr[2]>0 && neuralArr[3]>0 && neuralArr[4]>0 && neuralArr[5]>0 && neuralArr[6]>0 && neuralArr[7]>0;
   bool strong_downtrend=neuralArr[0]<0 && neuralArr[1]<0 && neuralArr[2]<0 && neuralArr[3]<0 && neuralArr[4]<0 && neuralArr[5]<0 && neuralArr[6]<0 && neuralArr[7]<0;

   if(PositionSelect(_Symbol))
     {
      long type=PositionGetInteger(POSITION_TYPE);
      bool close=false;

      if((type==POSITION_TYPE_BUY) && (trend==-1))

         if(!(strong_uptrend) || (bufChandelierUP[0]==EMPTY_VALUE)) close=true;
      if((type==POSITION_TYPE_SELL) && (trend==1))
         if(!(strong_downtrend) || (bufChandelierDN[0]==EMPTY_VALUE))
            close=true;
      if(close)
        {
         CTrade trade;
         trade.PositionClose(_Symbol);
        }
      else // adjust s/l
        {
         CTrade trade;

         if(copied>0)
           {
            if(type==POSITION_TYPE_BUY)
              {
               if(bufChandelierUP[0]!=EMPTY_VALUE)
                  trade.PositionModify(Symbol(),bufChandelierUP[0],0.0);
              }
            if(type==POSITION_TYPE_SELL)
              {
               if(bufChandelierDN[0]!=EMPTY_VALUE)
                  trade.PositionModify(Symbol(),bufChandelierDN[0],0.0);
              }
           }
        }
     }

   if((trend!=0) && (!PositionSelect(_Symbol)))
     {
      CTrade trade;
      MqlTick tick;
      MqlRates rates[];
      ArraySetAsSeries(rates,true);
      int copied=CopyRates(Symbol(),PERIOD_CURRENT,0,INPUT_WINDOW,rates);

      if(copied>0)

        {
         if(SymbolInfoTick(_Symbol,tick)==true)
           {

            if(trend>0)
              {
               trade.Buy(Lots,_Symbol,tick.ask);

               Print("Buy at "+tick.ask+" trend = "+trend+" neuralArr = "+neuralArr[0]);

              }
            if(trend<0)
              {
               trade.Sell(Lots,_Symbol,tick.bid);

               Print("Sell at "+tick.ask+" trend = "+trend+" neuralArr = "+neuralArr[0]);
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
