//+------------------------------------------------------------------+
//|                                                       CChart.mqh |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#include "ClassControlButton.mqh"
#define  UP          "\x0431"
#define  DOWN        "в"

ENUM_TIMEFRAMES periods[21];
//+------------------------------------------------------------------+
//| класс реализации чарта с контроллами                             |
//+------------------------------------------------------------------+
class CChart
  {
private:
   int               m_top;                     // Y координата левого верхнего угла
   int               m_left;                    // X координата левого верхнего угла
   int               m_width;                   // ширина
   int               m_height;                  // высота
   ENUM_TIMEFRAMES   m_time_frame;              // таймфрейм
   int               m_scaling;                 // текущий масштаб
   string            m_symbol;                  // Символ начарте
   string            m_chart_name;              // имя объекта Chart
   int               m_control_width;           // ширина кнопки
   int               m_control_height;          // высота кнопки
   CControlButton    m_controls[6];             // массив контролов упраления чартом
   bool              m_first_launch;            // признак первогозапуска
   int               m_period_counter;
public:
   void              CChart();
   void              CreateChart(int l,int t,int w,int h,string s,string name);
   void              MoveChart(int x,int y);
   void              SetSymbolForChart(string symbol);
   void              UpScaleChart();
   void              DownScaleChart();
   void              DeleteChart();
   bool              IsChartControlEvent(string control_name);
   void              DoChartOperations(string name);
   ENUM_TIMEFRAMES   GetChartTimeframe(){return(periods[m_period_counter]);};
  };
//+------------------------------------------------------------------+
//| конструктор по умолчанию                                         |
//+------------------------------------------------------------------+
void CChart::CChart()
  {
   m_top=0;
   m_left=0;
   m_time_frame=ChartPeriod(0);
   m_symbol=ChartSymbol(0);
   m_scaling=2;
   m_control_width=30;
   m_control_height=42;
   m_first_launch=true;
   periods[0]=PERIOD_M1;
   periods[1]=PERIOD_M2;
   periods[2]=PERIOD_M3;
   periods[3]=PERIOD_M4;
   periods[4]=PERIOD_M5;
   periods[5]=PERIOD_M6;
   periods[6]=PERIOD_M10;
   periods[7]=PERIOD_M12;
   periods[8]=PERIOD_M15;
   periods[9]=PERIOD_M20;
   periods[10]=PERIOD_M30;
   periods[11]=PERIOD_H1;
   periods[12]=PERIOD_H2;
   periods[13]=PERIOD_H3;
   periods[14]=PERIOD_H4;
   periods[15]=PERIOD_H6;
   periods[16]=PERIOD_H8;
   periods[17]=PERIOD_H12;
   periods[18]=PERIOD_D1;
   periods[19]=PERIOD_W1;
   periods[20]=PERIOD_MN1;
  }
//+------------------------------------------------------------------+
//| возвращает true, если нажат управляющий контрол                  |
//+------------------------------------------------------------------+
bool CChart::IsChartControlEvent(string control_name)
  {
   bool res=false;
   for(int i=0;i<6;i++)
     {
      if(m_controls[i].GetControlName()==control_name)return(true);
     }
   return(res);
  }
//+------------------------------------------------------------------+
//|  удаление графических объектов класса                            |
//+------------------------------------------------------------------+
void CChart::DeleteChart()
  {
   if(ObjectFind(0,m_chart_name)>=0) ObjectDelete(0,m_chart_name);
   for(int i=0;i<6;i++)
     {
      m_controls[i].DeleteControl();
     }
  }
//+------------------------------------------------------------------+
//|  создание объекта с указанными параметрами                       |
//+------------------------------------------------------------------+
void CChart::CreateChart(int l,int t,int w,int h,string s,string name)
  {
   for(int p=0;p<21;p++)
     {
      int tempPer=(int)ChartPeriod(0);
      if((int)periods[p]==(int)ChartPeriod(0))
        {
         m_period_counter=p;
         break;
        }
     }
   m_width=w;
   m_height=h;
   m_chart_name=name;
   //Print("Попробуем создать объект Chart  с именем ",m_chart_name);
   if(ObjectFind(0,m_chart_name)<0)ObjectCreate(0,m_chart_name,OBJ_CHART,0,0,0,0,0);
   SetSymbolForChart(s);
   MoveChart(l,t);
   m_first_launch=false;
   ObjectSetInteger(0,m_chart_name,OBJPROP_XSIZE,m_width-m_control_width);
//Print("Установили ширину");
   ObjectSetInteger(0,m_chart_name,OBJPROP_YSIZE,m_height);
//Print("Установили высоту");
   ObjectSetInteger(0,m_chart_name,OBJPROP_SELECTABLE,0);
//Print("Установили OBJPROP_SELECTABL");
   int left_controls=l+w-m_control_width;
   int top_contols=t;
//Print("Начинаем размещать кнопки c X:Y=>",left_controls,":",top_contols);
   m_controls[0].CreateButton(left_controls,top_contols,
                              m_control_width,m_control_height,"Scale +",UP);
   m_controls[0].SetTextDetails(8,"Wingdings",White);
   m_controls[0].SetTextForControl(UP);

   m_controls[1].CreateButton(left_controls,top_contols+m_control_height,
                              m_control_width,m_control_height,"Show Price","P");
   m_controls[1].SetTextForControl("P");
   m_controls[1].SetTextDetails(10,"Arial",White);

   m_controls[2].CreateButton(left_controls,top_contols+2*m_control_height,
                              m_control_width,m_control_height,"Scale -",DOWN);
   m_controls[2].SetTextDetails(8,"Wingdings",White);
   m_controls[2].SetTextForControl(DOWN);

   m_controls[3].CreateButton(left_controls,top_contols+3*m_control_height,
                              m_control_width,m_control_height,"Time Frame Up",UP);
   m_controls[3].SetTextDetails(8,"Wingdings",White);
   m_controls[3].SetTextForControl(UP);

   m_controls[4].CreateButton(left_controls,top_contols+4*m_control_height,
                              m_control_width,m_control_height,"Show Time","T");
   m_controls[4].SetTextForControl("T");
   m_controls[4].SetTextDetails(10,"Arial",White);

   m_controls[5].CreateButton(left_controls,top_contols+5*m_control_height,
                              m_control_width,m_control_height,"Time Frame Down",DOWN);
   m_controls[5].SetTextDetails(8,"Wingdings",White);
   m_controls[5].SetTextForControl(DOWN);

   for(int i=0;i<6;i++)
     {
      if(i<3) m_controls[i].SetBGColor(CadetBlue);
      else m_controls[i].SetBGColor(SeaGreen);
     }
   ObjectSetInteger(0,"Show Price",OBJPROP_STATE,ObjectGetInteger(0,m_chart_name,OBJPROP_PRICE_SCALE));
   ObjectSetInteger(0,"Show Time",OBJPROP_STATE,ObjectGetInteger(0,m_chart_name,OBJPROP_DATE_SCALE));
  }
