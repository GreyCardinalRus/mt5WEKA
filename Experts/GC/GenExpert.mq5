//+------------------------------------------------------------------+
//|                                                    GenExpert.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
#include <Expert\Signal\SignalCandlesRSI.mqh>
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Inp_Expert_Title                  ="GenExpert";
int                      Expert_MagicNumber                =31989;
bool                     Expert_EveryTick                  =false;
//--- inputs for signal
input int                Inp_Signal_CandlesRSI_Range       =6;
input int                Inp_Signal_CandlesRSI_Minimum     =25;
input double             Inp_Signal_CandlesRSI_ShadowBig   =0.5;
input double             Inp_Signal_CandlesRSI_ShadowLittle=0.2;
input double             Inp_Signal_CandlesRSI_Limit       =0.0;
input double             Inp_Signal_CandlesRSI_StopLoss    =2.0;
input double             Inp_Signal_CandlesRSI_TakeProfit  =1.0;
input int                Inp_Signal_CandlesRSI_Expiration  =4;
input int                Inp_Signal_CandlesRSI_PeriodRSI   =12;
input ENUM_APPLIED_PRICE Inp_Signal_CandlesRSI_AppliedRSI  =PRICE_CLOSE;
input int                Inp_Signal_CandlesRSI_ExtrMapp    =11184810;
//--- inputs for trailing
input double             Inp_Trailing_ParabolicSAR_Step    =0.02;
input double             Inp_Trailing_ParabolicSAR_Maximum =0.2;
//--- inputs for money
input double             Inp_Money_FixLot_Percent          =10.0;
input double             Inp_Money_FixLot_Lots             =0.1;
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(-1);
     }
//--- Creation of signal object
   CSignalCandlesRSI *signal=new CSignalCandlesRSI;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(-2);
     }
//--- Add signal to expert (will be deleted automatically))
   if(!ExtExpert.InitSignal(signal))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing signal");
      ExtExpert.Deinit();
      return(-3);
     }
//--- Set signal parameters
   signal.Range(Inp_Signal_CandlesRSI_Range);
   signal.Minimum(Inp_Signal_CandlesRSI_Minimum);
   signal.ShadowBig(Inp_Signal_CandlesRSI_ShadowBig);
   signal.ShadowLittle(Inp_Signal_CandlesRSI_ShadowLittle);
   signal.Limit(Inp_Signal_CandlesRSI_Limit);
   signal.StopLoss(Inp_Signal_CandlesRSI_StopLoss);
   signal.TakeProfit(Inp_Signal_CandlesRSI_TakeProfit);
   signal.Expiration(Inp_Signal_CandlesRSI_Expiration);
   signal.PeriodRSI(Inp_Signal_CandlesRSI_PeriodRSI);
   signal.AppliedRSI(Inp_Signal_CandlesRSI_AppliedRSI);
   signal.ExtrMapp(Inp_Signal_CandlesRSI_ExtrMapp);
//--- Check signal parameters
   if(!signal.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error signal parameters");
      ExtExpert.Deinit();
      return(-4);
     }
//--- Creation of trailing object
   CTrailingPSAR *trailing=new CTrailingPSAR;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(-5);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(-6);
     }
//--- Set trailing parameters
   trailing.Step(Inp_Trailing_ParabolicSAR_Step);
   trailing.Maximum(Inp_Trailing_ParabolicSAR_Maximum);
//--- Check trailing parameters
   if(!trailing.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error trailing parameters");
      ExtExpert.Deinit();
      return(-7);
     }
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(-8);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(-9);
     }
//--- Set money parameters
   money.Percent(Inp_Money_FixLot_Percent);
   money.Lots(Inp_Money_FixLot_Lots);
//--- Check money parameters
   if(!money.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error money parameters");
      ExtExpert.Deinit();
      return(-10);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(-11);
     }
//--- ok
   return(0);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| Function-event handler "tick"                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| Function-event handler "timer"                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
