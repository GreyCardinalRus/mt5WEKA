//+------------------------------------------------------------------+
//|                                              my_expert_class.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| ���������� ������                                                |
//+------------------------------------------------------------------+
class MyExpert
  {
//--- �������� ����� (����������) ������
private:
   int               Magic_No;   // Magic
   int               Chk_Margin; // ���� ������������� �������� ����� ����� ����������� ��������� ������� (1 ��� 0)
   double            LOTS;       // ���������� ����� ��� ��������
   double            TradePct;   // ������� ���������� ��������� ����� ��� �������� 
   double            ADX_min;    // ����������� �������� ADX
   int               ADX_handle; // ����� ���������� ADX
   int               MA_handle;  // ����� ���������� Moving Average
   double            plus_DI[];  // ������ ��� �������� �������� +DI ���������� ADX
   double            minus_DI[]; // ������ ��� �������� �������� -DI ���������� ADX
   double            MA_val[];   // ������ ��� �������� �������� ���������� Moving Average
   double            ADX_val[];  // ������ ��� �������� �������� ���������� ADX
   double            Closeprice; // ���������� ��� �������� ���� �������� ����������� ���� 
   MqlTradeRequest   trequest;   // ����������� ��������� ��������� ������� ��� �������� ����� �������� ��������
   MqlTradeResult    tresult;    // ����������� ��������� ������ ��������� ������� ��� ��������� ����������� �������� ��������
   string            symbol;     // ���������� ��� �������� ����� �������� �����������
   ENUM_TIMEFRAMES   period;     // ���������� ��� �������� �������� ����������
   string            Errormsg;   // ���������� ��� �������� ����� ��������� �� ������
   int               Errcode;    // ���������� ��� �������� ����� ����� ������
//--- �������� �����/������� (public)
public:
   void              MyExpert();                                  //����������� ������
   void              setSymbol(string syb){symbol = syb;}         //������� ��������� �������� �������
   void              setPeriod(ENUM_TIMEFRAMES prd){period = prd;}//������� ��������� ������� �������� �������
   void              setCloseprice(double prc){Closeprice=prc;}   //������� ��������� ���� �������� ����������� ����
   void              setchkMAG(int mag){Chk_Margin=mag;}          //������� ��������� �������� ���������� Chk_Margin
   void              setLOTS(double lot){LOTS=lot;}               //������� ��������� ������� ���� ��� ��������
   void              setTRpct(double trpct){TradePct=trpct/100;}  //������� ��������� �������� ��������� �����, ������������ � ��������
   void              setMagic(int magic){Magic_No=magic;}         //������� ��������� Magic number ��������
   void              setadxmin(double adx){ADX_min=adx;}          //������� ��������� ������������ �������� ADX
   void              doInit(int adx_period,int ma_period);        //�������, ������� ����� �������������� ��� ������������� ���������
   void              doUninit();                                  //�������, ������� ����� �������������� ��� ��������������� ���������
   bool              checkBuy();                                  //������� ��� �������� ������� �������
   bool              checkSell();                                 //������� ��� �������� ������� �������
   void              openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,
                             double TP,int dev,string comment="");   //������� ��� �������� ������� �� �������
   void              openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,
                              double TP,int dev,string comment="");  //������� ��� �������� ������� �� �������

   //--- ���������� ����� ������
protected:
   void              showError(string msg, int ercode);    //������� ��� ����������� ��������� �� �������
   void              getBuffers();                        //������� ��� ��������� ������������ �������
   bool              MarginOK();                          //������� �������� ������� ������������ ���������� �����
  };   // ����� ���������� ������
//+------------------------------------------------------------------+
// ����������� �������-������ ������ ������
//+------------------------------------------------------------------+
/*
 �����������
*/
void MyExpert::MyExpert()
  {
   //������������� ���� ����������� ����������
   ZeroMemory(trequest);
   ZeroMemory(tresult);
   ZeroMemory(ADX_val);
   ZeroMemory(MA_val);
   ZeroMemory(plus_DI);
   ZeroMemory(minus_DI);
   Errormsg="";
   Errcode=0;
  }
//+------------------------------------------------------------------+
// ������� ������ ��������� �� ������
//+------------------------------------------------------------------+
void MyExpert::showError(string msg,int ercode)
  {
   Alert(msg,"-������:",ercode,"!!"); // display error
  }
//+------------------------------------------------------------------+
// ��������� ������������ �������
//+------------------------------------------------------------------+
void MyExpert::getBuffers()
  {
   if(CopyBuffer(ADX_handle,0,0,3,ADX_val)<0 || CopyBuffer(ADX_handle,1,0,3,plus_DI)<0
      || CopyBuffer(ADX_handle,2,0,3,minus_DI)<0 || CopyBuffer(MA_handle,0,0,3,MA_val)<0)
     {
      Errormsg ="������ ����������� ������������ �������";
      Errcode = GetLastError();
      showError(Errormsg,Errcode);
     }
  }
