//+------------------------------------------------------------------+
//|                                                  MustWatcher.mqh |
//|                               Leonid Salavatov [MUSTADDON]© 2010 |
//+------------------------------------------------------------------+
#property copyright "Leonid Salavatov [MUSTADDON]© 2010"
#property link      "mustaddon@gmail.com"
#property version   "1.2"
#include <gc\CommonFunctions.mqh>
#include <gc\RemoteControl.mqh>
//---- inputs
input string statusfilename = "status.txt";
input string reportfilename = "report.txt";
input string commandsfilename="commands.txt";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMustWatcher
  {
private:
   //---- vars
   string            expname;
   string            ar_sSTATUScur[];
   string            ar_sSTATUSpast[];
   string            ar_sSPAM[];
   int               codepage;
   int               pospast;
   string            Abzac;
   double            curbalance;
   CRemoteControl    RemoteControl;
   //+------------------------------------------------------------------+
   //| Expert initialization function                                   |
   //+------------------------------------------------------------------+
public:
                     CMustWatcher();
                    ~CMustWatcher();
   void              OnTick();
private:
   void              WriteStatus();
   void              WriteNotify();
   void              WriteReport();
   void              ReadCommands();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMustWatcher::CMustWatcher()
  {
   expname="statusbot";
   codepage=CP_ACP;
   pospast=0;
   Abzac="------------------";
   curbalance=0.0;
   WriteStatus();
   WriteReport();
//---
   ResetLastError();
   string filename=expname+"\\"+spamfilename;
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_ANSI,'\t',codepage);
   if(filehandle!=INVALID_HANDLE)
     {
      FileWrite(filehandle,"Starting expert '"+expname+"'");
      FileClose(filehandle);
     }
   else Print("Не удалось открыть файл ",spamfilename,", ошибка",GetLastError());
//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void CMustWatcher::~CMustWatcher()
  {
//---
   FileDelete(expname+"\\"+statusfilename);
   FileDelete(expname+"\\"+spamfilename);
   FileDelete(expname+"\\"+reportfilename);
  string filename=expname+"\\"+spamfilename;
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_ANSI,'\t',codepage);
   if(filehandle!=INVALID_HANDLE)
     {
      FileWrite(filehandle,"Stop expert '"+expname+"'");
      FileClose(filehandle);
     }
 
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void CMustWatcher::OnTick()
  {
   WriteStatus();
   WriteNotify();
   WriteReport();
   ReadCommands();
  }
//+------------------------------------------------------------------+
void CMustWatcher::WriteStatus()
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
   int    filehandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_ANSI,'\t',codepage);
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
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMustWatcher::WriteNotify()
  {
   if(pospast==0 && PositionsTotal()==0) return;
//--- ищем изменения в позициях
   ArrayResize(ar_sSPAM,PositionsTotal()+pospast);
   int j,changing=0;
   for(int i=0;i<PositionsTotal();i++)
     {
      for(j=0;j<pospast;j++) {if(StringSubstr(ar_sSTATUScur[i],0,6)==StringSubstr(ar_sSTATUSpast[j],0,6))break;}
      if(j==pospast)
        {
         //         ar_sSPAM[changing]="[position added] "+ar_sSTATUScur[i];
         ar_sSPAM[changing]="[position open] ";//+ar_sSTATUScur[i];
         changing++;
        }
     }
   for(int i=0;i<pospast;i++)
     {
      for(j=0;j<PositionsTotal();j++){if(StringSubstr(ar_sSTATUScur[j],0,6)==StringSubstr(ar_sSTATUSpast[i],0,6))break;}
      if(j==PositionsTotal())
        {
         ar_sSPAM[changing]="[position closed] "+ar_sSTATUSpast[i];
         changing++;
        }
     }
//---
   ArrayResize(ar_sSTATUSpast,ArraySize(ar_sSTATUScur));
   if(ArraySize(ar_sSTATUScur)>0) ArrayCopy(ar_sSTATUSpast,ar_sSTATUScur,0,0,WHOLE_ARRAY);
   pospast=PositionsTotal();
   if(changing==0) return;
//--- если изменения есть то пишем файл notify.txt
   ResetLastError();
   string filename=expname+"\\"+spamfilename;
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_ANSI,'\t',codepage);
   if(filehandle!=INVALID_HANDLE)
     {
      for(int i=0;i<changing;i++)
        {FileWrite(filehandle,ar_sSPAM[i]);}
      FileClose(filehandle);
     }
   else Print("Не удалось открыть файл ",spamfilename,", ошибка",GetLastError());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMustWatcher::WriteReport()
  {
   if(AccountInfoDouble(ACCOUNT_BALANCE)==curbalance) return;
//--- request trade history
   HistorySelect(0,TimeCurrent());
   if(HistoryDealsTotal()<=0) return;
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
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_CSV|FILE_ANSI,rts,codepage);
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
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMustWatcher::ReadCommands()
  {
//commandsfilename
   string filename=expname+"\\"+commandsfilename,comstr,oper,smb,rc;
   int filehandle=FileOpen(filename,FILE_READ|FILE_CSV|FILE_ANSI,' ',codepage);
   if(filehandle!=INVALID_HANDLE)
     {
      if(FileSize(filehandle)<10)
        {
         //Print("Open  command ",filename);
         FileClose(filehandle);
         return;
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
      Print(RemoteControl.Run("",rc));
      filehandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_ANSI,';',codepage);
      FileClose(filehandle);
     }
//else Print("Не удалось открыть файл ",spamfilename,", ошибка",GetLastError());
  }

//+------------------------------------------------------------------+
