//+------------------------------------------------------------------+
//|                                                        Puria.mq5 |
//|                                       Copyright 2010, AM2 Group. |
//|                                         http://www.am2_group.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, AM2 Group."
#property link      "http://www.am2_group.net"
#property version   "1.00"

//--- ������� ���������
input int      StopLoss=14;      // Stop Loss
input int      TakeProfit=15;    // Take Profit
input int      MA1_Period=75;    // ������ Moving Average
input int      MA2_Period=85;    // ������ Moving Average
input int      MA3_Period=5;     // ������ Moving Average
input int      EA_Magic=12345;   // Magic Number ���������
input double   Lot=0.1;          // ���������� ����� ��� ��������
//--- ���������� ����������
int macdHandle;    // ����� ���������� MACD
int ma75Handle;    // ����� ���������� Moving Average
int ma85Handle;    // ����� ���������� Moving Average
int ma5Handle;     // ����� ���������� Moving Average
double macdVal[5]; // ����������� ������ ��� �������� ��������� �������� ���������� MACD
double ma75Val[5]; // ����������� ������ ��� �������� �������� ���������� Moving Average
double ma85Val[5]; // ����������� ������ ��� �������� �������� ���������� Moving Average 
double ma5Val[5];  // ����������� ������ ��� �������� �������� ���������� Moving Average 
double p_close;    // ���������� ��� �������� �������� close ����
int STP,TKP;       // ����� ������������ ��� �������� Stop Loss � Take Profit
bool BuyOne = true, SellOne = true; // ������ ���� �����
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- ���������� �� ���������� ����� ��� ������
   if(Bars(_Symbol,_Period)<60) // ����� ���������� ����� �� ������� ������ 60?
     {
      Alert("�� ������� ������ 60 �����, �������� �� ����� ��������!!");
      return(-1);
     }
//--- �������� ����� ���������� MACD
   macdHandle=iMACD(NULL,0,15,26,1,PRICE_CLOSE);
//---�������� ����� ���������� Moving Average
   ma75Handle=iMA(_Symbol,_Period,75,0,MODE_LWMA,PRICE_LOW);
   ma85Handle=iMA(_Symbol,_Period,85,0,MODE_LWMA,PRICE_LOW);
   ma5Handle=iMA(_Symbol,_Period,5,0,MODE_EMA,PRICE_CLOSE);
      
//--- ����� ���������, �� ���� �� ���������� �������� Invalid Handle
   if(macdHandle<0 || ma75Handle<0|| ma85Handle<0|| ma5Handle<0)
     {
      Alert("������ ��� �������� ����������� - ����� ������: ",GetLastError(),"!!");
      return(-1);
     }

