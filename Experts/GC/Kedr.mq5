//+------------------------------------------------------------------+
//|                                                         Kedr.mq4 |
//|                                                            Kadet |
//|                                                    kadet38@ya.ru |
//+------------------------------------------------------------------+
#property copyright "Kadet"
#property link      "www.kadet.nsknet.ru"

//------------- ����������� ���������� ������� -------------------
#include <MLP_func.mqh>
#include <Lite_EXPERT1.mqh>
#include <BTS_function.mqh>

//���������� ����������
extern int Structur  = 0;  // ��������� ��
extern int PorAct    = 5; // ����� ��������� ��������������� ����������� ������
//--------------------------------------------
extern int mn  = 1;
extern int flag1 = 128;    // - ���� �������� � 1 
extern int flag2 = 512;    // - ���� �������� � 2 
extern int flag3 = 384;    // - ���� �������� � 2 
extern int flag4 = 0;    // - ���� �������� � 2 
extern int flag5 = 0;    // - ���� �������� � 2 
extern int flag6 = 0;    // - ���� �������� � 2 
extern int flag7 = 0;    // - ���� �������� � 2 
extern int flag8 = 0;    // - ���� �������� � 2 
extern int flag9 = 0;    // - ���� �������� � 2 
extern int flag10 = 0;    // - ���� �������� � 2 
//--------------------------------------------
int tp         = 50;
int sl         = 60;
//--------------------------------------------
int ts         = 25;
int prevtime   = 0;
int mn_buy, mn_sell;
extern double Risk    = 0.5;

double DB_UD [1000,35];
// DB_UD [x][]          - ����� �������
// DB_UD [][NIn]        - ��������� ����������� ��� �� ����� �� 0 �� NIn
// DB_UD [][NIn+NOut]   - ����� �����/�����

double DB_TS [1000,35];
// DB_TS [x][]          - ����� �������
// DB_TS [][NIn]        - ��������� ����������� ��� �� ����� �� 0 �� NIn
// DB_UD [][NIn+NOut]   - ����� take_profit/stop_loss

bool f1 [16];        // - ������ ������
bool f2 [16];        // - ������ ������
bool f3 [16];        // - ������ ������
bool f4 [16];        // - ������ ������
bool f5 [16];        // - ������ ������
bool f6 [16];        // - ������ ������
bool f7 [16];        // - ������ ������
bool f8 [16];        // - ������ ������
bool f9 [16];        // - ������ ������
bool f10 [16];        // - ������ ������

//--------------------------------------------
int Network = 0;     // ��������� ��
int NIn     = 11;    // ���������� ������� �����������
int NOut    = 2;     // ���������� �����������
int Size    = 1000;  // �������� ������� (���-�� ���������
double A1   = -10.0; // ������ ������� ��������� ��
double B1   = 10.0;  // ������/������� ������� ��������� ��
double A2   = -100.0;// ������ ������� ��������� ��
double B2   = 100.0; // ������/������� ������� ��������� ��
double D    = -50.0; // ������/������� ������� ��������� ��
double X[];          // ������� ������ ������
double Y[];          // �������������� ������ (������ �����/����)
double TS[];         // �������������� ������ (������ take_profit/stop_loss)
//--------------------------------------------
int p0 = 2;
int p1 = 2;
int p2 = 2;
int p3 = 2;
int p4 = 2;
int p5 = 2;
int p6 = 2;
//--------------------------------------------
int Timeframe  = 0;
int bar  = 0;
double FastLimit = 0.5; 
double SlowLimit = 0.05;
int periodAMA = 9; 
int nfast = 2; 
int nslow = 30; 
double G = 2.0; 
double dK = 2.0; 
int ndot = 5; 
int CountBars = 300;
int CountBars1 = 300;
int CountBars2 = 400; 
int SSP = 7; 
double Kmin = 1.6; 
double Kmax = 50.6; 
bool gAlert = True;
int Fast = 8; 
int Slow = 21; 
int Signal = 5; 
int First_R = 8; 
int Second_S = 5; 
int SignalPeriod = 5; 
int Mode_Smooth = 2; 
int ExtDepth=12; 
int ExtDeviation=5; 
int ExtBackstep=3;
int FastEMA=12; 
int SlowEMA=26; 
int SignalSMA=9;
//--------------------------------------------


