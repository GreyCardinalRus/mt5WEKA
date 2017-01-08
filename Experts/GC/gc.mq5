//+------------------------------------------------------------------+
//|                                         Grey_Cardinal_Expert.mq4 |
//|                    Copyright © 2007, GreyCardinal Software Corp. |
//|                                        http://www.opencis.net.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, GreyCardinal Software Corp."
//#property stacksize 1024
#property link      "http://www.opencis.net.ru"
//#property indicator_chart_window
#property indicator_level1 1.4055

extern bool OnlyCurrVals = True; 

extern bool IsWoodyExpert = False; 
extern bool IsWilliamsExpert = False; 
extern bool IsAlligatorExpert = False; 
extern bool IsFiguresExpert = False; 
extern bool IsChaosExpert = False; 
extern bool isFractalExpert = False; 
extern bool IsCandlesExpert = False; 

extern color _Header = OrangeRed;
extern color _Text = RoyalBlue;
extern color _TextCurr = Yellow;
extern color _Data = CadetBlue;
extern color _DataPlus = Lime;
extern color _DataMinus = Red;
extern color _Separator = MediumPurple;
extern int FontSize = 8;
extern string FontName = "Tahoma";
extern int TopPos = 20;
extern int Corner = 0;
extern int MaxSpread = 20;
//extern int dy = 20;
extern int MaxPeriod=9; // 0 -auto
extern int LR.length=10;   // bars back regression begins
extern int time_frame=60;
extern double TrailingStop=150;
extern int Slippage = 0;
extern string _Symbol = "Пара";//"Symbol";
extern string _ValueName = "Результат";//"Value";
extern string _TotalName = "Всего";//"Total";
extern string _BreakevenName = "Breakeven";

//Woody------- Внешние параметры ------------------------------------------
extern int  SlowCCIPeriod = 14;   // Период медленного CCI
extern int  FastCCIPeriod = 6;    // Период быстрого CCI
extern int  NSignalBar    = 6;    // Номер сигнального бара
extern int  Delta         = 3;    // Допуск в барах
extern bool ShowComment   = False; // Показывать комментарии

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

color  LR.c=Orange;

string prefix = "GC_";
int MaxSymbols = 0;
string SymbolsArray[100];//={"","USDCHF","GBPUSD","EURUSD","USDJPY","AUDUSD","USDCAD","EURGBP","EURAUD","EURCHF","EURJPY","GBPJPY","GBPCHF"};
string Currencies[] = {"AED", "AUD", "BHD", "BRL", "CAD", "CHF", "CNY", 
                       "CYP", "CZK", "DKK", "DZD", "EEK", "EGP", "EUR",
                       "GBP"
                       //, "HKD"
                       , "HRK", "HUF", "IDR", "ILS", "INR",
                       "IQD", "IRR", "ISK", "JOD", "JPY", "KRW", "KWD",
                       "LBP", "LTL", "LVL", "LYD", "MAD", "MXN", "MYR",
                       "NOK", "NZD", "OMR", "PHP", "PLN", "QAR", "RON",
                       "RUB", "SAR", "SEK"
                       //, "SGD"
                       , "SKK", "SYP", "THB",
                       "TND", "TRY", "TWD", "USD", "VEB", "XAG", "XAU",
                       "YER", "ZAR"}; 

int SymbolSelOrderTicket[100];
double SymbolSel[100];
double SymbolBuy[100];
int SymbolBuyOrderTicket[100];
int PeriodNumber[10]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string PeriodName[10]={"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int SymbolSL[100];

double TrendOnSymbol[100,10]; //  тренд по символу и таймфрейму
double WideOnSymbol[100,10]; //  ширина тренда по символу и таймфрейму
double ResultOnSymbol[10,10]; //  финрезультат по символу  - текущая открыто продаж, покупок прибыль
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
datetime Calked[100][10];
int init()
 {
  MaxSymbols =CreateSymbolList();
  Comment( "Валютных пар = ",MaxSymbols);
   for( int SymbolIdx = 0; SymbolIdx<MaxSymbols;SymbolIdx++)  
       for ( int iperiod = 0; iperiod<MaxPeriod;iperiod++)  // по периодам
     Calked[SymbolIdx][iperiod]=0;
  start();   
  return(0);
 }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   clear();
   return(0);
  }

void clear() 
  {
//---- Чистим график
   string name;
   int obj_total = ObjectsTotal();
   for(int i = obj_total - 1; i >= 0; i--)
     {
       name = ObjectName(i);
       if(StringFind(name, prefix) == 0) 
           ObjectDelete(name);
     }
  }

