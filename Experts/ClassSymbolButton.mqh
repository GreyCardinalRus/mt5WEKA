//+------------------------------------------------------------------+
//|                                                CSymbolButton.mqh |
//|                      Copyright � 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//+------------------------------------------------------------------+
//|  ����� ��� �������� ������ �������                               |
//+------------------------------------------------------------------+
class CSymbolButton
  {
private:
   int               m_top;            // ���������� Y ������ �������� ����
   int               m_left;           // ���������� X ������ �������� ����
   double            m_height;         // ������ ������
   double            m_width;          // ������ ������
   color             m_txt_col;        // ���� ������
   color             m_bg_col;         // ���� ����
   int               m_ind_handle;     // ��������� �� ��������� ��� ���� ������
   ENUM_TIMEFRAMES   m_timeframe;      // ������, ��� �������� ��������� ���������
   string            m_symbol_name;    // ��� �������, ��� �������� ��������� ������
   double            m_indicator_value;// �������� ���������� �� ��������� ����
public:
                     CSymbolButton();
                    ~CSymbolButton();
   string            m_button_name;    // ���������� ��� ������
   bool              CreateSymbolButton(double top,double left,double height,double width,
                                        string buttonID,color TextColor,color BGColor);// constructor
   bool              DeleteSymbolButton();
   void              MoveButton(int x_shift,int y_shift);
   color             GetBGColor(){return(m_bg_col);};
   void              SetBGColor(color bg_color);
   string            GetSymbolName(){return(m_symbol_name);};
   void              SetSymbolName(string s){m_symbol_name=s;};
   void              SetIndicatorvalue(double v){m_indicator_value=v;}
   double            GetIndicatorvalue() { return m_indicator_value;}
   int               GetIndicatorHandle(){ return m_ind_handle; }
   ENUM_TIMEFRAMES   GetTimeframe(){return m_timeframe;}
   void              UpdateIndicator(ENUM_TIMEFRAMES tf);
  };
//+------------------------------------------------------------------+
//| ����������� �� ���������                                         |
//+------------------------------------------------------------------+
CSymbolButton::CSymbolButton(void)
  {
//--- ��������� ������ �������� ��� ����� �������
   m_symbol_name="";
//--- ��������� ������ �������� ��� ���������� � ������ ����������
   m_timeframe  =WRONG_VALUE;
   m_ind_handle =-1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSymbolButton::~CSymbolButton()
  {
   if(m_ind_handle>=0)
      IndicatorRelease(m_ind_handle);
  }
//+------------------------------------------------------------------+
//|  �������� �������� ����������                                    | 
//+------------------------------------------------------------------+
void CSymbolButton::UpdateIndicator(ENUM_TIMEFRAMES tf)
  {
   if(tf!=m_timeframe)
     {
      if(m_ind_handle>=0)
        {
         ///##exec_break
         IndicatorRelease(m_ind_handle);
        }
      m_ind_handle=iStochastic(m_symbol_name,tf,5,3,3,MODE_SMA,STO_LOWHIGH);
      m_timeframe =tf;
     }
  }
//+------------------------------------------------------------------+
//| �������� ������ �������                                          |
//+------------------------------------------------------------------+
bool CSymbolButton::DeleteSymbolButton()
  {
   if(ObjectFind(0,m_button_name)>=0)
     {
      //Print("������� ������ � ������ ",m_button_name);
      if(!ObjectDelete(0,m_button_name))
        {
         Print("�� ������� ������� ������ � ������ ",m_button_name,"! ������ #",GetLastError());
        }
      else
        {
         //ChartRedraw(0);
        }
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| setup object of Class CSymbolButton                               |
//+------------------------------------------------------------------+
bool CSymbolButton::CreateSymbolButton(double top,double left,double height,double width,
                                       string buttonID,color TextColor,color BGColor)
  {
   bool res=false;
//---
   if(ObjectFind(0,buttonID)<0)
     {
      m_top=(int)top;
      m_left=(int)left;
      ObjectCreate(ChartID(),buttonID,OBJ_BUTTON,0,0,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,TextColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,BGColor);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,m_left);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,m_top);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,(int)width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,(int)height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,"Arial");
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonID);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,10);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      m_button_name=buttonID;
      SetSymbolName(buttonID);
      //ChartRedraw(ChartID());
     }
//  else
//    {
//    }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| ������������� ���� ���� ������ �������                           |
//+------------------------------------------------------------------+
void CSymbolButton::SetBGColor(color bg_color)
  {
   ObjectSetInteger(0,m_button_name,OBJPROP_BGCOLOR,bg_color);
  }
//+------------------------------------------------------------------+
//| �������� ������ ������� �� ��������� ��������                    |
//+------------------------------------------------------------------+
void CSymbolButton::MoveButton(int x_shift,int y_shift)
  {
   m_top+=y_shift;
   m_left+=x_shift;
   ObjectSetInteger(0,m_button_name,OBJPROP_XDISTANCE,m_left);
   ObjectSetInteger(0,m_button_name,OBJPROP_YDISTANCE,m_top);
  }
//+------------------------------------------------------------------+
