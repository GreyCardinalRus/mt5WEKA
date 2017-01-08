
//+X================================================================X+
//|                                          MultiStochastic_Exp.mq5 |
//|                               Copyright © 2010, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+  
#property copyright "Copyright © 2010, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 5 
//---- использовано всего 5 графических построений
#property indicator_plots   5
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input int Kperiod = 5; //K-период (количество баров для расчетов)
input int Dperiod = 3; //D-период (период первичного сглаживания)
input int slowing = 3; //окончательное сглаживание
input ENUM_MA_METHOD ma_method = MODE_SMA; //тип сглаживания
input ENUM_STO_PRICE price_field = STO_LOWHIGH; //способ расчета стохастика
input string SymbolA = "EURJPY";
input string SymbolB = "EURJPY";
input string SymbolC = "USDJPY";
//+-----------------------------------+
//---- индикаторные буферы
double Fl_Buffer[], Dn_Buffer[], Up_Buffer[];
double UpEnd_Buffer[], DnEnd_Buffer[];
//---- целые переменные 
int MinBars, CrossA, CrossB, CrossC;
//+X================================================================X+
//| MultiStochastic indicator initialization function                | 
//+X================================================================X+   
void OnInit()
 {
//----+
  //---- получение хендлов используемых технических индикаторов
  CrossA = iStochastic(SymbolA, 0, Kperiod, Dperiod, slowing, ma_method, price_field);
  CrossB = iStochastic(SymbolB, 0, Kperiod, Dperiod, slowing, ma_method, price_field);
  CrossC = iStochastic(SymbolC, 0, Kperiod, Dperiod, slowing, ma_method, price_field);
  
  //---- превращение динамических массивов в индикаторные буферы
  SetIndexBuffer(0, Fl_Buffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(1, Dn_Buffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(2, Up_Buffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(3, DnEnd_Buffer, INDICATOR_CALCULATIONS);
  SetIndexBuffer(4, UpEnd_Buffer, INDICATOR_CALCULATIONS);
  //---- Инициализация констант
  MinBars = Kperiod + Dperiod + slowing;
  
  //---- индексация элементов в индикаторных буферах как в таймсериях
  ArraySetAsSeries(Fl_Buffer,    true);
  ArraySetAsSeries(Dn_Buffer,    true);
  ArraySetAsSeries(Up_Buffer,    true);
  ArraySetAsSeries(DnEnd_Buffer, true);
  ArraySetAsSeries(UpEnd_Buffer, true);
//----+ завершение инициализации
 }
//+X================================================================X+
//| Rates_Total() function                                           |
//+X================================================================X+
int Rates_Total(string SymbolA_, string SymbolB_, string SymbolC_, int BarMinimum)
 {
//----+
   int Bars0 = Bars(SymbolA_, 0);
   int Bars1 = Bars(SymbolB_, 0);
   int Bars2 = Bars(SymbolC_, 0);
   //----
   int error = GetLastError();
   ResetLastError();
   //----
   if (error == 4401)return(0);
   
   if (BarsCalculated(CrossA) <= BarMinimum
     || BarsCalculated(CrossB) <= BarMinimum
      || BarsCalculated(CrossC) <= BarMinimum)
    return(0);
//----+
   return(MathMin(Bars0, MathMin(Bars1, Bars2)));
 }
//+X================================================================X+
//|  SynchroCheck() function                                         |
//+X================================================================X+
bool SynchroCheck(string SymbolA_, string SymbolB_, string SymbolC_)
 {
//----+
   datetime Time_[1], Vel0, Vel1, Vel2;
   //----
   CopyTime(SymbolA_, 0, 0, 1, Time_); Vel0 = Time_[0];
   CopyTime(SymbolB_, 0, 0, 1, Time_); Vel1 = Time_[0];
   CopyTime(SymbolC_, 0, 0, 1, Time_); Vel2 = Time_[0];
   
   if (Vel0 != Vel1 || Vel1 != Vel2) return(false);
//----+
   return(true); 
 }
//+X================================================================X+
//| MultiStochastic iteration function                               |
//+X================================================================X+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]
               )
 {
//----+
  //---- Проверка количества баров на достаточность для расчёта
  int Bars_ = Rates_Total(SymbolA, SymbolB, SymbolC, MinBars * 5);
  if (Bars_ < MinBars)return(0);
  
  //---- Проверка синхронизации таймсерий
  if (!SynchroCheck(SymbolA, SymbolB, SymbolC))
    return(prev_calculated);
  
  //---- Объявление  массивов переменных с плавающей
                    // точкой для промежуточного хранения данных
  double TempArray1[], TempArray2[], TempArray3[];
  double TempArray4[], TempArray5[], TempArray6[];
  
  //---- Объявление локальных переменных
  int limit, limit_, bar;
  double Dif0, Dif1, Dif2;
  bool Up0, Up1, Up2, Dn0, Dn1, Dn2;
  
  //---- расчёт стартового номера limit для цикла пересчёта баров
  //---- Инициализация индикаторных буферов
  if (prev_calculated == 0)
       limit = Bars_ - 1 - MinBars;
  else limit = rates_total - prev_calculated;
  
  //----
  limit_ = limit + 1;

  //---- индексация элементов в массивах как в таймсериях
  ArraySetAsSeries(TempArray1, true);
  ArraySetAsSeries(TempArray2, true);
  ArraySetAsSeries(TempArray3, true);
  ArraySetAsSeries(TempArray4, true);
  ArraySetAsSeries(TempArray5, true);
  ArraySetAsSeries(TempArray6, true);
  
  //---- Используя хендлы индикаторов, копируем значения индикаторных 
                   // буферов в специально подготовленные для этого динамические массивы
  if (CopyBuffer(CrossA, 0, 0, limit_, TempArray1) < 0){Print("CopyBuffer TempArray1 error =", GetLastError());}
  if (CopyBuffer(CrossA, 1, 0, limit_, TempArray2) < 0){Print("CopyBuffer TempArray2 error =", GetLastError());}
  //----
  if (CopyBuffer(CrossB, 0, 0, limit_, TempArray3) < 0){Print("CopyBuffer TempArray3 error =", GetLastError());}
  if (CopyBuffer(CrossB, 1, 0, limit_, TempArray4) < 0){Print("CopyBuffer TempArray4 error =", GetLastError());}
  //----
  if (CopyBuffer(CrossC, 0, 0, limit_, TempArray5) < 0){Print("CopyBuffer TempArray5 error =", GetLastError());}
  if (CopyBuffer(CrossC, 1, 0, limit_, TempArray6) < 0){Print("CopyBuffer TempArray6 error =", GetLastError());}

  //---- Основной цикл расчёта индикатора
  for(bar = limit; bar >= 0; bar--)
   {
    Fl_Buffer[bar] = 300;
    Dn_Buffer[bar] = 0;
    Up_Buffer[bar] = 0;
    
    //----+ Получение сигналов входа в рынок
    Up0 = false;
    Up1 = false;
    Up2 = false;
    Dn0 = false;
    Dn1 = false;
    Dn2 = false;
    //---- 
    Dif0 = NormalizeDouble(TempArray1[bar] - TempArray2[bar], 4);
    Dif1 = NormalizeDouble(TempArray3[bar] - TempArray4[bar], 4);
    Dif2 = NormalizeDouble(TempArray5[bar] - TempArray6[bar], 4);
    //----
    if (Dif0 > 0) Up0 = true;
    if (Dif1 > 0) Up1 = true;
    if (Dif2 > 0) Up2 = true;
    //----
    if (Dif0 < 0) Dn0 = true;
    if (Dif1 < 0) Dn1 = true;
    if (Dif2 < 0) Dn2 = true;
    //----
    if (Up0 && Up1 && Dn2 && MathAbs(Dif1) > MathAbs(Dif2))Up2 = true;
    if (Up0 && Up2 && Dn1 && MathAbs(Dif2) > MathAbs(Dif1))Up1 = true;
    //----
    if (Dn0 && Dn1 && Up2 && MathAbs(Dif1) > MathAbs(Dif2))Dn2 = true;
    if (Dn0 && Dn2 && Up1 && MathAbs(Dif2) > MathAbs(Dif1))Dn1 = true;
    //----
    if (Up0 && Up1 && !Dn2) Up2 = true;
    if (Up0 && Up2 && !Dn1) Up1 = true;
    //----
    if (Dn0 && Dn1 && !Up2) Dn2 = true;
    if (Dn0 && Dn2 && !Up1) Dn1 = true;
    //----
    if (Up1 && Up2 && !Dn0) Up0 = true;
    if (Dn1 && Dn2 && !Up0) Dn0 = true;
    //----
    if (Up0 && Up1 && Up2)
     {
      Up_Buffer[bar] = 300;
      Fl_Buffer[bar] = 0;
     }
    //----
    if (Dn0 && Dn1 && Dn2)
     {
      Dn_Buffer[bar] = 300;
      Fl_Buffer[bar] = 0;
     } 
    //----+ Получение сигналов выхода из рынка
    DnEnd_Buffer[bar] = EMPTY_VALUE;
    UpEnd_Buffer[bar] = EMPTY_VALUE;
    //---- 
    if (Up0)
     DnEnd_Buffer[bar] = 300;
    //---- 
    if (Dn0)
     UpEnd_Buffer[bar] = 300;  
   }  
//----+ завершение вычислений значений индикатора 
  return(rates_total);
 }
//+X----------------------+ <<< The End >>> +-----------------------X+



