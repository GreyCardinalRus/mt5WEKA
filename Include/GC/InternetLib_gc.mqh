//+------------------------------------------------------------------+
//|																									 				InetHttp |
//|                                    Copyright � 2010, FXmaster.de |
//|                                      						 www.FXmaster.de |
//|     programming & support - Alexey Sergeev (profy.mql@gmail.com) |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2010, FXmaster.de"
#property link      "www.FXmaster.de"
#property version		"1.00"
#property description  "WinHttp & WinInet API"
#property library

#define FALSE 0

#define HINTERNET int
#define BOOL int
#define INTERNET_PORT int
#define LPINTERNET_BUFFERS int
#define DWORD int
#define DWORD_PTR int
#define LPDWORD int&
#define LPVOID uchar& 
#define LPSTR string
#define LPCWSTR	string&
#define LPCTSTR string&
#define LPTSTR string&
//LPCTSTR *		int
//LPVOID			uchar& +_[]

#import	"Kernel32.dll"
	DWORD GetLastError(int);
#import

#import "wininet.dll"
	DWORD InternetAttemptConnect(DWORD dwReserved);
	HINTERNET InternetOpenW(LPCTSTR lpszAgent, DWORD dwAccessType, LPCTSTR lpszProxyName, LPCTSTR lpszProxyBypass, DWORD dwFlags);
	HINTERNET InternetConnectW(HINTERNET hInternet, LPCTSTR lpszServerName, INTERNET_PORT nServerPort, LPCTSTR lpszUsername, LPCTSTR lpszPassword, DWORD dwService, DWORD dwFlags, DWORD_PTR dwContext);
	HINTERNET HttpOpenRequestW(HINTERNET hConnect, LPCTSTR lpszVerb, LPCTSTR lpszObjectName, LPCTSTR lpszVersion, LPCTSTR lpszReferer, int /*LPCTSTR* */ lplpszAcceptTypes, uint/*DWORD*/ dwFlags, DWORD_PTR dwContext);
	BOOL HttpSendRequestW(HINTERNET hRequest, LPCTSTR lpszHeaders, DWORD dwHeadersLength, LPVOID lpOptional[], DWORD dwOptionalLength);
	BOOL HttpQueryInfoW(HINTERNET hRequest, DWORD dwInfoLevel, LPVOID lpvBuffer[], LPDWORD lpdwBufferLength, LPDWORD lpdwIndex);
	HINTERNET InternetOpenUrlW(HINTERNET hInternet, LPCTSTR lpszUrl, LPCTSTR lpszHeaders, DWORD dwHeadersLength, uint/*DWORD*/ dwFlags, DWORD_PTR dwContext);
	BOOL InternetReadFile(HINTERNET hFile, LPVOID lpBuffer[], DWORD dwNumberOfBytesToRead, LPDWORD lpdwNumberOfBytesRead);
	BOOL InternetCloseHandle(HINTERNET hInternet);
	BOOL InternetSetOptionW(HINTERNET hInternet, DWORD dwOption, LPDWORD lpBuffer, DWORD dwBufferLength);
	BOOL InternetQueryOptionW(HINTERNET hInternet, DWORD dwOption, LPDWORD lpBuffer, LPDWORD lpdwBufferLength);
//	BOOL InternetSetCookieW(LPCTSTR lpszUrl, LPCTSTR lpszCookieName, LPCTSTR lpszCookieData);
	BOOL InternetGetCookieW(LPCTSTR lpszUrl, LPCTSTR lpszCookieName, LPVOID lpszCookieData[], LPDWORD lpdwSize);
#import

#define OPEN_TYPE_PRECONFIG		0   // ������������ ������������ �� ���������
#define INTERNET_SERVICE_FTP						1 // ������ Ftp
#define INTERNET_SERVICE_HTTP						3	// ������ Http 
#define HTTP_QUERY_CONTENT_LENGTH 			5

#define INTERNET_FLAG_PRAGMA_NOCACHE						0x00000100  // �� ���������� ��������
#define INTERNET_FLAG_KEEP_CONNECTION						0x00400000  // �� ��������� ����������
#define INTERNET_FLAG_SECURE            				0x00800000
#define INTERNET_FLAG_RELOAD										0x80000000  // �������� �������� � ������� ��� ��������� � ���
#define INTERNET_OPTION_SECURITY_FLAGS    	     31

#define ERROR_INTERNET_INVALID_CA								12045
#define INTERNET_FLAG_IGNORE_CERT_DATE_INVALID  0x00002000
#define INTERNET_FLAG_IGNORE_CERT_CN_INVALID    0x00001000
#define SECURITY_FLAG_IGNORE_CERT_CN_INVALID    INTERNET_FLAG_IGNORE_CERT_CN_INVALID
#define SECURITY_FLAG_IGNORE_CERT_DATE_INVALID  INTERNET_FLAG_IGNORE_CERT_DATE_INVALID
#define SECURITY_FLAG_IGNORE_UNKNOWN_CA         0x00000100
#define SECURITY_FLAG_IGNORE_WRONG_USAGE        0x00000200

