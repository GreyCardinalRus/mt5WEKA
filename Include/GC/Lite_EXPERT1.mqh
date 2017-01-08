//Version  January 31, 2008
//+==================================================================+
//|                                                 Lite_EXPERT1.mqh |
//|                             Copyright © 2008,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+==================================================================+
//---- Объявление глобальной переменной для запоминания 
                            //времени последнего обращения к серверу
int LastTime; 
//+==================================================================+
//| OpenBuyOrder1()                                                  |
//+==================================================================+
bool OpenBuyOrder1
        (bool& BUY_Signal, int MagicNumber, string Name_Order,
                double Money_Management, int STOPLOSS, int TAKEPROFIT)
 {
//----+
  if (!BUY_Signal)
           return(true); 
  //---- Проверка на истечение минимального интервала времени 
                                    //между двумя торговыми операциями         
  if (TimeCurrent() - LastTime < 11)
                          return(true); 
  int total = OrdersTotal();
  //---- Проверка на наличие открытой позиции 
          //с магическим числом равным значению переменной MagicNumber
  for(int ttt = total - 1; ttt >= 0; ttt--)     
      if (OrderSelect(ttt, SELECT_BY_POS, MODE_TRADES))
                      if (OrderMagicNumber() == MagicNumber)
                                                      return(true); 
  string OpderPrice, Symb = Symbol(); 
  int    ticket, StLOSS, TkPROFIT;
  double LOTSTEP, MINLOT, MAXLOT, MARGINREQUIRED;
  double FreeMargin, LotVel, Lot, ask, Stoploss, TakeProfit;                                                 
                                                      
  //----+ расчёт величины лота для открывания позиции
  LOTSTEP = MarketInfo(Symb, MODE_LOTSTEP);
  if (LOTSTEP <= 0)
              return(false);
  if (Money_Management > 0)
    {        
      MARGINREQUIRED = MarketInfo(Symb, MODE_MARGINREQUIRED);
      if (MARGINREQUIRED == 0.0)
                    return(false);
                    
      LotVel = GetFreeMargin()
               * Money_Management / MARGINREQUIRED;         
    }
  else 
    LotVel = MathAbs(Money_Management);
  //---- нормирование величины лота до ближайшего стандартного значения 
  Lot = LOTSTEP * MathFloor(LotVel / LOTSTEP);  
  
  //----+ проверка лота на минимальное допустимое значение
  MINLOT = MarketInfo(Symb, MODE_MINLOT);
  if (MINLOT < 0)
         return(false);
  if (Lot < MINLOT)
          return(true);
          
  //----+ проверка лота на максимальное допустимое значение
  MAXLOT = MarketInfo(Symb, MODE_MAXLOT);
  if (MAXLOT < 0)
         return(false);
  if (Lot > MAXLOT)
          Lot = MAXLOT;
          
  //----+ проверка величины лота на достаточность средств на счёте   
  if (!MarginCheck(Symb, OP_BUY, Lot))
                               return(false);
  if (Lot < MINLOT)
          return(true);
  //----
  ask = NormalizeDouble(Ask, Digits);
  if (ask == 0.0)
          return(false);
  //----             
  StLOSS = StopCorrect(Symb, STOPLOSS);
  if (StLOSS < 0)
          return(false);   
  //----
  Stoploss = NormalizeDouble(ask - StLOSS * Point, Digits);
  if (Stoploss < 0)
         return(false);
  //----       
  TkPROFIT = StopCorrect(Symb, TAKEPROFIT);
  if (TkPROFIT < 0)
          return(false);  
  //----               
  TakeProfit = NormalizeDouble(ask + TkPROFIT * Point, Digits);
  if (TakeProfit < 0)
         return(false);
  
  Print(StringConcatenate
         ("Открываем по ", Symb,
                       " позицию на покупку с магическим числом ", MagicNumber));
  //----+ Открываем позицию на покупку    
  ticket=OrderSend(Symb, OP_BUY, Lot, ask, 3, 
            Stoploss, TakeProfit, Name_Order, MagicNumber, 0, Blue); 
  
  //----
  if(ticket>0)
     if (OrderSelect(ticket, SELECT_BY_TICKET))
       {
         BUY_Signal = false;
         OpderPrice = DoubleToStr(OrderOpenPrice(), Digits);  
         Print(StringConcatenate(Symb, " BUY ордер с тикетом №",
                      ticket, " и магическим числом ", OrderMagicNumber(), 
                                                     " открыт по цене ",OpderPrice));
         //----
         LastTime = TimeCurrent();
         return(true);
       }
     else
       {
         Print(StringConcatenate("Не удалось окрыть ", Symb, 
                            " BUY ордер с магическим числом ", MagicNumber, "!!!"));
         LastTime = TimeCurrent();
         return(true);
       }
  return(true);
//----+
 }
