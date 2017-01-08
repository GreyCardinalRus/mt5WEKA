//+------------------------------------------------------------------+
//|                                         NeuralEncogIndicator.mq5 |
//|                                      Copyright 2011, Investeo.pl |
//|                                                http:/Investeo.pl |
//+------------------------------------------------------------------+
//Из-за реализации в виде "двойной DLL-обертки под .NET", 
//файлы Cloo.dll, encog-core-cs.dll и log4net.dll нужно скопировать в каталог установки клиентского терминала. 
//Файл EncogNNTrainDLL.dll нужно скопировать в каталог папка_данных_клиентского_терминала\MQL5\Libraries\.

#property copyright "Copyright 2011, Investeo.pl"
#property link      "http:/Investeo.pl"
#property version   "1.00"
#property indicator_separate_window

#property indicator_plots 1
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1  2

#import "EncogNNTrainDLL.dll"
   int initializeTrainedNN(string nnFile);
   int computeNNIndicator(double& ind1[], double& ind2[],double& ind3[], int size, double& result[], int rates);  
#import


int INPUT_WINDOW = 6;
int PREDICT_WINDOW = 1;

double ind1Arr[], ind2Arr[], ind3Arr[]; 
double neuralArr[];

int hStochastic;
int hWilliamsR;

int hNeuralMA;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
    
   SetIndexBuffer(0, neuralArr, INDICATOR_DATA);
   
   PlotIndexSetInteger(0, PLOT_SHIFT, 1);

   ArrayResize(ind1Arr, INPUT_WINDOW);
   ArrayResize(ind2Arr, INPUT_WINDOW);
   ArrayResize(ind3Arr, INPUT_WINDOW);
     
   ArrayInitialize(neuralArr, 0.0);
   
   ArraySetAsSeries(ind1Arr, true);   
   ArraySetAsSeries(ind2Arr, true);  
   ArraySetAsSeries(ind3Arr, true);
  
   ArraySetAsSeries(neuralArr, true);   
   
            
   hStochastic = iStochastic(NULL, 0, 8, 5, 5, MODE_EMA, STO_LOWHIGH);
   hWilliamsR = iWPR(NULL, 0, 21);
 
   Print(TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\Files\step5_network.eg");
   initializeTrainedNN(TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\Files\step5_network.eg");
   
   
   
//---
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
   int calc_limit;
   
   if(prev_calculated==0) // First execution of the OnCalculate() function after the indicator start
        calc_limit=rates_total-34; 
   else calc_limit=rates_total-prev_calculated;
    
   ArrayResize(neuralArr, rates_total);
   
   
   for (int i=0; i<calc_limit; i++)     
   {
      CopyBuffer(hStochastic, 0, i, INPUT_WINDOW, ind1Arr);
      CopyBuffer(hStochastic, 1, i, INPUT_WINDOW, ind2Arr);
      CopyBuffer(hWilliamsR,  0, i, INPUT_WINDOW, ind3Arr);    
      
      computeNNIndicator(ind1Arr, ind2Arr, ind3Arr, INPUT_WINDOW, neuralArr, rates_total-i); 
   }
     
  //Print("neuralArr[0] = " + neuralArr[0]);
  
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
