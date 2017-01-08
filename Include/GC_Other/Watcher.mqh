//+------------------------------------------------------------------+
//|                                                     Watcher.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.000"
#include <gc\CommonFunctions.mqh>


input string statusfilename = "status.txt";
input string reportfilename = "report.txt";
input string commandsfilename="commands.txt";
//// autoconnect if exist MustWatcher\data\set_bot
//int filehandle=FileOpen("MustWatcher\data\set_bot",FILE_READ|FILE_CSV|FILE_ANSI,':',CP_ACP);
//if(filehandle!=INVALID_HANDLE)
//  {
//   login="645990858";
//   password="Forex7";
//   Connect();
//   FileClose(filehandle);
//  }

//+------------------------------------------------------------------+
//|   Открывает/закрывает позиции и двигает стоп-лосы. РАБОТАЕТ!!    |
//+------------------------------------------------------------------+
class CWatcher
  {
private:
public:
   int               pospast;
   string            expname;
   string            ar_sSPAM[];
   int               changing;
   string            ar_sSTATUScur[];
   string            ar_sSTATUSpast[];
   string            Abzac;
   double            curbalance;
   datetime          lastUpdate;

public:
                     CWatcher(){Init();};
                    ~CWatcher(){DeInit();};
   void              Init(void);
   void              DeInit(void);
//   bool              Trailing();
   bool              Notify();
   bool              SendNotify();
   bool              SendStatus();
   bool              SendReport();
   bool              ReadCommands();
   bool              AddNotify(string str);
   bool              Run();
   //  bool              OnTick();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWatcher::Init()
  {
   //GlobalVariableTemp();
   lastUpdate=TimeCurrent();
   ArrayResize(ar_sSTATUScur,10);
   ArrayResize(ar_sSTATUSpast,10);
   expname="statusbot";
   pospast=0;
   ResetLastError();
   AddNotify("Starting watcher...");
   SendStatus();
   string filename=expname+"\\"+statusfilename;
   int    filehandle=FileOpen(filename,FILE_READ|FILE_TXT|FILE_ANSI,'\t',CP_ACP);
   if(filehandle!=INVALID_HANDLE)
     {
      if(FileSize(filehandle)<10)
        {
         FileClose(filehandle);
         return;
        }
      string statstr;

      statstr=FileReadString(filehandle);//StringToUpper(comstr);
      while(StringLen(statstr)>0)
        {
         AddNotify(statstr);
         statstr=FileReadString(filehandle);
        }
     }
   FileClose(filehandle);
   SendNotify();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWatcher::DeInit()
  {
   AddNotify("Stop watcher...");
//SendNotify();
//  SendStatus();
   string filename=expname+"\\"+statusfilename;
   int    filehandle=FileOpen(filename,FILE_READ|FILE_TXT|FILE_ANSI,'\t',CP_ACP);
   if(filehandle!=INVALID_HANDLE)
     {
      if(FileSize(filehandle)<10)
        {
         FileClose(filehandle);
         return;
        }
      string statstr;

      statstr=FileReadString(filehandle);//StringToUpper(comstr);
      while(StringLen(statstr)>0)
        {
         AddNotify(statstr);
         statstr=FileReadString(filehandle);
        }
     }
   FileClose(filehandle);
   SendNotify();
   Sleep(5000);
//FileDelete(expname+"\\"+spamfilename);
   FileDelete(expname+"\\"+statusfilename);
   FileDelete(expname+"\\"+reportfilename);
   FileDelete(expname+"\\"+commandsfilename);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWatcher::AddNotify(string str)
  {
   ArrayResize(ar_sSPAM,changing+1);
   ar_sSPAM[changing++]=str;//+ar_sSTATUScur[i];
                            //changing++;
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWatcher::Run(void)
  {
   ReadCommands();
   Trailing();
   Notify();
   SendNotify();
   if(AccountInfoDouble(ACCOUNT_BALANCE)==curbalance) return(true);
   curbalance=AccountInfoDouble(ACCOUNT_BALANCE);
   SendStatus();
   SendReport();
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWatcher::SendReport()
  {
   //if(AccountInfoDouble(ACCOUNT_BALANCE)==curbalance) return(true);
   //curbalance=AccountInfoDouble(ACCOUNT_BALANCE);
//--- request trade history
   HistorySelect(0,TimeCurrent());
   if(HistoryDealsTotal()<=0) return(true);
   string report_buffer[];
//string report_buffer_sorted[];
   ArrayResize(report_buffer,HistoryDealsTotal());
   int report_size=0,dig;
   string rts="|";
   string opentime,type,size,item,openprice,loss_lim,profit_lim,closetime,closeprice,commision,swap,profit;
   double opendeallots = 0;
   double opendealcomm = 0;
//datetime opendealtime;
//string opendealtype;
   double opendealprice=0;
   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
//--- for all deals
   for(uint i=0;i<total;i++)
     {
      if((bool)(ticket=HistoryDealGetTicket(i)))
        {
         if(HistoryDealGetInteger(ticket,DEAL_ENTRY)!=DEAL_ENTRY_OUT) continue;
         if(HistoryDealGetInteger(ticket,DEAL_TYPE)!=DEAL_TYPE_BUY && HistoryDealGetInteger(ticket,DEAL_TYPE)!=DEAL_TYPE_SELL) continue;
         if(HistoryDealGetInteger(ticket,DEAL_TYPE)==DEAL_TYPE_BUY) type="sell";
         if(HistoryDealGetInteger(ticket,DEAL_TYPE)==DEAL_TYPE_SELL)type="buy";
         item       = HistoryDealGetString(ticket,DEAL_SYMBOL);
         opentime   = TimeToString(HistoryDealGetInteger(ticket,DEAL_TIME),TIME_DATE|TIME_MINUTES);
         dig        = (int)SymbolInfoInteger(item,SYMBOL_DIGITS);
         openprice  = DoubleToString(HistoryDealGetDouble(ticket,DEAL_PRICE),dig);
         size       = DoubleToString(HistoryDealGetDouble(ticket,DEAL_VOLUME),2);
         loss_lim   = "";
         profit_lim = "";
         closetime  = TimeToString(HistoryDealGetInteger(ticket,DEAL_TIME),TIME_DATE|TIME_MINUTES);
         closeprice = DoubleToString(HistoryDealGetDouble(ticket,DEAL_PRICE),dig);
         commision  = DoubleToString(HistoryDealGetDouble(ticket,DEAL_COMMISSION),2);
         swap       = DoubleToString(HistoryDealGetDouble(ticket,DEAL_SWAP),2);
         profit     = DoubleToString(HistoryDealGetDouble(ticket,DEAL_PROFIT),2);

         report_buffer[report_size]=opentime+rts+type+rts+size+rts+item+rts+openprice+rts+loss_lim+rts+profit_lim+rts+closetime+rts+closeprice+rts+commision+rts+swap+rts+profit;
         report_size++;
         opendealprice=0;
         opendeallots=0;
         opendealcomm=0;
        }
     }
//--- если изменения есть то пишем файл report.txt
   ResetLastError();
   string filename=expname+"\\"+reportfilename;
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_CSV|FILE_ANSI,rts,CP_ACP);
   if(filehandle!=INVALID_HANDLE)
     {
      for(int i=0;i<report_size;i++)
        {
         FileWrite(filehandle,"@",report_buffer[i]);
        }
      FileWrite(filehandle,"#",DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2),AccountInfoString(ACCOUNT_CURRENCY));
      FileClose(filehandle);
     }
   else Print("Не удалось открыть файл ",reportfilename,", ошибка",GetLastError());
   return(true);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWatcher::SendStatus()
  {
   double sumprofit=AccountInfoDouble(ACCOUNT_PROFIT);
   double balance  =AccountInfoDouble(ACCOUNT_BALANCE);
   double equity   =AccountInfoDouble(ACCOUNT_EQUITY);
   string symset,order_type;
   int    tp,sl;
   double vol,open,profit;
//--- пишем инфу в status.txt 
   ArrayResize(ar_sSTATUScur,PositionsTotal());
   ResetLastError();
   string filename=expname+"\\"+statusfilename;
   int    filehandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_ANSI,'\t',CP_ACP);
   FileWrite(filehandle,"Balance = "+DoubleToString(balance,2)+" "+AccountInfoString(ACCOUNT_CURRENCY));
   for(int i=0;i<PositionsTotal() && filehandle!=INVALID_HANDLE;i++)
     {
      if(i==0)FileWrite(filehandle,Abzac);
      PositionGetSymbol(i);
      if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_BUY) order_type="buy";
      if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_SELL)order_type="sell";
      sl    =(int)PositionGetDouble(POSITION_SL);
      tp    =(int)PositionGetDouble(POSITION_TP);
      vol   =PositionGetDouble(POSITION_VOLUME);
      open  =PositionGetDouble(POSITION_PRICE_OPEN);
      profit=PositionGetDouble(POSITION_PROFIT);
      symset=PositionGetSymbol(i)+"  "+order_type+" "+DoubleToString(vol,2)+"  "+DoubleToString(profit,2)+" "+AccountInfoString(ACCOUNT_CURRENCY);
      FileWrite(filehandle,symset);
      ar_sSTATUScur[i]=symset;
      if(i==PositionsTotal()-1)
        {
         FileWrite(filehandle,"summa = "+DoubleToString(sumprofit,2)+" "+AccountInfoString(ACCOUNT_CURRENCY));
         FileWrite(filehandle,Abzac);
         FileWrite(filehandle,"Equity = "+DoubleToString(equity,2)+" "+AccountInfoString(ACCOUNT_CURRENCY));
        }
     }
   FileClose(filehandle);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWatcher::Notify()
  {
   bool ret=true; int i;
   ulong tic=0;

   HistorySelect(lastUpdate,TimeCurrent());
   int deals=HistoryDealsTotal();
   double profit;
   for(i=0;i<deals;i++)
     {
      tic=HistoryDealGetTicket(i);
      if(HistoryDealGetInteger(tic,DEAL_ENTRY)!=DEAL_ENTRY_OUT) continue;
      if(HistoryDealGetInteger(tic,DEAL_TYPE)!=DEAL_TYPE_BUY && HistoryDealGetInteger(tic,DEAL_TYPE)!=DEAL_TYPE_SELL) continue;
      profit=HistoryDealGetDouble(tic,DEAL_PROFIT);
      AddNotify("Result "+HistoryDealGetString(tic,DEAL_SYMBOL)+" "+(string)profit+", balance="+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2));
     }
   string symset,order_type;
   for(i=0;i<PositionsTotal();i++)
     {
      if(lastUpdate>PositionGetInteger(POSITION_TIME)) continue;
      if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_BUY) order_type="buy";
      if(PositionGetInteger(POSITION_TYPE)==ORDER_TYPE_SELL)order_type="sell";
      order_type+=" "+PositionGetSymbol(i)+" "+PositionGetString(POSITION_COMMENT);
      AddNotify(order_type);
     }
   lastUpdate=TimeCurrent()+1;
   return(ret);

//   if(pospast==0 && PositionsTotal()==0) return(true);
////--- ищем изменения в позициях
//   ArrayResize(ar_sSPAM,PositionsTotal()+pospast+changing);
//   int j;
////changing=0;
//   for( i=0;i<PositionsTotal();i++)
//     {
//      for(j=0;j<pospast && ArraySize(ar_sSTATUSpast)>=pospast;j++)
//        {
//         if(StringSubstr(ar_sSTATUScur[i],0,6)==StringSubstr(ar_sSTATUSpast[j],0,6))break;
//        }
//      if(j==pospast)
//        {
//         AddNotify("[position open] ");
//        }
//     }
//   for( i=0;i<pospast;i++)
//     {
//      for(j=0;j<PositionsTotal() && ArraySize(ar_sSTATUScur)>j && ArraySize(ar_sSTATUSpast)>i;j++)
//        {
//         if(StringSubstr(ar_sSTATUScur[j],0,6)==StringSubstr(ar_sSTATUSpast[i],0,6))break;
//        }
//      if(j==PositionsTotal())
//        {
//         AddNotify("[position closed] "+ar_sSTATUSpast[i]);
//         //changing++;
//        }
//     }
////---
//   ArrayResize(ar_sSTATUSpast,ArraySize(ar_sSTATUScur));
//   if(ArraySize(ar_sSTATUScur)>0) ArrayCopy(ar_sSTATUSpast,ar_sSTATUScur,0,0,WHOLE_ARRAY);
//   pospast=PositionsTotal();
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   CWatcher::SendNotify()
  {
   bool ret=true;
   if(changing==0) return(true);
//--- если изменения есть то пишем файл notify.txt
   ResetLastError();
   string filename=expname+"\\"+spamfilename;
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_ANSI,'\t',CP_ACP);
   if(filehandle!=INVALID_HANDLE)
     {
      for(int i=0;i<changing;i++)
        {FileWrite(filehandle,ar_sSPAM[i]);}
      FileClose(filehandle);
     }
   else Print("Не удалось открыть файл ",spamfilename,", ошибка",GetLastError());
   changing=0;

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWatcher::ReadCommands()
  {
//commandsfilename
   string filename=expname+"\\"+commandsfilename,comstr,oper,smb,rc;
   int filehandle=FileOpen(filename,FILE_READ|FILE_CSV|FILE_ANSI,' ',CP_ACP);
   if(filehandle!=INVALID_HANDLE)
     {
      if(FileSize(filehandle)<10)
        {
         //Print("Open  command ",filename);
         FileClose(filehandle);
         return(true);
        }

      //Print("Open  command ",filename);
      rc="";
      comstr=FileReadString(filehandle);//StringToUpper(comstr);
      rc+=StringSubstr(comstr,1+StringFind(comstr,";"));
      if(0==StringCompare(comstr,"TRADE;sell",false))
        {
         //oper=FileReadString(filehandle);
         smb=FileReadString(filehandle);
         rc+=" "+smb;
         NewOrder(smb,NewOrderSell,"icq");
        }
      else if(0==StringCompare(comstr,"TRADE;buy",false))
        {
         //oper=FileReadString(filehandle);
         smb=FileReadString(filehandle);
         rc+=" "+smb;
         NewOrder(smb,NewOrderBuy,"icq");
        }
      else
        {
         smb=FileReadString(filehandle);
         rc+=" "+smb;
        }
      FileClose(filehandle);
      //Print(RemoteControl.Run("",rc));
      FileDelete(expname+"\\"+commandsfilename);
     }
//else Print("Не удалось открыть файл ",spamfilename,", ошибка",GetLastError());
   return(true);
  }
//+------------------------------------------------------------------+
