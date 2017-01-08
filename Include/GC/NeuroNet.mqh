//+------------------------------------------------------------------+
//|                                                     NeuroNet.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#define iMaxLayer	5
#define iMaxNeuron	100
#define iMaxPattern	5000
// типы слоев (LayerType) (и соответствующих методов обучения)
#define ltIn	0
#define ltOut	1
#define ltBack	2
#define ltKoh	3

#define RAND_MAX 1

//double Math_Abs(double x);
//int Sign(double x);
//double Sigmoid(double x);
//int TradeDir(double x);// направление торговли
//------------------------------------------------
class CNeuroNet //: public CObject  
  {
public:
   int               nCycle;      // число циклов обучения до останова
   int               nPattern;   // число обучающих паттернов
   int               nLayer;      // число обучающих слоев
   double            Delta;   // требуемая минимальная ошибка выхода
   int               nNeuron[iMaxLayer];         // число нейронов в слое (по слоям)
   int               LayerType[iMaxLayer];      // типы слоев (по слоям)
   double            W[iMaxLayer][iMaxNeuron][iMaxNeuron];// веса по слоям
   double            dW[iMaxLayer][iMaxNeuron][iMaxNeuron];// коррекция веса
   double            Thresh[iMaxLayer][iMaxNeuron];      // порог
   double            dThresh[iMaxLayer][iMaxNeuron];      // коррекция порога
   double            Out[iMaxLayer][iMaxNeuron];         // значение выхода
   double            OutArr[iMaxNeuron];               // сортированные значения выхода слоя Кохонена
   int               IndexWin[iMaxNeuron];               // сортированные индексы нейронов слоя Кохонена
   double            Err[iMaxLayer][iMaxNeuron][iMaxNeuron];// ошибка

   double            Speed;         // Скорость обучения
   double            Impuls;         // Импульс обучения

   double            in[100][iMaxPattern];   // Вектор входных значений
   double            out[10][iMaxPattern];   // вектор выходных значяний
   double            pout[10];            // предыдущий вектор выходных значяний
   double            bar[4][iMaxPattern];      // бары, на которых учимся
   int               TradePos;   // направление ордера
   double            ProfitPos;   // полученная прибыль/убыток ордера

public:
                     CNeuroNet();
   virtual          ~CNeuroNet();
   // функции
   void              Init(int aPattern=1,int aLayer=1,int aCycle=10000,double aDelta=0.01,double aSpeed=0.1,double aImpuls=0.1);
   // функции обучения
   void              CalculateLayer();   // Расчет выхода слоя
   void              CalculateError();   // Расчет ошибки /для массива Target/
   void              ChangeWeight();   // Корректировка весов
   bool              TrainNetwork();   // Обучение сети
   void              CalculateLayer(int L);   // Расчет выхода слоя Кохонена
   void              CalculateError(int L); // Расчет ошибки слоя Кохонена
   void              ChangeWeight(int L);   // Корректировка весов для указания слоя
   bool              TrainNetwork(int L);   // Обучение слоя Кохонена

   bool              TrainMPS();   // Обучение сети на получение хорошего профита

                                   // данные для обмена с внешним миром
   bool              bInProc;   // флаг входа в функцию TrainNetwork
   bool              bStop;      // флаг для принудительного прекращения функции TrainNetwork
   int               loop;
   int               pat;
   int               iMaxErr;   // паттерн с максимальной ошибкой
   double            dMaxErr;   // максимальная ошибка
   double            sErr;   // квадрат ошибки паттерна
   int               iNeuron;   // максимальное число нейронов
   int               iWinNeuron;   // число нейронов

   int               WinNeuron[iMaxNeuron]; // массив активных нейронов
   int               NeuroPat[iMaxPattern][iMaxNeuron]; // массив активных нейронов

   void              LinearCovariation();   // Нормирование выборки
   void              SaveW();            // Анализ нейронной активности 
  };
//+------------------------------------------------------------------+
int Sign(double x)
  {
   if(x>=0) return(1); else return(-1);
  }
//------------------------------------------------
double Math_Abs(double x)
  {
   if(x>=0) return(x); else return(-x);
  }


double Sigmoid(double x)// вычисление логистической функции активации
  {
   return(1/(1+exp(-x)));
  }
//------------------------------------------------
int TradeDir(double x)// направление торговли
  {
   if(x>=0.5) return(1); else return(-1);
  }
//------------------------------------------------

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
CNeuroNet::CNeuroNet()
  {
   nCycle=10000; Delta=0.01; nPattern=1;
   sErr=0; loop=0; pat=0; iMaxErr=0; dMaxErr=0; bInProc=false; bStop=false;
  }