//+------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//| ������������� �������������� �������� ��                                     |
//+------------------------------------------------------------------------------+
int init() {
//----
   int bar, index = 0;
//--------------------------------------------
   mn_buy = mn;
   mn_sell = mn*10;
   Size    = 1000.0;       // �������� ������� (���-�� ���������
   ArrayResize(X,NIn);
   ArrayResize(Y,NOut);
   ArrayResize(TS,NOut);
//--------------------------------------------
// ����������� ���� ������ DB - ���������� �������
   for( bar=1000; bar>=0; bar-- ){
      index = 1000-bar;
      DataBase(index,bar);
   }
//--------------------------------------------
// �������� ��
   MLP(0,Structur,DB_UD,Size,A1,B1);
//   MLP(1,6,DB_TS,Size,A2,B2);
//--------------------------------------------
// ��������� ������ ���������
   for( int i=0; i<=15; i++ ){
      int st = MathPow(2,i);
      f1[i] = (flag1 & st)>0;
      f2[i] = (flag2 & st)>0;
      f3[i] = (flag3 & st)>0;
      f4[i] = (flag4 & st)>0;
      f5[i] = (flag5 & st)>0;
      f6[i] = (flag6 & st)>0;
      f7[i] = (flag7 & st)>0;
      f8[i] = (flag8 & st)>0;
      f9[i] = (flag9 & st)>0;
      f10[i] = (flag10 & st)>0;
      Print("; f1[",i,"] = ",f1[i],
            "; f2[",i,"] = ",f2[i],
            "; f3[",i,"] = ",f3[i],
            "; f4[",i,"] = ",f4[i],
            "; f5[",i,"] = ",f5[i],
            "; f6[",i,"] = ",f6[i],
            "; f7[",i,"] = ",f7[i],
            "; f8[",i,"] = ",f8[i],
            "; f9[",i,"] = ",f9[i],
            "; f10[",i,"] = ",f10[i]);
   }
//--------------------------------------------
   return(0);
//----
}


//+------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//| �������� �������                                                             |
//+------------------------------------------------------------------------------+
int start() {
//----
   static bool BUY_Sign, SELL_Sign, BUY_Stop, SELL_Stop;
   int i, t_ob, ind=0;
//--------------------------------------------
   if (Time[0] == prevtime) return(0);
      prevtime = Time[0];
//--------------------------------------------
   RefreshRates();
   ind = Bars - 1000*MathFloor(Bars/1000);
//--------------------------------------------
// ������������ �� ��� 1000-������� ��������.
/*
   t_ob =  1000*MathRound(1.0*ind/1000);
   if( ind == t_ob-1 ){
      Size = t_ob;
      MLP(0,Structur,DB_UD,Size,A1,B1);
      MLP(1,Structur,DB_TS,Size,A2,B2);
   }
*/
   if( ind == 999 ){
      Size = 1000;
      MLP(0,Structur,DB_UD,Size,A1,B1);
//      MLP(1,6,DB_TS,Size,A2,B2);
   }

//--------------------------------------------
// ������������ ������� ������ - X(i) � ��������� Y(i).
   DataBase(ind,0);
   Function(0);
   ArrayInitialize(Y,0.0);
//--------------------------------------------
//��������� ������� �� �� - Y(i)
   MLPProcess(0,X,Y);
   Y[0] = MathRound(Y[0]);
   Y[1] = MathRound(Y[1]);
/*
   MLPProcess(1,X,TS);
   tp = MathRound(MathAbs(TS[0]));
   sl = 10*MathRound(MathAbs(TS[1]));
*/
//--------------------------------------------
// ������ ����������� Y(i)

   Print("; Y[0] = ",Y[0],
         "; Y[1] = ",Y[1]);
   Comment("Y[0] = ",Y[0],
         "; Y[1] = ",Y[1]);

//--------------------------------------------
   if(Structur<9){
      if (Y[0]>0){
         BUY_Sign = true;
         SELL_Stop = true;
      }
      if (Y[1]<0){
         SELL_Sign = true;
         BUY_Stop = true;
      }
   } else {
      if (Y[0]>0 && Y[1]==0){
         BUY_Sign = true;
         SELL_Stop = true;
      }
      if ( Y[1]!=0 && Y[0]==0 ){
         SELL_Sign = true;
         BUY_Stop = true;
      }
   } 
//--------------------------------------------
   if (!CloseOrder1(BUY_Stop, mn_buy)) return(0);
   if (!CloseOrder1(SELL_Stop, mn_sell)) return(0); 
//--------------------------------------------
   if (!OpenBuyOrder1(BUY_Sign, mn_buy, "", Risk, sl, tp)) return(0);
   if (!OpenSellOrder1(SELL_Sign, mn_sell, "", Risk, sl, tp)) return(0);
//-------------------------------

   for( i=0; i<3; i++)
      if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) )
         if( ( MathAbs(Bid - OrderOpenPrice())/Point) > ts ){
            if (!Make_TreilingStop(mn_buy, ts)) return(0);
            if (!Make_TreilingStop(mn_sell, ts)) return(0);
         }

