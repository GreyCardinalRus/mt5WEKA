//+------------------------------------------------------------------+
//|                                                        Trail.mq5 |
//|                                                          pyroman |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "pyroman"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>

input int      DIST=30; //Ќормальное рассто€ние
input int      DIST_0=15; //–ассто€ние зоны безубыточности
input int      DIST_PANIC=5; //–ассто€ние в режиме паники
double SL; //текущее значение sl в валюте
int DIST_CURR; //текущее значение рассто€ни€ треккинга в пунктах

CPositionInfo posinf;
CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SL=0;
   DIST_CURR=DIST_0;
//---
/*         ObjectCreate(0,"TEST_LINE",OBJ_HLINE,0,0,0);
         ObjectSetInteger(0,"TEST_LINE",OBJPROP_COLOR,Blue);
         ObjectSetInteger(0,"TEST_LINE",OBJPROP_STYLE,STYLE_DOT);
*/
   CreateButton("PANIC",ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)-50,20,"Panic");

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

//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDelete(0,"PANIC");
   ObjectDelete(0,"SL_LINE");

   ObjectDelete(NULL,"label1");
   ObjectDelete(NULL,"label2");

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double sl_tmp=0;

/*   MqlTick last_tick;
   SymbolInfoTick(_Symbol,last_tick);*/

   if(posinf.Select(_Symbol))
     {
      if(posinf.PositionType()==POSITION_TYPE_BUY)
        {
         if(posinf.Profit()>0)
           {
            sl_tmp=posinf.PriceCurrent()-DIST_CURR*Point();
            if((sl_tmp>SL) && (sl_tmp>=posinf.PriceOpen()))
              {
               SL=sl_tmp;
               DIST_CURR=DIST;
              }
           }
         //«акрытие позиции при пересечении SL
         if(posinf.PriceCurrent()<=SL)
           {
            if(trade.PositionClose(_Symbol,0))
            {
               SL=0;
            }
           }
        }
      if(posinf.PositionType()==POSITION_TYPE_SELL)
        {
         if(posinf.Profit()>0)
           {
            sl_tmp=posinf.PriceCurrent()+DIST_CURR*Point();
            if((((SL>0) && (sl_tmp<SL)) || (SL==0)) && (sl_tmp<=posinf.PriceOpen()))
              {
               SL=sl_tmp;
               DIST_CURR=DIST;
              }
           }
         //«акрытие позиции при пересечении SL
         if((SL>0) && (posinf.PriceCurrent()>=SL))
           {
            if(trade.PositionClose(_Symbol,0))
            {
               SL=0;
            }
           }
        }
     }
   else
     {
      SL=0;
      DIST_CURR=DIST_0;
     }

   if(SL>0)
      ObjectSetString(NULL,"label1",OBJPROP_TEXT,string(MathAbs((posinf.PriceOpen()-SL)/Point())));
   else
      ObjectSetString(NULL,"label1",OBJPROP_TEXT,"n/a");

   ObjectSetString(NULL,"label2",OBJPROP_TEXT,string(MathAbs((posinf.PriceOpen()-posinf.PriceCurrent())/Point())));

   DrawLine();
  }
//+------------------------------------------------------------------+
void DrawLine()
  {
   if(SL>0)
     {
      if(ObjectFind(0,"SL_LINE")<0)
        {
         ObjectCreate(0,"SL_LINE",OBJ_HLINE,0,0,SL);
         ObjectSetInteger(0,"SL_LINE",OBJPROP_COLOR,Yellow);
         ObjectSetInteger(0,"SL_LINE",OBJPROP_STYLE,STYLE_DOT);
        }
      ObjectSetDouble(0,"SL_LINE",OBJPROP_PRICE,SL);
     }
   else
     {
      ObjectDelete(0,"SL_LINE");
     }

/*   MqlTick last_tick;
   SymbolInfoTick(_Symbol,last_tick);   
   ObjectSetDouble(0,"TEST_LINE",OBJPROP_PRICE,last_tick.ask+Point()*100);
*/
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(posinf.Select(_Symbol))
     {
      if(ObjectGetInteger(0,"PANIC",OBJPROP_STATE)!=0)
        {
         DIST_CURR=DIST_PANIC;
        }
      else
        {
         if(SL==0) DIST_CURR=DIST_0;
         else DIST_CURR=DIST;
        }
     }
   else
     {
      ObjectSetInteger(0,"PANIC",OBJPROP_STATE,0);
     }
  }
//+------------------------------------------------------------------+
void CreateButton(string name,long x,long y,string text="Button")
  {
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+------------------------------------------------------------------+
