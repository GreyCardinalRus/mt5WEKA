//+-------------------------------------------------------------------------------------------------+
//|                                                                            CDownLoadHistory.mqh |
//|                                                                                   2011, etrader |
//|                                                                            http://efftrading.ru |
//+-------------------------------------------------------------------------------------------------+
#property copyright "2011, etrader"
#property link      "http://efftrading.ru"

#include "ClassProgressBar.mqh" // http://www.mql5.com/ru/articles/17

enum ENUM_DOWNLOADHISTORYMODE {      //Варианты загрузки истории
  DOWNLOADHISTORYMODE_CURRENTSYMBOL, //Текущий символ
  DOWNLOADHISTORYMODE_ALLSYMBOLS     //Все символы из обзора рынка
};

//+-------------------------------------------------------------------------------------------------+
//| Класс, производит загрузу истории                                                               |
//+-------------------------------------------------------------------------------------------------+
class CDownLoadHistory{               
  private:
    int lasterror;                  // Код  последней ошибки
    bool isvisualmode;              // Флаг загрузки в режиме визуализации
    string symbol;                  // Символ, по которому произвоится загрузка истории, если NULL - то все из обзора рынка
    CProgressBar progresscurrent;   // Прогрессбар для текущего загружаемого символа
    CProgressBar progressall;       // Прогрессбар для общего процесса загрузки
    
  public:
    void Create( string symbolpass=NULL, bool isvisualmodepass=false );  // Инициализация объекта класса
    string ErrorDescription( int nerr );                                 // Текстовое описание ошибки
    int  Execute();                                                      // Выполнить загрузку
    int  ExecuteOneSymbol( string symbol);                               // Выполнить загрузку по символу
    int  LastError(){return( lasterror );};                              // Код последней ошибки
    //произвести загрузку истории по символу symbol на дату start_date
    int  CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,datetime start_date); 
}; 


//+-------------------------------------------------------------------------------------------------+
//| Выполнить загрузку во заданному символу                                                         |
//| Вход:  sym - символ                                                                             |
//| Выход: >=0 - успех, <0 - неудача, код ошибки                                                    |
//+-------------------------------------------------------------------------------------------------+
int CDownLoadHistory::ExecuteOneSymbol( string sym ){
  
  MqlDateTime fromtime;
  TimeLocal( fromtime );
  //цикл загрузки истории по годам начиная с текущего и кончая годом начала истории на сервере
  
  datetime begserver=(datetime)SeriesInfoInteger( sym, PERIOD_D1, SERIES_SERVER_FIRSTDATE );
  MqlDateTime tm;
  TimeToStruct( begserver, tm );
  int res = 0;
  if( isvisualmode ){
    progresscurrent.Create(0,"Загрузка",0,150,20);   // прогрессбар для текущего символа
    progresscurrent.Text("Выполнено для "+sym); 
    progresscurrent.Value( (int)0.00001 );
  
  }
 
  //цикл по годам истории
  for( int i= fromtime.year ; i >= tm.year; i-- ){
    string sd = IntegerToString( i ) +".01.01";
    //получить историю на дату sd
    res = CheckLoadHistory( sym, PERIOD_D1, StringToTime(sd) );
    if( res < 0 ){
      lasterror = res;
      return( res );
      break;
    }
    if( isvisualmode )progresscurrent.Value( (int)((0.+fromtime.year-i)/(-tm.year+fromtime.year)*100));
  }
  
  if( isvisualmode ){
    progresscurrent.Delete();
  }
  return( res );
} 

                    
//+-------------------------------------------------------------------------------------------------+
//| Инициализация объекта класса                                                                    |
//| Вход: symbolpass - символ, по которому производится загрузка истории, если NULL - то все        |
//|                    из обзора рынка                                                              |
//|       isvisualmodepass - флаг загрузки в режиме визуализации                                    |
//| Выход: нет                                                                                      |
//+-------------------------------------------------------------------------------------------------+
void CDownLoadHistory::Create( string symbolpass=NULL, bool isvisualmodepass=false  ){
  symbol = symbolpass;
  isvisualmode = isvisualmodepass;
  lasterror = 0;
}

//+-------------------------------------------------------------------------------------------------+
//| Текстовое описание ошибки                                                                       |
//| Вход:  nerr - код ошибки                                                                        |
//| Выход: текстовое описание                                                                       |                    
//+-------------------------------------------------------------------------------------------------+
string CDownLoadHistory::ErrorDescription( int nerr ){
  if(nerr >= 0 )return("Нет ошибки");
  if(nerr == -1 )return("Неизвестный символ");                        
  if(nerr == -2 )return("Запрошенных баров больше, чем можно отобразить на графике"); 
  if(nerr == -3 )return("Выполнение было прервано пользователем");  
  if(nerr == -4 )return("Индикатор не должен загружать собственные данные");
  if(nerr == -5 )return("Загрузка окончилась неудачей"); 
  return( "Неизвестная ошибка");
}



