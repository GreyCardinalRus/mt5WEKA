//+------------------------------------------------------------------+
//|                                           MultiCurrencyIndex.mq5 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "2010, olyakish"
#property version   "1.1"
#property indicator_separate_window

#property indicator_buffers 31
#property indicator_plots   8
//+------------------------------------------------------------------+
//| ������������ ����� ����������                                    |
//+------------------------------------------------------------------+
double Calculate_val(string smbl,ENUM_TIMEFRAMES tf,int limit,double &buf)
 {
 return (0);
 }
class CMultiCurr
{
private:
   string SymbolsArray[100];
   int SymbolCount;
   string Currencies[50];
   int CreateSymbolList(string smbl,int direct);
   int init_tf();
 public:
 CMultiCurr() ;
  void Init(string smbl);
  bool Calculate(string smbl,ENUM_TIMEFRAMES tf,int limit);
  double plotPlus[];
  double plotMinus[];
  double plotResult[];
 
};
void CMultiCurr::Init(string smbl)
 {
//   Print("Plus Plus");
   CreateSymbolList(StringSubstr(smbl,0,3),1);
//   Print("Plus Minus");
   CreateSymbolList(StringSubstr(smbl,0,3),-1);
//   Print("Minus Plus");
   CreateSymbolList(StringSubstr(smbl,3,3),1);
//   Print("Minus Minus");
   CreateSymbolList(StringSubstr(smbl,3,3),-1);
 
 }
