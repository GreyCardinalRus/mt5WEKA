//+------------------------------------------------------------------+
//|                                                         News.mq4 |
//|                                                                * |
//|                                                                * |
//+------------------------------------------------------------------+
#property  copyright "Andrew Bulagin"
#property  link      "andre9@ya.ru"
#property indicator_chart_window 
//#property indicator_buffers 0 

#include <InternetLib.mqh>

#import "kernel32.dll"
   int _lopen(string path, int of);
   int _lcreat(string path, int attrib);
   int _llseek(int handle, int offset, int origin);
   int _lread(int handle, int& buffer[], int bytes);
   int _lwrite(int handle, string buffer, int bytes);
   int _lclose(int handle);
#import

extern bool lines    = true;        // показывать на графике вертикальные линии в моменты выхода новостей
extern bool texts    = true;        // показывать текстовые надписи с описаниями новостей
extern bool comments = true;        // показывать список ближайших будущих и прошедших новостей
extern int old_news      = 10;      // количество предыдущих новостей в списке
extern int total_in_list = 30;      // всего новостей в списке

extern bool high     = true;        // показывать важные новости
extern bool medium   = true;        // показывать новости средней важности
extern bool low      = true;        // показывать новости малой важности

extern int update = 60;             // обновлять список новостей каждые 60 минут

extern bool eur = true;             // показывать новости для определенных валют
extern bool usd = true;
extern bool jpy = true;
extern bool gbp = true;
extern bool chf = true;
extern bool cad = false;
extern bool aud = false;
extern bool nzd = false;

extern color high_color    = Maroon;         // цвет важных новостей
extern color medium_color  = Sienna;         // цвет обычных новостей
extern color low_color     = DarkSlateGray;  // цвет незначительных новостей

extern bool russian = true;         // использовать файл перевода для руссификации новостей

extern int server_timezone = 1;     // часовой пояс сервера (центральная европа зимнее - GMT+1, летнее - GMT+2)
extern int show_timezone   = 3;     // показывать время для часового пояса (Москва - GMT+3, летнее - GMT+4)

extern bool alerts = false;         // предупреждать о выходе новостей звуковыми сигналами
extern int  alert_before = 5;       // предупреждать за 5 минут до выхода новостей
extern int  alert_every  = 30;      // звуковые сигналы каждые 30 секунд

// -----------------------------------------------------------------------------------------------------------------------------
int TotalNews = 0;
string News[1000][10];
datetime LastUpdate = 0;
int NextNewsLine = 0;
int LastAlert = 0;
string Translate[1000][2];
int TotalTranslate = 0;

// -----------------------------------------------------------------------------------------------------------------------------
int OnInit()
{ 
   if(russian) // подготовка шаблонов перевода новостей
   {
      int fhandle = FileOpen("translate.txt", FILE_READ);
      if(fhandle>0)
      {
         int i = 0;
         while(!FileIsEnding(fhandle))
         {
            string str = FileReadString(fhandle);
            if(str == "") break;
            Translate[i][0] = str;
            Translate[i][1] = FileReadString(fhandle);
            if(Translate[i][1] == "") Translate[i][1] = Translate[i][0];
            i++;
         }
         TotalTranslate = i;
         FileClose(fhandle);
      }
   }
   
   return(0); 
} 

// -----------------------------------------------------------------------------------------------------------------------------
int OnDeinit(const int reason) 
{ 
   for(int i=0; i<TotalNews; i++)
   {
      ObjectDelete(0,"News Line "+(string)i);
      ObjectDelete(0,"News Text "+(string)i);
   }   
   Comment("");
   
   return(0); 
} 

