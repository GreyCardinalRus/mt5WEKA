//+------------------------------------------------------------------+
//|                                           macd-neuro-example.mq5 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>        //подключаем библиотеку для совершения торговых операций
#include <Trade\PositionInfo.mqh> //подключаем библиотеку для получения информации о позициях
//--- значения весовых коэффициентов                                                                    
input double w0=0.5;
input double w1=0.5;
input double w2=0.5;
input double w3=0.5;
input double w4=0.5;
input double w5=0.5;
input double w6=0.5;
input double w7=0.5;
input double w8=0.5;
input double w9=0.5;
input double w10=0.5;
input double w11=0.5;
input double w12=0.5;
input double w13=0.5;
input double w14=0.5;
input double w15=0.5;
input double w16=0.5;
input double w17=0.5;
input double w18=0.5;
input double w19=0.5;

int               iMACD_handle;      // переменная для хранения хендла индикатора
double            iMACD_mainbuf[];   // динамический массив для хранения значений индикатора
double            iMACD_signalbuf[]; // динамический массив для хранения значений индикатора

double            inputs[20];        // массив для хранения входных сигналов
double            weight[20];        // массив для хранения весовых коэффициентов

string            my_symbol;         // переменная для хранения символа
ENUM_TIMEFRAMES   my_timeframe;      // переменная для хранения таймфрейма
double            lot_size;          // переменная для хранения минимального объема совершаемой сделки

double            out;               // переменная для хранения выходного значения нейрона

CTrade            m_Trade;           // объект для выполнения торговых операций
CPositionInfo     m_Position;        // объект для получения информации о позициях
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- сохраним текущий символ графика для дальнейшей работы советника именно на этом символе
   my_symbol=Symbol();
//--- сохраним текущий период графика для дальнейшей работы советника именно на этом периоде
   my_timeframe=PERIOD_CURRENT;
//--- сохраним минимальный объем совершаемой сделки
   lot_size=SymbolInfoDouble(my_symbol,SYMBOL_VOLUME_MIN);
//--- подключаем индикатор и получаем его хендл
   iMACD_handle=iMACD(my_symbol,my_timeframe,48,36,19,PRICE_CLOSE);
//--- проверяем наличие хендла индикатора
   if(iMACD_handle==INVALID_HANDLE)
     {
      //--- хендл не получен, выводим сообщение в лог об ошибке, завершаем работу с ошибкой
      Print("Не удалось получить хендл индикатора");
      return(-1);
     }
//--- добавляем индикатор на ценовой график
   ChartIndicatorAdd(ChartID(),0,iMACD_handle);
//--- устанавливаем индексация для массива iMACD_mainbuf как в таймсерии
   ArraySetAsSeries(iMACD_mainbuf,true);
//--- устанавливаем индексация для массива iMACD_signalbuf как в таймсерии
   ArraySetAsSeries(iMACD_signalbuf,true);
//--- переносим весовые коэффициенты в массив
   weight[0]=w0;
   weight[1]=w1;
   weight[2]=w2;
   weight[3]=w3;
   weight[4]=w4;
   weight[5]=w5;
   weight[6]=w6;
   weight[7]=w7;
   weight[8]=w8;
   weight[9]=w9;
   weight[10]=w10;
   weight[11]=w11;
   weight[12]=w12;
   weight[13]=w13;
   weight[14]=w14;
   weight[15]=w15;
   weight[16]=w16;
   weight[17]=w17;
   weight[18]=w18;
   weight[19]=w19;
//--- возвращаем 0, инициализация завершена
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- удаляем хэндл индикатора и освобождаем занимаемую им память
   IndicatorRelease(iMACD_handle);
//--- освобождаем динамический массив iMACD_mainbuf от данных
   ArrayFree(iMACD_mainbuf);
//--- освобождаем динамический массив iMACD_signalbuf от данных
   ArrayFree(iMACD_signalbuf);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int err1=0; // переменная для хранения результатов работы с основным буфером индикатора MACD
   int err2=0; // переменная для хранения результатов работы с сигнальным буфером индикатора MACD

