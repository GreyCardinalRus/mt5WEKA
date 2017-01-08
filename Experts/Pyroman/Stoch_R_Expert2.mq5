//+------------------------------------------------------------------+
//|                                                  SmartExpert.mq5 |
//|                                                          pyroman |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "pyroman"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input double   Lot=1;
input int      SL=200;
input int      TP=0;

/*//MACD signal 
input int      MACD_F=2;
input int      MACD_S=15;
input int      MACD_A=9;
int            h_macd=0;
double         macd_main[];
double         macd_signal[];
//end MACD Signal

//RSI signal 
input int         RSI=14;
int               h_rsi=0;
double            rsi_buffer[];
//end RSI Signal

//ROC signal 
input int         ROC=10;
int               h_roc=0;
double            roc_buffer[];
//end ROC Signal

*/
//WPR signal 
input int         WPR=30;
int               h_wpr=0;
double            wpr_buffer[];
//end WPR Signal

//Stochastic signal 
input int         StochK=10;
input int         StochD=3;
input int         StochSlow=3;
int               h_sth=0;
double            sth_buffer_main[];
double            sth_buffer_signal[];
//end Stochastic Signal


//Smart signal 
/*int               h_silver=0;
double            silver_buffer_buy[];
double            silver_buffer_sell[];
//end Smart Signal*/

/*//AMA signal 
input int         AMA=2;
input int         F_AMA=2;
input int         S_AMA=30;
int               h_ama=0;
double            ama_buffer[];
//end AMA Signal
*/

/*//MA signal 
input int         MA=10;
int               h_ma=0;
double            ma_buffer[];
//end MA Signal*/


//double SIGNAL[2]; //главная переменная. сформированный сигнал.
//datetime POS_TIME; //время формирования сигнала

int ARROW_ID=0;

CPositionInfo posinf;
CTrade trade;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

//---
/*   h_macd=iMACD(Symbol(),Period(),MACD_F,MACD_S,MACD_A,PRICE_CLOSE);
   h_roc=iCustom(Symbol(),Period(),"Examples\\ROC",ROC,PRICE_CLOSE);*/
   h_wpr=iWPR(Symbol(),Period(),WPR);
   h_sth=iStochastic(Symbol(),Period(),StochK,StochD,StochSlow,MODE_EMA,STO_LOWHIGH);
//   h_silver=iCustom(Symbol(),Period(),"SilverTrend_Signal",PRICE_CLOSE);
//   h_ama=iAMA(Symbol(),Period(),AMA,F_AMA,S_AMA,0,h_smart);
//   h_ma=iMA(Symbol(),Period(),MA,0,MODE_EMA,h_smart);

//---

   ObjectCreate(NULL,"label1",OBJ_LABEL,0,0,0);
   ObjectSetInteger(NULL,"label1",OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(NULL,"label1",OBJPROP_XDISTANCE,0);
   ObjectSetInteger(NULL,"label1",OBJPROP_YDISTANCE,0);
   ObjectSetInteger(NULL,"label1",OBJPROP_COLOR,White);
   ObjectSetString(NULL,"label1",OBJPROP_TEXT,"");

   ObjectCreate(NULL,"label2",OBJ_LABEL,0,0,0);
   ObjectSetInteger(NULL,"label2",OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetInteger(NULL,"label2",OBJPROP_XDISTANCE,0);
   ObjectSetInteger(NULL,"label2",OBJPROP_YDISTANCE,12);
   ObjectSetInteger(NULL,"label2",OBJPROP_COLOR,White);
   ObjectSetString(NULL,"label2",OBJPROP_TEXT,"");

   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(NULL,"label1");
   ObjectDelete(NULL,"label2");

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   double sl=0;
   double tp=0;
   datetime dt[];
//---

   CopyBuffer(h_sth,MAIN_LINE,0,3,sth_buffer_main);
   ArraySetAsSeries(sth_buffer_main,true);
   CopyBuffer(h_sth,SIGNAL_LINE,0,3,sth_buffer_signal);
   ArraySetAsSeries(sth_buffer_signal,true);
   
   CopyBuffer(h_wpr,0,0,3,wpr_buffer);
   ArraySetAsSeries(wpr_buffer,true);


//------------------------------------------------

   if(!posinf.Select(_Symbol))
     {
//         if((MathAbs(ama_buffer[1])>=1) && (ama_buffer[1]>0) && (ama_buffer[2]<=0))
         if((wpr_buffer[1]>-50) && (sth_buffer_main[1]>80) && (sth_buffer_main[2]<=80) && (sth_buffer_main[1]>sth_buffer_signal[1]))
//         if(silver_buffer_buy[0]>=1)
           {
            if(SL>0) sl=SymbolInfoDouble(_Symbol,SYMBOL_ASK)-SL*Point();
            if(TP>0) tp=SymbolInfoDouble(_Symbol,SYMBOL_ASK)+TP*Point();
            if(trade.Buy(Lot,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_ASK),sl,tp))
              {
               ARROW_ID+=1;
               ObjectCreate(ChartID(),"AG_BAY_" + string(ARROW_ID),OBJ_ARROW_BUY,0,SymbolInfoInteger(_Symbol,SYMBOL_TIME),SymbolInfoDouble(_Symbol,SYMBOL_ASK));
               CopyTime(_Symbol,0,0,2,dt);
               ArraySetAsSeries(dt,true);
               //POS_TIME=dt[1];
              }
            else
              {
               Print(trade.ResultRetcodeDescription());
              }

           }
//         else if((MathAbs(ama_buffer[1])>=1) && (ama_buffer[1]<0) && (ama_buffer[2]>=0))
         else if((wpr_buffer[1]<-50) && (sth_buffer_main[1]<20) && (sth_buffer_main[2]>=20) && (sth_buffer_main[1]<sth_buffer_signal[1]))
           {
            if(SL>0) sl=SymbolInfoDouble(_Symbol,SYMBOL_BID)+SL*Point();
            if(TP>0) tp=SymbolInfoDouble(_Symbol,SYMBOL_BID)-TP*Point();
            if(trade.Sell(Lot,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID),sl,tp))
              {
               ARROW_ID+=1;
               ObjectCreate(ChartID(),"AG_SELL_" + string(ARROW_ID),OBJ_ARROW_SELL,0,SymbolInfoInteger(_Symbol,SYMBOL_TIME),SymbolInfoDouble(_Symbol,SYMBOL_BID));
//               ObjectCreate(ChartID(),"sell",OBJ_ARROW_SELL,0,SymbolInfoInteger(_Symbol,SYMBOL_TIME),posinf.PriceOpenSymbolInfoDouble(_Symbol,SYMBOL_BID));
               CopyTime(_Symbol,0,0,2,dt);
               ArraySetAsSeries(dt,true);
               //POS_TIME=dt[1];
              }
            else
              {
               Print(trade.ResultRetcodeDescription());
              }

           }
        }
      else //когда позиция открыта
        {  
/*         if ((posinf.PositionType()==POSITION_TYPE_BUY) && ((silver_buffer_sell[1]>=1)))
         {
            trade.PositionClose(_Symbol);
         }
         else if ((posinf.PositionType()==POSITION_TYPE_SELL) && ((silver_buffer_buy[1]>=1)))
         {
            trade.PositionClose(_Symbol);
         }
*/            
        }
        
      ObjectSetString(NULL,"label1",OBJPROP_TEXT,"Stoch="+string(sth_buffer_main[0]));
      ObjectSetString(NULL,"label2",OBJPROP_TEXT,"WPR="+string(wpr_buffer[0]));

     