bool CMultiCurr::Calculate(string smbl,ENUM_TIMEFRAMES tf,int limit)
 {
   int copied;
   init_tf();
   //plus ...
   int p=CreateSymbolList(StringSubstr(smbl,0,3),1);
   
   if(EUR){copied=CopyClose("EURUSD",tf,0,shiftbars,EURUSD);if(copied==-1){f_comment("�����...EURUSD");return(0);}}
   if(GBP){copied=CopyClose("GBPUSD",tf,0,shiftbars,GBPUSD);if(copied==-1){f_comment("�����...GBPUSD");return(0);}}
   if(CHF){copied=CopyClose("USDCHF",tf,0,shiftbars,USDCHF);if(copied==-1){f_comment("�����...USDCHF");return(0);}}
   if(JPY){copied=CopyClose("USDJPY",tf,0,shiftbars,USDJPY);if(copied==-1){f_comment("�����...USDJPY");return(0);}}
   if(AUD){copied=CopyClose("AUDUSD",tf,0,shiftbars,AUDUSD);if(copied==-1){f_comment("�����...AUDUSD");return(0);}}
   if(CAD){copied=CopyClose("USDCAD",tf,0,shiftbars,USDCAD);if(copied==-1){f_comment("�����...USDCAD");return(0);}}
   if(NZD){copied=CopyClose("NZDUSD",tf,0,shiftbars,NZDUSD);if(copied==-1){f_comment("�����...NZDUSD");return(0);}}

   for(i=limit-1;i>=0;i--)
     {
      //������ ������� USD
      USDx[i]=1.0;
      if(EUR){USDx[i]+=EURUSD[i];}
      if(GBP){USDx[i]+=GBPUSD[i];}
      if(CHF){USDx[i]+=1/USDCHF[i];}
      if(JPY){USDx[i]+=1/USDJPY[i];}
      if(CAD){USDx[i]+=1/USDCAD[i];}
      if(AUD){USDx[i]+=AUDUSD[i];}
      if(NZD){USDx[i]+=NZDUSD[i];}
      USDx[i]=1/USDx[i];
      //������ ��������� �������� �����
      if(EUR){EURx[i]=EURUSD[i]*USDx[i];}
      if(GBP){GBPx[i]=GBPUSD[i]*USDx[i];}
      if(CHF){CHFx[i]=USDx[i]/USDCHF[i];}
      if(JPY){JPYx[i]=USDx[i]/USDJPY[i];}
      if(CAD){CADx[i]=USDx[i]/USDCAD[i];}
      if(AUD){AUDx[i]=AUDUSD[i]*USDx[i];}
      if(NZD){NZDx[i]=NZDUSD[i]*USDx[i];}
     }
//�������� ����������� ������ ��� ��������� � ����������� �� ���������� ���������� ����������
   if(ind_type==Use_RSI_on_indexes)
     {
      if(limit>1){ii=limit-rsi_period-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         if(StringSubstr(_Symbol,0,3)=="USD") MultiCurr.plotPlus[i]=f_RSI(USDx,rsi_period,i);
         else if (StringSubstr(_Symbol,3,3)=="USD") MultiCurr.plotMinus[i]=110-f_RSI(USDx,rsi_period,i);
         if(StringSubstr(_Symbol,0,3)=="EUR") plotPlus[i]=f_RSI(EURx,rsi_period,i);
         else if (StringSubstr(_Symbol,3,3)=="EUR") plotMinus[i]=110-f_RSI(EURx,rsi_period,i);
         if(StringSubstr(_Symbol,0,3)=="GBP") plotPlus[i]=f_RSI(GBPx,rsi_period,i);
         else if (StringSubstr(_Symbol,3,3)=="GBP") plotMinus[i]=110-f_RSI(GBPx,rsi_period,i);
         if(StringSubstr(_Symbol,0,3)=="NZD") plotPlus[i]=f_RSI(NZDx,rsi_period,i);
         else if (StringSubstr(_Symbol,3,3)=="NZD") plotMinus[i]=110-f_RSI(NZDx,rsi_period,i);
         if(StringSubstr(_Symbol,0,3)=="AUD") plotPlus[i]=f_RSI(AUDx,rsi_period,i);
         else if (StringSubstr(_Symbol,3,3)=="AUD") plotMinus[i]=110-f_RSI(AUDx,rsi_period,i);
         if(StringSubstr(_Symbol,0,3)=="CAD") plotPlus[i]=f_RSI(CADx,rsi_period,i);
         else if (StringSubstr(_Symbol,3,3)=="CAD") plotMinus[i]=110-f_RSI(CADx,rsi_period,i);
         if(StringSubstr(_Symbol,0,3)=="JPY") plotPlus[i]=f_RSI(JPYx,rsi_period,i);
         else if (StringSubstr(_Symbol,3,3)=="JPY") plotMinus[i]=110-f_RSI(JPYx,rsi_period,i);
         if(StringSubstr(_Symbol,0,3)=="CHF") plotPlus[i]=f_RSI(CHFx,rsi_period,i);
         else if (StringSubstr(_Symbol,3,3)=="CHF") plotMinus[i]=110-f_RSI(CHFx,rsi_period,i);

//         if(USD){USDplot[i]=f_RSI(USDx,rsi_period,i);}
//         if(EUR){EURplot[i]=f_RSI(EURx,rsi_period,i);}
//         if(GBP){GBPplot[i]=f_RSI(GBPx,rsi_period,i);}
//         if(CHF){CHFplot[i]=f_RSI(CHFx,rsi_period,i);}
//         if(JPY){JPYplot[i]=f_RSI(JPYx,rsi_period,i);}
//         if(CAD){CADplot[i]=f_RSI(CADx,rsi_period,i);}
//         if(AUD){AUDplot[i]=f_RSI(AUDx,rsi_period,i);}
//         if(NZD){NZDplot[i]=f_RSI(NZDx,rsi_period,i);}
         plotResult[i]=(plotPlus[i]+plotMinus[i])/2; 
        }
     }
   if(ind_type==Use_MACD_on_indexes)
     {
      if(limit>1){ii=limit-MACD_slow-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         //if(USD){USDplot[i]=f_MACD(USDx,MACD_fast,MACD_slow,i);}
         //if(EUR){EURplot[i]=f_MACD(EURx,MACD_fast,MACD_slow,i);}
         //if(GBP){GBPplot[i]=f_MACD(GBPx,MACD_fast,MACD_slow,i);}
         //if(CHF){CHFplot[i]=f_MACD(CHFx,MACD_fast,MACD_slow,i);}
         //if(JPY){JPYplot[i]=f_MACD(JPYx,MACD_fast,MACD_slow,i);}
         //if(CAD){CADplot[i]=f_MACD(CADx,MACD_fast,MACD_slow,i);}
         //if(AUD){AUDplot[i]=f_MACD(AUDx,MACD_fast,MACD_slow,i);}
         //if(NZD){NZDplot[i]=f_MACD(NZDx,MACD_fast,MACD_slow,i);}
        }
     }
   if(ind_type==Use_Stochastic_Main_on_indexes)
     {
      if(limit>1){ii=limit-Stoch_period_k-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
         //if(USD){USDStoch[i]=f_Stoch(USDx,rsi_period,i);}
         //if(EUR){EURStoch[i]=f_Stoch(EURx,Stoch_period_k,i);}
         //if(GBP){GBPStoch[i]=f_Stoch(GBPx,Stoch_period_k,i);}
         //if(CHF){CHFStoch[i]=f_Stoch(CHFx,Stoch_period_k,i);}
         //if(JPY){JPYStoch[i]=f_Stoch(JPYx,Stoch_period_k,i);}
         //if(CAD){CADStoch[i]=f_Stoch(CADx,Stoch_period_k,i);}
         //if(AUD){AUDStoch[i]=f_Stoch(AUDx,Stoch_period_k,i);}
         //if(NZD){NZDStoch[i]=f_Stoch(NZDx,Stoch_period_k,i);}
        }
      if(limit>1){ii=limit-Stoch_period_sma-1;}
      else{ii=limit-1;}
      for(i=ii;i>=0;i--)
        {
        // if(USD){USDplot[i]=SimpleMA(i,Stoch_period_sma,USDStoch);}
        // if(EUR){EURplot[i]=SimpleMA(i,Stoch_period_sma,EURStoch);}
        // if(GBP){GBPplot[i]=SimpleMA(i,Stoch_period_sma,GBPStoch);}
        // if(CHF){CHFplot[i]=SimpleMA(i,Stoch_period_sma,CHFStoch);}
        // if(JPY){JPYplot[i]=SimpleMA(i,Stoch_period_sma,JPYStoch);}
        // if(CAD){CADplot[i]=SimpleMA(i,Stoch_period_sma,CADStoch);}
        // if(AUD){AUDplot[i]=SimpleMA(i,Stoch_period_sma,AUDStoch);}
        // if(NZD){NZDplot[i]=SimpleMA(i,Stoch_period_sma,NZDStoch);}
        }

     } return(true);
 }
 CMultiCurr::CMultiCurr() 
 {
   ArraySetAsSeries(plotPlus,true);                             // ���������� ������� ��� ���������
   ArrayInitialize(plotPlus,EMPTY_VALUE);                       // ������� �������� 
   ArraySetAsSeries(plotMinus,true);                             // ���������� ������� ��� ���������
   ArrayInitialize(plotMinus,EMPTY_VALUE);                       // ������� ��������
   ArraySetAsSeries(plotResult,true);                             // ���������� ������� ��� ���������
   ArrayInitialize(plotResult,EMPTY_VALUE);                       // ������� ��������
 };

