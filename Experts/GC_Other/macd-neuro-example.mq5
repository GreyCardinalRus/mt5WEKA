//+------------------------------------------------------------------+
//|                                           macd-neuro-example.mq5 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>        //���������� ���������� ��� ���������� �������� ��������
#include <Trade\PositionInfo.mqh> //���������� ���������� ��� ��������� ���������� � ��������
//--- �������� ������� �������������                                                                    
input double w0=0.5;
input double w1=0.5;
input double w2=0.5;
input double w3=0.5;
input double w4=0.5;
input double w5=0.5;
input double w6=0.5;
input double w7=0.5;
input double w8=0.5;
input double w9=0.5;
input double w10=0.5;
input double w11=0.5;
input double w12=0.5;
input double w13=0.5;
input double w14=0.5;
input double w15=0.5;
input double w16=0.5;
input double w17=0.5;
input double w18=0.5;
input double w19=0.5;

int               iMACD_handle;      // ���������� ��� �������� ������ ����������
double            iMACD_mainbuf[];   // ������������ ������ ��� �������� �������� ����������
double            iMACD_signalbuf[]; // ������������ ������ ��� �������� �������� ����������

double            inputs[20];        // ������ ��� �������� ������� ��������
double            weight[20];        // ������ ��� �������� ������� �������������

string            my_symbol;         // ���������� ��� �������� �������
ENUM_TIMEFRAMES   my_timeframe;      // ���������� ��� �������� ����������
double            lot_size;          // ���������� ��� �������� ������������ ������ ����������� ������

double            out;               // ���������� ��� �������� ��������� �������� �������

CTrade            m_Trade;           // ������ ��� ���������� �������� ��������
CPositionInfo     m_Position;        // ������ ��� ��������� ���������� � ��������
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- �������� ������� ������ ������� ��� ���������� ������ ��������� ������ �� ���� �������
   my_symbol=Symbol();
//--- �������� ������� ������ ������� ��� ���������� ������ ��������� ������ �� ���� �������
   my_timeframe=PERIOD_CURRENT;
//--- �������� ����������� ����� ����������� ������
   lot_size=SymbolInfoDouble(my_symbol,SYMBOL_VOLUME_MIN);
//--- ���������� ��������� � �������� ��� �����
   iMACD_handle=iMACD(my_symbol,my_timeframe,48,36,19,PRICE_CLOSE);
//--- ��������� ������� ������ ����������
   if(iMACD_handle==INVALID_HANDLE)
     {
      //--- ����� �� �������, ������� ��������� � ��� �� ������, ��������� ������ � �������
      Print("�� ������� �������� ����� ����������");
      return(-1);
     }
//--- ��������� ��������� �� ������� ������
   ChartIndicatorAdd(ChartID(),0,iMACD_handle);
//--- ������������� ���������� ��� ������� iMACD_mainbuf ��� � ���������
   ArraySetAsSeries(iMACD_mainbuf,true);
//--- ������������� ���������� ��� ������� iMACD_signalbuf ��� � ���������
   ArraySetAsSeries(iMACD_signalbuf,true);
//--- ��������� ������� ������������ � ������
   weight[0]=w0;
   weight[1]=w1;
   weight[2]=w2;
   weight[3]=w3;
   weight[4]=w4;
   weight[5]=w5;
   weight[6]=w6;
   weight[7]=w7;
   weight[8]=w8;
   weight[9]=w9;
   weight[10]=w10;
   weight[11]=w11;
   weight[12]=w12;
   weight[13]=w13;
   weight[14]=w14;
   weight[15]=w15;
   weight[16]=w16;
   weight[17]=w17;
   weight[18]=w18;
   weight[19]=w19;
//--- ���������� 0, ������������� ���������
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- ������� ����� ���������� � ����������� ���������� �� ������
   IndicatorRelease(iMACD_handle);
//--- ����������� ������������ ������ iMACD_mainbuf �� ������
   ArrayFree(iMACD_mainbuf);
//--- ����������� ������������ ������ iMACD_signalbuf �� ������
   ArrayFree(iMACD_signalbuf);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int err1=0; // ���������� ��� �������� ����������� ������ � �������� ������� ���������� MACD
   int err2=0; // ���������� ��� �������� ����������� ������ � ���������� ������� ���������� MACD

