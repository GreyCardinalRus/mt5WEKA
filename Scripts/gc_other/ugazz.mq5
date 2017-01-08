//+����������������������������������������������������������������������+
//|                                       JQS UGA The alternative ZigZag |
//|                                       Copyright � 2010, JQS aka Joo. |
//|                                     http://www.mql4.com/ru/users/joo |
//+����������������������������������������������������������������������+
#property copyright "Copyright � 2010, JQS aka Joo."                   //|
#property link      "http://www.mql4.com/ru/users/joo"                 //|
//+����������������������������������������������������������������������+
#property description "������, ��������������� ������ ����������"      //|
#property description "�������������� ������������� ��������� UGAlib," //|
#property description "������������� ������������� ���������"          //|
#property description "������������� �������"                          //|
#property description "�� ������� ������ ������ ��������������� ZZ"    //|
//+����������������������������������������������������������������������+
#property version   "1.00"                                             //|
#property script_show_inputs                                           //|
//+����������������������������������������������������������������������+
#include <UGAlib.mqh>
//+����������������������������������������������������������������������+

//������������������������������������������������������������������������
//----------------------������� ����������--------------------------------
input string GenofundParam        =        "----��������� ���������----";
input int    ChromosomeCount_P    = 100;       //���-�� �������� � �������
input int    GeneCount_P          = 100;       //���-�� �����
input int    FFNormalizeDigits_P  = 0;        //���-�� ������ ����������������
input int    GeneNormalizeDigits_P= 0;        //���-�� ������ ����
input int    Epoch_P               = 50;    //���-�� ���� ��� ���������
//---
input string GA_OperatorParam     =        "----��������� ����������----";
input double ReplicationPortion_P  = 100.0; //���� ����������.
input double NMutationPortion_P    = 10.0;  //���� ������������ �������.
input double ArtificialMutation_P  = 10.0;  //���� ������������� �������.
input double GenoMergingPortion_P  = 20.0;  //���� ������������� �����.
input double CrossingOverPortion_P = 20.0;  //���� �������������.
input double ReplicationOffset_P   = 0.5;   //����������� �������� ������ ���������
input double NMutationProbability_P= 5.0;   //����������� ������� ������� ���� � %
//---
input string OptimisationParam    =        "----��������� �����������----";
input double RangeMinimum_P       = 0.0;    //������� ��������� ������
input double RangeMaximum_P       = 5.0;     //�������� ��������� ������
input double Precision_P          = 1.0;  //��������� ��������
input int    OptimizeMethod_P     = 2;       //�����.:1-Min,������-Max