//--------------------------------------------
   return(0);
//----
}


//+------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//| ������������ ���� ������                                                     |
//+------------------------------------------------------------------------------+
void MLP(int Network,   // ��������� ��
         int Structur,  // ��������� ��
         double& X[][], // ��������� ��
         int Size,      // ����� ��
         double A,      // ������ �����
         double B) {    // ������� �����
//--------------------------------------------
   double Decay = 0.0015;     // - ���������  weight  decay,  >=0.
   int Simple,
       NHid          = 5,
       NHid1         = 3,
       NHid2         = 5,
       Restarts      = 3,     // - ����� ������� ��������� �� ��������� �������, >0.
       Rep           = 0,
       RMS_Error     = 0,
       RelCL_SError  = 1,
       N_Error       = 2,
       Epoch_Count   = 3;

//--------------------------------------------
//   ������� DB, MultiLayerPerceptron � LBFGSState ����������� � �������� �� ���������
//   ��������� �������� ����������:
//      - (NIn + NOut) - �� ����� 20;
//      - NHid, NHid1, NHid2 - �� ����� 10;
//   � ������ ������������� ��������� ��������� �������� ���������� ����������� 
//   ������� ��������.
//--------------------------------------------

// ������������� ��������� ��
   switch(Structur){
//--------------------------------------------
// �  ��������  ������� ��������� ������� �����  ������������  ���������������  �������,  ��������  ���� ��������.
      case 0:  { MLPCreate0( NIn,NOut,Network );                Simple=0; break; }   // ��� ������� �����
      case 1:  { MLPCreate1( NIn,NHid,NOut,Network );           Simple=0; break; }   // � ����� ������� �����
      case 2:  { MLPCreate2(NIn,NHid1,NHid2,NOut,Network);      Simple=0; break; }   // � ����� �������� ������

//--------------------------------------------
// �  ��������  ������� ��������� ������� �����  ������������  ���������������  �������.
// �������� �������� ��������� ���� ����� ���: (B, +INF) ���� D>=0, ��� (-INF, B), ���� D<0.,                                                            
      case 3:  { MLPCreateB0(NIn,NOut,B,D,Network);             Simple=0; break; }   // ��� ������� �����.
      case 4:  { MLPCreateB1(NIn,NHid,NOut,B,D,Network);        Simple=0; break; }   // � ����� ������� �����
      case 5:  { MLPCreateB2(NIn,NHid1,NHid2,NOut,B,D,Network); Simple=0; break; }   // � ����� �������� ������

//--------------------------------------------
// �  ��������  ������� ��������� ������� �����  ������������  ���������������  �������.
// �������� �������� ��������� ���� ����� [A,B] (������������ ��������������� ������� � ��������� �� �������/����������������).
      case 6:  { MLPCreateR0(NIn,NOut,A,B,Network);             Simple=0; break; }   // ��� ������� �����.
      case 7:  { MLPCreateR1(NIn,NHid,NOut,A,B,Network);        Simple=0; break; }   // � ����� ������� �����
      case 8:  { MLPCreateR2(NIn,NHid1,NHid2,NOut,A,B,Network); Simple=0; break; }   // � ����� �������� ������

//--------------------------------------------
// ��������� ����-�������������.
      case 9:  { MLPCreateC0(NIn,NOut,Network);                 Simple=0; break; }   // ��� ������� �����.
      case 10: { MLPCreateC1(NIn,NHid,NOut,Network);            Simple=1; break; }   // � ����� ������� �����
      case 11: { MLPCreateC2(NIn,NHid1,NHid2,NOut,Network);     Simple=1; break; }   // � ����� �������� ������
//--------------------------------------------
      default: Alert("��������� �� �� ������");                return(0);
   }
//--------------------------------------------
// �������� �� � �������� ��������������
   switch(Simple){
      case 0 : MLPTrainNSimple(Network,X,Size,Decay,Restarts,Rep); break;   // ���������������� ���
      case 1 : MLPTrainSimple(Network,X,Size,Decay,Restarts,Rep);  break;   // �������� ���
      default: return(0);
   }   
//--------------------------------------------
Print(" ������������������ ������ ���� = ",MLPTrainingReport[Rep,RMS_Error],
      " ������������� ������ ������������� (�� 0 �� 1) = ",MLPTrainingReport[Rep,RelCL_SError],
      " ������������ ������� ������ (��, ������� ���������������� � ���� ��������) = ",MLPTrainingReport[Rep,N_Error],
      " ����� ���� = ",MLPTrainingReport[Rep,Epoch_Count]);
//--------------------------------------------
   return(0);
//----
}


