//+------------------------------------------------------------------+
//|                                           MultiCurrencyIndex.mq5 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "2010, olyakish"
#property version   "1.1"
#property indicator_separate_window

#property indicator_buffers 31
#property indicator_plots   8
//+------------------------------------------------------------------+
//| перечисление типов индикатора                                    |
//+------------------------------------------------------------------+
enum Indicator_Type
  {
   Use_RSI_on_indexes=1,               // RSI от индекса
   Use_MACD_on_indexes=2,              // MACD от индекса
   Use_Stochastic_Main_on_indexes=3     // Stochastic от индекса
  };
input Indicator_Type ind_type=Use_RSI_on_indexes;  // тип индикатора от индекса

input bool USD=true;
input bool EUR=true;
input bool GBP=true;
input bool JPY=true;
input bool CHF=true;
input bool CAD=true;
input bool AUD=true;
input bool NZD=true;
input string rem000="";       //   В зависимости от типа индикатора
input string rem0000="";      //   потребуются значения :
input int rsi_period=9;       // период RSI
input int MACD_fast=5;        // период MACD_fast
input int MACD_slow=34;       // период MACD_slow
input int Stoch_period_k=8;    // период Stochastic %K
input int Stoch_period_sma=5;  // период сглаживания для Stochastic %K
input int shiftbars=500;      // количество баров для расчета индикатора

input color Color_USD = Green;            // Цвет линии USD
input color Color_EUR = DarkBlue;         // Цвет линии EUR
input color Color_GBP = Red;              // Цвет линии GBP
input color Color_CHF = Chocolate;        // Цвет линии CHF
input color Color_JPY = Maroon;           // Цвет линии JPY
input color Color_AUD = DarkOrange;       // Цвет линии AUD
input color Color_CAD = Purple;           // Цвет линии CAD
input color Color_NZD = Teal;             // Цвет линии NZD


input int wid_main=2; //Толщина линий относительно текущего графика
input ENUM_LINE_STYLE style_slave=STYLE_DOT; //Стиль второстепенных линий относительно текущего графика
double EURUSD[],GBPUSD[],USDCHF[],USDJPY[],AUDUSD[],USDCAD[],NZDUSD[]; // котировки
double USDx[],EURx[],GBPx[],JPYx[],CHFx[],CADx[],AUDx[],NZDx[];        // индексы
double USDplot[],EURplot[],GBPplot[],JPYplot[],CHFplot[],CADplot[],AUDplot[],NZDplot[]; // итоговые линии по валютам
double USDStoch[],EURStoch[],GBPStoch[],JPYStoch[],CHFStoch[],CADStoch[],AUDStoch[],NZDStoch[]; // буферы промежуточных данных стохастика по типу close/close без сглаживания
                                                                                        // распределение индексов буферов
// 0-7 включительно - буферы для отрисовки итоговых линий
// 8-14 включительно - буферы  основных валютных пар содержащих в себе USD
// 15-22 включительно - буферы индексов валют
// 23-30 включительно - буферы промежуточных данных стохастика по типу close/close без сглаживания 

int i,ii;
int y_pos=0;          // переменная Y координата для информационных объектов

