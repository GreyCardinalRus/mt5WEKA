//+------------------------------------------------------------------+
//|                                    downloadhistoryvisualmode.mq5 |
//|                                                    2011, etrader |
//|                                             http://efftrading.ru |
//+------------------------------------------------------------------+
#property copyright "2011, etrader"
#property link      "http://efftrading.ru"
#property version   "1.00"
#property description "Скрипт производит загрузку истории по текущему символу"
#property description " или по всем, доступным в обзоре рынка "
#property script_show_inputs


#include <CDownLoadHistory.mqh>




input ENUM_DOWNLOADHISTORYMODE DMode;  // Вариант загрузки истории
void OnStart(){

  CDownLoadHistory downloader; 
  downloader.Create( (DMode==DOWNLOADHISTORYMODE_CURRENTSYMBOL)?Symbol():NULL, true );
  if( downloader.Execute( )<0){
    Print("Ошибка загрузки исторических данных: ", downloader.ErrorDescription( downloader.LastError() ));
    return;
  }
  Print("Загрузка выполнена успешно");
}  


//+------------------------------------------------------------------+