//------------------------------------------------
CNeuroNet::~CNeuroNet()
  {
  }
//------------------------------------------------
void CNeuroNet::Init(int aPattern,int aLayer,int aCycle,double aDelta,double aSpeed,double aImpuls)
  {
// Инициализируем переменные
   nCycle=aCycle; Delta=aDelta; nPattern=aPattern; nLayer=aLayer+1; Speed=aSpeed; Impuls=aImpuls;
   if(nPattern>iMaxPattern)
     {
      //AfxMessageBox("Вы задали много шаблонов!");
      nPattern=iMaxPattern;
     }
// Инициализируем слои
   int N,pN,L;
// обозначили типы слоев
   LayerType[0]=ltIn;   // входящий слой (вектор значений)
                        //	LayerType[1]=ltKoh;	// задали слой типа Кохонена для классификации входных векторов
   LayerType[nLayer]=ltOut; // выходящий слой
   for(L=1;L<nLayer;L++) LayerType[L]=ltBack; // скрытые слои с методом обратного распространения

                                              //srand(time(NULL)); // перенастроили счетчик
   double p=0.00001;
// Обнулили массивы и задали начальные веса
   for(L=1;L<nLayer;L++)
     {
      for(N=0;N<nNeuron[L];N++)
        {
         for(pN=0;pN<nNeuron[L-1];pN++)
           {
            dW[L][N][pN]=0; W[L][N][pN]=p+double(rand())/RAND_MAX;
           }
         dThresh[L][N]=0; Thresh[L][N]=p+double(rand())/RAND_MAX;
        }
     }
// нормирование выборки и весов на [-1,1]
   LinearCovariation();

/*	L=1; // нормируем веса слоя Кохонена
	for(N=0;N<nNeuron[L];N++)
	{
		p=0; for(pN=0;pN<nNeuron[L-1];pN++) p+=W[L][N][pN]*W[L][N][pN];
		p=sqrt(p); for(pN=0;pN<nNeuron[L-1];pN++) W[L][N][pN]=W[L][N][pN]/p;
		// все веса на середину
		for(pN=0;pN<nNeuron[L-1];pN++) W[L][N][pN]=1/sqrt(nNeuron[L]);
	}
*/
  }
//------------------------------------------------
void CNeuroNet::CalculateLayer() // Расчет выхода слоя
  {
   int N,pN,L;
   double sum;

   for(L=1;L<nLayer;L++) // проходим по слоям
     {
      switch(LayerType[L]) // определяем тип слоя
        {
         case ltBack: // слой - метод обратного распространения
            for(N=0;N<nNeuron[L];N++)
              {
               sum=0;
               for(pN=0;pN<nNeuron[L-1];pN++)
                  sum+=W[L][N][pN]*Out[L-1][pN];
               Out[L][N]=Sigmoid(sum+Thresh[L][N]);
              }
            break;
         case ltKoh: // слой Кохонена
            CalculateLayer(L);
            break;
        }
     }
  }
//------------------------------------------------
void CNeuroNet::CalculateLayer(int L) // Расчет выхода слоя Кохонена
  {
   if(LayerType[L]!=ltKoh) return;// только слой Кохонена

   int N,pN; double Max=0;
   for(N=0;N<nNeuron[L];N++) // считаем выходы нейронов
     {
      Out[L][N]=0;
      for(pN=0;pN<nNeuron[L-1];pN++) Out[L][N]+=W[L][N][pN]*Out[L-1][pN];
      OutArr[N]=Out[L][N];  IndexWin[N]=N;
     }
// сортируем массив выходов по убыванию
   bool b=true;
   while(b)
     {
      b=false;
      for(N=1;N<nNeuron[L];N++)
        {
         if(OutArr[N]>OutArr[N-1])
           {
            Max=OutArr[N]; OutArr[N]=OutArr[N-1]; OutArr[N-1]=Max;
            pN=IndexWin[N]; IndexWin[N]=IndexWin[N-1]; IndexWin[N-1]=pN; b=true;
           }
        }
     }
// определяем допустимую зону, нейроны которой принимают участие в коррекции весов
// сделаем ее зависимой от числа циклов обучения, 
// постепенно сужая до одного максимального победителей
   double h=nNeuron[L]-((double)(loop)/(double)(10*nNeuron[L]));
   if(h<1) h=1; if(h>nNeuron[L]) h=nNeuron[L];
   iWinNeuron=1;
  }
