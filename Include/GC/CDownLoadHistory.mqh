//+-------------------------------------------------------------------------------------------------+
//|                                                                            CDownLoadHistory.mqh |
//|                                                                                   2011, etrader |
//|                                                                            http://efftrading.ru |
//+-------------------------------------------------------------------------------------------------+
#property copyright "2011, etrader"
#property link      "http://efftrading.ru"

#include "ClassProgressBar.mqh" // http://www.mql5.com/ru/articles/17

enum ENUM_DOWNLOADHISTORYMODE {      //�������� �������� �������
  DOWNLOADHISTORYMODE_CURRENTSYMBOL, //������� ������
  DOWNLOADHISTORYMODE_ALLSYMBOLS     //��� ������� �� ������ �����
};

//+-------------------------------------------------------------------------------------------------+
//| �����, ���������� ������� �������                                                               |
//+-------------------------------------------------------------------------------------------------+
class CDownLoadHistory{               
  private:
    int lasterror;                  // ���  ��������� ������
    bool isvisualmode;              // ���� �������� � ������ ������������
    string symbol;                  // ������, �� �������� ����������� �������� �������, ���� NULL - �� ��� �� ������ �����
    CProgressBar progresscurrent;   // ����������� ��� �������� ������������ �������
    CProgressBar progressall;       // ����������� ��� ������ �������� ��������
    
  public:
    void Create( string symbolpass=NULL, bool isvisualmodepass=false );  // ������������� ������� ������
    string ErrorDescription( int nerr );                                 // ��������� �������� ������
    int  Execute();                                                      // ��������� ��������
    int  ExecuteOneSymbol( string symbol);                               // ��������� �������� �� �������
    int  LastError(){return( lasterror );};                              // ��� ��������� ������
    //���������� �������� ������� �� ������� symbol �� ���� start_date
    int  CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,datetime start_date); 
}; 


//+-------------------------------------------------------------------------------------------------+
//| ��������� �������� �� ��������� �������                                                         |
//| ����:  sym - ������                                                                             |
//| �����: >=0 - �����, <0 - �������, ��� ������                                                    |
//+-------------------------------------------------------------------------------------------------+
int CDownLoadHistory::ExecuteOneSymbol( string sym ){
  
  MqlDateTime fromtime;
  TimeLocal( fromtime );
  //���� �������� ������� �� ����� ������� � �������� � ������ ����� ������ ������� �� �������
  
  datetime begserver=(datetime)SeriesInfoInteger( sym, PERIOD_D1, SERIES_SERVER_FIRSTDATE );
  MqlDateTime tm;
  TimeToStruct( begserver, tm );
  int res = 0;
  if( isvisualmode ){
    progresscurrent.Create(0,"��������",0,150,20);   // ����������� ��� �������� �������
    progresscurrent.Text("��������� ��� "+sym); 
    progresscurrent.Value( (int)0.00001 );
  
  }
 
  //���� �� ����� �������
  for( int i= fromtime.year ; i >= tm.year; i-- ){
    string sd = IntegerToString( i ) +".01.01";
    //�������� ������� �� ���� sd
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
//| ������������� ������� ������                                                                    |
//| ����: symbolpass - ������, �� �������� ������������ �������� �������, ���� NULL - �� ���        |
//|                    �� ������ �����                                                              |
//|       isvisualmodepass - ���� �������� � ������ ������������                                    |
//| �����: ���                                                                                      |
//+-------------------------------------------------------------------------------------------------+
void CDownLoadHistory::Create( string symbolpass=NULL, bool isvisualmodepass=false  ){
  symbol = symbolpass;
  isvisualmode = isvisualmodepass;
  lasterror = 0;
}

//+-------------------------------------------------------------------------------------------------+
//| ��������� �������� ������                                                                       |
//| ����:  nerr - ��� ������                                                                        |
//| �����: ��������� ��������                                                                       |                    
//+-------------------------------------------------------------------------------------------------+
string CDownLoadHistory::ErrorDescription( int nerr ){
  if(nerr >= 0 )return("��� ������");
  if(nerr == -1 )return("����������� ������");                        
  if(nerr == -2 )return("����������� ����� ������, ��� ����� ���������� �� �������"); 
  if(nerr == -3 )return("���������� ���� �������� �������������");  
  if(nerr == -4 )return("��������� �� ������ ��������� ����������� ������");
  if(nerr == -5 )return("�������� ���������� ��������"); 
  return( "����������� ������");
}



//+-------------------------------------------------------------------------------------------------+
//| ��������� ��������                                                                              |
//| ����: ���                                                                                       |       
//| �����: >=0 - �����, <0 - �������, ��� ������                                                    |
//+-------------------------------------------------------------------------------------------------+
int CDownLoadHistory::Execute(){

  
  if( symbol!= NULL)return( ExecuteOneSymbol( symbol ));  //� ������ �������� �������� ��� ������ �������
  
  int total =  SymbolsTotal(true);
  int res = 0;
  if( isvisualmode ){
    progressall.Create(0, "�������������",0,150,40);   // ����������� �������� ����� ������� ��������
    progressall.Text("�������� ����� ");  
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
//| ��������� ������� ������� �� ���� start_date, ���� ����������,                                  |
//| �� ���������� ������� ��������                                                                  |
//| ����  : symbol - ������ � ���������                                                             |
//|         period - ���������                                                                      |
//|         start_date - ���� �������� �������                                                      |
//| ����� : ��� ���������� ���������� �������� ���������                                            |
//|         ��. http://www.mql5.com/ru/docs/series/timeseries_access                                |
//| ����. : ���                                                                                     |
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