//+==================================================================+
//| OpenSellOrder1()                                                 |
//+==================================================================+
bool OpenSellOrder1
        (bool& SELL_Signal, int MagicNumber, string Name_Order,
                double Money_Management, int STOPLOSS, int TAKEPROFIT)
 {
//----+
  if (!SELL_Signal)
           return(true); 
  //---- Проверка на истечение минимального интервала времени 
                                    //между двумя торговыми операциями         
  if (TimeCurrent() - LastTime < 11)
                          return(true); 
  int total = OrdersTotal();
  //---- Проверка на наличие открытой позиции 
          //с магическим числом равным значению переменной MagicNumber
  for(int ttt = total - 1; ttt >= 0; ttt--)     
      if (OrderSelect(ttt, SELECT_BY_POS, MODE_TRADES))
                      if (OrderMagicNumber() == MagicNumber)
                                                      return(true); 
  string OpderPrice, Symb = Symbol(); 
  int    SPREAD, ticket, StLOSS, TkPROFIT;
  double LOTSTEP, MINLOT, MAXLOT, MARGINREQUIRED, TICKSIZE;
  double LotVel, Lot, bid, Stoploss, TakeProfit, TICKVALUE;                                                 
                                                      
  //----+ расчёт величины лота для открывания позиции
  if (Money_Management > 0)
    {        
      MARGINREQUIRED = MarketInfo(Symb, MODE_MARGINREQUIRED);
      if (MARGINREQUIRED == 0.0)
                    return(false); 
      SPREAD = MarketInfo(Symb, MODE_SPREAD);
      if (SPREAD == 0)
                    return(false);
                    
      TICKVALUE = MarketInfo(Symb, MODE_TICKVALUE);
      if (TICKVALUE == 0)
                    return(false);
                    
      TICKSIZE = MarketInfo(Symb, MODE_TICKSIZE);
      if (TICKSIZE == 0)
                    return(false);                                                
                           
      LotVel = GetFreeMargin() * Money_Management / 
                    (MARGINREQUIRED - (SPREAD * TICKVALUE));    
                        
      LOTSTEP = MarketInfo(Symb, MODE_LOTSTEP); 
      if (LOTSTEP <= 0)
                  return(false);
    }
  else 
    LotVel = MathAbs(Money_Management);
  //---- нормирование величины лота до ближайшего стандартного значения   
  Lot = LOTSTEP * MathFloor(LotVel / LOTSTEP);
  
  //----+ проверка лота на минимальное допустимое значение
  MINLOT = MarketInfo(Symb, MODE_MINLOT);
  if (MINLOT < 0)
         return(false);
  if (Lot < MINLOT)
          return(true);
          
  //----+ проверка лота на максимальное допустимое значение
  MAXLOT = MarketInfo(Symb, MODE_MAXLOT);
  if (MAXLOT < 0)
         return(false);
  if (Lot > MAXLOT)
          Lot = MAXLOT;
          
  //----+ проверка величины лота на достаточность средств на счёте   
  if (!MarginCheck(Symb, OP_SELL, Lot))
                                  return(false);
  if (Lot < MINLOT)
          return(true);
  //----
  bid = NormalizeDouble(Bid, Digits);
  if (bid == 0.0)
          return(false);
  //----             
  StLOSS = StopCorrect(Symb, STOPLOSS);
  if (StLOSS < 0)
          return(false);   
  //----
  Stoploss = NormalizeDouble(bid + StLOSS * Point, Digits);
  if (Stoploss < 0)
         return(false);
  //----       
  TkPROFIT = StopCorrect(Symb, TAKEPROFIT);
  if (TkPROFIT < 0)
          return(false);  
  //----      
  TakeProfit = NormalizeDouble(bid - TkPROFIT * Point, Digits);
  if (TakeProfit < 0)
         return(false);
  
  Print(StringConcatenate
         ("Открываем по ", Symb,
                       " позицию на продажу с магическим числом ", MagicNumber));    
  //----+ Открываем позицию на продажу    
  ticket=OrderSend(Symb, OP_SELL, Lot, bid, 3, 
            Stoploss, TakeProfit, Name_Order, MagicNumber, 0, Red); 
  
  
  //----
  if(ticket>0)
     if (OrderSelect(ticket, SELECT_BY_TICKET))
       {
         SELL_Signal = false;
         OpderPrice = DoubleToStr(OrderOpenPrice(), Digits);  
         Print(StringConcatenate(Symb, " SELL ордер с тикетом №",
                                 ticket, " и магическим числом ", OrderMagicNumber(), 
                                                     " открыт по цене ",OpderPrice));
         //----
         LastTime = TimeCurrent();
         return(true);
       }
     else
       {
         Print(StringConcatenate("Не удалось окрыть ", Symb, 
                            " SELL ордер с магическим числом ", MagicNumber, "!!!"));
         LastTime = TimeCurrent();
         return(true);
       }
  return(true);
//----+  
 }   
//+==================================================================+
//| GetFreeMargin() function                                         |
//+==================================================================+
double GetFreeMargin()
  {
//----+
   switch(AccountFreeMarginMode())
       {
        
        case 0: return(AccountFreeMargin() + AccountProfit());
        case 1: return(AccountFreeMargin());
        case 2: if (AccountProfit() > 0) 
                  return(AccountFreeMargin());
                else
                  return(AccountFreeMargin() - AccountProfit());
        case 3: if (AccountProfit() < 0) 
                  return(AccountFreeMargin());
                else
                  return(AccountFreeMargin() - AccountProfit());
       }
//----+
  } 
