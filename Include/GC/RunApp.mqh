//+------------------------------------------------------------------+
//|                                                       RunApp.mqh |
//|                                                     GreyCardinal |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "GreyCardinal"
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
 #import "MT5_Run_APP_x64.dll"
   int         RunAppRun(string cmd,    // ����� ������� ������ ����������
                string ret     // ����� ���������
                );
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
 #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
