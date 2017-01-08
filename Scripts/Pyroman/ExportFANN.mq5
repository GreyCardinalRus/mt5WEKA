//+------------------------------------------------------------------+
//|                                                ExportHistory.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                           History_in_MathCAD.mq5 |
//|                                                    Привалов С.В. |
//|                           https://login.mql5.com/ru/users/Prival |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.1"
//#include <Fractals.mqh>

// Valentin

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input bool _EURUSD_=true;//Euro vs US Dollar
input bool _GBPUSD_=false;//Great Britain Pound vs US Dollar
input bool _USDCHF_=false;//US Dollar vs Swiss Franc
input bool _USDJPY_=false;//US Dollar vs Japanese Yen
input bool _USDCAD_=false;//US Dollar vs Canadian Dollar
input bool _AUDUSD_=false;//Australian Dollar vs US Dollar
input bool _NZDUSD_=false;//New Zealand Dollar vs US Dollar
input bool _USDSEK_=false;//US Dollar vs Sweden Kronor
                          // crosses
input bool _AUDNZD_=false;//Australian Dollar vs New Zealand Dollar
input bool _AUDCAD_=false;//Australian Dollar vs Canadian Dollar
input bool _AUDCHF_=false;//Australian Dollar vs Swiss Franc
input bool _AUDJPY_=false;//Australian Dollar vs Japanese Yen
input bool _CHFJPY_=false;//Swiss Frank vs Japanese Yen
input bool _EURGBP_=false;//Euro vs Great Britain Pound 
input bool _EURAUD_=false;//Euro vs Australian Dollar
input bool _EURCHF_=false;//Euro vs Swiss Franc
input bool _EURJPY_=false;//Euro vs Japanese Yen
input bool _EURNZD_=false;//Euro vs New Zealand Dollar
input bool _EURCAD_=false;//Euro vs Canadian Dollar
input bool _GBPCHF_=false;//Great Britain Pound vs Swiss Franc
input bool _GBPJPY_=false;//Great Britain Pound vs Japanese Yen
input bool _CADCHF_=false;//Canadian Dollar vs Swiss Franc
input int _Pers_ =5;//Период анализа
input int _Outs_=1;//Количество выходов
input int _Shift_=5;//на сколько периодов вперед прогноз
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   string SymbolsArray[30];//={"","USDCHF","GBPUSD","EURUSD","USDJPY","AUDUSD","USDCAD","EURGBP","EURAUD","EURCHF","EURJPY","GBPJPY","GBPCHF"};

   int MaxSymbols=0;

//---- 
   if(_EURUSD_) SymbolsArray[MaxSymbols++]="EURUSD";//Euro vs US Dollar
   if(_GBPUSD_) SymbolsArray[MaxSymbols++]="GBPUSD";//Euro vs US Dollar
   if(_AUDUSD_) SymbolsArray[MaxSymbols++]="AUDUSD";//Euro vs US Dollar
   if(_NZDUSD_) SymbolsArray[MaxSymbols++]="NZDUSD";//Euro vs US Dollar
   if(_USDCHF_) SymbolsArray[MaxSymbols++]="USDCHF";//Euro vs US Dollar
   if(_USDJPY_) SymbolsArray[MaxSymbols++]="USDJPY";//Euro vs US Dollar
   if(_USDCAD_) SymbolsArray[MaxSymbols++]="USDCAD";//Euro vs US Dollar
   if(_USDSEK_) SymbolsArray[MaxSymbols++]="USDSEK";//Euro vs US Dollar
   if(_AUDNZD_) SymbolsArray[MaxSymbols++]="AUDNZD";//Euro vs US Dollar
   if(_AUDCAD_) SymbolsArray[MaxSymbols++]="AUDCAD";//Euro vs US Dollar
   if(_AUDCHF_) SymbolsArray[MaxSymbols++]="AUDCHF";//Euro vs US Dollar
   if(_AUDJPY_) SymbolsArray[MaxSymbols++]="AUDJPY";//Euro vs US Dollar
   if(_CHFJPY_) SymbolsArray[MaxSymbols++]="CHFJPY";//Euro vs US Dollar
   if(_EURGBP_) SymbolsArray[MaxSymbols++]="EURGBP";//Euro vs US Dollar
   if(_EURAUD_) SymbolsArray[MaxSymbols++]="EURAUD";//Euro vs US Dollar
   if(_EURCHF_) SymbolsArray[MaxSymbols++]="EURCHF";//Euro vs US Dollar
   if(_EURJPY_) SymbolsArray[MaxSymbols++]="EURJPY";//Euro vs US Dollar
   if(_EURNZD_) SymbolsArray[MaxSymbols++]="EURNZD";//Euro vs US Dollar
   if(_EURCAD_) SymbolsArray[MaxSymbols++]="EURCAD";//Euro vs US Dollar
   if(_GBPCHF_) SymbolsArray[MaxSymbols++]="GBPCHF";//Euro vs US Dollar
   if(_GBPJPY_) SymbolsArray[MaxSymbols++]="GBPJPY";//Euro vs US Dollar
   if(_CADCHF_) SymbolsArray[MaxSymbols++]="CADCHF";//Euro vs US Dollar
                                                    //WriteFile( 1,5,2010); // день, месяц, год 
   Write_File(SymbolsArray,MaxSymbols,1000,1000,_Pers_,_Outs_); //
   return;// работа скрипта завершена
  }
