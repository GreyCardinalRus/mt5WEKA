//+------------------------------------------------------------------+
//|                                                RemoteControl.mqh |
//|                                                     GreyCardinal |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "GreyCardinal"
#property link      "http://www.mql5.com"

const string  op[2]={"?","!"};
const string cmd[8]={"HELP","INFO","SYMB","ORDS","PARAM","ALERT","---","---"};
//+------------------------------------------------------------------+

//+----------------------------------------------------------------+
//    ������� ������ 
//    ���������: [?|!][�������][��������][��������]
//+----------------------------------------------------------------+    
/*
      help - ������� � ��������;
      info - ���������� � ��������� �����;
      symb [������] - �������� ���� ��� ���������� �����������;
      ords [close|sl|tp][��������] - ���������� ��������� ��������;
      param [sl|tp|p0|p1|p2] [��������] - ���������� �����������;
      close - �������� ���������;
*/

// ������ ������  -������ ������ -��� �����
// ��� ������ �������������
// ������ -
// �������� -
// ����������� -
// ��������� - 

class CRemoteControl
  {
private:
public:
   string            Run(string UIN,string cmdstr);
  };
//+------------------------------------------------------------------+
string CRemoteControl::Run(string UIN,string cmdstr)
  {
   string part[5];
   string resp;
   string text="";
   string symbol,type;
   int digits;
   bool ret;
   MqlDateTime dt;

   if(ParseString(cmdstr,part))
     {

      resp=StringFormat("# %s %s %s %s %s #\n",part[0],part[1],part[2],part[3],part[4]);

      if(part[0]==op[0]) //?
        {

         //--------------------------------------------------------
         if(part[1]==cmd[0]) //help
            //--------------------------------------------------------
           {
            return(resp+
                   "[?|!][�������][��������][��������]\n"+
                   "help - ������� � ��������;\n"+
                   "info - ��������� �����;\n"+
                   "symb [������] - ���������;\n"
                   "ords [������] [close|sl|tp] [��������] - ������;\n"
                   );
           }
         //--------------------------------------------------------
         else if(part[1]==cmd[1]) //info
         //--------------------------------------------------------
            return(resp+
                   StringFormat("Balance: %.2f; Profit: %.2f",
                   AccountInfoDouble(ACCOUNT_BALANCE),AccountInfoDouble(ACCOUNT_PROFIT)));

         //--------------------------------------------------------
         else if(part[1]==cmd[2]) //symb
         //--------------------------------------------------------
           {

            type=part[2];

            if(type=="")// ����� ���� ��������� � MarketWatch
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
                  if(SymbolSelect(type,true)) text="���������� ��������";
                  else text=type+"-������ � ������������ �����������";
                 }
              }
            return(resp+text);
           }
         //--------------------------------------------------------
         else if(part[1]==cmd[3]) //ords
         //--------------------------------------------------------
           {
            if(PositionsTotal()==0) text="�������� ������� ���";
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
            return(resp+text);
           }
         //--------------------------------------------------------
        }
      //--------------------------------------------------------
      else if(part[0]==op[1]) //!
      //--------------------------------------------------------
        {
         //--------------------------------------------------------
        }

      //--------------------------------------------------------
      if(part[1]==cmd[6]) //close
         //--------------------------------------------------------
        {
         //client.SendMessage(UIN,resp+"���������: "+(TerminalClose(0)?"��":"���"));
        }

      //--------------------------------------------------------
      if(part[1]==cmd[7]) //shdwn
         //--------------------------------------------------------
        {
         //client.SendMessage(UIN, resp + "���������: " + (ShutdownWindows()?"��":"���"));
        }
     }
  return("");
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
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
string ExtractSubString(string source,uint start_pos)
//+------------------------------------------------------------------+
  {
   string dest;
   uint len=StringLen(source);
   bool shift=false;
   uint pos;

   StringInit(dest,len,0);
   pos=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(start_pos<len)
     {
      for(uint i=start_pos; i<len; i++)
        {
         if(StringGetCharacter(source,i)!=0x20)
           {
            StringSetCharacter(dest,pos++,StringGetCharacter(source,i));
            shift=true; // ���� ������ ������
           }
         else if(shift) break;
        }
     }

   return(dest);
  };
//+------------------------------------------------------------------+
bool ParseString(string msg,string &part[])//&part[5])//
//+------------------------------------------------------------------+
  {

   bool   ret;
   uint   len;
   uint   start_pos=0;
   string buf=msg;
   string substr;
   ushort chr;

   StringToUpper(buf); // ��� ������� ����� ����������� � ������� ������� ��������

   StringInit(part[0],20,0);
   StringInit(part[1],20,0);
   StringInit(part[2],20,0);
   StringInit(part[3],20,0);

   for(int i=0; i<5; i++) // ��������� �������� �� ������
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      substr=ExtractSubString(buf,start_pos);
      if(substr==NULL)break;
      part[i]=substr;
      start_pos=start_pos+StringLen(substr)+1;

      //StringToUpper(part[i]);   
     }

// ������ ���������� ��������
// part0
   len=StringLen(part[0]);

   if(len==0) return(false);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(len==1)
     {
      // part0 - ���� ����������� ������ �������� �������
      if(!((part[0]==op[0]) || (part[0]==op[1])))return(false);

      // part1 - �������� ������ ������� 
      ret=false;
      for(int i=0; i<ArrayRange(cmd,0); i++)
        {
         if(StringFind(part[1],cmd[i],0)!=-1)// ������ �������
           {
            ret=true; break;
           }
        }
      return(ret);

     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else // ���� � ������ ��������� ����� ������ ������� 
     {
      chr=StringGetCharacter(buf,0);
      // part[0]
      if(!((chr=='!') || (chr=='?'))) return(false);

      // part[1]
      ret=false;
      for(int i=0; i<ArrayRange(cmd,0); i++)
        {
         if(StringFind(part[0],cmd[i],1)!=-1)// ������ �������
           {
            part[4] = part[3];
            part[3] = part[2];
            part[2] = part[1];
            part[1] = cmd[i];

            StringSetCharacter(part[0],0,chr);
            StringSetCharacter(part[0],1,0);

            ret=true;
            break;
           }
        }
      return(ret);
     }

   return(true);
  }
//+------------------------------------------------------------------+
