//+------------------------------------------------------------------+
//|                                                        fann2.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"

#include <gc\FANN2MQL5.mqh>

int ann;
int input_count=4999;
// InputVector[] - Array of ann input data
double InputVector[];
// symbols list
string slist[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
// symbols list
   int symb_total;
   symb_total=SymbolsTotal(false);
   ArrayResize(slist,symb_total);
   for(int i=0;i<symb_total;i++) slist[i]=SymbolName(i,true);

//   

// Creating NN
//ann_prepare_input2(0);
   //f2M5_parallel_init();
   ann=CreateAnn();
   //Print("ann=",ann);
   //ann_save(ann,TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\1.net");
   //ann_save(ann,"1");
   TrainNN();
   get_res();
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

   ann_save(ann,TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\fann.net");
   ann_destroy();
   //f2M5_parallel_deinit();
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(isNewBar(_Period))
     {
      ann_destroy();
      ann=CreateAnn();
      TrainNN();
     }
   get_res();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_res()
  {
//---
   ann_prepare_input(0);

   if(f2M5_run(ann,InputVector)<0)
     {
      Print("Network RUN ERROR! ann="+IntegerToString(ann));
     }
   double nxt_price=f2M5_get_output(ann,0)/GetDelim(_Symbol);
   draw_line(nxt_price);
   Comment("\nNext Price Target: "+DoubleToString(nxt_price,_Digits)+" MSE: "+DoubleToString(f2M5_get_MSE(ann))+" NN Input: "+IntegerToString(f2M5_get_num_input(ann))+" NN Output: "+IntegerToString(f2M5_get_num_output(ann)));
  }
//+------------------------------------------------------------------+
int CreateAnn()
  {
   ann=f2M5_create_standard(4,8,16,8,1);
   f2M5_set_act_function_hidden(ann,6);
   f2M5_set_act_function_output(ann,6);
   f2M5_randomize_weights(ann,-0.7,0.7);
   //Print("ANN: created successfully with handler "+IntegerToString(ann));
   if(ann==-1) Print("ERROR INITIALIZING NETWORK!");
   return(ann);
  }
//+------------------------------------------------------------------+  
void TrainNN()
  {
////for(int i=0; i<input_count; i++)
   for(int epochs=0; epochs<5; epochs++)
     {
      for(int i=input_count; i>1; i--)
        {
         // ArrayResize(InputVector,0);
         ann_prepare_input(i);
         double cl[];
         ArrayResize(cl,1);
         cl[0]=iClose(NULL,_Period,i-1)*GetDelim(_Symbol);
         ann_train(ann,InputVector,cl);

         ArrayFree(cl);

         f2M5_run(ann,InputVector);

         Comment("Training NN# MSE:  "+DoubleToString(f2M5_get_MSE(ann))+":"+IntegerToString(i)+" Result="+DoubleToString(f2M5_get_output(ann,0)/GetDelim(_Symbol),_Digits));

        }

     }//
  }
//+------------------------------------------------------------------+
void ann_prepare_input(int pos)
  {
   int inp_vec_size=0;
   for(int i=0; i<ArraySize(slist); i++)
     {
      datetime time1[1],time2[1];

      //Print(IntegerToString(ArraySize(slist))); || StringFind(slist[i],"#",0)>0
      if(CopyTime("EURUSD",_Period,pos,1,time1)!=1 || CopyTime(slist[i],_Period,pos,1,time2)!=1) continue;
      if(time1[0]!=time2[0]) continue;

      double res;
      double iClose[];
      if(CopyClose(slist[i],_Period,pos,1,iClose)!=1) Print("Copy rate failure symbol="+slist[i]);

      res=iClose[0]*GetDelim(slist[i]);
      ArrayFree(iClose);

      ArrayResize(InputVector,inp_vec_size+1);
      //InputVector[inp_vec_size]=NormalizeDouble(res,SymbolInfoInteger(slist[i],SYMBOL_DIGITS));
      InputVector[inp_vec_size]=res;
      //Print("Pos=" + pos + " Symb="+slist[i]+DoubleToString(InputVector[inp_vec_size],_Digits));

      inp_vec_size++;
     }

  }
//+------------------------------------------------------------------+
void ann_prepare_input2(int pos)
  {
   ResetLastError();
   int filehandle=FileOpen("inpvec.txt",FILE_WRITE|FILE_TXT);
   if(filehandle!=INVALID_HANDLE)
     {


      int inp_vec_size=0;
      for(int i=0; i<ArraySize(slist); i++)
        {
         datetime time1[1],time2[1];

         //Print(IntegerToString(ArraySize(slist))); || StringFind(slist[i],"#",0)>0
         if(CopyTime("EURUSD",_Period,pos,1,time1)!=1 || CopyTime(slist[i],_Period,pos,1,time2)!=1) continue;
         if(time1[0]!=time2[0]) continue;

         double res;
         double iClose[];
         if(CopyClose(slist[i],_Period,pos,1,iClose)!=1) Print("Copy rate failure symbol="+slist[i]);

         res=iClose[0]*GetDelim(slist[i]);
         ArrayFree(iClose);

         ArrayResize(InputVector,inp_vec_size+1);
         //InputVector[inp_vec_size]=NormalizeDouble(res,SymbolInfoInteger(slist[i],SYMBOL_DIGITS));
         InputVector[inp_vec_size]=res;
         //Print("Pos=" + pos + " Symb="+slist[i]+DoubleToString(InputVector[inp_vec_size],_Digits));
         FileWrite(filehandle,slist[i]," ",DoubleToString(GetDelim(slist[i]))," ",DoubleToString(res));
         inp_vec_size++;
        }
      FileClose(filehandle);
      Print("FileOpen OK");     
     }
   else Print("ќпераци€ FileOpen неудачна, ошибка",GetLastError());
  }
//+------------------------------------------------------------------+
void ann_train(int fann,double &input_vector[],double &output_vector[])
  {
   if(f2M5_train(fann,input_vector,output_vector)==-1)
     {
      Print("Network TRAIN ERROR! ann="+IntegerToString(ann));
     }
//Print("ann_train("+IntegerToString(ann)+") succeded");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ann_destroy()
  {
   f2M5_destroy(ann);
   //Print("f2M5_destroy("+IntegerToString(ann)+") returned: "+IntegerToString(f2M5_destroy(ann)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iClose(string symbol,ENUM_TIMEFRAMES period,int index)
  {
   double result;
   double iClose[];
   if(CopyClose(symbol,period,index,1,iClose)!=1)
     {
      return(0);
     }
   result=iClose[0];
   ArrayFree(iClose);
   return(result);
  }
//+------------------------------------------------------------------+
bool ann_save(int fann,string path)
  {
//int ret=-1;
//ret=f2M_save(ann,path);
   uchar p[];
   StringToCharArray(path,p);
   if(f2M5_save(fann,p)<0) 
     {
      Print(path);
      return(false);
     }
//   Print("f2M_save("+IntegerToString(ann)+", "+p+") returned: "+IntegerToString(f2M_save(ann,path)));
   return(true);

  }
//int GetDelim(string Symb)
/**/

double GetDelim(string Symb)
  {
   double price=SymbolInfoDouble(Symb,SYMBOL_BID);
   if(price<1) return(1);
   if(price>1  &&  price<10) return(0.1);
   if(price>10 && price<100) return(0.01);
   if(price>100  &&  price<1000) return(0.001);
   if(price>1000 && price<10000) return(0.0001);
   if(price>10000 && price<100000) return(0.0001);
   return(0.1);
/*
   double price=SymbolInfoDouble(Symb,SYMBOL_BID);
   if(price<1) return(1);
   if(price>1 && price<10) return(1);
   if(price>10 && price<100) return(0.1);
   if(price>100 && price<1000) return(0.01);
   if(price>1000 && price<10000) return(0.001);
   if(price>10000 && price<100000) return(0.001);
   return(0.1);   */
  }
//+------------------------------------------------------------------+
void draw_line(double price)
  {
   string name="TargetPriceLine";
   if(ObjectFind(0,name)<0)
     {
      //--- создадим объект Label
      ObjectCreate(0,name,OBJ_HLINE,0,TimeCurrent(),price);
      ObjectSetInteger(0,name,OBJPROP_COLOR,GreenYellow);
        }else{
      ObjectSetDouble(0,name,OBJPROP_PRICE,price);
     }

//--- отрисуем на графике
   ChartRedraw(0);

  }

//+------------------------------------------------------------------+
//| возвращает true если по€вилс€ новый бар, иначе false             |
//+------------------------------------------------------------------+
bool isNewBar(ENUM_TIMEFRAMES timeFrame)
  {
//----
   static datetime old_Times[21];// массив дл€ хранени€ старых значений
   bool res=false;               // переменна€ результата анализа  
   int  i=0;                       // номер €чейки массива old_Times[]     
   datetime new_Time[1];         // врем€ нового бара

   switch(timeFrame)
     {
      case PERIOD_M1:  i= 0; break;
      case PERIOD_M2:  i= 1; break;
      case PERIOD_M3:  i= 2; break;
      case PERIOD_M4:  i= 3; break;
      case PERIOD_M5:  i= 4; break;
      case PERIOD_M6:  i= 5; break;
      case PERIOD_M10: i= 6; break;
      case PERIOD_M12: i= 7; break;
      case PERIOD_M15: i= 8; break;
      case PERIOD_M20: i= 9; break;
      case PERIOD_M30: i=10; break;
      case PERIOD_H1:  i=11; break;
      case PERIOD_H2:  i=12; break;
      case PERIOD_H3:  i=13; break;
      case PERIOD_H4:  i=14; break;
      case PERIOD_H6:  i=15; break;
      case PERIOD_H8:  i=16; break;
      case PERIOD_H12: i=17; break;
      case PERIOD_D1:  i=18; break;
      case PERIOD_W1:  i=19; break;
      case PERIOD_MN1: i=20; break;
     }
// скопируем врем€ последнего бара в €чейку new_Time[0]   
   int copied=CopyTime(_Symbol,timeFrame,0,1,new_Time);

   if(copied>0) // все ок. данные скопированы
     {
      if(old_Times[i]!=new_Time[0]) // если старое врем€ бара не равно новому
        {
         if(old_Times[i]!=0) res=true;    // если это не первый запуск, то истина = новый бар
         old_Times[i]=new_Time[0];        // запоминаем врем€ бара
        }
     }
//----
   return(res);
  }
//+------------------------------------------------------------------+
