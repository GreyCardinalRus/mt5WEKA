//+------------------------------------------------------------------+
//|                                          20_200_pips_MQL5_v1.mq5 |
//|                                    Copyright 2010, ������� ����� |
//|                                          http://www.autoforex.ru |
//+------------------------------------------------------------------+

#property copyright "Copyright 2010, ������� �����"
#property link      "http://www.autoforex.ru"
#property version   "1.00"

//��������� ������� ����������. ��� ����� �������� ����� � �� �������� ����� ����� ������ ����� �������� �������

input int      TakeProfit=200;
input int      StopLoss=2000;
input int      TradeTime=18;
input int      t1=7;
input int      t2=2;
input int      delta=70;
input double   lot=0.1;

bool cantrade=true;// ���� ��� ���������� ��� ������� ��������.
double Ask; // ����� ����� ������� ���� Ask ��� ������ ���� (��� �������)
double Bid; // ����� ����� ������� ���� Bid ��� ������ ���� (��� �������)

//������� �������� ������� (Long) �������. ��������� ����� �������� ���������� �� ���������
int OpenLong(double volume=0.1,int slippage=10,string comment="EUR/USD 20 pips expert (Long)",int magic=0)
  {
   MqlTradeRequest my_trade;//��������� ��������� ���� MqlTradeRequest ��� ������������ �������
   MqlTradeResult my_trade_result;//� ���� ��������� ����� ����� ������� �� ������.
   
   //����� ���������� ��� ����������� ���� ��������� �������.
   my_trade.action=TRADE_ACTION_DEAL;//���������� �������� ����� �� ����������� ���������� ������ � ���������� 
                                     //����������� (��������� �������� �����)
   my_trade.symbol=Symbol();//��������� � �������� �������� ���� - ������� �������� ���� 
                            //(��, �� ������� ������� ��������)
   my_trade.volume=NormalizeDouble(volume,1);//������ ����
   my_trade.price=NormalizeDouble(Ask,_Digits);//����, ��� ���������� ������� ����� ������ ���� ��������. 
   //� ����� ������ ��� TRADE_ACTION_DEAL ��� ������� ���� � ��, �������� ���������� ��������� �� �����������.
   my_trade.sl=NormalizeDouble(Ask-StopLoss*_Point,_Digits);//�������� ������ (���� ��� ������� ������� ������� 
                                                            //��������� ������)
   my_trade.tp=NormalizeDouble(Ask+TakeProfit*_Point,_Digits);//���������� (���� ��� ������� ������� �������
                                                              // ���������� ������)
   my_trade.deviation=slippage;//��������������� � ������� (��� ������������ ������ ���� �� ������, �.�. 
                               //��������������� �� ������ �� ������)
   my_trade.type=ORDER_TYPE_BUY;//��� ��������� ������ (��������)
   my_trade.type_filling=ORDER_FILLING_AON;//��������� ��� ��������� �����. (All Or Nothing - ��� ��� ������) 
   //������ ����� ���� ��������� ������������� � ��������� ������ � �� ���� ������ ��� ����� ��������� � ������.
   my_trade.comment=comment;//����������� ������
   my_trade.magic=magic;//���������� ����� ������
   
   ResetLastError();//�������� ��� ��������� ������ 
   if(OrderSend(my_trade,my_trade_result))//���������� ������ �� �������� �������. ��� ���� ��������� 
                                          //������� �� ������ �������� �������
     {
      // ���� ������ ������ ����� �� �������� �� ��������� 
      Print("��� ���������� �������� - ",my_trade_result.retcode);
     }
   else
     {
      //������ �� ������ ����� � ��� ���� ������, ������� �� � ������
      Print("��� ���������� �������� - ",my_trade_result.retcode);
      Print("������ �������� ������ = ",GetLastError());    
     }  
return(0);// ������� �� ������� �������� ������     
}

