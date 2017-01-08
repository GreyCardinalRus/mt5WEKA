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
#include <GC\CurrPairs.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   CPInit();
   WriteFile(1,6,2011); //
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
   FileName="D:\\fann\\"+Symbol()+"_"+fTimeFrameName(_Period)+"_"+IntegerToString(Month,2,'0')+".csv";
//StringToCharArray(File_Name,FileName);

//FileName=Symbol()+"_"+fTimeFrameName(_Period)+"_"+IntegerToString(Month,2,'0')+".csv";
   Comment(FileName);
   MqlRates rates[];
   MqlDateTime tm;
   ArraySetAsSeries(rates,true);

   string   start_time=""+(string)Year+"."+IntegerToString(Month,2,'0')+"."+IntegerToString(Day,2,'0');  // � ����� ����

   ResetLastError();

   FileHandle=FileOpen(FileName,FILE_WRITE|FILE_ANSI|FILE_CSV,',');
   if(FileHandle!=INVALID_HANDLE)
     {
      Print(FileName);
      FileWrite(FileHandle,// ���������� � ����
                "Symbol",
                "spread",// ���������� ������, ��������� � 1 ������ 1970 ����
                "Open",                      // Open
                "High",                      // High
                "Low",                       // Low
                "Close",                     // Close
                "year",                            // ���
                "mon",                             // �����
                "day",                             // ����
                "hour",                            // ���
                "min",                             // ������
                "day_of_week",// ���������� ����� ��� � ���� (1 ������ - ��� 0-�� ���� � ����)
                "HmL");
      for(int SymbolIdx=0; SymbolIdx<MaxSymbols;SymbolIdx++)
        {
         copied=CopyRates(SymbolsArray[SymbolIdx],_Period,StringToTime(start_time),TimeCurrent(),rates);
         if(copied>0)
           {
            for(int i=copied-1;i>=0;i--)
              {
               TimeToStruct(rates[i].time,tm);
               if(tm.day>=Day && tm.mon==Month && tm.year==Year) // �������� ���������� ��������� ������
                  FileWrite(FileHandle,// ���������� � ����
                            SymbolsArray[SymbolIdx],
                            rates[i].spread,
                            rates[i].open,                      // Open
                            rates[i].high,                      // High
                            rates[i].low,                       // Low
                            rates[i].close,                     // Close
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
