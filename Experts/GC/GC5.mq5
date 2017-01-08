
//+------------------------------------------------------------------+
//|                                                          GC5.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                        http://www.opencis.net.ru |
//+------------------------------------------------------------------+
#property copyright "2010, GreyCardinal. Valentin"
#property link      "http://www.opencis.net.ru"
#property version   "0.01"
//#include <Strings\String.mqh>
input bool OnlyCurrVals = true; // Только данная пара
input bool ShowBigTable = false; // Показывать таблицу
input bool ShowGraph = false; // Рисовать график
input bool IsRSIExpert = true;  // Эксперт по RSI

input int iBars=100;// Шагов назад

input int Periods=17;  //Period for MA indicator
input int SL=31;       //Stop Loss
input int TP=69;       //Take Profit
input int MAGIC=777;   //MAGIC number

int sl;
int tp;
MqlTradeRequest trReq;
MqlTradeResult trRez;

input color _Header = OrangeRed;
input color _Text = RoyalBlue;
input color _TextCurr = Yellow;
input color _Data = CadetBlue;
input color _DataPlus = Lime;
input color _DataMinus = Red;
input color _Separator = MediumPurple;
input color  Bg_Color = Gray;
input color  Btn_Color = Gold;
input int FontSize = 8;
input string FontName = "Tahoma";
input int TopPos = 20;
input int Corner = 0;
input int MaxSpread = 20;
//extern int dy = 20;
input int MaxPeriod=10; // 0 -auto
//extern int LR.length=10;   // bars back regression begins
input int time_frame=60;
input double TrailingStop=150;
input int Slippage = 0;
input string _Symbol_ = "Пара";//"Symbol";
input string _ValueName_ = "Результат";//"Value";
input string _TotalName_ = "Всего";//"Total";
input string _BreakevenName_ = "Breakeven";
datetime TC;
int BuyOrders;
int SellOrders;
double tfLow[],tfHigh[],tfOpen[],tfClose[];
datetime tfTime[];
long tfVolume[];
MqlTick tick; //variable for tick info
int cntBau;
int Bars;

ENUM_TIMEFRAMES PeriodNumber[21]={
PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4, PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12
,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2
,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
 

//{PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string PeriodName[21]={"M1","M2","M3","M4","M5","M6","M10","M12","M15","M20","M30","H1","H2","H3","H4","H6","H8","H12","D1","W1","MN"};
datetime PeriodUpdate[21];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//Set default vaules for all new order requests
   trReq.action=TRADE_ACTION_DEAL;
   trReq.magic=MAGIC;
   trReq.symbol=Symbol();                 // Trade symbol
   trReq.volume=1;                      // Requested volume for a deal in lots
   trReq.deviation=1;                     // Maximal possible deviation from the requested price
   trReq.type_filling=ORDER_FILLING_AON;  // Order execution type
   trReq.type_time=ORDER_TIME_GTC;        // Order execution time
   trReq.comment="GC";
//end

//input parameters are ReadOnly
   tp=TP;
   sl=SL;
//end

//Suppoprt for acount with 5 decimals
   if(_Digits==5)
     {
      sl*=10;
      tp*=10;
     }
//end
//---
  MaxSymbols =CreateSymbolList();
  Print( "Валютных пар = ",MaxSymbols);
//   for( int SymbolIdx = 0; SymbolIdx<MaxSymbols;SymbolIdx++)  
//       for ( int iperiod = 0; iperiod<MaxPeriod;iperiod++)  // по периодам
//     Calked[SymbolIdx][iperiod]=0;
   ArraySetAsSeries(tfHigh,true);
   ArraySetAsSeries(tfClose,true);
   ArraySetAsSeries(tfLow,true);
   ArraySetAsSeries(tfOpen,true);
   ArraySetAsSeries(tfTime,true);
  BuyOrders=0; SellOrders=0;
    if (iBars==0) Bars=100;//Bars(_Symbol,_Period);
    else Bars=iBars;
    if (MQL5InfoInteger(MQL5_TESTING)) Bars=3;

  if (ShowBigTable)  gc_update();   



   return(0);
   
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   clear();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Print(HistoryDealsTotal());
  if ((TimeCurrent()-TC)>60)// раз в секунду
   {
//    Print("OnTick",TimeCurrent(),TC);
    //Print("Bars=",Bars);
    CopyClose(_Symbol,_Period,0,Bars,tfClose);
    CopyHigh(_Symbol,_Period,0,Bars,tfHigh);
    CopyLow(_Symbol,_Period,0,Bars,tfLow);
    CopyOpen(_Symbol,_Period,0,Bars,tfOpen);
    CopyTime(_Symbol,_Period,0,Bars,tfTime);
    if (IsRSIExpert) RSIExpert();
    if (ShowBigTable)  gc_update();   
    TC=TimeCurrent();
   }
   MoveOrders();
  }

//+------------------------------------------------------------------+
//|  возвращает строковое наименование типа ордера                   |
//+------------------------------------------------------------------+
string GetOrderType(long type)
  {
   string str_type="unknown operation";
   switch(type)
     {
      case (ORDER_TYPE_BUY):            return("buy");
      case (ORDER_TYPE_SELL):           return("sell");
      case (ORDER_TYPE_BUY_LIMIT):      return("buy limit");
      case (ORDER_TYPE_SELL_LIMIT):     return("sell limit");
      case (ORDER_TYPE_BUY_STOP):       return("buy stop");
      case (ORDER_TYPE_SELL_STOP):      return("sell stop");
      case (ORDER_TYPE_BUY_STOP_LIMIT): return("buy stop limit");
      case (ORDER_TYPE_SELL_STOP_LIMIT):return("sell stop limit");
     }
   return(str_type);
  }

