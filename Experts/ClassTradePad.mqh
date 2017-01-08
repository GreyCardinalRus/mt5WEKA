//+------------------------------------------------------------------+
//|                                                       CChart.mqh |
//|                      Copyright � 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#include "ClassSymbolButton.mqh"
#include "ClassChart.mqh"
//+------------------------------------------------------------------+
//| ����� ���������� ������� ���������                               |
//+------------------------------------------------------------------+
class CTradePad
  {
private:
   int               m_rows;                    // ���������� ����� � ������� ��������
   int               m_columns;                 // ���������� �������� � ������� ��������
   int               m_button_width;            // ������ ������ � ��������
   int               m_button_height;           // ������ ������ � ��������
   int               m_top;                     // ���������� X ��� �������� ������ ���� �������
   int               m_left;                    // ���������� Y ��� �������� ������ ���� �������
   int               m_left_previous_header;    // ���������� �������� X ��� �������� ������ ���� ���������
   int               m_top_previos_header;      // ���������� �������� Y ��� �������� ������ ���� ���������
   color             m_button_text_color;       // ������ ���� ������ ��� ������
   color             m_button_bg_color;         // ������ ���� ���� ��� ������
   string            m_prefix;                  // ������ ������� ��� ����������� �������� ���� CSymbolButton
   string            m_chart_name;              // ��� ������� Chart
   int               m_top_chart;               // ���������� Y ��� �������� ������ ���� �������
   int               m_left_chart;              // ���������� X ��� �������� ������ ���� �������
   int               m_footer_width;            // ������ �������
   CSymbolButton     m_symbol_set[];            // ������ � ��������� ��� ���������� �������� ��������
   string            m_header;                  // ��� ������� ��� �������� �������
   int               m_top_buy_button;          // ���������� Y ��� �������� ������ ���� ������ BUY
   int               m_left_buy_button;         // ���������� X ��� �������� ������ ���� ������ BUY
   int               m_top_sell_button;         // ���������� Y ��� �������� ������ ���� ������ SELL
   int               m_left_sell_button;        // ���������� X ��� �������� ������ ���� ������ SELL
   int               m_top_lots_edit;           // ���������� Y ��� �������� ������ ���� ���� ����� ������
   int               m_left_lots_edit;          // ���������� X ��� �������� ������ ���� ���� ����� ������
   int               m_width_lots_edit;         // ������ ���� ����� ������
   string            m_buy_button;              // ��� ������ BUY
   string            m_sell_button;             // ��� ������ SELL
   string            m_lots_edit;               // ��� ���� ����� ������
   string            m_chart_symbol_name;       // ��� �������, ������� ���������� ������ Chart
   ENUM_TIMEFRAMES   m_current_tf;              // ������ �������,������� ���������� ������ Chart
   color             m_up_color;
   color             m_down_color;
   color             m_flat_color;
   color             m_blank_color;
   CChart            tradeChart;                // ������ ����
public:
   void              CTradePad();                // �����������
   bool              CreateTradePad(int cols,int rows,int Xleft,int Ytop,int width,int height,color u,color d,color f,color b);
   int               DeleteTradePad();
   string            GetChartName(){return(m_chart_name);};
   int               GetSymbolButtons(){return(ArraySize(m_symbol_set));};
   void              SetButtons(string symbolName);
   void              MoveTradePad(int x_shift,int y_shift);
   void              GetShiftTradePad(int &x_shift,int &y_shift);
   string            GetHeaderName(){return(m_header);};
   void              SetButtonColors();
   void              SetTrendColors(color u,color d,color f,color b){m_up_color=u;m_down_color=d;m_flat_color=f; m_blank_color=b;};
   void              EmptyFunction();
   int               GetIndicatorHandle(string symbol,ENUM_TIMEFRAMES timeframe);
  };
//+------------------------------------------------------------------+
//|  ����������� �� ��������� (������ ��� ����������)                |
//+------------------------------------------------------------------+
void CTradePad::CTradePad()
  {
   m_button_bg_color=Green;
   m_button_text_color=White;
   m_prefix="cell_";
   m_header="TablePad";
   m_chart_name="test";
   m_buy_button="BuyButton";
   m_sell_button="SellButton";
   m_lots_edit="InputVolume";
  }
