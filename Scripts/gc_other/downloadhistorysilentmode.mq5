//+------------------------------------------------------------------+
//|                                    downloadhistorysilentmode.mq5 |
//|                                                    2011, etrader |
//|                                             http://efftrading.ru |
//+------------------------------------------------------------------+
#property copyright "2011, etrader"
#property link      "http://efftrading.ru"
#property version   "1.00"
#property description "������ �������� ������� �� ������� � ������ 'silent'"


#include "CDownLoadHistory.mqh"




void OnStart(){

  CDownLoadHistory downloader; 
  downloader.Create( Symbol() );
  if( downloader.Execute( )<0){
    Print("������ �������� ������������ ������ ��� "+Symbol()+": ", downloader.ErrorDescription( downloader.LastError() ));
    return;
  }
  Print("�������� ��� "+Symbol()+" ��������� �������");
}  


//+------------------------------------------------------------------+
