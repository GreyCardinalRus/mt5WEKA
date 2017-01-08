//+------------------------------------------------------------------+
//|                                                      Oracles.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Candels.mqh>
//------------------------------------------------------------
// ��������� �������� -� �� ������
// �� ���
//------------------------------------------------------------
class TOracle
{
private:
protected:
   virtual bool       Init(){return(true);}
   virtual void       Deinit(){};
public:
   string   symbol;        // ����� ���� ���������
   int      way;          // ����(����) � �� ������� ���������������� ������� ���������)
   double price;
   datetime expiration;    // ���� ��������� ������������
              TOracle(){way=0;Init();}
              ~TOracle() { Deinit(); }
   virtual bool       Prediction(string symbol,int shift=0){return(true);}
};
//------------------------------------------------------------
// �� ���
//------------------------------------------------------------

//------------------------------------------------------------
// ������� -��� ��� ������� ��� ��� ������
//------------------------------------------------------------

//============================================================
//Heiken_Ashi
//============================================================
class CHeiken_Ashi: public TOracle
{
private: // ���������� ��������� � �������-���������� ����� �� �����
 int hHeiken_Ashi;
 virtual bool       Init();
 virtual void       Deinit(){};
public:
   virtual bool       Prediction(string symbol,int shift=0); 
};

bool CHeiken_Ashi::Init()
 {
  hHeiken_Ashi=0; way=0;
  return (true);
 }
// ����� ������� �������! � � ������ �������
bool CHeiken_Ashi::Prediction(string symbol,int shift=0)  
 {
  MqlRates rt[1];
  ENUM_TIMEFRAMES period=PERIOD_H1;
  if (0==hHeiken_Ashi) hHeiken_Ashi=iCustom(symbol,period,"Examples\\Heiken_Ashi");
   if(CopyRates(symbol,period,0,1,rt)!=1)
     {
      Print("CopyRates of ",symbol," failed, no history");
      return (false);
     }
   if(rt[0].tick_volume>1) return (false);

   double   haOpen[3],haHigh[3],haLow[3],haClose[3];

   if(CopyBuffer(hHeiken_Ashi,0,0,3,haOpen)!=3
      || CopyBuffer(hHeiken_Ashi,1,0,3,haHigh)!=3
      || CopyBuffer(hHeiken_Ashi,2,0,3,haLow)!=3
      || CopyBuffer(hHeiken_Ashi,3,0,3,haClose)!=3)
     {
      Print("CopyBuffer from Heiken_Ashi failed, no data");
      return(false);
     }
//---- ��������� ������� ��� �������
   if(haOpen[3-2]>haClose[3-2])// ����� �� ���������
     {
      way=-100;
     }
//---- ��������� ������� ��� �������
   if(haOpen[3-2]<haClose[3-2]) // ����� �� ���������
     {
     way=100;
     }

  return(true); 
 }
//--------------------------------------------
class CeSimpleMA: public TOracle
{
private: // ���������� ��������� � �������-���������� ����� �� �����
 int Periods;  //Period for MA indicator
 int handle1;
 int handle2;
 double SmoothedBuffer1[];
 double SmoothedBuffer2[];
 virtual bool       Init();
 virtual void       Deinit(){};
public:
   virtual bool       Prediction(string symbol,int shift=0); 
};

bool CeSimpleMA::Init()
 {
  Periods=17; way=0;handle1=0;handle2=0;
  return (true);
 }
// ����� ������� �������! � � ������ �������
bool CeSimpleMA::Prediction(string symbol,int shift=0)  
 {
  MqlRates rt[1];
  way=0;
  ENUM_TIMEFRAMES period=PERIOD_M1;
  if (0== handle1) handle1=iMA(symbol,period,Periods,0,MODE_EMA,PRICE_CLOSE);
  if (0== handle2) handle2=iMA(symbol,period,Periods+2,0,MODE_EMA,PRICE_CLOSE);
  if ((0== handle1)||(0== handle2))
    {
     Print("eSimpleMA::handle1=",handle1,"handle2=",handle2);
     return(false);
    }
  
  MqlTick tick; //variable for tick info
  if(!SymbolInfoTick(symbol,tick))
    {
     Print("eSimpleMA::Failed to get Symbol info!");
     return(false);
    }

//Copy latest MA indicator values into a buffer
   int copied=CopyBuffer(handle1,0,0,4,SmoothedBuffer1);
   if(copied>0)  copied=CopyBuffer(handle2,0,0,4,SmoothedBuffer2);

   if(copied>0)
     {
      //If MAPeriod > MAPeriod+2 -> BUY
      if(SmoothedBuffer1[1]>SmoothedBuffer2[1] && SmoothedBuffer1[2]<SmoothedBuffer2[2])
        {
         way=100;
        }
      //If MAPeriod < MAPeriod+2 -> SELL
      else if(SmoothedBuffer1[1]<SmoothedBuffer2[1] && SmoothedBuffer1[2]>SmoothedBuffer2[2])
        {
         way=-100;
        }
     }
    else 
    {
     Print("eSimpleMA::Failed to copied!");
     return(false);
    }

  return(true); 
 }


