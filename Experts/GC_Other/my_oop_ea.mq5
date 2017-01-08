//+------------------------------------------------------------------+
//|                                                    my_oop_ea.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
// �������� ��� �����
#include <my_expert_class.mqh>
//--- ������� ���������
input int      StopLoss=30;      // Stop Loss
input int      TakeProfit=100;   // Take Profit
input int      ADX_Period=14;    // ������ ���������� ADX
input int      MA_Period=10;     // ������ ���������� Moving Average
input int      EA_Magic=12345;   // Magic Number ���������
input double   Adx_Min=22.0;     // ����������� �������� ADX
input double   Lot=0.2;          // ���������� ����� ��� ��������
input int      Margin_Chk=0;     // ����� �� ��������� ������ ����� ����� ���������� ������ (0=���, 1=��)
input double   Trd_percent=15.0; // ������� �����, ������������ � ��������
//--- ������ ���������
int STP,TKP;   // ����� �������������� ��� �������� Stop Loss � Take Profit
// ������ ������ ������ 
MyExpert Cexpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- �������� ������� ������������ ���������� ����� ��� ������
   if(Bars(_Symbol,_Period)<60) // ���� ����� ���������� ����� ����� 60
     {
      Alert("� ��� ����� 60 �����, �������� �������� ������!!");
      return(1);
     }
//--- ������ ������� �������������
   Cexpert.doInit(ADX_Period,MA_Period);
//--- ��������� ���� ����������� ���������� ��� ������ ������� ������
   Cexpert.setPeriod(_Period);    // ������ ������
   Cexpert.setSymbol(_Symbol);    // ������ ������ (�������� ����)
   Cexpert.setMagic(EA_Magic);    // ������ Magic Number
   Cexpert.setadxmin(Adx_Min);    // ������������� ����������� �������� ADX
   Cexpert.setLOTS(Lot);          // ������ ���-�� �����
   Cexpert.setchkMAG(Margin_Chk); // ������ ���� �������� �����
   Cexpert.setTRpct(Trd_percent); // ������ ����������� ������� ����������� ��������� �����
//--- �������� ��������� �������� � 5 �������
   STP = StopLoss;
   TKP = TakeProfit;
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- �������� ������� ���������������
   Cexpert.doUninit();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- ����� �� �� ����������� ���������� ����� ��� ������
   int Mybars=Bars(_Symbol,_Period);
   if(Mybars<60) // ���� ����� ���������� ����� ������ 60
     {
      Alert("� ��� ������ 60 �����, �������� �� ����� ��������!!");
      return;
     }

//--- ������ ��������� ��������� MQL5, ������� ����� �������������� � ����� ��������
   MqlTick latest_price;      // ����� �������������� ��� ��������� �������/��������� ��������� ����
   MqlRates mrate[];          // ����� �������������� ��� �������� ���, ������� � ������� ��� ������� �� �����
/*
     ������� ���, ����� ��������, ������� �� ����� ������������ ��� �������� ���������
     ����� ���������� ��� � ���������
*/
// ��� ������� ���������
   ArraySetAsSeries(mrate,true);
//--- �������� ��������� ���� ���������, ��������� ��������� MqlTick 
   if(!SymbolInfoTick(_Symbol,latest_price))
     {
      Alert("������ ��������� ��������� ���� ��������� - ������:",GetLastError(),"!!");
      return;
     }

//--- ������� ������ �� ��������� ���� ����� 
   if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
     {
      Alert("������ ����������� ���������/������������ ������ - ������:",GetLastError(),"!!");
      return;
     }

//--- �������� ������ ��������� ������� �������� ������ � ������ ������ ������ ����
// ������� static-���������� ���� datetime
   static datetime Prev_time;
// ������� ����� ������ �������� ���� (��� 0)
   datetime Bar_time[1];
// �������� �����
   Bar_time[0] = mrate[0].time;
// ���� ��� ������� �����, � ��� ��� ������ ����
   if(Prev_time==Bar_time[0])
     {
      return;
     }
// ��������� ����� � ����������� ���������� (��������� ��������)
   Prev_time = Bar_time[0]; 


//--- ������ ���, ����������
//--- ���� �� � ��� ��� �������� �������?
   bool Buy_opened=false,Sell_opened=false; // ���������� ��� �������� ���������� �������� ������� �������� �������

   if(PositionSelect(_Symbol)==true) // � ��� ���� �������� ������� �� �������� �������
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened=true;  // ��� ������� �������
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened=true; // ��� �������� �������
        }
     }
// ��������� ���� �������� ����������� ���� (��� 1) � ��������������� ���������� ��������
   Cexpert.setCloseprice(mrate[1].close);  // ���� �������� ���� 1
//--- �������� ������� ������� �� �������
   if(Cexpert.checkBuy()==true)
     {
      // ���� �� �������� ������� �� �������?
      if(Buy_opened)
        {
         Alert("� ��� ��� ���� ������� �� �������!!!"); 
         return;    // �� ��������� � ������� �������
        }
      double aprice = NormalizeDouble(latest_price.ask,_Digits);
      double stl    = NormalizeDouble(latest_price.ask - STP*_Point,_Digits);
      double tkp    = NormalizeDouble(latest_price.ask + TKP*_Point,_Digits);
      int    mdev   = 100;
      // ��������� �����
      Cexpert.openBuy(ORDER_TYPE_BUY,aprice,stl,tkp,mdev);
     }
//--- �������� ������� ������� �� �������n
   if(Cexpert.checkSell()==true)
     {
      // ���� �� �������� ������� �� �������?
      if(Sell_opened)
        {
         Alert("� ��� ��� ���� �������� ������� �� �������!!!"); 
         return;    //�� ��������� � �������� �������
        }
      double bprice=NormalizeDouble(latest_price.bid,_Digits);
      double bstl    = NormalizeDouble(latest_price.bid + STP*_Point,_Digits);
      double btkp    = NormalizeDouble(latest_price.bid - TKP*_Point,_Digits);
      int    bdev=100;
      // ��������� �����
      Cexpert.openSell(ORDER_TYPE_SELL,bprice,bstl,btkp,bdev);
     }

   return;
  }
//+------------------------------------------------------------------+