//+------------------------------------------------------------------+
//| СОЗДАЁТ СПИСОК ДОСТУПНЫХ ВАЛЮТНЫХ СИМВОЛОВ                       |
//+------------------------------------------------------------------+
int CreateSymbolList()
  {
   int SymbolCount;
   int CurrencyCount = ArrayRange(Currencies, 0);
   int Loop, SubLoop;
   string TempSymbol;
   if (OnlyCurrVals == False)
    { 
     SymbolsArray[SymbolCount] = Symbol(); SymbolCount++;
     for(Loop = 0; Loop < CurrencyCount; Loop++) for(SubLoop = 0; SubLoop < CurrencyCount; SubLoop++)
      {
       TempSymbol = Currencies[Loop] + Currencies[SubLoop];
       if((TempSymbol!=Symbol())&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1))&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
        {
         SymbolsArray[SymbolCount] = TempSymbol;
         SymbolCount++;
        }
      }
    }
   else
    {
     // прямые
     for(Loop = 0; Loop < CurrencyCount; Loop++) for(SubLoop = 0; SubLoop < CurrencyCount; SubLoop++)
      {
       if(StringFind(Symbol(),Currencies[Loop],0)==0)
        {
         TempSymbol = Currencies[Loop] + Currencies[SubLoop];
         if((TempSymbol!=Symbol())&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1))&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      }
     for(Loop = 0; Loop < CurrencyCount; Loop++) for(SubLoop = 0; SubLoop < CurrencyCount; SubLoop++)
      {
       if(StringFind(Symbol(),Currencies[SubLoop],0)==3)
        {
         TempSymbol = Currencies[Loop] + Currencies[SubLoop];
         if((TempSymbol!=Symbol())&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1))&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           //ArrayResize(SymbolsArray, SymbolCount + 1);
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      } 
     SymbolsArray[SymbolCount] = Symbol(); SymbolCount++;
     // противники
     for(Loop = 0; Loop < CurrencyCount; Loop++) for(SubLoop = 0; SubLoop < CurrencyCount; SubLoop++)
      {
       if(StringFind(Symbol(),Currencies[Loop],0)==3)
        {
         TempSymbol = Currencies[Loop] + Currencies[SubLoop];
         if((TempSymbol!=Symbol())&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1))&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      }
     for(Loop = 0; Loop < CurrencyCount; Loop++) for(SubLoop = 0; SubLoop < CurrencyCount; SubLoop++)
      {
       if(StringFind(Symbol(),Currencies[SubLoop],0)==0)
        {
         TempSymbol = Currencies[Loop] + Currencies[SubLoop];
         if((TempSymbol!=Symbol())&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1))&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
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
//+------------------------------------------------------------------+
int CalkTrend(int SymbolIndx,int in_period, int end.bar  = 1)
 {
   // расчет тренда - пока не очень -но всетаки... плюс рисует самый правый... думаю надо ширину сделать динамической - показывать и его длину
   int period = PeriodNumber[in_period];
//linear regression calculation
   int start.bar=LR.length+end.bar;
   int n=start.bar-end.bar+1;
//---- calculate price values
   double value=iClose(SymbolsArray[SymbolIndx],period,end.bar);
   double a,b,c;
   double sumy=value;
   double sumx=0.0;
   double sumxy=0.0;
   double sumx2=0.0;
   double min_val = 0, max_val=0;
   string name;
  double Resistance_Line_Price[2]={0,0}; // up
  datetime Resistance_Line_dt[2];
  double Support_Line_Price[2]={0,0};    // down
  double Resistance_Line_Angle = 0,Support_Line_Angle = 0;
  datetime Support_Line_dt[2];    // down
  double dh,dhc,dl,dlc;
  int Resistance_Line_shift[2];
  int Support_Line_shift[2];

   for(int i=1; i<n; i++)
     {
      value=iClose(SymbolsArray[SymbolIndx],period,end.bar+i);
      if (max_val< iHigh(SymbolsArray[SymbolIndx],period,end.bar+i)) max_val= iHigh(SymbolsArray[SymbolIndx],period,end.bar+i);
      if ((min_val==0)||(min_val> iLow(SymbolsArray[SymbolIndx],period,end.bar+i))) min_val= iLow(SymbolsArray[SymbolIndx],period,end.bar+i);
      sumy+=value;
      sumxy+=value*i;
      sumx+=i;
      sumx2+=i*i;
     }
   c=sumx2*n-sumx*sumx;
   if(c==0.0) return;
   b=(sumxy*n-sumx*sumy)/c;
   a=(sumy-sumx*b)/n;
   double LR.price.2=a;
   double LR.price.1=a+b*n;

//---- maximal deviation calculation (not used)
   double max.dev=0;
   double deviation=0;
   double dvalue=a;
   for(i=0; i<n; i++)
     {
      value=iClose(SymbolsArray[SymbolIndx],period,end.bar+i);
      dvalue+=b;
      deviation=MathAbs(value-dvalue);
      if(max.dev<=deviation) max.dev=deviation;
     }
   double x=0,x.sum=0,x.avg=0,x.sum.squared=0,std.dev=0;
      //Linear regression trendline
      ObjectCreate(prefix+period+SymbolsArray[SymbolIndx]+"m "+LR.length+" TL",OBJ_TREND,0,iTime(SymbolsArray[SymbolIndx],period,start.bar),LR.price.1,Time[end.bar],LR.price.2);
      ObjectSet(prefix+period+SymbolsArray[SymbolIndx]+"m "+LR.length+" TL",OBJPROP_WIDTH,1);
   if ((Symbol() == SymbolsArray[SymbolIndx]) && Period() == period )//&&(1==2))
      ObjectSet(prefix+period+SymbolsArray[SymbolIndx]+"m "+LR.length+" TL",OBJPROP_COLOR,LR.c);
   else  ObjectSet(prefix+period+SymbolsArray[SymbolIndx]+"m "+LR.length+" TL",OBJPROP_COLOR,Black);

   
   //     ObjectSet(period+"m "+LR.length+" TL",OBJPROP_WIDTH,1);
      ObjectSet(prefix+period+SymbolsArray[SymbolIndx]+"m "+LR.length+" TL",OBJPROP_RAY,False);     
   for(i=0; i<start.bar; i++)    
    {
     x=MathAbs(iClose(SymbolsArray[SymbolIndx],period,i)-ObjectGetValueByShift(prefix+period+SymbolsArray[SymbolIndx]+"m "+LR.length+" TL",i));
     
     x.sum+=x;
     if(i>0)  
      {
       x.avg=(x.avg+x)/i;
       x.sum.squared+=(x-x.avg)*(x-x.avg);
       std.dev=MathSqrt(x.sum.squared/(start.bar-1));  
      }  
    }

   double angle = (LR.price.1 - LR.price.2)/ (start.bar - end.bar);
   Resistance_Line_shift[1]=0;Resistance_Line_shift[0]=0;
   int pLast = start.bar, pFirst = end.bar;
   while (pLast>pFirst)
    {
     if(Resistance_Line_shift[1]==0)
      {
       Resistance_Line_Price[0]=iHigh(SymbolsArray[SymbolIndx],period,pLast);Resistance_Line_dt[0]=iTime(SymbolsArray[SymbolIndx],period,pLast);Resistance_Line_shift[0] = pLast;
       Support_Line_Price[0]=iLow(SymbolsArray[SymbolIndx],period,pLast);Support_Line_dt[0]=iTime(SymbolsArray[SymbolIndx],period,pLast);Support_Line_shift[0] = pLast;
       Resistance_Line_Price[1]=iHigh(SymbolsArray[SymbolIndx],period,pFirst);Resistance_Line_dt[1]=iTime(SymbolsArray[SymbolIndx],period,pFirst);Resistance_Line_shift[1] = pFirst;
       Support_Line_Price[1]=iLow(SymbolsArray[SymbolIndx],period,pFirst);Support_Line_dt[1]=iTime(SymbolsArray[SymbolIndx],period,pFirst);Support_Line_shift[1] = pFirst;
      }
     else 
      {
       angle = (Support_Line_Price[0]-Support_Line_Price[1])/(Support_Line_shift[0] - Support_Line_shift[1]);
     // ищем низ 
//       if (SymbolsArray[SymbolIndx]==Symbol()&&period==Period()) 
//        {
//         Print(Support_Line_Price[0]-angle/(Resistance_Line_shift[0] - pLast)," ",Resistance_Line_shift[0]," ",iLow(SymbolsArray[SymbolIndx],period,pLast)," ",pLast);
//        }
//       if (((Support_Line_Price[0]-angle/(Resistance_Line_shift[0] - pLast)) - iLow(SymbolsArray[SymbolIndx],period,pLast))>((LR.price.1-angle/(start.bar - pLast)) - Support_Line_Price[0]))
       if ((Support_Line_Price[0]-angle/(Resistance_Line_shift[0] - pLast))>iLow(SymbolsArray[SymbolIndx],period,pLast))
        {
         Support_Line_Price[0]=iLow(SymbolsArray[SymbolIndx],period,pLast);Support_Line_dt[0]=iTime(SymbolsArray[SymbolIndx],period,pLast);Support_Line_shift[0] = pLast;
        }
       angle = (Support_Line_Price[0]-Support_Line_Price[1])/(Support_Line_shift[0] - Support_Line_shift[1]);
       if ((Support_Line_Price[1]-angle/(Resistance_Line_shift[1] - pFirst))>iLow(SymbolsArray[SymbolIndx],period,pFirst))
        {
         Support_Line_Price[1]=iLow(SymbolsArray[SymbolIndx],period,pFirst);Support_Line_dt[1]=iTime(SymbolsArray[SymbolIndx],period,pFirst);Support_Line_shift[1] = pFirst;
        }
       angle = (Resistance_Line_Price[0]-Resistance_Line_Price[1])/(Resistance_Line_shift[0] - Resistance_Line_shift[1]);
       if (iHigh(SymbolsArray[SymbolIndx],period,pLast) >(Resistance_Line_Price[0]-angle/(Resistance_Line_shift[0] - pLast)))
        {
         Resistance_Line_Price[0]=iHigh(SymbolsArray[SymbolIndx],period,pLast);Resistance_Line_dt[0]=iTime(SymbolsArray[SymbolIndx],period,pLast);Resistance_Line_shift[0] = pLast;
        }
       if (iHigh(SymbolsArray[SymbolIndx],period,pFirst) >(Resistance_Line_Price[1]-angle/(Resistance_Line_shift[0] - pFirst)))
        {
         Resistance_Line_Price[1]=iHigh(SymbolsArray[SymbolIndx],period,pFirst);Resistance_Line_dt[1]=iTime(SymbolsArray[SymbolIndx],period,pFirst);Resistance_Line_shift[1] = pFirst;
        }
      }
     pLast--;pFirst++;
    }
    
   // попробуем нарисовать...
   if (SymbolsArray[SymbolIndx]==Symbol()&&period==Period())
    {
     name = prefix+"Resistance_Line";
     ObjectDelete(name);
     ObjectCreate(name,OBJ_TREND,0,Resistance_Line_dt[0],Resistance_Line_Price[0],Resistance_Line_dt[1],Resistance_Line_Price[1]);
//     Print("Resistance_Line ",Resistance_Line_dt[0]," ",Resistance_Line_Price[0]," ",Resistance_Line_dt[1]," ",Resistance_Line_Price[1]);
     ObjectSet(name,OBJPROP_COLOR,Blue);
     ObjectSet(name,OBJPROP_WIDTH,1);
     ObjectSet(name,OBJPROP_RAY,True);
     name = prefix+"Support_Line";
     ObjectDelete(name);
     ObjectCreate(name,OBJ_TREND,0,Support_Line_dt[0],Support_Line_Price[0],Support_Line_dt[1],Support_Line_Price[1]);
//     Print("Support_Line ",Support_Line_dt[0]," ",Support_Line_Price[0]," ",Support_Line_dt[1]," ",Support_Line_Price[1]);
     ObjectSet(name,OBJPROP_COLOR,Red);
     ObjectSet(name,OBJPROP_WIDTH,1);
     ObjectSet(name,OBJPROP_RAY,True);
    }

   if (end.bar  == 1)
    {
     TrendOnSymbol[SymbolIndx, in_period] = (LR.price.2 - LR.price.1)*10000;//period;
     WideOnSymbol[SymbolIndx, in_period] = (max_val - min_val)*10000;
   //WideOnSymbol[SymbolIndx, in_period] = (High[iHighest(SymbolsArray[SymbolIndx],1,MODE_HIGH,period*LR.length,0)] -Low[iLowest(SymbolsArray[SymbolIndx],1,MODE_LOW,period*LR.length,0)])*10000;
//   WideOnSymbol[SymbolIndx, in_period] = std.dev*std.channel.2*10000;
     if(StringFind(SymbolsArray[SymbolIndx], "JPY") != -1) 
      {
       TrendOnSymbol[SymbolIndx, in_period] = TrendOnSymbol[SymbolIndx, in_period] / 100;
       WideOnSymbol[SymbolIndx, in_period] = WideOnSymbol[SymbolIndx, in_period] /100;
      }
      return(0);
     }
     else  return((LR.price.2 - LR.price.1)*10000);
 }  
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
 //  clear();
   int SymbolIdx = 3;
   int wid=0;
   int ColPos,RowPos;
   string data;
//----
   string name = prefix + "symbols";

   if(ObjectFind(name) == -1)       ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name, OBJPROP_XDISTANCE, 20);
   ObjectSet(name, OBJPROP_YDISTANCE, TopPos);
   ObjectSetText(name, _Symbol, FontSize, FontName, _Header);
   ObjectSet(name, OBJPROP_CORNER, Corner);
   name = prefix + "equity";
   if(ObjectFind(name) == -1)  
    {
     ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
     ObjectSet(name, OBJPROP_XDISTANCE, 80);
     ObjectSet(name, OBJPROP_YDISTANCE, TopPos);
     ObjectSetText(name, _ValueName, FontSize, FontName, _Header);
     ObjectSet(name, OBJPROP_CORNER, Corner);
    }
   RowPos = TopPos;
   for( SymbolIdx = 0; SymbolIdx<MaxSymbols;SymbolIdx++)  
    {
     if (SymbolSL[SymbolIdx]==0 ) SymbolSL[SymbolIdx] = CalkSL(SymbolIdx);
     int spread = MarketInfo(SymbolsArray[SymbolIdx],MODE_SPREAD);
//     RowPos = RowPos+FontSize*1.5;
     RowPos = 20 + (SymbolIdx+1)*FontSize*1.5;
     name = prefix + SymbolsArray[SymbolIdx];
     ObjectDelete(name);
     if(ObjectFind(name) == -1)  
      {
       ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
       ObjectSet(name, OBJPROP_XDISTANCE, 20);
       ObjectSet(name, OBJPROP_YDISTANCE, RowPos);
       ObjectSetText(name,SymbolsArray[SymbolIdx]+"("+DoubleToStr(spread,0)+")", FontSize, FontName, _Text);
       ObjectSet(name, OBJPROP_CORNER, Corner);
       if (Symbol() == SymbolsArray[SymbolIdx]) ObjectSet(name,OBJPROP_COLOR,_TextCurr );
      }
     if (SymbolsArray[SymbolIdx]==Symbol())       
      {
       name = "Sale_Line";
       //if ((SymbolSel[SymbolIdx]==0)&&(ObjectFind(name)!=-1)) 
       ObjectDelete(name);
       if (SymbolSel[SymbolIdx]>0)
        {
         ObjectCreate(name,OBJ_TREND,0,iTime(SymbolsArray[SymbolIdx], Period(),1),SymbolSel[SymbolIdx],iTime(SymbolsArray[SymbolIdx], Period(),0),SymbolSel[SymbolIdx]);
           ObjectSet(name,OBJPROP_COLOR,Gold);
           ObjectSet(name,OBJPROP_WIDTH,1);
           ObjectSet(name,OBJPROP_RAY,True);
          }
         name = "buy_Line";
         ObjectDelete(name);
         if (SymbolBuy[SymbolIdx] > 0) 
          {
           ObjectCreate(name,OBJ_TREND,0,iTime(SymbolsArray[SymbolIdx], Period(),1),SymbolBuy[SymbolIdx],iTime(SymbolsArray[SymbolIdx], Period(),0),SymbolBuy[SymbolIdx]);
           ObjectSet(name,OBJPROP_COLOR,Magenta);
           ObjectSet(name,OBJPROP_WIDTH,1);
           ObjectSet(name,OBJPROP_RAY,True);
          }
        }
       //
       for ( int iperiod = 0; iperiod<MaxPeriod;iperiod++)  // по периодам
        {
         ColPos = 150+(iperiod*100);
         int timeframe = PeriodNumber[iperiod];
         name = prefix + "period_"+PeriodName[iperiod];
         if(ObjectFind(name) == -1)  
          {
           ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
           ObjectSet(name, OBJPROP_XDISTANCE, ColPos);
           ObjectSet(name, OBJPROP_YDISTANCE, TopPos);
           ObjectSetText(name,PeriodName[iperiod], FontSize, FontName, _Header);
           ObjectSet(name, OBJPROP_CORNER, Corner);
           if (Period() == PeriodNumber[iperiod]) ObjectSet(name,OBJPROP_COLOR,_TextCurr );
          }
         if (Calked[SymbolIdx][iperiod]!=iTime(SymbolSel[SymbolIdx],timeframe,0)) 
          {
           Calked[SymbolIdx][iperiod] = iTime(SymbolSel[SymbolIdx],timeframe,0);
           name = "Sale_Line";
           if ((SymbolSel[SymbolIdx]==0)&&(ObjectFind(name)!=-1)) ObjectDelete(name);
           if ((SymbolSel[SymbolIdx]>0)&&(ObjectFind(name)==-1))
            {
             ObjectCreate(name,OBJ_TREND,0,iTime(SymbolsArray[SymbolIdx], timeframe,1),SymbolSel[SymbolIdx],iTime(SymbolsArray[SymbolIdx], timeframe,0),SymbolSel[SymbolIdx]);
             ObjectSet(name,OBJPROP_COLOR,Gold);
             ObjectSet(name,OBJPROP_WIDTH,1);
             ObjectSet(name,OBJPROP_RAY,True);
            }
           name = "buy_Line";
           ObjectDelete(name);
           if (SymbolBuy[SymbolIdx] > 0) 
            {
             ObjectCreate(name,OBJ_TREND,0,iTime(SymbolsArray[SymbolIdx], timeframe,1),SymbolBuy[SymbolIdx],iTime(SymbolsArray[SymbolIdx], timeframe,0),SymbolBuy[SymbolIdx]);
             ObjectSet(name,OBJPROP_COLOR,Magenta);
             ObjectSet(name,OBJPROP_WIDTH,1);
             ObjectSet(name,OBJPROP_RAY,True);
            }
           alligator_GATORLIPS = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORLIPS , 1);// green
           alligator_GATORTEETH = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORTEETH , 1); // red
           alligator_GATORJAW = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORJAW , 1);// blue
           alligator_GATORLIPSP = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORLIPS , 2);// green
           alligator_GATORTEETHP = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORTEETH , 2); // red
           alligator_GATORJAWP = iAlligator( SymbolsArray[SymbolIdx], timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORJAW , 2);// blue
           CalkTrend(SymbolIdx,iperiod); 
           name = prefix + "period_"+PeriodName[iperiod]+"_"+SymbolsArray[SymbolIdx];
           if(ObjectFind(name) == -1)  ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
           ObjectSet(name, OBJPROP_XDISTANCE, ColPos);
           ObjectSet(name, OBJPROP_YDISTANCE, RowPos);
           data = " "+DoubleToStr(TrendOnSymbol[SymbolIdx, iperiod],2)+"("+DoubleToStr(WideOnSymbol[SymbolIdx, iperiod]-spread,0)+")";
           if(MathAbs(TrendOnSymbol[SymbolIdx, iperiod]) < 5*MarketInfo(SymbolsArray[SymbolIdx],MODE_SPREAD)) ObjectSetText(name, "Flat"+"("+DoubleToStr(WideOnSymbol[SymbolIdx, iperiod],0)+")", FontSize, FontName, _Data);
           else if(TrendOnSymbol[SymbolIdx, iperiod] > 0) ObjectSetText(name, data, FontSize, FontName, _DataPlus);
           else if(TrendOnSymbol[SymbolIdx, iperiod] < 0) ObjectSetText(name, data, FontSize, FontName, _DataMinus);
           if (PeriodNumber[iperiod]==Period())  wid=WhatToDo(SymbolIdx, iperiod);
          }
        }
       if (!IsTesting()||SymbolsArray[SymbolIdx]==Symbol())  // по валютам
        {
         if (MathAbs(SymbolBuy[SymbolIdx] - MarketInfo(SymbolsArray[SymbolIdx],MODE_ASK))<MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT)) {OrderBuy(SymbolIdx, 1); SymbolBuy[SymbolIdx] =0;}
         if (MathAbs(SymbolSel[SymbolIdx] - MarketInfo(SymbolsArray[SymbolIdx],MODE_BID))<MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT)) {OrderSell(SymbolIdx, 1);SymbolSel[SymbolIdx] = 0; }
         int cnt = OrdersTotal();
         double result = 0;
         double newStopLost;
         bool havesell= false, havebuy = false;
         for(int i = 0; i < cnt; i++) //---- обрабатываем открытые ордера - двигаем на размер стоплоса насколько можно
          {
           if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))    continue; //---- только "активные"
           if(SymbolsArray[SymbolIdx]!= OrderSymbol()) continue; //---- только "активные"
           if((OrderType() == OP_BUY || OrderType() == OP_SELL)) // посчитаем текущие результаты
              result += OrderProfit();// - OrderCommission() - OrderSwap();
           if(iVolume(SymbolsArray[SymbolIdx], time_frame,0)!=1) continue;
           if(OrderType()==OP_BUY)  
            {
            //newStopLost = iLow(SymbolsArray[SymbolIdx], timeframe,1) - 2*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);
             havebuy = true;
             newStopLost = alligator_GATORTEETH+MarketInfo(SymbolsArray[SymbolIdx],MODE_SPREAD)*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);//MarketInfo(SymbolsArray[SymbolIdx],MODE_BID)- SymbolSL[SymbolIdx]*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);
             slu= newStopLost - OrderStopLoss();
             if(slu>(MarketInfo(SymbolsArray[SymbolIdx],MODE_TICKSIZE)*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT)))
             if (IsDemo() || IsTesting()) OrderModify(OrderTicket(), 0, newStopLost, 0, 0, Gray);
           if ((TimeHour(iTime(SymbolsArray[SymbolIdx], 60,1))-TimeHour(OrderOpenTime()))<3) 
            {
             if ((iAO(SymbolsArray[SymbolIdx], time_frame,1)> iAO(SymbolsArray[SymbolIdx], 60,2)) // green
                &&(iVolume(SymbolsArray[SymbolIdx], time_frame,0)==1)) 
              {
               Print("Add ",3-(TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime())));
               OrderBuy(SymbolIdx, iperiod);
              } 
            }
          }
         if(OrderType()==OP_SELL)
          {
           if(SymbolSelOrderTicket[SymbolIdx]==0) SymbolSelOrderTicket[SymbolIdx]=OrderTicket();
           havesell= true;
           if(SymbolSelOrderTicket[SymbolIdx]== OrderTicket())
            {             
             if ((TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime()))<3) 
              {
               if (iAO(SymbolsArray[SymbolIdx], time_frame,1)< iAO(SymbolsArray[SymbolIdx], time_frame,2)) // red
                {
                 Print("Add Sell lots= ",3-(TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime())));
                 OrderSell(SymbolIdx, 0,0,0,3-(TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime())));
                } 
              }
             if ((TimeHour(iTime(SymbolsArray[SymbolIdx], time_frame,1))-TimeHour(OrderOpenTime()))>2) 
               newStopLost = iHigh(SymbolsArray[SymbolIdx], time_frame,1) + 2*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT);
             else  newStopLost = 0;
            }             
           if (newStopLost>0)
            {
             slu= OrderStopLoss() - newStopLost;
             if(slu>(MarketInfo(SymbolsArray[SymbolIdx],MODE_TICKSIZE)*MarketInfo(SymbolsArray[SymbolIdx],MODE_POINT)))
               if (IsDemo() || IsTesting()) OrderModify(OrderTicket(), 0, newStopLost, 0, 0, Gray);
            }
          }
        }
       name = prefix + "equity"+SymbolsArray[SymbolIdx];
       if(ObjectFind(name) == -1)  
        {
         ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name, OBJPROP_XDISTANCE, 80);
         ObjectSet(name, OBJPROP_YDISTANCE, RowPos);
        }  
       string eq = DoubleToStr(result, 2);
       if(result > 0) eq = "+" + eq;
       eq = "$" + eq;
       if(result > 0) ObjectSetText(name, eq, FontSize, FontName, _DataPlus);
       if(result < 0) ObjectSetText(name, eq,  FontSize, FontName, _DataMinus);
       if(result == 0) ObjectSetText(name, "-------------",  FontSize, FontName, _Data);
       ObjectSet(name, OBJPROP_CORNER, Corner);
       if(havesell == false) SymbolSelOrderTicket[SymbolIdx]= 0;
       if(havebuy  == false) SymbolBuyOrderTicket[SymbolIdx]= 0;
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
  return(2*MarketInfo(SymbolsArray[SymbolIdx],MODE_STOPLEVEL)); // пока так
 }
