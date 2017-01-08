//+------------------------------------------------------------------+
//|                                                       FANN_1.mq5 |
//|                                                          pyroman |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "pyroman"
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <Fann2MQL.mqh>

MqlTradeRequest trReq;
MqlTradeResult trRez;

//--- input parameters
input int      StopLoss=100;
input int      TakeProfit=150;
input int MAGIC=999;   //MAGIC number

extern int DebugLevel=2;
extern int AnnsNumber=1;
extern int AnnInputs=30;
extern bool NeuroFilter=false;
extern bool SaveAnn=true;
extern bool Parallel=true;

// AnnsArray[ann#] - массив нейросетей
int AnnsArray[];

// флаг статуса загрузки всех нейросетей
bool AnnsLoaded=true;

// AnnOutputs[ann#] - массив выходов нейросети
double AnnOutputs[];

// InputVector[] - массив входных данных нейросети
double InputVector[];

// Сохраненные значения входов для длинной и короткой позиций.
double Input[];

//MACD signal 
input int      MACD_F=2;
input int      MACD_S=12;
input int      MACD_A=9;
int            h_macd=0;
double         macd_main[];
double         macd_signal[];
//end MACD Signal

//RSI signal 
input int         RSI=14;
int               h_rsi=0;
double            rsi_buffer[];
//end RSI Signal

//ROC signal 
input int         ROC=10;
int               h_roc=0;
double            roc_buffer[];
//end ROC Signal

//WPR signal 
input int         WPR=14;
int               h_wpr=0;
double            wpr_buffer[];
//end WPR Signal

int sl;
int tp;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   int i,ann;
   trReq.action=TRADE_ACTION_DEAL;
   trReq.magic=MAGIC;
   trReq.symbol=Symbol();                 // Trade symbol
   trReq.volume=0.1;                    // Requested volume for a deal in lots
   trReq.deviation=1;                     // Maximal possible deviation from the requested price
   trReq.type_filling=ORDER_FILLING_AON;  // Order execution type
   trReq.type_time=ORDER_TIME_GTC;        // Order execution time
   trReq.comment="Ultimate Neural";

   h_macd=iMACD(Symbol(),Period(),MACD_F,MACD_S,MACD_A,PRICE_CLOSE);
   h_rsi=iRSI(Symbol(),Period(),RSI,PRICE_CLOSE);
   //h_roc=iCustom(Symbol(),Period(),"Examples\\ROC",ROC,PRICE_CLOSE);
   h_wpr=iWPR(Symbol(),Period(),WPR);
//      h_ao=iAO(Symbol(),Period());
//input parameters are ReadOnly
   tp=TakeProfit;
   sl=StopLoss;
//end
//Support for acount with 5 decimals
   if(_Digits==5)
     {
      sl*=10;
      tp*=10;
     }
//end
//LastBalance = AccountInfoDouble(ACCOUNT_BALANCE);

// Инициализиуем нейросети
   ArrayResize(AnnsArray,AnnsNumber);
   for(i=0;i<AnnsNumber;i++)
     {
      ann=ann_load("net_"+(string)i+".net");
      if(ann<0)
         AnnsLoaded=false;
      AnnsArray[i]=ann;
     }
   ArrayResize(AnnOutputs,AnnsNumber);
   ArrayResize(InputVector,AnnInputs);
   ArrayResize(Input,AnnInputs);
//   ArrayResize(ShortInput,AnnInputs);

// Инициализируем потоки (Intel TBB threads)
   f2M_parallel_init();

//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int i;
//---
// Deinitialize anns
   for(i=AnnsNumber-1; i>=0; i--)
     {
      if(SaveAnn)
        {
         ann_save(AnnsArray[i],"net_"+(string)i+".net");
        }
     }
  // ann_destroy(AnnsArray[i]);

// Deinitialize Intel TBB threads
//f2M_parallel_deinit();

  }
