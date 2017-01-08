//+--------------------------------------------------------------------------------------+
//|                                                 Nearest Neighbor - weighted corr.mq5 |
//|                                                                 Copyright 2010, gpwr |
//|                                                                   vlad1004@yahoo.com |
//+--------------------------------------------------------------------------------------+
#property copyright "gpwr"
#property version   "1.00"
#property description "Предсказание будущего основано на ближайшем соседе в прошлом"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- future model outputs
#property indicator_label1  "NN будущие"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- past model outputs
#property indicator_label2  "NN прошлые"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Blue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//===================================== Входные параметры ===========================================
input int    Npast   =300; // # количество баров прошлого в паттерне
input int    Nfut    =50;  // # количество баров будущего в паттерне (должно быть < Npast)

// Глобальные переменные
int bars,PrevBars,si;
double mx[],sxx[],denx[],sumx,sumxx;
bool FirstTime;

// Индикаторные буферы
double ynn[],xnn[];

// Custom indicator initialization function ---------------------------------------------+
void OnInit()
{
// Инициализируем глобальные переменные
   PrevBars=Bars(_Symbol,_Period)-1;
   FirstTime=true;
   si=Npast*(Npast+1)/2;

// Маппинг индикаторных буферов
   SetIndexBuffer(0,ynn,INDICATOR_DATA);
   SetIndexBuffer(1,xnn,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,"1NN("+string(Npast)+")");
   PlotIndexSetInteger(0,PLOT_SHIFT,Nfut);
}

//====================================== MAIN ============================================
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& Time[],
                const double& Open[],
                const double& High[],
                const double& Low[],
                const double& Close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
// Проверка на наличие необходимого количества данных и нового бара
   int bars=rates_total;
   if(bars<Npast+Nfut)
   {
      Print("Ошибка: Недостаточно баров в истории!");
      return(0);
   }
   if(PrevBars==bars) return(rates_total);
   PrevBars=bars;

// Инициализируем индикаторные буферы значением EMPTY_VALUE
   ArrayInitialize(xnn,EMPTY_VALUE);
   ArrayInitialize(ynn,EMPTY_VALUE);

// Главный цикл ---------------------------------------------------------------------------+
   // Расчет корреляционных сумм для текущего паттерна
   // Текущий паттерн начинается при i=bars-Npast и заканчивается при i=bars-1
   double my=0.0;
   double syy=0.0;
   for(int i=0;i<Npast;i++)
   {
      double y=Open[bars-Npast+i];
      my +=y*(i+1);
      syy+=y*y*(i+1);
   }
   double deny=syy*si-my*my;
   if(deny<=0)
   {
      Print("Нулевое или отрицательное значение выражения: syy*Npast-my*my = ",deny);
      return(0);
   }
   deny=MathSqrt(deny);
   
   // Расчет корреляционных сумм для паттернов прошлого
   // Паттерны прошлого начинаются при k=0 и заканчиваются при k=bars-Npast-Nfut   
   ArrayResize(mx,bars-Npast-Nfut+1);
   ArrayResize(sxx,bars-Npast-Nfut+1);
   ArrayResize(denx,bars-Npast-Nfut+1);
   int kstart;
   if(FirstTime) kstart=0;
   else kstart=bars-Npast-Nfut;
   FirstTime=false;
   for(int k=kstart;k<=bars-Npast-Nfut;k++)
   {
      if(k==0)
      {
         mx[0] =0.0;
         sxx[0]=0.0;
         sumx  =0.0;
         sumxx =0.0;
         for(int i=0;i<Npast;i++)
         {
            double x =Open[i];
            double xx=x*x;
            mx[0] +=x*(i+1);
            sxx[0]+=xx*(i+1);
            sumx  +=x;
            sumxx +=xx;
         }
      }
      else
      {
         double xnew=Open[k+Npast-1];
         double xold=Open[k-1];
         mx[k] =mx[k-1]-sumx+xnew*Npast;
         sxx[k]=sxx[k-1]-sumxx+xnew*xnew*Npast;
         sumx +=xnew-xold;
         sumxx+=xnew*xnew-xold*xold;
      }
      denx[k]=sxx[k]*si-mx[k]*mx[k];
   }
   
   // Расчет кросс-корреляционных сумм, 
   // коэффициентов корреляции и нахождение ближайших соседей
   double sxy[];
   ArrayResize(sxy,bars-Npast-Nfut+1);
   double b,corrMax=0;
   int knn=0;
   for(int k=0;k<=bars-Npast-Nfut;k++)
   {
      // вычисляем sxy
      sxy[k]=0.0;
      for(int i=0;i<Npast;i++) sxy[k]+=Open[k+i]*Open[bars-Npast+i]*(i+1);
      
      // Вычисляем коэффициент корреляции
      if(denx[k]<=0)
      {
         Print("Нулевое или отрицательное значение выражения sxx[k]*Npast-mx[k]*mx[k]. Пропускаем паттерн # ",k);
         continue;
      }
      double num=sxy[k]*si-mx[k]*my;
      double corr=num/MathSqrt(denx[k])/deny;
      if(corr>corrMax)
      {
         corrMax=corr;
         knn=k;
         b=num/denx[k];
      }
   }
   Print("Ближайший сосед начинается ",Time[knn]," и заканчивается ",Time[knn+Npast-1],
      ". Его коэффициент корреляции с текущим паттерном равен ",corrMax);
        
   // Вычисляем xm[] и ym[] масштабированием ближайшего соседа
   double delta=Open[bars-1]-b*Open[knn+Npast-1];
   for(int i=0;i<Npast+Nfut;i++)
   {
      if(i<=Npast-1) xnn[bars-Npast+i]=b*Open[knn+i]+delta;
      if(i>=Npast-1) ynn[bars-Npast-Nfut+i]=b*Open[knn+i]+delta;
   }
   
   return(rates_total);
}