//+------------------------------------------------------------------+
//| возвращает true в случае успешного открытия Buy                  |
//+------------------------------------------------------------------+
//bool OrderBuy(string symbol, double price =0, double SP = 0)
bool OrderBuy(int SymbolIdx, int timeframeIdx, double price =0, double SP = 0,int lots=1)
 {
  string symbol = SymbolsArray[SymbolIdx];
  int timeframe = PeriodNumber[timeframeIdx];
   int cnt = OrdersTotal();
   for(int i = 0; i < cnt; i++) //---- обрабатываем открытые ордера
    {
     if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))    continue; //---- только "активные"
     if((OrderType() == OP_SELL )&& symbol== OrderSymbol())     OrderClose(OrderTicket(), OrderLots(),MarketInfo(symbol,MODE_BID),3,Gray)  ;
    }
   bool res=false;
   Print("OrderBuy");
   if (IsDemo() || IsTesting()) TrueBuySell = true;
   if (Symbol() == symbol)
    {
     string name = "tipa_buy";
     if(ObjectFind(name) != -1)  ObjectDelete(name);
     ObjectCreate(name, OBJ_ARROW, 0, Time[0], MarketInfo(symbol,MODE_ASK));
     ObjectSet(name,OBJPROP_ARROWCODE,71);
     if (TrueBuySell == true)  // реально заключаем сделки
      {
       double openPrice = MarketInfo(symbol,MODE_ASK);
       if (price >0) openPrice = price;
       double StopPrice = MarketInfo(symbol,MODE_BID)-15*MarketInfo(symbol,MODE_STOPLEVEL)*MarketInfo(symbol,MODE_POINT);
       double TakePrice = openPrice+10*MarketInfo(symbol,MODE_STOPLEVEL)*MarketInfo(symbol,MODE_POINT);
       double set_lots = MarketInfo(symbol,MODE_MINLOT)*lots;
       string GCSLcomment = " ";
       if (symbol==Symbol()) res=OrderSend(symbol,OP_BUY,set_lots,openPrice,SP,StopPrice,TakePrice,GCSLcomment,GC_Magic_Number,0,Blue);
      }
    }
   return (res);
  }
    
