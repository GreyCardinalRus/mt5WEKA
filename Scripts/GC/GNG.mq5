//+------------------------------------------------------------------+
//|                                                          GNG.mq5 |
//|                                             Copyright 2010, alsu |
//|                                                 alsufx@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, alsu"
#property link      "alsufx@gmail.com"
#property version   "1.00"
#property script_show_inputs

#include <GNG/GNG.mqh>
#include <GC\GetVectors.mqh>

//--- количество входных векторов, используемых для обучения
input int      samples=100;

//--- параметры алгоритма
input int lambda=20;
input int age_max=15;
input double alpha=0.5;
input double beta=0.0005;
input double eps_w=0.05;
input double eps_n=0.0006;
input int max_nodes=1000;
input double max_E=0.01;
double OV[];
//---глобальные переменные
CGNGUAlgorithm *GNGAlgorithm;
//CGNGAlgorithm *GNGAlgorithm;
int window;
//int rsi_handle;
int input_dimension;
int _samples;
//double RSI_buffer[];
datetime time[];
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int i,j;
   window=ChartWindowFind(0,"GNG_dummy");
   input_dimension=2;

//--- чтобы функция CopyBuffer() работала правильно, количество векторов 
//--- должно укладываться в количество баров с запасом на длину вектора 
   _samples=samples+input_dimension*10;
   if(_samples>Bars(_Symbol,_Period)) _samples=Bars(_Symbol,_Period);

////--- получаем входные данные для алгоритма
//   rsi_handle=iRSI(NULL,0,8,PRICE_CLOSE);
//   int bars=0;
//   while((bars=BarsCalculated(rsi_handle))<=0) Sleep(50);
//
//   int copied=CopyBuffer(rsi_handle,0,1,_samples,RSI_buffer);
//   if(copied<=0) PrintFormat(" Не удалось скопировать данные индикатора RSI, BarsCalculated=%d. Ошибка %d",bars,GetLastError());
//
////--- возвращаем заданное пользователем значение
   _samples=_samples-input_dimension*10;
//   PrintFormat("copied=%d     _samples=%d",copied,_samples);

//--- запоминаем времена открытия первых 100 баров
 CopyTime(_Symbol,_Period,0,1050,time);

//--- создать экземпляр алгоритма и установить размерность входных данных
   GNGAlgorithm=new CGNGUAlgorithm;
//   GNGAlgorithm=new CGNGAlgorithm;

//--- векторы данных
   double v[],v1[],v2[];
   ArrayResize(v,input_dimension);
   ArrayResize(v1,input_dimension);
   ArrayResize(v2,input_dimension);i=1;
   while(!GetVectors(v1,OV,input_dimension,0,"Easy",_Symbol,PERIOD_M1,i++));
 //  Print(i);
   while(!GetVectors(v2,OV,input_dimension,0,"Easy",_Symbol,PERIOD_M1,++i));
 //  Print(i);
//   for(i=0;i<input_dimension;i++)
//     {
//      v1[i] = RSI_buffer[i];
//      v2[i] = RSI_buffer[i+3];
//     }
//
//--- инициализация алгоритма
   GNGAlgorithm.Init(input_dimension,v1,v2,lambda,age_max,alpha,beta,eps_w,eps_n,max_nodes,max_E);
   if(window>0)
     {
      //-- рисуем прямоугольное поле и информационные метки
      ObjectCreate(0,"GNG_rect",OBJ_RECTANGLE,window,time[0],0,time[999],3);
      ObjectSetInteger(0,"GNG_rect",OBJPROP_BACK,true);
      ObjectSetInteger(0,"GNG_rect",OBJPROP_COLOR,DarkGray);
      ObjectSetInteger(0,"GNG_rect",OBJPROP_BGCOLOR,DarkGray);

      ObjectCreate(0,"Label_samples",OBJ_LABEL,window,0,0);
      ObjectSetInteger(0,"Label_samples",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_samples",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_samples",OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,"Label_samples",OBJPROP_YDISTANCE,10);
      ObjectSetInteger(0,"Label_samples",OBJPROP_COLOR,Red);
      ObjectSetString(0,"Label_samples",OBJPROP_TEXT,"Total samples: 2");

      ObjectCreate(0,"Label_neurons",OBJ_LABEL,window,0,0);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_YDISTANCE,25);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_COLOR,Red);
      ObjectSetString(0,"Label_neurons",OBJPROP_TEXT,"Total neurons: 2");
     }