//+-----------------------------------------------------------------------+
// ��������(PUBLIC)������� ������ ������ 
//+-----------------------------------------------------------------------+
/*
   ������������� 
*/
void MyExpert::doInit(int adx_period,int ma_period)
  {
//--- �������� ����� ���������� ADX
   ADX_handle=iADX(symbol,period,adx_period);
//--- �������� ����� ���������� Moving Average
   MA_handle=iMA(symbol,period,ma_period,0,MODE_EMA,PRICE_CLOSE);
//--- �������� ������������ �������
   if(ADX_handle<0 || MA_handle<0)
     {
      Errormsg="Error Creating Handles for indicators";
      Errcode=GetLastError();
      showError(Errormsg,Errcode);
     }
// ������������� ������� AsSeries ��� ��������
// ��� �������� ADX
   ArraySetAsSeries(ADX_val,true);
// ��� �������� +DI
   ArraySetAsSeries(plus_DI,true);
// ��� �������� -DI
   ArraySetAsSeries(minus_DI,true);
// ��� �������� MA
   ArraySetAsSeries(MA_val,true);
  }
//+------------------------------------------------------------------+
// ���������������
//+------------------------------------------------------------------+
void MyExpert::doUninit()
  {
//--- Release our indicator handles
   IndicatorRelease(ADX_handle);
   IndicatorRelease(MA_handle);
  }
//+------------------------------------------------------------------+
// ��������� ���� ������� ������������ ���������� ����� ��� ��������
//+------------------------------------------------------------------+
bool MyExpert::MarginOK()
  {
      double one_lot_price;                                                    //�����, ��������� ��� ������ ����
   double act_f_mag     = AccountInfoDouble(ACCOUNT_FREEMARGIN);               //������ ��������� ����� �� �����
   long   levrage       = AccountInfoInteger(ACCOUNT_LEVERAGE);                //����� ������� �����
   double contract_size = SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE); //������ ���������
   string base_currency = SymbolInfoString(symbol,SYMBOL_CURRENCY_BASE);       //������� ������
                                                                                
   if(base_currency=="USD")
     {
      one_lot_price=contract_size/levrage;
     }
   else
     {
      double bprice= SymbolInfoDouble(symbol,SYMBOL_BID);
      one_lot_price=bprice*contract_size/levrage;
     }
   // �������� ������� ����, ����� ��������� ���������� ����� �� ��������� �������� �������
   if(MathFloor(LOTS*one_lot_price)>MathFloor(act_f_mag*TradePct))
     {
      return(false);
     }
   else
     {
      return(true);
     }
  }