//+------------------------------------------------------------------+
//| возвращает true в случае успешного открытия Sel                  |
//+------------------------------------------------------------------+
//bool OrderSell(string symbol, double price =0, double SP = 0)
int OrderSell(int SymbolIdx, int timeframeIdx, double price =0, double SP = 0,int lots=1)
 {
  string symbol = SymbolsArray[SymbolIdx];
  int timeframe = PeriodNumber[timeframeIdx];
   int cnt = OrdersTotal();
   for(int i = 0; i < cnt; i++) //---- обрабатываем открытые ордера
    {
     if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))    continue; //---- только "активные"
//     if((OrderType() == OP_SELL)&& symbol== OrderSymbol())       return (false);
     if((OrderType() == OP_BUY )&& symbol== OrderSymbol())       OrderClose(OrderTicket(), OrderLots(),MarketInfo(symbol,MODE_ASK),3,Gray)  ;
    }
   int res=0;
   if (IsDemo() || IsTesting()) TrueBuySell = true;
   if (Symbol() == symbol)
    {
     string name = "tipa_sale";
     if(ObjectFind(name) != -1)  ObjectDelete(name);
     ObjectCreate(name, OBJ_ARROW, 0, Time[2], MarketInfo(symbol,MODE_ASK));
     ObjectSet(name,OBJPROP_ARROWCODE,72);
    }
   if (TrueBuySell == true)  // реально заключаем сделки
    {
     double openPrice = MarketInfo(symbol,MODE_BID);
     if (price >0) openPrice = price;  
     double StopPrice = MarketInfo(symbol,MODE_ASK)+15*MarketInfo(symbol,MODE_STOPLEVEL)*MarketInfo(symbol,MODE_POINT);
     double TakePrice = 0;//openPrice-3*MarketInfo(symbol,MODE_STOPLEVEL)*MarketInfo(symbol,MODE_POINT);
     double set_lots = MarketInfo(symbol,MODE_MINLOT)*lots;
     if (price ==0)   res=OrderSend(symbol,OP_SELL,set_lots,openPrice,SP,StopPrice,TakePrice,GCSLcomment,GC_Magic_Number,0,Red);
     else        res=OrderSend(symbol,OP_SELLLIMIT,set_lots,openPrice,SP,StopPrice,TakePrice,GCSLcomment,GC_Magic_Number,0,Red);
     if(SymbolSelOrderTicket[SymbolIdx]== 0) SymbolSelOrderTicket[SymbolIdx]=res;
    }
   return (res);
  }
    