//--- копируем данные из индикаторного массива в динамический массив iMACD_mainbuf для дальнейшей работы с ними
   err1=CopyBuffer(iMACD_handle,0,2,ArraySize(inputs)/2,iMACD_mainbuf);
//--- копируем данные из индикаторного массива в динамический массив iMACD_signalbuf для дальнейшей работы с ними
   err2=CopyBuffer(iMACD_handle,1,2,ArraySize(inputs)/2,iMACD_signalbuf);
//--- если есть ошибки, то выводим сообщение в лог об ошибке и выходим из функции
   if(err1<0 || err2<0)
     {
      Print("Не удалось скопировать данные из индикаторного буфера");
      return;
     }

   double d1=-1.0; //нижняя граница интервала для нормализации значений
   double d2=1.0;  //верхняя граница интервала для нормализации значений
//--- минимальное значение на интервале
   double x_min=MathMin(iMACD_mainbuf[ArrayMinimum(iMACD_mainbuf)],iMACD_signalbuf[ArrayMinimum(iMACD_signalbuf)]);
//--- максимальное значение на интервале
   double x_max=MathMax(iMACD_mainbuf[ArrayMaximum(iMACD_mainbuf)],iMACD_signalbuf[ArrayMaximum(iMACD_signalbuf)]);
//--- В цикле заполняем массив входов значениями индикатора с предварительной нормализацией
   for(int i=0;i<ArraySize(inputs)/2;i++)
     {
      inputs[i*2]=(((iMACD_mainbuf[i]-x_min)*(d2-d1))/(x_max-x_min))+d1;
      inputs[i*2+1]=(((iMACD_signalbuf[i]-x_min)*(d2-d1))/(x_max-x_min))+d1;
     }
//--- записываем результат вычисления нейрона в переменную out
   out=CalculateNeuron(inputs,weight);
//--- если значение выхода нейрона меньше 0
   if(out<0)
     {
      //--- если уже существует позиция по этому символу
      if(m_Position.Select(my_symbol))
        {
         //--- и тип этой позиции Sell, то закрываем ее
         if(m_Position.PositionType()==POSITION_TYPE_SELL) m_Trade.PositionClose(my_symbol);
         //--- а если тип этой позиции Buy, то выходим
         if(m_Position.PositionType()==POSITION_TYPE_BUY) return;
        }
      //--- если дошли сюда, значит позиции нет, открываем ее
      m_Trade.Buy(lot_size,my_symbol);
     }
//--- если значение выхода нейрона больше или равно 0
   if(out>=0)
     {
      //--- если уже существует позиция по этому символу
      if(m_Position.Select(my_symbol))
        {
         //--- и тип этой позиции Buy, то закрываем ее
         if(m_Position.PositionType()==POSITION_TYPE_BUY) m_Trade.PositionClose(my_symbol);
         //--- а если тип этой позиции Sell, то выходим
         if(m_Position.PositionType()==POSITION_TYPE_SELL) return;
        }
      //--- если дошли сюда, значит позиции нет, открываем ее
      m_Trade.Sell(lot_size,my_symbol);
     }
  }
//+------------------------------------------------------------------+
//|   Функция вычисления нейрона                                     |
//+------------------------------------------------------------------+
double CalculateNeuron(double &x[],double &w[])
  {
//--- переменная для хранения средневзвешенной суммы входных сигналов
   double NET=0.0;
//--- в цикле по количеству входов получаем средневзвешенную сумму входов
   for(int n=0;n<ArraySize(x);n++)
     {
      NET+=x[n]*w[n];
     }
//--- умножаем средневзвешенную сумму входов на добавочный коэффициент
   NET*=0.1;
//--- передаем средневзвешенную сумму входов в функцию активации и возвращаем ее значение
   return(ActivateNeuron(NET));
  }
//+------------------------------------------------------------------+
//|   Функция активации нейрона                                      |
//+------------------------------------------------------------------+
double ActivateNeuron(double x)
  {
//--- переменная для хранения результата функции активации
   double Out;
//--- функция гиперболического тангенса
   Out=(exp(x)-exp(-x))/(exp(x)+exp(-x));
//--- возвращаем значение функции активации
   return(Out);
  }
//+------------------------------------------------------------------+
