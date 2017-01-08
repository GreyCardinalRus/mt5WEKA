//+------------------------------------------------------------------+
//|                                                  TradePad_Sample |
//|                       Copyright  2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include "ClassTradePad.mqh"

input int TableRows=5;
int TableCols=5;
input int TableTop=40;
input int TableLeft=20;
input int CellWidth=70;
input int CellHeight=40;
input int TimerPeriodSeconds=5;

input color UpTrendColor=OliveDrab;
input color DownTrendColor=HotPink;
input color FlatColor=DarkGray;
input color UnknownTrend=Cornsilk;

bool launched=false;

CTradePad SymbolTable;
//+------------------------------------------------------------------+
//| создать таблицу символов через объект CTradePad                  |
//+------------------------------------------------------------------+
bool CreatePad(int cols,int rows)
  {
   bool res=false;
//---
   SymbolTable.CreateTradePad(TableCols,TableRows,TableLeft,TableTop,CellWidth,CellHeight,UpTrendColor,DownTrendColor,FlatColor,UnknownTrend);
//---
   return(res);

  }
//+------------------------------------------------------------------+
//| удалить объект CTradePad                                         |
//+------------------------------------------------------------------+
bool DeletePad()
  {
   bool res=false;
//---

   int del=SymbolTable.DeleteTradePad();
   if(ObjectFind(0,SymbolTable.GetChartName())>=0)ObjectDelete(0,SymbolTable.GetChartName());
   ChartRedraw(0);
//Print(del," Symbols deleted");
//---
   return(res);
  }
//+------------------------------------------------------------------+
//|  инициализация при запуске или переинициализации                 |
//+------------------------------------------------------------------+
void OnInit()
  {
   EventSetTimer(TimerPeriodSeconds);
   if(!launched)
     {
      CreatePad(TableCols,TableRows);
      launched=true;
     }
  }
//+------------------------------------------------------------------+
//| при завершении работы советника и изменении входных параметров   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- 
   launched=false;
//--- отключим таймер
   EventKillTimer();
//--- удалим объект
   DeletePad();
  }
//+------------------------------------------------------------------+
//| Process chart events                                             |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   //Print("Событие OnChartEvent: lparam =",lparam,"   dparam=",dparam);

   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      string clickedButton=sparam;
      SymbolTable.SetButtons(clickedButton);
      ChartRedraw();
     }
   if(id==CHARTEVENT_OBJECT_DRAG)
     {
      string dragged=sparam;
      //Print("Перемещен объект ",dragged," lparam =",lparam,"   dparam=",dparam);
      if(dragged==SymbolTable.GetHeaderName())
        {
         int x=(int)ObjectGetInteger(0,dragged,OBJPROP_XDISTANCE);
         int y=(int)ObjectGetInteger(0,dragged,OBJPROP_YDISTANCE);
         SymbolTable.GetShiftTradePad(x,y);
         //Print("X смещение = ",x,"   Y смещение = ",y);
         SymbolTable.MoveTradePad(x,y);
         ChartRedraw();
        }
     }

  }
//+------------------------------------------------------------------+
//| обработка событий таймера                                        |
//+------------------------------------------------------------------+
void OnTimer()
  {
   //Print("Timer event");
   if(launched)SymbolTable.SetButtonColors();
  }

//+------------------------------------------------------------------+
