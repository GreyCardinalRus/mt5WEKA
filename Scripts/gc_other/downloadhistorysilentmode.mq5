//+------------------------------------------------------------------+
//|                                    downloadhistorysilentmode.mq5 |
//|                                                    2011, etrader |
//|                                             http://efftrading.ru |
//+------------------------------------------------------------------+
#property copyright "2011, etrader"
#property link      "http://efftrading.ru"
#property version   "1.00"
#property description "Пример загрузки истории по символу в режиме 'silent'"


#include "CDownLoadHistory.mqh"




void OnStart(){

  CDownLoadHistory downloader; 
  downloader.Create( Symbol() );
  if( downloader.Execute( )<0){
    Print("Ошибка загрузки исторических данных для "+Symbol()+": ", downloader.ErrorDescription( downloader.LastError() ));
    return;
  }
  Print("Загрузка для "+Symbol()+" выполнена успешно");
}  


//+------------------------------------------------------------------+
