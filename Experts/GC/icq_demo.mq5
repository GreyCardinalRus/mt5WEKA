//+------------------------------------------------------------------+
//|                                                    icq_demo.mq5  |
//|              Copyright Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <gc\icq_mql5.mqh>

COscarClient client;
//+------------------------------------------------------------------+
int OnInit()
//+------------------------------------------------------------------+
  {
   printf("Start ICQ Client");

   client.Connect();
   EventSetTimer(6);
   return(0);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
//+------------------------------------------------------------------+
  {
   client.Disconnect();
   printf("Stop ICQ Client");
  }
//+------------------------------------------------------------------+
//void OnTick()
//+------------------------------------------------------------------+
void OnTimer()
  {
   string text;
   static datetime time_out;
   MqlTick last_tick;

// чтение сообщений
   while(client.ReadMessage(client.uin,client.msg,client.len))
     {
      printf("Receive: %s, %s, %u",client.uin,client.msg,client.len);
     }

// передача котировок каждые 30 сек
   if((TimeCurrent()-time_out)>=30)
     {
      time_out=TimeCurrent();
      SymbolInfoTick(Symbol(),last_tick);

      text=Symbol()+" BID:"+DoubleToString(last_tick.bid,Digits())+
           " ASK:"+DoubleToString(last_tick.ask,Digits());

      if(client.SendMessage(ICQ_Expert,//<- номер получателя 
         text)) //<- текст сообщения 
         printf("Send: "+text);
     }
  }
//+------------------------------------------------------------------+