//------------------------------------------------
void CNeuroNet::CalculateError() // Расчет ошибки
  {
   int N,nN,L;
   double sum;
   for(L=nLayer-1; L>0;L--) // проходим по слоям
     {
      if(LayerType[L]==ltKoh) break; // только не для Кохонена
      switch(LayerType[L+1]) // определяем тип следующего слоя
        {
         case ltOut: // выходной вектор 
            for(N=0;N<nNeuron[L];N++) // вычисляем ошибку нейронов выходного слоя
            Err[L][N][0]=Out[L][N]*(1-Out[L][N])*(Out[L+1][N]-Out[L][N]);
            break;
         case ltBack: // скрытый слой по методу обратного распространения
            for(N=0;N<nNeuron[L];N++) // проходим по нейронам в слое
              {
               sum=0;
               for(nN=0;nN<nNeuron[L+1];nN++) sum+=Err[L+1][nN][0]*W[L+1][nN][N];
               Err[L][N][0]=Out[L][N]*(1-Out[L][N])*sum;
              }
            break;
        }
     }
  }
//------------------------------------------------
void CNeuroNet::CalculateError(int L) // Расчет ошибки слоя Кохонена
  {
   if(LayerType[L]!=ltKoh) return;// только слой Кохонена

   int N,pN;
// скорость обучения сделаем зависимой от прошедшего времени обучения
   Speed=0.2-sqrt(double(loop)/double(nNeuron[L]*1e4)); if(Speed<0.0005) Speed=0.0005;
// проходим по полученной группе нейронов и находим их коррекции
   for(N=0;N<nNeuron[L];N++)
     {
      for(pN=0;pN<nNeuron[L-1];pN++)
        {
         Err[L][N][pN]=Out[L-1][pN]-W[L][N][pN];
         dW[L][N][pN]=Speed*Err[L][N][pN];//+Impuls*dW[L][N][pN];
        }
     }
  }
//------------------------------------------------
void CNeuroNet::ChangeWeight() // Корректировка весов
  {
   int pN,N,L,ea;
   double max=0;
   for(L=nLayer-1;L>0;L--)
     {
      switch(LayerType[L]) // определяем тип слоя
        {
         case ltBack: // слой - метод обратного распространения
            for(N=0;N<nNeuron[L];N++) // находим максимальную ошибку
            if(Math_Abs(Err[L][N][0])>Math_Abs(max)) { max=Err[L][N][0]; ea=N; }
            // меняем веса как обычно
            for(N=0;N<nNeuron[L];N++)
              {
               for(pN=0;pN<nNeuron[L-1];pN++)
                 {
                  // для самого "глупого" ускоряем обучение
                  if(N==ea) dW[L][N][pN]=2*Speed*Err[L][N][0]*Out[L-1][pN]+Impuls*dW[L][N][pN];
                  else dW[L][N][pN]=Speed*Err[L][N][0]*Out[L-1][pN]+Impuls*dW[L][N][pN];
                  //если корректировка очень маленькая
                  if(Math_Abs(dW[L][N][pN])<1e-8) dW[L][N][pN]=1e-7*Sign(dW[L][N][pN]);
                  W[L][N][pN]+=dW[L][N][pN];
                 }
               // для самого "глупого" ускоряем обучение
               if(N==ea) dThresh[L][N]=2*Speed*Err[L][N][0]+Impuls*dThresh[L][N];
               else dThresh[L][N]=Speed*Err[L][N][0]+Impuls*dThresh[L][N];
               //если корректировка очень маленькая
               if(Math_Abs(dThresh[L][N])<1e-8) dThresh[L][N]=10*dThresh[L][N];
               Thresh[L][N]+=dThresh[L][N];
              }
            break;
        }
     }
  }
//------------------------------------------------
void CNeuroNet::ChangeWeight(int L) // Корректировка весов для Кохонена
  {
   int pN,N,i;
   double h=double(nPattern)/double(nNeuron[L]);
// корректируем веса указанного слоя
   if(LayerType[L]!=ltKoh) return;// только слой Кохонена

   N=0; i=0; // с принципом справедливости!
   while(i<iWinNeuron && N<nNeuron[L])
     {
      //		if (WinNeuron[IndexWin[N]]<int(h+1))
        {
         WinNeuron[IndexWin[N]]++; // счетчик нейрона победителей
         for(pN=0;pN<nNeuron[L-1];pN++)
            W[L][IndexWin[N]][pN]+=dW[L][IndexWin[N]][pN];
         i++;
        }
      N++;
     }
   N=nNeuron[L]-1;
   if(i<iWinNeuron)
      for(pN=0;pN<nNeuron[L-1];pN++) W[L][IndexWin[N]][pN]+=dW[L][IndexWin[N]][pN];
  }
