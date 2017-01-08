//+------------------------------------------------------------------+
//|                                                    my_oop_ea.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
// Включаем наш класс
#include <my_expert_class.mqh>
//--- входные параметры
input int      StopLoss=30;      // Stop Loss
input int      TakeProfit=100;   // Take Profit
input int      ADX_Period=14;    // Период индикатора ADX
input int      MA_Period=10;     // Период индикатора Moving Average
input int      EA_Magic=12345;   // Magic Number советника
input double   Adx_Min=22.0;     // Минимальное значение ADX
input double   Lot=0.2;          // Количество лотов для торговли
input int      Margin_Chk=0;     // Нужно ли проверять размер маржи перед помещением ордера (0=Нет, 1=Да)
input double   Trd_percent=15.0; // Процент маржи, используемый в торговле
//--- Другие параметры
int STP,TKP;   // Будут использоваться для значений Stop Loss и Take Profit
// Объект нашего класса 
MyExpert Cexpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- проверка наличия необходимого количества баров для работы
   if(Bars(_Symbol,_Period)<60) // если общее количество баров менее 60
     {
      Alert("У нас менее 60 баров, советник закончит работу!!");
      return(1);
     }
//--- запуск функции инициализации
   Cexpert.doInit(ADX_Period,MA_Period);
//--- установка всех необходимых переменных для нашего объекта класса
   Cexpert.setPeriod(_Period);    // задает период
   Cexpert.setSymbol(_Symbol);    // задает символ (валютную пару)
   Cexpert.setMagic(EA_Magic);    // задает Magic Number
   Cexpert.setadxmin(Adx_Min);    // устанавливаем минимальное значение ADX
   Cexpert.setLOTS(Lot);          // задаем кол-во лотов
   Cexpert.setchkMAG(Margin_Chk); // задаем флаг проверки маржи
   Cexpert.setTRpct(Trd_percent); // задаем минимальный процент необходимой свободной маржи
//--- Включаем поддержку брокеров в 5 знаками
   STP = StopLoss;
   TKP = TakeProfit;
   if(_Digits==5 || _Digits==3)
     {
      STP = STP*10;
      TKP = TKP*10;
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Вызываем функцию деинициализации
   Cexpert.doUninit();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Имеем ли мы достаточное количество баров для работы
   int Mybars=Bars(_Symbol,_Period);
   if(Mybars<60) // если общее количество баров меньше 60
     {
      Alert("У нас меньше 60 баров, советник не будет работать!!");
      return;
     }

//--- задаем некоторые структуры MQL5, которые будут использоваться в нашей торговле
   MqlTick latest_price;      // будет использоваться для получения текущих/последних котировок цены
   MqlRates mrate[];          // будет использоваться для хранения цен, объемов и спредов для каждого из баров
/*
     Сделаем так, чтобы значения, которые мы будем использовать для массивов котировок
     имели индексацию как в таймсерии
*/
// для массива котировок
   ArraySetAsSeries(mrate,true);
//--- Получаем последнюю цену котировки, используя структуру MqlTick 
   if(!SymbolInfoTick(_Symbol,latest_price))
     {
      Alert("Ошибка получения последней цены котировки - ошибка:",GetLastError(),"!!");
      return;
     }

//--- Получим данные по последним трем барам 
   if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
     {
      Alert("Ошибка копирования котировок/исторических данных - ошибка:",GetLastError(),"!!");
      return;
     }

//--- советник должен проверять условия торговли только в случае начала нового бара
// объявим static-переменную типа datetime
   static datetime Prev_time;
// получим время начала текущего бара (бар 0)
   datetime Bar_time[1];
// копируем время
   Bar_time[0] = mrate[0].time;
// если оба времени равны, у нас нет нового бара
   if(Prev_time==Bar_time[0])
     {
      return;
     }
// скопируем время в статическую переменную (сохраняем значение)
   Prev_time = Bar_time[0]; 


//--- ошибок нет, продолжаем
//--- есть ли у нас уже открытые позиции?
   bool Buy_opened=false,Sell_opened=false; // переменные для хранения результата проверки наличия открытых позиций

   if(PositionSelect(_Symbol)==true) // у нас есть открытая позиция по текущему символу
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened=true;  // Это длинная позиция
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened=true; // Это короткая позиция
        }
     }
// Скопируем цену закрытия предыдущего бара (бар 1) в соответствующую переменную эксперта
   Cexpert.setCloseprice(mrate[1].close);  // цена закрытия бара 1
//--- Проверка наличия позиции на покупку
   if(Cexpert.checkBuy()==true)
     {
      // есть ли открытая позиция на покупку?
      if(Buy_opened)
        {
         Alert("У нас уже есть позиция на покупку!!!"); 
         return;    // Не добавляем к длинной позиции
        }
      double aprice = NormalizeDouble(latest_price.ask,_Digits);
      double stl    = NormalizeDouble(latest_price.ask - STP*_Point,_Digits);
      double tkp    = NormalizeDouble(latest_price.ask + TKP*_Point,_Digits);
      int    mdev   = 100;
      // размещаем ордер
      Cexpert.openBuy(ORDER_TYPE_BUY,aprice,stl,tkp,mdev);
     }
//--- Проверка наличия позиции на продажуn
   if(Cexpert.checkSell()==true)
     {
      // есть ли открытая позиция на продажу?
      if(Sell_opened)
        {
         Alert("У нас уже есть открытая позиция на продажу!!!"); 
         return;    //Не добавляем к короткой позиции
        }
      double bprice=NormalizeDouble(latest_price.bid,_Digits);
      double bstl    = NormalizeDouble(latest_price.bid + STP*_Point,_Digits);
      double btkp    = NormalizeDouble(latest_price.bid - TKP*_Point,_Digits);
      int    bdev=100;
      // размещаем ордер
      Cexpert.openSell(ORDER_TYPE_SELL,bprice,bstl,btkp,bdev);
     }

   return;
  }
//+------------------------------------------------------------------+