//+------------------------------------------------------------------+
//|  �������� ������� �������� (���������� �����������)              |
//+------------------------------------------------------------------+
bool CTradePad::CreateTradePad(int cols,int rows,int Xleft,int Ytop,int width,int height,
                               color u,color d,color f,color b)
  {
   bool res=false;
//---
   SetTrendColors(u,d,f,b);
   m_left=Xleft;
   m_top=Ytop;
   int Yord,Xord;
//--- ������� � ��� ����� ������?
   ArrayResize(m_symbol_set,cols*rows);
   int j=0,tradeSymbols=SymbolsTotal(false);
   string symb[];
   ArrayResize(symb,cols*rows);

//--- �������� �����
   m_top_previos_header=m_top-20;
   m_left_previous_header=m_left;
   if(ObjectFind(0,m_header)<0) ObjectCreate(0,m_header,OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,m_header,OBJPROP_COLOR,White);
   ObjectSetInteger(0,m_header,OBJPROP_BGCOLOR,Blue);
   ObjectSetInteger(0,m_header,OBJPROP_XDISTANCE,m_left_previous_header);
   ObjectSetInteger(0,m_header,OBJPROP_YDISTANCE,m_top_previos_header);
   ObjectSetInteger(0,m_header,OBJPROP_XSIZE,cols*width);
   ObjectSetInteger(0,m_header,OBJPROP_YSIZE,20);
   ObjectSetString(0,m_header,OBJPROP_TEXT,"Trade Pad ");
   ObjectSetString(0,m_header,OBJPROP_FONT,"Tahoma");
   ObjectSetInteger(0,m_header,OBJPROP_SELECTABLE,true);

//--- �������� ������
   for(int c=0;c<cols;c++)
     {
      Xord=m_left+c*width;         // X �������� ������ �������
      for(int r=0;r<rows;r++)
        {
         Yord=m_top+r*height;     // Y �������� ������ �������
         string name;
         if(j>=tradeSymbols) j=0;
         name=SymbolName(j,false);
         j++;
         symb[c*rows+r]=name;
         SymbolSelect(name,true);
         double v;
         color col;
         //--- ���������� ��������� ������ ��� �������� ������ ����������
         m_symbol_set[c*rows+r].SetSymbolName(name);
         m_symbol_set[c*rows+r].UpdateIndicator(_Period);

         //col=GetColorOfSymbol(curr_handle,
         //                     m_up_color,m_down_color,
         //                     m_flat_color,m_blank_color,v);
         m_symbol_set[c*rows+r].CreateSymbolButton(Yord,
                                                   Xord,
                                                   height,
                                                   width,
                                                   name,
                                                   m_button_text_color,
                                                   m_blank_color);
        }
     }
//--- ������ ������ ������
   ObjectSetInteger(0,symb[0],OBJPROP_STATE,true);

//--- �������� ������ Chart
   int chartheight=252;
   m_current_tf=ChartPeriod(0);
//   if(ObjectFind(0,m_chart_name)<0)ObjectCreate(0,m_chart_name,OBJ_CHART,0,0,0,0,0);

   m_top_chart=m_top+rows*height;
   m_left_chart=m_left;

   m_footer_width=cols*width;

   chartheight=252;
   tradeChart.CreateChart(m_left_chart,m_top_chart,m_footer_width,chartheight,symb[0],"testChart");

//--- �������� ������
//--- ������ SELL
   if(ObjectFind(0,m_sell_button)<0) ObjectCreate(0,m_sell_button,OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,m_sell_button,OBJPROP_COLOR,White);
   ObjectSetInteger(0,m_sell_button,OBJPROP_BGCOLOR,OrangeRed);
   m_top_sell_button=m_top_chart+chartheight;
   m_left_sell_button=m_left_chart;
   ObjectSetInteger(0,m_sell_button,OBJPROP_XDISTANCE,m_left_sell_button);
   ObjectSetInteger(0,m_sell_button,OBJPROP_YDISTANCE,m_top_sell_button);
   ObjectSetInteger(0,m_sell_button,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,m_sell_button,OBJPROP_YSIZE,40);
   ObjectSetString(0,m_sell_button,OBJPROP_FONT,"Tahoma");
   ObjectSetInteger(0,m_sell_button,OBJPROP_FONTSIZE,15);
   ObjectSetString(0,m_sell_button,OBJPROP_TEXT,"SELL");
   ObjectSetInteger(0,m_sell_button,OBJPROP_SELECTABLE,false);

//--- ������ BUY
   if(ObjectFind(0,m_buy_button)<0) ObjectCreate(0,m_buy_button,OBJ_BUTTON,0,0,0,0,0);
   ObjectSetInteger(0,m_buy_button,OBJPROP_COLOR,White);
   ObjectSetInteger(0,m_buy_button,OBJPROP_BGCOLOR,Blue);
   m_top_buy_button=m_top_sell_button;
   m_left_buy_button=m_left_chart+m_footer_width-100;
   ObjectSetInteger(0,m_buy_button,OBJPROP_XDISTANCE,m_left_buy_button);
   ObjectSetInteger(0,m_buy_button,OBJPROP_YDISTANCE,m_top_buy_button);
   ObjectSetInteger(0,m_buy_button,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,m_buy_button,OBJPROP_YSIZE,40);
   ObjectSetString(0,m_buy_button,OBJPROP_FONT,"Tahoma");
   ObjectSetInteger(0,m_buy_button,OBJPROP_FONTSIZE,15);
   ObjectSetString(0,m_buy_button,OBJPROP_TEXT,"BUY");
   ObjectSetInteger(0,m_buy_button,OBJPROP_SELECTABLE,false);

//--- ���� ����� Volume
   if(ObjectFind(0,m_lots_edit)<0) ObjectCreate(0,m_lots_edit,OBJ_EDIT,0,0,0,0,0);
   ObjectSetInteger(0,m_lots_edit,OBJPROP_COLOR,White);
   ObjectSetInteger(0,m_lots_edit,OBJPROP_BGCOLOR,DarkOliveGreen);
   m_top_lots_edit=m_top_sell_button;
   m_left_lots_edit=m_left_chart+100;
   m_width_lots_edit=m_footer_width-200;
   ObjectSetInteger(0,m_lots_edit,OBJPROP_XDISTANCE,m_left_lots_edit);
   ObjectSetInteger(0,m_lots_edit,OBJPROP_YDISTANCE,m_top_lots_edit);
   ObjectSetInteger(0,m_lots_edit,OBJPROP_XSIZE,m_width_lots_edit);
   ObjectSetInteger(0,m_lots_edit,OBJPROP_YSIZE,40);
   ObjectSetString(0,m_lots_edit,OBJPROP_FONT,"Tahoma");
   ObjectSetInteger(0,m_lots_edit,OBJPROP_FONTSIZE,10);
   ObjectSetString(0,m_lots_edit,OBJPROP_TEXT,"   0.1");
   ObjectSetInteger(0,m_lots_edit,OBJPROP_SELECTABLE,false);

//---  ������� �� ��������� ���� ���������
   ChartRedraw(0);

//--- �������� ������� � ��������� ������ ���������� ��� ������
   Sleep(300);
   SetButtonColors();
   ChartRedraw(0);

//---
   return(res);
  }