//+------------------------------------------------------------------+
//| возвращает что делать - 0=ничего, 1 -продать, 2 -купить          |
//+------------------------------------------------------------------+


int WhatToDo(int SymbolIdx, int timeframeIdx)
 {
   string symbol = SymbolsArray[SymbolIdx];
   int timeframe = PeriodNumber[timeframeIdx];
   
//   double  alligator_GATORLIPS = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORLIPS , 0);// green
//   double  alligator_GATORTEETH = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORTEETH , 0); // red
//   double  alligator_GATORJAW = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORJAW , 0);// blue
   int WTD = 0,wdy =0,ae=0;
   double alligator;
   if (isFractalExpert == True)
    {
     int isFract = HaveFractal(SymbolIdx, timeframe);
     if (isFract == 2) // up
      {   /// red
       SymbolBuy[SymbolIdx] =  iHigh(symbol, timeframe,3) +MarketInfo(symbol,MODE_SPREAD)*MarketInfo(symbol,MODE_POINT);
      }   ///red
     if (isFract == 1) // down
      {
       SymbolSel[SymbolIdx] = iLow(symbol, timeframe,3) - MarketInfo(symbol,MODE_POINT);
      }
    }
   if( IsWoodyExpert == true) 
    {
     wdy = WoodyExpert(symbol, timeframe);
    }
   if (IsAlligatorExpert == True)
    {
     ae=AlligatorExpert(symbol, timeframe);
    }
  if (IsFiguresExpert == True )
   {
    //WTD = 
    FiguresExpert(symbol, timeframe);
   }
  if (IsCandlesExpert == True )
   {
    CandlesExpert(SymbolIdx, timeframeIdx);
   }

  WTD = ae;
//  if (WTD==1 )   OrderSell(symbol);
//if (WTD==2 )   OrderBuy(symbol);
  if (IsChaosExpert == True )    WTD = ChaosExpert(SymbolIdx, timeframeIdx);
  //if (WTD==1 )   OrderSell(symbol);
  //if (WTD==2 )   OrderBuy(symbol);
  return(WTD); // ничего
 }