//������� �������� �������� (Short) �������. ���������� ������� �������� ������� �������.
int OpenShort(double volume=0.1,int slippage=10,string comment="EUR/USD 20 pips expert (Short)",int magic=0)
  {
   MqlTradeRequest my_trade;
   MqlTradeResult my_trade_result;
   my_trade.action=TRADE_ACTION_DEAL;
   my_trade.symbol=Symbol();
   my_trade.volume=NormalizeDouble(volume,1);
   my_trade.price=NormalizeDouble(Bid,_Digits);
   my_trade.sl=NormalizeDouble(Bid+StopLoss*_Point,_Digits);
   my_trade.tp=NormalizeDouble(Bid-TakeProfit*_Point,_Digits);
   my_trade.deviation=slippage;
   my_trade.type=ORDER_TYPE_SELL;
   my_trade.type_filling=ORDER_FILLING_AON;
   my_trade.comment=comment;
   my_trade.magic=magic;

   ResetLastError();  
   if(OrderSend(my_trade,my_trade_result))
     {
      Print("��� ���������� �������� - ",my_trade_result.retcode);
     }
   else
     {
      Print("��� ���������� �������� - ",my_trade_result.retcode);
      Print("������ �������� ������ = ",GetLastError()); 
      }        
return(0);     
}

int OnInit()
  {
   return(0);
  }


void OnDeinit(const int reason){}

void OnTick()
   {
   double Open[];//������ ��� ����� ��������� ���� �������� ����� (������� Open[t1] � Open[t2])
   MqlDateTime mqldt;//� ���� ��������� ������ ������� �����.
   TimeCurrent(mqldt);//��������� ������ � ������� �������.
   int len;//���������� ������������ ������ ������� Open[].
        
   MqlTick last_tick;//����� ����� ��������� ���� ���������� ���������� ����
   SymbolInfoTick(_Symbol,last_tick);//��������� ��������� last_tick ���������� ������ �������� �������.
   Ask=last_tick.ask;//��������� ���������� Ask � Bid ��� ����������� �������������
   Bid=last_tick.bid;
   
   ArraySetAsSeries(Open,true);//��� �������� ������ ���������� ������ Open[] ��� ���������.
   
   //����� ��������� ����� ������� �����, ����� ����������� ����� �������� Open[t1] � Open[t2]
   if (t1>=t2)len=t1+1;//t1 � t2 - ������ ����� �� ������� ������������ ����. ����� ������� �� ���
   else len=t2+1;      //� ��������� 1 (�.�. ���� ��� � ������� ���)

   CopyOpen(_Symbol,PERIOD_H1,0,len,Open);//��������� ������ Open[] ����������� ����������
   
   //����������� ���� cantarde �� true, �.�. �������� ��������� ����� ��������� �������
   if(((mqldt.hour)>TradeTime)) cantrade=true;
                 
   // ��������� ����������� ������ � �������:
   if(!PositionSelect(_Symbol))// ���� ��� ��� �������� �������
   {
      if((mqldt.hour==TradeTime) && (cantrade))//���� ������ ����� ���������
        {
         if(Open[t1]>(Open[t2]+delta*_Point))//��������� ������� ��� �������� �������� ������ (�������)
           {                  
               OpenShort(lot,10,"EUR/USD 20 pips expert (Short)",1234);//��������� ������� Short 
               cantrade=false;// ����������� ���� (��������� ���������), ����� �� ������� ������ ������� �� ���������� ���                                         
               return;//�������
           }
         if((Open[t1]+delta*_Point)<Open[t2])//��������� ������� ��� �������� ������� ������ (�������)
           {
               OpenLong(lot,10,"EUR/USD 20 pips expert (Long)",1234);//��������� ������� Long
               cantrade=false;// ����������� ���� (��������� ���������), ����� �� ������� ������ ������� �� ���������� ���                                           
               return;//�������
           }
        }
   }
   return;
  }
//+------------------------------------------------------------------+
