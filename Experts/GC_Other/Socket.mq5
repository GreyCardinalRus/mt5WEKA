//+------------------------------------------------------------------+
//|                                                       Socket.mq5 |
//|                                                     GreyCardinal |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

//#include <GC\Socket.mqh>
#include <GC\mt5_connect.mqh>

//#define host "encogserver"
#define host "192.168.2.104"
//#define host "localhost"
#define port 7777

CSocketClient client;
//SOCKET_CLIENT client;
MqlTick tick;
//+------------------------------------------------------------------+
int OnInit()
//+------------------------------------------------------------------+
  {
   if(client.Connect()==SOCKET_CONNECT_STATUS_OK)
      Print("Socket Opened");
   EventSetTimer(6);
   return(0);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
//+------------------------------------------------------------------+
  {
//SocketWriteString(client,"!Exit\n");
   client.Disconnect();
   Print("Socket Closed");
   EventKillTimer();
  }
//+------------------------------------------------------------------+
void OnTimer()
//+------------------------------------------------------------------+
  {
   static int nm=0;
   string str_out,str_in;
   StringInit(str_in,4096,0);
   uint r=0;
   if(SymbolInfoTick(_Symbol,tick))
     {

      str_out=StringFormat("%s %s %s %s %s",IntegerToString(nm++),_Symbol,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),
                           DoubleToString(tick.bid,_Digits),DoubleToString(tick.ask,_Digits));

      //if(client.status!=SOCKET_CONNECT_STATUS_OK)
      //  {
      //   if(SocketOpen(client,host,port)==SOCKET_CONNECT_STATUS_OK)
      //      Print("Socket Opened");
      //   else   Print("Socket NotOpened ");
      //  }

      //if((r=SocketSendReceive(client,str_out+"\n",str_in))==SOCKET_CONNECT_STATUS__ERROR)
      //if((r=SocketReadString(client,str_in))==SOCKET_CONNECT_STATUS__ERROR)
      if((r=client.SendMessage(str_out))==SOCKET_CONNECT_STATUS__ERROR)
        {
         Print("Error, connection failed");
         //     Sleep(3000);
         //if(SocketOpen(client,host,port)==SOCKET_CONNECT_STATUS_OK)
         //   Print("Opened Socket");
        }
      //else Print("get:",r," <",str_in,">");
      //r=SocketReadString(client,str_in);
      //Print("get:",r," <",str_in,">");
     }
   if((r=client.ReadMessage(str_in))>0)
     {
      Print("get...",r," ",str_in);
     }
  }
//+------------------------------------------------------------------+