int HaveFractal(int SymbolIdx, int timeframe)
  {
   string symbol = SymbolsArray[SymbolIdx];
   if((iHigh(symbol,timeframe,2)>iHigh(symbol,timeframe,1))
    &&(iHigh(symbol,timeframe,2)>iHigh(symbol,timeframe,3)))
     {
 //      Print("SymbolBuy[SymbolIdx]=",SymbolBuy[SymbolIdx]);
       SymbolBuy[SymbolIdx] =  iHigh(symbol, timeframe,2) +(MarketInfo(symbol,MODE_SPREAD)+1)*MarketInfo(symbol,MODE_POINT);
      }
//    return(2);
   if((iLow(symbol,timeframe,2)<iLow(symbol,timeframe,1))
    &&(iLow(symbol,timeframe,2)<iLow(symbol,timeframe,3)))
       SymbolSel[SymbolIdx] = iLow(symbol, timeframe,2) - MarketInfo(symbol,MODE_POINT);
//    return(1);

//   if(iFractals(symbol,timeframe,MODE_UPPER,3)>0) return(2);
//   if(iFractals(symbol,timeframe,MODE_LOWER,3)>0) return(1);
   return(0);
  
  }
  
int WoodyExpert(string symbol, int timeframe)
 {
  int result=0;
  bool fcu=False, fcd=False, fup=False, fdn=False;
  int shift, ss;
  string comm;
  for (shift=5; shift>=0; shift--) {
    TrendUp[shift] = 0;
    TrendDn[shift] = 0;
    FastCCI[shift] = iCCI(symbol, timeframe, FastCCIPeriod, PRICE_TYPICAL, shift);
    SlowCCI[shift] = iCCI(symbol, timeframe, SlowCCIPeriod, PRICE_TYPICAL, shift);
    HistCCI[shift] = SlowCCI[shift];
    if (HistCCI[shift+1]*HistCCI[shift]<0) {
      if (ss<=Delta) {
        if (fup && HistCCI[shift]>0) fcu = True;
        else fcu = False;
        if (fdn && HistCCI[shift]<0) fcd = True;
        else fcd = False;
      } else {
        if (ss<NSignalBar) {
          fup = False; fdn = False;
          fcu = False; fcd = False;
          comm = "No Trend";
        }
      }
      ss = 1;
    } else ss++;
    if (ss==NSignalBar) SignalBar[shift] = HistCCI[shift];
    else SignalBar[shift] = 0;
    if ((ss>NSignalBar || fcu) && HistCCI[shift]>0) {
      TrendUp[shift] = HistCCI[shift];
      fup = True; fdn = False; fcd = False;
      comm = "Up Trend "+(ss-NSignalBar);result = ss-NSignalBar;
    }
    if ((ss>NSignalBar || fcd) && HistCCI[shift]<0) {
      TrendDn[shift] = HistCCI[shift];
      fdn = True; fup = False; fcu = False;
      comm = "Down Trend "+(ss-NSignalBar);result = ss-NSignalBar;
    }
  }
  if (ShowComment) Comment(comm);
   Print(TrendUp[0]);
      if (result>1) result = 2;
     if (result<-1) result = 1;
    
     if ( result == 2) // buy
      {
//       if ((iHigh(symbol, timeframe, 0)> alligator_GATORLIPS)&&(alligator_GATORLIPS > alligator_GATORTEETH)&&(alligator_GATORTEETH > alligator_GATORJAW))
        {
        }
//       else 
        {
         result = 0;
        }
       }
      if ( result == 1) // buy
       {
//        if ((iLow(symbol, timeframe, 0)< alligator_GATORLIPS)&&(alligator_GATORLIPS < alligator_GATORTEETH)&&( alligator_GATORTEETH < alligator_GATORJAW))
        {
        }
//        else 
        {
         result = 0;
        }
      }
  
   return (result); 
 }