//------------------------------------------------
bool CNeuroNet::TrainNetwork() // Обучение сетки
  {
   int i,ipat;
   bool bError=true;
   double err,ser2,dmax;
   bInProc=true;
   loop=1;
   while(!bStop && (bError || (nCycle>0 && loop<nCycle))) // входим в цикл обучения
     {
      for(pat=0;pat<nPattern;pat++) // проходим по шаблону и обучаем сеть
        {
         for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][pat]; // взяли обучающий шаблон
         for(i=0;i<nNeuron[nLayer];i++) Out[nLayer][i]=out[i][pat]; // взяли выходы обучающего шаблона
         CalculateLayer(); // рассчитали выход
         CalculateError(); // рассчитали ошибку
         ChangeWeight(); // подкоректировали веса
        }
      bError=false; // флаг конца обучения
      dmax=0; ser2=0;
      for(pat=0; pat<nPattern;pat++) // проверили качество обучения
        {
         for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][pat]; // взяли обучающий шаблон
         for(i=0;i<nNeuron[nLayer];i++) Out[nLayer][i]=out[i][pat]; // взяли выходы обучающего шаблона
         CalculateLayer(); // рассчитали выход
                           // если хоть в одном образце есть ошибка, то продолжаем обучение
         for(i=0;i<nNeuron[nLayer-1];i++)
           {
            err=Out[nLayer][i]-Out[nLayer-1][i];   // значение ошибки
            if(Math_Abs(err)>Delta) bError=true;   // сравнение с требуемой
            if(Math_Abs(err)>Math_Abs(dmax)) { ipat=pat; dmax=err; }// максимальная
            ser2+=(err*err);// среднеквадратичная
           }
        }
      sErr=ser2; dMaxErr=dmax; iMaxErr=ipat;
      loop++;
     }
   bInProc=false;
   return(!bError);// возвращаем результат обучения - смогли обучить или нет
  }
//------------------------------------------------
bool CNeuroNet::TrainNetwork(int L) // Обучение слоя Кохонена
  {
   if(LayerType[L]!=ltKoh) return(false);// только слой Кохонена

   int N,pN,ipat;
   bool bError=true;
   double ser2,dmax,Alfa,err,Betta;
   bInProc=true;
   loop=1; L=1;
   while(!bStop && (bError || (nCycle>0 && loop<nCycle))) // входим в цикл обучения
     {
      //		iNeuron=0; // обнулили счетчик нейронов победителей
      for(N=0;N<nNeuron[L];N++) { for(pN=0;pN<nNeuron[L];pN++) WinNeuron[N]=0; }
      for(pat=0;pat<nPattern;pat++) { for(N=0;N<nNeuron[L];N++) NeuroPat[pat][N]=0; }
      // используем метод выпуклой комбинации
      Alfa=double(loop)/1e5; if(Alfa>1) Alfa=1;
      Alfa=1; Betta=(1-Alfa)/sqrt(nNeuron[L-1]);
      for(pat=0;pat<nPattern;pat++) // проходим по шаблону и обучаем сеть
        {
         // взяли обучающий шаблон
         for(N=0;N<nNeuron[L-1];N++) Out[L-1][N]=Alfa*in[N][pat]+Betta;
         CalculateLayer(L); // рассчитали выход
         CalculateError(L); // вычислили ошибку слоя
         ChangeWeight(L); // подкорректировали веса
         NeuroPat[pat][IndexWin[0]]++; // ореагировавшего нейрона на паттерн
                                       //			if (iWinNeuron>iNeuron) iNeuron=iWinNeuron;
         if(pat==1) iNeuron=IndexWin[0];
        }

      //		bError=false; // флаг конца обучения
      dmax=WinNeuron[0]; pat=0;
      // находим частого нейрона победителя
      for(N=0;N<nNeuron[L];N++) if(WinNeuron[N]>dmax) { dmax=WinNeuron[N]; pat=N; }
      // находим любой неактивнй нейрон и делим "славу" победителя
      for(N=0;N<nNeuron[L];N++)
        {
         //			if (WinNeuron[N]==0) 
         //				for(pN=0;pN<nNeuron[L-1];pN++) W[L][N][pN]=W[L][pat][pN]; 
        }

      dmax=0;
      for(pat=0; pat<nPattern;pat++) // проверяем качество обучения
        {
         ser2=0;
         // взяли обучающий шаблон
         for(N=0;N<nNeuron[L-1];N++) Out[L-1][N]=Alfa*in[N][pat]+Betta;
         CalculateLayer(L); // рассчитали выход
         CalculateError(L); // вычислили ошибку слоя
         for(N=0;N<iWinNeuron;N++) // находим среднеквадратичную ошибку
           {
            for(pN=0;pN<nNeuron[L-1];pN++) // проссумировали ошибку слоя
              {
               err=Math_Abs(Err[L][IndexWin[N]][pN]);
               ser2+=(err*err);
               if(err>dmax) { ipat=pat; dmax=err; }   // запомнили максимальную
              }
           }
         // если хоть в одном образце есть большая ошибка, то продолжаем обучение
         if(ser2>Delta) bError=true;   // сравнение с требуемой
        }
      sErr=ser2; dMaxErr=dmax; iMaxErr=ipat;
      loop++;
      // сохраняем активность в файл
      //		if (loop==4000) SaveW();

     }
   bInProc=false;
   return(!bError);// возвращаем результат обучения - смогли обучить или нет
  }