enum Indicator_Type
  {
   Use_RSI_on_indexes=1,               // RSI �� �������
   Use_MACD_on_indexes=2,              // MACD �� �������
   Use_Stochastic_Main_on_indexes=3     // Stochastic �� �������
  };
input Indicator_Type ind_type=Use_RSI_on_indexes;  // ��� ���������� �� �������
int vals=8;
string valuts[]={"USD","EUR","GPB","JPY","CHF","CAD","AUD","NZD"};
bool valutssel[]={true,true,true,true,true,true,true,true};
bool USD=true;
bool EUR=true;
bool GBP=true;
bool JPY=true;
bool CHF=true;
bool CAD=true;
bool AUD=true;
bool NZD=true;
input string rem000="";       //   � ����������� �� ���� ����������
input string rem0000="";      //   ����������� �������� :
input int rsi_period=9;       // ������ RSI
input int MACD_fast=5;        // ������ MACD_fast
input int MACD_slow=34;       // ������ MACD_slow
input int Stoch_period_k=8;    // ������ Stochastic %K
input int Stoch_period_sma=5;  // ������ ����������� ��� Stochastic %K
input int shiftbars=500;      // ���������� ����� ��� ������� ����������

//input color Color_USD = Green;            // ���� ����� USD
//input color Color_EUR = DarkBlue;         // ���� ����� EUR
//input color Color_GBP = Red;              // ���� ����� GBP
//input color Color_CHF = Chocolate;        // ���� ����� CHF
//input color Color_JPY = Maroon;           // ���� ����� JPY
//input color Color_AUD = DarkOrange;       // ���� ����� AUD
//input color Color_CAD = Purple;           // ���� ����� CAD
//input color Color_NZD = Teal;             // ���� ����� NZD


input int wid_main=2; //������� ����� ������������ �������� �������
input ENUM_LINE_STYLE style_slave=STYLE_DOT; //����� �������������� ����� ������������ �������� �������
//double pairs[8][500];
//double valsx[8][500];
//double valsStoch[8][500];
double EURUSD[],GBPUSD[],USDCHF[],USDJPY[],AUDUSD[],USDCAD[],NZDUSD[]; // ���������
double USDx[],EURx[],GBPx[],JPYx[],CHFx[],CADx[],AUDx[],NZDx[];        // �������
//double USDplot[],EURplot[],GBPplot[],JPYplot[],CHFplot[],CADplot[],AUDplot[],NZDplot[]; // �������� ����� �� �������
double USDStoch[],EURStoch[],GBPStoch[],JPYStoch[],CHFStoch[],CADStoch[],AUDStoch[],NZDStoch[]; // ������ ������������� ������ ���������� �� ���� close/close ��� �����������
                                                                                        // ������������� �������� �������
// 0-7 ������������ - ������ ��� ��������� �������� �����
// 8-14 ������������ - ������  �������� �������� ��� ���������� � ���� USD
// 15-22 ������������ - ������ �������� �����
// 23-30 ������������ - ������ ������������� ������ ���������� �� ���� close/close ��� ����������� 

int i,ii;
int y_pos=0;          // ���������� Y ���������� ��� �������������� ��������

datetime arrTime[7];  // ������ � ��������� ��������� �������� �������� ���� (����� ��� �������������)
int bars_tf[7];       // ��� �������� ���������� ��������� ����� �� ������ �������� �����
int countVal=0;       // ���������� �������������� �����
int index=0;
datetime tmp_time[1]; // ������������� ������ ��� ������� ����
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
CMultiCurr MultiCurr;
void OnInit()
  {
  MultiCurr.Init(_Symbol);
  //CreateSymbolList(_Symbol); // QC
   if(ind_type==1 || ind_type==3)
     {
      IndicatorSetInteger(INDICATOR_DIGITS,1);                    // ���������� ������ ����� ������� ���� RSI ��� Stochastic
     }
   if(ind_type==2)
     {
      IndicatorSetInteger(INDICATOR_DIGITS,5);                    // ���������� ������ ����� ������� ���� MACD
     }
   int i=0;
//   for(i=0;i<8;i++) if((StringSubstr(_Symbol,0,3)==valuts[i])||(StringSubstr(_Symbol,3,3)==valuts[i])) valutssel[i]=true;
   f_draw(StringSubstr(_Symbol,0,3),Green);                                    // ��������� � ���� ���������� ���������� 
   f_draw(StringSubstr(_Symbol,3,3),Red);                                    // ��������� � ���� ���������� ���������� 

   string nameInd="MultiCurrencyIndex";
   if(ind_type==Use_RSI_on_indexes){nameInd+=" RSI("+IntegerToString(rsi_period)+")";}
   if(ind_type==Use_MACD_on_indexes){nameInd+=" MACD("+IntegerToString(MACD_fast)+","+IntegerToString(MACD_slow)+")";}
   if(ind_type==Use_Stochastic_Main_on_indexes){nameInd+=" Stochastic("+IntegerToString(Stoch_period_k)+","+IntegerToString(Stoch_period_sma)+")";}
   IndicatorSetString(INDICATOR_SHORTNAME,nameInd);
   SetIndexBuffer(0,MultiCurr.plotPlus,INDICATOR_DATA);                   // ������ ��� ���������
   PlotIndexSetString(0,PLOT_LABEL,"USDplot");                 // ��� ����� �� ���������� (��� ��������� �����)
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,shiftbars);           // ������ �������� ���������
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);            // ����� ��������� (�����)
   {PlotIndexSetInteger(0,PLOT_LINE_WIDTH,1);}        // ���� USD ������������ � ����� ������� �� ������ ����� ��������������� ������� 
   {PlotIndexSetInteger(0,PLOT_LINE_STYLE,style_slave);}
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,Green);           // ���� ����� ���������

   SetIndexBuffer(1,MultiCurr.plotMinus,INDICATOR_DATA);                   // ������ ��� ���������
   PlotIndexSetString(1,PLOT_LABEL,"EURplot");                 // ��� ����� �� ���������� (��� ��������� �����)
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,shiftbars);           // ������ �������� ���������
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);            // ����� ��������� (�����)
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,Red);           // ���� ����� ���������
   {PlotIndexSetInteger(1,PLOT_LINE_WIDTH,1);}        // ���� EUR ������������ � ����� �������
   {PlotIndexSetInteger(1,PLOT_LINE_STYLE,style_slave);}

   SetIndexBuffer(2,MultiCurr.plotResult,INDICATOR_DATA);                   // ������ ��� ���������
   PlotIndexSetString(2,PLOT_LABEL,"EURplot");                 // ��� ����� �� ���������� (��� ��������� �����)
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,shiftbars);           // ������ �������� ���������
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);            // ����� ��������� (�����)
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,Violet);           // ���� ����� ���������
   {PlotIndexSetInteger(2,PLOT_LINE_WIDTH,1);}        // ���� EUR ������������ � ����� �������

   if(USD)
     {
      countVal++;
//      f_draw("USD",Color_USD);                                    // ��������� � ���� ���������� ���������� 
     }
   SetIndexBuffer(15,USDx,INDICATOR_CALCULATIONS);                // ������ ��� ������� ������� ��� �������� (�� ������������ �� ���������� � ���� �����) 
   ArraySetAsSeries(USDx,true);                                   // ���������� ������� ��� ���������
   ArrayInitialize(USDx,EMPTY_VALUE);                             // ������� ��������
   if(ind_type==Use_Stochastic_Main_on_indexes)
     {
      SetIndexBuffer(23,USDStoch,INDICATOR_CALCULATIONS);          // ���� ���������� ���������� ��� Use_Stochastic_Main_on_indexes �� ����� ��� ���� ������������� ������
      ArraySetAsSeries(USDStoch,true);                             // ���������� ������� ��� ���������
      ArrayInitialize(USDStoch,EMPTY_VALUE);                       // ������� ��������
     }

   if(EUR)
     {
      countVal++;
      SetIndexBuffer(8,EURUSD,INDICATOR_CALCULATIONS);            // ������ Close �������� ���� EURUSD
      ArraySetAsSeries(EURUSD,true);                              // ���������� ������� ��� ���������
      ArrayInitialize(EURUSD,EMPTY_VALUE);                        // ������� ��������
      SetIndexBuffer(16,EURx,INDICATOR_CALCULATIONS);             // ������ ��� ������� ���� ��� ��������
                                                                  // (�� ������������ �� ���������� � ���� �����) 
      ArraySetAsSeries(EURx,true);
      ArrayInitialize(EURx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(24,EURStoch,INDICATOR_CALCULATIONS);       // ���� ���������� ���������� ��� Use_Stochastic_Main_on_indexes,
                                                                  // �� ����� ��� ���� ������������� ������
         ArraySetAsSeries(EURStoch,true);                          // ���������� ������� ��� ���������
         ArrayInitialize(EURStoch,EMPTY_VALUE);                    // ������� ��������
        }
//      f_draw("EUR",Color_EUR);                                    // ��������� � ���� ���������� ����������
     }
   if(GBP)
     {
      countVal++;
      //SetIndexBuffer(2,GBPplot,INDICATOR_DATA);
      //PlotIndexSetString(2,PLOT_LABEL,"GBPplot");
      //PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,shiftbars);
      //PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);
      //PlotIndexSetInteger(2,PLOT_LINE_COLOR,Color_GBP);
      //if(StringFind(Symbol(),"GBP",0)!=-1)
      //  {PlotIndexSetInteger(2,PLOT_LINE_WIDTH,wid_main);}
      //else
      //  {PlotIndexSetInteger(2,PLOT_LINE_STYLE,style_slave);}
      //ArraySetAsSeries(GBPplot,true);
      //ArrayInitialize(GBPplot,EMPTY_VALUE);
      SetIndexBuffer(9,GBPUSD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(GBPUSD,true);
      ArrayInitialize(GBPUSD,EMPTY_VALUE);
      SetIndexBuffer(17,GBPx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(GBPx,true);
      ArrayInitialize(GBPx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(25,GBPStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(GBPStoch,true);
         ArrayInitialize(GBPStoch,EMPTY_VALUE);
        }
//      f_draw("GBP",Color_GBP);
     }
   if(JPY)
     {
      countVal++;
      //SetIndexBuffer(3,JPYplot,INDICATOR_DATA);
      //PlotIndexSetString(3,PLOT_LABEL,"JPYplot");
      //PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,shiftbars);
      //PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_LINE);
      //PlotIndexSetInteger(3,PLOT_LINE_COLOR,Color_JPY);
      //if(StringFind(Symbol(),"JPY",0)!=-1)
      //  {PlotIndexSetInteger(3,PLOT_LINE_WIDTH,wid_main);}
      //else
      //  {PlotIndexSetInteger(3,PLOT_LINE_STYLE,style_slave);}
      //ArraySetAsSeries(JPYplot,true);
      //ArrayInitialize(JPYplot,EMPTY_VALUE);
      SetIndexBuffer(10,USDJPY,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(USDJPY,true);
      ArrayInitialize(USDJPY,EMPTY_VALUE);
      SetIndexBuffer(18,JPYx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(JPYx,true);
      ArrayInitialize(JPYx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(26,JPYStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(JPYStoch,true);
         ArrayInitialize(JPYStoch,EMPTY_VALUE);
        }
//      f_draw("JPY",Color_JPY);
     }
   if(CHF)
     {
      countVal++;
      //SetIndexBuffer(4,CHFplot,INDICATOR_DATA);
      //PlotIndexSetString(4,PLOT_LABEL,"CHFplot");
      //PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,shiftbars);
      //PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_LINE);
      //PlotIndexSetInteger(4,PLOT_LINE_COLOR,Color_CHF);
      //if(StringFind(Symbol(),"CHF",0)!=-1)
      //  {PlotIndexSetInteger(4,PLOT_LINE_WIDTH,wid_main);}
      //else
      //  {PlotIndexSetInteger(4,PLOT_LINE_STYLE,style_slave);}
      //ArraySetAsSeries(CHFplot,true);
      //ArrayInitialize(CHFplot,EMPTY_VALUE);
      SetIndexBuffer(11,USDCHF,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(USDCHF,true);
      ArrayInitialize(USDCHF,EMPTY_VALUE);
      SetIndexBuffer(19,CHFx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(CHFx,true);
      ArrayInitialize(CHFx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(27,CHFStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(CHFStoch,true);
         ArrayInitialize(CHFStoch,EMPTY_VALUE);
        }
//      f_draw("CHF",Color_CHF);
     }
   if(CAD)
     {
      countVal++;
      //SetIndexBuffer(5,CADplot,INDICATOR_DATA);
      //PlotIndexSetString(5,PLOT_LABEL,"CADplot");
      //PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,shiftbars);
      //PlotIndexSetInteger(5,PLOT_DRAW_TYPE,DRAW_LINE);
      //PlotIndexSetInteger(5,PLOT_LINE_COLOR,Color_CAD);
      //if(StringFind(Symbol(),"CAD",0)!=-1)
      //  {PlotIndexSetInteger(5,PLOT_LINE_WIDTH,wid_main);}
      //else
      //  {PlotIndexSetInteger(5,PLOT_LINE_STYLE,style_slave);}
      //ArraySetAsSeries(CADplot,true);
      //ArrayInitialize(CADplot,EMPTY_VALUE);
      //SetIndexBuffer(12,USDCAD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(USDCAD,true);
      ArrayInitialize(USDCAD,EMPTY_VALUE);
      SetIndexBuffer(20,CADx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(CADx,true);
      ArrayInitialize(CADx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(28,CADStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(CADStoch,true);
         ArrayInitialize(CADStoch,EMPTY_VALUE);
        }
//      f_draw("CAD",Color_CAD);
     }
   if(AUD)
     {
      countVal++;
      //SetIndexBuffer(6,AUDplot,INDICATOR_DATA);
      //PlotIndexSetString(6,PLOT_LABEL,"AUDplot");
      //PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,shiftbars);
      //PlotIndexSetInteger(6,PLOT_DRAW_TYPE,DRAW_LINE);
      //PlotIndexSetInteger(6,PLOT_LINE_COLOR,Color_AUD);
      //if(StringFind(Symbol(),"AUD",0)!=-1)
      //  {PlotIndexSetInteger(6,PLOT_LINE_WIDTH,wid_main);}
      //else
      //  {PlotIndexSetInteger(6,PLOT_LINE_STYLE,style_slave);}
      //ArraySetAsSeries(AUDplot,true);
      //ArrayInitialize(AUDplot,EMPTY_VALUE);
      SetIndexBuffer(13,AUDUSD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(AUDUSD,true);
      ArrayInitialize(AUDUSD,EMPTY_VALUE);
      SetIndexBuffer(21,AUDx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(AUDx,true);
      ArrayInitialize(AUDx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(29,AUDStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(AUDStoch,true);
         ArrayInitialize(AUDStoch,EMPTY_VALUE);
        }
//      f_draw("AUD",Color_AUD);
     }
   if(NZD)
     {
      countVal++;
      //SetIndexBuffer(7,NZDplot,INDICATOR_DATA);
      //PlotIndexSetString(7,PLOT_LABEL,"NZDplot");
      //PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,shiftbars);
      //PlotIndexSetInteger(7,PLOT_DRAW_TYPE,DRAW_LINE);
      //PlotIndexSetInteger(7,PLOT_LINE_COLOR,Color_NZD);
      //if(StringFind(Symbol(),"NZD",0)!=-1)
      //  {PlotIndexSetInteger(7,PLOT_LINE_WIDTH,wid_main);}
      //else
      //  {PlotIndexSetInteger(7,PLOT_LINE_STYLE,style_slave);}
      //ArraySetAsSeries(NZDplot,true);
      //ArrayInitialize(NZDplot,EMPTY_VALUE);
      SetIndexBuffer(14,NZDUSD,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(NZDUSD,true);
      ArrayInitialize(NZDUSD,EMPTY_VALUE);
      SetIndexBuffer(22,NZDx,INDICATOR_CALCULATIONS);
      ArraySetAsSeries(NZDx,true);
      ArrayInitialize(NZDx,EMPTY_VALUE);
      if(ind_type==Use_Stochastic_Main_on_indexes)
        {
         SetIndexBuffer(30,NZDStoch,INDICATOR_CALCULATIONS);
         ArraySetAsSeries(NZDStoch,true);
         ArrayInitialize(NZDStoch,EMPTY_VALUE);
        }
  //    f_draw("NZD",Color_NZD);
     }
   ArrayResize(arrTime,countVal-1);
   ArrayResize(bars_tf,countVal-1);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int limit=shiftbars;

   if(prev_calculated>0)
     {limit=1;}
   else
     {limit=shiftbars;}
   MultiCurr.Calculate(_Symbol,_Period,limit);
// ������������� �������� ��������������� �������� ���
   ////init_tf();


   return(rates_total);
  }
//+------------------------------------------------------------------+
///                        ��������������� �������
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
///                        ������ RSI
//+------------------------------------------------------------------+
double f_RSI(double &buf_in[],int period,int shift)
  {
   double pos=0.00000000,neg=0.00000000;
   double diff=0.0;
   for(int j=shift;j<=shift+period;j++)
     {
      diff=buf_in[j]-buf_in[j+1];
      pos+=(diff>0?diff:0.0);
      neg+=(diff<0?-diff:0.0);
     }
   if(neg<0.000000001){return(100.0);}//������ �� ������� �� ����
   pos/=period;
   neg/=period;
   return(100.0 -(100.0/(1.0+pos/neg)));
  }
//+------------------------------------------------------------------+
///                        ������ MACD
//+------------------------------------------------------------------+   
double f_MACD(double &buf_in[],int period_fast,int period_slow,int shift)
  {
   return(SimpleMA(shift,period_fast,buf_in)-SimpleMA(shift,period_slow,buf_in));
  }
//+------------------------------------------------------------------+
///                        ������ SMA
//+------------------------------------------------------------------+   
double SimpleMA(const int position,const int period,const double &price[])
  {
   double result=0.0;
   for(int i=0;i<period;i++) result+=price[position+i];
   result/=period;
   return(result);
  }
//+------------------------------------------------------------------+
///        ������ Stochastic close/close ��� �����������
//+------------------------------------------------------------------+   
double f_Stoch(double &price[],int period_k,int shift)
  {
   double result=0.0;
   double max=price[ArrayMaximum(price,shift,period_k)];
   double min=price[ArrayMinimum(price,shift,period_k)];
   result=(price[shift]-min)/(max-min)*100.0;
   return(result);
  }
//+------------------------------------------------------------------+
///        ��������� ������� 
//+------------------------------------------------------------------+   
int f_draw(string name,color _color)
  {
   ObjectCreate(0,name,OBJ_LABEL,ChartWindowFind(),0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,0);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y_pos);
   ObjectSetString(0,name,OBJPROP_TEXT,name);
   ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
   y_pos+=15;
   return(0);
  }
//+------------------------------------------------------------------+
///        ����������� � ������ ������ ���� ���������� 
//+------------------------------------------------------------------+   
int f_comment(string  text)
  {
   string name="f_comment";
   color _color=Crimson;
   if(ObjectFind(0,name)>=0){ObjectSetString(0,name,OBJPROP_TEXT,text);}
   else
     {
      ObjectCreate(0,name,OBJ_LABEL,ChartWindowFind(),0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,0);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,0);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_COLOR,_color);
     }
   return(0);
  }
//+------------------------------------------------------------------+
///        ������������� ��������������� �� �������� ��� 
//+------------------------------------------------------------------+   
int CMultiCurr::init_tf()
  {
   int copy;
   ArrayInitialize(arrTime,0);
   ArrayInitialize(bars_tf,0);
   bool writeComment=true;
   for(int n=0;n<10;n++) // ����  ��� ������������� ��������������� �������� ��� ����������� ��
     {
      index=0;
      int exit=-1;
      if(writeComment){f_comment("���� ������������� ��");writeComment=false;}
      if(EUR)
        {
         bars_tf[index]=Bars("EURUSD",PERIOD_CURRENT);
         copy=CopyTime("EURUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(GBP)
        {
         bars_tf[index]=Bars("GBPUSD",PERIOD_CURRENT);
         copy=CopyTime("GBPUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(CHF)
        {
         bars_tf[index]=Bars("USDCHF",PERIOD_CURRENT);
         copy=CopyTime("USDCHF",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(JPY)
        {
         bars_tf[index]=Bars("USDJPY",PERIOD_CURRENT);
         copy=CopyTime("USDJPY",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(CAD)
        {
         bars_tf[index]=Bars("USDCAD",PERIOD_CURRENT);
         copy=CopyTime("USDCAD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(AUD)
        {
         bars_tf[index]=Bars("AUDUSD",PERIOD_CURRENT);
         copy=CopyTime("AUDUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
         index++;
        }
      if(NZD)
        {
         bars_tf[index]=Bars("NZDUSD",PERIOD_CURRENT);
         copy=CopyTime("NZDUSD",PERIOD_CURRENT,0,1,tmp_time);
         arrTime[index]=tmp_time[0];
        }

      for(int h=1;h<=index;h++)
        {
         if(arrTime[0]==arrTime[h]&&  arrTime[0]!=0 && exit==-1){exit=1;}
         if(arrTime[0]!=arrTime[h] &&  arrTime[0]!=0 && exit==1){exit=0;}
         if(bars_tf[h]<shiftbars){exit=0;}
        }
      if(exit==1){f_comment("���������� ����������������");return(0);}
     }
   f_comment("���������� ������������� ��");
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| ������� ������ ��������� �������� �������� |
//+------------------------------------------------------------------+
int CMultiCurr::CreateSymbolList(string smbl,int direct=0) // QC
  {
SymbolCount=0;


   //string SymbolsArray[100];
   //int SymbolCount;
   //string Currencies[50];
   int CurrencyCount = SymbolsTotal(true);
   int Loop;
   string TempSymbol;
   for(Loop = 0; Loop < CurrencyCount; Loop++) 
    {
     Currencies[Loop]=SymbolName(Loop,true);
    }
   // ������
     if (direct>=0)
      {
     for(Loop = 0; Loop < CurrencyCount; Loop++)// for(SubLoop = 0; SubLoop < CurrencyCount; SubLoop++)
      {
// string str=StringSubstr(_Symbol,3,3);
       if(StringSubstr(smbl,0,3)==StringSubstr(Currencies[Loop],0,3))
        {
         TempSymbol = Currencies[Loop];
         if((TempSymbol!=smbl))//&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1)))//&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      }
     for(Loop = 0; Loop < CurrencyCount; Loop++)
      {
       if(StringSubstr(smbl,3,3)==StringSubstr(Currencies[Loop],3,3))
        {
         TempSymbol = Currencies[Loop];
         if((TempSymbol!=smbl))//&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1)))//&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           //ArrayResize(SymbolsArray, SymbolCount + 1);
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      } 
     } 
//     SymbolsArray[SymbolCount] = smbl; SymbolCount++;
     // ����������
    if (direct<=0)
    {
     for(Loop = 0; Loop < CurrencyCount; Loop++)
      {
       if(StringSubstr(smbl,0,3)==StringSubstr(Currencies[Loop],3,3))
        {
         TempSymbol = Currencies[Loop];
         if((TempSymbol!=smbl))//&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1)))//&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      }
     for(Loop = 0; Loop < CurrencyCount; Loop++)
      {
       if(StringSubstr(smbl,3,3)==StringSubstr(Currencies[Loop],0,3))
        {
         TempSymbol = Currencies[Loop];
         if((TempSymbol!=smbl))//&&(iHigh(TempSymbol, PERIOD_W1,1) > iLow(TempSymbol, PERIOD_W1,1)))//&&(MaxSpread >=MarketInfo(TempSymbol,MODE_SPREAD)))
          {
           //ArrayResize(SymbolsArray, SymbolCount + 1);
           SymbolsArray[SymbolCount] = TempSymbol;
           SymbolCount++;
          }
        }
      } 
    }
//    for(Loop=0;Loop<SymbolCount;Loop++) Print(Loop,SymbolsArray[Loop]);
    return(SymbolCount);
  }