//+==================================================================+
//| StopCorrect() function                                           |
//+==================================================================+
int StopCorrect(string symbol, int Stop)
  {
//----+
   int CorrStop, Extrem_Stop;
   
   Extrem_Stop = MarketInfo(symbol, MODE_STOPLEVEL);
   if(Extrem_Stop <= 0)
                return(-1);
                
   if(Stop < Extrem_Stop)
               CorrStop = Extrem_Stop;
   else 
      CorrStop = Stop;
      
   return(CorrStop);
//----+
  } 
//+==================================================================+
//| MarginCheck() function                                           |
//+==================================================================+ 
bool MarginCheck(string symbol, int Cmd, double& Lot) 
 {
//----+
   int  Margin_Check;
   
   double MINLOT = MarketInfo(symbol, MODE_MINLOT);
   if (MINLOT < 0)
              return(false);
              
   double LOTSTEP = MarketInfo(symbol, MODE_LOTSTEP);
   if (LOTSTEP < 0)
              return(false);
              
   Lot = LOTSTEP * MathFloor(Lot / LOTSTEP); 
   
   while(Lot >= MINLOT && Margin_Check <= 0)
          {
            Margin_Check =
              AccountFreeMarginCheck(symbol, Cmd, Lot);
                      
            if (Margin_Check < 0)
                          Lot -= LOTSTEP; 
                          
            if (Lot < MINLOT)
                        return(true);
          }
            
  return(true);
//----+
 }  
//+==================================================================+
//| CloseOrder1() function                                           |
//+==================================================================+

bool CloseOrder1(bool& CloseStop, int MagicNumber)
  {
//----+
   //---- проверка на истечение десятисекундного интервала времени
   if (!CloseStop)
          return(true);
     if (TimeCurrent() - LastTime < 11)
                                   return(true);
   //----                
   int total=OrdersTotal(); 
   if (total==0)return(true);
   //----
   color  Order_Color;
   string ClosePrice, Symb, Order_Type;
   double priceClose;
   int    ticket,DIGITS; 
   
   //---- поиск открытой позиции с нужным магическим числом
   for(int pos=total-1;pos>=0;pos--)                                                                 
     {
      if (OrderSelect(pos, SELECT_BY_POS))
         if (OrderMagicNumber() == MagicNumber)
                                if (OrderType() < 2)
                                                 break;
      if (pos == 0)
               return(true);
     }

   ticket = OrderTicket(); 
   Symb = OrderSymbol();
   
   DIGITS = MarketInfo(OrderSymbol(), MODE_DIGITS); 
   if (DIGITS == 0)
             return(false);
   
   //----+ Получение значений для удаления ордера
   switch(OrderType())
     {
      
      case OP_BUY:
       {
         priceClose = MarketInfo(Symb, MODE_BID);
         if (priceClose == 0)
                    return(false);
         Order_Type =" BUY";
         Order_Color = Red;
         break;
       }
      //----   
      case OP_SELL:
       {
         priceClose = MarketInfo(Symb, MODE_ASK);
         if (priceClose == 0)
                    return(false);
         Order_Type =" SELL";
         Order_Color = Lime;
         break;
       }
      default : 
         return(true);
     }
   
   //----+  Закрываем открытую позицию                                 
   Print(StringConcatenate("Закрываем на ", pos,
        " позиции ", Symb, Order_Type, " ордер с тикетом №", ticket,
                                   " и магическим числом ", MagicNumber));
                                            
   if(OrderClose(ticket, OrderLots(), priceClose, 3, Order_Color))
     {
       CloseStop = false;
       ClosePrice = DoubleToStr(OrderClosePrice(), DIGITS);  
       Print(StringConcatenate(Symb, Order_Type, " ордер с тикетом №",
                       ticket, " и магическим числом ", OrderMagicNumber(), 
                                             " закрыт по цене ", ClosePrice));
       LastTime = TimeCurrent();
                       return(true);
     }
   else 
     {
       Print(StringConcatenate("Не удалось закрыть ", Symb, 
          Order_Type," ордер с тикетом №", ticket, " и магическим числом ", 
                                                         MagicNumber, "!!!"));
       LastTime = TimeCurrent();
       return(true);
     }
    //----   
   return(true);
//----+
  }       
//+==================================================================+
//| DeleteOrder1() function                                          |
//+==================================================================+