//------------------------------------------------
void CNeuroNet::LinearCovariation()// нормирование выборки на [0,1]
  {
   int pat,N,pN,L,k=1;
   double max,min;
// входные вектора
   for(N=0; N<nNeuron[0]; N++) // по всем нейронам входного слоя
     {
      min=in[N][0]; // ищем минимум на всей выборке
      for(pat=0; pat<nPattern; pat++) if(in[N][pat]<min) min=in[N][pat];
      // подвигаем на величину минимального значения 
      for(pat=0; pat<nPattern; pat++) in[N][pat]-=min;
      max=in[N][0]; // ищем максимум на всей выборке
      for(pat=0; pat<nPattern; pat++) if(in[N][pat]>max) max=in[N][pat];
      // сужаем до [-1,1]
      for(pat=0; pat<nPattern; pat++) in[N][pat]=2*(in[N][pat]/max)-1;
     }
/*
	for(pat=0;pat<nPattern;pat++)	// нормируем входные ветора на свою длину
	{
		p=0;
		for(N=0;N<nNeuron[0];N++) p+=in[N][pat]*in[N][pat];
		p=sqrt(p);
		for(N=0;N<nNeuron[0];N++) in[N][pat]=in[N][pat]/p;
	}
*/
// веса слоев
   for(L=0; L<nLayer; L++)
     {
      if(LayerType[L]==ltBack && nNeuron[L]>1)
        {
         for(pN=0; pN<nNeuron[L-1]; pN++)
           {
            min=W[L][0][pN]; // ищем минимум на всей выборке
            for(N=0; N<nNeuron[L]; N++) if(W[L][N][pN]<min) min=W[L][N][pN];
            // подвигаем на величину минимального значения 
            for(N=0; N<nNeuron[L]; N++) W[L][N][pN]-=min;
            max=W[L][0][pN]; // ищем максимум на всей выборке
            for(N=0; N<nNeuron[L]; N++) if(W[L][N][pN]>max) max=W[L][N][pN];
            // сужаем до [-1,1]
            for(N=0; N<nNeuron[L]; N++) W[L][N][pN]=2*(W[L][N][pN]/max)-1;
           }
        }
      if(LayerType[L]==ltBack && nNeuron[L]==1) // если в слое только один нейрон
        {
         N=0;
         min=W[L][0][0]; // ищем минимум на всей выборке
         for(pN=0; pN<nNeuron[L-1]; pN++) if(W[L][N][pN]<min) min=W[L][N][pN];
         // подвигаем на величину минимального значения 
         for(pN=0; pN<nNeuron[L-1]; pN++) W[L][N][pN]-=min;
         max=W[L][N][0]; // ищем максимум на всей выборке
         for(pN=0; pN<nNeuron[L-1]; pN++) if(W[L][N][pN]>max) max=W[L][N][pN];
         // сужаем до [-1,1]
         for(pN=0; pN<nNeuron[L-1]; pN++) W[L][N][pN]=2*(W[L][N][pN]/max)-1;
        }
     }
  }