//+------------------------------------------------------------------+
//|  событие нажатия кнопок чарта                                    |
//+------------------------------------------------------------------+
void CChart::DoChartOperations(string name)
  {
//Print("Test DoChartOperations(),  name=",name);
   if(name=="Show Time")
     {
      bool showdates=ObjectGetInteger(0,name,OBJPROP_STATE);
      ObjectSetInteger(0,m_chart_name,OBJPROP_DATE_SCALE,showdates);
     }

   if(name=="Show Price")
     {
      bool showdates=ObjectGetInteger(0,name,OBJPROP_STATE);
      ObjectSetInteger(0,m_chart_name,OBJPROP_PRICE_SCALE,showdates);
     }

   if(name=="Scale +")
     {
      UpScaleChart();
      Sleep(100);
      ObjectSetInteger(0,name,OBJPROP_STATE,false);
     }

   if(name=="Scale -")
     {
      DownScaleChart();
      Sleep(100);
      ObjectSetInteger(0,name,OBJPROP_STATE,false);
     }

   if(name=="Time Frame Up")
     {
      if(m_period_counter<20)
        {
         m_period_counter++;
         ObjectSetInteger(0,m_chart_name,OBJPROP_PERIOD,periods[m_period_counter]);
        }
      Sleep(100);
      ObjectSetInteger(0,name,OBJPROP_STATE,false);
     }

   if(name=="Time Frame Down")
     {
      if(m_period_counter>0)
        {
         m_period_counter--;
         ObjectSetInteger(0,m_chart_name,OBJPROP_PERIOD,periods[m_period_counter]);
        }
      Sleep(100);
      ObjectSetInteger(0,name,OBJPROP_STATE,false);
     }

  }
//+------------------------------------------------------------------+
//| установить символ                                                |
//+------------------------------------------------------------------+
void CChart::SetSymbolForChart(string symbol)
  {
   m_symbol=symbol;
   ObjectSetString(0,m_chart_name,OBJPROP_SYMBOL,symbol);
  }
//+------------------------------------------------------------------+
//| переместить в указанные координаты                               |
//+------------------------------------------------------------------+
void CChart::MoveChart(int x,int y)
  {
   m_left+=x;
   m_top+=y;
   ObjectSetInteger(0,m_chart_name,OBJPROP_XDISTANCE,m_left);
   ObjectSetInteger(0,m_chart_name,OBJPROP_YDISTANCE,m_top);
   if(m_first_launch) return;
   for(int i=0;i<6;i++)
     {
      m_controls[i].MoveControlButton(x,y);
     }
  }
//+------------------------------------------------------------------+
//| увеличить график                                                 |
//+------------------------------------------------------------------+
void CChart::UpScaleChart()
  {
//Print(__FUNCTION__,"m_scaling =",m_scaling);
   if(m_scaling<5)
     {
      m_scaling++;
      Print(__FUNCTION__,"Установим масштаб графика =",m_scaling);
      bool changed=ObjectSetInteger(0,m_chart_name,OBJPROP_CHART_SCALE,m_scaling);
      if(!changed)
        {
         Print(__FUNCTION__,"Не удалось увеличить масштаб графика. Ошибка="+(string)GetLastError());
        }
      else
        {
         Print("Масштаб графика =",ObjectGetInteger(0,m_chart_name,OBJPROP_CHART_SCALE));
        }
     }
  }
//+------------------------------------------------------------------+
//| уменьшить график                                                 |
//+------------------------------------------------------------------+
void CChart::DownScaleChart()
  {
//Print(__FUNCTION__,"m_scaling =",m_scaling);
   if(m_scaling>0)
     {
      m_scaling--;
      Print(__FUNCTION__,"Установим масштаб графика =",m_scaling);
      bool changed=ObjectSetInteger(0,m_chart_name,OBJPROP_CHART_SCALE,m_scaling);
      if(!changed)
        {
         Print(__FUNCTION__,"Не удалось уменьшить масштаб графика. Ошибка="+(string)GetLastError());
        }
      else
        {
         Print("Масштаб графика =",ObjectGetInteger(0,m_chart_name,OBJPROP_CHART_SCALE));
        }
     }
  }
//+------------------------------------------------------------------+
