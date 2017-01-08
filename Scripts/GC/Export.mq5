//+------------------------------------------------------------------+
//|                                                ExportHistory.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                           History_in_MathCAD.mq5 |
//|                                                    �������� �.�. |
//|                           https://login.mql5.com/ru/users/Prival |
//+------------------------------------------------------------------+
#property copyright "�������� �.�."
#property link      "https://login.mql5.com/ru/users/Prival"
#property version   "1.08"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input bool _EURUSD_=true;//Euro vs US Dollar
input bool _GBPUSD_=false;//Great Britain Pound vs US Dollar
input bool _USDCHF_=false;//US Dollar vs Swiss Franc
input bool _USDJPY_=false;//US Dollar vs Japanese Yen
input bool _USDCAD_=false;//US Dollar vs Canadian Dollar
input bool _AUDUSD_=false;//Australian Dollar vs US Dollar
input bool _NZDUSD_=false;//New Zealand Dollar vs US Dollar
input bool _USDSEK_=false;//US Dollar vs Sweden Kronor
// crosses
input bool _AUDNZD_=false;//Australian Dollar vs New Zealand Dollar
input bool _AUDCAD_=false;//Australian Dollar vs Canadian Dollar
input bool _AUDCHF_=false;//Australian Dollar vs Swiss Franc
input bool _AUDJPY_=false;//Australian Dollar vs Japanese Yen
input bool _CHFJPY_=false;//Swiss Frank vs Japanese Yen
input bool _EURGBP_=false;//Euro vs Great Britain Pound 
input bool _EURAUD_=false;//Euro vs Australian Dollar
input bool _EURCHF_=false;//Euro vs Swiss Franc
input bool _EURJPY_=false;//Euro vs Japanese Yen
input bool _EURNZD_=false;//Euro vs New Zealand Dollar
input bool _EURCAD_=false;//Euro vs Canadian Dollar
input bool _GBPCHF_=false;//Great Britain Pound vs Swiss Franc
input bool _GBPJPY_=false;//Great Britain Pound vs Japanese Yen
input bool _CADCHF_=false;//Canadian Dollar vs Swiss Franc
input int _Pers_=10;//Canadian Dollar vs Swiss Franc

string SymbolsArray[30];//={"","USDCHF","GBPUSD","EURUSD","USDJPY","AUDUSD","USDCAD","EURGBP","EURAUD","EURCHF","EURJPY","GBPJPY","GBPCHF"};

int MaxSymbols=0;
void OnStart()
  {

//---- 
  if(_EURUSD_) SymbolsArray[MaxSymbols++]="EURUSD";//Euro vs US Dollar
  if(_GBPUSD_) SymbolsArray[MaxSymbols++]="GBPUSD";//Euro vs US Dollar
  if(_AUDUSD_) SymbolsArray[MaxSymbols++]="AUDUSD";//Euro vs US Dollar
  if(_NZDUSD_) SymbolsArray[MaxSymbols++]="NZDUSD";//Euro vs US Dollar
  if(_USDCHF_) SymbolsArray[MaxSymbols++]="USDCHF";//Euro vs US Dollar
  if(_USDJPY_) SymbolsArray[MaxSymbols++]="USDJPY";//Euro vs US Dollar
  if(_USDCAD_) SymbolsArray[MaxSymbols++]="USDCAD";//Euro vs US Dollar
  if (_USDSEK_) SymbolsArray[MaxSymbols++]="USDSEK";//Euro vs US Dollar
  if (_AUDNZD_) SymbolsArray[MaxSymbols++]="AUDNZD";//Euro vs US Dollar
  if (_AUDCAD_) SymbolsArray[MaxSymbols++]="AUDCAD";//Euro vs US Dollar
  if (_AUDCHF_) SymbolsArray[MaxSymbols++]="AUDCHF";//Euro vs US Dollar
  if(_AUDJPY_) SymbolsArray[MaxSymbols++]="AUDJPY";//Euro vs US Dollar
  if(_CHFJPY_) SymbolsArray[MaxSymbols++]="CHFJPY";//Euro vs US Dollar
  if(_EURGBP_) SymbolsArray[MaxSymbols++]="EURGBP";//Euro vs US Dollar
  if (_EURAUD_) SymbolsArray[MaxSymbols++]="EURAUD";//Euro vs US Dollar
  if(_EURCHF_) SymbolsArray[MaxSymbols++]="EURCHF";//Euro vs US Dollar
  if(_EURJPY_) SymbolsArray[MaxSymbols++]="EURJPY";//Euro vs US Dollar
  if (_EURNZD_) SymbolsArray[MaxSymbols++]="EURNZD";//Euro vs US Dollar
  if (_EURCAD_) SymbolsArray[MaxSymbols++]="EURCAD";//Euro vs US Dollar
  if (_GBPCHF_) SymbolsArray[MaxSymbols++]="GBPCHF";//Euro vs US Dollar
  if (_GBPJPY_) SymbolsArray[MaxSymbols++]="GBPJPY";//Euro vs US Dollar
  if (_CADCHF_) SymbolsArray[MaxSymbols++]="CADCHF";//Euro vs US Dollar
  //WriteFile( 1,5,2010); // ����, �����, ��� 
   WriteFile( 1,6,2010); //
   return;// ������ ������� ���������
  }