//------------------------------------------------------------------ struct tagRequest
struct tagRequest
{
	string stVerb; // ����� ������� GET/POST
	string stObject; // ���� � �������� "/get.php?a=1"  ��� "/index.htm"
	string stHead; // ��������� �������, 
								// "Content-Type: multipart/form-data; boundary=1BEF0A57BE110FD467A\r\n"
								// ��� "Content-Type: application/x-www-form-urlencoded"
	string stData; // �������������� ������ ������
	bool fromFile; // ���� =true, �� stData ���������� ��� ����� ������
	string stOut; // ���� ��� ������ ������
	bool toFile; // ���� =true, �� stOut ���������� ��� ����� ��� ������ ������
	void Init(string aVerb, string aObject, string aHead, string aData, bool from, string aOut, bool to);
};
//------------------------------------------------------------------ class MqlNet
void tagRequest::Init(string aVerb, string aObject, string aHead, string aData, bool from, string aOut, bool to)
{
	stVerb=aVerb; // ����� ������� GET/POST
	stObject=aObject; // ���� � �������� "/get.php?a=1"  ��� "/index.htm"
	stHead=aHead; // ��������� �������, "Content-Type: application/x-www-form-urlencoded"
	stData=aData; // �������������� ������ ������
	fromFile=from; // ���� =true, �� stData ���������� ��� ����� ������
	stOut=aOut; // ���� ��� ������ ������
	toFile=to; // ���� =true, �� stOut ���������� ��� ����� ��� ������ ������
}
//------------------------------------------------------------------ class MqlNet
class MqlNet
{
public:
	string Host; // ���� �����
	int Port; // ����
	string User; // ��� ������������
	string Pass; // ������ ������������
	int Service; // ��� ������� 
	// ���������� ���������
	int hSession; // ���������� ������
	int hConnect; // ���������� ����������
public:
	MqlNet(); // ����������� ������
	~MqlNet(); // ����������
	bool Open(string aHost, int aPort, string aUser, string aPass, int aService); // ������� ������ � ��������� ����������
	void Close(); // ��������� ������ � ����������
	bool Request(tagRequest &req); // ���������� ������
	bool OpenURL(string aURL, string &Out, bool toFile); // ������ ������ �������� � ���� ��� � ����������
	void ReadPage(int hRequest, string &Out, bool toFile); // ������� ��������
	long GetContentSize(int hURL); //��������� ���������� � ������� �����������  ��������
	int FileToArray(string FileName, uchar& data[]); // �������� ���� � ������ ��� ��������
};

