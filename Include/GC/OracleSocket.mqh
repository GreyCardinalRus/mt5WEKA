//+------------------------------------------------------------------+
//|                                                 OracleSocket.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <GC\Socket.mqh>
#include <gc\Oracle.mqh>

#define host "encogserver"
//#define host "192.168.2.104"
//#define host "localhost"
#define port 7777
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CEasySocket:public COracleTemplate
  {
   SOCKET_CLIENT     client;
   // COscarClient      client;
   virtual double    forecast(string smbl,int shift,bool train);
   //virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("Easy");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CEasySocket::forecast(string smbl,int shift,bool train)
  {
   double res=0;
   int i=0;
   string msg=GetInputAsString(smbl,shift);
   if((client.status!=SOCKET_CONNECT_STATUS_OK) && 
      (SocketOpen(client,host,port)!=SOCKET_CONNECT_STATUS_OK))
     {
      Print("Opened Socket error"); return(0);
     }
   string str_out,str_in;
//if(""==msg) return(res);
   str_out="ENCOG,"+GetInputAsString(smbl,shift)+"\n";
   if(SocketWriteString(client,str_out)==SOCKET_CONNECT_STATUS__ERROR)
     {
      Print("Error, connection failed");return(0);
      //Sleep(3000);
      //if(SocketOpen(client,host,port)==SOCKET_CONNECT_STATUS_OK)
      //Print("Opened Socket");
     }

//  client.SendMessage(ICQ_Expert,GetInputAsString(smbl,shift));
//for(i=0;i<100||client.ReadMessage(client.uin,client.msg,client.len);i++)
     {
      Sleep(500);
      //client.ReadMessage(client.uin,client.msg,client.len);
     }
//     client.ReadMessage(client.uin,client.msg,client.len);
//  if(client.len>0 &&0<StringFind(client.msg,smbl,0))
     {
      //     Print(client.msg);
      //     if(0==StringFind(client.msg,"!Sell",0)) res=-1;
      //   if(0==StringFind(client.msg,"!Buy",0)) res=1;
      //      if(0==StringFind(client.msg,"!Sell",0) return(-1);
      //      if(0==StringFind(client.msg,"!Sell",0) return(-1);

      //      res = StringToDouble(client.msg);// есть ответ
      //     client.msg="";         
     }
   return(res);
  }
//+------------------------------------------------------------------+