//+------------------------------------------------------------------+
//|  ��������� ����� ����                                            |
//+------------------------------------------------------------------+
void CTradePad::SetButtonColors()
  {
   int i,buttons=GetSymbolButtons();
   double v;// ���� ����� �������� �������� ����������      
//--- ��������� ���� ��� �������� ������� �����������
   for(i=0;i<buttons;i++)
      m_symbol_set[i].UpdateIndicator(m_current_tf);
//---
   for(i=0;i<buttons;i++)
     {
      color c; // ���� ����� �������� ���� ������      
      int handle=m_symbol_set[i].GetIndicatorHandle();
      if(handle>0)
        {
         c=GetColorOfSymbol(handle,
                            m_up_color,m_down_color,
                            m_flat_color,m_blank_color,v);
         m_symbol_set[i].SetIndicatorvalue(v);
        }
      else
        {
         c=m_blank_color;
        }
      //---
      m_symbol_set[i].SetBGColor(c);
     }
//---
   ChartRedraw();
//---
  }
//+------------------------------------------------------------------+
//| �������� ���� �������� ������� ��������                          |
//+------------------------------------------------------------------+
int CTradePad::DeleteTradePad()
  {
   int deleted=0;
   int size=ArraySize(m_symbol_set);
//---
   tradeChart.DeleteChart();
   for(int i=0;i<size;i++)
     {
      m_symbol_set[i].DeleteSymbolButton();
      deleted++;
     }
   ObjectDelete(0,m_header);
   ObjectDelete(0,m_buy_button);
   ObjectDelete(0,m_sell_button);
   ObjectDelete(0,m_lots_edit);
//---
   return(deleted);
  }