int AlligatorExpert(string symbol, int timeframe)
 {
  int WTD = 0;
  double up[4]={0,0,0,0}, down[4]={0,0,0,0};
  double  alligator_GATORLIPS = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORLIPS , 0);// green
  double  alligator_GATORTEETH = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORTEETH , 0); // red
  double  alligator_GATORJAW = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORJAW , 0);// blue
  int i;
  for (i = 0; i< 3;i++)
   {
    alligator_GATORLIPS = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORLIPS , i);// green
    alligator_GATORTEETH = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORTEETH , i); // red
    alligator_GATORJAW = iAlligator( symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, ma_method, PRICE_HIGH, MODE_GATORJAW , i);// blue
    if (up[0]>0)
     {
      if ((up[1]>alligator_GATORLIPS)&&(up[2]>alligator_GATORTEETH)&&(up[3]>alligator_GATORJAW)&&
         ((up[1]-alligator_GATORLIPS)>0)&&
          ((up[1]-alligator_GATORLIPS)>(up[2]-alligator_GATORTEETH))&&
          ((up[2]-alligator_GATORTEETH)>(up[3]-alligator_GATORJAW)))
       {
        up[0]=1;
       }
       else up[0]=-1;
      }
    if (down[0]>0)
      {
       if ((down[1]<alligator_GATORLIPS)&&(down[2]<alligator_GATORTEETH)&&(down[3]<alligator_GATORJAW)&&
          ((alligator_GATORLIPS-down[1])>(alligator_GATORTEETH-down[2]))&&((alligator_GATORTEETH -down[2])>(alligator_GATORJAW- down[3]))       
         )
        {
         down[0]=1;
        }
       else down[0]=-1;
      }
     up[1]=alligator_GATORLIPS;up[2]=alligator_GATORTEETH;up[3]=alligator_GATORJAW;
     down[1]=alligator_GATORLIPS;down[2]=alligator_GATORTEETH;down[3]=alligator_GATORJAW;
     if (up[0]==0) up[0]=1;
     if (down[0]==0) down[0]=1;
    }
//     if (wdy<-1) WTD = 1;
  for (i = 0; i< 10;i++)  if (timeframe== PeriodNumber[i]) break;
  int SymbolIdx = 0; for (SymbolIdx = 0; i< 10;i++)  if (symbol== SymbolsArray[i]) break;
  if (MathAbs(TrendOnSymbol[SymbolIdx, i+1]) < MarketInfo(symbol,MODE_SPREAD)) 
    { 
     if ((up[0]==1)) WTD = 2;
     if ((down[0]==1)) WTD = 1;
    }
 return(WTD);
}

int FiguresExpert(string symbol, int timeframe)
 {
  string name;
  int result=0;
  double Resistance_Line_Price[2]={0,0}; // up
  datetime Resistance_Line_dt[2];
  double Support_Line_Price[2]={0,0};    // down
  double Resistance_Line_Angle = 0,Support_Line_Angle = 0;
  datetime Support_Line_dt[2];    // down
  double dh,dhc,dl,dlc;
  int Resistance_Line_shift[2];
  int Support_Line_shift[2];
  for (int i = 0; i< 25; i++)
   {
    dh = iHigh(symbol, timeframe,i);dl = iLow(symbol, timeframe,i);
    if (Resistance_Line_Price[0]==0) {Resistance_Line_Price[0]=dh;Resistance_Line_dt[0]=iTime(symbol, timeframe,i); Resistance_Line_shift[0] = i;}
    if (Support_Line_Price[0]==0) {Support_Line_Price[0]=dl;Support_Line_dt[0]=iTime(symbol, timeframe,i); Support_Line_shift[0] = i;}
    if (i<2)
     {
      if (Resistance_Line_Price[0]<dh)
       {
        Resistance_Line_Price[0]=dh;Resistance_Line_dt[0]=iTime(symbol, timeframe,i); Resistance_Line_shift[0] = i;
       }  
      if (Support_Line_Price[0]>dl)
       {
        Support_Line_Price[0]=dl;Support_Line_dt[0]=iTime(symbol, timeframe,i); Support_Line_shift[0] = i;
       }  
     }
    else
     {
      if (Resistance_Line_Price[1]==0) 
       {
        if(i == (Resistance_Line_shift[0]+1)) i+=2;
        Resistance_Line_Price[1]=dh;Resistance_Line_dt[1]=iTime(symbol, timeframe,i); Resistance_Line_shift[1] = i;
       }
      Resistance_Line_Angle = (Resistance_Line_Price[1] - Resistance_Line_Price[0])/(Resistance_Line_shift[1] - Resistance_Line_shift[0])/MarketInfo(symbol,MODE_POINT);
      dhc = MathRound(Resistance_Line_Price[0]/MarketInfo(symbol,MODE_POINT)-Resistance_Line_Angle*(i-Resistance_Line_shift[0]));
      Print("(",Resistance_Line_Price[1]," - ",Resistance_Line_Price[0],") / (",Resistance_Line_shift[1]," - ",Resistance_Line_shift[0],")=",Resistance_Line_Angle," ",dhc," ",MathRound(dh/MarketInfo(symbol,MODE_POINT))," ",i);
      if (MathAbs(dhc-MathRound(dh/MarketInfo(symbol,MODE_POINT)))< 1)
       {
        Resistance_Line_Price[1]=dh;Resistance_Line_dt[1]=iTime(symbol, timeframe,i);Resistance_Line_shift[1] = i;
       }   
      
      if (Support_Line_Price[1]==0) 
       {
        if(i == (Support_Line_shift[0]+1)) i+=2;
        Support_Line_Price[1]=dl;Support_Line_dt[1]=iTime(symbol, timeframe,i); Support_Line_shift[1] = i;
       }
      Support_Line_Angle = (Support_Line_Price[1] - Support_Line_Price[0])/(Support_Line_shift[1] - Support_Line_shift[0])/MarketInfo(symbol,MODE_POINT);
      dlc = MathRound(Support_Line_Price[0]/MarketInfo(symbol,MODE_POINT)-Support_Line_Angle*(i-Support_Line_shift[0]));
      Print("(",Resistance_Line_Price[1]," - ",Resistance_Line_Price[0],") / (",Resistance_Line_shift[1]," - ",Resistance_Line_shift[0],")=",Resistance_Line_Angle," ",dhc," ",MathRound(dh/MarketInfo(symbol,MODE_POINT))," ",i);
      if (MathAbs(dlc-MathRound(dl/MarketInfo(symbol,MODE_POINT)))< 1)
       {
        Support_Line_Price[1]=dl;Support_Line_dt[1]=iTime(symbol, timeframe,i);Support_Line_shift[1] = i;
       }   
      
     }
     
   }
   // попробуем нарисовать...
   if (symbol==Symbol()&&timeframe==Period())
    {
     name = prefix+"Resistance_Line";
     ObjectDelete(name);
     ObjectCreate(name,OBJ_TREND,0,Resistance_Line_dt[1],Resistance_Line_Price[1],Resistance_Line_dt[0],Resistance_Line_Price[0]);
 //    Print(Resistance_Line_dt[0]," ",Resistance_Line_Price[0]," ",Resistance_Line_dt[1]," ",Resistance_Line_Price[1]);
     ObjectSet(name,OBJPROP_COLOR,Blue);
     ObjectSet(name,OBJPROP_WIDTH,1);
     ObjectSet(name,OBJPROP_RAY,True);
     name = prefix+"Support_Line";
     ObjectDelete(name);
     ObjectCreate(name,OBJ_TREND,0,Support_Line_dt[1],Support_Line_Price[1],Support_Line_dt[0],Support_Line_Price[0]);
 //    Print(Resistance_Line_dt[0]," ",Resistance_Line_Price[0]," ",Resistance_Line_dt[1]," ",Resistance_Line_Price[1]);
     ObjectSet(name,OBJPROP_COLOR,Red);
     ObjectSet(name,OBJPROP_WIDTH,1);
     ObjectSet(name,OBJPROP_RAY,True);
    }
  
  
  return (result); 
 }