//+------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//| ������������ ���� ������                                                     |
//+------------------------------------------------------------------------------+
void DataBase( int i, int bar ) { // i - ����� �������
//--------------------------------------------
   double summ = 0, norm_up, norm_down, max = 0, min = 0;
//--------------------------------------------
   bar +=10;
   Function(bar);
//--------------------------------------------
   for( int j=0; j<NIn; j++ ){
      DB_UD[i,j] = X[j];
      DB_TS[i,j] = X[j];
   }
//--------------------------------------------
   for(int k=bar; k>bar-10; k-- ){
      summ += Open[k];
//--------------------------------------------
      if( High[k]!=0 && Low[k]!=0 ){
         norm_up = (High[k]-Open[bar])/Point;
         max = MathMax(max,norm_up);
         norm_down = (Low[k]-Open[bar])/Point;
         min = MathMin(min,norm_down);
      } else {
         max = 0.0;
         min = 0.0;
      }         
   }
//--------------------------------------------
// ������������ ����������� - �������� ���������� (Y(i,n))
   if( Open[bar]!=0 && (summ/10 - Open[bar])/Point > PorAct ){
      DB_UD [i,NIn] = 1.0;
      DB_UD [i,(NIn+1)] = 0.0;
      DB_TS [i,NIn] = max;
      DB_TS [i,(NIn+1)] = min;
   } else
      if(  Open[bar]!=0 && (summ/10 - Open[bar])/Point < -PorAct ){
         DB_UD [i,NIn] = 0.0;
         DB_UD [i,(NIn+1)] = -1.0;
         DB_TS [i,NIn] = min;
         DB_TS [i,(NIn+1)] = max;
      } else {
         DB_UD [i,NIn] = 0.0;
         DB_UD [i,(NIn+1)] = 0.0;
         DB_TS [i,NIn] = 0.0;
         DB_TS [i,(NIn+1)] = 0.0;
      }
//--------------------------------------------
   return(0);
//----
}


