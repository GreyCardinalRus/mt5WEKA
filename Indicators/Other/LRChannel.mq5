//+------------------------------------------------------------------+
//|                                                         LRCh.mq5 |
//|                                                      Vladimir M. |
//|                                                mikh.vl@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Vladimir M."
#property link      "mikh.vl@gmail.com"
#property version   "1.00"

#property description "Linear Regression Channel"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_style4  STYLE_DOT
#property indicator_style5  STYLE_DOT
#property indicator_color1  Blue
#property indicator_color2  Yellow
#property indicator_color3  Yellow
#property indicator_color4  Red
#property indicator_color5  Red
#property indicator_applied_price PRICE_CLOSE
//--- input params
input int InChPeriod = 150; //Channel Period

int ExChPeriod,rCount;
//---- buffers
double rlBuffer[],upBuffer[],downBuffer[],highBuffer[],lowBuffer[]; 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- check input variables
   int BarsTotal;
   BarsTotal=Bars(_Symbol,PERIOD_CURRENT);
   if(InChPeriod<2)
     {
      ExChPeriod=2;
      printf("Incorrect input value InChPeriod=%d. Indicator will use InChPeriod=%d.",
             InChPeriod,ExChPeriod);
     }
   else if(InChPeriod>=BarsTotal)
     {
      ExChPeriod=BarsTotal-1;
      printf("Total Bars=%d. Incorrect input value InChPeriod=%d. Indicator will use InChPeriod=%d.",
             BarsTotal,InChPeriod,ExChPeriod);
     }
   else ExChPeriod=InChPeriod;
   
   SetIndexBuffer(0,rlBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,upBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,downBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,highBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,lowBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,BarsTotal-ExChPeriod-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,BarsTotal-ExChPeriod-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,BarsTotal-ExChPeriod-1);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,BarsTotal-ExChPeriod-1);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,BarsTotal-ExChPeriod-1);
   PlotIndexSetString(0,PLOT_LABEL,"Main Line("+string(ExChPeriod)+")");
   PlotIndexSetString(1,PLOT_LABEL,"Up Line("+string(ExChPeriod)+")");
   PlotIndexSetString(2,PLOT_LABEL,"Down Line("+string(ExChPeriod)+")");
   PlotIndexSetString(3,PLOT_LABEL,"High Line("+string(ExChPeriod)+")");
   PlotIndexSetString(4,PLOT_LABEL,"Low Line("+string(ExChPeriod)+")");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[])
   {
    double sumX,sumY,sumXY,sumX2,a,b,F,S;
    int X;
//--- check for bars count
    if(rates_total<ExChPeriod+1)return(0);
//--- if  new bar set, calculate    
    if(rCount!=rates_total)
      {
//--- calculate coefficient a and b of equation linear regression 
       F=0.0;
       S=0.0;
       sumX=0.0;
       sumY=0.0;
       sumXY=0.0;
       sumX2=0.0;
       X=0;
       for(int i=rates_total-1-ExChPeriod;i<rates_total-1;i++)
         {
          sumX+=X;
          sumY+=price[i];
          sumXY+=X*price[i];
          sumX2+=MathPow(X,2);
          X++;
         }
       a=(sumX*sumY-ExChPeriod*sumXY)/(MathPow(sumX,2)-ExChPeriod*sumX2);
       b=(sumY-a*sumX)/ExChPeriod;
//--- calculate values of main line and error F
       X=0;
       for(int i=rates_total-1-ExChPeriod;i<rates_total;i++)
         {
          rlBuffer[i]=b+a*X;
          F+=MathPow(price[i]-rlBuffer[i],2);
          X++;
         }
//--- calculate deviation S       
       S=NormalizeDouble(MathSqrt(F/(ExChPeriod+1))/MathCos(MathArctan(a*M_PI/180)*M_PI/180),_Digits);
//--- calculate values of last buffers
       for(int i=rates_total-1-ExChPeriod;i<rates_total;i++)
         {
          upBuffer[i]=rlBuffer[i]+S;
          downBuffer[i]=rlBuffer[i]-S;
          highBuffer[i]=rlBuffer[i]+2*S;
          lowBuffer[i]=rlBuffer[i]-2*S;
         }
 
        rCount=rates_total;
      }
      
    return(rates_total);
   }
//+------------------------------------------------------------------+