//------------------------------------------------
void CNeuroNet::SaveW() // сохраняем активность в файл
  {
//int N, pN, L=1;
//CFile file;
//CString FileName= "F:\\ForexWork\\MetaTraders\\MetaTrader 4 Ft-Trade\\experts\\files\\NeuroWgh.dat";
//file.Open(FileName, CFile::modeCreate); file.Close();
//file.Open(FileName, CFile::modeWrite);
//// записываем файл
//for(N=0;N<nNeuron[L];N++) 
//{
//	for(pN=0;pN<nNeuron[L-1];pN++) 
//		file.Write(&W[L][N][pN], sizeof(double));
//}
//file.Flush(); file.Close();
  }
//------------------------------------------------
bool CNeuroNet::TrainMPS() // Обучение сетки
  {
   int i,ipat;
   bool bError=true;
   double ser2,dmax=0;
   double TP=50;
   bInProc=true; bStop=false;
   loop=1;
   while(!bStop && (bError || (nCycle>0 && loop<nCycle))) // входим в цикл обучения
     {
      ser2=0;
      pat=0; // открываем ордер для первого шаблона
      for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][pat]; // взяли обучающий шаблон
      CalculateLayer(); // рассчитали выход
                        // если выход больше нуля, то покупка, иначе продажа
      TradePos=TradeDir(Out[nLayer-1][0]); ipat=pat;

      for(pat=1;pat<nPattern;pat++) // проходим по шаблону и обучаем сеть
        {
         for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][pat]; // взяли обучающий шаблон
         CalculateLayer(); // рассчитали выход
                           // считаем прибыль/убыток по ценам закрытия [3]
         ProfitPos=1e4*TradePos*(bar[3][pat]-bar[3][ipat]);
         // если поменялось направление торговли или сработал стоп-ордер
         if(/*TradeDir(Out[nLayer-1][0])!=TradePos || */ProfitPos>=TP || ProfitPos<=-TP)
           {
            // корректируем веса
            if(pat==48)
               CalculateLayer(); // рассчитали выход
            ser2+=ProfitPos;
            // задали требуемы выход сети
            Out[nLayer][0]=Sigmoid(0.1*TradePos*ProfitPos);
            // взяли начальный шаблон, по которому открывались
            for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][ipat];
            CalculateLayer(); // рассчитали выход
            CalculateError(); // рассчитали ошибку
            ChangeWeight(); // подкоректировали веса
            if(pat==48)
               CalculateLayer(); // рассчитали выход
            // переходим на новый ордер
            for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][pat];
            CalculateLayer(); // рассчитали выход
                              // если выход больше нуля, то покупка, иначе продажа
            TradePos=TradeDir(Out[nLayer-1][0]);
            ipat=pat;
           }
        }

      sErr=ser2; dMaxErr=ser2; iMaxErr=(int)ser2;
      loop++;
     }
   bInProc=false;
   return(!bError);// возвращаем результат обучения - смогли обучить или нет
  }
class CWorkThread //: public CWinThread
{
	//DECLARE_DYNCREATE(CWorkThread)
public:
	int nBAR;	// число баров для обучения (число обучающих шаблонов)
	int nIN;		// размерность входа (число значений в шаблоне)
	int nOUT;	// размерность выхода 
	CNeuroNet NN; // сеть

	CWorkThread();
	virtual ~CWorkThread();
	
	void ProcessedMsg();		// обработка задания

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CWorkThread)
	public:
	virtual bool InitInstance();
	//virtual bool PreTranslateMessage(MSG* pMsg);
	//}}AFX_VIRTUAL

	// Generated message map functions
	//{{AFX_MSG(CWorkThread)
		// NOTE - the ClassWizard will add and remove member functions here.
	//}}AFX_MSG

	//DECLARE_MESSAGE_MAP()
};

CWorkThread::CWorkThread()
{
}
//------------------------------------------------
bool CWorkThread::InitInstance()
{
	return (true);
}
//------------------------------------------------
CWorkThread::~CWorkThread()
{
}

//BEGIN_MESSAGE_MAP(CWorkThread, CWinThread)
	//{{AFX_MSG_MAP(CWorkThread)
		// NOTE - the ClassWizard will add and remove mapping macros here.
	//}}AFX_MSG_MAP
//END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CWorkThread message handlers

