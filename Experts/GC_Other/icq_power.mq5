//+------------------------------------------------------------------+
//|                                                    icq_power.mq5 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <icq_mql5.mqh>
#include <icq_power.mqh>
#include <Trade\Trade.mqh>

long   SL = 30;
long   TP = 50;
double p0 = 0.8;
double p1 = 1.2;
double p2 = 22.5;

COscarClient client;
//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   printf("Start ICQ Client");
//---   
   client.login      =  "610043094";     //<- login
   client.password   =  "password";     //<- password
   client.server     =  "login.icq.com";
   client.port       =  5190;
   client.autocon    =  true;

   client.Connect();
//---
   EventSetTimer(1);
//---
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
//--- read messages
   if(client.ReadMessage(client.uin,client.msg,client.len))
     {
      PrintFormat("Receive: %s, %s %d",client.uin,client.msg,client.len);
      Run(client.uin,client.msg);
     }
  }
//+------------------------------------------------------------------+
//|   Run                                                            |
//+------------------------------------------------------------------+
void Run(string UIN,string cmdstr)
  {
   string part[5];
   string resp;
   string text="";
   string symbol,type;
   int digits;
   bool ret;
   MqlDateTime dt;
   MqlTradeRequest request;
   MqlTradeResult result;
   CTrade trade;

   if(ParseString(cmdstr,part))
     {

      resp=StringFormat("# %s %s %s %s %s #\n",part[0],part[1],part[2],part[3],part[4]);

      if(part[0]==op[0]) //?
        {

         //--- help
         if(part[1]==cmd[0])
           {

            client.SendMessage(UIN,resp+
                               "[?|!][command][parameters][value]\n"+
                               "help - help on commands;\n"+
                               "info - account info;\n"+
                               "symb [symbol] - quotes;\n"
                               "ords [symbol] [close|sl|tp] [value] - orders;\n"+
                               "param [sl|tp|p0|p1|p2] [value] - variables;\n"+
                               "close - close terminal;\n"+
                               "shdwn - turn off the PC; \\ n"
                               );

           }
         else
         if(part[1]==cmd[1]) //--- info

            client.SendMessage(UIN,resp+
                               StringFormat("Balance: %.2f; Profit: %.2f",
                               AccountInfoDouble(ACCOUNT_BALANCE),AccountInfoDouble(ACCOUNT_PROFIT)));

         //--- symb
         else if(part[1]==cmd[2])
           {
            type=part[2];
            if(type=="")// вывод всех имеющихся в MarketWatch
              {
               TimeCurrent(dt);
               text=text+StringFormat("%4d/%02d/%02d %02d:%02d:%02d\n",dt.year,dt.mon,dt.day,dt.hour,dt.min,dt.sec);

               for(int i=0; i<SymbolsTotal(true); i++)
                 {
                  symbol=SymbolName(i,true);
                  StringToUpper(symbol);
                  digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
                  text=text+StringFormat("%s %s/%s \n",symbol,DoubleToString(SymbolInfoDouble(symbol,SYMBOL_BID),digits),DoubleToString(SymbolInfoDouble(symbol,SYMBOL_ASK),digits));
                 }
              }
            else
              {
               ret=false;

               for(int i=0; i<SymbolsTotal(true); i++)
                 {
                  symbol=SymbolName(i,true);
                  StringToUpper(symbol);
                  if(symbol==type) ret=true;
                 }

               if(ret)
                 {
                  digits=(int)SymbolInfoInteger(type,SYMBOL_DIGITS);
                  text=StringFormat("%s %s/%s",type,DoubleToString(SymbolInfoDouble(type,SYMBOL_BID),digits),DoubleToString(SymbolInfoDouble(type,SYMBOL_ASK),digits));
                 }
               else
                 {
                  if(SymbolSelect(type,true)) text="symbol added";
                  else text=type+"-error in symbol name";
                 }
              }
            client.SendMessage(UIN,resp+text);
           }
         
         //--- ords
         else if(part[1]==cmd[3])
           {

            if(PositionsTotal()==0) text="there isn't any opened orders";
            for(int i=0; i<PositionsTotal(); i++)
              {
               symbol=PositionGetSymbol(i);
               if(PositionSelect(symbol))
                 {
                  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) type="buy";
                  else type="sell";

                  digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
                  text=text+StringFormat("%i. %s %s %.2f price=%s SL=%s TP=%s profit=%.2f\n",
                                         i+1,symbol,type,PositionGetDouble(POSITION_VOLUME),DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                                         DoubleToString(PositionGetDouble(POSITION_SL),digits),DoubleToString(PositionGetDouble(POSITION_TP),digits),PositionGetDouble(POSITION_PROFIT));
                 }
              }
            client.SendMessage(UIN,resp+text);
           }

         //--- param
         else if(part[1]==cmd[4])
           {
            if(part[2]=="") text=StringFormat("SL=%i; TP=%i; p0=%.5f; p1=%.5f; p2=%.5f",SL,TP,p0,p1,p2);
            else if(part[2]=="SL") text = StringFormat("SL= %i"  , SL);
            else if(part[2]=="TP") text = StringFormat("TP= %i"  , TP);
            else if(part[2]=="P0") text = StringFormat("p0= %.5f", p0);
            else if(part[2]=="P1") text = StringFormat("p1= %.5f", p1);
            else if(part[2]=="P2") text = StringFormat("p2= %.5f", p2);
            else text=StringFormat("%s - invalid parameter",part[2]);
            client.SendMessage(UIN,resp+text);
           }
        }
      //---
      else if(part[0]==op[1]) //!
        {
         //---
         if(part[1]==cmd[3]) //ords
           {

            for(int i=0; i<PositionsTotal(); i++)
              {
               symbol=PositionGetSymbol(i);
               StringToUpper(symbol);

               if(symbol==part[2])
                  if(PositionSelect(symbol))
                    {
                     //--- SL
                     if(part[3]=="SL")
                       {
                        if(IsDouble(part[4]))
                          {
                           trade.PositionModify(symbol,StringToDouble(part[4]),PositionGetDouble(POSITION_TP));
                           text=trade.ResultRetcodeDescription();
                          }
                        else    text=part[3]+"- invalid data";
                       }
                     //--- TP
                     else if(part[3]=="TP")
                       {
                        if(IsDouble(part[4]))
                          {
                           trade.PositionModify(symbol,PositionGetDouble(POSITION_SL),StringToDouble(part[4]));
                           text=trade.ResultRetcodeDescription();
                          }
                        else    text=part[3]+"- invalid data";
                       }
                     //--- CLOSE
                     else if(part[3]=="CLOSE")
                       {
                        if(IsInteger(part[4]))
                          {
                           trade.PositionClose(part[2]);
                           text=trade.ResultRetcodeDescription();
                          }
                        else text=part[4]+"- invalid parameter";
                       }
                     else text=part[3]+"- invalid parameter";
                    }
               else text=part[2]+"- invalid parameter";
              }
            client.SendMessage(UIN,resp+text);
           }

         //--- param
         if(part[1]==cmd[4])
           {

            if(part[2]=="SL")
              {
               if(IsInteger(part[3]))
                 {
                  SL=StringToInteger(part[3]);
                  text=part[2]+"="+part[3];
                 }
               else    text=part[3]+"- invalid data";
              }
            else if(part[2]=="TP")
              {
               if(IsInteger(part[3]))
                 {
                  TP=StringToInteger(part[3]);
                  text=part[2]+"="+part[3];
                 }
               else    text=part[3]+"- invalid data";
              }
            else if(part[2]=="P0")
              {
               if(IsDouble(part[3]))
                 {
                  p0=StringToDouble(part[3]);
                  text=part[2]+"="+part[3];
                 }
               else    text=part[3]+"- invalid data";
              }

            else if(part[2]=="P1")
              {
               if(IsDouble(part[3]))
                 {
                  p1=StringToDouble(part[3]);
                  text=part[2]+"="+part[3];
                 }
               else    text=part[3]+"- invalid data";
              }

            else if(part[2]=="P2")
              {
               if(IsDouble(part[3]))
                 {
                  p2=StringToDouble(part[3]);
                  text=part[2]+"="+part[3];
                 }
               else    text=part[3]+"- invalid data";
              }

            else text=StringFormat("%s - invalid parameter",part[2]);

            client.SendMessage(UIN,resp+text);
           }
         //---
         if(part[1]==cmd[6]) //close
           {
            client.SendMessage(UIN,resp+"completed: "+(TerminalClose(0)?"yes":"no"));
           }
         //---
         if(part[1]==cmd[7]) //shdwn
           {
            client.SendMessage(UIN,resp+"completed: "+(ShutdownWindows()?"yes":"no"));
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|   IsInteger                                                      |
//+------------------------------------------------------------------+
bool IsInteger(string value)
  {
   for(int i=0; i<StringLen(value); i++)
      if(!((StringGetCharacter(value,i)>='0') && (StringGetCharacter(value,i)<='9'))) return(false);
   return(true);
  }
//+------------------------------------------------------------------+
//|   IsDouble                                                       |
//+------------------------------------------------------------------+
bool IsDouble(string value)
  {
   for(int i=0;i<StringLen(value);i++)
      if(!(((StringGetCharacter(value,i)>='0') && (StringGetCharacter(value,i)<='9')) || (StringGetCharacter(value,i)=='.'))) return(false);
   return(true);
  }
//+------------------------------------------------------------------+
