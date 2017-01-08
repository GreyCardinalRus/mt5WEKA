//+------------------------------------------------------------------+
//|                                                     icq_mql5.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

//returned values of ICQConnect functions
#define ICQ_CONNECT_STATUS_OK					0xFFFFFFFF
#define ICQ_CONNECT_STATUS_RECV_ERROR		0xFFFFFFFE
#define ICQ_CONNECT_STATUS_SEND_ERROR		0xFFFFFFFD
#define ICQ_CONNECT_STATUS_CONNECT_ERROR	0xFFFFFFFC
#define ICQ_CONNECT_STATUS_AUTH_ERROR     0xFFFFFFFB

enum ENUM_STATE {STATE_PROCESSING=0,STATE_CONNECTED=1,STATE_DISCONNECTED=2};
//+------------------------------------------------------------------+
//|   ICQ_CLIENT                                                     |
//+------------------------------------------------------------------+
struct ICQ_CLIENT
  {
   uchar             status;   // connection status code 
   ushort            sequence; // sequence counter 
   ulong             sock;     // socket number
  };

//+------------------------------------------------------------------+
//|   DLL import                                                     |
//+------------------------------------------------------------------+
#import "icq_mql5.dll"
uint ICQConnect(ICQ_CLIENT &cl,string host,uint port,string login,string pass,uint timeout=20000);
void ICQClose(ICQ_CLIENT &cl);
uint ICQSendMsg(ICQ_CLIENT &cl,string uin,string msg);
uint ICQReadMsg(ICQ_CLIENT &cl,string &uin,string &msg,uint &len);
#import "icq_mql564.dll"
uint ICQConnect(ICQ_CLIENT &cl,string host,uint port,string login,string pass,uint timeout=20000);
void ICQClose(ICQ_CLIENT &cl);
uint ICQSendMsg(ICQ_CLIENT &cl,string uin,string msg);
uint ICQReadMsg(ICQ_CLIENT &cl,string &uin,string &msg,uint &len);
#import
//+------------------------------------------------------------------+
//|   COscarClient                                                   |
//+------------------------------------------------------------------+
class COscarClient
  {
private:
   ICQ_CLIENT        client;        // for storage of connection info
   uint              connect;       // connection state flag
   datetime          timesave;      // last server connection time
   datetime          time_in;       // last time of read post
   ENUM_STATE        state;         // state
public:
   string            uin;           // buffer to store the sender UIN of the message received
   string            msg;           // buffer to store the received message
   uint              len;           // number of characters in the received message
   //---
   string            login;         // sender UIN number
   string            password;      // password of UIN 
   string            server;        // server name    
   uint              port;          // port  
   uint              timeout;       // timeout in seconds between the server connection attempts
   bool              autocon;       // automatic connection
   //---
   void              COscarClient();// constructor for class variables initialization
   bool              Connect(void); // Connect to server
   void              Disconnect(void);// Disconnect from the server
   ENUM_STATE        State(void){return(state);};// State
   bool              SendMessage(string user,string message);// Send message  
   bool              ReadMessage(string &user,string &message,uint &length); // Read message
   void              Login(const string text){login=text;};//Get Login
   string            Login(){return(login);};//Set Login
   void              Password(const string text){password=text;};//Set Passowrd
   string            Password(){return(password);};//Get Password
  };
//+------------------------------------------------------------------+
//|   ReadMessage                                                    |
//+------------------------------------------------------------------+
bool COscarClient::ReadMessage(string &user,string &message,uint &length)
  {
   bool res=false;
   bool read=false;
   
   if(_IsX64)
      read=icq_mql564::ICQReadMsg(client,user,message,length);
   else
      read=icq_mql5::ICQReadMsg(client,user,message,length);

   StringTrimLeft(user);
   StringTrimRight(user);

   StringTrimLeft(message);
   StringTrimRight(message);

   if(read) res=true;
   else if(client.status!=STATE_CONNECTED)
                          if(autocon) Connect();

   Sleep(0);
   return(res);
  };
//+------------------------------------------------------------------+
//|   SendMessage                                                    |
//+------------------------------------------------------------------+
bool COscarClient::SendMessage(string UIN,string message)
  {
   bool ret=true;
   bool send=false;

   if(_IsX64)
      send=icq_mql564::ICQSendMsg(client,UIN,message);
   else
      send=icq_mql5::ICQSendMsg(client,UIN,message);

   if(!send)
     {
      ret=false;
      if(autocon) Connect();
     }
   return(ret);
  };
//+------------------------------------------------------------------+
//|   Connect                                                        |
//+------------------------------------------------------------------+
bool COscarClient::Connect()
  {

   if((TimeLocal()-timesave)>=timeout)
     {
      timesave=TimeLocal();

      if(_IsX64)
         connect=icq_mql564::ICQConnect(client,server,port,login,password);
      else
         connect=icq_mql5::ICQConnect(client,server,port,login,password);

      if(connect==ICQ_CONNECT_STATUS_OK)state=STATE_CONNECTED;
      else state=STATE_DISCONNECTED;

      PrintError(connect);
     }

   if(connect==ICQ_CONNECT_STATUS_OK)
     {
      return(true);
     }
   else return(false);

  };
//+------------------------------------------------------------------+
//|   Disconnect                                                     |
//+------------------------------------------------------------------+
COscarClient::Disconnect()
  {
   connect  = ICQ_CONNECT_STATUS_OK;
   state    = STATE_DISCONNECTED;

   if(_IsX64) icq_mql564::ICQClose(client);
   else       icq_mql5::ICQClose(client);
  }
//+------------------------------------------------------------------+
//|   COscarClient                                                   |
//+------------------------------------------------------------------+
COscarClient::COscarClient(void)
  {
   StringInit(uin,10,0);
   StringInit(msg,4096,0);
   timeout = 20;
   autocon = true;
   state=STATE_DISCONNECTED;
  }
//+------------------------------------------------------------------+
//|   PrintError                                                     |
//+------------------------------------------------------------------+
void PrintError(uint status)
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
      default:                               errstr = IntegerToString(status,8,' '); break;
     }
   printf("%s",errstr);
  }
//+------------------------------------------------------------------+