//------------------------------------------------------------------ MqlNet
void MqlNet::MqlNet()
{
	hSession=-1; hConnect=-1; Host=""; User=""; Pass=""; Service=-1; // �������� ���������
}
//------------------------------------------------------------------ ~MqlNet
void MqlNet::~MqlNet()
{
	Close(); // ��������� ��� ����������� 
}
//------------------------------------------------------------------ Open
bool MqlNet::Open(string aHost, int aPort, string aUser, string aPass, int aService)
{
	if (aHost=="") { Print("-Host not specified"); return(false); }
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // �������� ���������� DLL � ���������
	if(!MQL5InfoInteger(MQL5_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // �������� ���������� DLL � ���������
	if (hSession>0 || hConnect>0) Close(); // ���� ������ ���� �����������, �� ��������� 
	Print("+Open Inet..."); // ��������� ��� ������� �������� � ������
	if (InternetAttemptConnect(0)!=0) { Print("-Err AttemptConnect"); return(false); } // ���� �� ������� ��������� ��������� ���������� � ����������, �� �������
	string UserAgent="Mozilla"; string nill="";
	hSession=InternetOpenW(UserAgent, OPEN_TYPE_PRECONFIG, nill, nill, 0); // ��������� ������
	if (hSession<=0) { Print("-Err create Session"); Close(); return(false); } // ���� �� ������ ������� ������, �� �������
	hConnect=InternetConnectW(hSession, aHost, aPort, aUser, aPass, aService, 0, 0); 
	if (hConnect<=0) { Print("-Err create Connect"); Close(); return(false); }
	Host=aHost; Port=aPort; User=aUser; Pass=aPass; Service=aService;
	return(true); // ����� ��� �������� ����������� �������
}
//------------------------------------------------------------------ Close
void MqlNet::Close()
{
	if (hSession>0) { InternetCloseHandle(hSession); hSession=-1; Print("-Close Session..."); }
	if (hConnect>0) { InternetCloseHandle(hConnect); hConnect=-1; Print("-Close Connect..."); }
}
//------------------------------------------------------------------ Request
bool MqlNet::Request(tagRequest &req)
{
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // �������� ���������� DLL � ���������
	if(!MQL5InfoInteger(MQL5_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // �������� ���������� DLL � ���������
	if (req.toFile && req.stOut=="") { Print("-File not specified "); return(false); }
	uchar data[]; int hRequest, hSend; 
	string Vers="HTTP/1.1"; string nill="";
	if (req.fromFile) { if (FileToArray(req.stData, data)<0) { Print("-Err reading file "+req.stData); return(false); } }// ��������� ���� � ������
	else StringToCharArray(req.stData, data);

	if (hSession<=0 || hConnect<=0) { Close(); if (!Open(Host, Port, User, Pass, Service)) { Print("-Err Connect"); Close(); return(false); } }
	// ������� ���������� �������
	hRequest=HttpOpenRequestW(hConnect, req.stVerb, req.stObject, Vers, nill, 0, INTERNET_FLAG_KEEP_CONNECTION|INTERNET_FLAG_RELOAD|INTERNET_FLAG_PRAGMA_NOCACHE, 0); 
	if (hRequest<=0) { Print("-Err OpenRequest"); InternetCloseHandle(hConnect); return(false); }


	// ���������� ������
	int n=0;
	while (n<3)
	{
		n++;
		hSend=HttpSendRequestW(hRequest, req.stHead, StringLen(req.stHead), data, ArraySize(data)); // ��������� ����
		if (hSend<=0) 
		{ 	
			int err=0; err=GetLastError(err); Print("-Err SendRequest= ", err); 
			if (err!=ERROR_INTERNET_INVALID_CA)
			{
				int dwFlags;
				int dwBuffLen = sizeof(dwFlags);
				InternetQueryOptionW(hRequest, INTERNET_OPTION_SECURITY_FLAGS, dwFlags, dwBuffLen);
				dwFlags |= SECURITY_FLAG_IGNORE_UNKNOWN_CA;
				int rez=InternetSetOptionW(hRequest, INTERNET_OPTION_SECURITY_FLAGS, dwFlags, sizeof (dwFlags));
				if (!rez) { Print("-Err InternetSetOptionW= ", GetLastError(err)); break; }
			}
			else break;
		} 
		else break;
	}
	if (hSend>0) ReadPage(hRequest, req.stOut, req.toFile); // ������ ��������
	InternetCloseHandle(hRequest); InternetCloseHandle(hSend); // ������� ��� ������
	if (hSend<=0) Close();
	return(true);
}
//------------------------------------------------------------------ OpenURL
bool MqlNet::OpenURL(string aURL, string &Out, bool toFile)
{
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // �������� ���������� DLL � ���������
	if(!MQL5InfoInteger(MQL5_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // �������� ���������� DLL � ���������
	string nill="";
	if (hSession<=0 || hConnect<=0) { Close(); if (!Open(Host, Port, User, Pass, Service)) { Print("-Err Connect"); Close(); return(false); } }
	int hURL=InternetOpenUrlW(hSession, aURL, nill, 0, INTERNET_FLAG_RELOAD|INTERNET_FLAG_PRAGMA_NOCACHE, 0); 
	if(hURL<=0) { Print("-Err OpenUrl"); return(false); }
	ReadPage(hURL, Out, toFile); // ������ � Out
	InternetCloseHandle(hURL); // ������� 
	return(true);
}
//------------------------------------------------------------------ ReadPage
void MqlNet::ReadPage(int hRequest, string &Out, bool toFile)
{
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return; } // �������� ���������� DLL � ���������
	if(!MQL5InfoInteger(MQL5_DLLS_ALLOWED)) { Print("-DLL not allowed"); return; } // �������� ���������� DLL � ���������
	// ������ �������� 
	uchar ch[100]; string toStr=""; int dwBytes, h=-1;
	if (toFile) h=FileOpen(Out, FILE_ANSI|FILE_BIN|FILE_WRITE);
	while(InternetReadFile(hRequest, ch, 100, dwBytes)) 
	{
		if (dwBytes<=0) break; toStr=toStr+CharArrayToString(ch, 0, dwBytes);
		if (toFile) for (int i=0; i<dwBytes; i++) FileWriteInteger(h, ch[i], CHAR_VALUE);
	}
	if (toFile) { FileFlush(h); FileClose(h); }
	else Out=toStr;
}
//------------------------------------------------------------------ GetContentSize
long MqlNet::GetContentSize(int hRequest)
{
	if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // �������� ���������� DLL � ���������
	if(!MQL5InfoInteger(MQL5_DLLS_ALLOWED)) { Print("-DLL not allowed"); return(false); } // �������� ���������� DLL � ���������
	int len=2048, ind=0; uchar buf[2048];
	int Res=HttpQueryInfoW(hRequest, HTTP_QUERY_CONTENT_LENGTH, buf, len, ind);
	if (Res<=0) { Print("-Err QueryInfo"); return(-1); }

	string s=CharArrayToString(buf, 0, len);
	if (StringLen(s)<=0) return(0);
	return(StringToInteger(s));
}
//----------------------------------------------------- FileToArray
int MqlNet::FileToArray(string aFileName, uchar& data[])
{
	int h, i, size;	
	h=FileOpen(aFileName, FILE_ANSI|FILE_BIN|FILE_READ);	if (h<0) return(-1);
	FileSeek(h, 0, SEEK_SET);	
	size=(int)FileSize(h); ArrayResize(data, (int)size); 
	for (i=0; i<size; i++) data[i]=(uchar)FileReadInteger(h, CHAR_VALUE); 
	FileClose(h); return(size);
}