void CWorkThread::ProcessedMsg()
{
	// Выполняем обработку 
//	CFile file;
//	int i, j, k;
//	CString FileName; // именя файла данных 
//	FileName= "F:\\ForexWork\\MetaTraders\\MetaTrader 4 Ft-Trade\\experts\\files\\MA25_15.in";
//	file.Open(FileName, CFile::modeRead);
//	// читаем заголовок файла
//	file.Read(&nBAR, sizeof(int));// число шаблонов
//	file.Read(&nIN, sizeof(int)); // размерность входа
//	file.Read(&nOUT, sizeof(int));// размерность выхода
//	// берем из файла входы
//	for (i=0; i<nBAR; i++) for (j=0; j<nIN; j++) file.Read(&NN.in[j][i], sizeof(double)); 
//	// берем из файла выходы
//	for (i=0; i<nBAR; i++) for (j=0; j<nOUT; j++) file.Read(&NN.out[j][i], sizeof(double));
//	file.Close(); // закрыли файл данных
//
//	FileName= "F:\\ForexWork\\MetaTraders\\MetaTrader 4 Ft-Trade\\experts\\files\\MA25_15.bar";
//	file.Open(FileName, CFile::modeRead);
//	// берем из файла цены
//	for (i=0; i<nBAR; i++)  for (j=0; j<4; j++) file.Read(&NN.bar[j][i], sizeof(double)); 
//	file.Close(); // закрыли файл данных
//
//	NN.nNeuron[0]=nIN;	// размерность входного вектора данных
//	NN.nNeuron[1]=2*nIN;// число нейронов в слое // Кохонена
//	NN.nNeuron[2]=nIN;	// число нейронов в слое 
//	NN.nNeuron[3]=5;	// число нейронов в слое 
//	NN.nNeuron[4]=nOUT;	// число нейронов в выходном слое (размерность совпадает с Target)
//	NN.nNeuron[5]=nOUT;	// размерность выходного целевого вектора данных
//	NN.Init(1000, 4, 6000, 1e-8, 0.15, 0.15); // Создаем сеть и веса
//
////	NN.TrainNetwork(1);	// Классифицировали входы по слою Кохонена
//	NN.TrainMPS();	// Начали обучение сети
//
//	// сохраняем веса в файл для индикатора MQL
//	file.Open(FileName+".wgh", CFile::modeCreate); file.Close();
//	file.Open(FileName+".wgh", CFile::modeWrite);
//	// записываем заголовок файла
//	file.Write(&nIN, sizeof(int)); // размерность входа
//	file.Write(&nOUT, sizeof(int));// размерность выхода
//	file.Write(&NN.nLayer, sizeof(int));// размерность сети
//	// записываем число слоев и их размерности
//	for (k=0; k<NN.nLayer; k++) file.Write(&NN.nNeuron[k], sizeof(int)); // для слоев
//	// записываем веса и пороги в файл
//	for (k=1; k<NN.nLayer; k++)
//		for (i=0; i<NN.nNeuron[k]; i++)
//		{
//			for (j=0; j<NN.nNeuron[k-1]; j++)
//				file.Write(&NN.W[k][i][j], sizeof(double));	// веса сети
//			file.Write(&NN.Thresh[k][i], sizeof(double));	// порог для выхода нейрона
//		}
//	file.Flush(); file.Close();
//
//	// отсылаем сообщение о завершении работы
//	AfxGetMainWnd()->PostMessage(WM_COMMAND, WT_END_JOB, 0);
}
//------------------------------------------------
//BOOL CWorkThread::PreTranslateMessage(MSG* pMsg) 
//{
//	switch (pMsg->message)
//	{
//	case WM_COMMAND:
//		switch (pMsg->wParam)
//		{
//		case WT_HAVE_JOB:
//			ProcessedMsg(); // обрабатываем
//			break;
//		}
//		break;
//	}
//	return CWinThread::PreTranslateMessage(pMsg);
//}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//#define PUPIL	0
//#define TEACHER	1
//
//
//
////------------------------------------------------
//class CLayer //: public CObject  
//{
//public:
//	int	Type;				// типа //УЧЕНИК-УЧИТЕЛЬ
//	int nNeuron;			// число нейронов в слое
//	double W[500][500];		// вес
//	double cW[500][500];	// коррекция веса
//	double Thresh[500];		// порог
//	double cThresh[500];	// коррекция порога
//	double Out[500];		// значение выхода
//	double Err[500];		// ошибка
//	CLayer *prev;			// предыдущий слой (для входных данных)
//	CLayer *next;			// следующий слой (для BackPropagation)
//	double Speed;			// Скорость обучения
//	double Impuls;			// Импульс обучения
//
//	// функции для работы
//	void CalculateLayer();	// Расчет выхода слоя
//	void CalculateError();	// Расчет ошибки /для массива Target/
//	void ChangeWeight();	// Корректировка весов
//
//public:
//	CLayer();
//	virtual ~CLayer();
//	// функции
//	void Init(int aType=TEACHER, CLayer *ap=NULL, CLayer *an=NULL, double aSpeed=0.6, double aImpuls=0.6);
//	void SetNeuron(int aNeuron=1);
//};
//
//CLayer::CLayer()
//{
//	Type=TEACHER; nNeuron=0;
//	prev=NULL; next=NULL;
//	Speed=0.6; Impuls=0.6;
//}
////------------------------------------------------
//void CLayer::Init(int aType, CLayer *ap, CLayer *an, double aSpeed, double aImpuls)
//{
//	Speed=aSpeed;
//	Impuls=aImpuls;
//	prev=ap; next=an;
//	Type=aType; 
//}
////------------------------------------------------
//void CLayer::SetNeuron(int aNeuron)
//{
//	nNeuron=aNeuron;
//	if (Type==TEACHER || prev==NULL)	return;
//	int j,i;
//	for(i=0;i<nNeuron;i++)	// Обнулили массивы
//	{
//		for(j=0;j<prev->nNeuron;j++) cW[i][j]=0;
//		cThresh[i]=0;
//	}
//	// Задали начальные веса
//	srand((unsigned)time(NULL)); // перенастроили счетчик
//	double p=0.00001;
//	for(i=0; i<nNeuron;i++)
//	{ 
//		for(j=0; j<prev->nNeuron;j++)	W[i][j]=p+double(rand())/RAND_MAX;
//		Thresh[i]=p+double(rand())/RAND_MAX;
//	}
//}
////------------------------------------------------
//CLayer::~CLayer()
//{
//}
////------------------------------------------------
//void CLayer::CalculateLayer() // Расчет выхода слоя
//{
//	if (Type==TEACHER)	return;
//	prev->CalculateLayer();	// вычисляем выход предыдущего слоя // типа рекурсии 
//	int i,j;
//	double sum;
//	for(i=0;i<nNeuron;i++)
//	{ 
//		sum=0;
//		for(j=0;j<prev->nNeuron;j++) sum+=W[i][j]*prev->Out[j];
//		Out[i]=Sigmoid(sum+Thresh[i]);
//	}
//}
////------------------------------------------------
//void CLayer::CalculateError() // Расчет ошибки
//{
//	if (Type==TEACHER)	return;
//	int i, j; 
//	double sum;
//	if (next->Type==TEACHER)	// если это выходной слой, то берем целевой выход next->Out	
//		for(i=0;i<nNeuron;i++) 
//			Err[i]=Out[i]*(1-Out[i])*(next->Out[i]-Out[i]);
//	else	//	иначе расчитываем как скрытый слой
//		for(i=0;i<nNeuron;i++)
//		{ 
//			sum=0;
//			for(j=0;j<next->nNeuron;j++) sum+=next->Err[j]*next->W[j][i];
//			Err[i]=Out[i]*(1-Out[i])*sum;
//		}
//	prev->CalculateError();	// вычисляем ошибку для предыдущего слоя // типа рекурсии 
//}
////------------------------------------------------
//void CLayer::ChangeWeight() // Корректировка весов
//{
//	if (Type==TEACHER)	return;
//	int j, i, ea;
//	double max=0;
//
//	// находим максимальную ошибку
//	for(i=0;i<nNeuron;i++) if (MathAbs(Err[i])>MathAbs(max))	{	max=Err[i]; ea=i; }
//	// меняем веса как обычно
//	for(i=0;i<nNeuron;i++)
//	{
//		for(j=0;j<prev->nNeuron;j++) 
//		{
//			// для самого "глупого" ускоряем обучение
//			if (i==ea) cW[i][j]=2*Speed*Err[i]*prev->Out[j]+Impuls*cW[i][j];
//			else cW[i][j]=Speed*Err[i]*prev->Out[j]+Impuls*cW[i][j];
//			//если корректировка очень маленькая
//			if (MathAbs(cW[i][j])<1e-6) cW[i][j]=1e-5*Sign(cW[i][j]);
//			W[i][j]+=cW[i][j];
//		}
//			// для самого "глупого" ускоряем обучение
//		if (i==ea) cThresh[i]=2*Speed*Err[i]+Impuls*cThresh[i];
//		else cThresh[i]=Speed*Err[i]+Impuls*cThresh[i];
//		//если корректировка очень маленькая
//		if (MathAbs(cThresh[i])<1e-6) cThresh[i]=1e-5*Sign(cThresh[i]);
//		Thresh[i]+=cThresh[i];
//	}
//	prev->ChangeWeight();	// меняем веса предыдущего слоя // типа рекурсии 
//}
////------------------------------------------------
