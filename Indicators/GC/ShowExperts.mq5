//+------------------------------------------------------------------+
//|                                                  ShowExperts.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#include <Oracles.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int numop=0;
int OnInit()
  {
//--- indicator buffers mapping
//---
   Print("SE init");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
////---
//--- return value of prev_calculated for next call
  int i,needcalk=rates_total-prev_calculated;
  if (needcalk>1000) needcalk=1000;
  string name;
  // создаем эксперта
  CRevers myExpert;
  // вызываем по всей истории
  for(i=0;i<needcalk;i++)
   {
    if (myExpert.Prediction(_Symbol,i))
     { // предсказывает на открытие операции
      if (0!=myExpert.way)
       {
         name="orcl_chart_pos_"+(string)(numop++);
         Print(myExpert.price,time[numop]); 
         // рисуем символ покупки/продажи
         if (0>myExpert.way)//&&myExpert.price<SymbolInfoDouble(_Symbol,SYMBOL_BID))
          {
            ObjectCreate(0,name,OBJ_ARROW_SELL,0,time[1],myExpert.price); 
           }
          else 
           {
            ObjectCreate(0,name,OBJ_ARROW_SELL,0,time[1],myExpert.price);
           }
         }
      }
    }
   return(rates_total);
  }
//+------------------------------------------------------------------+
