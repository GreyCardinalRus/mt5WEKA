//+------------------------------------------------------------------+
//|                                                     mt5_connect.mqh |
//|              Copyright Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

// ������������ �������� ��� ������� ICQConnect 
#define ICQ_CONNECT_STATUS_OK					   0xFFFFFFFF
#define ICQ_CONNECT_STATUS_RECV_ERROR			0xFFFFFFFE
#define ICQ_CONNECT_STATUS_SEND_ERROR			0xFFFFFFFD
#define ICQ_CONNECT_STATUS_CONNECT_ERROR		0xFFFFFFFC
#define ICQ_CONNECT_STATUS_AUTH_ERROR			0xFFFFFFFB

// �������� ��� ICQ_CLIENT.status
#define ICQ_CLIENT_STATUS_CONNECTED		      1
#define ICQ_CLIENT_STATUS_DISCONNECTED	      2

#define ICQ_Login "645990858" 
#define ICQ_Password "Forex7"
#define ICQ_Expert "622662116"
//#define ICQ_Expert "36770049"
#define ICQ_Master "36770049"

#define SOCKET_CONNECT_STATUS_OK				0
#define SOCKET_CONNECT_STATUS__ERROR		1000

#define SOCKET_CLIENT_STATUS_CONNECTED		1
#define SOCKET_CLIENT_STATUS_DISCONNECTED	2
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct SOCKET_CLIENT
  {
   uchar             status;   // ��� ��������� ����������� 
   ushort            sequence; // ������� ������������������ 
   uint              sock;     // ����� ������
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ICQ_CLIENT
  {
   uchar             status;   // ��� ��������� ����������� 
   ushort            sequence; // ������� ������������������ 
   uint              sock;     // ����� ������
  };
//+------------------------------------------------------------------+
//#import "mt5_connect_x64.dll"
#import "mt5_connect_x32.dll"
//+------------------------------------------------------------------+   
uint ICQConnect(
                ICQ_CLIENT &cl,// ���������� ��� �������� ������ � �����������
                string host,  // ��� �������, �������� login.icq.com
                ushort port,  // ���� �������, �������� 5190
                string login, // ����� ������� ������ (UIN)
                string pass   // ������ ��� ������� ������
                );

void ICQClose(
              ICQ_CLIENT &cl    // ���������� ��� �������� ������ � �����������
              );

uint ICQSendMsg(
                ICQ_CLIENT &cl,// ���������� ��� �������� ������ � �����������.
                string uin,    // ����� ������� ������ ����������
                string msg     // ����� ���������
                );

uint ICQReadMsg(
                ICQ_CLIENT &cl,// ���������� ��� �������� ������ � ����������� 
                string &uin,  // ����� ������� ������ ����������� 
                string &msg,  // ����� ��������� 
                uint &len   // ���������� �������� �������� � ���������
                );

uint SocketOpen(
                SOCKET_CLIENT &cl,// ���������� ��� �������� ������ � �����������
                string host,      // ��� �������
                ushort port       // ���� �������
                );

void SocketClose(
                 SOCKET_CLIENT &cl // ���������� ��� �������� ������ � �����������
                 );

uint SocketWriteString(
                       SOCKET_CLIENT &cl,// ���������� ��� �������� ������ � ����������� 
                       string str        // ������
                       );
uint SocketReadString(
                      SOCKET_CLIENT &cl,// ���������� ��� �������� ������ � ����������� 
                      string &str        // ������
                      );
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSocketClient
  {
private:
   SOCKET_CLIENT     client;        // �������� ������ � �����������
   uint              connect;      // ���� ��������� �����������
   datetime          timesave;     // �������� ���������� ������� ����������� � �������
   datetime          time_in;      // �������� ���������� ������� ������ ���������

public:
   string            msg;            // ������ ��� �������� ������ ��������� ���������
   uint              len;            // ���������� �������� � �������� ���������
   string            server;         // ��� �������    
   ushort            port;           // ������� ����  
   uint              timeout;        // ������� ��������(� ��������) ����� ��������� ����������� � ������
   bool              autocon;        // �������������� �������������� ����������
                     CSocketClient();   // ����������� ��� ������������� ���������� ������
   void              Init(void);
   bool              Connect(void);    // ��������� ���������� � ��������
   void              Disconnect(void); // ������ ���������� � ��������
   int               SendMessage(string  msg); // ������� ���������  
   int               ReadMessage(string &msg); // ����� ���������
  };
//+------------------------------------------------------------------+
class COscarClient
//+------------------------------------------------------------------+
  {
private:
   ICQ_CLIENT        client;        // �������� ������ � �����������
   uint              connect;      // ���� ��������� �����������
   datetime          timesave;     // �������� ���������� ������� ����������� � �������
   datetime          time_in;      // �������� ���������� ������� ������ ���������

public:
   string            uin;            // ������ ��� �������� uin ���������� ��� ��������� ���������
   string            msg;            // ������ ��� �������� ������ ��������� ���������
   uint              len;            // ���������� �������� � �������� ���������

   string            login;          // ����� ������� ������ ����������� (UIN)
   string            password;       // ������ ��� UIN 
   string            server;         // ��� �������    
   ushort            port;           // ������� ����  
   uint              timeout;        // ������� ��������(� ��������) ����� ��������� ����������� � ������
   bool              autocon;        // �������������� �������������� ����������

                     COscarClient();   // ����������� ��� ������������� ���������� ������
   void              Init(void);
   bool              Connect(void);    // ��������� ���������� � ��������
   void              Disconnect(void); // ������ ���������� � ��������
   bool              SendMessage(string  UIN,string  msg); // ������� ���������  
   bool              ReadMessage(string &UIN,string &msg,uint &len); // ����� ���������
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSocketClient::Connect()
//+------------------------------------------------------------------+
  {

   if((connect!=SOCKET_CONNECT_STATUS_OK) && (TimeLocal()-timesave)>=timeout)
     {
      timesave=TimeLocal();
      //      if(SocketOpen(client,server,port)==SOCKET_CONNECT_STATUS_OK)
      connect=SocketOpen(client,server,port);
      Print("Socket connect...");

      //PrintError(connect);
     }
   if(connect==SOCKET_CONNECT_STATUS_OK)
     {
      return(true);
     }
   else return(false);

  };
//+------------------------------------------------------------------+
CSocketClient::Disconnect()
//+------------------------------------------------------------------+
  {
   connect=SOCKET_CLIENT_STATUS_DISCONNECTED;
   SocketClose(client);
  }
//+------------------------------------------------------------------+
CSocketClient::CSocketClient(void)// �����������
//+------------------------------------------------------------------+
  {
   StringInit(msg,1025,0);
   timeout=20;
   server="192.168.2.104";
   port=7777;
   autocon=true;
   //msg="                                                                                                                                                                    ";
   connect= SOCKET_CLIENT_STATUS_DISCONNECTED;
   Connect();
  }
//+------------------------------------------------------------------+
int CSocketClient::ReadMessage(string &message)
//+------------------------------------------------------------------+
  {
   Connect();
   StringInit(message,1025,0);
   message="                                                                                                                                                   ";
   return((int)SocketReadString(client,message));
  };
//+------------------------------------------------------------------+
int CSocketClient::SendMessage(string message)
//+------------------------------------------------------------------+
  {
   bool ret=true;
   if(""==message) return(ret);
   Connect();
   if(!SocketWriteString(client,message+"\n"))
     {
      ret=false;
     }
   return(ret);
  };
//+------------------------------------------------------------------+
bool COscarClient::ReadMessage(string &uin,string &msg,uint &len)
//+------------------------------------------------------------------+
  {
   bool res=false;
   if(client.status!=ICQ_CLIENT_STATUS_CONNECTED && autocon) Connect();

   if(ICQReadMsg(client,uin,msg,len)) res=true;
   else if(client.status!=ICQ_CLIENT_STATUS_CONNECTED)
                          if(autocon) Connect();

   Sleep(100);
   return(res);
  };
//+------------------------------------------------------------------+
bool COscarClient::SendMessage(string UIN,string message)
//+------------------------------------------------------------------+
  {
   bool ret=true;
   if(""==message) return(ret);
   if(client.status!=ICQ_CLIENT_STATUS_CONNECTED && autocon) Connect();
   if(!ICQSendMsg(client,UIN,message))
     {
      ret=false;
      if(autocon) Connect();
     }
   return(ret);
  };
//+------------------------------------------------------------------+
bool COscarClient::Connect()
//+------------------------------------------------------------------+
  {

   if((TimeLocal()-timesave)>=timeout)
     {
      timesave= TimeLocal();
      connect = ICQConnect(client,server,port,login,password);

      PrintError(connect);
     }

   if(connect==ICQ_CONNECT_STATUS_OK) return(true);
   else return(false);

  };
//+------------------------------------------------------------------+
COscarClient::Disconnect()
//+------------------------------------------------------------------+
  {
   connect=ICQ_CLIENT_STATUS_DISCONNECTED;
   ICQClose(client);
  }
//+------------------------------------------------------------------+
COscarClient::COscarClient(void)// �����������
//+------------------------------------------------------------------+
  {
   StringInit(uin,10,0);
   StringInit(msg,4096,0);
   login=ICQ_Login;
   password=ICQ_Password;
   timeout=20;
   server="login.icq.com";
   port=5190;
   autocon=true;
   Connect();
  }
//+------------------------------------------------------------------+
void PrintError(uint status)
//+------------------------------------------------------------------+
  {
   string errstr;

   switch(status)
     {
      case ICQ_CONNECT_STATUS_OK:            errstr = "Status_OK";            break;
      case ICQ_CONNECT_STATUS_AUTH_ERROR:    errstr = "Status_AUTH_ERROR";    break;
      case ICQ_CONNECT_STATUS_CONNECT_ERROR: errstr = "Status_CONNECT_ERROR"; break;
      case ICQ_CONNECT_STATUS_RECV_ERROR:    errstr = "Status_RECV_ERROR";    break;
      case ICQ_CONNECT_STATUS_SEND_ERROR:    errstr = "Status_SEND_ERROR";    break;
      case 0:                                errstr = "PARAMETER_INCORRECT";  break;
      default:                        errstr=IntegerToString(status,8,' '); break;
     }
   printf("%s",errstr);
  }
//+------------------------------------------------------------------+