//--- главный цикл агоритма начинаем с i=2 т.к. 2 векора уже использовали
   int si=i;
   for(int jjj=0;jjj<100;jjj++)
   for(i=si;i<samples;i++)
     {
      //--- заполняем вектор данных (для наглядности берем отсчеты, отстоящие
      //--- на 3 бара - они меньше скоррелированы)
      if(!GetVectors(v,OV,input_dimension,0,"Easy",_Symbol,PERIOD_M1,i+2)) continue;
      //              {
      //     for(j=0;j<input_dimension;j++)
      //       v[j]=RSI_buffer[i+j*3];

      if(window>0)
        {
         //--- показываем вектор на графике
         ObjectCreate(0,"Sample_"+(string)i,OBJ_ARROW,window,time[v[0]*400+550],v[1]*1.4+1.5);
         ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_ARROWCODE,159);
         ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_COLOR,Magenta);
         ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_BACK,true);

         //--- меняем информационную метку
         ObjectSetString(0,"Label_samples",OBJPROP_TEXT,"Total samples: "+string(i+1));
        }
      else Comment("Total samples: "+string(i+1),"  Total neurons: "+string(GNGAlgorithm.Neurons.Total())," ME=",GNGAlgorithm.maximun_E);
      //--- передаем входной вектор алгоритму для расчета
      GNGAlgorithm.ProcessVector(v);

      if(window>0)
        {
         //--- на графике необходимо удалить старые нейроны и связи, чтобы потом нарисовать новые
         for(j=ObjectsTotal(0)-1;j>=0;j--)
           {
            string name=ObjectName(0,j);
            if(StringFind(name,"Neuron_")>=0)
              {
               ObjectDelete(0,name);
              }
            else if(StringFind(name,"Connection_")>=0)
              {
               ObjectDelete(0,name);
              }
           }
        }
      double weights[];
      CGNGNeuron *tmp,*W1,*W2;
      CGNGConnection *tmpc;

      GNGAlgorithm.Neurons.FindWinners(W1,W2);

      //--- отрисовка нейронов
      tmp=GNGAlgorithm.Neurons.GetFirstNode();
      while(CheckPointer(tmp))
        {
         tmp.Weights(weights);

         if(window>0)
           {
            ObjectCreate(0,"Neuron_"+(string)tmp.uid,OBJ_ARROW,window,time[weights[0]*400+550],weights[1]*1.4+1.5);
            ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_ARROWCODE,158);

            //--- победитель цветом Lime, второй лучший Green, остальные Red
            if(tmp==W1) ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Lime);
            else if(tmp==W2) ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Green);
            else ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Red);

            ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_BACK,false);
           }
         tmp=GNGAlgorithm.Neurons.GetNextNode();
        }
      if(window>0)
        {
         ObjectSetString(0,"Label_neurons",OBJPROP_TEXT,"Total neurons: "+string(GNGAlgorithm.Neurons.Total()));
        }
      else Comment("Total samples: "+string(i+1),"  Total neurons: "+string(GNGAlgorithm.Neurons.Total())," ME=",GNGAlgorithm.maximun_E);
      //--- отрисовка связей
      tmpc=GNGAlgorithm.Connections.GetFirstNode();
      while(CheckPointer(tmpc))
        {
         double x1=0,x2,y1=0,y2;

         tmp=GNGAlgorithm.Neurons.Find(tmpc.uid1);
         if(tmp!=NULL)
           {
            tmp.Weights(weights);
            x1=(weights[0]*400+550);y1=(weights[1]*1.4+1.47);
           }
         tmp=GNGAlgorithm.Neurons.Find(tmpc.uid2);
         tmp.Weights(weights);
         x2=(weights[0]*400+550);y2=(weights[1]*1.4+1.47);

         if(window>0)
           {
            ObjectCreate(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJ_TREND,window,time[x1],y1,time[x2],y2);
            ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_WIDTH,1);
            ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_STYLE,STYLE_DOT);
            ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_COLOR,Yellow);
            ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_BACK,false);
           }
         tmpc=GNGAlgorithm.Connections.GetNextNode();
        }

      ChartRedraw();
     }

//--- удаляем из памяти экземпляр алгоритма
   Print("Completed! Total neurons: "+string(GNGAlgorithm.Neurons.Total()));
   delete GNGAlgorithm;

//--- пауза перед очисткой графика
   while(!IsStopped())Sleep(100);

//--- удаляем с экрана все рисунки
   ObjectsDeleteAll(0,window);
  }
//+------------------------------------------------------------------+
