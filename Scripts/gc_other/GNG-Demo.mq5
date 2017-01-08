//+------------------------------------------------------------------+
//|                                                          GNG.mq5 |
//|                                             Copyright 2010, alsu |
//|                                                 alsufx@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, alsu"
#property link      "alsufx@gmail.com"
#property version   "1.00"
//#property script_show_inputs

//#include <GNG/GNG.mqh>
#include <GC\gc_ann.mqh>
#include <GC\GetVectors.mqh>
#include <GC\CurrPairs.mqh> // пары
//--- количество входных векторов, используемых дл€ обучени€
input int     samples=10;
//input string AlgoStr="RSI";
//--- параметры алгоритма
input int lambda=20;
input int age_max=10;
input int ages=1;
input double alpha=0.5;
input double beta=0.0005;
input double eps_w=0.05;
input double eps_n=0.0006;
input int max_nodes=1000;
input double max_E=0.1f;

//---глобальные переменные
CGCANN *GNGAlgorithm;

int _samples;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int window;datetime time[];

   CPInit();
   window=ChartWindowFind(0,"GNG_dummy");


//--- создать экземпл€р алгоритма и установить размерность входных данных
   GNGAlgorithm=new CGCANN;
   GNGAlgorithm.debug = true;
   GNGAlgorithm.ClearTraning=true;


//--- инициализаци€ алгоритма
   if(!GNGAlgorithm.Load("GCANN"))
     {
      Print("Save template... GCANN");
      GNGAlgorithm.Save("GCANN");
      delete GNGAlgorithm;
      return;
     }
   if(0==GNGAlgorithm.num_input())
     {
      Print("Set Oracle");
      delete GNGAlgorithm;
      return;
     }

 GNGAlgorithm.ExportDataWithTest(10,10,SymbolsArray);

//GNGAlgorithm.Save("GCANN_new");  
   _samples=samples+GNGAlgorithm.num_input()*10;
   if(_samples>Bars(_Symbol,_Period)) _samples=Bars(_Symbol,_Period);

////--- возвращаем заданное пользователем значение
   _samples=_samples-GNGAlgorithm.num_input()*10;//GNGAlgorithm.Init(input_dimension,lambda,age_max,alpha,beta,eps_w,eps_n,max_nodes,max_E);
                                                 //GNGAlgorithm.Load("GCANN");
   if(window>0 && GNGAlgorithm.num_input()==2)
     {
      //--- запоминаем времена открыти€ первых 100 баров
      CopyTime(_Symbol,_Period,0,1000,time);
      //--- удал€ем с экрана все рисунки
      ObjectsDeleteAll(0,window);
      //-- рисуем пр€моугольное поле и информационные метки
      ObjectCreate(0,"GNG_rect",OBJ_RECTANGLE,window,time[0],0,time[999],100);
      ObjectSetInteger(0,"GNG_rect",OBJPROP_BACK,true);
      ObjectSetInteger(0,"GNG_rect",OBJPROP_COLOR,DarkGray);
      ObjectSetInteger(0,"GNG_rect",OBJPROP_BGCOLOR,DarkGray);

      ObjectCreate(0,"Label_neurons",OBJ_LABEL,window,0,0);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_YDISTANCE,25);
      ObjectSetInteger(0,"Label_neurons",OBJPROP_COLOR,Red);
      ObjectSetString(0,"Label_neurons",OBJPROP_TEXT,"Total neurons: 2");

      ObjectCreate(0,"Label_age",OBJ_LABEL,window,0,0);
      ObjectSetInteger(0,"Label_age",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_age",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_age",OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,"Label_age",OBJPROP_YDISTANCE,40);
      ObjectSetInteger(0,"Label_age",OBJPROP_COLOR,Red);
      ObjectSetString(0,"Label_age",OBJPROP_TEXT,"Age: 0");

      ObjectCreate(0,"Label_ae",OBJ_LABEL,window,0,0);
      ObjectSetInteger(0,"Label_ae",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_ae",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
      ObjectSetInteger(0,"Label_ae",OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,"Label_ae",OBJPROP_YDISTANCE,55);
      ObjectSetInteger(0,"Label_ae",OBJPROP_COLOR,Red);
      ObjectSetString(0,"Label_ae",OBJPROP_TEXT,"Age: 0");
      //for(i=1;i<samples;i++)
      //  {
      //   //--- заполн€ем вектор данных 
      //   if(!GetVectors(v,ov,input_dimension,1,AlgoStr,_Symbol,PERIOD_M1,i)) continue;
      //   //--- показываем вектор на графике
      //   ObjectCreate(0,"Sample_"+(string)i,OBJ_ARROW,window,time[v[0]*400+500],v[1]*45+50);
      //   ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_ARROWCODE,159);
      //   ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_COLOR,Blue);
      //   if(ov[0]>0.1) ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_COLOR,Green);
      //   if(ov[0]<-0.1) ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_COLOR,Red);
      //   ObjectSetInteger(0,"Sample_"+(string)i,OBJPROP_BACK,true);
      //  }
     }
   int ts=0,i=0;//MaxSymbols=1;
   for(int ma=0;ma<MaxSymbols;ma++)
     {
      for(i=0;i<samples;i++)
        {
         //--- передаем входной вектор алгоритму дл€ расчета
         GNGAlgorithm.forecast(SymbolsArray[ma],i,true);
//         GNGAlgorithm.forecast("EURUSD",i,true);
         ts++;
         if(samples<10||0==ts%100)Comment("Total samples: "+string(ts),"  Total neurons: "+string(GNGAlgorithm.Neurons.Total())," ME=",GNGAlgorithm.maximun_E);
        }
      if(window>0 && GNGAlgorithm.num_input()==2)
        {
         GNGAlgorithm.Draw(window,time,1000,100);
        }
      else Comment("Total samples: "+string(ts),"  Total neurons: "+string(GNGAlgorithm.Neurons.Total())," ME=",GNGAlgorithm.maximun_E);
      GNGAlgorithm.Save("GCANN");
      ChartRedraw();
     }
//}
//--- удал€ем из пам€ти экземпл€р алгоритма
   Print("Completed! Total neurons: "+string(GNGAlgorithm.Neurons.Total())+" from "+(string)ts+" samples");
//GNGAlgorithm.ini_save("GCANN");
   GNGAlgorithm.Save("GCANN");
   delete GNGAlgorithm;

//--- пауза перед очисткой графика
   while(!IsStopped())Sleep(100);

//--- удал€ем с экрана все рисунки
   ObjectsDeleteAll(0,window);
  }
//+------------------------------------------------------------------+
