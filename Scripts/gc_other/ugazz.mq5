//+——————————————————————————————————————————————————————————————————————+
//|                                       JQS UGA The alternative ZigZag |
//|                                       Copyright © 2010, JQS aka Joo. |
//|                                     http://www.mql4.com/ru/users/joo |
//+——————————————————————————————————————————————————————————————————————+
#property copyright "Copyright © 2010, JQS aka Joo."                   //|
#property link      "http://www.mql4.com/ru/users/joo"                 //|
//+——————————————————————————————————————————————————————————————————————+
#property description "Скрипт, демонстрирующий работу библиотеки"      //|
#property description "Универсального Генетического Алгоритма UGAlib," //|
#property description "использующего представление хромосомы"          //|
#property description "вещественными числами"                          //|
#property description "на примере поиска вершин альтернативного ZZ"    //|
//+——————————————————————————————————————————————————————————————————————+
#property version   "1.00"                                             //|
#property script_show_inputs                                           //|
//+——————————————————————————————————————————————————————————————————————+
#include <UGAlib.mqh>
//+——————————————————————————————————————————————————————————————————————+

//————————————————————————————————————————————————————————————————————————
//----------------------Входные переменные--------------------------------
input string GenofundParam        =        "----Параметры генофонда----";
input int    ChromosomeCount_P    = 100;       //Кол-во хромосом в колонии
input int    GeneCount_P          = 100;       //Кол-во генов
input int    FFNormalizeDigits_P  = 0;        //Кол-во знаков приспособлености
input int    GeneNormalizeDigits_P= 0;        //Кол-во знаков гена
input int    Epoch_P               = 50;    //Кол-во эпох без улучшения
//---
input string GA_OperatorParam     =        "----Параметры операторов----";
input double ReplicationPortion_P  = 100.0; //Доля Репликации.
input double NMutationPortion_P    = 10.0;  //Доля Естественной мутации.
input double ArtificialMutation_P  = 10.0;  //Доля Искусственной мутации.
input double GenoMergingPortion_P  = 20.0;  //Доля Заимствования генов.
input double CrossingOverPortion_P = 20.0;  //Доля Кроссинговера.
input double ReplicationOffset_P   = 0.5;   //Коэффициент смещения границ интервала
input double NMutationProbability_P= 5.0;   //Вероятность мутации каждого гена в %
//---
input string OptimisationParam    =        "----Параметры оптимизации----";
input double RangeMinimum_P       = 0.0;    //Минимум диапазона поиска
input double RangeMaximum_P       = 5.0;     //Максимум диапазона поиска
input double Precision_P          = 1.0;  //Требуемая точность
input int    OptimizeMethod_P     = 2;       //Оптим.:1-Min,другое-Max

input string Other                =        "----Прочее----";
input double Spred                = 80.0;
input bool   Show                 = true;
//————————————————————————————————————————————————————————————————————————

//————————————————————————————————————————————————————————————————————————
//----------------------Глобальные переменные-----------------------------
double   Hight  [];
double   Low    [];
datetime Time   [];
datetime Ti     [];
double   Peaks  [];
bool     show;
//————————————————————————————————————————————————————————————————————————
//--------------------------Тело программы--------------------------------
int OnStart()
{
  //-----------------------Переменные-------------------------------------
  //Подготовка глобальных переменных для UGA
  ChromosomeCount=ChromosomeCount_P; //Кол-во хромосом в колонии
  GeneCount      =GeneCount_P;       //Кол-во генов
  RangeMinimum   =RangeMinimum_P;    //Минимум диапазона поиска
  RangeMaximum   =RangeMaximum_P;    //Максимум диапазона поиска
  Precision      =Precision_P;       //Шаг поиска
  OptimizeMethod =OptimizeMethod_P;  //1-минимум, любое другое-максимум

  FFNormalizeDigits   = FFNormalizeDigits_P;  //Кол-во знаков приспособлености
  GeneNormalizeDigits = GeneNormalizeDigits_P;//Кол-во знаков гена

  ArrayResize(Chromosome,GeneCount+1);
  ArrayInitialize(Chromosome,0);
  Epoch=Epoch_P;                     //Кол-во эпох без улучшения
  //----------------------------------------------------------------------
  //Подготовка глобальных переменных
  ArraySetAsSeries(Hight,true);  CopyHigh (NULL,0,0,GeneCount+1,Hight);
  ArraySetAsSeries(Low,true);    CopyLow  (NULL,0,0,GeneCount+1,Low);
  ArraySetAsSeries(Time,true);   CopyTime (NULL,0,0,GeneCount+1,Time);
  ArrayResize     (Ti,GeneCount+1);ArrayInitialize(Ti,0);
  ArrayResize(Peaks,GeneCount+1);ArrayInitialize(Peaks,0.0);
  show=Show;
  //----------------------------------------------------------------------
  //Локальные переменные
  int time_start=GetTickCount(),time_end=0;
  //----------------------------------------------------------------------
  
  //Очистим экран
  ObjectsDeleteAll(0,-1,-1);
  ChartRedraw(0);
  //Запуск главной ф-ии UGA
  UGA
   (
   ReplicationPortion_P, //Доля Репликации.
   NMutationPortion_P,   //Доля Естественной мутации.
   ArtificialMutation_P, //Доля Искусственной мутации.
   GenoMergingPortion_P, //Доля Заимствования генов.
   CrossingOverPortion_P,//Доля Кроссинговера.
   //---
   ReplicationOffset_P,  //Коэффициент смещения границ интервала
   NMutationProbability_P//Вероятность мутации каждого гена в %
   );
  //----------------------------------
  //Выведем последний результат на экран
  show=true;
  ServiceFunction();
  //----------------------------------
  time_end=GetTickCount();
  //----------------------------------
  Print(time_end-time_start," мс - Время исполнения");
  //----------------------------------
  return(0);
}
//————————————————————————————————————————————————————————————————————————