// -----------------------------------------------------------------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i;
   string str = "";
   
   datetime timec = TimeCurrent();
   if(timec >= LastUpdate+update*60)    // обновление списка новостей
   {
     Print(timec, TimeCurrent());
      for(int i=0; i<TotalNews; i++)
      {
         ObjectDelete(0,"News Line "+(string)i);
         ObjectDelete(0,"News Text "+(string)i);
      }   
      
      str = LoadNews(timec);
     
      Parce_News(str);
         
      datetime current = 0;
      for( i=0; i<TotalNews; i++ ) // создание линий и надписей новостей на графике
      {      
         int prev = (int)current;
         current = StringToTime(News[i][0]+" "+News[i][1]);
         color clr;
         if(News[i][5] == "Low")    clr = low_color;     else
         if(News[i][5] == "Medium") clr = medium_color;  else
         if(News[i][5] == "High")   clr = high_color;
         
         string text = "";
         if(News[i][8] != "" || News[i][7] != "") text = "[" + News[i][8] + ", " + News[i][7] + "]";
         if(News[i][6] != "") text = text + " " + News[i][6];
         
         if(lines && (prev != current))
         {
            ObjectCreate(0,"News Line "+(string)i, OBJ_VLINE, 0, current, 0);
            ObjectSetInteger(0,"News Line "+(string)i, OBJPROP_COLOR, clr);
            ObjectSetInteger(0,"News Line "+(string)i, OBJPROP_STYLE, STYLE_DASH);
            ObjectSetInteger(0,"News Line "+(string)i, OBJPROP_BACK, true);          
            //ObjectSetString(0,"News Line "+i, News[i][9] + " " + News[i][4] + " " + text, 8);         
            ObjectSetInteger(0,"News Line "+(string)i, OBJPROP_TIMEFRAMES, OBJ_PERIOD_M1+OBJ_PERIOD_M5+OBJ_PERIOD_M15+OBJ_PERIOD_M30+OBJ_PERIOD_H1+OBJ_PERIOD_H4);          
         }
         
         if (texts && (prev != current) )
         {
//????            ObjectCreate(0,"News Text "+i, OBJ_TEXT, 0, current, Close[0]  ); //WindowPriceMin()+(WindowPriceMax()-WindowPriceMin())*0.8
            ObjectSetInteger(0,"News Text "+(string)i, OBJPROP_COLOR, clr);
            ObjectSetDouble(0,"News Text "+(string)i, OBJPROP_ANGLE, 90);
            //ObjectSetString(0,"News Text "+i, News[i][9] + " " + News[i][4] + " " + text, 8);
            ObjectSetInteger(0,"News Text "+(string)i, OBJPROP_TIMEFRAMES, OBJ_PERIOD_M1+OBJ_PERIOD_M5+OBJ_PERIOD_M15+OBJ_PERIOD_M30+OBJ_PERIOD_H1+OBJ_PERIOD_H4);          
         }
         
         
      }                
      
      for(i=0; i<TotalNews; i++)
         if(StringToTime(News[i][0]+" "+News[i][1]) > timec) break;
      NextNewsLine = i;
      LastAlert = 0;

      if(comments) // создание списка новостей на графике
         Comment(News_List());   
   } // конец обновления списка новостей
   
   datetime next_time = StringToTime(News[NextNewsLine][0]+" "+News[NextNewsLine][1]);
   if(timec >= next_time) // вышла следующая новость
   {
      LastUpdate = timec - update*60 + 60;  // обновить список новостей через минуту после выхода очередной новости
      for(i=0; i<TotalNews; i++)
         if(StringToTime(News[i][0]+" "+News[i][1]) > timec) break;
      NextNewsLine = i;

      LastAlert = 0;
      if(comments)
         Comment(News_List());   
   }

   next_time = StringToTime(News[NextNewsLine][0]+" "+News[NextNewsLine][1]);
   if(timec >= next_time - alert_before*60) // скоро выйдет следующая новость
   {
      if(timec >= LastAlert + alert_every)
      {
         if(alerts) PlaySound("alert.wav");
        // Print("Следующая новость выйдет через " + (((next_time-time)-(next_time-time)%60)/60) + " минут(ы) " + ((next_time-time)%60) + " секунд(ы).");
         LastAlert = (int)timec;
      }
   }
   
   return(0);
}