bool DeleteOrder1(bool& CloseStop, int MagicNumber)
  {
//----+
   //---- проверка на истечение десятисекундного интервала времени
   if (!CloseStop)
          return(true);
     if (TimeCurrent() - LastTime < 11)
                                   return(true);
   //----                
   int total=OrdersTotal(); 
   if (total==0)return(true);
   //----
   string Order_Type;
   int    ticket;                         
   //----
   //---- поиск отложенных ордеров с нужным магическим числом
   for(int pos = total - 1; pos >= 0; pos--)                                                                 
     {
      if (OrderSelect(pos, SELECT_BY_POS))
         if (OrderMagicNumber() == MagicNumber)
                                if (OrderType() > 1)
                                                 break;
      if (pos == 0)
               return(true);
     }
   
   ticket = OrderTicket(); 
   //----         
   switch(OrderType())
     {
       case OP_BUYLIMIT:  
                  Order_Type = 
                    " отложенный ордер BUY LIMIT";   
                                               break;
       case OP_SELLLIMIT: 
                  Order_Type = 
                   " отложенный ордер SELLL LIMIT"; 
                                               break;
       case OP_BUYSTOP:   
                  Order_Type = 
                      " отложенный ордер BUY STOP";
                                               break;
       case OP_SELLSTOP: 
                  Order_Type = 
                     " отложенный ордер SELL STOP";
                                               break;
       default : 
         return(true);
     }
                                    
   Print(StringConcatenate("Закрываем на ", pos, " позиции ",
               OrderSymbol(), Order_Type, " с тикетом №", ticket,
                              " и магическим числом ", MagicNumber));
                                            
   if (OrderDelete(ticket, CLR_NONE)) 
     {
       CloseStop = false;
       Print(StringConcatenate(OrderSymbol(), Order_Type, 
               " с тикетом №", ticket, " и магическим числом ", 
                                      OrderMagicNumber(), " закрыт"));
       LastTime = TimeCurrent();
       return(true);
     }
   else 
     {
       Print(StringConcatenate("Не удалось закрыть ", 
           OrderSymbol(), Order_Type, " с тикетом №", ticket, 
                        " и магическим числом ", MagicNumber, "!!!"));
       LastTime = TimeCurrent();
       return(true);
     }
   //----   
   return(true);
//----+
  }  
//+==================================================================+
//| OpenBuyLimitOrder1()                                             |
//+==================================================================+
bool OpenBuyLimitOrder1
        (bool& Order_Signal, int MagicNumber, 
           double Money_Management, int STOPLOSS, int TAKEPROFIT,
                                      int LEVEL, datetime Expiration)
 {
//----+
  if (!Order_Signal)
              return(true); 
  //---- Проверка на истечение минимального интервала времени 
                                    //между двумя торговыми операциями         
  if (TimeCurrent() - LastTime < 11)
                          return(true); 
  int total = OrdersTotal();
  //---- Проверка на наличие открытой позиции 
          //с магическим числом равным значению переменной MagicNumber
  for(int ttt = total - 1; ttt >= 0; ttt--)     
      if (OrderSelect(ttt, SELECT_BY_POS, MODE_TRADES))
                      if (OrderMagicNumber() == MagicNumber)
                                                      return(true); 
  string Symb = Symbol(), OpderPrice; 
  int    ticket, StLOSS, TkPROFIT, Level;
  double LOTSTEP, MINLOT, MAXLOT, MARGINREQUIRED;
  double FreeMargin, LotVel, Lot, OpenPrice, Stoploss, TakeProfit;                                                 
                                                      
  //----+ расчёт величины лота для открывания позиции
  
  LOTSTEP = MarketInfo(Symb, MODE_LOTSTEP);
  if (LOTSTEP <= 0)
              return(false);
  if (Money_Management > 0)
    {        
      MARGINREQUIRED = MarketInfo(Symb, MODE_MARGINREQUIRED);
      if (MARGINREQUIRED == 0.0)
                         return(false);
                    
      LotVel = GetFreeMargin()
               * Money_Management / MARGINREQUIRED;         
    }
  else 
    LotVel = MathAbs(Money_Management);
  //---- нормирование величины лота до ближайшего стандартного значения  
  Lot = LOTSTEP * MathFloor(LotVel / LOTSTEP);
  
  //----+ проверка лота на минимальное допустимое значение
  MINLOT = MarketInfo(Symb, MODE_MINLOT);
  if (MINLOT < 0)
         return(false);
  if (Lot < MINLOT)
          return(true);
          
  //----+ проверка лота на максимальное допустимое значение
  MAXLOT = MarketInfo(Symb, MODE_MAXLOT);
  if (MAXLOT < 0)
         return(false);
  if (Lot > MAXLOT)
          Lot = MAXLOT;
          
  Level = StopCorrect(Symb, LEVEL);
  //----
  OpenPrice = NormalizeDouble(Ask - Level * Point, Digits);
  if (OpenPrice == 0.0)
               return(false);
  //----             
  StLOSS = StopCorrect(Symb, STOPLOSS);
  if (StLOSS < 0)
          return(false);   
  //----
  Stoploss = NormalizeDouble(OpenPrice - StLOSS * Point, Digits);
  if (Stoploss < 0)
         return(false);
  //----       
  TkPROFIT = StopCorrect(Symb, TAKEPROFIT);
  if (TkPROFIT < 0)
          return(false);  
  //----               
  TakeProfit = NormalizeDouble(OpenPrice + TkPROFIT * Point, Digits);
  if (TakeProfit < 0)
         return(false);
  
  Print(StringConcatenate
         ("Выставляем по ", Symb,
                  " отложенный BUY LIMIT ордер с магическим числом ", MagicNumber));
  //----+ Открываем позицию на покупку    
  ticket = OrderSend(Symb, OP_BUYLIMIT, Lot, OpenPrice, 0, 
            Stoploss, TakeProfit, NULL, MagicNumber, Expiration, Blue); 
  
  //----
  if(ticket > 0)
     if (OrderSelect(ticket, SELECT_BY_TICKET))
       {
         Order_Signal = false;
         OpderPrice = DoubleToStr(OrderOpenPrice(), Digits);
         Print(StringConcatenate("Отложенный BUY LIMIT ",Symb, 
           " ордер с тикетом №",  ticket, " и магическим числом ", 
                OrderMagicNumber(), " выставлен. Цена срабатывания ордера ",OpderPrice,
                              ". Расчитанная цена была ", DoubleToStr(OpenPrice, Digits)));
         //----
         LastTime = TimeCurrent();
         return(true);
       }
     else
       {
         Print(StringConcatenate("Не удалось выставить отложенный BUY LIMIT ", Symb, 
                                   " ордер с магическим числом ", MagicNumber, "!!!"));
         LastTime = TimeCurrent();
         return(true);
       }
  return(true);
//----+
 }