//+------------------------------------------------------------------+
//|  ������� ������� ������ � ��������� ������� � �����              |
//+------------------------------------------------------------------+
void CTradePad::SetButtons(string name)
  {
   int handle=ObjectFind(0,name);

//--- ���� ������ ������ BUY
   if(name==m_buy_button)
     {
      //--- ������ ������� ������ �������
      Sleep(200);
      ObjectSetInteger(0,name,OBJPROP_STATE,false);
      return;
     }
//--- ���� ������ ������ SELL
   if(name==m_sell_button)
     {
      //--- ������ ������� ������ �������
      Sleep(200);
      ObjectSetInteger(0,name,OBJPROP_STATE,false);
      return;
     }

//--- ���������� ������� ��������� ������ CChart
   if(tradeChart.IsChartControlEvent(name))
     {
      //Print("��������� ������� �������� ������ CChart");
      tradeChart.DoChartOperations(name);
      m_current_tf=tradeChart.GetChartTimeframe();
      SetButtonColors();
      ChartRedraw(0);
      return;
     }

//Print("���������� ������� ������ � ������ ", name);
   if(handle>=0)
     {
      int size=GetSymbolButtons();
      for(int i=0;i<size;i++)
        {
         if(m_symbol_set[i].m_button_name==name)
           {
            bool selected=ObjectGetInteger(0,name,OBJPROP_STATE);
            Print("������ "+name+" ������, �������� ���������� ����� ",m_symbol_set[i].GetIndicatorvalue());
            if(!selected)
               ObjectSetInteger(0,m_symbol_set[i].m_button_name,OBJPROP_STATE,false);
           }
         else
           {
            ObjectSetInteger(0,m_symbol_set[i].m_button_name,OBJPROP_STATE,false);
           }

        }
     }
   tradeChart.SetSymbolForChart(name);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| ����������� ��� �������� ������� ��������                        |
//+------------------------------------------------------------------+
void CTradePad::MoveTradePad(int x_shift,int y_shift)
  {
   int buttons=GetSymbolButtons();
//--- �������� ������
   for(int i=0;i<buttons;i++)
     {
      m_symbol_set[i].MoveButton(x_shift,y_shift);
     }
//--- �������� Chart
   tradeChart.MoveChart(x_shift,y_shift);
//--- �������� ������ BUY
   m_left_buy_button+=x_shift;
   m_top_buy_button+=y_shift;
   ObjectSetInteger(0,m_buy_button,OBJPROP_XDISTANCE,m_left_buy_button);
   ObjectSetInteger(0,m_buy_button,OBJPROP_YDISTANCE,m_top_buy_button);
//--- �������� ������ SELL
   m_left_sell_button+=x_shift;
   m_top_sell_button+=y_shift;
   ObjectSetInteger(0,m_sell_button,OBJPROP_XDISTANCE,m_left_sell_button);
   ObjectSetInteger(0,m_sell_button,OBJPROP_YDISTANCE,m_top_sell_button);
//--- �������� ���� ����� InputVolume
   m_left_lots_edit+=x_shift;
   m_top_lots_edit+=y_shift;
   ObjectSetInteger(0,m_lots_edit,OBJPROP_XDISTANCE,m_left_lots_edit);
   ObjectSetInteger(0,m_lots_edit,OBJPROP_YDISTANCE,m_top_lots_edit);
//--- ������� �� ���������
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTradePad::GetShiftTradePad(int &x_shift,int &y_shift)
  {
//--- �������� �������� ��������
   int dx=x_shift-m_left_previous_header;
   int dy=y_shift-m_top_previos_header;
//--- �������� ����� ����������
   m_left_previous_header=x_shift;
   m_top_previos_header=y_shift;
//--- ������ ��������� ��������
   x_shift=dx;
   y_shift=dy;
  }
//+------------------------------------------------------------------+
//| ������� ���� � ����������� �� ����������� ������                 |
//+------------------------------------------------------------------+
color GetColorOfSymbol(int indicator_handle,
                       color up,
                       color dn,
                       color flat,
                       color empty,
                       double &value)
  {
   color trend=flat;
//---
   double values[1];
   if(BarsCalculated(indicator_handle)<=0) return(empty);
   if(CopyBuffer(indicator_handle,1,0,1,values)<=0) return(empty);
   value=values[0];
   if(values[0]>80) trend=up;
   if(values[0]<20) trend=dn;
   return(trend);
//---
  }
//+------------------------------------------------------------------+