void MoveOrders()
 {
   MqlDateTime tm;
   HistorySelect(0,TimeCurrent());
//--- create objects
   string   name;
   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
   double   price;
   double   profit;
   datetime time;
   string   symbol;
   long     type;
   long     entry;
//--- for all deals
   double result = 0;
   double newStopLost;
   bool havesell= false, havebuy = false;
   for(uint i=0;i<total;i++)
     {
      //--- try to get deals ticket
      if(ticket=HistoryDealGetTicket(i))
        {
         //--- get deals properties
         price =HistoryDealGetDouble(ticket,DEAL_PRICE);
         time  =HistoryDealGetInteger(ticket,DEAL_TIME);
         symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         type  =HistoryDealGetInteger(ticket,DEAL_TYPE);
         entry =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
            //name="TradeHistory_Deal_"+string(ticket);
            //if(entry) ObjectCreate(0,name,OBJ_ARROW_RIGHT_PRICE,0,time,price,0,0);
            //else      ObjectCreate(0,name,OBJ_ARROW_LEFT_PRICE,0,time,price,0,0);
            ////--- set object properties
            //ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
            //ObjectSetInteger(0,name,OBJPROP_BACK,0);
            //ObjectSetInteger(0,name,OBJPROP_COLOR,type?BuyColor:SellColor);
            //if(profit!=0) ObjectSetString(0,name,OBJPROP_TEXT,"Profit: "+string(profit));
  //         }
//        }
     //}
//--- apply on chart
   //ChartRedraw();
  
//   for(int i = 0; i < cnt; i++) //---- обрабатываем открытые ордера - двигаем на размер стоплоса насколько можно
//    {
      //--- получим тикет ордера по его позиции в списке
//      if(ticket=OrderGetTicket(i))
//        {
         //--- получим свойства ордера
//         open_price=       OrderGetDouble(ORDER_PRICE_OPEN);
  //       current_price=       OrderGetDouble(ORDER_PRICE_CURRENT);
//         time_setup=       OrderGetInteger(ORDER_TIME_SETUP);
//         symbol=           OrderGetString(ORDER_SYMBOL);
//         order_magic=      OrderGetInteger(ORDER_MAGIC);
//         positionID =      OrderGetInteger(ORDER_POSITION_ID);
//         initial_volume=   OrderGetDouble(ORDER_VOLUME_INITIAL);
//         type=GetOrderType(OrderGetInteger(ORDER_TYPE));
         //--- подготовим и выведм информацию об ордере
//          string name=prefix+"Deal_"+tm.day+"_"+tm.hour+"_"+tm.min;
//      ObjectDelete(0,name);
//      if (OrderGetDouble(ORDER_PRICE_CURRENT)>OrderGetDouble(ORDER_PRICE_OPEN))
//         ObjectCreate(0,name,OBJ_ARROW_THUMB_UP,0,OrderGetInteger(ORDER_TIME_SETUP),OrderGetDouble(ORDER_PRICE_OPEN),0,0);
//      else   
//         ObjectCreate(0,name,OBJ_ARROW_THUMB_DOWN,0,OrderGetInteger(ORDER_TIME_SETUP),OrderGetDouble(ORDER_PRICE_OPEN),0,0);
         
   //--- сделаем недоступным для выделения мышкой 
//      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
        }
     }
      //if((type == ORDER_TYPE_BUY || type == ORDER_TYPE_SELL)) // посчитаем текущие результаты
      //        result += OrderProfit();// - OrderCommission() - OrderSwap();
      //     if(iVolume(SymbolsArray[SymbolIdx], time_frame,0)!=1) continue;
      //     if(OrderType()==OP_BUY)  
      //      {
      //      //newStopLost = iLow(SymbolsArray[SymbolIdx], timeframe,1) - 2*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);
      //       havebuy = true;
      //       newStopLost = alligator_GATORTEETH+MarketInfo(SymbolsArray[SymbolIdx],MODE_SPREAD)*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);//MarketInfo(SymbolsArray[SymbolIdx],MODE_BID)- SymbolSL[SymbolIdx]*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);
      //       slu= newStopLost - OrderStopLoss();
      //       if(slu>(MarketInfo(SymbolsArray[SymbolIdx],MODE_TICKSIZE)*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT)))
      //       if (IsDemo() || IsTesting()) OrderModify(OrderTicket(), 0, newStopLost, 0, 0, Gray);
      //     if ((TimeHour(iTime(SymbolsArray[SymbolIdx], 60,1))-TimeHour(OrderOpenTime()))<3) 
      //      {
      //       if ((iAO(SymbolsArray[SymbolIdx], time_frame,1)> iAO(SymbolsArray[SymbolIdx], 60,2)) // green
      //          &&(iVolume(SymbolsArray[SymbolIdx], time_frame,0)==1)) 
      //        {
      //         Print("Add ",3-(TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime())));
      //         OrderBuy(SymbolIdx, iperiod);
      //        } 
      //      }
      //    }
      //   if(OrderType()==OP_SELL)
      //    {
      //     if(SymbolSelOrderTicket[SymbolIdx]==0) SymbolSelOrderTicket[SymbolIdx]=OrderTicket();
      //     havesell= true;
      //     if(SymbolSelOrderTicket[SymbolIdx]== OrderTicket())
      //      {             
      //       if ((TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime()))<3) 
      //        {
      //         if (iAO(SymbolsArray[SymbolIdx], time_frame,1)< iAO(SymbolsArray[SymbolIdx], time_frame,2)) // red
      //          {
      //           Print("Add Sell lots= ",3-(TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime())));
      //           OrderSell(SymbolIdx, 0,0,0,3-(TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime())));
      //          } 
      //        }
      //       if ((TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime()))>2) 
      //         newStopLost = iHigh(SymbolsArray[SymbolIdx], time_frame,1) + 2*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);
      //       else  newStopLost = 0;
      //      }             
      //     if (newStopLost>0)
      //      {
      //       slu= OrderStopLoss() - newStopLost;
      //       if(slu>(MarketInfo(SymbolsArray[SymbolIdx],MODE_TICKSIZE)*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT)))
      //         if (IsDemo() || IsTesting()) OrderModify(OrderTicket(), 0, newStopLost, 0, 0, Gray);
      //      }
      //    }
      //  }
      // name = prefix + "equity"+SymbolsArray[SymbolIdx];
      // if(ObjectFind(name) == -1)  
      //  {
      //   ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
      //   ObjectSet(name, OBJPROP_XDISTANCE, 80);
      //   ObjectSet(name, OBJPROP_YDISTANCE, RowPos);
      //  }  
      // string eq = DoubleToStr(result, 2);
      // if(result > 0) eq = "+" + eq;
      // eq = "$" + eq;
      // if(result > 0) ObjectSetText(name, eq, FontSize, FontName, _DataPlus);
      // if(result < 0) ObjectSetText(name, eq,  FontSize, FontName, _DataMinus);
      // if(result == 0) ObjectSetText(name, "-------------",  FontSize, FontName, _Data);
      // ObjectSet(name, OBJPROP_CORNER, Corner);
      // if(havesell == false) SymbolSelOrderTicket[SymbolIdx]= 0;
      // if(havebuy  == false) SymbolBuyOrderTicket[SymbolIdx]= 0;

}


double CopyBufferMQL4(int handle,int index,int shift)
  {
   double buf[];
   switch(index)
     {
      case 0: if(CopyBuffer(handle,0,shift,1,buf)>0)
         return(buf[0]); break;
      case 1: if(CopyBuffer(handle,1,shift,1,buf)>0)
         return(buf[0]); break;
      case 2: if(CopyBuffer(handle,2,shift,1,buf)>0)
         return(buf[0]); break;
      case 3: if(CopyBuffer(handle,3,shift,1,buf)>0)
         return(buf[0]); break;
      case 4: if(CopyBuffer(handle,4,shift,1,buf)>0)
         return(buf[0]); break;
      default: break;
     }
   return(EMPTY_VALUE);
  }

double iRSIMQL4(string symbol,
                ENUM_TIMEFRAMES timeframe,
                int period,
                int price,
                int shift)
  {
   //ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   ENUM_APPLIED_PRICE applied_price=PriceMigrate(price);
   int handle=iRSI(symbol,timeframe,period,applied_price);
   if(handle<0)
     {
      Print("Объект iRSI не создан: Ошибка ",GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle,0,shift));
  }
ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0: return(MODE_SMA);
      case 1: return(MODE_EMA);
      case 2: return(MODE_SMMA);
      case 3: return(MODE_LWMA);
      default: return(MODE_SMA);
     }
  }
ENUM_APPLIED_PRICE PriceMigrate(int price)
  {
   switch(price)
     {
      case 1: return(PRICE_CLOSE);
      case 2: return(PRICE_OPEN);
      case 3: return(PRICE_HIGH);
      case 4: return(PRICE_LOW);
      case 5: return(PRICE_MEDIAN);
      case 6: return(PRICE_TYPICAL);
      case 7: return(PRICE_WEIGHTED);
      default: return(PRICE_CLOSE);
     }
  }
ENUM_STO_PRICE StoFieldMigrate(int field)
  {
   switch(field)
     {
      case 0: return(STO_LOWHIGH);
      case 1: return(STO_CLOSECLOSE);
      default: return(STO_LOWHIGH);
     }
  }
//+------------------------------------------------------------------+
enum ALLIGATOR_MODE  { MODE_GATORJAW=1,   MODE_GATORTEETH, MODE_GATORLIPS };
enum ADX_MODE        { MODE_MAIN,         MODE_PLUSDI, MODE_MINUSDI };
enum UP_LOW_MODE     { MODE_BASE,         MODE_UPPER,      MODE_LOWER };
enum ICHIMOKU_MODE   { MODE_TENKANSEN=1,  MODE_KIJUNSEN, MODE_SENKOUSPANA, MODE_SENKOUSPANB, MODE_CHINKOUSPAN };
enum MAIN_SIGNAL_MODE{ MODE_MAIN,         MODE_SIGNAL };

int RSIExpert()
 {
  double rsi_c,rsi_p;
 for(int i=1;i<Bars-1;i++)
  {
   rsi_c = iRSIMQL4(_Symbol, _Period ,  14,  PRICE_WEIGHTED,  i);
   rsi_p = iRSIMQL4(_Symbol, _Period ,  14,  PRICE_WEIGHTED,  i+1);
   if (((rsi_c-rsi_p)>1)
   &((tfHigh[i+1]-tfHigh[i])>0.0001))//&(Low[i]<Low[i-1]))
    {
     OrderBuy("rsi",_Symbol, tfTime[i-1],tfHigh[i-1]);
//     Print(Time[i]+"RSIP=",iRSIMQL4(_Symbol, _Period ,  14,  PRICE_WEIGHTED,  i+1)," Rsi=",iRSIMQL4(_Symbol, _Period ,  14,  PRICE_WEIGHTED,  i));
    }
   
   if (((rsi_p-rsi_c)>1)
   //&(High[i-1]>High[i]))
   &((tfLow[i]-tfLow[i+1])>0.0001))
     OrderSell("rsi",_Symbol, tfTime[i-1],tfLow[i-1]);
  }
 
 //Print("RSI=",iRSIMQL4(_Symbol, _Period ,  14,  PRICE_WEIGHTED,  1)," RsiPrew=",iRSIMQL4(_Symbol, _Period ,  14,  PRICE_WEIGHTED,  2));
 return 0;
 }

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
 {
  int SymbolIdx;
   //событие - клик по графическому объекту  
  if(id==CHARTEVENT_OBJECT_CLICK)
   {
   //клик по парам
    for( SymbolIdx = 0; SymbolIdx<MaxSymbols;SymbolIdx++)  
     {
      //name = prefix + SymbolsArray[SymbolIdx];
      if(sparam==prefix + SymbolsArray[SymbolIdx])
       {
        //проверим состояние кнопки
        bool selected=ObjectGetInteger(0,sparam,OBJPROP_STATE);//проверим состояние кнопки
         //если нажата
        if(selected)
         {
          Print(sparam," sel");
          ObjectSetString(0,"test_Object_Chart",OBJPROP_SYMBOL,SymbolsArray[SymbolIdx]);
          //Symbol(SymbolsArray[SymbolIdx]);
         } 
        else
         {
          Print(sparam," unsel");
         }
       }
     }
     
    for ( int iperiod = 0; iperiod<MaxPeriod;iperiod++)  // по периодам
     {
//       int timeframe = PeriodNumber[iperiod];
      //name = prefix + SymbolsArray[SymbolIdx];
      if(sparam==prefix + "period_"+PeriodName[iperiod])
       {
        //проверим состояние кнопки
        bool selected=ObjectGetInteger(0,sparam,OBJPROP_STATE);//проверим состояние кнопки
         //если нажата
        if(selected)
         {
          Print(sparam," sel");
          ObjectSetInteger(0,"test_Object_Chart",OBJPROP_PERIOD,PeriodNumber[iperiod]);
         } 
        else
         {
          Print(sparam," unsel");
         }
       }
     }
   for( SymbolIdx = 0; SymbolIdx<MaxSymbols;SymbolIdx++)  
    {
    for ( int iperiod = 0; iperiod<MaxPeriod;iperiod++)  // по периодам
     {
      if(sparam==prefix + SymbolsArray[SymbolIdx]+"_"+PeriodName[iperiod])
       {
        //проверим состояние кнопки
        bool selected=ObjectGetInteger(0,sparam,OBJPROP_STATE);//проверим состояние кнопки
         //если нажата
        if(selected)
         {
          ObjectSetInteger(0,"test_Object_Chart",OBJPROP_PERIOD,PeriodNumber[iperiod]);
          ObjectSetString(0,"test_Object_Chart",OBJPROP_SYMBOL,SymbolsArray[SymbolIdx]);
         } 
        else
         {
         }
//         ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
       }
     }
     }
   ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
   ChartRedraw();
   }
 }