//+------------------------------------------------------------------+
// �������� ������� �������
//+------------------------------------------------------------------+
bool MyExpert::checkBuy()
  {
  /*
    �������� �������� ������� �������: ���������� ������� (MA) ����������, 
    ���� �������� ����������� ���� ���� ��, ADX > ADX min, +DI > -DI
  */
   getBuffers();
   //--- ��������� ���������� ���� bool ��� �������� ����������� �������� ����� ������� �������
   bool Buy_Condition_1 = (MA_val[0]>MA_val[1]) && (MA_val[1]>MA_val[2]); // MA ������
   bool Buy_Condition_2 = (Closeprice > MA_val[1]);         // ���� �������� ����������� ������ MA
   bool Buy_Condition_3 = (ADX_val[0]>ADX_min);             // ������� �������� ADX ������ ��������� ������������(22)
   bool Buy_Condition_4 = (plus_DI[0]>minus_DI[0]);         // +DI ������ ��� -DI
//--- �������� ��� ������ 
   if(Buy_Condition_1 && Buy_Condition_2 && Buy_Condition_3 && Buy_Condition_4)
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }
//+------------------------------------------------------------------+
// �������� ������� ��� �������
//+------------------------------------------------------------------+
bool MyExpert::checkSell()
  {
  /*
    �������� ������� ������� : ���������� ������� (MA) ������, 
    ���� �������� ����������� ���� ���� ��, ADX > ADX min, -DI > +DI
  */
  getBuffers();
  //--- ��������� ���������� ���� bool ��� �������� ����������� �������� ������� ��� �������
   bool Sell_Condition_1 = (MA_val[0]<MA_val[1]) && (MA_val[1]<MA_val[2]);  // MA ������
   bool Sell_Condition_2 = (Closeprice <MA_val[1]);                         // ���� �������� ����������� ���� ������ MA-8
   bool Sell_Condition_3 = (ADX_val[0]>ADX_min);                            // ������� �������� ADX ������, ��� ����������� (22)
   bool Sell_Condition_4 = (plus_DI[0]<minus_DI[0]);                        // -DI ������, ��� +DI
   
  //--- �������� ��� ������

   if(Sell_Condition_1 && Sell_Condition_2 && Sell_Condition_3 && Sell_Condition_4)
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }
//+------------------------------------------------------------------+
// ��������� ������� �� �������
//+------------------------------------------------------------------+
void MyExpert::openBuy(ENUM_ORDER_TYPE otype,double askprice,double SL,double TP,int dev,string comment="")
  {
// ���� ���������� ��������� �����
   if(Chk_Margin==1)
     {
      if(MarginOK()==false)
        {
         Errormsg= "� ��� ��� ������������ ���������� ������� ��� �������� �������!!!";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
      else
        {
         trequest.action=TRADE_ACTION_DEAL;
         trequest.type=otype;
         trequest.volume=LOTS;
         trequest.price=askprice;
         trequest.sl=SL;
         trequest.tp=TP;
         trequest.deviation=dev;
         trequest.magic=Magic_No;
         trequest.symbol=symbol;
         trequest.type_filling=ORDER_FILLING_AON;
         // �������� ������
         OrderSend(trequest,tresult);
         // ��������� ���������
         if(tresult.retcode==10009 || tresult.retcode==10008) //������ ������� �������� 
           {
            Alert("����� Buy ������� ��������, ����� ������ #:",tresult.order,"!!");
           }
         else
           {
            Errormsg= "������ �� ��������� ������ Buy �� ��������.";
            Errcode =GetLastError();
            showError(Errormsg,Errcode);
           }
        }
     }
   else
     {
      trequest.action=TRADE_ACTION_DEAL;
      trequest.type=otype;
      trequest.volume=LOTS;
      trequest.price=askprice;
      trequest.sl=SL;
      trequest.tp=TP;
      trequest.deviation=dev;
      trequest.magic=Magic_No;
      trequest.symbol=symbol;
      trequest.type_filling=ORDER_FILLING_AON;
      // �������� ������
      OrderSend(trequest,tresult);
      // ��������� ���������
      if(tresult.retcode==10009 || tresult.retcode==10008) //������ ������� �������� 
        {
         Alert("A Buy order has been successfully placed with Ticket#:",tresult.order,"!!");
        }
      else
        {
         Errormsg= "The Buy order request could not be completed";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
     }
  }
//+------------------------------------------------------------------+
// �������� ������� �� �������
//+------------------------------------------------------------------+
void MyExpert::openSell(ENUM_ORDER_TYPE otype,double bidprice,double SL,double TP,int dev,string comment="")
  {
// Do check Margin if enabled
   if(Chk_Margin==1)
     {
      if(MarginOK()==false)
        {
         Errormsg= "� ��� ��� ������������ ���������� ������� ��� �������� �������!!!";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
      else
        {
         trequest.action=TRADE_ACTION_DEAL;
         trequest.type=otype;
         trequest.volume=LOTS;
         trequest.price=bidprice;
         trequest.sl=SL;
         trequest.tp=TP;
         trequest.deviation=dev;
         trequest.magic=Magic_No;
         trequest.symbol=symbol;
         trequest.type_filling=ORDER_FILLING_AON;
         // �������� ������
         OrderSend(trequest,tresult);
         // ��������� ���������
         if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed 
           {
            Alert("����� Sell ������� ��������, ����� ������ #:",tresult.order,"!!");
           }
         else
           {
            Errormsg= "������ �� ��������� ������ Sell �� ��������";
            Errcode =GetLastError();
            showError(Errormsg,Errcode);
           }
        }
     }
   else
     {
      trequest.action=TRADE_ACTION_DEAL;
      trequest.type=otype;
      trequest.volume=LOTS;
      trequest.price=bidprice;
      trequest.sl=SL;
      trequest.tp=TP;
      trequest.deviation=dev;
      trequest.magic=Magic_No;
      trequest.symbol=symbol;
      trequest.type_filling=ORDER_FILLING_AON;
      // �������� ������
      OrderSend(trequest,tresult);
      // ��������� ���������
      if(tresult.retcode==10009 || tresult.retcode==10008) //Request successfully completed 
        {
         Alert("����� Sell ��� ������� �������, ����� ������ #:",tresult.order,"!!");
        }
      else
        {
         Errormsg= "The Sell order request could not be completed";
         Errcode =GetLastError();
         showError(Errormsg,Errcode);
        }
     }
  }
//+----------------------------------------------------------------+
