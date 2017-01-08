//+------------------------------------------------------------------+
//|                                                MetaArbitrage.mq5 |
//|                                 Copyright © 2010 www.fxmaster.de |
//|                                         Coding by Sergeev Alexey |
//+------------------------------------------------------------------+
#property copyright   "www.fxmaster.de  © 2010"
#property link        "www.fxmaster.de"
#property version     "1.00"
#property description "Active exchange and price monitoring"

#include <InternetLib.mqh>

input string Host="www.fxmaster.de";   // хост, используемый в скрипте
input int Delay=10;                    // макс. врем€ задержки
input bool LineView=true;              // вкл/выкл показ линий
input bool ListView=true;              // вкл/выкл показ списка
input string ID="";                    // префикс, чтобы различать поставщиков котировок
string FileName="_arbitr.txt";         // »м€ файла на сервере

color Clr[1000],_Clr[1000];            // ÷вет котировок

string inf="";

MqlNet INet;  // экземпл€р класса дл€ работы с »нтернет
//------------------------------------------------------------------ OnInit
int OnInit()
  {
   // им€ файла на сервере
   FileName=(ID+Symbol())+"_arbitr.txt";
   inf="";
   // открываем сессию
   if(!INet.Open(Host,80)) return(0);
   Clr[0]=Orange;
   Clr[1]=Lime;
   Clr[2]=Crimson;
   Clr[3]=DeepSkyBlue;
   Clr[4]=Magenta;
   Clr[5]=CadetBlue;
   Clr[6]=Red;
   Clr[7]=SteelBlue;
   Clr[8]=OliveDrab;
   Clr[9]=DeepPink;
   Clr[10]=SlateGray;
   for(int i=11; i<1000; i++)
     {
      Clr[i]=StringToColor(ITS(MathRand()*255/32767)+","+ITS(MathRand()*255/32767)+","+ITS(MathRand()*255/32767));
     }
   EventSetTimer(1);
   CreateButton(ChartID(),"Line","!",270,15,20,20,Orange,LineView,"Wingdings");
   CreateButton(ChartID(),"List","2",300,15,20,20,Orange,ListView,"Wingdings");
   return(0);
  }
//------------------------------------------------------------------ OnDeinit
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll2(0,OBJ_HLINE,"bid");
   ObjectsDeleteAll2(0,OBJ_LABEL,"bid");
   ObjectDelete(ChartID(),"Line");
   ObjectDelete(ChartID(),"List");
   EventKillTimer();
   Comment("");
   // закрываем сессию
   INet.Close();
  }
//------------------------------------------------------------------ OnTimer
void OnTimer()
  {
   inf="\n"+Host+" :: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+" | UTC "+TimeToString(TimeLocal()-ShiftGMT(),TIME_MINUTES|TIME_SECONDS);
   if(IsStopped())
     {
      inf=inf+"\n - system stopped"; Comment(inf);
      return;
     }
   // получение и показ данных
   RecieveBid();
   // показываем комментарий и ждем 100 ms
   Comment(inf);
   Sleep(100);
   return;
  }
//------------------------------------------------------------------ RecieveBid
void RecieveBid()
  {
   int i,h,n,wdth;
   double _Bid[],d;
   datetime _Time[];
   string Server[],Request,end,st,name;
   MqlTick tick;

   if(!SymbolInfoTick(Symbol(),tick)) return;

   // подготовка get-запроса
   Request="/metaarbitr.php"+
           "?server="+AccountInfoString(ACCOUNT_SERVER)+
           "&pair="+(ID+Symbol())+
           "&bid="+DTS(tick.bid)+
           "&time="+ITS(TimeLocal()-ShiftGMT());

   // посылаем запрос на сервер
   if(!INet.Request("GET",Request,FileName,true))
     {
      Print("-Err request");
      return;
     }

   h=FileOpen(FileName,FILE_CSV|FILE_READ,';');
   if(h<0)
     {
      inf=inf+"\nCan\'t open "+FileName; return;
     }

   // обработка полученного файла
   FileSeek(h,0,SEEK_SET);
   end=FileReadString(h);
   if(end=="" || FileIsEnding(h) || StringSubstr(end,0,5)!="~beg~") return;
   // сервер
   n=(int)StringToInteger(FileReadString(h)); 

   //копируем данные в массив
   ArrayResize(_Bid,n);
   ArrayResize(Server,n);
   ArrayResize(_Time,n);
   for(i=0; i<n; i++)
     {
      Server[i]=FileReadString(h);
      _Bid[i]=StringToDouble(FileReadString(h));
      _Time[i]=StringToInteger(FileReadString(h));
      _Clr[i]=Clr[i];
     }
   // закрываем файл
   FileClose(h); 

  // сортируем котировки дл€ показа списка валют по возрастанию
   bool b=true;
   while(b)
     {
      b=false;
      for(i=1; i<n; i++)
         if(_Bid[i]>_Bid[i-1])
           {
            d=_Bid[i];
            _Bid[i]=_Bid[i-1];
            _Bid[i-1]=d;
            d=_Time[i];
            _Time[i]=_Time[i-1];
            _Time[i-1]=(int)d;
            name=Server[i];
            Server[i]=Server[i-1];
            Server[i-1]=name;
            d=_Clr[i];
            _Clr[i]=_Clr[i-1];
            _Clr[i-1]=(int)d;
            b=true;
           }
     }

   // показываем данные на графике
   ObjectsDeleteAll2(0,OBJ_HLINE,"bid");
   ObjectsDeleteAll2(0,OBJ_LABEL,"bid");
   // показываем линии
   bool showLine=ObjectGetInteger(ChartID(), "Line", OBJPROP_STATE);
   // показываем список
   bool showList=ObjectGetInteger(ChartID(), "List", OBJPROP_STATE); 
   for(i=0; i<n; i++)
     {
      if(_Time[i]<TimeLocal()-ShiftGMT()-Delay) continue;
      wdth=1;
      if(Server[i]==AccountInfoString(ACCOUNT_SERVER)) wdth=2;
      if(showLine)
         SetHLine(ChartID(),"bid"+Server[i],_Bid[i],_Clr[i],wdth,STYLE_SOLID,Server[i]);
      if(showList)
         SetLabel(ChartID(),"bidL"+Server[i],0,DTS(_Bid[i])+" | "+Server[i],_Clr[i],5,37+11*i,0,7,"Tahoma");
     }
   inf=inf+"\nActive - "+ITS(n)+" server | "+(ID+Symbol())+" | current "+AccountInfoString(ACCOUNT_SERVER);
   // перерисовка графика
   ChartRedraw();
  }