extern bool IsWoodyExpert = false; 
extern bool IsWilliamsExpert = false; 
extern bool IsAlligatorExpert = false; 
extern bool IsFiguresExpert = false; 
extern bool IsChaosExpert = false; 
extern bool isFractalExpert = false; 
extern bool IsCandlesExpert = false; 


//Woody------- Внешние параметры ------------------------------------------
extern int  SlowCCIPeriod = 14;   // Период медленного CCI
extern int  FastCCIPeriod = 6;    // Период быстрого CCI
extern int  NSignalBar    = 6;    // Номер сигнального бара
extern int  Delta         = 3;    // Допуск в барах
extern bool ShowComment   = false; // Показывать комментарии

string GCSLcomment = " ";
int GC_Magic_Number = 0;
//Woody------- Буферы индикатора ------------------------------------------
double FastCCI[];
double SlowCCI[];
double HistCCI[];
double SignalBar[];
double TrendUp[];
double TrendDn[];

bool TrueBuySell = false;

double slu,sld,a,b;
//Alligator
int jaw_period = 13;
int jaw_shift = 8;
int teeth_period = 8;
int teeth_shift = 5;
int lips_period = 5;
int lips_shift = 3;
int applied_price = PRICE_WEIGHTED;// Взвешенная цена закрытия, (high+low+close+close)/4
//int ma_method = MODE_SMA ; //- простое скользящее среднее 
//int ma_method = MODE_EMA ; //- экспоненциальное скользящее среднее 
//int ma_method = MODE_SMMA;// - сглаженное скользящее среднее 
int ma_method = MODE_LWMA;// - линейно-взвешенное скользящее среднее 
 
double  alligator_GATORLIPS ;// green
double  alligator_GATORTEETH ; // red
double  alligator_GATORJAW ;// blue
double  alligator_GATORLIPSP ;// green
double  alligator_GATORTEETHP ; // red
double  alligator_GATORJAWP ;// blue

//color  LR.c=Orange;

string prefix = "GC_";
int MaxSymbols = 0;
string SymbolsArray[100];//={"","USDCHF","GBPUSD","EURUSD","USDJPY","AUDUSD","USDCAD","EURGBP","EURAUD","EURCHF","EURJPY","GBPJPY","GBPCHF"};
string Currencies[50];

int SymbolSelOrderTicket[100];
double SymbolSel[100];
double SymbolBuy[100];
int SymbolBuyOrderTicket[100];
//ENUM_TIMEFRAMES PeriodNumber[10]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
//string PeriodName[10]={"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int SymbolSL[100];

double TrendOnSymbol[100][10]; //  тренд по символу и таймфрейму
double WideOnSymbol[100][10]; //  ширина тренда по символу и таймфрейму
double ResultOnSymbol[10][10]; //  финрезультат по символу  - текущая открыто продаж, покупок прибыль
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
datetime Calked[100][10];
//| Получим Low для заданного номера бара |
//+------------------------------------------------------------------+
//double High[],Low[];
//double iLow(string symbol,ENUM_TIMEFRAMES timeframe,int index)
//{
//   double low=10;
//   ArraySetAsSeries(tfLow,true);
//   int copied=CopyLow(symbol,timeframe,0,Bars(symbol,timeframe),tfLow);
//   if(copied>0 && index<copied) low=tfLow[index];
//   return(low);
//}
////+------------------------------------------------------------------+
////| Получим High для заданного номера бара |
////+------------------------------------------------------------------+
//double iHigh(string symbol,ENUM_TIMEFRAMES timeframe,int index)
//{
//   double high=10;
//   ArraySetAsSeries(tfHigh,true);
//   int copied=CopyHigh(symbol,timeframe,0,Bars(symbol,timeframe),tfHigh);
//   if(copied>0 && index<copied) high=tfHigh[index];
//   return(high);
//}

void clear() 
  {
//---- Чистим график
   string name;
   int obj_total = ObjectsTotal(0);
   for(int i = obj_total - 1; i >= 0; i--)
     {
       name = ObjectName(0,i);
       if(StringFind(name, prefix) == 0) 
           ObjectDelete(0,name);
     }
  }