//+-------------------------------------------------------------------------------------------------+
//| Выполнить загрузку                                                                              |
//| Вход: нет                                                                                       |       
//| Выход: >=0 - успех, <0 - неудача, код ошибки                                                    |
//+-------------------------------------------------------------------------------------------------+
int CDownLoadHistory::Execute(){

  
  if( symbol!= NULL)return( ExecuteOneSymbol( symbol ));  //В случае варианта загрузки для одного символа
  
  int total =  SymbolsTotal(true);
  int res = 0;
  if( isvisualmode ){
    progressall.Create(0, "ЗагрузкаВсего",0,150,40);   // прогрессбар отражает общий процесс загрузки
    progressall.Text("Загрузка всего ");  
  }
  for( int i = 0; i<total; i++ ){
    string cursym = SymbolName(i,true);
    if( isvisualmode ){
    }
    res = ExecuteOneSymbol( cursym );
    if( res < 0){
      lasterror = res;
      return( res );
    }
    if(isvisualmode ){
      int prc = (int)(1.*i/total*100);
      progressall.Value( prc );
    }
  }
  return(res);
}  




//+-------------------------------------------------------------------------------------------------+
//| Проверить наличие истории на дату start_date, если остуствует,                                  |
//| то произвести попытку загрузки                                                                  |
//| Вход  : symbol - символ в терминале                                                             |
//|         period - таймфрейм                                                                      |
//|         start_date - дата проверки истории                                                      |
//| Выход : код результата выполнения операции подробнее                                            |
//|         см. http://www.mql5.com/ru/docs/series/timeseries_access                                |
//| Прим. : нет                                                                                     |
//+-------------------------------------------------------------------------------------------------+
int CDownLoadHistory::CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,datetime start_date){
   datetime first_date=0;
   datetime times[100];
//--- check symbol & period
   if(symbol==NULL || symbol=="") symbol=Symbol();
   if(period==PERIOD_CURRENT)     period=Period();
//--- check if symbol is selected in the MarketWatch
   if(!SymbolInfoInteger(symbol,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL) return(-1);
      SymbolSelect(symbol,true);
     }
//--- check if data is present
   SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date);
   if(first_date>0 && first_date<=start_date) return(1);
//--- don't ask for load of its own data if it is an indicator
   if(MQL5InfoInteger(MQL5_PROGRAM_TYPE)==PROGRAM_INDICATOR && Period()==period && Symbol()==symbol)
      return(-4);
//--- second attempt
   if(SeriesInfoInteger(symbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,first_date))
     {
      //--- there is loaded data to build timeseries
      if(first_date>0)
        {
         //--- force timeseries build
         CopyTime(symbol,period,first_date+PeriodSeconds(period),1,times);
         //--- check date
         if(SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date) return(2);
        }
     }
//--- max bars in chart from terminal options
   int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);
//--- load symbol history info
   datetime first_server_date=0;
   while(!SeriesInfoInteger(symbol,PERIOD_M1,SERIES_SERVER_FIRSTDATE,first_server_date) && !IsStopped())
      Sleep(5);
//--- fix start date for loading
   if(first_server_date>start_date) start_date=first_server_date;
   if(first_date>0 && first_date<first_server_date)
      Print("Warning: first server date",first_server_date,"for",symbol,"does not match to first series date",first_date);
//--- load data step by step
   
   
   int fail_cnt=0;
   while(!IsStopped())
     {
      //--- wait for timeseries build
      while(!SeriesInfoInteger(symbol,period,SERIES_SYNCRONIZED) && !IsStopped())
         Sleep(5);
      //--- ask for built bars
      int bars=Bars(symbol,period);
      if(bars>0)
        {
         if(bars>=max_bars) return(-2);
         //--- ask for first date
         if(SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date) return(0);
        }
      //--- copying of next part forces data loading
      int copied=CopyTime(symbol,period,bars,100,times);
      if(copied>0)
        {
         //--- check for data
         if(times[0]<=start_date)  return(0);
         if(bars+copied>=max_bars) return(-2);
         fail_cnt=0;
        }
      else
        {
         //--- no more than 100 failed attempts
         fail_cnt++;
         if(fail_cnt>=100) return(-5);
         Sleep(10);
        }
     }
//--- stopped
   return(-3);
  }

