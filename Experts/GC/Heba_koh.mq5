// Реализация многослойного персептрона с обучением по правилу Хебба (MQL4, Metatrader)

// Обучение нейронной сети без учителя. В качестве функции активации используется только тангенсоида

#property copyright "Shumi"
#property link      "http://apsheronsk.bozo.ru"
#define MAX 50
#define HEBB 1
#define SIGNAL_HEBB 2
#define KOHONEN 3

double Alpha=0.5; // коэффициент в тангенсоиде
int Layers; // количество слоев
int GNeuro[]={6,25,2};// количество нейронов в слоях. Для задачи с волнами, кол-во входов должно быть четным!
double GMatrix[][MAX][MAX]; // массив весов
double Input[]; // входной вектор
double Output[]; // выходной вектор (желаемый)
double GSum[][MAX]; // то что входит в нейроны
double GOut[][MAX]; // то что выходит из нейронов
                    //
double sea[50000][3]; // массив с параметрами волн
int    count=0; // счетчик, сколько строк (волн) было прочитано с csv-файла
                //
double Error,stab=1; // ошибка для обучения с учителем, признак застабилизированности весов
double stab_porog=0.001; // порог застабилизированности весов
bool   Tutor=false; // с учителем или без
bool   Test=false;
double Koef1=0.005; // скорость обучения
bool   Debug_Mode=false; // режим деббугера
int    debugfile;
double max2[3]; // максимальное значение в sea[][2] для шкалирования
int    LEARNING_TYPE=HEBB;
int    kolvo=100; // количество примеров в обучающей выборке
//+------------------------------------------------------------------+
int start()
  {
   if(Debug_Mode==true) {debugfile=FileOpen("Matrixes.csv",FILE_CSV|FILE_WRITE,';');}
   ReadParams();
   PrepareInputs();
   SetParams();
   InitNet();
//TestCalc(100);
   Hebb();
   if(Debug_Mode==true) {FileClose(debugfile);}
   return(0);
  }
//+------------------------------------------------------------------+
void SetParams()
  {
   Layers=ArraySize(GNeuro); // определяем количество слоев сети
   Alert("Количество слоев = ",Layers);
   ArrayResize(GMatrix,Layers-1); //инициализируем первое измерение GMatrix
   ArrayResize(Input,GNeuro[0]); // инициализируем размерность входного вектора
   ArrayResize(Output,GNeuro[Layers-1]); // размерность выходного вектора   
   ArrayResize(GSum,Layers-1); // инициализируем размерность сумматоров в перцептроны
   ArrayResize(GOut,Layers-1); // инициализируем размерность выходов нейронов
   ArrayInitialize(GSum,0);
   ArrayInitialize(GOut,0);
  }
//+------------------------------------------------------------------+
void InitNet()
  {
// Инициализация весов сети
   MathSrand(Minute()+Hour());
   for(int z=0;z<Layers;z++)
     {
      for(int i=0;i<MAX;i++)
        {
         for(int j=0;j<MAX;j++)
           {
            if(Test==false)
              {
               GMatrix[z][i][j]=DSC(MathRand(),4)/31000-0.5;
              }
            else
              {
               GMatrix[z][i][j]=1;
              }
           }
       }
    }
  }
//+------------------------------------------------------------------+
void Calc(int num)
  {
// расчет выхода сети
   SetIO(num);
   double temp;
   for(int i=0; i<Layers-1; i++)
     {
      //Alert("i= ", i);
      //Alert(GNeuro[i+1], " ", GNeuro[i]);
      for(int j=0; j<GNeuro[i+1]; j++)
        {
         temp=0;
         for(int z=0; z<GNeuro[i]; z++)
           {
            if(i==0)
              {
               temp=temp+GMatrix[i][j][z]*Input[z];
              }
            else
              {
               temp=temp+GMatrix[i][j][z]*GOut[i-1][j];
              }
           }
         GSum[i][j]=temp; // то что входит в нейрон
         GOut[i][j]=Tang(temp);
        }
    }
  }
