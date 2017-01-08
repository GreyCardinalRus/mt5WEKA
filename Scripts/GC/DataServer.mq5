#include <Indicators/Indicator.mqh>
#import "MT5DataServerDll.dll"
  bool StartServer (string host, string port);
  bool StopServer ();
  int  GetQuery (string& s);
  int  AddReplay (string s);
#import

void Init() {
  bool a=StartServer("localhost","8765");
  if (a) Print("Server started");
//  EventSetTimer(1);
  ObjectCreate(0,"RCV",OBJ_LABEL,0,0,0,0,0);
  ObjectSetInteger(0,"RCV",OBJPROP_XDISTANCE,10);
  ObjectSetInteger(0,"RCV",OBJPROP_YDISTANCE,10);
  ObjectCreate(0,"SND",OBJ_LABEL,0,0,0,0,0);
  ObjectSetInteger(0,"SND",OBJPROP_XDISTANCE,10);
  ObjectSetInteger(0,"SND",OBJPROP_YDISTANCE,30);
}

void Deinit(const int reason) {
//  EventKillTimer();
  bool a=StopServer();
  if (a) Print("Server stoped");
}
/*
void OnQuery(const string query) {
//  Print("Rcv:#"+query+"#");
  ObjectSetString(0,"RCV",OBJPROP_TEXT,query);
  uchar buf[255];
  string s=query+" 1.2345";
  StringToCharArray(s,buf,0,StringLen(s));
//  Print("Snd:#"+s+"#");
  ObjectSetString(0,"SND",OBJPROP_TEXT,s);
  int r=PutData(buf,StringLen(s));
  if (r!=StringLen(s)) Print ("Err send fail: "+s);
  ChartRedraw();
}
*/
string GetReplay(string s) {
  string r="ERR";
  int L=StringLen(s);
  string P[];
  int Pi=0;
  ArrayResize(P,1);
  StringInit(P[0],L,0);
  for (int i=0; i<L; i++) {
    int ch=StringGetCharacter(s,i);
    if (ch=='(' || ch==',') {
      Pi+=1;
      ArrayResize(P,Pi+1);
      StringInit(P[Pi],L,0);
    } else if (ch != ')') {
      StringSetCharacter(P[Pi],StringLen(P[Pi]),ch);
    }
  }
  if (P[0]=="HELP") {
    r="HELP - show this help\r\n"+
      "GETRATES(SYMBOL,TIMEFRAME,DATE_FROM,DATE_TO) - get Date,Open,High,Low,Close,Volume";
  }
  if (P[0]=="GETRATES") {
    MqlRates rates[];
    string sym=P[1];
    ENUM_TIMEFRAMES tf=GetTimeFrame(P[2]);
    datetime dt1=StringToTime(P[3]);
    datetime dt2=StringToTime(P[4]);
    if (CheckLoadHistory(sym,tf,dt1)>0) {
      int cnt=CopyRates(sym,tf,dt1,dt2,rates);
    }
    long d=SymbolInfoInteger(sym,SYMBOL_DIGITS);
    r="";
    for (int i=0; i<ArraySize(rates)-1; i++) {
      StringAdd(r,TimeToString(rates[i].time,TIME_DATE|TIME_MINUTES));
      StringAdd(r,",");
      StringAdd(r,DoubleToString(rates[i].open,d));
      StringAdd(r,",");
      StringAdd(r,DoubleToString(rates[i].high,d));
      StringAdd(r,",");
      StringAdd(r,DoubleToString(rates[i].low,d));
      StringAdd(r,",");
      StringAdd(r,DoubleToString(rates[i].close,d));
      StringAdd(r,",");
      StringAdd(r,IntegerToString(rates[i].tick_volume));
      StringAdd(r,";\r\n");
    }
    StringAdd(r,"OK");
  }
  if (P[0]=="GETIND") {
    string sym=P[1];
    ENUM_TIMEFRAMES tf=GetTimeFrame(P[2]);
    ENUM_INDICATOR i_type=GetIndicatorType(P[3]);
    long buf=StringToInteger(P[4]);
    datetime dt1=StringToTime(P[5]);
    datetime dt2=StringToTime(P[6]);
    MqlParam params[];
    for(int i=7; i<ArraySize(P); i++) {
      ArrayResize(params,ArraySize(params)+1);
      SetIndParam(params[i-7],P[i]);
    }
   int h=IndicatorCreate(sym,tf,i_type,ArraySize(params),params);
   datetime dates[];
   double data[];
   r="";
   for (datetime d=dt1; d<dt2; d+=PeriodSeconds(tf)) {
     if (CopyBuffer(h,buf,d,1,data)>0) {
      if (CopyTime(sym,tf,d,1,dates)>0) {
        if (d==dates[0]) {
          StringAdd(r,TimeToString(dates[0]));
          StringAdd(r,",");
          StringAdd(r,DoubleToString(data[0]));
          StringAdd(r,";\r\n");
        }
      }
    }
   }
   StringAdd(r,"OK");
   IndicatorRelease(h);   
  }
        
  return(r);
}

void OnStart() 
{
  Init();
  string s;
  StringInit(s,1024,0);
  while (!IsStopped()) {
    GetQuery(s); 
    if (StringLen(s)>0) {
      AddReplay(GetReplay(s));
      StringInit(s,1024,0);
    }
    Sleep(1000);
  }
  Deinit(0);
}

int CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,datetime start_date)
  {
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

ENUM_TIMEFRAMES GetTimeFrame(string s) {
  if (s=="M1") return(PERIOD_M1); else
  if (s=="M5") return(PERIOD_M5); else
  if (s=="M15") return(PERIOD_M15); else
  if (s=="M30") return(PERIOD_M30); else
  if (s=="H1") return(PERIOD_H1); else
  if (s=="H4") return(PERIOD_H4); else
  if (s=="D1") return(PERIOD_D1); else
  if (s=="W1") return(PERIOD_W1); else
  if (s=="MN1") return(PERIOD_MN1); else
  return(PERIOD_CURRENT);
}

ENUM_DATATYPE GetDataType(string s) {
  if (s=="BOOL") return(TYPE_BOOL);
  if (s=="CHAR") return(TYPE_CHAR);
  if (s=="UCHAR") return(TYPE_UCHAR);
  if (s=="SHORT") return(TYPE_SHORT);
  if (s=="USHORT") return(TYPE_USHORT);
  if (s=="COLOR") return(TYPE_COLOR);
  if (s=="INT") return(TYPE_INT);
  if (s=="UINT") return(TYPE_UINT);
  if (s=="DATATIME") return(TYPE_DATETIME);
  if (s=="LONG") return(TYPE_LONG);
  if (s=="ULONG") return(TYPE_ULONG);
  if (s=="FLOAT") return(TYPE_FLOAT);
  if (s=="DOUBLE") return(TYPE_DOUBLE);
  if (s=="STRING") return(TYPE_STRING);
  return(TYPE_STRING);
}
 
int SetIndParam(MqlParam &param, string s) {
  int p=StringFind(s,":");
  string ts=StringSubstr(s,0,p);  
  string vs=StringSubstr(s,p+1);
  param.type=GetDataType(ts);
  if (param.type==TYPE_STRING) {
    param.string_value=vs;
    return(0);
  } else
  if (param.type==TYPE_DOUBLE || param.type==TYPE_FLOAT) {
    param.double_value=StringToDouble(vs);
    return (0);
  }
  else {
    if (StringSubstr(vs,0,StringLen("MODE_"))=="MODE_")  param.integer_value=GetMode(vs); else 
    if (StringSubstr(vs,0,StringLen("PRICE_"))=="PRICE_") param.integer_value=GetPrice(vs); 
    else param.integer_value=StringToInteger(vs);
    return(0);
  }
  return(-1);
}

ENUM_INDICATOR GetIndicatorType(string s) {
  if (s=="IND_AC") return(IND_AC);
  if (s=="IND_AD") return(IND_AD);
  if (s=="IND_ADX") return(IND_ADX);
  if (s=="IND_ADXW") return(IND_ADXW);
  if (s=="IND_ALLIGATOR") return(IND_ALLIGATOR);
  if (s=="IND_AMA") return(IND_AMA);
  if (s=="IND_AO") return(IND_AO);
  if (s=="IND_ATR") return(IND_ATR);
  if (s=="IND_BANDS") return(IND_BANDS);
  if (s=="IND_BEARS") return(IND_BEARS);
  if (s=="IND_BULLS") return(IND_BULLS);
  if (s=="IND_BWMFI") return(IND_BWMFI);
  if (s=="IND_CCI") return(IND_CCI);
  if (s=="IND_CHAIKIN") return(IND_CHAIKIN);
  if (s=="IND_CUSTOM") return(IND_CUSTOM);
  if (s=="IND_DEMA") return(IND_DEMA);
  if (s=="IND_DEMARKER") return(IND_DEMARKER);
  if (s=="IND_ENVELOPES") return(IND_ENVELOPES);
  if (s=="IND_FORCE") return(IND_FORCE);
  if (s=="IND_FRACTALS") return(IND_FRACTALS);
  if (s=="IND_FRAMA") return(IND_FRAMA);
  if (s=="IND_GATOR") return(IND_GATOR);
  if (s=="IND_ICHIMOKU") return(IND_ICHIMOKU);
  if (s=="IND_MA") return(IND_MA);
  if (s=="IND_MACD") return(IND_MACD);
  if (s=="IND_MFI") return(IND_MFI);
  if (s=="IND_MOMENTUM") return(IND_MOMENTUM);
  if (s=="IND_OBV") return(IND_OBV);
  if (s=="IND_OSMA") return(IND_OSMA);
  if (s=="IND_RSI") return(IND_RSI);
  if (s=="IND_RVI") return(IND_RVI);
  if (s=="IND_SAR") return(IND_SAR);
  if (s=="IND_STDDEV") return(IND_STDDEV);
  if (s=="IND_STOCHASTIC") return(IND_STOCHASTIC);
  if (s=="IND_TEMA") return(IND_TEMA);
  if (s=="IND_TRIX") return(IND_TRIX);
  if (s=="IND_VIDYA") return(IND_VIDYA);
  if (s=="IND_VOLUMES") return(IND_VOLUMES);
  if (s=="IND_WPR") return(IND_WPR);
   return(-1);
}

int GetMode(string s) {
  if (s=="MODE_SMA") return(MODE_SMA);
  if (s=="MODE_EMA") return(MODE_EMA);
  if (s=="MODE_SMMA") return(MODE_SMMA);
  if (s=="MODE_LWMA") return(MODE_LWMA);
  return(-1);
}

int GetPrice(string s) {
  if (s=="PRICE_CLOSE") return(PRICE_CLOSE);
  if (s=="PRICE_OPEN") return(PRICE_OPEN);
  if (s=="PRICE_HIGH") return(PRICE_HIGH);
  if (s=="PRICE_LOW") return(PRICE_LOW);
  if (s=="PRICE_MEDIAN") return(PRICE_MEDIAN);
  if (s=="PRICE_TYPICAL") return(PRICE_TYPICAL);
  if (s=="PRICE_WEIGHTED") return(PRICE_WEIGHTED);
  return(-1);
}