//+==================================================================+
//| OpenBuyStopOrder1()                                              |
//+==================================================================+
bool OpenBuyStopOrder1
        (bool& Order_Signal, int MagicNumber, 
           double Money_Management, int STOPLOSS, int TAKEPROFIT,
                                      int LEVEL, datetime Expiration)
 {
//----+
  if (!Order_Signal)
             return(true); 
  //---- Проверка на истечение минимального интервала времени 
                                    //между двумя торговыми операциями         
  if (TimeCurrent() - LastTime < 11)
                          return(true); 
  int total = OrdersTotal();
  //---- Проверка на наличие открытой позиции 
          //с магическим числом равным значению переменной MagicNumber
  for(int ttt = total - 1; ttt >= 0; ttt--)     
      if (OrderSelect(ttt, SELECT_BY_POS, MODE_TRADES))
                      if (OrderMagicNumber() == MagicNumber)
                                                      return(true); 
  string Symb = Symbol(), OpderPrice; 
  int    ticket, StLOSS, TkPROFIT, Level;
  double LOTSTEP, MINLOT, MAXLOT, MARGINREQUIRED;
  double FreeMargin, LotVel, Lot, OpenPrice, Stoploss, TakeProfit;                                                 
                                                      
  //----+ расчёт величины лота для открывания позиции
  
  LOTSTEP = MarketInfo(Symb, MODE_LOTSTEP);
  if (LOTSTEP <= 0)
              return(false);
  if (Money_Management > 0)
    {        
      MARGINREQUIRED = MarketInfo(Symb, MODE_MARGINREQUIRED);
      if (MARGINREQUIRED == 0.0)
                    return(false);
                    
      LotVel = GetFreeMargin()
               * Money_Management / MARGINREQUIRED;         
    }
  else 
    LotVel = MathAbs(Money_Management);
  //---- нормирование величины лота до ближайшего стандартного значения  
  Lot = LOTSTEP * MathFloor(LotVel / LOTSTEP);
  
  //----+ проверка лота на минимальное допустимое значение
  MINLOT = MarketInfo(Symb, MODE_MINLOT);
  if (MINLOT < 0)
         return(false);
  if (Lot < MINLOT)
          return(true);
          
  //----+ проверка лота на максимальное допустимое значение
  MAXLOT = MarketInfo(Symb, MODE_MAXLOT);
  if (MAXLOT < 0)
         return(false);
  if (Lot > MAXLOT)
          Lot = MAXLOT;
          
  Level = StopCorrect(Symb, LEVEL);
  //----
  OpenPrice = NormalizeDouble(Ask + Level * Point, Digits);
  if (OpenPrice == 0.0)
          return(false);
  //----             
  StLOSS = StopCorrect(Symb, STOPLOSS);
  if (StLOSS < 0)
          return(false);   
  //----
  Stoploss = NormalizeDouble(OpenPrice - StLOSS * Point, Digits);
  if (Stoploss < 0)
         return(false);
  //----       
  TkPROFIT = StopCorrect(Symb, TAKEPROFIT);
  if (TkPROFIT < 0)
          return(false);  
  //----               
  TakeProfit = NormalizeDouble(OpenPrice + TkPROFIT * Point, Digits);
  if (TakeProfit < 0)
         return(false);
  
  Print(StringConcatenate
         ("Выставляем по ", Symb,
                  " отложенный BUY STOP ордер с магическим числом ", MagicNumber));
  //----+ Открываем позицию на покупку    
  ticket = OrderSend(Symb, OP_BUYSTOP, Lot, OpenPrice, 0, 
            Stoploss, TakeProfit, NULL, MagicNumber, Expiration, Blue); 
  
  //----
  if(ticket > 0)
     if (OrderSelect(ticket, SELECT_BY_TICKET))
       {
         Order_Signal = false;  
         OpderPrice = DoubleToStr(OrderOpenPrice(), Digits);
         Print(StringConcatenate("Отложенный BUY STOP ",Symb, 
            " ордер с тикетом №",  ticket, " и магическим числом ", 
               OrderMagicNumber(), " выставлен. Цена срабатывания ордера ",OpderPrice,
                            ". Расчитанная цена была ", DoubleToStr(OpenPrice, Digits)));
         //----
         LastTime = TimeCurrent();
         return(true);
       }
     else
       {
         Print(StringConcatenate("Не удалось выставить отложенный BUY STOP ", Symb, 
                                   " ордер с магическим числом ", MagicNumber, "!!!"));
         LastTime = TimeCurrent();
         return(true);
       }
  return(true);
//----+
 }
