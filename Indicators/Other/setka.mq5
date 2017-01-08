//+------------------------------------------------------------------+
//|                                                        Setka.mq5 |
//|                                          Copyright �������� �.�. |
//|                           https://login.mql5.com/ru/users/Prival |
//+------------------------------------------------------------------+
#property copyright "�������� �.�."
#property link      "https://login.mql5.com/ru/users/Prival"
#property version   "3.02"
#property indicator_chart_window

//--- input parameters
input int   Step=250;         // ��� ����� � ������� �� ���������
input int   Figure=1000;      // ��� ������

// ���� ������������ �����
color new_hour=DimGray;       // ����� ���
color new_day =Blue;          // ����� ����
color new_week=DeepPink;      // ����� ������
color new_mon =Yellow;        // ����� �����

// ���� �������������� �����
color new_Hfigure=RoyalBlue;  // ����� ������
color new_Hline=DimGray;      // ����� �����

//
double minChartPrice, minChartPrice_old;
double maxChartPrice, maxChartPrice_old;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
  EventSetTimer(25); 
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  EventKillTimer();
  ObjectsDeleteAll(0,0,OBJ_HLINE);   // ������� ��� �������������� �����
  ObjectsDeleteAll(0,0,OBJ_VLINE);   // ������� ��� ������������ �����
  }   
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      // ������ ������� ���������
                 const int prev_calculated,  // ���������� ����� �� ���������� ������
                 const datetime& time[],     // Time
                 const double& open[],       // Open
                 const double& high[],       // High
                 const double& low[],        // Low
                 const double& close[],      // Close
                 const long& tick_volume[],  // Tick Volume
                 const long& volume[],       // Real Volume
                 const int& spread[])        // Spread
  {
//---
  if(rates_total<0) return(0);  // ������ �� ������� � ������ �� ������ �� �������

  ArraySetAsSeries(time,true);
  MqlDateTime str;
  color  ColorLine;

  // **************** ������������ ����� ************************************************
  string name_line="";     // ��� �����
  int    start,            // ����� ������ ���������
         counter_line,     // ������� �����
         kol_Bars,         // ���������� ������� �����
         kol_Bars_old;     // ������ ����������
         
  kol_Bars=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR);

  if(prev_calculated==0 || kol_Bars>kol_Bars_old)   {
     start=kol_Bars-1;                    // ����� ������ ��������� = kol_Bars
     kol_Bars_old=kol_Bars;               // ����������
     ObjectsDeleteAll(0,0,OBJ_VLINE);     // ������� ��� ������������ �����
     // ������������� ����� ���������� ����
     if(_Period<PERIOD_M30) {
       TimeToStruct(TimeCurrent() ,str);
       if(ObjectFind(0,"VLine_0")<0) SetVLine("VLine_0", TimeCurrent()+60*(60-str.min)+(60-str.sec), new_hour);
     }
  }
  else start=rates_total-prev_calculated;

  for(int i=start;i>0;i--)  {
      ColorLine=0;
      if(isNewBar_i(time[i],PERIOD_H1) && (_Period<PERIOD_M30)) ColorLine=new_hour; 
      if(isNewBar_i(time[i],PERIOD_D1) && (_Period<PERIOD_H4 )) ColorLine=new_day; 
      if(isNewBar_i(time[i],PERIOD_W1) && (_Period<PERIOD_D1 )) ColorLine=new_week; 
      if(isNewBar_i(time[i],PERIOD_MN1)&& (_Period<PERIOD_MN1)) ColorLine=new_mon; 
      if(ColorLine!=0) {
         // ���������� ��� ����� 12:00
         counter_line++;
         TimeToStruct(time[i] ,str);  
         StringConcatenate(name_line,IntegerToString(str.hour,2,'0'),":",IntegerToString(str.min,2,'0'),"_N",counter_line);
         // ������������� �����
         SetVLine(name_line, time[i], ColorLine);   
      } // end if(ColorLine!=0) 
  }// end for(int i=start;i>=0;i--)
  //--- return value of prev_calculated for next call
   return(rates_total);
  }