int ChaosExpert(int SymbolIdx, int timeframeIdx)
 {
  string symbol = SymbolsArray[SymbolIdx];
  int timeframe = PeriodNumber[timeframeIdx];
  string name;
  int WTD = 0;
  double sBuy =iHigh(symbol, timeframe,1) +MarketInfo(symbol,MODE_SPREAD)*MarketInfo(symbol,MODE_POINT);
  if ((iClose(symbol, timeframe,1) > (iHigh(symbol, timeframe,1)+iLow(symbol, timeframe,1))/2)
//    &&(sBuy < alligator_GATORLIPS)
//    &&(sBuy < alligator_GATORTEETH)
//    &&(sBuy < alligator_GATORJAW)
//    &&(sBuy < iHigh(symbol, timeframe,2)+MarketInfo(symbol,MODE_SPREAD)*MarketInfo(symbol,MODE_POINT))
//       &&(iLow(symbol, timeframe,1) < alligator_GATORLIPS) &&(iHigh(symbol, timeframe,1) > alligator_GATORLIPS)
//       &&(iLow(symbol, timeframe,1) < alligator_GATORTEETH) &&(iHigh(symbol, timeframe,1) > alligator_GATORTEETH)
//       &&(iLow(symbol, timeframe,1) < alligator_GATORJAW) &&(iHigh(symbol, timeframe,1) > alligator_GATORJAW)
    &&(MathAbs(iHigh(symbol, timeframe,1) -alligator_GATORJAW) > 2*MathAbs( iHigh(symbol, timeframe,2) - alligator_GATORJAW))
    ) 
   { 
    SymbolBuy[SymbolIdx] =  iHigh(symbol, timeframe,1) +MarketInfo(symbol,MODE_SPREAD)*MarketInfo(symbol,MODE_POINT);
    SymbolSL[SymbolIdx] =  (iHigh(symbol, timeframe,1) - iLow(symbol, timeframe,1))/MarketInfo(symbol,MODE_POINT)+MarketInfo(symbol,MODE_SPREAD)+1;
        //Comment("MODE_SWAPSHORT=",MarketInfo(symbol,MODE_SWAPSHORT)," MODE_SWAPLONG=",MarketInfo(symbol,MODE_SWAPLONG)," MODE_SWAPTYPE=",MarketInfo(symbol,MODE_SWAPTYPE));
        if (symbol==Symbol()&&timeframe==Period())
         {
          name = "alligator_GATORJAW_Line";
          ObjectDelete(name);
          ObjectCreate(name,OBJ_TREND,0,iTime(symbol, timeframe,2),alligator_GATORJAWP,iTime(symbol, timeframe,1),alligator_GATORJAW);
          ObjectSet(name,OBJPROP_COLOR,Yellow);
          ObjectSet(name,OBJPROP_WIDTH,1);
          ObjectSet(name,OBJPROP_RAY,True);
          name = "Price_Line";
          ObjectDelete(name);
          ObjectCreate(name,OBJ_TREND,0,iTime(symbol, timeframe,2),iHigh(symbol, timeframe,2),iTime(symbol, timeframe,1),iHigh(symbol, timeframe,1));
          ObjectSet(name,OBJPROP_COLOR,Gold);
          ObjectSet(name,OBJPROP_WIDTH,1);
          ObjectSet(name,OBJPROP_RAY,True);
         }
        
        GCSLcomment =" "+timeframe; GC_Magic_Number = timeframe;
        //OrderBuy(SymbolsArray[SymbolIdx]);//, iHigh(symbol, timeframe,0));
    }
      if ((iClose(symbol, timeframe,1) < (iHigh(symbol, timeframe,1)+iLow(symbol, timeframe,1))/2)
       &&(iLow(symbol, timeframe,1) < alligator_GATORLIPS) &&(iHigh(symbol, timeframe,1) > alligator_GATORLIPS)
       &&(iLow(symbol, timeframe,1) < alligator_GATORTEETH) &&(iHigh(symbol, timeframe,1) > alligator_GATORTEETH)
       &&(iLow(symbol, timeframe,1) < alligator_GATORJAW) &&(iHigh(symbol, timeframe,1) > alligator_GATORJAW)
       &&(MathAbs(iHigh(symbol, timeframe,1) -alligator_GATORTEETH) > MathAbs( iHigh(symbol, timeframe,2) - alligator_GATORTEETHP))
       )
       {
        GCSLcomment =" "+timeframe; GC_Magic_Number = timeframe;
        SymbolSel[SymbolIdx] = iLow(symbol, timeframe,1) - MarketInfo(symbol,MODE_POINT);
//        OrderSell(SymbolsArray[SymbolIdx]);//, iHigh(symbol, timeframe,0));
       }
  return(WTD);
 }

int CandlesExpert(int SymbolIdx, int timeframeIdx)
 {
  string symbol = SymbolsArray[SymbolIdx];
  int timeframe = PeriodNumber[timeframeIdx];
  if ((iClose(symbol, timeframe,2) > iOpen(symbol, timeframe,2))
   &&(iClose(symbol, timeframe,1) < iOpen(symbol, timeframe,1))
   &&(iClose(symbol, timeframe,2) < iOpen(symbol, timeframe,1))
   &&(iClose(symbol, timeframe,1) < iOpen(symbol, timeframe,2)))
    {
     GCSLcomment =" "+timeframe; GC_Magic_Number = timeframe;
     SymbolSel[SymbolIdx] = iLow(symbol, timeframe,1) - MarketInfo(symbol,MODE_POINT);
    }
  if ((iClose(symbol, timeframe,2) < iOpen(symbol, timeframe,2))
   &&(iClose(symbol, timeframe,1) > iOpen(symbol, timeframe,1))
   &&(iClose(symbol, timeframe,2) > iOpen(symbol, timeframe,1))
   &&(iClose(symbol, timeframe,1) > iOpen(symbol, timeframe,2)))
    {
     SymbolBuy[SymbolIdx] =  iHigh(symbol, timeframe,1) +MarketInfo(symbol,MODE_SPREAD)*MarketInfo(symbol,MODE_POINT);
//        OrderSell(SymbolsArray[SymbolIdx]);//, iHigh(symbol, timeframe,0));
    }

  return(0); 
 }