//+==================================================================+
//| OpenSellLimitOrder1()                                            |
//+==================================================================+
bool OpenSellLimitOrder1
        (bool& Order_Signal, int MagicNumber, 
           double Money_Management, int STOPLOSS, int TAKEPROFIT,
                                      int LEVEL, datetime Expiration)
 {
//----+
  if (!Order_Signal)
           return(true); 
  //---- Проверка на истечение минимального интервала времени 
                                    //между двумя торговыми операциями         
  if (TimeCurrent() - LastTime < 11)
                          return(true); 
  int total = OrdersTotal();
  //---- Проверка на наличие открытой позиции 
          //с магическим числом равным значению переменной MagicNumber
  for(int ttt = total - 1; ttt >= 0; ttt--)     
      if (OrderSelect(ttt, SELECT_BY_POS, MODE_TRADES))
                      if (OrderMagicNumber() == MagicNumber)
                                                      return(true); 
  string Symb = Symbol(), OpderPrice; 
  int    SPREAD, ticket, StLOSS, TkPROFIT, Level;
  double LOTSTEP, MINLOT, MAXLOT, MARGINREQUIRED, TICKSIZE;
  double LotVel, Lot, OpenPrice, Stoploss, TakeProfit, TICKVALUE;                                                 
                                                      
  //----+ расчёт величины лота для открывания позиции
  if (Money_Management > 0)
    {        
      MARGINREQUIRED = MarketInfo(Symb, MODE_MARGINREQUIRED);
      if (MARGINREQUIRED == 0.0)
                    return(false); 
      SPREAD = MarketInfo(Symb, MODE_SPREAD);
      if (SPREAD == 0)
                    return(false);
                    
      TICKVALUE = MarketInfo(Symb, MODE_TICKVALUE);
      if (TICKVALUE == 0)
                    return(false);
                    
      TICKSIZE = MarketInfo(Symb, MODE_TICKSIZE);
      if (TICKSIZE == 0)
                    return(false);                                              
                           
      LotVel = GetFreeMargin() * Money_Management /
                         (MARGINREQUIRED - (SPREAD * TICKVALUE));
                        
      LOTSTEP = MarketInfo(Symb, MODE_LOTSTEP);
      if (LOTSTEP <= 0)
                  return(false);
    }
  else 
    LotVel = MathAbs(Money_Management);
  //---- нормирование величины лота до ближайшего стандартного значения    
  Lot = LOTSTEP * MathFloor(LotVel / LOTSTEP);
  
  //----+ проверка лота на минимальное допустимое значение
  MINLOT = MarketInfo(Symb, MODE_MINLOT);
  if (MINLOT < 0)
         return(false);
  if (Lot < MINLOT)
          return(true);
          
  //----+ проверка лота на максимальное допустимое значение
  MAXLOT = MarketInfo(Symb, MODE_MAXLOT);
  if (MAXLOT < 0)
         return(false);
  if (Lot > MAXLOT)
          Lot = MAXLOT;
  
  Level = StopCorrect(Symb, LEVEL);        
  //----
  OpenPrice = NormalizeDouble(Bid  + Level * Point, Digits);
  if (OpenPrice == 0.0)
               return(false);
  //----             
  StLOSS = StopCorrect(Symb, STOPLOSS);
  if (StLOSS < 0)
          return(false);   
  //----
  Stoploss = NormalizeDouble(OpenPrice + StLOSS * Point, Digits);
  if (Stoploss < 0)
         return(false);
  //----       
  TkPROFIT = StopCorrect(Symb, TAKEPROFIT);
  if (TkPROFIT < 0)
          return(false);  
  //----      
  TakeProfit = NormalizeDouble(OpenPrice - TkPROFIT * Point, Digits);
  if (TakeProfit < 0)
         return(false);
  
  Print(StringConcatenate
         ("Выставляем по ", Symb,
                  " отложенный SELL LIMIT ордер с магическим числом ", MagicNumber));
  //----+ Открываем позицию на продажу    
  ticket = OrderSend(Symb, OP_SELLLIMIT, Lot, OpenPrice, 0, 
            Stoploss, TakeProfit, NULL, MagicNumber, 0, Magenta); 
  
  
  //----
  if(ticket > 0)
     if (OrderSelect(ticket, SELECT_BY_TICKET))
       {
         Order_Signal = false; 
         OpderPrice = DoubleToStr(OrderOpenPrice(), Digits);
         Print(StringConcatenate("Отложенный SELL LIMIT ",Symb, 
              " ордер с тикетом №",  ticket, " и магическим числом ", 
                OrderMagicNumber(), " выставлен. Цена срабатывания ордера ",OpderPrice,
                               ". Расчитанная цена была ", DoubleToStr(OpenPrice, Digits)));
         LastTime = TimeCurrent();
         return(true);
       }
     else
       {
         Print(StringConcatenate("Не удалось выставить отложенный SELL LIMIT ", Symb, 
                                   " ордер с магическим числом ", MagicNumber, "!!!"));
         LastTime = TimeCurrent();
         return(true);
       }
  return(true);
//----+  
 }