//--- �������� ������ �� ������������� ������� � ������������ ������ iMACD_mainbuf ��� ���������� ������ � ����
   err1=CopyBuffer(iMACD_handle,0,2,ArraySize(inputs)/2,iMACD_mainbuf);
//--- �������� ������ �� ������������� ������� � ������������ ������ iMACD_signalbuf ��� ���������� ������ � ����
   err2=CopyBuffer(iMACD_handle,1,2,ArraySize(inputs)/2,iMACD_signalbuf);
//--- ���� ���� ������, �� ������� ��������� � ��� �� ������ � ������� �� �������
   if(err1<0 || err2<0)
     {
      Print("�� ������� ����������� ������ �� ������������� ������");
      return;
     }

   double d1=-1.0; //������ ������� ��������� ��� ������������ ��������
   double d2=1.0;  //������� ������� ��������� ��� ������������ ��������
//--- ����������� �������� �� ���������
   double x_min=MathMin(iMACD_mainbuf[ArrayMinimum(iMACD_mainbuf)],iMACD_signalbuf[ArrayMinimum(iMACD_signalbuf)]);
//--- ������������ �������� �� ���������
   double x_max=MathMax(iMACD_mainbuf[ArrayMaximum(iMACD_mainbuf)],iMACD_signalbuf[ArrayMaximum(iMACD_signalbuf)]);
//--- � ����� ��������� ������ ������ ���������� ���������� � ��������������� �������������
   for(int i=0;i<ArraySize(inputs)/2;i++)
     {
      inputs[i*2]=(((iMACD_mainbuf[i]-x_min)*(d2-d1))/(x_max-x_min))+d1;
      inputs[i*2+1]=(((iMACD_signalbuf[i]-x_min)*(d2-d1))/(x_max-x_min))+d1;
     }
//--- ���������� ��������� ���������� ������� � ���������� out
   out=CalculateNeuron(inputs,weight);
//--- ���� �������� ������ ������� ������ 0
   if(out<0)
     {
      //--- ���� ��� ���������� ������� �� ����� �������
      if(m_Position.Select(my_symbol))
        {
         //--- � ��� ���� ������� Sell, �� ��������� ��
         if(m_Position.PositionType()==POSITION_TYPE_SELL) m_Trade.PositionClose(my_symbol);
         //--- � ���� ��� ���� ������� Buy, �� �������
         if(m_Position.PositionType()==POSITION_TYPE_BUY) return;
        }
      //--- ���� ����� ����, ������ ������� ���, ��������� ��
      m_Trade.Buy(lot_size,my_symbol);
     }
//--- ���� �������� ������ ������� ������ ��� ����� 0
   if(out>=0)
     {
      //--- ���� ��� ���������� ������� �� ����� �������
      if(m_Position.Select(my_symbol))
        {
         //--- � ��� ���� ������� Buy, �� ��������� ��
         if(m_Position.PositionType()==POSITION_TYPE_BUY) m_Trade.PositionClose(my_symbol);
         //--- � ���� ��� ���� ������� Sell, �� �������
         if(m_Position.PositionType()==POSITION_TYPE_SELL) return;
        }
      //--- ���� ����� ����, ������ ������� ���, ��������� ��
      m_Trade.Sell(lot_size,my_symbol);
     }
  }
//+------------------------------------------------------------------+
//|   ������� ���������� �������                                     |
//+------------------------------------------------------------------+
double CalculateNeuron(double &x[],double &w[])
  {
//--- ���������� ��� �������� ���������������� ����� ������� ��������
   double NET=0.0;
//--- � ����� �� ���������� ������ �������� ���������������� ����� ������
   for(int n=0;n<ArraySize(x);n++)
     {
      NET+=x[n]*w[n];
     }
//--- �������� ���������������� ����� ������ �� ���������� �����������
   NET*=0.1;
//--- �������� ���������������� ����� ������ � ������� ��������� � ���������� �� ��������
   return(ActivateNeuron(NET));
  }
//+------------------------------------------------------------------+
//|   ������� ��������� �������                                      |
//+------------------------------------------------------------------+
double ActivateNeuron(double x)
  {
//--- ���������� ��� �������� ���������� ������� ���������
   double Out;
//--- ������� ���������������� ��������
   Out=(exp(x)-exp(-x))/(exp(x)+exp(-x));
//--- ���������� �������� ������� ���������
   return(Out);
  }
//+------------------------------------------------------------------+