input string Other                =        "----������----";
input double Spred                = 80.0;
input bool   Show                 = true;
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//----------------------���������� ����������-----------------------------
double   Hight  [];
double   Low    [];
datetime Time   [];
datetime Ti     [];
double   Peaks  [];
bool     show;
//������������������������������������������������������������������������
//--------------------------���� ���������--------------------------------
int OnStart()
{
  //-----------------------����������-------------------------------------
  //���������� ���������� ���������� ��� UGA
  ChromosomeCount=ChromosomeCount_P; //���-�� �������� � �������
  GeneCount      =GeneCount_P;       //���-�� �����
  RangeMinimum   =RangeMinimum_P;    //������� ��������� ������
  RangeMaximum   =RangeMaximum_P;    //�������� ��������� ������
  Precision      =Precision_P;       //��� ������
  OptimizeMethod =OptimizeMethod_P;  //1-�������, ����� ������-��������

  FFNormalizeDigits   = FFNormalizeDigits_P;  //���-�� ������ ����������������
  GeneNormalizeDigits = GeneNormalizeDigits_P;//���-�� ������ ����

  ArrayResize(Chromosome,GeneCount+1);
  ArrayInitialize(Chromosome,0);
  Epoch=Epoch_P;                     //���-�� ���� ��� ���������
  //----------------------------------------------------------------------
  //���������� ���������� ����������
  ArraySetAsSeries(Hight,true);  CopyHigh (NULL,0,0,GeneCount+1,Hight);
  ArraySetAsSeries(Low,true);    CopyLow  (NULL,0,0,GeneCount+1,Low);
  ArraySetAsSeries(Time,true);   CopyTime (NULL,0,0,GeneCount+1,Time);
  ArrayResize     (Ti,GeneCount+1);ArrayInitialize(Ti,0);
  ArrayResize(Peaks,GeneCount+1);ArrayInitialize(Peaks,0.0);
  show=Show;
  //----------------------------------------------------------------------
  //��������� ����������
  int time_start=GetTickCount(),time_end=0;
  //----------------------------------------------------------------------
  
  //������� �����
  ObjectsDeleteAll(0,-1,-1);
  ChartRedraw(0);
  //������ ������� �-�� UGA
  UGA
   (
   ReplicationPortion_P, //���� ����������.
   NMutationPortion_P,   //���� ������������ �������.
   ArtificialMutation_P, //���� ������������� �������.
   GenoMergingPortion_P, //���� ������������� �����.
   CrossingOverPortion_P,//���� �������������.
   //---
   ReplicationOffset_P,  //����������� �������� ������ ���������
   NMutationProbability_P//����������� ������� ������� ���� � %
   );
  //----------------------------------
  //������� ��������� ��������� �� �����
  show=true;
  ServiceFunction();
  //----------------------------------
  time_end=GetTickCount();
  //----------------------------------
  Print(time_end-time_start," �� - ����� ����������");
  //----------------------------------
  return(0);
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//-----------------------------------------------------------------------+
// ��������� �������. ���������� �� UGA.                                 |
// ������ ��� ������ ���������� �������� �������������� ����������,      |
//��������, ��� ��������.                                                |
//���� � ��� ��� �����������, �������� ������� ������ ���:               |
//   void ServiceFunction()                                              |
//   {                                                                   |
//   }                                                                   |
//-----------------------------------------------------------------------+
void ServiceFunction()
{ 
  if(show==true)
  {
    //-----------------------����������-----------------------------------
    double PipsSum=0.0;
    int    PeaksCount=0;
    double temp=0.0;
    //--------------------------------------------------------------------
    for(int u=1;u<=GeneCount;u++)
    {
      temp=Chromosome[u];
      if(temp<=1.0 )
      {
        Peaks[PeaksCount]=NormalizeDouble(Hight[u],Digits());
        Ti   [PeaksCount]=Time[u];
        PeaksCount++;
      }
      if(temp>=4.0)
      {
        Peaks[PeaksCount]=NormalizeDouble(Low[u],Digits());
        Ti   [PeaksCount]=Time[u];
        PeaksCount++;
      }
    }
    ObjectsDeleteAll(0,-1,-1);
    for(int V=0;V<PeaksCount-1;V++)
    {
      PipsSum+=NormalizeDouble((MathAbs(Peaks[V]-Peaks[V+1]))/Point(),FFNormalizeDigits)-Spred;
      ObjectCreate    (0,"BoxBackName"+(string)V,OBJ_TREND,0,Ti[V],Peaks[V],Ti[V+1],Peaks[V+1]);
      ObjectSetInteger(0,"BoxBackName"+(string)V,OBJPROP_COLOR,Yellow);
      ObjectSetInteger(0,"BoxBackName"+(string)V,OBJPROP_SELECTABLE,true);
    }
    ChartRedraw(0);
    Comment(PipsSum);
  }
  //----------------------------------------------------------------------
  else
    return;
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//-----------------------------------------------------------------------+
// ������� ������ ����������������� �����. ���������� �� UGA.            |
// ��� ���������� � ���� ������������� �������.                          |
//                                                                       |
// ��� �������:                                                          |
// ����� ����� ����������� ��������� ����������.������� "��������"       |
// ��������� �� ������������ ������ � ������� ������� �� ����. ����      |
// ���������� ���������� ������� �������, �� ������������ �������� �     |
// ����� �������������� ������������ ����������������� �����             |
// (������ ���������� ����������).                                       |
//-----------------------------------------------------------------------+

//========================================================================
void FitnessFunction(int chromos)
{
  //-----------------------����������-------------------------------------
  double PipsSum=0.0;
  int    PeaksCount=0;
  double temp=0.0;
  //----------------------------------------------------------------------
  for(int u=1;u<=GeneCount;u++)
  {
    temp=Colony[u][chromos];
    if(temp<=1.0)
    {
      Peaks[PeaksCount]=NormalizeDouble(Hight[u],Digits());
      PeaksCount++;
    }
    if(temp>=4.0)
    {
      Peaks[PeaksCount]=NormalizeDouble(Low[u],Digits());
      PeaksCount++;
    }
  }

  if(PeaksCount>1)
  {
    for(int V=0;V<PeaksCount-1;V++)
      PipsSum+=NormalizeDouble((MathAbs(Peaks[V]-Peaks[V+1]))/Point(),FFNormalizeDigits)-Spred;

    Colony[0][chromos]=PipsSum;
  }
  else
    Colony[0][chromos]=-10000000.0;
  AmountStartsFF++;
}