//+==================================================================+
//| OpenSellStopOrder1()                                             |
//+==================================================================+
bool OpenSellStopOrder1
        (bool& Order_Signal, int MagicNumber, 
           double Money_Management, int STOPLOSS, int TAKEPROFIT,
                                      int LEVEL, datetime Expiration)
 {
//----+
  if (!Order_Signal)
           return(true); 
  //---- Проверка на истечение минимального интервала времени 
                                    //между двумя торговыми операциями         
  if (TimeCurrent() - LastTime < 11)
                          return(true); 
  int total = OrdersTotal();
  //---- Проверка на наличие открытой позиции 
          //с магическим числом равным значению переменной MagicNumber
  for(int ttt = total - 1; ttt >= 0; ttt--)     
      if (OrderSelect(ttt, SELECT_BY_POS, MODE_TRADES))
                      if (OrderMagicNumber() == MagicNumber)
                                                      return(true); 
  string Symb = Symbol(), OpderPrice; 
  int    SPREAD, ticket, StLOSS, TkPROFIT, Level;
  double LOTSTEP, MINLOT, MAXLOT, MARGINREQUIRED, TICKSIZE;
  double LotVel, Lot, OpenPrice, Stoploss, TakeProfit, TICKVALUE;                                                 
                                                      
  //----+ расчёт величины лота для открывания позиции
  if (Money_Management > 0)
    {        
      MARGINREQUIRED = MarketInfo(Symb, MODE_MARGINREQUIRED);
      if (MARGINREQUIRED == 0.0)
                    return(false); 
      SPREAD = MarketInfo(Symb, MODE_SPREAD);
      if (SPREAD == 0)
                    return(false);
                    
      TICKVALUE = MarketInfo(Symb, MODE_TICKVALUE);
      if (TICKVALUE == 0)
                    return(false);
                    
      TICKSIZE = MarketInfo(Symb, MODE_TICKSIZE);
      if (TICKSIZE == 0)
                    return(false);                                                
                           
      LotVel = GetFreeMargin() * Money_Management / 
                      (MARGINREQUIRED - (SPREAD * TICKVALUE));
                        
      LOTSTEP = MarketInfo(Symb, MODE_LOTSTEP);
      if (LOTSTEP <= 0)
                  return(false);
    }
  else 
    LotVel = MathAbs(Money_Management);
  //---- нормирование величины лота до ближайшего стандартного значения 
  Lot = LOTSTEP * MathFloor(LotVel / LOTSTEP);
  
  //----+ проверка лота на минимальное допустимое значение
  MINLOT = MarketInfo(Symb, MODE_MINLOT);
  if (MINLOT < 0)
         return(false);
  if (Lot < MINLOT)
          return(true);
          
  //----+ проверка лота на максимальное допустимое значение
  MAXLOT = MarketInfo(Symb, MODE_MAXLOT);
  if (MAXLOT < 0)
         return(false);
  if (Lot > MAXLOT)
          Lot = MAXLOT;
  
  Level = StopCorrect(Symb, LEVEL);        
  //----
  OpenPrice = NormalizeDouble(Bid - Level * Point, Digits);
  if (OpenPrice == 0.0)
               return(false);
  //----             
  StLOSS = StopCorrect(Symb, STOPLOSS);
  if (StLOSS < 0)
          return(false);   
  //----
  Stoploss = NormalizeDouble(OpenPrice + StLOSS * Point, Digits); 
  if (Stoploss < 0)
         return(false);
  //----       
  TkPROFIT = StopCorrect(Symb, TAKEPROFIT); 
  if (TkPROFIT < 0)
          return(false);  
  //----      
  TakeProfit = NormalizeDouble(OpenPrice - TkPROFIT * Point, Digits); 
  if (TakeProfit < 0)
         return(false);
  
  Print(StringConcatenate
         ("Выставляем по ", Symb,
                  " отложенный SELL STOP ордер с магическим числом ", MagicNumber));
  //----+ Открываем позицию на продажу    
  ticket = OrderSend(Symb, OP_SELLSTOP, Lot, OpenPrice, 0, 
            Stoploss, TakeProfit, NULL, MagicNumber, 0, Magenta); 
  
  
  //----
  if(ticket > 0)
     if (OrderSelect(ticket, SELECT_BY_TICKET))
       {
         Order_Signal = false; 
         OpderPrice = DoubleToStr(OrderOpenPrice(), Digits);
         Print(StringConcatenate("Отложенный SELL STOP ",Symb, 
               " ордер с тикетом №",  ticket, " и магическим числом ", 
                 OrderMagicNumber(), " выставлен. Цена срабатывания ордера ",OpderPrice, 
                              ". Расчитанная цена была ", DoubleToStr(OpenPrice, Digits)));
         LastTime = TimeCurrent();
         return(true);
       }
     else
       {     
         Print(StringConcatenate("Не удалось выставить отложенный SELL STOP ", Symb, 
                                   " ордер с магическим числом ", MagicNumber, "!!!"));
         LastTime = TimeCurrent();
         return(true);
       }
  return(true);
//----+  
 }   
