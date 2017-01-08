//+------------------------------------------------------------------+
//|                                                       Orders.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---
   uint     total=OrdersTotal();
   ulong    ticket=0;
   string   symbol;
   long     type;
   double price;
   for(uint i=0;i<total;i++)
     {
      //--- try to get deals ticket
      if(ticket=OrderGetTicket(i))
        {
         //--- get orders properties
  //       open_price=   OrderGetDouble(ORDER_PRICE_OPEN);
//         time_setup=  OrderGetInteger(ORDER_TIME_SETUP);
//         time_open=OrderGetInteger(ORDER_TIME_DONE);
         symbol=        OrderGetString(ORDER_SYMBOL);
         type  =        OrderGetInteger(ORDER_TYPE);
         price =        OrderGetDouble(ORDER_TP);
         if(type==ORDER_TYPE_BUY_LIMIT) Print("Покупка ",symbol," по цене ",price);
         if(type==ORDER_TYPE_SELL_LIMIT) Print("Продажа ",symbol," по цене ",price);
//         order_magic= OrderGetInteger(ORDER_MAGIC);
//         positionID =   OrderGetInteger(ORDER_POSITION_ID);
//         initial_volume=OrderGetDouble(ORDER_VOLUME_INITIAL);
         //--- print list of orders
         //string order_info="#"+(string)ticket+" "+symbol+" at "+(string)open_price+
//                           " was set at "+(string)time_setup;
         //Print(order_info);
        }
     }

//   Print("Orders=",OrdersTotal());
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
//---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