// -----------------------------------------------------------------------------------------------------------------------------
string LoadNews(datetime curr_time)
{ 
  bool reload = false;
  int pos = 0, pos1 = 0;
  int file = 0, file2 = 0;
  string str = "", str2 = "";
  file = FileOpen("news.csv", FILE_BIN|FILE_READ);
  if(file!=-1)
  {
    FileClose(file); 
    str2 = ReadFile("news.csv");
        
    pos = StringFind(str2, "\n");
    int cache_time = (int)StringToTime(StringSubstr(str2, 0, pos));
    str2 = StringSubstr(str2, pos+2);

    if(cache_time<=curr_time-update*60) reload = true;
  }
  else reload = true;

  LastUpdate = curr_time;
  if(reload)
  {
    str = ReadWebPage("http://www.dailyfx.com/calendar/cal.csv?week=&sort=dateDesc&timezone=&currency=|&importance=|&time="+(string)curr_time);
    if(str == "") return((string)0);
    Str_Replace("\n\n", "\n", str);
    str = StringTrimRight(str);
    WriteFile("news.csv", TimeToString(curr_time, TIME_DATE|TIME_SECONDS)+"\n"+str);
  }  
  else
    str = StringTrimRight(str2);
  return (str);  
}

// -----------------------------------------------------------------------------------------------------------------------------
void Parce_News(string str)
{
  string arr[1000];
  TotalNews = Explode(str, "\n", arr)-1;
  int i = 0,j=0;
  for(int l=0; l<TotalNews; l++)
  {      
    string arr1[10];
    Explode(arr[l+1], ",", arr1);
    
    if(!eur && (arr1[3]=="EUR") ) continue;
    if(!usd && (arr1[3]=="USD") ) continue;
    if(!jpy && (arr1[3]=="JPY") ) continue;
    if(!gbp && (arr1[3]=="GBP") ) continue;
    if(!chf && (arr1[3]=="CHF") ) continue;
    if(!cad && (arr1[3]=="CAD") ) continue;
    if(!aud && (arr1[3]=="AUD") ) continue;
    if(!nzd && (arr1[3]=="NZD") ) continue;

    if(!high   && (arr1[5]=="High") )   continue;
    if(!medium && (arr1[5]=="Medium") ) continue;
    if(!low    && (arr1[5]=="Low") )    continue;

    for( int j=0; j<10; j++ )
      News[i][j] = arr1[j];
    string tmp[3], tmp1[2];    
    Explode(News[i][0], " ", tmp);
    int mon = 0;
    if(tmp[1]=="Jan") mon=1;  else if(tmp[1]=="Feb") mon=2;  else if(tmp[1]=="Mar") mon=3; else 
    if(tmp[1]=="Apr") mon=4;  else if(tmp[1]=="May") mon=5;  else if(tmp[1]=="Jun") mon=6; else 
    if(tmp[1]=="Jul") mon=7;  else if(tmp[1]=="Aug") mon=8;  else if(tmp[1]=="Sep") mon=9; else
    if(tmp[1]=="Oct") mon=10; else if(tmp[1]=="Nov") mon=11; else if(tmp[1]=="Dec") mon=12;
    MqlDateTime tm;  TimeCurrent(tm);

    News[i][0] = (string)tm.year+"."+(string)mon+"."+(string)tmp[2];
     
    Explode(News[i][1], " ", tmp);
    bool pm = tmp[1]=="PM";
    Explode(tmp[0], ":", tmp1);
    tmp1[0] = StringToInteger((string)tmp1[0])%12;
    if(pm) tmp1[0] = StringToInteger((string)tmp1[0])+12;
    News[i][1] = tmp1[0]+":"+tmp1[1];
     
    datetime dt = StringToTime(News[i][0]+" "+News[i][1]);
    News[i][0] = TimeToString(dt + server_timezone*60*60, TIME_DATE);
    News[i][1] = TimeToString(dt + server_timezone*60*60, TIME_MINUTES);
    News[i][9] = TimeToString(dt + show_timezone*60*60, TIME_DATE|TIME_MINUTES);
    News[i][4] = Str_Replace("&#039;", "\'", News[i][4]);
     
    if(russian)
    {
      for(j=0; j<TotalTranslate; j++)
        News[i][4] = Str_Replace(Translate[j][0], Translate[j][1], News[i][4]);
    }
    i++;
  } 
  
  TotalNews = i;     
  string tm = "";
  for(i=0; i<TotalNews-1; i++)  
  {
    for(int k=i+1; k<TotalNews; k++)
      if( StringToTime(News[k][9])<StringToTime(News[i][9]) 
      || ( StringToTime(News[k][9])==StringToTime(News[i][9]) && (News[k][5]=="High" || (News[k][5]=="Medium" && News[i][5]=="Low"))) )
        for( j=0; j<10; j++ )
        {
          tm = News[i][j]; News[i][j] = News[k][j]; News[k][j] = tm;
        }
  }
}