//+------------------------------------------------------------------+
int Write_File(string &SymbolsArray[],int MaxSymbols,int train_qty,int test_qty,int Pers=5,int Outs=1)
  {
   int shift=0;
// test
   shift=Write_File_fann_data("Forex_test.test",SymbolsArray,MaxSymbols,test_qty,Pers,Outs,shift);
   shift=Write_File_fann_data("Forex_train.train",SymbolsArray,MaxSymbols,train_qty,Pers,Outs,shift);
// чето ниже не работает :(
   FileCopy("Forex_test.test",FILE_COMMON,"Forex_test.dat",FILE_REWRITE);
   FileCopy("Forex_train.train",FILE_COMMON,"Forex_train.dat",FILE_REWRITE);
//\
   return(shift);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Write_File_fann_data(string FileName,string &SymbolsArray[],int MaxSymbols,int qty,int Pers,int Outs,int shift)
  {
   int i;
   double IB[],OB[];
   ArrayResize(IB,Pers+2);
   ArrayResize(OB,Outs+2);
   int FileHandle=0;
   int needcopy=0;
   int copied=0;
   MqlRates rates[];
  // MqlDateTime tm;
   ArraySetAsSeries(rates,true);
   string outstr;
   int SymbolIdx;
   FileHandle=FileOpen(FileName,FILE_WRITE|FILE_ANSI|FILE_TXT,' ');
   needcopy=qty;   

   if(FileHandle!=INVALID_HANDLE)
     {
      FileWrite(FileHandle,// записываем в файл шапку
                needcopy,// 
//                2+(1+Pers)*MaxSymbols,// количество секунд, прошедших с 1 января 1970 года
                (Pers)*MaxSymbols,// количество секунд, прошедших с 1 января 1970 года
                MaxSymbols);
      for(SymbolIdx=0; SymbolIdx<MaxSymbols;SymbolIdx++)
        {
         int bars=Bars(SymbolsArray[SymbolIdx],_Period);
         Print("Баров в истории = ",bars);
         for(i=0;i<needcopy&&shift<bars;shift++)
            if(GetVectors(IB,OB,Pers,Outs,SymbolsArray[SymbolIdx],_Period,3,shift))
              {
               i++;
/*               copied=CopyRates(SymbolsArray[SymbolIdx],_Period,shift,3,rates);
               TimeToStruct(rates[2].time,tm);
               //               outstr=""+(string)tm.mon+" "+(string)tm.day+" "+(string)tm.day_of_week+" "+(string)tm.hour+" "+(string)tm.min;
               outstr=""+(string)tm.day_of_week+" "+(string)tm.hour;
               // news
               for(int ibj=0;ibj<MaxSymbols;ibj++)
                 {
                  outstr=outstr+" 0";
                 }*/
               // data
               for(int ibj=0;ibj<Pers;ibj++)
                 {
                  outstr=outstr+" "+(string)(IB[ibj]);
                 }
               for(int ibj=0;ibj<Outs;ibj++)
                 {
                  outstr=outstr+" "+(string)(OB[ibj]);
                 }

               FileWrite(FileHandle,outstr);       // 
               
              }
        }
     }
   FileClose(FileHandle);

   return(shift);
  }
  
string fTimeFrameName(int arg)
  {
   int v;
   if(arg==0)
     {
      v=_Period;
     }
   else
     {
      v=arg;
     }
   switch(v)
     {
      case PERIOD_M1:    return("M1");
      case PERIOD_M2:    return("M2");
      case PERIOD_M3:    return("M3");
      case PERIOD_M4:    return("M4");
      case PERIOD_M5:    return("M5");
      case PERIOD_M6:    return("M6");
      case PERIOD_M10:   return("M10");
      case PERIOD_M12:   return("M12");
      case PERIOD_M15:   return("M15");
      case PERIOD_M20:   return("M20");
      case PERIOD_M30:   return("M30");
      case PERIOD_H1:    return("H1");
      case PERIOD_H2:    return("H2");
      case PERIOD_H3:    return("H3");
      case PERIOD_H4:    return("H4");
      case PERIOD_H6:    return("H6");
      case PERIOD_H8:    return("H8");
      case PERIOD_H12:   return("H12");
      case PERIOD_D1:    return("D1");
      case PERIOD_W1:    return("W1");
      case PERIOD_MN1:   return("MN1");
      default:    return("?");
     }
  } // end fTimeFrameName


//+------------------------------------------------------------------+
//| Заполняем вектор ! вначале -выходы -потом вход                   |
//| просто разница                                                   |
//+------------------------------------------------------------------+

bool GetVectors(double &InputVector[],double &OutputVector[],int num_inputs=5,int num_outputs=1,string smbl="",ENUM_TIMEFRAMES tf=0,int npf=3,int shift=0)
  {// пара, период, смещение назад (для индикатора полезно)
   //int shft_his=7;
   //int shft_cur=0;

   if(""==smbl) smbl=_Symbol;
   if(0==tf) tf=_Period;
   double Close[];
   ArraySetAsSeries(Close,true); 
// копируем историю
   int maxcount=CopyClose(smbl,tf,shift,num_inputs+num_outputs+2,Close);
   ArrayInitialize(InputVector,EMPTY_VALUE);
   if(maxcount<num_inputs+num_outputs+1)
     {
      Print("Shift = ",shift," maxcount = ",maxcount);
      return(false);
     }
   int i;
   for(i=0;i<num_inputs;i++)
     {
      // вычислим и отнормируем
      InputVector[i]=100*(Close[i+1]-Close[i]);
     }
   for(i=0;i<num_outputs;i++)
     {
      // вычислим и отнормируем
      OutputVector[i]=100*(Close[num_inputs+i+1]-Close[num_inputs+i]);
     }
   return(true);
  }



//+------------------------------------------------------------------+
//| Заполняем вектор ! вначале -выходы -потом вход                   |
//| Фракталы                                                         |
//+------------------------------------------------------------------+

bool GetVectors_f(double &InputVector[],int num_vectors=5,string smbl="",ENUM_TIMEFRAMES tf=0,int npf=3,int shift=0)
  {// пара, период, смещение назад (для индикатора полезно)
   int shft_his=7;
   int shft_cur=0;

   if(""==smbl) smbl=_Symbol;
   if(0==tf) tf=_Period;
   double Low[],High[];
   ArraySetAsSeries(Low,true); ArraySetAsSeries(High,true);
// копируем историю
   int ncl=CopyLow(smbl,tf,shift,num_vectors*10*npf,Low);
   int nch=CopyHigh(smbl,tf,shift,num_vectors*10*npf,High);
   ArrayInitialize(InputVector,EMPTY_VALUE);
   int maxcount=MathMin(ncl,nch);
   if(maxcount<num_vectors*10*npf)
     {
      Print("Shift = ",shift," maxcount = ",maxcount);
      return(false);
     }
   double UpperBuffer[];
   double LowerBuffer[];
   ArrayResize(UpperBuffer,num_vectors*10*npf);
   ArrayResize(LowerBuffer,num_vectors*10*npf);
   ArrayInitialize(UpperBuffer,EMPTY_VALUE);
   ArrayInitialize(LowerBuffer,EMPTY_VALUE);
   int i,j;
   for(i=npf-1;i<maxcount-2;i++)
     {
      if(((5==npf) && (High[i]>High[i+1] && High[i]>High[i+2] && High[i]>=High[i-1] && High[i]>=High[i-2]))
         || ((3==npf) && ((High[i]>High[i+1] && High[i]>=High[i-1]))))
        {
         UpperBuffer[i]=High[i];
         // проверка что предыдущее тоже верх и ниже
         for(j=i-1;UpperBuffer[j]==EMPTY_VALUE && LowerBuffer[j]==EMPTY_VALUE && j>0;j--);
         if(UpperBuffer[j]==EMPTY_VALUE)
           {
            if(LowerBuffer[j]>UpperBuffer[i])UpperBuffer[i]=EMPTY_VALUE;// ExtUpperBuffer[i]=High[i];
           }
         else
           {
            if(UpperBuffer[j]>UpperBuffer[i]) UpperBuffer[i]=EMPTY_VALUE;
            else
              {
               UpperBuffer[j]=EMPTY_VALUE;
               for(j=i-1;UpperBuffer[j]==EMPTY_VALUE && LowerBuffer[j]==EMPTY_VALUE && j>0;j--);
               if(LowerBuffer[j]==EMPTY_VALUE);// ExtUpperBuffer[i]=High[i];
               else
                 {
                  if(LowerBuffer[j]<LowerBuffer[i]) LowerBuffer[i]=EMPTY_VALUE;
                  else LowerBuffer[j]=EMPTY_VALUE;
                 }
              }
           }
        }
      else UpperBuffer[i]=EMPTY_VALUE;

      //---- Lower Fractal
      if(((5==npf) && (Low[i]<Low[i+1] && Low[i]<Low[i+2] && Low[i]<=Low[i-1] && Low[i]<=Low[i-2]))
         || ((3==npf) && ((Low[i]<Low[i+1] && Low[i]<=Low[i-1]))))
        {
         LowerBuffer[i]=Low[i];
         // проверка что предыдущее тоже верх и ниже
         for(j=i-1;UpperBuffer[j]==EMPTY_VALUE && LowerBuffer[j]==EMPTY_VALUE && j>0;j--);
         if(LowerBuffer[j]==EMPTY_VALUE)
           {
            if(UpperBuffer[j]<LowerBuffer[i]) LowerBuffer[i]=EMPTY_VALUE;
           }
         else
           {
            if(LowerBuffer[j]<LowerBuffer[i]) LowerBuffer[i]=EMPTY_VALUE;
            else
              {
               LowerBuffer[j]=EMPTY_VALUE;
               for(j=i-1;UpperBuffer[j]==EMPTY_VALUE && LowerBuffer[j]==EMPTY_VALUE && j>0;j--);
               if(UpperBuffer[j]==EMPTY_VALUE);// ExtUpperBuffer[i]=High[i];
               else
                 {
                  if(UpperBuffer[j]>UpperBuffer[i]) UpperBuffer[i]=EMPTY_VALUE;
                 }
              }
           }

        }
      else LowerBuffer[i]=EMPTY_VALUE;
     }
// Возьмем num_vectors значимых элементов
// вначале проверим что последний "красивый" -тоесть на котором можно заработать
   int fp=npf-1;
   double prf=0,prl=0;
   if(UpperBuffer[fp]==EMPTY_VALUE && LowerBuffer[fp]==EMPTY_VALUE) return(false);// нет фрактала  
                                                                                  //   do
     {
      if(LowerBuffer[fp]==EMPTY_VALUE)// ExtUpperBuffer[i]=High[i];
         prf=UpperBuffer[fp];
      else  prf=LowerBuffer[fp];
      //fp=j;
      for(j=fp+1;UpperBuffer[j]==EMPTY_VALUE && LowerBuffer[j]==EMPTY_VALUE && j<maxcount;j++);
      if(LowerBuffer[j]==EMPTY_VALUE)// ExtUpperBuffer[i]=High[i];
         prl=UpperBuffer[j];
      else  prl=LowerBuffer[j];
     }
   if((MathAbs(prf-prl)/(SymbolInfoInteger(smbl,SYMBOL_SPREAD)*SymbolInfoDouble(smbl,SYMBOL_POINT)))>5)
     {
      // заполняем массив выходной 
      InputVector[0]=prf-prl;
      prf=prl;fp=j;
      for(i=0;i<num_vectors;i++)
        {
         for(j=fp+1;UpperBuffer[j]==EMPTY_VALUE && LowerBuffer[j]==EMPTY_VALUE && j<maxcount;j++);
         if(LowerBuffer[j]==EMPTY_VALUE)// ExtUpperBuffer[i]=High[i];
            prl=UpperBuffer[j];
         else  prl=LowerBuffer[j];
         InputVector[i+1]=100*(prf-prl);      prf=prl;fp=j;
        }

      return(true);// 
     }
   else
      return(false);// нет свечки  
   return(true);// нет свечки
  }
