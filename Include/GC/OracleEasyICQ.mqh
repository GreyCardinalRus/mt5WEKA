//+------------------------------------------------------------------+
//|                                                OracleEasyICQ.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <gc\mt5_connect.mqh>
#include <gc\Oracle.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CEasyICQ:public COracleTemplate
  {
   COscarClient      client;
   virtual double    forecast(string smbl,int shift,bool train);
   //virtual double    forecast(string smbl,datetime startdt,bool train);
   virtual string    Name(){return("Easy");};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CEasyICQ::forecast(string smbl,int shift,bool train)
  {
   double res=0;
   int i=0;
   string msg=GetInputAsString(smbl,shift);
   //if(""==msg) return(res);
   client.SendMessage(ICQ_Expert,GetInputAsString(smbl,shift));
   //for(i=0;i<100||client.ReadMessage(client.uin,client.msg,client.len);i++)
      {
        Sleep(500);
        //client.ReadMessage(client.uin,client.msg,client.len);
      }
      client.ReadMessage(client.uin,client.msg,client.len);
   if(client.len>0 &&0<StringFind(client.msg,smbl,0))
      {
      Print(client.msg);
      if(0==StringFind(client.msg,"!Sell",0)) res=-0.99;
      if(0==StringFind(client.msg,"!Buy",0)) res=0.99;
//    
      if(0==StringFind(client.msg,"!CloseSell",0)) res=0.99;
      if(0==StringFind(client.msg,"!CloseBuy",0)) res=-0.99;
//      
      
//      res = StringToDouble(client.msg);// ���� �����
      client.msg="";         
      }   
   return(res);
  }
//+------------------------------------------------------------------+
