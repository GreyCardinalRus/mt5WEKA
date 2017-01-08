//+------------------------------------------------------------------+
//|                                                    icq_demo.mq5  |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <icq_mql5.mqh>
COscarClient client;
//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   printf("Start ICQ Client");

   client.login    = "610043094";   //<- login
   client.password = "password";   //<- password
   client.server   = "login.icq.com";
   client.port     = 5190;
   client.Connect();

   EventSetTimer(1);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   client.Disconnect();
   printf("Stop ICQ Client");
  }
//+------------------------------------------------------------------+
//|   OnTimer                                                        |
//+------------------------------------------------------------------+
void OnTimer()
  {
   string text;
   static datetime time_out;
   MqlTick last_tick;

//--- read messages
   while(client.ReadMessage(client.uin,client.msg,client.len))
     {
      printf("Receive: %s, %s, %u",client.uin,client.msg,client.len);
     }

//--- send quotes every 30 sec.
   if((TimeCurrent()-time_out)>=30)
     {
      time_out=TimeCurrent();
      SymbolInfoTick(_Symbol,last_tick);

      text=_Symbol+" BID:"+DoubleToString(last_tick.bid,_Digits)+
           " ASK:"+DoubleToString(last_tick.ask,_Digits);

      if(client.SendMessage("266690424",//<- recipient account
         text))                         //<- message text
         printf("Send: "+text);
     }
  }
//+------------------------------------------------------------------+