//+------------------------------------------------------------------+
//| СОЗДАЁТ СПИСОК ДОСТУПНЫХ ВАЛЮТНЫХ СИМВОЛОВ                       |
//+------------------------------------------------------------------+
int CreateSymbolList() // QC
  {
   int SymbolCount;
   int CurrencyCount = SymbolsTotal(true);
   int Loop;
   string TempSymbol;
   for(Loop = 0; Loop < CurrencyCount; Loop++) 
    {
     Currencies[Loop]=SymbolName(Loop,true);
    }
   if (OnlyCurrVals == false)
    { 
     SymbolsArray[SymbolCount] = _Symbol; SymbolCount++;
     for(Loop = 0; Loop < CurrencyCount; Loop++)
      {
       TempSymbol = Currencies[Loop];
       if((TempSymbol!=Symbol()))//&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1)))//&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
        {
         SymbolsArray[SymbolCount] = TempSymbol;
         SymbolCount++;
        }
      }
    }
   else
    {
     // прямые
     for(Loop = 0; Loop < CurrencyCount; Loop++)// for(SubLoop = 0; SubLoop < CurrencyCount; SubLoop++)
      {
//       string str=StringSubstr(_Symbol,3,3);
       if(StringSubstr(_Symbol,0,3)==StringSubstr(Currencies[Loop],0,3))
        {
         TempSymbol = Currencies[Loop];
         if((TempSymbol!=_Symbol))//&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1)))//&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      }
     for(Loop = 0; Loop < CurrencyCount; Loop++)
      {
       if(StringSubstr(_Symbol,3,3)==StringSubstr(Currencies[Loop],3,3))
        {
         TempSymbol = Currencies[Loop];
         if((TempSymbol!=_Symbol))//&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1)))//&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           //ArrayResize(SymbolsArray, SymbolCount + 1);
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      } 
     SymbolsArray[SymbolCount] = _Symbol; SymbolCount++;
     // противники
     for(Loop = 0; Loop < CurrencyCount; Loop++)
      {
       if(StringSubstr(_Symbol,0,3)==StringSubstr(Currencies[Loop],3,3))
        {
         TempSymbol = Currencies[Loop];
         if((TempSymbol!=_Symbol))//&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1)))//&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      }
     for(Loop = 0; Loop < CurrencyCount; Loop++)
      {
       if(StringSubstr(_Symbol,3,3)==StringSubstr(Currencies[Loop],0,3))
        {
         TempSymbol = Currencies[Loop];
         if((TempSymbol!=_Symbol))//&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1)))//&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           //ArrayResize(SymbolsArray, SymbolCount + 1);
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      } 
    }
    
   return(SymbolCount);
  }
int gc_update()
  {
 //  clear();
   int SymbolIdx = 3;
   int wid=0;
   int ColPos,RowPos;
   string data;
   double diff;
//----
//   printf("update %d",TimeCurrent());
   string name = prefix + "symbols";

   if(ObjectFind(0,name) == -1)  
   {
     ObjectCreate(0,name, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0,name, OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0,name, OBJPROP_YDISTANCE, TopPos);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,FontSize*9);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,FontSize*2);
      ObjectSetString(0,name,OBJPROP_TEXT, _Symbol_);
      //ObjectSetString(0,name, _Symbol_, FontSize, FontName, _Header);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,1);
     }
//   ObjectSetInteger(0,name, OBJPROP_CORNER, Corner);
   name = prefix + "equity";
   if(ObjectFind(0,name) == -1)  
    {
     ObjectCreate(0,name, OBJ_BUTTON, 0, 0, 0);
     ObjectSetInteger(0,name, OBJPROP_XDISTANCE, FontSize*9+20);
     ObjectSetInteger(0,name, OBJPROP_YDISTANCE, TopPos);
     ObjectSetInteger(0,name,OBJPROP_XSIZE,FontSize*10);
     ObjectSetInteger(0,name,OBJPROP_YSIZE,FontSize*2);
     ObjectSetInteger(0,name,OBJPROP_SELECTABLE,1);
     ObjectSetString(0,name,OBJPROP_TEXT, _ValueName_);
    }
   //RowPos = TopPos+FontSize;
   for( SymbolIdx = 0; SymbolIdx<MaxSymbols;SymbolIdx++)  
    {
  //   if (SymbolSL[SymbolIdx]==0 ) SymbolSL[SymbolIdx] = CalkSL(SymbolIdx);
     long spread = SymbolInfoInteger(SymbolsArray[SymbolIdx],SYMBOL_SPREAD);//MarketInfo(SymbolsArray[SymbolIdx],MODE_SPREAD);
//     RowPos = RowPos+FontSize*1.8;
     RowPos = TopPos + (SymbolIdx+1)*FontSize*2;
     name = prefix + SymbolsArray[SymbolIdx];
     ObjectDelete(0,name);
     if(ObjectFind(0,name) == -1)  
      {
       ObjectCreate(0,name, OBJ_BUTTON, 0, 0, 0);
       ObjectSetInteger(0,name, OBJPROP_XDISTANCE, 20);
       ObjectSetInteger(0,name, OBJPROP_YDISTANCE, RowPos);
       ObjectSetInteger(0,name,OBJPROP_XSIZE,FontSize*9);
       ObjectSetInteger(0,name,OBJPROP_YSIZE,FontSize*2);
       ObjectSetString(0,name,OBJPROP_TEXT,SymbolsArray[SymbolIdx]+"("+DoubleToString(spread,0)+")");
       ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
       ObjectSetInteger(0,name,OBJPROP_BGCOLOR,Bg_Color);
       ObjectSetInteger(0,name,OBJPROP_COLOR,Btn_Color);
       ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
       if (Symbol() == SymbolsArray[SymbolIdx]) ObjectSetInteger(0,name,OBJPROP_COLOR,_TextCurr );
      }
    // if (SymbolsArray[SymbolIdx]==Symbol())       
    //  {
    //   name = "Sale_Line";
    //   //if ((SymbolSel[SymbolIdx]==0)&&(ObjectFind(name)!=-1)) 
    //   ObjectDelete(0,name);
    //   if (SymbolSel[SymbolIdx]>0)
    //    {
    //     ObjectCreate(0,name,OBJ_TREND,0,iTime(SymbolsArray[SymbolIdx], Period(),1),SymbolSel[SymbolIdx],iTime(SymbolsArray[SymbolIdx], Period(),0),SymbolSel[SymbolIdx]);
    //       ObjectSet(name,OBJPROP_COLOR,Gold);
    //       ObjectSet(name,OBJPROP_WIDTH,1);
    //       ObjectSet(name,OBJPROP_RAY,True);
    //      }
    //     name = "buy_Line";
    //     ObjectDelete(name);
    //     if (SymbolBuy[SymbolIdx] > 0) 
    //      {
    //       ObjectCreate(name,OBJ_TREND,0,iTime(SymbolsArray[SymbolIdx], Period(),1),SymbolBuy[SymbolIdx],iTime(SymbolsArray[SymbolIdx], Period(),0),SymbolBuy[SymbolIdx]);
    //       ObjectSet(name,OBJPROP_COLOR,Magenta);
    //       ObjectSet(name,OBJPROP_WIDTH,1);
    //       ObjectSet(name,OBJPROP_RAY,True);
    //      }
    //    }
    //   //
       for ( int iperiod = 0; iperiod<MaxPeriod;iperiod++)  // по периодам
        {
         ColPos = 20+FontSize*19+(iperiod*FontSize*5);
//         int timeframe = PeriodNumber[iperiod];
         name = prefix + "period_"+PeriodName[iperiod];
         // шапка
         if(ObjectFind(0,name) == -1)  
          {
           ObjectCreate(0,name, OBJ_BUTTON, 0, 0, 0);
           ObjectSetString(0,name,OBJPROP_TEXT,PeriodName[iperiod]);
           ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
           ObjectSetInteger(0,name, OBJPROP_XDISTANCE, ColPos);
           ObjectSetInteger(0,name, OBJPROP_YDISTANCE, TopPos);
           ObjectSetInteger(0,name,OBJPROP_XSIZE,FontSize*5);
           ObjectSetInteger(0,name,OBJPROP_YSIZE,FontSize*2);
           ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
           ObjectSetInteger(0,name,OBJPROP_BGCOLOR,Bg_Color);
           ObjectSetInteger(0,name,OBJPROP_COLOR,Btn_Color);
    //       if (Period() == PeriodNumber[iperiod]) ObjectSet(name,OBJPROP_COLOR,_TextCurr );
          }
         name = prefix + SymbolsArray[SymbolIdx]+"_"+PeriodName[iperiod];
         if(ObjectFind(0,name) == -1)  
          {
           ObjectCreate(0,name, OBJ_BUTTON, 0, 0, 0);
           ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
           ObjectSetInteger(0,name, OBJPROP_XDISTANCE, ColPos);
           ObjectSetInteger(0,name, OBJPROP_YDISTANCE, RowPos);
           ObjectSetInteger(0,name,OBJPROP_XSIZE,FontSize*5);
           ObjectSetInteger(0,name,OBJPROP_YSIZE,FontSize*2);
           ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
           ObjectSetInteger(0,name,OBJPROP_BGCOLOR,Bg_Color);
           ObjectSetInteger(0,name,OBJPROP_COLOR,Btn_Color);
    //       if (Period() == PeriodNumber[iperiod]) ObjectSet(name,OBJPROP_COLOR,_TextCurr );
        }
        double diff = 0;//10000*(iHigh(SymbolsArray[SymbolIdx], PeriodNumber[iperiod],1) 
        //- iLow(SymbolsArray[SymbolIdx], PeriodNumber[iperiod],1)
        //- iHigh(SymbolsArray[SymbolIdx], PeriodNumber[iperiod],5) 
        //+ iLow(SymbolsArray[SymbolIdx], PeriodNumber[iperiod],5));
        ObjectSetInteger(0,name,OBJPROP_COLOR,_Data);
        if (diff>0)
         {
           ObjectSetInteger(0,name,OBJPROP_COLOR,_DataPlus);
         }
        if (diff<0)
         {
           ObjectSetInteger(0,name,OBJPROP_COLOR,_DataMinus);
         } 
        ObjectSetString(0,name,OBJPROP_TEXT,(int)diff);
    
    //     if (Calked[SymbolIdx][iperiod]!=iTime(SymbolSel[SymbolIdx],timeframe,0)) 
    //      {
    //       Calked[SymbolIdx][iperiod] = iTime(SymbolSel[SymbolIdx],timeframe,0);
    //       name = "Sale_Line";
    //       if ((SymbolSel[SymbolIdx]==0)&&(ObjectFind(name)!=-1)) ObjectDelete(name);
    //       if ((SymbolSel[SymbolIdx]>0)&&(ObjectFind(name)==-1))
    //        {
    //         ObjectCreate(name,OBJ_TREND,0,iTime(SymbolsArray[SymbolIdx], timeframe,1),SymbolSel[SymbolIdx],iTime(SymbolsArray[SymbolIdx], timeframe,0),SymbolSel[SymbolIdx]);
    //         ObjectSet(name,OBJPROP_COLOR,Gold);
    //         ObjectSet(name,OBJPROP_WIDTH,1);
    //         ObjectSet(name,OBJPROP_RAY,True);
    //        }
    //       name = "buy_Line";
    //       ObjectDelete(name);
    //       if (SymbolBuy[SymbolIdx] > 0) 
    //        {
    //         ObjectCreate(name,OBJ_TREND,0,iTime(SymbolsArray[SymbolIdx], timeframe,1),SymbolBuy[SymbolIdx],iTime(SymbolsArray[SymbolIdx], timeframe,0),SymbolBuy[SymbolIdx]);
    //         ObjectSet(name,OBJPROP_COLOR,Magenta);
    //         ObjectSet(name,OBJPROP_WIDTH,1);
    //         ObjectSet(name,OBJPROP_RAY,True);
    //        }
    //       alligator_GATORLIPS = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORLIPS , 1);// green
    //       alligator_GATORTEETH = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORTEETH , 1); // red
    //       alligator_GATORJAW = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORJAW , 1);// blue
    //       alligator_GATORLIPSP = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORLIPS , 2);// green
    //       alligator_GATORTEETHP = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORTEETH , 2); // red
    //       alligator_GATORJAWP = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORJAW , 2);// blue
    //       CalkTrend(SymbolIdx,iperiod); 
    //       name = prefix + "period_"+PeriodName[iperiod]+"_"+SymbolsArray[SymbolIdx];
    //       if(ObjectFind(name) == -1)  ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
    //       ObjectSet(name, OBJPROP_XDISTANCE, ColPos);
    //       ObjectSet(name, OBJPROP_YDISTANCE, RowPos);
    //       data = " "+DoubleToStr(TrendOnSymbol[SymbolIdx, iperiod],2)+"("+DoubleToStr(WideOnSymbol[SymbolIdx, iperiod]-spread,0)+")";
    //       if(MathAbs(TrendOnSymbol[SymbolIdx, iperiod]) < 5*MarketInfo(SymbolsArray[SymbolIdx],MODE_SPREAD)) ObjectSetText(name, "Flat"+"("+DoubleToStr(WideOnSymbol[SymbolIdx, iperiod],0)+")", FontSize, FontName, _Data);
    //       else if(TrendOnSymbol[SymbolIdx, iperiod] > 0) ObjectSetText(name, data, FontSize, FontName, _DataPlus);
    //       else if(TrendOnSymbol[SymbolIdx, iperiod] < 0) ObjectSetText(name, data, FontSize, FontName, _DataMinus);
    //       if (PeriodNumber[iperiod]==Period())  wid=WhatToDo(SymbolIdx, iperiod);
    //      }
    //    }
    //   if (!IsTesting()||SymbolsArray[SymbolIdx]==Symbol())  // по валютам
    //    {
    //     if (MathAbs(SymbolBuy[SymbolIdx] - MarketInfo(SymbolsArray[SymbolIdx],MODE_ASK))<MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT)) {OrderBuy(SymbolIdx, 1); SymbolBuy[SymbolIdx] =0;}
    //     if (MathAbs(SymbolSel[SymbolIdx] - MarketInfo(SymbolsArray[SymbolIdx],MODE_BID))<MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT)) {OrderSell(SymbolIdx, 1);SymbolSel[SymbolIdx] = 0; }
    //     int cnt = OrdersTotal();
    //     double result = 0;
    //     double newStopLost;
    //     bool havesell= false, havebuy = false;
    //     for(int i = 0; i < cnt; i++) //---- обрабатываем открытые ордера - двигаем на размер стоплоса насколько можно
    //      {
    //       if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))    continue; //---- только "активные"
    //       if(SymbolsArray[SymbolIdx]!= OrderSymbol()) continue; //---- только "активные"
    //       if((OrderType() == OP_BUY || OrderType() == OP_SELL)) // посчитаем текущие результаты
    //          result += OrderProfit();// - OrderCommission() - OrderSwap();
    //       if(iVolume(SymbolsArray[SymbolIdx], time_frame,0)!=1) continue;
    //       if(OrderType()==OP_BUY)  
    //        {
    //        //newStopLost = iLow(SymbolsArray[SymbolIdx], timeframe,1) - 2*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);
    //         havebuy = true;
    //         newStopLost = alligator_GATORTEETH+MarketInfo(SymbolsArray[SymbolIdx],MODE_SPREAD)*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);//MarketInfo(SymbolsArray[SymbolIdx],MODE_BID)- SymbolSL[SymbolIdx]*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);
    //         slu= newStopLost - OrderStopLoss();
    //         if(slu>(MarketInfo(SymbolsArray[SymbolIdx],MODE_TICKSIZE)*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT)))
    //         if (IsDemo() || IsTesting()) OrderModify(OrderTicket(), 0, newStopLost, 0, 0, Gray);
    //       if ((TimeHour(iTime(SymbolsArray[SymbolIdx], 60,1))-TimeHour(OrderOpenTime()))<3) 
    //        {
    //         if ((iAO(SymbolsArray[SymbolIdx], time_frame,1)> iAO(SymbolsArray[SymbolIdx], 60,2)) // green
    //            &&(iVolume(SymbolsArray[SymbolIdx], time_frame,0)==1)) 
    //          {
    //           Print("Add ",3-(TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime())));
    //           OrderBuy(SymbolIdx, iperiod);
    //          } 
    //        }
    //      }
    //     if(OrderType()==OP_SELL)
    //      {
    //       if(SymbolSelOrderTicket[SymbolIdx]==0) SymbolSelOrderTicket[SymbolIdx]=OrderTicket();
    //       havesell= true;
    //       if(SymbolSelOrderTicket[SymbolIdx]== OrderTicket())
    //        {             
    //         if ((TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime()))<3) 
    //          {
    //           if (iAO(SymbolsArray[SymbolIdx], time_frame,1)< iAO(SymbolsArray[SymbolIdx], time_frame,2)) // red
    //            {
    //             Print("Add Sell lots= ",3-(TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime())));
    //             OrderSell(SymbolIdx, 0,0,0,3-(TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime())));
    //            } 
    //          }
    //         if ((TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime()))>2) 
    //           newStopLost = iHigh(SymbolsArray[SymbolIdx], time_frame,1) + 2*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);
    //         else  newStopLost = 0;
    //        }             
    //       if (newStopLost>0)
    //        {
    //         slu= OrderStopLoss() - newStopLost;
    //         if(slu>(MarketInfo(SymbolsArray[SymbolIdx],MODE_TICKSIZE)*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT)))
    //           if (IsDemo() || IsTesting()) OrderModify(OrderTicket(), 0, newStopLost, 0, 0, Gray);
    //        }
    //      }
    //    }
    //   name = prefix + "equity"+SymbolsArray[SymbolIdx];
    //   if(ObjectFind(name) == -1)  
    //    {
    //     ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
    //     ObjectSet(name, OBJPROP_XDISTANCE, 80);
    //     ObjectSet(name, OBJPROP_YDISTANCE, RowPos);
    //    }  
    //   string eq = DoubleToStr(result, 2);
    //   if(result > 0) eq = "+" + eq;
    //   eq = "$" + eq;
    //   if(result > 0) ObjectSetText(name, eq, FontSize, FontName, _DataPlus);
    //   if(result < 0) ObjectSetText(name, eq,  FontSize, FontName, _DataMinus);
    //   if(result == 0) ObjectSetText(name, "-------------",  FontSize, FontName, _Data);
    //   ObjectSet(name, OBJPROP_CORNER, Corner);
    //   if(havesell == false) SymbolSelOrderTicket[SymbolIdx]= 0;
    //   if(havebuy  == false) SymbolBuyOrderTicket[SymbolIdx]= 0;
      }
    }
 if (ShowGraph)
  {
   string chart_name="test_Object_Chart";
  // Print("Попробуем создать объект Chart  с именем ",chart_name);
//--- если такого объекта нет - создадим его
   if(ObjectFind(0,chart_name)<0)
    {
      ObjectCreate(0,chart_name,OBJ_CHART,0,0,0,0,0);
   //--- зададим символ
      ObjectSetString(0,chart_name,OBJPROP_SYMBOL,"EURUSD");
   //--- зададим координату X для точки привязки
      ObjectSetInteger(0,chart_name,OBJPROP_XDISTANCE,100);
   //--- зададим координату Y для точки привязки
      ObjectSetInteger(0,chart_name,OBJPROP_YDISTANCE,TopPos + (SymbolIdx+3)*FontSize*2);
//--- установим ширину
      ObjectSetInteger(0,chart_name,OBJPROP_XSIZE,400);
   //--- установим высоту
      ObjectSetInteger(0,chart_name,OBJPROP_YSIZE,300);
   //--- установим период
      ObjectSetInteger(0,chart_name,OBJPROP_PERIOD,PERIOD_M5);
   //--- установим масшаб ( от 0 до 5)
      //ObjectSetInteger(0,chart_name,OBJPROP_SCALE,4);
   //--- сделаем недоступным для выделения мышкой 
      ObjectSetInteger(0,chart_name,OBJPROP_SELECTABLE,false);
   } 
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| возвращает размер стоплоса в пунктах для выбранной пары          |
//+------------------------------------------------------------------+
int CalkSL(int SymbolIdx)
 {
  return(2);//*MarketInfo(SymbolsArray[SymbolIdx],MODE_STOPLEVEL)); // пока так
 }
//+------------------------------------------------------------------+
//| возвращает true в случае успешного открытия Buy                  |
//+------------------------------------------------------------------+
//bool OrderBuy(string symbol, double price =0, double SP = 0)
bool OrderBuy(int SymbolIdx, int timeframeIdx, double price =0, double SP = 0,int lots=1)
 {
  bool res=false;
  //string symbol = SymbolsArray[SymbolIdx];
  //int timeframe = PeriodNumber[timeframeIdx];
  // int cnt = OrdersTotal();
  // for(int i = 0; i < cnt; i++) //---- обрабатываем открытые ордера
  //  {
  //   if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))    continue; //---- только "активные"
  //   if((OrderType() == OP_SELL )&& symbol== OrderSymbol())     OrderClose(OrderTicket(), OrderLots(),MarketInfo(symbol,MODE_BID),3,Gray)  ;
  //  }
  // bool res=false;
  // Print("OrderBuy");
  // if (IsDemo() || IsTesting()) TrueBuySell = true;
  // if (Symbol() == symbol)
  //  {
  //   string name = "tipa_buy";
  //   if(ObjectFind(name) != -1)  ObjectDelete(name);
  //   ObjectCreate(name, OBJ_ARROW, 0, Time[0], MarketInfo(symbol,MODE_ASK));
  //   ObjectSet(name,OBJPROP_ARROWCODE,71);
  //   if (TrueBuySell == true)  // реально заключаем сделки
  //    {
  //     double openPrice = MarketInfo(symbol,MODE_ASK);
  //     if (price >0) openPrice = price;
  //     double StopPrice = MarketInfo(symbol,MODE_BID)-15*MarketInfo(symbol,MODE_STOPLEVEL)*MarketInfo(symbol,MODE_POINT);
  //     double TakePrice = openPrice+10*MarketInfo(symbol,MODE_STOPLEVEL)*MarketInfo(symbol,MODE_POINT);
  //     double set_lots = MarketInfo(symbol,MODE_MINLOT)*lots;
  //     string GCSLcomment = " ";
  //     if (symbol==Symbol()) res=OrderSend(symbol,OP_BUY,set_lots,openPrice,SP,StopPrice,TakePrice,GCSLcomment,GC_Magic_Number,0,Blue);
  //    }
  //  }
   return (res);
  }
    
//+------------------------------------------------------------------+
//| возвращает true в случае успешного открытия Sel                  |
//+------------------------------------------------------------------+
//bool OrderSell(string symbol, double price =0, double SP = 0)
int OrderSell(int SymbolIdx, int timeframeIdx, double price =0, double SP = 0,int lots=1)
 {
   bool res=false;
//  string symbol = SymbolsArray[SymbolIdx];
//  int timeframe = PeriodNumber[timeframeIdx];
//   int cnt = OrdersTotal();
//   for(int i = 0; i < cnt; i++) //---- обрабатываем открытые ордера
//    {
//     if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))    continue; //---- только "активные"
////     if((OrderType() == OP_SELL)&& symbol== OrderSymbol())       return (false);
//     if((OrderType() == OP_BUY )&& symbol== OrderSymbol())       OrderClose(OrderTicket(), OrderLots(),MarketInfo(symbol,MODE_ASK),3,Gray)  ;
//    }
//   int res=0;
//   if (IsDemo() || IsTesting()) TrueBuySell = true;
//   if (Symbol() == symbol)
//    {
//     string name = "tipa_sale";
//     if(ObjectFind(name) != -1)  ObjectDelete(name);
//     ObjectCreate(name, OBJ_ARROW, 0, Time[2], MarketInfo(symbol,MODE_ASK));
//     ObjectSet(name,OBJPROP_ARROWCODE,72);
//    }
//   if (TrueBuySell == true)  // реально заключаем сделки
//    {
//     double openPrice = MarketInfo(symbol,MODE_BID);
//     if (price >0) openPrice = price;  
//     double StopPrice = MarketInfo(symbol,MODE_ASK)+15*MarketInfo(symbol,MODE_STOPLEVEL)*MarketInfo(symbol,MODE_POINT);
//     double TakePrice = 0;//openPrice-3*MarketInfo(symbol,MODE_STOPLEVEL)*MarketInfo(symbol,MODE_POINT);
//     double set_lots = MarketInfo(symbol,MODE_MINLOT)*lots;
//     if (price ==0)   res=OrderSend(symbol,OP_SELL,set_lots,openPrice,SP,StopPrice,TakePrice,GCSLcomment,GC_Magic_Number,0,Red);
//     else        res=OrderSend(symbol,OP_SELLLIMIT,set_lots,openPrice,SP,StopPrice,TakePrice,GCSLcomment,GC_Magic_Number,0,Red);
//     if(SymbolSelOrderTicket[SymbolIdx]== 0) SymbolSelOrderTicket[SymbolIdx]=res;
//    }
   return (res);
  }
    

//+------------------------------------------------------------------+
//| возвращает что делать - 0=ничего, 1 -продать, 2 -купить          |
//+------------------------------------------------------------------+


//int WhatToDo(int SymbolIdx, int timeframeIdx)
// {
//   string symbol = SymbolsArray[SymbolIdx];
//   int timeframe = PeriodNumber[timeframeIdx];
//   
////   double  alligator_GATORLIPS = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORLIPS , 0);// green
////   double  alligator_GATORTEETH = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORTEETH , 0); // red
////   double  alligator_GATORJAW = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORJAW , 0);// blue
//   int WTD = 0,wdy =0,ae=0;
//   double alligator;
//   if (isFractalExpert == True)
//    {
//     int isFract = HaveFractal(SymbolIdx, timeframe);
//     if (isFract == 2) // up
//      {   /// red
//       SymbolBuy[SymbolIdx] =  iHigh(symbol, timeframe,3) +MarketInfo(symbol,MODE_SPREAD)*MarketInfo(symbol,MODE_POINT);
//      }   ///red
//     if (isFract == 1) // down
//      {
//       SymbolSel[SymbolIdx] = iLow(symbol, timeframe,3) - MarketInfo(symbol,MODE_POINT);
//      }
//    }
//   if( IsWoodyExpert == true) 
//    {
//     wdy = WoodyExpert(symbol, timeframe);
//    }
//   if (IsAlligatorExpert == True)
//    {
//     ae=AlligatorExpert(symbol, timeframe);
//    }
//  if (IsFiguresExpert == True )
//   {
//    //WTD = 
//    FiguresExpert(symbol, timeframe);
//   }
//  if (IsCandlesExpert == True )
//   {
//    CandlesExpert(SymbolIdx, timeframeIdx);
//   }
//
//  WTD = ae;
////  if (WTD==1 )   OrderSell(symbol);
////if (WTD==2 )   OrderBuy(symbol);
//  if (IsChaosExpert == True )    WTD = ChaosExpert(SymbolIdx, timeframeIdx);
//  //if (WTD==1 )   OrderSell(symbol);
//  //if (WTD==2 )   OrderBuy(symbol);
//  return(WTD); // ничего
// }
//
//int HaveFractal(int SymbolIdx, int timeframe)
//  {
//   string symbol = SymbolsArray[SymbolIdx];
//   if((iHigh(symbol,timeframe,2)>iHigh(symbol,timeframe,1))
//    &&(iHigh(symbol,timeframe,2)>iHigh(symbol,timeframe,3)))
//     {
// //      Print("SymbolBuy[SymbolIdx]=",SymbolBuy[SymbolIdx]);
//       SymbolBuy[SymbolIdx] =  iHigh(symbol, timeframe,2) +(MarketInfo(symbol,MODE_SPREAD)+1)*MarketInfo(symbol,MODE_POINT);
//      }
////    return(2);
//   if((iLow(symbol,timeframe,2)<iLow(symbol,timeframe,1))
//    &&(iLow(symbol,timeframe,2)<iLow(symbol,timeframe,3)))
//       SymbolSel[SymbolIdx] = iLow(symbol, timeframe,2) - MarketInfo(symbol,MODE_POINT);
////    return(1);
//
////   if(iFractals(symbol,timeframe,MODE_UPPER,3)>0) return(2);
////   if(iFractals(symbol,timeframe,MODE_LOWER,3)>0) return(1);
//   return(0);
//  
//  }
//  
//int WoodyExpert(string symbol, int timeframe)
// {
//  int result=0;
//  bool fcu=False, fcd=False, fup=False, fdn=False;
//  int shift, ss;
//  string comm;
//  for (shift=5; shift>=0; shift--) {
//    TrendUp[shift] = 0;
//    TrendDn[shift] = 0;
//    FastCCI[shift] = iCCI(symbol, timeframe, FastCCIPeriod, PRICE_TYPICAL, shift);
//    SlowCCI[shift] = iCCI(symbol, timeframe, SlowCCIPeriod, PRICE_TYPICAL, shift);
//    HistCCI[shift] = SlowCCI[shift];
//    if (HistCCI[shift+1]*HistCCI[shift]<0) {
//      if (ss<=Delta) {
//        if (fup && HistCCI[shift]>0) fcu = True;
//        else fcu = False;
//        if (fdn && HistCCI[shift]<0) fcd = True;
//        else fcd = False;
//      } else {
//        if (ss<NSignalBar) {
//          fup = False; fdn = False;
//          fcu = False; fcd = False;
//          comm = "No Trend";
//        }
//      }
//      ss = 1;
//    } else ss++;
//    if (ss==NSignalBar) SignalBar[shift] = HistCCI[shift];
//    else SignalBar[shift] = 0;
//    if ((ss>NSignalBar || fcu) && HistCCI[shift]>0) {
//      TrendUp[shift] = HistCCI[shift];
//      fup = True; fdn = False; fcd = False;
//      comm = "Up Trend "+(ss-NSignalBar);result = ss-NSignalBar;
//    }
//    if ((ss>NSignalBar || fcd) && HistCCI[shift]<0) {
//      TrendDn[shift] = HistCCI[shift];
//      fdn = True; fup = False; fcu = False;
//      comm = "Down Trend "+(ss-NSignalBar);result = ss-NSignalBar;
//    }
//  }
//  if (ShowComment) Comment(comm);
//   Print(TrendUp[0]);
//      if (result>1) result = 2;
//     if (result<-1) result = 1;
//    
//     if ( result == 2) // buy
//      {
////       if ((iHigh(symbol, timeframe, 0)> alligator_GATORLIPS)&&(alligator_GATORLIPS > alligator_GATORTEETH)&&(alligator_GATORTEETH > alligator_GATORJAW))
//        {
//        }
////       else 
//        {
//         result = 0;
//        }
//       }
//      if ( result == 1) // buy
//       {
////        if ((iLow(symbol, timeframe, 0)< alligator_GATORLIPS)&&(alligator_GATORLIPS < alligator_GATORTEETH)&&( alligator_GATORTEETH < alligator_GATORJAW))
//        {
//        }
////        else 
//        {
//         result = 0;
//        }
//      }
//  
//   return (result); 
// }
//int AlligatorExpert(string symbol, int timeframe)
// {
//  int WTD = 0;
//  double up[4]={0,0,0,0}, down[4]={0,0,0,0};
//  double  alligator_GATORLIPS = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORLIPS , 0);// green
//  double  alligator_GATORTEETH = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORTEETH , 0); // red
//  double  alligator_GATORJAW = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORJAW , 0);// blue
//  int i;
//  for (i = 0; i< 3;i++)
//   {
//    alligator_GATORLIPS = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORLIPS , i);// green
//    alligator_GATORTEETH = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORTEETH , i); // red
//    alligator_GATORJAW = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORJAW , i);// blue
//    if (up[0]>0)
//     {
//      if ((up[1]>alligator_GATORLIPS)&&(up[2]>alligator_GATORTEETH)&&(up[3]>alligator_GATORJAW)&&
//         ((up[1]-alligator_GATORLIPS)>0)&&
//          ((up[1]-alligator_GATORLIPS)>(up[2]-alligator_GATORTEETH))&&
//          ((up[2]-alligator_GATORTEETH)>(up[3]-alligator_GATORJAW)))
//       {
//        up[0]=1;
//       }
//       else up[0]=-1;
//      }
//    if (down[0]>0)
//      {
//       if ((down[1]<alligator_GATORLIPS)&&(down[2]<alligator_GATORTEETH)&&(down[3]<alligator_GATORJAW)&&
//          ((alligator_GATORLIPS-down[1])>(alligator_GATORTEETH-down[2]))&&((alligator_GATORTEETH -down[2])>(alligator_GATORJAW- down[3]))       
//         )
//        {
//         down[0]=1;
//        }
//       else down[0]=-1;
//      }
//     up[1]=alligator_GATORLIPS;up[2]=alligator_GATORTEETH;up[3]=alligator_GATORJAW;
//     down[1]=alligator_GATORLIPS;down[2]=alligator_GATORTEETH;down[3]=alligator_GATORJAW;
//     if (up[0]==0) up[0]=1;
//     if (down[0]==0) down[0]=1;
//    }
////     if (wdy<-1) WTD = 1;
//  for (i = 0; i< 10;i++)  if (timeframe== PeriodNumber[i]) break;
//  int SymbolIdx = 0; for (SymbolIdx = 0; i< 10;i++)  if (symbol== SymbolsArray[i]) break;
//  if (MathAbs(TrendOnSymbol[SymbolIdx, i+1]) < MarketInfo(symbol,MODE_SPREAD)) 
//    { 
//     if ((up[0]==1)) WTD = 2;
//     if ((down[0]==1)) WTD = 1;
//    }
// return(WTD);
//}
//
//int FiguresExpert(string symbol, int timeframe)
// {
//  string name;
//  int result=0;
//  double Resistance_Line_Price[2]={0,0}; // up
//  datetime Resistance_Line_dt[2];
//  double Support_Line_Price[2]={0,0};    // down
//  double Resistance_Line_Angle = 0,Support_Line_Angle = 0;
//  datetime Support_Line_dt[2];    // down
//  double dh,dhc,dl,dlc;
//  int Resistance_Line_shift[2];
//  int Support_Line_shift[2];
//  for (int i = 0; i< 25; i++)
//   {
//    dh = iHigh(symbol, timeframe,i);dl = iLow(symbol, timeframe,i);
//    if (Resistance_Line_Price[0]==0) {Resistance_Line_Price[0]=dh;Resistance_Line_dt[0]=iTime(symbol, timeframe,i); Resistance_Line_shift[0] = i;}
//    if (Support_Line_Price[0]==0) {Support_Line_Price[0]=dl;Support_Line_dt[0]=iTime(symbol, timeframe,i); Support_Line_shift[0] = i;}
//    if (i<2)
//     {
//      if (Resistance_Line_Price[0]<dh)
//       {
//        Resistance_Line_Price[0]=dh;Resistance_Line_dt[0]=iTime(symbol, timeframe,i); Resistance_Line_shift[0] = i;
//       }  
//      if (Support_Line_Price[0]>dl)
//       {
//        Support_Line_Price[0]=dl;Support_Line_dt[0]=iTime(symbol, timeframe,i); Support_Line_shift[0] = i;
//       }  
//     }
//    else
//     {
//      if (Resistance_Line_Price[1]==0) 
//       {
//        if(i == (Resistance_Line_shift[0]+1)) i+=2;
//        Resistance_Line_Price[1]=dh;Resistance_Line_dt[1]=iTime(symbol, timeframe,i); Resistance_Line_shift[1] = i;
//       }
//      Resistance_Line_Angle = (Resistance_Line_Price[1] - Resistance_Line_Price[0])/(Resistance_Line_shift[1] - Resistance_Line_shift[0])/MarketInfo(symbol,MODE_POINT);
//      dhc = MathRound(Resistance_Line_Price[0]/MarketInfo(symbol,MODE_POINT)-Resistance_Line_Angle*(i-Resistance_Line_shift[0]));
//      Print("(",Resistance_Line_Price[1]," - ",Resistance_Line_Price[0],") / (",Resistance_Line_shift[1]," - ",Resistance_Line_shift[0],")=",Resistance_Line_Angle," ",dhc," ",MathRound(dh/MarketInfo(symbol,MODE_POINT))," ",i);
//      if (MathAbs(dhc-MathRound(dh/MarketInfo(symbol,MODE_POINT)))< 1)
//       {
//        Resistance_Line_Price[1]=dh;Resistance_Line_dt[1]=iTime(symbol, timeframe,i);Resistance_Line_shift[1] = i;
//       }   
//      
//      if (Support_Line_Price[1]==0) 
//       {
//        if(i == (Support_Line_shift[0]+1)) i+=2;
//        Support_Line_Price[1]=dl;Support_Line_dt[1]=iTime(symbol, timeframe,i); Support_Line_shift[1] = i;
//       }
//      Support_Line_Angle = (Support_Line_Price[1] - Support_Line_Price[0])/(Support_Line_shift[1] - Support_Line_shift[0])/MarketInfo(symbol,MODE_POINT);
//      dlc = MathRound(Support_Line_Price[0]/MarketInfo(symbol,MODE_POINT)-Support_Line_Angle*(i-Support_Line_shift[0]));
//      Print("(",Resistance_Line_Price[1]," - ",Resistance_Line_Price[0],") / (",Resistance_Line_shift[1]," - ",Resistance_Line_shift[0],")=",Resistance_Line_Angle," ",dhc," ",MathRound(dh/MarketInfo(symbol,MODE_POINT))," ",i);
//      if (MathAbs(dlc-MathRound(dl/MarketInfo(symbol,MODE_POINT)))< 1)
//       {
//        Support_Line_Price[1]=dl;Support_Line_dt[1]=iTime(symbol, timeframe,i);Support_Line_shift[1] = i;
//       }   
//      
//     }
//     
//   }
//   // попробуем нарисовать...
//   if (symbol==Symbol()&&timeframe==Period())
//    {
//     name = prefix+"Resistance_Line";
//     ObjectDelete(name);
//     ObjectCreate(name,OBJ_TREND,0,Resistance_Line_dt[1],Resistance_Line_Price[1],Resistance_Line_dt[0],Resistance_Line_Price[0]);
// //    Print(Resistance_Line_dt[0]," ",Resistance_Line_Price[0]," ",Resistance_Line_dt[1]," ",Resistance_Line_Price[1]);
//     ObjectSet(name,OBJPROP_COLOR,Blue);
//     ObjectSet(name,OBJPROP_WIDTH,1);
//     ObjectSet(name,OBJPROP_RAY,True);
//     name = prefix+"Support_Line";
//     ObjectDelete(name);
//     ObjectCreate(name,OBJ_TREND,0,Support_Line_dt[1],Support_Line_Price[1],Support_Line_dt[0],Support_Line_Price[0]);
// //    Print(Resistance_Line_dt[0]," ",Resistance_Line_Price[0]," ",Resistance_Line_dt[1]," ",Resistance_Line_Price[1]);
//     ObjectSet(name,OBJPROP_COLOR,Red);
//     ObjectSet(name,OBJPROP_WIDTH,1);
//     ObjectSet(name,OBJPROP_RAY,True);
//    }
//  
//  
//  return (result); 
// }
//
//int ChaosExpert(int SymbolIdx, int timeframeIdx)
// {
//  string symbol = SymbolsArray[SymbolIdx];
//  int timeframe = PeriodNumber[timeframeIdx];
//  string name;
//  int WTD = 0;
//  double sBuy =iHigh(symbol, timeframe,1) +MarketInfo(symbol,MODE_SPREAD)*MarketInfo(symbol,MODE_POINT);
//  if ((iClose(symbol, timeframe,1) > (iHigh(symbol, timeframe,1)+iLow(symbol, timeframe,1))/2)
////    &&(sBuy < alligator_GATORLIPS)
////    &&(sBuy < alligator_GATORTEETH)
////    &&(sBuy < alligator_GATORJAW)
////    &&(sBuy < iHigh(symbol, timeframe,2)+MarketInfo(symbol,MODE_SPREAD)*MarketInfo(symbol,MODE_POINT))
////       &&(iLow(symbol, timeframe,1) < alligator_GATORLIPS) &&(iHigh(symbol, timeframe,1) > alligator_GATORLIPS)
////       &&(iLow(symbol, timeframe,1) < alligator_GATORTEETH) &&(iHigh(symbol, timeframe,1) > alligator_GATORTEETH)
////       &&(iLow(symbol, timeframe,1) < alligator_GATORJAW) &&(iHigh(symbol, timeframe,1) > alligator_GATORJAW)
//    &&(MathAbs(iHigh(symbol, timeframe,1) -alligator_GATORJAW) > 2*MathAbs( iHigh(symbol, timeframe,2) - alligator_GATORJAW))
//    ) 
//   { 
//    SymbolBuy[SymbolIdx] =  iHigh(symbol, timeframe,1) +MarketInfo(symbol,MODE_SPREAD)*MarketInfo(symbol,MODE_POINT);
//    SymbolSL[SymbolIdx] =  (iHigh(symbol, timeframe,1) - iLow(symbol, timeframe,1))/MarketInfo(symbol,MODE_POINT)+MarketInfo(symbol,MODE_SPREAD)+1;
//        //Comment("MODE_SWAPSHORT=",MarketInfo(symbol,MODE_SWAPSHORT)," MODE_SWAPLONG=",MarketInfo(symbol,MODE_SWAPLONG)," MODE_SWAPTYPE=",MarketInfo(symbol,MODE_SWAPTYPE));
//        if (symbol==Symbol()&&timeframe==Period())
//         {
//          name = "alligator_GATORJAW_Line";
//          ObjectDelete(name);
//          ObjectCreate(name,OBJ_TREND,0,iTime(symbol, timeframe,2),alligator_GATORJAWP,iTime(symbol, timeframe,1),alligator_GATORJAW);
//          ObjectSet(name,OBJPROP_COLOR,Yellow);
//          ObjectSet(name,OBJPROP_WIDTH,1);
//          ObjectSet(name,OBJPROP_RAY,True);
//          name = "Price_Line";
//          ObjectDelete(name);
//          ObjectCreate(name,OBJ_TREND,0,iTime(symbol, timeframe,2),iHigh(symbol, timeframe,2),iTime(symbol, timeframe,1),iHigh(symbol, timeframe,1));
//          ObjectSet(name,OBJPROP_COLOR,Gold);
//          ObjectSet(name,OBJPROP_WIDTH,1);
//          ObjectSet(name,OBJPROP_RAY,True);
//         }
//        
//        GCSLcomment =" "+timeframe; GC_Magic_Number = timeframe;
//        //OrderBuy(SymbolsArray[SymbolIdx]);//, iHigh(symbol, timeframe,0));
//    }
//      if ((iClose(symbol, timeframe,1) < (iHigh(symbol, timeframe,1)+iLow(symbol, timeframe,1))/2)
//       &&(iLow(symbol, timeframe,1) < alligator_GATORLIPS) &&(iHigh(symbol, timeframe,1) > alligator_GATORLIPS)
//       &&(iLow(symbol, timeframe,1) < alligator_GATORTEETH) &&(iHigh(symbol, timeframe,1) > alligator_GATORTEETH)
//       &&(iLow(symbol, timeframe,1) < alligator_GATORJAW) &&(iHigh(symbol, timeframe,1) > alligator_GATORJAW)
//       &&(MathAbs(iHigh(symbol, timeframe,1) -alligator_GATORTEETH) > MathAbs( iHigh(symbol, timeframe,2) - alligator_GATORTEETHP))
//       )
//       {
//        GCSLcomment =" "+timeframe; GC_Magic_Number = timeframe;
//        SymbolSel[SymbolIdx] = iLow(symbol, timeframe,1) - MarketInfo(symbol,MODE_POINT);
////        OrderSell(SymbolsArray[SymbolIdx]);//, iHigh(symbol, timeframe,0));
//       }
//  return(WTD);
// }
//
//int CandlesExpert(int SymbolIdx, int timeframeIdx)
// {
//  string symbol = SymbolsArray[SymbolIdx];
//  int timeframe = PeriodNumber[timeframeIdx];
//  if ((iClose(symbol, timeframe,2) > iOpen(symbol, timeframe,2))
//   &&(iClose(symbol, timeframe,1) < iOpen(symbol, timeframe,1))
//   &&(iClose(symbol, timeframe,2) < iOpen(symbol, timeframe,1))
//   &&(iClose(symbol, timeframe,1) < iOpen(symbol, timeframe,2)))
//    {
//     GCSLcomment =" "+timeframe; GC_Magic_Number = timeframe;
//     SymbolSel[SymbolIdx] = iLow(symbol, timeframe,1) - MarketInfo(symbol,MODE_POINT);
//    }
//  if ((iClose(symbol, timeframe,2) < iOpen(symbol, timeframe,2))
//   &&(iClose(symbol, timeframe,1) > iOpen(symbol, timeframe,1))
//   &&(iClose(symbol, timeframe,2) > iOpen(symbol, timeframe,1))
//   &&(iClose(symbol, timeframe,1) > iOpen(symbol, timeframe,2)))
//    {
//     SymbolBuy[SymbolIdx] =  iHigh(symbol, timeframe,1) +MarketInfo(symbol,MODE_SPREAD)*MarketInfo(symbol,MODE_POINT);
////        OrderSell(SymbolsArray[SymbolIdx]);//, iHigh(symbol, timeframe,0));
//    }
//
//  return(0); 
// }
//
bool OrderBuy(string pfx,string Smbl, datetime tf, double price =0, double SP = 0,int lots=1)
 {
   BuyOrders++;
   MqlDateTime tm;
   TimeToStruct(tf,tm);

   string name=prefix+"Buy_"+pfx+"_"+tm.day+"_"+tm.hour+"_"+tm.min;
  // Print("Попробуем создать объект Chart  с именем ",chart_name);
//--- если такого объекта нет - создадим его
   if(ObjectFind(0,name)<0)
    {
      ObjectCreate(0,name,OBJ_ARROW_BUY,0,tf,price,0,0);
   //--- сделаем недоступным для выделения мышкой 
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
    } 
    if (tf == TimeCurrent())
     {
    if(!SymbolInfoTick(Smbl,tick))
     {
      Print("Failed to get Symbol info!");
      return false;
     }
     trReq.price=tick.ask;                   // SymbolInfoDouble(NULL,SYMBOL_ASK);
      trReq.sl=tick.ask-_Point*sl;            // Stop Loss level of the order
      trReq.tp=tick.ask+_Point*tp;            // Take Profit level of the order
      trReq.type=ORDER_TYPE_BUY;              // Order type
      OrderSend(trReq,trRez);
    } 
 return true;
}

bool OrderSell(string pfx,string Smbl, datetime tf, double price =0, double SP = 0,int lots=1)
 {
   SellOrders++;
   MqlDateTime tm;
   TimeToStruct(tf,tm);

   string name=prefix+"Sell_"+pfx+"_"+tm.day+"_"+tm.hour+"_"+tm.min;
  // Print("Попробуем создать объект Chart  с именем ",chart_name);
//--- если такого объекта нет - создадим его
   if(ObjectFind(0,name)<0)
    {
      ObjectCreate(0,name,OBJ_ARROW_SELL,0,tf,price,0,0);
   //--- сделаем недоступным для выделения мышкой 
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
    } 
    if (tf == TimeCurrent())
     {
    if(!SymbolInfoTick(Smbl,tick))
     {
      Print("Failed to get Symbol info!");
      return false;
     }
         trReq.price=tick.bid;
         trReq.sl=tick.bid+_Point*sl;            // Stop Loss level of the order
         trReq.tp=tick.bid-_Point*tp;            // Take Profit level of the order
         trReq.type=ORDER_TYPE_SELL;             // Order type
         OrderSend(trReq,trRez);
        }
 return true;
}