// -----------------------------------------------------------------------------------------------------------------------------
string Str_Replace(string search, string replace, string process)
{
  int pos = StringFind(process, search);
  while(pos != -1)
  {
    if(pos==0) 
      process = replace + StringSubstr(process, StringLen(search));
    else 
      process = StringSubstr(process, 0, pos) + replace + StringSubstr(process, pos+StringLen(search));
    pos = StringFind(process, search);
  }  
  return (process);
}

// -----------------------------------------------------------------------------------------------------------------------------
string News_List()
{
  int start = 0;
  if(NextNewsLine >= old_news) start = NextNewsLine - old_news;
  string com = "_____ Прошедшие новости ______________________\n";
  for(int i=start; i<start+total_in_list && i<TotalNews; i++)
  {
    string text = "";
    if(News[i][8] != "" || News[i][7] != "") text = "[" + News[i][8] + ", " + News[i][7] + "]";
    if(News[i][6] != "") text = text + " " + News[i][6];
    com = com + News[i][9] + " " + StringSubstr(News[i][5], 0, 1) + " " + News[i][4] + " " + text + "\n";
    if(i==NextNewsLine-1) com = com + "_____ Будущие новости ________________________\n";
  }
  return(com);  
}

// -----------------------------------------------------------------------------------------------------------------------------
int Explode(string str, string delimiter, string& arr[])
{
   int i = 0;
   int pos = StringFind(str, delimiter);
   while(pos != -1)
   {
      if(pos == 0) arr[i] = ""; else arr[i] = StringSubstr(str, 0, pos);
      i++;
      str = StringSubstr(str, pos+StringLen(delimiter));
      pos = StringFind(str, delimiter);
      if(pos == -1 || str == "") break;
   }
   arr[i] = str;

   return(i+1);
}
void ParseURL(string URL,string &host,string &request,string &filename)
  {
   host=StringSubstr(URL,7);
   // убрали
   int i=StringFind(host,"/"); 
   request=StringSubstr(host,i);
   host=StringSubstr(host,0,i);
   string file="";
   for(i=StringLen(URL)-1; i>=0; i--)
      if(StringSubstr(URL,i,1)=="/")
        {
         file=StringSubstr(URL,i+1);
         break;
        }
   if(file!="") filename=file;
  }