//+------------------------------------------------------------------+
//| ANN functions                                                    |
//+------------------------------------------------------------------+
void debug(int level,string text)
  {
   if(DebugLevel>=level)
     {
      if(level==0)
         text="ОШИБКА: "+text;
      Print(text);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ann_load(string path)
  {
   int ann=-1;

/* Загрузить нейросеть */
   ann=f2M_create_from_file(path);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ann!=-1)
     {
      debug(1,"Нейросеть: '"+path+"' успешно загружена. Ее хендл: "+(string)ann);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ann==-1)
     {

/* Создание нейросети */
      ann=f2M_create_standard(4,AnnInputs,AnnInputs,AnnInputs/2+1,1);
      f2M_set_act_function_hidden(ann,FANN_SIGMOID_SYMMETRIC_STEPWISE);
      f2M_set_act_function_output(ann,FANN_SIGMOID_SYMMETRIC_STEPWISE);
      f2M_randomize_weights(ann,-0.4,0.4);
      debug(1,"Нейросеть: '"+path+"' успешно создана. Ее хендл: "+(string)ann);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ann==-1)
     {
      debug(0,"ИНИЦИАЛИЗАЦИЯ НЕЙРОСЕТИ!");
     }
   return(ann);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ann_prepare_input()
  {
   int i;

   for(i=0;i<=AnnInputs-1;i=i+3)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
/*      InputVector[i]=
         10*iMACD(NULL,0,FastMA,SlowMA,SignalMA,PRICE_CLOSE,
                  MODE_MAIN,i*3);
      InputVector[i+1]=
         10*iMACD(NULL,0,FastMA,SlowMA,SignalMA,PRICE_CLOSE,
                  MODE_SIGNAL,i*3);
      InputVector[i+2]=InputVector[i-2]-InputVector[i-1];*/
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void
ann_save(int ann,string path)
  {
   int ret=-1;
   ret=f2M_save(ann,path);
   debug(1,"f2M_save("+(string)ann+", "+path+") returned: "+(string)ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void
ann_destroy(int ann)
  {
   int ret=-1;
   ret=f2M_destroy(ann);
   debug(1,"f2M_destroy("+(string)ann+") returned: "+(string)ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ann_run(int ann,double &vector[])
  {
   int ret;
   double out;
   ret=f2M_run(ann,vector);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ret<0)
     {
      debug(0,"ОШИБКА запуска нейросети!!! ann="+(string)ann);
      return(FANN_DOUBLE_ERROR);
     }
   out=f2M_get_output(ann,0);
   debug(3,"f2M_get_output("+(string)ann+") результат: "+(string)out);
   return(out);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int anns_run_parallel(int anns_count,int &anns[],double &input_vector[])
  {
   int ret;

   ret=f2M_run_parallel(anns_count,anns,input_vector);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ret<0)
     {
      debug(0,"f2M_run_parallel("+(string)anns_count+") результат: "+(string)ret);
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void run_anns()
  {
   int i;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Parallel)
     {
      anns_run_parallel(AnnsNumber,AnnsArray,InputVector);
     }

   for(i=0;i<AnnsNumber;i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Parallel)
        {
         AnnOutputs[i]=f2M_get_output(AnnsArray[i],0);
           } else {
         AnnOutputs[i]=ann_run(AnnsArray[i],InputVector);
        }
     }
  }
//+------------------------------------------------------------------+

void
ann_train(int ann,double &input_vector[],double &output_vector[])
  {
   if(f2M_train(ann,input_vector,output_vector)==-1) 
     {
      debug(0,"Network TRAIN ERROR! ann="+(string)ann);
     }
   debug(3,"ann_train("+(string)ann+") succeded");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int i,j,k;
//---
   MqlTick tick; //variable for tick info
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!SymbolInfoTick(Symbol(),tick))
     {
      Print("Failed to get Symbol info!");
      return;
     }

   CopyBuffer(h_macd,0,5,11,macd_main);
   CopyBuffer(h_macd,1,5,11,macd_signal);
   ArraySetAsSeries(macd_main,true);
   ArraySetAsSeries(macd_signal,true);

   for(i=0; i<AnnsNumber; i++)
     {
      for(j=0; j<AnnInputs; j=j+3)
        {
         for(k=0; k<10; k++)
           {
            if(macd_main[k]>0)
               InputVector[j]=1;
            else if(macd_main[k]<0)
               InputVector[j]=-1;
            else
               InputVector[j]=0;

            if(macd_main[k]>macd_signal[k])
               InputVector[j+1]=1;
            else if(macd_main[k]<macd_signal[k])
               InputVector[j+1]=-1;
            else
               InputVector[j+1]=0;

            if(macd_main[k]>macd_main[k+1])
               InputVector[j]=1;
            else if(macd_main[k]<macd_main[k+1])
               InputVector[j]=-1;
            else
               InputVector[j]=0;
           }
        }
      AnnOutputs[0]=OutputCalculate();
      ann_train(AnnsArray[i],InputVector,AnnOutputs);
     }

  }
//+------------------------------------------------------------------+

int OutputCalculate()
  {
   double res;
   MqlRates rates_buffer[];
   int out;
   
   ArraySetAsSeries(rates_buffer,true);
   CopyRates(NULL,0,0,5,rates_buffer);
   res=(rates_buffer[4].high-rates_buffer[0].low)/_Point;
   if((res>0) && MathAbs(res)>=50)
     {
      out=1;
     }
   else if((res<0) && MathAbs(res)>=50)
     {
      out=-1;
     }
   else
     {
      out=0;
     }

   return(out);
  }
//+------------------------------------------------------------------+