datetime arrTime[7];  // массив с последним известным временем нулевого бара (нужно для синхронизации)
int bars_tf[7];       // для проверки количества доступных баров на разных валютных парах
int countVal=0;       // количество задейстованных валют
int index=0;
datetime tmp_time[1]; // промежуточный массив для времени бара
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   if(ind_type==1 || ind_type==3)
     {
      IndicatorSetInteger(INDICATOR_DIGITS,1);                    // количество знаков после запятой если RSI или Stochastic
     }
   if(ind_type==2)
     {
      IndicatorSetInteger(INDICATOR_DIGITS,5);                    // количество знаков после запятой если MACD
     }
   string nameInd="MultiCurrencyIndex";
   if(ind_type==Use_RSI_on_indexes){nameInd+=" RSI("+IntegerToString(rsi_period)+")";}
   if(ind_type==Use_MACD_on_indexes){nameInd+=" MACD("+IntegerToString(MACD_fast)+","+IntegerToString(MACD_slow)+")";}
   if(ind_type==Use_Stochastic_Main_on_indexes){nameInd+=" Stochastic("+IntegerToString(Stoch_period_k)+","+IntegerToString(Stoch_period_sma)+")";}
   IndicatorSetString(INDICATOR_SHORTNAME,nameInd);
   if(USD)
     {
      countVal++;
      SetIndexBuffer(0,USDplot,INDICATOR_DATA);                   // массив для отрисовки
      PlotIndexSetString(0,PLOT_LABEL,"USDplot");                 // имя линии на индикаторе (при наведении мышки)
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,shiftbars);           // откуда начинаем отрисовку
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);            // стиль рисования (линия)
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,Color_USD);           // цвет линии отрисовки
      if(StringFind(Symbol(),"USD",0)!=-1)
        {PlotIndexSetInteger(0,PLOT_LINE_WIDTH,wid_main);}        // если USD присутствует в имени символа то рисуем линию соответствующей толщины 
      else
        {PlotIndexSetInteger(0,PLOT_LINE_STYLE,style_slave);}
      ArraySetAsSeries(USDplot,true);                             // индексация массива как таймсерия
      ArrayInitialize(USDplot,EMPTY_VALUE);                       // нулевые значения 
      f_draw("USD",Color_USD);                                    // отрисовка в окне индикатора информации 
     }
   SetIndexBuffer(15,USDx,INDICATOR_CALCULATIONS);                // массив для индекса доллара для расчетов (не отображается на индикаторе в виде линии) 
   ArraySetAsSeries(USDx,true);                                   // индексация массива как таймсерия
   ArrayInitialize(USDx,EMPTY_VALUE);                             // нулевые значения
   if(ind_type==Use_Stochastic_Main_on_indexes)
     {
      SetIndexBuffer(23,USDStoch,INDICATOR_CALCULATIONS);          // если назначение индикатора как Use_Stochastic_Main_on_indexes то нужен еще этот промежуточный массив
      ArraySetAsSeries(USDStoch,true);                             // индексация массива как таймсерия
      ArrayInitialize(USDStoch,EMPTY_VALUE);                       // нулевые значения
     }

   if(EUR)
     {
      countVal++;
      SetIndexBuffer(1,EURplot,INDICATOR_DATA);                   // массив для отрисовки
      PlotIndexSetString(1,PLOT_LABEL,"EURplot");                 // имя линии на индикаторе (при наведении мышки)
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,shiftbars);           // откуда начинаем отрисовку
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);            // стиль рисования (линия)
      PlotIndexSetInteger(1,PLOT_LINE_COLOR,Color_EUR);           // цвет линии отрисовки
      if(StringFind(Symbol(),"EUR",0)!=-1)
        {PlotIndexSetInteger(1,PLOT_LINE_WIDTH,wid_main);}        // если EUR присутствует в имени символа
      // то рисуем линию соответствующей толщины    
      else
        {PlotIndexSetInteger(1,PLOT_LINE_STYLE,style_slave);}     // если EUR НЕ присутствует в имени символа,
      // то рисуем линию соответсвующего стиля (на кроссах))
      ArraySetAsSeries(EURplot,true);                             // индексация массива как таймсерия
      ArrayInitialize(EURplot,EMPTY_VALUE);                       // нулевые значения
      SetIndexBuffer(8,EURUSD,INDICATOR_CALCULATIONS);            // данные Close валютной пары EURUSD
      ArraySetAsSeries(EURUSD,true);                              // индексация массива как таймсерия
      ArrayInitialize(EURUSD,EMPTY_VALUE);                        // нулевые значения
      SetIndexBuffer(16,EURx,INDICATOR_CALCULATIONS);             // массив для индекса Евры для расчетов
                                                                  // (не отображается на индикаторе в виде линии) 
      ArraySetAsSeries(EURx,true);
      ArrayInitialize(EURx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(24,EURStoch,INDICATOR_CALCULATIONS);       // если назначение индикатора как Use_Stochastic_Main_on_indexes,
                                                                  // то нужен еще этот промежуточный массив
         ArraySetAsSeries(EURStoch,true);                          // индексация массива как таймсерия
         ArrayInitialize(EURStoch,EMPTY_VALUE);                    // нулевые значения
        }
      f_draw("EUR",Color_EUR);                                    // отрисовка в окне индикатора информации
     }
   if(GBP)
     {
      countVal++;
      SetIndexBuffer(2,GBPplot,INDICATOR_DATA);
      PlotIndexSetString(2,PLOT_LABEL,"GBPplot");
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,Color_GBP);
      if(StringFind(Symbol(),"GBP",0)!=-1)
        {PlotIndexSetInteger(2,PLOT_LINE_WIDTH,wid_main);}
      else
        {PlotIndexSetInteger(2,PLOT_LINE_STYLE,style_slave);}
      ArraySetAsSeries(GBPplot,true);
      ArrayInitialize(GBPplot,EMPTY_VALUE);
      SetIndexBuffer(9,GBPUSD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(GBPUSD,true);
      ArrayInitialize(GBPUSD,EMPTY_VALUE);
      SetIndexBuffer(17,GBPx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(GBPx,true);
      ArrayInitialize(GBPx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(25,GBPStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(GBPStoch,true);
         ArrayInitialize(GBPStoch,EMPTY_VALUE);
        }
      f_draw("GBP",Color_GBP);
     }
   if(JPY)
     {
      countVal++;
      SetIndexBuffer(3,JPYplot,INDICATOR_DATA);
      PlotIndexSetString(3,PLOT_LABEL,"JPYplot");
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,Color_JPY);
      if(StringFind(Symbol(),"JPY",0)!=-1)
        {PlotIndexSetInteger(3,PLOT_LINE_WIDTH,wid_main);}
      else
        {PlotIndexSetInteger(3,PLOT_LINE_STYLE,style_slave);}
      ArraySetAsSeries(JPYplot,true);
      ArrayInitialize(JPYplot,EMPTY_VALUE);
      SetIndexBuffer(10,USDJPY,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(USDJPY,true);
      ArrayInitialize(USDJPY,EMPTY_VALUE);
      SetIndexBuffer(18,JPYx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(JPYx,true);
      ArrayInitialize(JPYx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(26,JPYStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(JPYStoch,true);
         ArrayInitialize(JPYStoch,EMPTY_VALUE);
        }
      f_draw("JPY",Color_JPY);
     }
   if(CHF)
     {
      countVal++;
      SetIndexBuffer(4,CHFplot,INDICATOR_DATA);
      PlotIndexSetString(4,PLOT_LABEL,"CHFplot");
      PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(4,PLOT_LINE_COLOR,Color_CHF);
      if(StringFind(Symbol(),"CHF",0)!=-1)
        {PlotIndexSetInteger(4,PLOT_LINE_WIDTH,wid_main);}
      else
        {PlotIndexSetInteger(4,PLOT_LINE_STYLE,style_slave);}
      ArraySetAsSeries(CHFplot,true);
      ArrayInitialize(CHFplot,EMPTY_VALUE);
      SetIndexBuffer(11,USDCHF,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(USDCHF,true);
      ArrayInitialize(USDCHF,EMPTY_VALUE);
      SetIndexBuffer(19,CHFx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(CHFx,true);
      ArrayInitialize(CHFx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(27,CHFStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(CHFStoch,true);
         ArrayInitialize(CHFStoch,EMPTY_VALUE);
        }
      f_draw("CHF",Color_CHF);
     }
   if(CAD)
     {
      countVal++;
      SetIndexBuffer(5,CADplot,INDICATOR_DATA);
      PlotIndexSetString(5,PLOT_LABEL,"CADplot");
      PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(5,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(5,PLOT_LINE_COLOR,Color_CAD);
      if(StringFind(Symbol(),"CAD",0)!=-1)
        {PlotIndexSetInteger(5,PLOT_LINE_WIDTH,wid_main);}
      else
        {PlotIndexSetInteger(5,PLOT_LINE_STYLE,style_slave);}
      ArraySetAsSeries(CADplot,true);
      ArrayInitialize(CADplot,EMPTY_VALUE);
      SetIndexBuffer(12,USDCAD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(USDCAD,true);
      ArrayInitialize(USDCAD,EMPTY_VALUE);
      SetIndexBuffer(20,CADx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(CADx,true);
      ArrayInitialize(CADx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(28,CADStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(CADStoch,true);
         ArrayInitialize(CADStoch,EMPTY_VALUE);
        }
      f_draw("CAD",Color_CAD);
     }
   if(AUD)
     {
      countVal++;
      SetIndexBuffer(6,AUDplot,INDICATOR_DATA);
      PlotIndexSetString(6,PLOT_LABEL,"AUDplot");
      PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(6,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(6,PLOT_LINE_COLOR,Color_AUD);
      if(StringFind(Symbol(),"AUD",0)!=-1)
        {PlotIndexSetInteger(6,PLOT_LINE_WIDTH,wid_main);}
      else
        {PlotIndexSetInteger(6,PLOT_LINE_STYLE,style_slave);}
      ArraySetAsSeries(AUDplot,true);
      ArrayInitialize(AUDplot,EMPTY_VALUE);
      SetIndexBuffer(13,AUDUSD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(AUDUSD,true);
      ArrayInitialize(AUDUSD,EMPTY_VALUE);
      SetIndexBuffer(21,AUDx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(AUDx,true);
      ArrayInitialize(AUDx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(29,AUDStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(AUDStoch,true);
         ArrayInitialize(AUDStoch,EMPTY_VALUE);
        }
      f_draw("AUD",Color_AUD);
     }
   if(NZD)
     {
      countVal++;
      SetIndexBuffer(7,NZDplot,INDICATOR_DATA);
      PlotIndexSetString(7,PLOT_LABEL,"NZDplot");
      PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,shiftbars);
      PlotIndexSetInteger(7,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(7,PLOT_LINE_COLOR,Color_NZD);
      if(StringFind(Symbol(),"NZD",0)!=-1)
        {PlotIndexSetInteger(7,PLOT_LINE_WIDTH,wid_main);}
      else
        {PlotIndexSetInteger(7,PLOT_LINE_STYLE,style_slave);}
      ArraySetAsSeries(NZDplot,true);
      ArrayInitialize(NZDplot,EMPTY_VALUE);
      SetIndexBuffer(14,NZDUSD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(NZDUSD,true);
      ArrayInitialize(NZDUSD,EMPTY_VALUE);
      SetIndexBuffer(22,NZDx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(NZDx,true);
      ArrayInitialize(NZDx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(30,NZDStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(NZDStoch,true);
         ArrayInitialize(NZDStoch,EMPTY_VALUE);
        }
      f_draw("NZD",Color_NZD);
     }
   ArrayResize(arrTime,countVal-1);
   ArrayResize(bars_tf,countVal-1);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int limit=shiftbars;

   if(prev_calculated>0)
     {limit=1;}
   else
     {limit=shiftbars;}
   int copied;

// инициализация графиков задействованных валютных пар
   init_tf();

   if(EUR){copied=CopyClose("EURUSD",PERIOD_CURRENT,0,shiftbars,EURUSD);if(copied==-1){f_comment("Ждите...EURUSD");return(0);}}
   if(GBP){copied=CopyClose("GBPUSD",PERIOD_CURRENT,0,shiftbars,GBPUSD);if(copied==-1){f_comment("Ждите...GBPUSD");return(0);}}
   if(CHF){copied=CopyClose("USDCHF",PERIOD_CURRENT,0,shiftbars,USDCHF);if(copied==-1){f_comment("Ждите...USDCHF");return(0);}}
   if(JPY){copied=CopyClose("USDJPY",PERIOD_CURRENT,0,shiftbars,USDJPY);if(copied==-1){f_comment("Ждите...USDJPY");return(0);}}
   if(AUD){copied=CopyClose("AUDUSD",PERIOD_CURRENT,0,shiftbars,AUDUSD);if(copied==-1){f_comment("Ждите...AUDUSD");return(0);}}
   if(CAD){copied=CopyClose("USDCAD",PERIOD_CURRENT,0,shiftbars,USDCAD);if(copied==-1){f_comment("Ждите...USDCAD");return(0);}}
   if(NZD){copied=CopyClose("NZDUSD",PERIOD_CURRENT,0,shiftbars,NZDUSD);if(copied==-1){f_comment("Ждите...NZDUSD");return(0);}}

   for(i=limit-1;i>=0;i--)
     {
      //расчет индекса USD
      USDx[i]=1.0;
      if(EUR){USDx[i]+=EURUSD[i];}
      if(GBP){USDx[i]+=GBPUSD[i];}
      if(CHF){USDx[i]+=1/USDCHF[i];}
      if(JPY){USDx[i]+=1/USDJPY[i];}
      if(CAD){USDx[i]+=1/USDCAD[i];}
      if(AUD){USDx[i]+=AUDUSD[i];}
      if(NZD){USDx[i]+=NZDUSD[i];}
      USDx[i]=1/USDx[i];
      //расчет остальных индексов валют
      if(EUR){EURx[i]=EURUSD[i]*USDx[i];}
      if(GBP){GBPx[i]=GBPUSD[i]*USDx[i];}
      if(CHF){CHFx[i]=USDx[i]/USDCHF[i];}
      if(JPY){JPYx[i]=USDx[i]/USDJPY[i];}
      if(CAD){CADx[i]=USDx[i]/USDCAD[i];}
      if(AUD){AUDx[i]=AUDUSD[i]*USDx[i];}
      if(NZD){NZDx[i]=NZDUSD[i]*USDx[i];}
     }
//начинаем расчитывать буферы для отрисовки в зависимости от выбранного назначения индикатора
   if(ind_type==Use_RSI_on_indexes)
     {
      if(limit>1){ii=limit-rsi_period-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         if(USD){USDplot[i]=f_RSI(USDx,rsi_period,i);}
         if(EUR){EURplot[i]=f_RSI(EURx,rsi_period,i);}
         if(GBP){GBPplot[i]=f_RSI(GBPx,rsi_period,i);}
         if(CHF){CHFplot[i]=f_RSI(CHFx,rsi_period,i);}
         if(JPY){JPYplot[i]=f_RSI(JPYx,rsi_period,i);}
         if(CAD){CADplot[i]=f_RSI(CADx,rsi_period,i);}
         if(AUD){AUDplot[i]=f_RSI(AUDx,rsi_period,i);}
         if(NZD){NZDplot[i]=f_RSI(NZDx,rsi_period,i);}
        }
     }
   if(ind_type==Use_MACD_on_indexes)
     {
      if(limit>1){ii=limit-MACD_slow-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         if(USD){USDplot[i]=f_MACD(USDx,MACD_fast,MACD_slow,i);}
         if(EUR){EURplot[i]=f_MACD(EURx,MACD_fast,MACD_slow,i);}
         if(GBP){GBPplot[i]=f_MACD(GBPx,MACD_fast,MACD_slow,i);}
         if(CHF){CHFplot[i]=f_MACD(CHFx,MACD_fast,MACD_slow,i);}
         if(JPY){JPYplot[i]=f_MACD(JPYx,MACD_fast,MACD_slow,i);}
         if(CAD){CADplot[i]=f_MACD(CADx,MACD_fast,MACD_slow,i);}
         if(AUD){AUDplot[i]=f_MACD(AUDx,MACD_fast,MACD_slow,i);}
         if(NZD){NZDplot[i]=f_MACD(NZDx,MACD_fast,MACD_slow,i);}
        }
     }
   if(ind_type==Use_Stochastic_Main_on_indexes)
     {
      if(limit>1){ii=limit-Stoch_period_k-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         if(USD){USDStoch[i]=f_Stoch(USDx,rsi_period,i);}
         if(EUR){EURStoch[i]=f_Stoch(EURx,Stoch_period_k,i);}
         if(GBP){GBPStoch[i]=f_Stoch(GBPx,Stoch_period_k,i);}
         if(CHF){CHFStoch[i]=f_Stoch(CHFx,Stoch_period_k,i);}
         if(JPY){JPYStoch[i]=f_Stoch(JPYx,Stoch_period_k,i);}
         if(CAD){CADStoch[i]=f_Stoch(CADx,Stoch_period_k,i);}
         if(AUD){AUDStoch[i]=f_Stoch(AUDx,Stoch_period_k,i);}
         if(NZD){NZDStoch[i]=f_Stoch(NZDx,Stoch_period_k,i);}
        }
      if(limit>1){ii=limit-Stoch_period_sma-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         if(USD){USDplot[i]=SimpleMA(i,Stoch_period_sma,USDStoch);}
         if(EUR){EURplot[i]=SimpleMA(i,Stoch_period_sma,EURStoch);}
         if(GBP){GBPplot[i]=SimpleMA(i,Stoch_period_sma,GBPStoch);}
         if(CHF){CHFplot[i]=SimpleMA(i,Stoch_period_sma,CHFStoch);}
         if(JPY){JPYplot[i]=SimpleMA(i,Stoch_period_sma,JPYStoch);}
         if(CAD){CADplot[i]=SimpleMA(i,Stoch_period_sma,CADStoch);}
         if(AUD){AUDplot[i]=SimpleMA(i,Stoch_period_sma,AUDStoch);}
         if(NZD){NZDplot[i]=SimpleMA(i,Stoch_period_sma,NZDStoch);}
        }

     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
///                        Вспомогательные функции
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
///                        Расчет RSI
//+------------------------------------------------------------------+
double f_RSI(double &buf_in[],int period,int shift)
  {
   double pos=0.00000000,neg=0.00000000;
   double diff=0.0;
   for(int j=shift;j<=shift+period;j++)
     {
      diff=buf_in[j]-buf_in[j+1];
      pos+=(diff>0?diff:0.0);
      neg+=(diff<0?-diff:0.0);
     }
   if(neg<0.000000001){return(100.0);}//Защита от деления на ноль
   pos/=period;
   neg/=period;
   return(100.0 -(100.0/(1.0+pos/neg)));
  }
//+------------------------------------------------------------------+
///                        Расчет MACD
//+------------------------------------------------------------------+   
double f_MACD(double &buf_in[],int period_fast,int period_slow,int shift)
  {
   return(SimpleMA(shift,period_fast,buf_in)-SimpleMA(shift,period_slow,buf_in));
  }
//+------------------------------------------------------------------+
///                        Расчет SMA
//+------------------------------------------------------------------+   
double SimpleMA(const int position,const int period,const double &price[])
  {
   double result=0.0;
   for(int i=0;i<period;i++) result+=price[position+i];
   result/=period;
   return(result);
  }
//+------------------------------------------------------------------+
///        Расчет Stochastic close/close без сглаживания
//+------------------------------------------------------------------+   
double f_Stoch(double &price[],int period_k,int shift)
  {
   double result=0.0;
   double max=price[ArrayMaximum(price,shift,period_k)];
   double min=price[ArrayMinimum(price,shift,period_k)];
   result=(price[shift]-min)/(max-min)*100.0;
   return(result);
  }
//+------------------------------------------------------------------+
///        Отрисовка объеков 
//+------------------------------------------------------------------+   
int f_draw(string name,color _color)
  {
   ObjectCreate(0,name,OBJ_LABEL,ChartWindowFind(),0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,0);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y_pos);
   ObjectSetString(0,name,OBJPROP_TEXT,name);
   ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
   y_pos+=15;
   return(0);
  }
//+------------------------------------------------------------------+
///        Комментарий в правом нижнем углу индикатора 
//+------------------------------------------------------------------+   
int f_comment(string  text)
  {
   string name="f_comment";
   color _color=Crimson;
   if(ObjectFind(0,name)>=0){ObjectSetString(0,name,OBJPROP_TEXT,text);}
   else
     {
      ObjectCreate(0,name,OBJ_LABEL,ChartWindowFind(),0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,0);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,0);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
     }
   return(0);
  }
//+------------------------------------------------------------------+
///        Инициализация задействованных ТФ валютных пар 
//+------------------------------------------------------------------+   
int init_tf()
  {
   int copy;
   ArrayInitialize(arrTime,0);
   ArrayInitialize(bars_tf,0);
   bool writeComment=true;
   for(int n=0;n<10;n++) // Цикл  для инициализации задействованных валютных пар одинакового ТФ
     {
      index=0;
      int exit=-1;
      if(writeComment){f_comment("Идет синхронизация ТФ");writeComment=false;}
      if(EUR)
        {
         bars_tf[index]=Bars("EURUSD",PERIOD_CURRENT);
         copy=CopyTime("EURUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(GBP)
        {
         bars_tf[index]=Bars("GBPUSD",PERIOD_CURRENT);
         copy=CopyTime("GBPUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(CHF)
        {
         bars_tf[index]=Bars("USDCHF",PERIOD_CURRENT);
         copy=CopyTime("USDCHF",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(JPY)
        {
         bars_tf[index]=Bars("USDJPY",PERIOD_CURRENT);
         copy=CopyTime("USDJPY",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(CAD)
        {
         bars_tf[index]=Bars("USDCAD",PERIOD_CURRENT);
         copy=CopyTime("USDCAD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(AUD)
        {
         bars_tf[index]=Bars("AUDUSD",PERIOD_CURRENT);
         copy=CopyTime("AUDUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(NZD)
        {
         bars_tf[index]=Bars("NZDUSD",PERIOD_CURRENT);
         copy=CopyTime("NZDUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
        }

      for(int h=1;h<=index;h++)
        {
         if(arrTime[0]==arrTime[h]&&  arrTime[0]!=0 && exit==-1){exit=1;}
         if(arrTime[0]!=arrTime[h] &&  arrTime[0]!=0 && exit==1){exit=0;}
         if(bars_tf[h]<shiftbars){exit=0;}
        }
      if(exit==1){f_comment("Таймфреймы синхронизированы");return(0);}
     }
   f_comment("Неуспешная синхронизация ТФ");
   return(0);
  }
//+------------------------------------------------------------------+
