//+------------------------------------------------------------------+
//|																													MetaSwap |
//|																	Copyright © 2011 www.fxmaster.de |
//|																					Coding by Sergeev Alexey |
//+------------------------------------------------------------------+
#property copyright "www.fxmaster.de © 2006-2011"
#property link "www.fxmaster.de"
#property version "1.00"
#property description "Active swap monitoring"

#include <InternetLib.mqh>

string Server[]; // массив имен серверов
double Long[], Short[]; // массив данных свопов
MqlNet INet; // экземпляр класса для работы

//------------------------------------------------------------------ OnStart
void OnStart()
{
	// открываем сессию
	//if (!INet.Open("www.russianarmy.ru", 80, "", "", INTERNET_SERVICE_HTTP)) return;
	if (!INet.Open("www.fxmaster.de", 80, "", "", INTERNET_SERVICE_HTTP)) return;
	// обнулили массивы
	ArrayResize(Server, 0); ArrayResize(Long, 0); ArrayResize(Short, 0);
	
	string file=Symbol()+"_swap.csv"; // файл куда пример данные свопа
	if (!SendData(file, "GET")) { Print("-err Send data"); return; } // отправляем свопы
	if (!ReadSwap(file)) { Print("-err File struct"); return; } // прочитали данные из принятого файла
	UpdateInfo(); // обновили информацию свопов на графике
}
//------------------------------------------------------------------ SendData
bool SendData(string file, string mode)
{
	string smb=Symbol();
	string Head="Content-Type: application/x-www-form-urlencoded"; // заголовок
	string Path="/forex/metaswap.php"; // путь к странице
	//string Path="/mt5swap/metaswap.php"; // путь к странице
	string Data="server="+AccountInfoString(ACCOUNT_SERVER)+
							"&pair="+smb+
							"&long="+DTS(SymbolInfoDouble(smb, SYMBOL_SWAP_LONG))+
							"&short="+DTS(SymbolInfoDouble(smb, SYMBOL_SWAP_SHORT));

	tagRequest req; // инициализация параметров 
	if (mode=="GET")  req.Init(mode, Path+"?"+Data, Head, "", 	false, file, true);
	if (mode=="POST") req.Init(mode, Path,					Head, Data, false, file, true);

	return(INet.Request(req)); // посылаем запрос на сервер
}
//------------------------------------------------------------------ ReadSwap
bool ReadSwap(string file) // обработка полученного файла
{
	int h=FileOpen(file, FILE_ANSI|FILE_CSV|FILE_READ, ';');
	if(h<0) { Print("Can\'t open "+file); return(false); }

	FileSeek(h, 0, SEEK_SET);
	string beg=FileReadString(h);
	if(beg=="" || StringSubstr(beg, 0, 5)!="~beg~") { FileClose(h); return(false); }

	int n=(int)StringToInteger(FileReadString(h)); // число серверов
	
	//копируем данные в массивы
	ArrayResize(Server, n); ArrayResize(Long, n); ArrayResize(Short, n);
	for(int i=0; i<n; i++) { Server[i]=FileReadString(h); Long[i]=FileReadNumber(h); Short[i]=FileReadNumber(h); }
	
	string end=FileReadString(h);
	if(end=="" || StringSubstr(end, 0, 5)!="~end~") { FileClose(h); return(false); }
	FileClose(h); 

	Print("Active - "+DTS(n, 0)+" server | "+Symbol()+" | current "+AccountInfoString(ACCOUNT_SERVER));
	return(true);
}
//------------------------------------------------------------------ UpdateInfo
void UpdateInfo() // обновляем инфо на экране
{
	int n=ArraySize(Server); //число серверов
	ObjectsDeleteAll2(0, OBJ_LABEL, "swap"); // удаляем прошлую таблицу
	SetLabel(ChartID(), "swap", 0, "Сервер | Long | Short", clrRed, 5, 40, 0, 8, "Tahoma");
	for(int i=0; i<n; i++) // перерисовали таблицу
		SetLabel(ChartID(), "swap"+Server[i], 0, Server[i]+" | "+DTS(Long[i], 2)+" | "+DTS(Short[i], 2), clrRed, 5, 40+15*(i+1), 0, 8, "Tahoma");
	ChartRedraw(); // обновили чарт
}

//------------------------------------------------------------------ ObjectsDeleteAll2
void ObjectsDeleteAll2(int wnd=-1, int type=-1, string pref="")
{
	string names[]; int n=ObjectsTotal(ChartID()); ArrayResize(names, n);
	for(int i=0; i<n; i++) names[i]=ObjectName(ChartID(), i);
	for(int i=0; i<n; i++)
	{
		if(wnd>=0) if(ObjectFind(ChartID(), names[i])!=wnd) continue;
		if(type>=0) if(ObjectGetInteger(ChartID(), names[i], OBJPROP_TYPE)!=type) continue;
		if(pref!="") if(StringSubstr(names[i], 0, StringLen(pref))!=pref) continue;
		ObjectDelete(ChartID(), names[i]);
	}
}
//------------------------------------------------------------------ SetLabel
void SetLabel(long chart, string name, int wnd, string text, color clr, int x, int y, int corn, int fontsize, string font)
{
	ObjectCreate(chart, name, OBJ_LABEL, wnd, 0, 0);
	ObjectSetInteger(chart, name, OBJPROP_CORNER, corn);
	ObjectSetString(chart, name, OBJPROP_TEXT, text);
	ObjectSetString(chart, name, OBJPROP_FONT, font);
	ObjectSetInteger(chart, name, OBJPROP_FONTSIZE, fontsize);
	ObjectSetInteger(chart, name, OBJPROP_COLOR, clr);
	ObjectSetInteger(chart, name, OBJPROP_XDISTANCE, x);
	ObjectSetInteger(chart, name, OBJPROP_YDISTANCE, y);
}
//--------------------------------------------------------------- DTS
string DTS(double d, int n=-1) { if(n<0) return(DoubleToString(d, Digits())); else return(DoubleToString(d, n)); }