//============================================================
//Revers
//============================================================
class CRevers: public TOracle
{
private: // ���������� ��������� � �������-���������� ����� �� �����
// int hHeiken_Ashi;
 virtual bool       Init();
 virtual void       Deinit(){};
public:
 virtual bool       Prediction(string symbol,int shift=0); 
};

bool CRevers::Init()
 {


  //hHeiken_Ashi=0; 
  way=0;
  return (true);
 }
// ����� ������� �������! � � ������ �������
bool CRevers::Prediction(string symbol,int shift=0)  
 {
  way=0;
  ENUM_TIMEFRAMES period=PERIOD_M1;
  double BufferO[],BufferC[],BufferL[],BufferH[];
  ArraySetAsSeries(BufferO,true); ArraySetAsSeries(BufferC,true);
  ArraySetAsSeries(BufferL,true); ArraySetAsSeries(BufferH,true);
  int needcopy=5+shift;
  if(CopyOpen(symbol,period,0,needcopy,BufferO)!=needcopy)   return(false);
  if(CopyClose(symbol,period,0,needcopy,BufferC)!=needcopy)     return(false);
  if(CopyLow(symbol,period,0,needcopy,BufferL)!=needcopy) return(false);
  if(CopyHigh(symbol,period,0,needcopy,BufferH)!=needcopy) return(false);
  double pw=pow(10,SymbolInfoInteger(symbol,SYMBOL_DIGITS));
  int spread=(int)SymbolInfoInteger(symbol,SYMBOL_SPREAD);
  // ������?
  if (
  (BufferO[1+shift]>BufferC[1+shift])
  &&((BufferO[1+shift]-BufferC[1+shift])*pw<spread)
  &&((BufferH[1+shift]-BufferO[1+shift])>(BufferC[1+shift]-BufferL[1+shift]))
  &&(BufferL[1+shift]<BufferL[2+shift])
  &&(BufferL[2+shift]<BufferL[3+shift])
  &&(BufferL[3+shift]<BufferL[4+shift])
  )
   {
    way=100;
    price = BufferH[1+shift]+spread/pw;
   }
  // �������?
  if (
  (BufferC[1+shift]>BufferO[1+shift])
  &&((BufferC[1+shift]-BufferO[1+shift])*pw<spread)
  &&((BufferC[1+shift]-BufferO[1+shift])>(BufferC[1+shift]-BufferL[1+shift]))
  &&(BufferH[1+shift]>BufferH[2+shift])
  &&(BufferH[2+shift]>BufferH[3+shift])
  &&(BufferH[3+shift]>BufferH[4+shift])
  )
   {
    way=-100;
    price = BufferL[1+shift]-spread/pw;
   }

  return(true); 
 }

//============================================================
//Heiken_Ashi
//============================================================
class CCandels: public TOracle
{
private: // ���������� ��������� � �������-���������� ����� �� �����
// virtual bool       Init();
// virtual void       Deinit(){};
public:
   virtual bool       Prediction(string symbol,int shift=0); 
};

//bool CHeiken_Ashi::Init()
// {
//  hHeiken_Ashi=0; way=0;
//  return (true);
// }
// ����� ������� �������! � � ������ �������
bool CCandels::Prediction(string symbol,int shift=0)  
 {
  //MqlRates rt[1];
  way=0;
  ENUM_TIMEFRAMES period=PERIOD_H1;
  Candel_Type ct=IsCandel(symbol,period,shift);
  switch(ct)
   { 
      // buy
      case CT_HangingMan:// ����� ������
      case CT_BlackEscimo:// ������ ������
      case CT_BlackHummer:// ������ ������
      case CT_WhiteEscimo:// ����� ������
      case CT_WhiteHummer:// ����� ������
        way=100; return(true);
       break;
      // sell
      case CT_ShootingStar:// ����� ������
      case CT_RBlackEscimo:// ������ ������
      case CT_RBlackHummer:// ������ ������
      case CT_RWhiteEscimo:// ����� ������
      case CT_RWhiteHummer:// ����� ������
        way=-100; return(true);
       break;
    case CT_None:// ������
    case CT_Doji:// 
      default: 
       return(false);   break;
       break;
     }
  return(true); 
 }