//+------------------------------------------------------------------+

int WriteFile(int Day,int Month,int Year) 
  {

   // ���� Day<1 �� � ������ ������
   if(Day<1) Day=1;

   string FileName="";
   //uchar FileName[];
   int copied=0;
   int FileHandle=0;

   // ���������� ��� �����, (������+������+�����) EURUSD_M1_09.txt
   FileName="Forex.train";
   //StringToCharArray(File_Name,FileName);

   //FileName=Symbol()+"_"+fTimeFrameName(_Period)+"_"+IntegerToString(Month,2,'0')+".csv";
   Comment(FileName);
   MqlRates rates[];
   MqlDateTime tm;
   ArraySetAsSeries(rates,true);

   string   start_time=""+(string)Year+"."+IntegerToString(Month,2,'0')+"."+IntegerToString(Day,2,'0');  // � ����� ����

   ResetLastError();

   FileHandle=FileOpen(FileName,FILE_WRITE|FILE_ANSI|FILE_TXT,' ');
   if(FileHandle!=INVALID_HANDLE)
     {
      Print(FileName);
      //FileWrite(FileHandle,   // ���������� � ����
      //             "Symbol",
      //             "DateTime",    // ���������� ������, ��������� � 1 ������ 1970 ����
      //             "Open",                      // Open
      //             "High",                      // High
      //             "Low",                       // Low
      //             "Close",                     // Close
      //             "Tick_volume",               // Tick Volume
      //             "year",                            // ���
      //             "mon",                             // �����
      //             "day",                             // ����
      //             "hour",                            // ���
      //             "min",                             // ������
      //             "day_of_week",             // ���������� ����� ��� � ���� (1 ������ - ��� 0-�� ���� � ����)
      //             "HmL");                    
   for( int SymbolIdx=0; SymbolIdx<MaxSymbols;SymbolIdx++)
    {
     copied=CopyRates(SymbolsArray[SymbolIdx],_Period,StringToTime(start_time),TimeCurrent(),rates);
      FileWrite(FileHandle,   // ���������� � ����
                   copied, // 
                   5+(1+_Pers_)*MaxSymbols,    // ���������� ������, ��������� � 1 ������ 1970 ����
                   MaxSymbols);
      //             "Open",                      // Open
      //             "High",                      // High
      //             "Low",                       // Low
      //             "Close",                     // Close
      //             "Tick_volume",               // Tick Volume
      //             "year",                            // ���
      //             "mon",                             // �����
      //             "day",                             // ����
      //             "hour",                            // ���
      //             "min",                             // ������
      //             "day_of_week",             // ���������� ����� ��� � ���� (1 ������ - ��� 0-�� ���� � ����)
      //             "HmL");                    
     if(copied>0)
       {
        for(int i=copied-1;i>=0;i--)
         {
          TimeToStruct(rates[i].time,tm);
          if(tm.day>=Day && tm.mon==Month && tm.year==Year) // �������� ���������� ��������� ������
             FileWrite(FileHandle,   // ���������� � ����
                       SymbolsArray[SymbolIdx],
                       TimeToString(rates[i].time,TIME_MINUTES),    // ���������� ������, ��������� � 1 ������ 1970 ����
                       rates[i].open,                      // Open
                       rates[i].high,                      // High
                       rates[i].low,                       // Low
                        rates[i].close,                     // Close
                        rates[i].tick_volume,               // Tick Volume
                        tm.year,                            // ���
                        tm.mon,                             // �����
                        tm.day,                             // ����
                        tm.hour,                            // ���
                         tm.min,                            // ������
                         tm.day_of_week,                    // ���� ������ (0-�����������, 1-�����������)
                         rates[i].high-rates[i].low);       // 
           }
         }
       }
      //else Print("�� ������� �������� ������������ ������ �� �������",Symbol()," err=",GetLastError());
     }

   //������� ���� (��������� ���������/handle, ����� ���� ����� ���� 
   //������� ��� ������� �����������)
   FileClose(FileHandle);

   return(0);
  }
//+---------------------------------------------------------------------------------------------+
string fTimeFrameName(int arg)
  {
   int v;
   if(arg==0)
     {
      v=_Period;
     }
   else
     {
      v=arg;
     }
   switch(v)
     {
      case PERIOD_M1:    return("M1");
      case PERIOD_M2:    return("M2");
      case PERIOD_M3:    return("M3");
      case PERIOD_M4:    return("M4");
      case PERIOD_M5:    return("M5");
      case PERIOD_M6:    return("M6");
      case PERIOD_M10:   return("M10");
      case PERIOD_M12:   return("M12");
      case PERIOD_M15:   return("M15");
      case PERIOD_M20:   return("M20");
      case PERIOD_M30:   return("M30");
      case PERIOD_H1:    return("H1");
      case PERIOD_H2:    return("H2");
      case PERIOD_H3:    return("H3");
      case PERIOD_H4:    return("H4");
      case PERIOD_H6:    return("H6");
      case PERIOD_H8:    return("H8");
      case PERIOD_H12:   return("H12");
      case PERIOD_D1:    return("D1");
      case PERIOD_W1:    return("W1");
      case PERIOD_MN1:   return("MN1");
      default:    return("?");
     }
  } // end fTimeFrameName