//+----------------------------------------------------------------------------+
//|  �������� : ��������� ������� OBJ_VLINE ������������ �����                 |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    nm - ��� �����                                                          |
//|    t1 - �����                                                              |
//|    cl - ���� �����                                                         |
//+----------------------------------------------------------------------------+
void SetVLine(string nm="", datetime t1=0, color cl=Red)
  {
  ResetLastError();
  if (t1<=0) return; 
  if (ObjectFind(0,nm)<0) ObjectCreate(0, nm, OBJ_VLINE, 0, t1, 2);
  else Print("������ LastError=",_LastError," �������� SetVLine ",nm," t=",t1);
  
  ObjectSetInteger(0, nm, OBJPROP_COLOR, cl);
  ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_DOT);
  ObjectSetInteger(0, nm, OBJPROP_WIDTH, 1);          // ������� �����  
  ObjectSetInteger(0, nm, OBJPROP_BACK,  true);       // �������� ��� ���
  ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false); // ��������� ��������� ������� ������ 
  }
//+----------------------------------------------------------------------------+
//|  �������� : ��������� ������� OBJ_HLINE �������������� �����               |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    nm - ��� �����                                                          |
//|    p1 - ������� �������                                                    |
//|    cl - ���� �����                                                         |
//+----------------------------------------------------------------------------+
void SetHLine(string nm="", double p1=0, color cl=Red)
   {
   ResetLastError();
   if (ObjectFind(0,nm)<0) ObjectCreate(0, nm, OBJ_HLINE, 0, 0, p1); 
   else Print("������ LastError=",_LastError, " �������� SetHLine ",nm," p1=",p1);
   
   ObjectSetInteger(0, nm, OBJPROP_COLOR, cl);         // ����  
   ObjectSetInteger(0, nm, OBJPROP_STYLE, STYLE_DOT);  // �����
   ObjectSetInteger(0, nm, OBJPROP_WIDTH, 1);          // ������� �����  
   ObjectSetInteger(0, nm, OBJPROP_SELECTABLE, false); // ��������� ��������� ������� ������
   }
//+----------------------------------------------------------------------------+
//|  �������� : ��������� �������������� �����                                 |
//+----------------------------------------------------------------------------+
void Ris_H_Line(double max, double min)
   {
   double Uroven=0.0;      // ������� ������ �������������� �����
   int    rez,             // ���������� ������ ��� ���
          counter_line=0,  // ������� �����
          i=0;             // ������� ��������

   while(Uroven<=max) 
     {
     i++;
     Uroven=i*Step*_Point;
     if(Uroven>=min) {
      counter_line++;
      rez=(int)MathMod(Uroven*MathPow(10,_Digits),Figure); // �������� ��� �������
      if(rez==0) {
        // ����� ������ ���������� �� W1
        if(_Period<PERIOD_W1 ) SetHLine("HLine_"+counter_line, Uroven, new_Hfigure);
      }
      else   
        // ������������� ������� ���������� �� M30 
        if(_Period<PERIOD_M30) SetHLine("HLine_"+counter_line, Uroven, new_Hline);     
     }// end if(Uroven>=Min)
   }// end while (Uroven<=Max)
  }//end ��������� �������������� �����
//+------------------------------------------------------------------+
//| ���������� true ���� ����� ���, ����� false                      |
//+------------------------------------------------------------------+
bool isNewBar_i(datetime date, ENUM_TIMEFRAMES timeFrame)
  {
//----
   static datetime old_Times[21];// ������ ��� �������� ������ �������� �������
   bool res=false;               // ���������� ���������� �������  
   int  pos;                     // ����� ������ ������� old_Times[]     
   datetime new_Time[1];         // ����� ������ ����

   switch(timeFrame)
     {
      case PERIOD_M1:  pos= 0; break;
      case PERIOD_M2:  pos= 1; break;
      case PERIOD_M3:  pos= 2; break;
      case PERIOD_M4:  pos= 3; break;
      case PERIOD_M5:  pos= 4; break;
      case PERIOD_M6:  pos= 5; break;
      case PERIOD_M10: pos= 6; break;
      case PERIOD_M12: pos= 7; break;
      case PERIOD_M15: pos= 8; break;
      case PERIOD_M20: pos= 9; break;
      case PERIOD_M30: pos=10; break;
      case PERIOD_H1:  pos=11; break;
      case PERIOD_H2:  pos=12; break;
      case PERIOD_H3:  pos=13; break;
      case PERIOD_H4:  pos=14; break;
      case PERIOD_H6:  pos=15; break;
      case PERIOD_H8:  pos=16; break;
      case PERIOD_H12: pos=17; break;
      case PERIOD_D1:  pos=18; break;
      case PERIOD_W1:  pos=19; break;
      case PERIOD_MN1: pos=20; break;
     }
   // ��������� ����� �������������� �� ������� ���� � ������ new_Time[0]   
   int copied=CopyTime(_Symbol,timeFrame,date,1,new_Time);

   if(copied>0) // ��� ��. ������ �����������
      {
      if(old_Times[pos]!=new_Time[0])       // ���� ������ ����� ���� �� ����� ������
         {
         if(old_Times[pos]!=0) res=true;    // ���� ��� �� ������ ������, �� ������ = ����� ���
         old_Times[pos]=new_Time[0];        // ���������� ����� ����
         }  
      }
//---- 
   return(res);
  }
//+------------------------------------------------------------------+
//| ��������� ������� �� ���������                                   |
//+------------------------------------------------------------------+
 void OnChartEvent(const int          id,
                   const long    &lparam,
                   const double  &dparam,
                   const string  &sparam )
{
  // ������ �������������� ����� ���� ������� ���� ����� ������ 
  minChartPrice=NormalizeDouble(ChartGetDouble(ChartID(),CHART_PRICE_MIN,0),_Digits);
  maxChartPrice=NormalizeDouble(ChartGetDouble(ChartID(),CHART_PRICE_MAX,0),_Digits);

  if(minChartPrice<minChartPrice_old || maxChartPrice>maxChartPrice_old) {
  
      minChartPrice_old=minChartPrice-Step*_Point;       // ���������� ������� + - ��� �.�. ������� ������
      maxChartPrice_old=maxChartPrice+Step*_Point;       // 
      ObjectsDeleteAll(0,0,OBJ_HLINE);                   // ������� ��� �������������� �����
      Ris_H_Line(maxChartPrice_old, minChartPrice_old);  // ������
      ChartRedraw( );
  }
return;
}
//+------------------------------------------------------------------+
//| ������.                                                          |
//+------------------------------------------------------------------+
void OnTimer()
   {
   // �������� �� ������� ��-�� ��������� ������� ����� 
   if(_Period<PERIOD_M30) {
      MqlDateTime str;
      // ������� ������ ����� ���������� ����
      if (ObjectFind(0,"VLine_0")>=0) ObjectDelete(0, "VLine_0"); 
      // ������������� ����� ����� ���������� ����
      TimeToStruct(TimeCurrent() ,str);
      if(ObjectFind(0,"VLine_0")<0) SetVLine("VLine_0", TimeCurrent()+60*(60-str.min)+(60-str.sec), new_hour);
   } // end if(_Period<PERIOD_M30)

   // ������ �� ���������������� �������� ������
   // ����� ������� isNewBar_i �� �������� ���������� ��������   
   datetime var[2];
   CopyTime(_Symbol,PERIOD_M5 ,0,2,var);
   CopyTime(_Symbol,PERIOD_M15,0,2,var);
   CopyTime(_Symbol,PERIOD_M30,0,2,var);
   CopyTime(_Symbol,PERIOD_H1 ,0,2,var);
   CopyTime(_Symbol,PERIOD_H4 ,0,2,var);
   CopyTime(_Symbol,PERIOD_D1 ,0,2,var);
   CopyTime(_Symbol,PERIOD_W1 ,0,2,var);
   CopyTime(_Symbol,PERIOD_MN1,0,2,var);
   return;
   }