//————————————————————————————————————————————————————————————————————————
//-----------------------------------------------------------------------+
// Сервисная функция. Вызывается из UGA.                                 |
// Служит для вывода наилучшего варианта оптимизируемых аргументов,      |
//например, для контроля.                                                |
//Если в ней нет обходимости, оставить функцию пустой так:               |
//   void ServiceFunction()                                              |
//   {                                                                   |
//   }                                                                   |
//-----------------------------------------------------------------------+
void ServiceFunction()
{ 
  if(show==true)
  {
    //-----------------------Переменные-----------------------------------
    double PipsSum=0.0;
    int    PeaksCount=0;
    double temp=0.0;
    //--------------------------------------------------------------------
    for(int u=1;u<=GeneCount;u++)
    {
      temp=Chromosome[u];
      if(temp<=1.0 )
      {
        Peaks[PeaksCount]=NormalizeDouble(Hight[u],Digits());
        Ti   [PeaksCount]=Time[u];
        PeaksCount++;
      }
      if(temp>=4.0)
      {
        Peaks[PeaksCount]=NormalizeDouble(Low[u],Digits());
        Ti   [PeaksCount]=Time[u];
        PeaksCount++;
      }
    }
    ObjectsDeleteAll(0,-1,-1);
    for(int V=0;V<PeaksCount-1;V++)
    {
      PipsSum+=NormalizeDouble((MathAbs(Peaks[V]-Peaks[V+1]))/Point(),FFNormalizeDigits)-Spred;
      ObjectCreate    (0,"BoxBackName"+(string)V,OBJ_TREND,0,Ti[V],Peaks[V],Ti[V+1],Peaks[V+1]);
      ObjectSetInteger(0,"BoxBackName"+(string)V,OBJPROP_COLOR,Yellow);
      ObjectSetInteger(0,"BoxBackName"+(string)V,OBJPROP_SELECTABLE,true);
    }
    ChartRedraw(0);
    Comment(PipsSum);
  }
  //----------------------------------------------------------------------
  else
    return;
}
//————————————————————————————————————————————————————————————————————————

//————————————————————————————————————————————————————————————————————————
//-----------------------------------------------------------------------+
// Функция оценки приспособленности особи. Вызывается из UGA.            |
// Это собственно и есть оптимизируема функция.                          |
//                                                                       |
// Для примера:                                                          |
// Нужно найти оптимальные параметры индикатора.Следует "прогнать"       |
// индикатор на исторических данных и собрать сигналы от него. Если      |
// интересует количество пунктов прибыли, то максимальное значение и     |
// будет соответсвовать максимальной приспособленности особи             |
// (набора параметров индикатора).                                       |
//-----------------------------------------------------------------------+

//========================================================================
void FitnessFunction(int chromos)
{
  //-----------------------Переменные-------------------------------------
  double PipsSum=0.0;
  int    PeaksCount=0;
  double temp=0.0;
  //----------------------------------------------------------------------
  for(int u=1;u<=GeneCount;u++)
  {
    temp=Colony[u][chromos];
    if(temp<=1.0)
    {
      Peaks[PeaksCount]=NormalizeDouble(Hight[u],Digits());
      PeaksCount++;
    }
    if(temp>=4.0)
    {
      Peaks[PeaksCount]=NormalizeDouble(Low[u],Digits());
      PeaksCount++;
    }
  }

  if(PeaksCount>1)
  {
    for(int V=0;V<PeaksCount-1;V++)
      PipsSum+=NormalizeDouble((MathAbs(Peaks[V]-Peaks[V+1]))/Point(),FFNormalizeDigits)-Spred;

    Colony[0][chromos]=PipsSum;
  }
  else
    Colony[0][chromos]=-10000000.0;
  AmountStartsFF++;
}