//докупка------------------------------------------------
/*   else if(posinf.Profit()<0)
     {
      CopyTime(_Symbol,0,0,2,dt);
      ArraySetAsSeries(dt,true);
      
      if((POS_TIME!=dt[1])&& ((MathAbs(posinf.PriceCurrent() - posinf.PriceOpen())/_Point)>=30) && (posinf.Volume()<10*Lot))
//      if((POS_TIME!=dt[1])&& ((MathAbs(posinf.PriceCurrent() - posinf.PriceOpen())*Lot/(2*_Point*posinf.Volume()))>=10) && (posinf.Volume()<10*Lot))
        {

         if((posinf.PositionType()==POSITION_TYPE_BUY) && ((SIGNAL[1]<0) || (SIGNAL[0]<=-8)))
           {
            if(SL>0) sl=SymbolInfoDouble(_Symbol,SYMBOL_ASK)-SL*Point();
            if(TP>0) tp=SymbolInfoDouble(_Symbol,SYMBOL_ASK)+TP*Point();
            if(trade.Buy(Lot,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_ASK),sl,tp))
              {
               ObjectCreate(ChartID(),"buy",OBJ_ARROW_BUY,0,SymbolInfoInteger(_Symbol,SYMBOL_TIME),SymbolInfoDouble(_Symbol,SYMBOL_ASK));
               CopyTime(_Symbol,0,0,2,dt);
               ArraySetAsSeries(dt,true);
               POS_TIME=dt[1];
              }
            else
              {
               Print(trade.ResultRetcodeDescription());
              }

           }
         if((posinf.PositionType()==POSITION_TYPE_SELL) && ((SIGNAL[1]>0) || (SIGNAL[0]>=8)))
           {
            if(SL>0) sl=SymbolInfoDouble(_Symbol,SYMBOL_BID)+SL*Point();
            if(TP>0) tp=SymbolInfoDouble(_Symbol,SYMBOL_BID)-TP*Point();
            if(trade.Sell(Lot,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID),sl,tp))
              {
               ObjectCreate(ChartID(),"sell",OBJ_ARROW_SELL,0,SymbolInfoInteger(_Symbol,SYMBOL_TIME),SymbolInfoDouble(_Symbol,SYMBOL_BID));
               CopyTime(_Symbol,0,0,2,dt);
               ArraySetAsSeries(dt,true);
               POS_TIME=dt[1];
              }
            else
              {
               Print(trade.ResultRetcodeDescription());
              }
           }
        }
     }*/
  }
//+------------------------------------------------------------------+
int Sign(double n)
  {
   if(n>0) return 1;
   else if(n<0) return -1;
   else return 0;
  }
//+------------------------------------------------------------------+