//+------------------------------------------------------------------+
void TestCalc(int num)
  {
   SetIO(num);
   double temp;
   for(int i=0; i<Layers-1; i++)
     {
      Alert("i= ",i);
      Alert(GNeuro[i+1]," ",GNeuro[i]);
      for(int j=0; j<GNeuro[i+1]; j++)
        {
         temp=0;
         for(int z=0; z<GNeuro[i]; z++)
           {
            if(i==0)
              {
               temp=temp+GMatrix[i][j][z]*Input[z];
              }
            else
              {
               temp=temp+GMatrix[i][j][z]*GOut[i-1][j];
              }
           }
         GSum[i][j]=temp; // то что входит в нейрон
         GOut[i][j]=GSum[i][j];
        }
    }
   PrintMatrixes();
  }
//+------------------------------------------------------------------+
void SetIO(int num)
  {
// Установка входов-выходов
// num - номер примера
   for(int i=0;i<GNeuro[0];i=i+2) // устанавливаем входы
     {
      Input[i]=sea[num-i][0]; // высота
      Input[i+1]=sea[num-i][2]; // угол
     }
// выходы сети
   if(Tutor==true) // для обучения с учителем использум 2 выхода! угол и высоту на след итерации
     {
      Output[0]=sea[num+1][0]; // высота
      Output[1]=sea[num+1][2]; // угол
     }
   if(Test==true)
     {
      for(i=0;i<GNeuro[0];i=i+2) // устанавливаем входы
        {
         Input[i]=1; // высота
         Input[i+1]=1; // угол
        }
     }
  }
//+------------------------------------------------------------------+

void Hebb()
  {
// ОБучение без учителя, по Хеббу
   int num;
   double pow,parma;
   MathSrand(TimeLocal());
   while(stab>stab_porog) // пока веса не застабилизировались
     {
      num=MathRand()%(kolvo+1);
      if(num<GNeuro[0]/2) {num=GNeuro[0]/2+1;}
      Calc(num);
      stab=0;
      // изменяем веса
      for(int i=0;i<Layers-1;i++) // цикл по количеству матриц весов
        {
         //Alert("i = ", i);
         //Alert(GNeuro[i], " ", GNeuro[i+1]);
         for(int j=0;j<GNeuro[i+1];j++)
           {
            for(int z=0;z<GNeuro[i];z++)
              {
               if(i!=0)
                 {
                  if(LEARNING_TYPE==HEBB) // Обучение по Хеббу
                    {
                     parma=Koef1*GOut[i-1][z]*GOut[i][j];
                    }
                  else if(LEARNING_TYPE==SIGNAL_HEBB) // Обучение по сигнальному методу Хебба
                    {
                    }
                  else if(LEARNING_TYPE==KOHONEN) // по правилу Кохонена
                    {
                     parma=Koef1*GOut[i-1][z]*GMatrix[i][j][z];
                    }
                  GMatrix[i][j][z]=GMatrix[i][j][z]-parma;
                 }
               else
                 {
                  if(LEARNING_TYPE==HEBB)
                    {
                     parma=Koef1*Input[z]*GOut[i][j];
                    }
                  else if(LEARNING_TYPE==SIGNAL_HEBB)
                    {
                    }
                  else if(LEARNING_TYPE==KOHONEN)
                    {
                     parma=Koef1*Input[z]*GMatrix[i][j][z];
                    }
                  GMatrix[i][j][z]=GMatrix[i][j][z]-parma;
                 }
               if(MathAbs(GMatrix[i][j][z])>3) {GMatrix[i][j][z]=DSC(MathRand(),4)/31000-0.5; Alert("Сброс связи");}
               stab=stab+MathAbs(parma); // на сколько изменились веса
              }
           }
        }
      Alert("I = ",num," stab = ",stab);
      Sleep(100);
      //Alert("num= ", num, " ", Input[0], " ", Input[1], " ", Input[2], " ", Input[3]);         
      if(Debug_Mode==true)
        {
         PrintMatrixes();
        }
     }
  }