//+==================================================================+
//| Make_TreilingStop() function                                     |
//+==================================================================+
bool Make_TreilingStop(int MagicNumber, int TRAILINGSTOP)
 {
   if(TRAILINGSTOP <= 0)
                     return(true); 
   //---- Проверка на истечение минимального интервала времени 
                                  //между двумя торговыми операциями         
  if (TimeCurrent() - LastTime < 11)
          return(true); 
  bool FindOrder;        
  int pos, total = OrdersTotal();
  if (total == 0)
              return(true);
  //---- Проверка на наличие открытой позиции 
        //с магическим числом равным значению переменной MagicNumber
  for(pos = total - 1; pos >= 0; pos--)   
    if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES))
                  if (OrderMagicNumber() == MagicNumber)
                                           if (OrderType() < 2)
                                              {
                                               FindOrder = true;
                                               break;
                                              }
                                                            
  if (!FindOrder)
             return(true); 
  //----           
  color Order_Color;
  //----
  double NewStopLoss, ask, bid, point, TRStop;
  //----
  string NEWSTOPLOSS, Order_Type, PriceName, symb = OrderSymbol();
  //----
  int    ticket, digits;       
  //----           
  ticket = OrderTicket(); 
  //----
  digits = MarketInfo(symb, MODE_DIGITS); 
  if (digits == 0)
            return(false);
  //----
  ask = NormalizeDouble(MarketInfo(symb, MODE_ASK), digits); 
  if (ask == 0)
          return(false);
  //----
  bid = NormalizeDouble(MarketInfo(symb, MODE_BID), digits); 
  if (bid == 0)
           return(false);
  //----
  point = MarketInfo(symb, MODE_POINT); 
  if (point == 0)
           return(false); 
  //----
  TRStop = StopCorrect(symb, TRAILINGSTOP) * point;
  if (TRStop < 0)
           return(false);
  //----
  
   switch(OrderType())
     {
      //----+ Получение значений для модификации ордера
      case OP_BUY:
       {
        if(bid - OrderStopLoss() > TRStop)
          {
            NewStopLoss = bid - TRStop;
            Order_Type =" BUY";
            Order_Color = Lime;
            PriceName = StringConcatenate(" BID = ", 
                                    DoubleToStr(bid, digits));
          }
        else 
          return(true);
        break;
       }
      //----+ Модифицируем ордер на покупку
      case OP_SELL:
       {
        if(OrderStopLoss() - ask > TRStop)
          { 
            NewStopLoss = ask + TRStop;
            Order_Type =" SELL";
            Order_Color = Red;
            PriceName = StringConcatenate(" ASK = ", 
                                    DoubleToStr(ask, digits));
          }
        else 
         return(true);
        break;
       }
      //----+ 
      default : 
         return(true);
      }
  
      //----+ Модифицируем ордер 
       if(OrderCloseTime()!=0)
                       return(true);
       Print(StringConcatenate("Двигаем стоплосс трейлинстопом в ", 
                                                      TRAILINGSTOP, " пунктов"));
       Print(StringConcatenate("Меняем стоплосс  на ",pos,
                 " позиции. ", symb, Order_Type, " ордер с тикетом №",ticket, 
                                           " и магическим числом ", MagicNumber)); 
       //----
       if(OrderModify(ticket, OrderOpenPrice(), NewStopLoss, 
                                         OrderTakeProfit(), 0, Order_Color))
         {
           Print(StringConcatenate(symb, Order_Type, " ордер с тикетом №", 
            ticket, " и магическим числом ", OrderMagicNumber(), " модифицирован"));
           //----              
           NEWSTOPLOSS = DoubleToStr(OrderStopLoss(), digits);  
           Print(StringConcatenate("Новый стоплосс ордера ", NEWSTOPLOSS, 
                                                 ". Расчётный стоплос ", 
                                    DoubleToStr(NewStopLoss, digits), ".", PriceName)); 
           //----
           LastTime = TimeCurrent();
           return(true);
         }
       else 
         {
           Print("Не удалось модифицировать ", symb, Order_Type, " ордер с тикетом №",
                                     ticket, " и магическим числом ", OrderMagicNumber());
           LastTime = TimeCurrent();
           return(true);
         } 
    return(true);   
//----
  } 
//+-------------------------------------------------------------------------------------------+