//------------------------------------------------------------------ OnChartEvent
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam=="Line" && !ObjectGetInteger(ChartID(),"Line",OBJPROP_STATE))
        {
         ObjectsDeleteAll2(0,OBJ_HLINE,"bidL");
         ChartRedraw(ChartID());
        }
      if(sparam=="List" && !ObjectGetInteger(ChartID(),"Line",OBJPROP_STATE))
        {
         ObjectsDeleteAll2(0,OBJ_TEXT,"bid");
         ChartRedraw(ChartID());
        }
     }
  }
//------------------------------------------------------------------ ObjectsDeleteAll2
void ObjectsDeleteAll2(int wnd=-1,int type=-1,string pref="")
  {
   string st,names[]; int i,n=ObjectsTotal(ChartID()); ArrayResize(names,n);
   for(i=0; i<n; i++) names[i]=ObjectName(ChartID(), i);
   for(i=0; i<n; i++)
     {
      if(wnd>=0) if(ObjectFind(ChartID(),names[i])!=wnd) continue;
      if(type>=0) if(ObjectGetInteger(ChartID(), names[i], OBJPROP_TYPE)!=type) continue;
      if(pref!="") if(StringSubstr(names[i], 0, StringLen(pref))!=pref) continue;
      ObjectDelete(ChartID(),names[i]);
     }
  }
//------------------------------------------------------------------ CreateButton
void CreateButton(long chart,string name,string txt,int x,int y,int dx,int dy,color clr,bool state,string font)
  {
   ObjectCreate(chart,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(chart,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(chart,name,OBJPROP_STATE,state);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,Black);
   ObjectSetInteger(chart,name,OBJPROP_BGCOLOR,clr);
   ObjectSetInteger(chart,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart,name,OBJPROP_XSIZE,dx);
   ObjectSetInteger(chart,name,OBJPROP_YSIZE,dy);
   ObjectSetString(chart,name,OBJPROP_TEXT,txt);
   ObjectSetString(chart,name,OBJPROP_FONT,font);
  }
//------------------------------------------------------------------ SetHLine
void SetHLine(long chart,string name,double pr,color clr,int width,int style,string st)
  {
   ObjectCreate(chart,name,OBJ_HLINE,0,0,0);
   ObjectSetDouble(chart,name,OBJPROP_PRICE,pr);
   ObjectSetInteger(chart,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,clr);
   ObjectSetString(chart,name,OBJPROP_TEXT,st);
   ObjectSetInteger(chart,name,OBJPROP_STYLE,style);
  }
//------------------------------------------------------------------ SetLabel
void SetLabel(long chart,string name,int wnd,string text,color clr,int x,int y,int corn,int fontsize,string font)
  {
   ObjectCreate(chart,name,OBJ_LABEL,wnd,0,0);
   ObjectSetInteger(chart,name,OBJPROP_CORNER,corn);
   ObjectSetString(chart,name,OBJPROP_TEXT,text);
   ObjectSetString(chart,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart,name,OBJPROP_FONTSIZE,fontsize);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart,name,OBJPROP_YDISTANCE,y);
  }
//---------------------------------------------------------------   DTS
string DTS(double d,int n=-1) { if(n<0) return(DoubleToString(d,Digits())); else return(DoubleToString(d,n)); }
//---------------------------------------------------------------   ITS
string ITS(double d) { return(DoubleToString(d,0)); }
//------------------------------------------------------------------
#import "kernel32.dll"
int  GetTimeZoneInformation(int &TZInfoArray[]);
#import
int ShiftGMT()
  {
   int TZInfoArray[43],gmt_shift=0,ret=GetTimeZoneInformation(TZInfoArray);
   if(ret!=0) gmt_shift=TZInfoArray[0]; else if(ret==2) gmt_shift+=TZInfoArray[42];
   return(-gmt_shift*60);
  }
//+------------------------------------------------------------------+