//+------------------------------------------------------------------+
double Tang(double inp)
  {
// Расчет тангенсоиды
   double ret=(MathExp(Alpha*inp)-MathExp((-1)*Alpha*inp))/(MathExp(Alpha*inp)+MathExp((-1)*Alpha*inp));
   return(ret);
  }
//+------------------------------------------------------------------+
string DS(double a,int kol)
  {
   return(DoubleToStr(a,kol));
  }
//+------------------------------------------------------------------+
double DSC(double a,int kol)
  {
   return(StrToDouble(DS(a,kol)));
  }
//+------------------------------------------------------------------+
bool ReadParams()
  {
   string str;
   int handle=FileOpen("zigzag.csv",FILE_CSV|FILE_READ,';');
   while(!FileIsEnding(handle))
     {
      sea[count][0]=StrToDouble(FileReadString(handle));
      sea[count][1]=StrToDouble(FileReadString(handle));
      sea[count][2]=StrToDouble(FileReadString(handle));
      //Alert(sea[count][0], " || ", sea[count][1], " || ", sea[count][2]);     
      count++;
     }
   Alert("Файл с волнами прочитан, кол-во записей = ",count);
   FileClose(handle);
  }
//+------------------------------------------------------------------+
void PrintMatrixes()
  {
   int i,j,z;
   string str;
   FileWrite(debugfile,"------------------New iteration--------------------");
   for(i=0;i<Layers-1;i++)
     {
      FileWrite(debugfile," ");
      FileWrite(debugfile," Matrix # ",i);
      for(j=0;j<GNeuro[i+1];j++)
        {
         str="";
         for(z=0;z<GNeuro[i];z++)
           {
            str=str+DS(GMatrix[i][j][z],4)+";";
           }
         FileWrite(debugfile,str);
        }
     }
   FileWrite(debugfile," ");
   FileWrite(debugfile,"*** GSum ***");
// Пишем GSum
   for(i=0;i<Layers-1;i++)
     {
      str="";
      FileWrite(debugfile,"GSum # ",i);
      for(j=0;j<GNeuro[i+1];j++)
        {
         str=str+DS(GSum[i][j],4)+";";
        }
      FileWrite(debugfile,str);
      FileWrite(debugfile,"");
     }
// Пишем GOut
   FileWrite(debugfile," ");
   FileWrite(debugfile,"*** GOut ***");
   for(i=0;i<Layers-1;i++)
     {
      str="";
      FileWrite(debugfile,"GOut # ",i);
      for(j=0;j<GNeuro[i+1];j++)
        {
         str=str+DS(GOut[i][j],4)+";";
        }
      FileWrite(debugfile,str);
      FileWrite(debugfile,"");
     }
// печатаем входы

  FileWrite(debugfile," ");
   FileWrite(debugfile,"Inputs # ");
   str="";
   for(i=0;i<GNeuro[0];i++)
     {
      str=str+Input[i]+";";
     }
   FileWrite(debugfile,str);
  }
//+------------------------------------------------------------------+

void PrepareInputs()
  {
// шкалируем входы
   max2[0]=-100; max2[1]=-100; max2[2]=-100;
   for(int i=0;i<3;i++)
     {
      for(int j=0;j<count;j++)
        {
        if(MathAbs(sea[j][i])>max2[i]) {max2[i]=sea[j][i];}
        }
     }
//
   for(i=0;i<3;i++)
     {
      for(j=0;j<count;j++)
        {
         sea[j][i]=sea[j][i]/max2[i];
        }
     }
  }
//+------------------------------------------------------------------+

void PrintNewMatrixes()

  {

// выводим отмасштабированные матрицы (просто посмотреть)

//for(int)

  }
//+------------------------------------------------------------------+

void SaveNet()

  {

// функция сохранения параметров сети

  }
//+------------------------------------------------------------------+

void LoadNet()

  {

// функция загрузки параметров сети из файла (веса, количество слоев нейросети и нейронов в них)

  }

//+------------------------------------------------------------------+//+------------------------------------------------------------------+
//|                                                     Heba_koh.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
