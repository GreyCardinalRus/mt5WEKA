//+------------------------------------------------------------------+
//|                                                   WatcherICQ.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <gc\Watcher.mqh>
#include <gc_other\icq_mql5.mqh>
#include <gc_other\icq_power.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CWatcherICQ:public  CWatcher
  {
   COscarClient      client;
public:
                     CWatcherICQ();
                    ~CWatcherICQ();
   bool              Run();
   void              Comm(string UIN,string cmdstr);
   bool              SendNotify(string UIN="");
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWatcherICQ::~CWatcherICQ(void)
  {
   client.Disconnect();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWatcherICQ::CWatcherICQ(void)
  {
   CWatcher::Init();//SendNotify();
   //int filehandle=FileOpen("MustWatcher\data\set_bot",FILE_READ|FILE_CSV|FILE_ANSI,':',CP_ACP);
   //if(filehandle!=INVALID_HANDLE)
   //  {
   //   client.login=StringSubstr(FileReadString(filehandle),3);//"645990858";
   //   client.password=FileReadString(filehandle);//"Forex7";
   //   client.Connect();
   //   FileClose(filehandle);
   //  }
   //else
   //  {
      //client.login="645990858";
      //client.password="Forex7";
      client.Connect();
 //    }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CWatcherICQ::Run()
  {
// чтение сообщений
   while(client.ReadMessage(client.uin,client.msg,client.len))
     {
      Comm(client.uin,client.msg);
      printf("Receive: %s, %s %u ",client.uin,client.msg,client.len);
     }
   CWatcher::Run();
   SendNotify();

   return(true);
  }
//+------------------------------------------------------------------+
bool   CWatcherICQ::SendNotify(string UIN)
  {
   bool ret=true;
   if(changing==0) return(true);
  // if(""==UIN) UIN=ICQ_Master;
//--- если изменения есть то пишем файл notify.txt
   ResetLastError();
   for(int i=0;i<changing;i++)
     {
      if(""!=ar_sSPAM[i]) client.SendMessage(UIN,ar_sSPAM[i]);
     }
   changing=0;

   return(true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CWatcherICQ::Comm(string UIN,string cmdstr)
//+------------------------------------------------------------------+
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
//CTrade trade;

   if(ParseString(cmdstr,part))
     {

      resp=StringFormat("# %s %s %s %s %s #\n",part[0],part[1],part[2],part[3],part[4]);

      if(part[0]==op[0]) //?
        {

         //--------------------------------------------------------
         if(part[1]==cmd[0]) //help
            //--------------------------------------------------------
           {
            client.SendMessage(UIN,resp+
                               "[?|!][команда][параметр][значение]\n"+
                               "help - справка о командах;\n"+
                               "info - состояние счета;\n"+
                               "symb [символ] - котировки;\n"
                               "ords [символ] [close|sl|tp] [значение] - ордера;\n"+
                               "param [sl|tp|p0|p1|p2] [значение] - переменные;\n"+
                               "close - закрыть терминал;\n"+
                               "shdwn - выключить ПК;\n"
                               );
           }
         //--------------------------------------------------------
         else if(part[1]==cmd[1]) //info
         //--------------------------------------------------------
            client.SendMessage(UIN,resp+
                               StringFormat("Balance: %.2f; Profit: %.2f",
                               AccountInfoDouble(ACCOUNT_BALANCE),AccountInfoDouble(ACCOUNT_PROFIT)));

         //--------------------------------------------------------
         else if(part[1]==cmd[2]) //symb
         //--------------------------------------------------------
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
                  if(SymbolSelect(type,true)) text="инструмент добавлен";
                  else text=type+"-ошибка в наименовании инструмента";
                 }
              }
            client.SendMessage(UIN,resp+text);
           }
         //--------------------------------------------------------
         else if(part[1]==cmd[3]) //ords
         //--------------------------------------------------------
           {

            if(PositionsTotal()==0) text="открытых ордеров нет";
            for(int i=0; i<PositionsTotal(); i++)
              {
               symbol=PositionGetSymbol(i);
               if(PositionSelect(symbol))
                 {
                  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) type="buy";
                  else type="sell";

                  digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
                  text=text+StringFormat("%i. %s %s %.2f price=%s sl=%s tp=%s profit=%.2f\n",
                                         i+1,symbol,type,PositionGetDouble(POSITION_VOLUME),DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                                         DoubleToString(PositionGetDouble(POSITION_SL),digits),DoubleToString(PositionGetDouble(POSITION_TP),digits),PositionGetDouble(POSITION_PROFIT));
                 }
              }
            client.SendMessage(UIN,resp+text);
           }

         //--------------------------------------------------------
         //         else if(part[1]==cmd[4]) //param
         //         //--------------------------------------------------------
         //           {
         //            if(part[2]== "")  text = StringFormat("sl=%i; tp=%i; p0=%.5f; p1=%.5f; p2=%.5f", s_l, t_p, p0, p1, p2);
         //            else if(part[2]=="SL") text = StringFormat("sl= %i"  , s_l);
         //            else if(part[2]=="TP") text = StringFormat("tp= %i"  , t_p);
         //            else if(part[2]=="P0") text = StringFormat("p0= %.5f", p0);
         //            else if(part[2]=="P1") text = StringFormat("p1= %.5f", p1);
         //            else if(part[2]=="P2") text = StringFormat("p2= %.5f", p2);
         //            else text=StringFormat("%s - неверный параметр",part[2]);
         //
         //            client.SendMessage(UIN,resp+text);
         //
         //           }
        }
      //--------------------------------------------------------
      else if(part[0]==op[1]) //!
      //--------------------------------------------------------
        {
         //--------------------------------------------------------
         if(part[1]==cmd[3]) //ords
            //--------------------------------------------------------
           {

            for(int i=0; i<PositionsTotal(); i++)
              {
               symbol=PositionGetSymbol(i);
               StringToUpper(symbol);

               if(symbol==part[2])
                  if(PositionSelect(symbol))
                    {

                     //--------------------------------------------------------
                     if(part[3]=="SL")
                        //--------------------------------------------------------
                       {
                        if(IsDouble(part[4]))
                          {
                           //trade.PositionModify(symbol,StringToDouble(part[4]),PositionGetDouble(POSITION_TP));
                           //text=trade.ResultRetcodeDescription();
                          }
                        else    text=part[3]+"-неверные данные";
                       }
                     //--------------------------------------------------------
                     else if(part[3]=="TP")
                     //--------------------------------------------------------
                       {
                        if(IsDouble(part[4]))
                          {
                           //trade.PositionModify(symbol,PositionGetDouble(POSITION_SL),StringToDouble(part[4]));
                           //text=trade.ResultRetcodeDescription();
                          }
                        else    text=part[3]+"-неверные данные";
                       }
                     //--------------------------------------------------------
                     else if(part[3]=="CLOSE")
                     //--------------------------------------------------------
                       {
                        if(IsInteger(part[4]))
                          {
                           //trade.PositionClose(part[2],(ulong)part[4]);
                           //text=trade.ResultRetcodeDescription();
                          }
                        else text=part[4]+"- неверный параметр";
                       }
                     else text=part[3]+"- неверный параметр";
                    }
               else text=part[2]+"- неверный параметр";
              }
            client.SendMessage(UIN,resp+text);
           }

         //--------------------------------------------------------
         if(part[1]==cmd[4]) //param
            //--------------------------------------------------------
           {

            if(part[2]=="SL")
              {
               if(IsInteger(part[3]))
                 {
                  //s_l=StringToInteger(part[3]);
                  text=part[2]+"="+part[3];
                 }
               else    text=part[3]+"-неверные данные";
              }
            else if(part[2]=="TP")
              {
               if(IsInteger(part[3]))
                 {
                  //t_p=StringToInteger(part[3]);
                  text=part[2]+"="+part[3];
                 }
               else    text=part[3]+"-неверные данные";
              }
            else if(part[2]=="P0")
              {
               if(IsDouble(part[3]))
                 {
                  //p0=StringToDouble(part[3]);
                  text=part[2]+"="+part[3];
                 }
               else    text=part[3]+"-неверные данные";
              }

            else if(part[2]=="P1")
              {
               if(IsDouble(part[3]))
                 {
                  //p1=StringToDouble(part[3]);
                  text=part[2]+"="+part[3];
                 }
               else    text=part[3]+"-неверные данные";
              }

            else if(part[2]=="P2")
              {
               if(IsDouble(part[3]))
                 {
                  //p2=StringToDouble(part[3]);
                  text=part[2]+"="+part[3];
                 }
               else    text=part[3]+"-неверные данные";
              }

            else text=StringFormat("%s - неверный параметр",part[2]);

            client.SendMessage(UIN,resp+text);
           }

         //--------------------------------------------------------
         if(part[1]==cmd[6]) //close
            //--------------------------------------------------------
           {
            client.SendMessage(UIN,resp+"выполнено: "+(TerminalClose(0)?"да":"нет"));
           }

         //--------------------------------------------------------
         if(part[1]==cmd[7]) //shdwn
            //--------------------------------------------------------
           {
            //client.SendMessage(UIN, resp + "выполнено: " + (ShutdownWindows()?"да":"нет"));
           }
        }
     }
  }
//+------------------------------------------------------------------+
bool IsInteger(string value)
//+------------------------------------------------------------------+
  {
   for(int i=0; i<StringLen(value); i++)
      if(!((StringGetCharacter(value,i)>='0') && (StringGetCharacter(value,i)<='9'))) return(false);
   return(true);
  }
//+------------------------------------------------------------------+
bool IsDouble(string value)
//+------------------------------------------------------------------+
  {
   for(int i=0;i<StringLen(value);i++)
      if(!(((StringGetCharacter(value,i)>='0') && (StringGetCharacter(value,i)<='9')) || (StringGetCharacter(value,i)=='.'))) return(false);
   return(true);
  }
//+------------------------------------------------------------------+