//+------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------+
//| ������� ������������ ������� ���������� - X(i,bar)                           |
//+------------------------------------------------------------------------------+
double Function( int bar ) {
//----
   int t=0;
   datetime Tm;
//--------------------------------------------
// ���� � 1 (2047)

   if (f1[0]) { X[t] = MACD_func (bar); t++; }
   if (f1[1]) { X[t] = CCI_func (bar); t++; }
   if (f1[2]) { X[t] = SAR_func (bar); t++; }
   if (f1[3]) { X[t] = ADX_func (bar); t++; }
   if (f1[4]) { X[t] = DM_func (bar); t++; }
   if (f1[5]) { X[t] = MA_func (bar); t++; }
   if (f1[6]) { X[t] = WPR_func (bar); t++; }
   if (f1[7]) { X[t] = AC_func (bar); t++; }
   if (f1[8]) { X[t] = MFI_func (bar); t++; }
   if (f1[9]) { X[t] = Moving(bar); t++; }
   if (f1[10]) { X[t] = Input (bar); t++; }

//--------------------------------------------
// ���� � 2 (2047)

   if (f2[0]) { X[t] = MathRound(MACD_func (bar)); t++; }
   if (f2[1]) { X[t] = MathRound(CCI_func (bar)); t++; }
   if (f2[2]) { X[t] = MathRound(SAR_func (bar)); t++; }
   if (f2[3]) { X[t] = MathRound(ADX_func (bar)); t++; }
   if (f2[4]) { X[t] = MathRound(DM_func (bar)); t++; }
   if (f2[5]) { X[t] = MathRound(MA_func (bar)); t++; }
   if (f2[6]) { X[t] = MathRound(WPR_func (bar)); t++; }
   if (f2[7]) { X[t] = MathRound(AC_func (bar)); t++; }
   if (f2[8]) { X[t] = MathRound(MFI_func (bar)); t++; }
   if (f2[9]) { X[t] = MathRound(Moving(bar)); t++; }
   if (f2[10]) { X[t] = MathRound(Input (bar)); t++; }

//--------------------------------------------
// ���� � 3 (1023)

   if (f3[0]) { X[t] = MAMA_func (bar,FastLimit,SlowLimit); t++; }
   if (f3[1]) { X[t] = AMA_func (bar,periodAMA,nfast,nslow,G,dK); t++; }
   if (f3[2]) { X[t] = Awesome_func (bar); t++; }
   if (f3[3]) { X[t] = CoeffofLine_func (bar,ndot,CountBars); t++; }
   if (f3[4]) { X[t] = STLM_hist_func (bar,CountBars); t++; }
   if (f3[5]) { X[t] = SilverTrend_func (bar,CountBars,SSP,Kmin,Kmax,gAlert); }
   if (f3[6]) { X[t] = TSI_MACD_hist_func (bar,Fast,Slow,Signal,First_R,Second_S,SignalPeriod,Mode_Smooth); t++; }
   if (f3[7]) { X[t] = ZigZag_func (bar,ExtDepth,ExtDeviation,ExtBackstep); t++; }
   if (f3[8]) { X[t] = OsMA_5c_func (bar,FastEMA,SlowEMA,SignalSMA); t++; }
   if (f3[9]) { X[t] = Fractals_func (bar); t++; }

//--------------------------------------------
// ���� � 4 (127)

   Tm   = iTime( 0, 0, bar);
   if (f4[0]) { X[t] = Flat_Log(Tm, PERIOD_M1 ,bar); t++; }
   if (f4[1]) { X[t] = Flat_Log(Tm, PERIOD_M5 ,bar); t++; }
   if (f4[2]) { X[t] = Flat_Log(Tm, PERIOD_M15,bar); t++; }
   if (f4[3]) { X[t] = Flat_Log(Tm, PERIOD_M30,bar); t++; }
   if (f4[4]) { X[t] = Flat_Log(Tm, PERIOD_H1 ,bar); t++; }
   if (f4[5]) { X[t] = Flat_Log(Tm, PERIOD_H4 ,bar); t++; }
   if (f4[6]) { X[t] = Flat_Log(Tm, PERIOD_D1 ,bar); t++; }

//--------------------------------------------
// ���� � 5 (127)

   Tm   = iTime( 0, 0, bar);
   if (f5[0]) { X[t] = Flat(Tm, PERIOD_M1 ,bar); t++; }
   if (f5[1]) { X[t] = Flat(Tm, PERIOD_M5 ,bar); t++; }
   if (f5[2]) { X[t] = Flat(Tm, PERIOD_M15,bar); t++; }
   if (f5[3]) { X[t] = Flat(Tm, PERIOD_M30,bar); t++; }
   if (f5[4]) { X[t] = Flat(Tm, PERIOD_H1 ,bar); t++; }
   if (f5[5]) { X[t] = Flat(Tm, PERIOD_H4 ,bar); t++; }
   if (f5[6]) { X[t] = Flat(Tm, PERIOD_D1 ,bar); t++; }
   
//--------------------------------------------
// ���� � 6 (127)

   Tm   = iTime( 0, 0, bar);
   if (f6[0]) { X[t] = Flat_1(Tm, PERIOD_M1 ,bar); t++; }
   if (f6[1]) { X[t] = Flat_1(Tm, PERIOD_M5 ,bar); t++; }
   if (f6[2]) { X[t] = Flat_1(Tm, PERIOD_M15,bar); t++; }
   if (f6[3]) { X[t] = Flat_1(Tm, PERIOD_M30,bar); t++; }
   if (f6[4]) { X[t] = Flat_1(Tm, PERIOD_H1 ,bar); t++; }
   if (f6[5]) { X[t] = Flat_1(Tm, PERIOD_H4 ,bar); t++; }
   if (f6[6]) { X[t] = Flat_1(Tm, PERIOD_D1 ,bar); t++; }

//--------------------------------------------
// ���� � 7 (127)

   Tm   = iTime( 0, 0, bar);
   if (f7[0]) { X[t] = Flat_P(Tm, PERIOD_M1 ,bar,p0); t++; }
   if (f7[1]) { X[t] = Flat_P(Tm, PERIOD_M5 ,bar,p1); t++; }
   if (f7[2]) { X[t] = Flat_P(Tm, PERIOD_M15,bar,p2); t++; }
   if (f7[3]) { X[t] = Flat_P(Tm, PERIOD_M30,bar,p3); t++; }
   if (f7[4]) { X[t] = Flat_P(Tm, PERIOD_H1 ,bar,p4); t++; }
   if (f7[5]) { X[t] = Flat_P(Tm, PERIOD_H4 ,bar,p5); t++; }
   if (f7[6]) { X[t] = Flat_P(Tm, PERIOD_D1 ,bar,p6); t++; }

//--------------------------------------------
// ���� ������ � ������ �������� ���� - EUR_JPY
//--------------------------------------------
// ���� � 8 (127)

   Tm   = iTime( 0, 0, bar);
   if (f8[0]) { X[t] = Flat_Log(Tm, PERIOD_M1 ,"EURJPY"); t++; }
   if (f8[1]) { X[t] = Flat_Log(Tm, PERIOD_M5 ,"EURJPY"); t++; }
   if (f8[2]) { X[t] = Flat_Log(Tm, PERIOD_M15,"EURJPY"); t++; }
   if (f8[3]) { X[t] = Flat_Log(Tm, PERIOD_M30,"EURJPY"); t++; }
   if (f8[4]) { X[t] = Flat_Log(Tm, PERIOD_H1 ,"EURJPY"); t++; }
   if (f8[5]) { X[t] = Flat_Log(Tm, PERIOD_H4 ,"EURJPY"); t++; }
   if (f8[6]) { X[t] = Flat_Log(Tm, PERIOD_D1 ,"EURJPY"); t++; }

//--------------------------------------------
// ���� � 9 (127)

   Tm   = iTime( 0, 0, bar);
   if (f9[0]) { X[t] = Flat(Tm, PERIOD_M1 ,"EURJPY"); t++; }
   if (f9[1]) { X[t] = Flat(Tm, PERIOD_M5 ,"EURJPY"); t++; }
   if (f9[2]) { X[t] = Flat(Tm, PERIOD_M15,"EURJPY"); t++; }
   if (f9[3]) { X[t] = Flat(Tm, PERIOD_M30,"EURJPY"); t++; }
   if (f9[4]) { X[t] = Flat(Tm, PERIOD_H1 ,"EURJPY"); t++; }
   if (f9[5]) { X[t] = Flat(Tm, PERIOD_H4 ,"EURJPY"); t++; }
   if (f9[6]) { X[t] = Flat(Tm, PERIOD_D1 ,"EURJPY"); t++; }

//--------------------------------------------
// ���� � 10 (127)

   Tm   = iTime( 0, 0, bar);
   if (f10[0]) { X[t] = Flat_1(Tm, PERIOD_M1 ,"EURJPY"); t++; }
   if (f10[1]) { X[t] = Flat_1(Tm, PERIOD_M5 ,"EURJPY"); t++; }
   if (f10[2]) { X[t] = Flat_1(Tm, PERIOD_M15,"EURJPY"); t++; }
   if (f10[3]) { X[t] = Flat_1(Tm, PERIOD_M30,"EURJPY"); t++; }
   if (f10[4]) { X[t] = Flat_1(Tm, PERIOD_H1 ,"EURJPY"); t++; }
   if (f10[5]) { X[t] = Flat_1(Tm, PERIOD_H4 ,"EURJPY"); t++; }
   if (f10[6]) { X[t] = Flat_1(Tm, PERIOD_D1 ,"EURJPY"); t++; }

//--------------------------------------------
/*
   Print("; X[0] = ",X[0],
         "; X[1] = ",X[1],
         "; X[2] = ",X[2],
         "; X[3] = ",X[3],
         "; X[4] = ",X[4],
         "; X[5] = ",X[5],
         "; X[6] = ",X[6],
         "; X[7] = ",X[7],
         "; X[8] = ",X[8],
         "; X[9] = ",X[9],
         "; X[10] = ",X[10]);
*/
//--------------------------------------------
   NIn = t;
//--------------------------------------------
   return(0);
//----
}