//--- ��� ������ � ���������, ������������� 3-� � 5-�� ������� ���������,
//--- �������� �� 10 �������� SL � TP
   STP = StopLoss;
   TKP = TakeProfit;
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- ����������� ������ �����������
   IndicatorRelease(ma75Handle);
   IndicatorRelease(ma85Handle);
   IndicatorRelease(ma5Handle);
   IndicatorRelease(macdHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

// ��� ���������� �������� ������� ���� �� ���������� static-���������� Old_Time.
// ��� ������ ���������� ������� OnTick �� ����� ���������� ����� �������� ���� � ����������� ��������.
// ���� ��� �� �����, ��� ��������, ��� ����� �������� ����� ���.

   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar=false;

// �������� ����� �������� ���� � ������� New_Time[0]
   int copied=CopyTime(_Symbol,_Period,0,1,New_Time);
   if(copied>0) // ok, ������� �����������
     {
      if(Old_Time!=New_Time[0]) // ���� ������ ����� �� �����
        {
         IsNewBar=true;   // ����� ���
         if(MQL5InfoInteger(MQL5_DEBUGGING)) Print("����� ���",New_Time[0],"������ ���",Old_Time);
         Old_Time=New_Time[0];   // ��������� ����� ����
        }
     }
   else
     {
      Alert("������ ����������� �������, ����� ������ =",GetLastError());
      ResetLastError();
      return;
     }

//--- �������� ������ ��������� ������� ���������� ����� �������� �������� ������ ��� ����� ����
   if(IsNewBar==false)
     {
      return;
     }

//--- ����� �� �� ����������� ���������� ����� �� ������� ��� ������
   int Mybars=Bars(_Symbol,_Period);
   if(Mybars<60) // ���� ����� ���������� ����� ������ 60
     {
      Alert("�� ������� ����� 60 �����, �������� �������� �� �����!!");
      return;
     }

//--- ��������� ���������, ������� ����� �������������� ��� ��������
   MqlTick latest_price;       // ����� �������������� ��� ������� ���������
   MqlTradeRequest mrequest;   // ����� �������������� ��� ������� �������� ��������
   MqlTradeResult mresult;     // ����� �������������� ��� ��������� ����������� ���������� �������� ��������
   MqlRates mrate[];           // ����� ��������� ����, ������ � ����� ��� ������� ����
   
   mrequest.action = TRADE_ACTION_DEAL;        // ����������� ����������
   mrequest.type_filling = ORDER_FILLING_AON;  // ��� ���������� ������ - ��� ��� ������   
   mrequest.symbol = _Symbol;                  // ������
   mrequest.volume = Lot;                      // ���������� ����� ��� ��������
   mrequest.magic = EA_Magic;                  // Magic Number 
   mrequest.deviation=5;                       // ��������������� �� ������� ����
   
/*
     ��������� ���������� � �������� ��������� � ����������� 
     ��� � ����������
*/
// ������ ���������
   ArraySetAsSeries(mrate,true);
// ������ �������� ���������� MACD
   ArraySetAsSeries(macdVal,true);
// ������ �������� ���������� MA
   ArraySetAsSeries(ma75Val,true);
   ArraySetAsSeries(ma85Val,true);
   ArraySetAsSeries(ma5Val,true);

//--- �������� ������� �������� ��������� � ��������� ���� MqlTick
   if(!SymbolInfoTick(_Symbol,latest_price))
     {
      Alert("������ ��������� ��������� ��������� - ������:",GetLastError(),"!!");
      return;
     }

//--- �������� ������������ ������ ��������� 3-� �����
   if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
     {
      Alert("������ ����������� ������������ ������ - ������:",GetLastError(),"!!");
      return;
     }

//--- �������� �������� ����������� � �������
      
   if(CopyBuffer(ma75Handle,0,0,3,ma75Val)<0 || CopyBuffer(ma85Handle,0,0,3,ma85Val)<0
      || CopyBuffer(ma5Handle,0,0,3,ma5Val)<0)
     {
      Alert("������ ����������� ������� ���������� MACD - ����� ������:",GetLastError(),"!!");
      return;
     }
   if(CopyBuffer(macdHandle,0,0,3,macdVal)<0)
     {
      Alert("������ ����������� ������� ���������� Moving Average - ����� ������:",GetLastError());
      return;
     }

// ��������� ������� ���� �������� ����������� ���� (��� ��� 1)
   p_close=mrate[1].close;  // ���� �������� ����������� ����

/*
    1. �������� ������� ��� ������� : MA-5 ���������� MA-75 � MA-85 ����� �����, 
       ���������� ���� �������� ���� ������ MA-5, ��������� MACD ������ 0.
*/

//--- ��������� ���������� ���� boolean, ��� ����� �������������� ��� �������� ������� ��� �������
   bool Buy_Signal=(ma5Val[1]>ma75Val[1]) && (ma5Val[1]>ma85Val[1]      // MA-5 ���������� MA-75 � MA-85 ����� �����
                 && p_close > ma5Val[1]                                 // ���������� ���� �������� ���� ���������� ������� MA-5
                 && macdVal[1]>0);                                      // ��������� MACD ������ 0
/*
    2. �������� ������� ��� ������� : MA-5 ���������� MA-75 � MA-85 ������ ����, 
       ���������� ���� �������� ���� ������ MA-5, ��������� MACD ������ 0.
*/

//--- ��������� ���������� ���� boolean, ��� ����� �������������� ��� �������� ������� ��� �������
   bool Sell_Signal = (ma5Val[1]<ma75Val[1]) && (ma5Val[1]<ma85Val[1]       //MA-5 ���������� MA-75 � MA-85 ������ ����
                    && p_close < ma5Val[1]                                  // ���������� ���� �������� ���� MA-5
                    && macdVal[1]<0);                                       // ��������� MACD ������ 0


//--- �������� ��� ������
   if(Buy_Signal &&                                                         // �������� ���� ���� ������ �� �������
      PositionSelect(Symbol())==false &&                                    // ����� ������
      BuyOne)                                                               // ��� ������� �� ������� ������ ������ ���� �����
     {
      mrequest.type = ORDER_TYPE_BUY;                                       // ����� �� �������
      mrequest.price = NormalizeDouble(latest_price.ask,_Digits);           // ��������� ���� ask
      mrequest.sl = NormalizeDouble(latest_price.ask - STP*_Point,_Digits); // Stop Loss
      mrequest.tp = NormalizeDouble(latest_price.ask + TKP*_Point,_Digits); // Take Profit 
      OrderSend(mrequest,mresult);                                          // �������� ����� 
      BuyOne = false;                                                       // �� ������� ������ ���� �����                                                   
      SellOne = true;                                                       // ������ ���� ������ ������ �� �������           
     }
     
//--- �������� ��� ������
   else if(Sell_Signal &&                                                   // ������� ���� ���� ������ �� �������
           PositionSelect(Symbol())==false &&                               // ����� ������
           SellOne)                                                         // ��� ������� �� ������� ������ ������ ���� �����
     {   
      mrequest.type= ORDER_TYPE_SELL;                                       // ����� �� �������
      mrequest.price = NormalizeDouble(latest_price.bid,_Digits);           // ��������� ���� Bid
      mrequest.sl = NormalizeDouble(latest_price.bid + STP*_Point,_Digits); // Stop Loss
      mrequest.tp = NormalizeDouble(latest_price.bid - TKP*_Point,_Digits); // Take Profit
      OrderSend(mrequest,mresult);                                          // �������� �����
      SellOne = false;                                                      // �� ������� ������ ���� �����                                             
      BuyOne = true;                                                        // ������ ���� ������ ������ �� �������                   
     }         
   return;
  }
//+------------------------------------------------------------------+