// -----------------------------------------------------------------------------------------------------------------------------
string ReadWebPage(string url)
 {
  if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
  {
    Print("Необходимо в настройках разрешить использование DLL");
    return("");
  }
  MqlNet INet; // переменная для работы в интернете
  string cBuffer[8192];
  int dwBytesRead[1]; 
  string str = "";

   string Host,Request,FileName="Recieve_"+TimeToString(TimeCurrent())+".mq5";
//"http://www.dailyfx.com/calendar/cal.csv?week=&sort=dateDesc&timezone=&currency=|&importance=|&time="+(string)curr_time
   // разделили адрес на запрос
   ParseURL(url,Host,Request,FileName);
//   Print("Host=",Host);
//   Print("Request=",Request);
   FileName = "cal.csv";
   // открыли сессию
   if(!INet.Open(Host,80)) return(0);
//   Print("+Copy "+FileName+" from  http://"+Host+" to "+GetFolder(FolderType));

   // получили файл
   if(!INet.Request("GET",Request,&cBuffer,true))
     {
      Print("-Err download "+url);
      return(0);
     }
  while(!IsStopped())
  {
    for(int i = 0; i<8192; i++) cBuffer[i] = 0;
    bool bResult = InternetReadFile(hRequest, cBuffer, 32768, dwBytesRead);
    if(dwBytesRead[0] == 0) break;
    string text = "";   
    for(int i=0; i<8192; i++)
    {
      text = text + CharToString(cBuffer[i] & 0x000000FF);
      if(StringLen(text) == dwBytesRead[0]) break;
      text = text + CharToString(cBuffer[i] >> 8 & 0x000000FF);
      if(StringLen(text) == dwBytesRead[0]) break;
      text = text + CharToString(cBuffer[i] >> 16 & 0x000000FF);
      if(StringLen(text) == dwBytesRead[0]) break;
      text = text + CharToString(cBuffer[i] >> 24 & 0x000000FF);
    }
    str = str + text;
  }

//  InternetCloseHandle(hInternetSession);
   
  return(str);
}

// -----------------------------------------------------------------------------------------------------------------------------
string ReadFile (string path) 
{
  path = TerminalInfoString(TERMINAL_PATH) + "/experts/files/" + path;
  int buffer[], count, handle, i, result;
  string text = "";
  handle = _lopen(path, 0);
  if(handle < 0) 
  {
    Print("Ошибка открытия файла ", path); 
    return("");
  }
  count =_llseek (handle,0,2);          
  if(count < 0)  
  {
    Print("Ошибка установки указателя"); 
    return ("");
  }
  ArrayResize(buffer, 1+count/4);
  result = _llseek(handle, 0, 0);          
  if(result < 0) 
  {
    Print("Ошибка установки указателя"); 
    return("");
  }
  result = _lread(handle, buffer, count); 
  if(result < 0) 
  {
    Print("Ошибка чтения файла ", path); 
    return("");
  }
  result = _lclose(handle);              
  if(result < 0) 
  {
    Print("Ошибка закрытия файла ", path); 
    return("");
  }
  for(i=0; i<ArraySize(buffer); i++) 
  {
    text = text
      + CharToString(buffer[i]     & 0x000000FF)
      + CharToString(buffer[i]>> 8 & 0x000000FF)
      + CharToString(buffer[i]>>16 & 0x000000FF)
      + CharToString(buffer[i]>>24 & 0x000000FF);
  }
  text = StringSubstr(text,0,count);
  return(text);
}
 
// -----------------------------------------------------------------------------------------------------------------------------
void WriteFile (string path, string buffer) 
{
  path = TerminalInfoString(TERMINAL_PATH) + "/experts/files/" + path;
  int handle, result, count = StringLen(buffer); 
  handle = _lopen(path, 1);
  if(handle < 0) 
  {
    handle = _lcreat(path, 0);
    if(handle < 0) 
    {
      Print("Ошибка создания файла ", path);
      return;
    }
    result = _lclose(handle);
  }
  handle = _lopen(path, 1);              
  if(handle < 0) 
  {
    Print("Ошибка открытия файла ", path); 
    return;
  }
  result = _llseek(handle, 0, 0);          
  if(result < 0) 
  {
    Print("Ошибка установки указателя"); 
    return;
  }
  result = _lwrite(handle, buffer, count); 
  if(result < 0) 
    Print("Ошибка записи в файл ", path, " ", count, " байт");
  result = _lclose (handle);              
  if(result < 0)  
    Print("Ошибка закрытия файла ", path);
}