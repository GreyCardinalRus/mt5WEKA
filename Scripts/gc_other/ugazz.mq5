//+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
//|                                       JQS UGA The alternative ZigZag |
//|                                       Copyright ｩ 2010, JQS aka Joo. |
//|                                     http://www.mql4.com/ru/users/joo |
//+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
#property copyright "Copyright ｩ 2010, JQS aka Joo."                   //|
#property link      "http://www.mql4.com/ru/users/joo"                 //|
//+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
#property description "ﾑ��韵�, 蒟������頏���韜 �珮��� 礪硴韶�裲�"      //|
#property description "ﾓ�鞣褞�琿���胛 ﾃ褊褪顆褥��胛 ﾀ�胛�頸�� UGAlib," //|
#property description "頌����銛��裙� ��裝��珞�褊韃 ���������"          //|
#property description "粢�褥�粢����� �頌�瑟�"                          //|
#property description "�� ��韲褞� ��頌�� 粢��竟 琿��褞�瑣鞣��胛 ZZ"    //|
//+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
#property version   "1.00"                                             //|
#property script_show_inputs                                           //|
//+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+
#include <UGAlib.mqh>
//+覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧+

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//----------------------ﾂ��蓖�� �褞褌褊���--------------------------------
input string GenofundParam        =        "----ﾏ瑩瑟褪�� 肄�����萵----";
input int    ChromosomeCount_P    = 100;       //ﾊ��-粽 �������� � �����韋
input int    GeneCount_P          = 100;       //ﾊ��-粽 肄���
input int    FFNormalizeDigits_P  = 0;        //ﾊ��-粽 鈿瑕�� ��頌����硴褊����
input int    GeneNormalizeDigits_P= 0;        //ﾊ��-粽 鈿瑕�� 肄��
input int    Epoch_P               = 50;    //ﾊ��-粽 ���� 砒� �����褊��
//---
input string GA_OperatorParam     =        "----ﾏ瑩瑟褪�� ��褞瑣����----";
input double ReplicationPortion_P  = 100.0; //ﾄ��� ﾐ襃�韭璋韋.
input double NMutationPortion_P    = 10.0;  //ﾄ��� ﾅ��褥�粢���� ���璋韋.
input double ArtificialMutation_P  = 10.0;  //ﾄ��� ﾈ������粢���� ���璋韋.
input double GenoMergingPortion_P  = 20.0;  //ﾄ��� ﾇ琲���粽籵��� 肄���.
input double CrossingOverPortion_P = 20.0;  //ﾄ��� ﾊ����竟胛粢��.
input double ReplicationOffset_P   = 0.5;   //ﾊ����頽韃�� ��襌褊�� 胙瑙頽 竟�褞籵��
input double NMutationProbability_P= 5.0;   //ﾂ褞�������� ���璋韋 �琥蒡胛 肄�� � %
//---
input string OptimisationParam    =        "----ﾏ瑩瑟褪�� ���韲韈璋韋----";
input double RangeMinimum_P       = 0.0;    //ﾌ竟韲�� 蒻瑜珸��� ��頌��
input double RangeMaximum_P       = 5.0;     //ﾌ瑕�韲�� 蒻瑜珸��� ��頌��
input double Precision_P          = 1.0;  //ﾒ�裔�褌�� ��������
input int    OptimizeMethod_P     = 2;       //ﾎ��韲.:1-Min,蓿�胛�-Max

input string Other                =        "----ﾏ���裹----";
input double Spred                = 80.0;
input bool   Show                 = true;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//----------------------ﾃ��矜����� �褞褌褊���-----------------------------
double   Hight  [];
double   Low    [];
datetime Time   [];
datetime Ti     [];
double   Peaks  [];
bool     show;
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//--------------------------ﾒ褄� ���胙瑟��--------------------------------
int OnStart()
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
  //ﾏ�蒹���粲� 肭�矜����� �褞褌褊��� 蓁� UGA
  ChromosomeCount=ChromosomeCount_P; //ﾊ��-粽 �������� � �����韋
  GeneCount      =GeneCount_P;       //ﾊ��-粽 肄���
  RangeMinimum   =RangeMinimum_P;    //ﾌ竟韲�� 蒻瑜珸��� ��頌��
  RangeMaximum   =RangeMaximum_P;    //ﾌ瑕�韲�� 蒻瑜珸��� ��頌��
  Precision      =Precision_P;       //ﾘ璢 ��頌��
  OptimizeMethod =OptimizeMethod_P;  //1-�竟韲��, ��碚� 蓿�胛�-�瑕�韲��

  FFNormalizeDigits   = FFNormalizeDigits_P;  //ﾊ��-粽 鈿瑕�� ��頌����硴褊����
  GeneNormalizeDigits = GeneNormalizeDigits_P;//ﾊ��-粽 鈿瑕�� 肄��

  ArrayResize(Chromosome,GeneCount+1);
  ArrayInitialize(Chromosome,0);
  Epoch=Epoch_P;                     //ﾊ��-粽 ���� 砒� �����褊��
  //----------------------------------------------------------------------
  //ﾏ�蒹���粲� 肭�矜����� �褞褌褊���
  ArraySetAsSeries(Hight,true);  CopyHigh (NULL,0,0,GeneCount+1,Hight);
  ArraySetAsSeries(Low,true);    CopyLow  (NULL,0,0,GeneCount+1,Low);
  ArraySetAsSeries(Time,true);   CopyTime (NULL,0,0,GeneCount+1,Time);
  ArrayResize     (Ti,GeneCount+1);ArrayInitialize(Ti,0);
  ArrayResize(Peaks,GeneCount+1);ArrayInitialize(Peaks,0.0);
  show=Show;
  //----------------------------------------------------------------------
  //ﾋ��琿���� �褞褌褊���
  int time_start=GetTickCount(),time_end=0;
  //----------------------------------------------------------------------
  
  //ﾎ�頌�韲 ���瑙
  ObjectsDeleteAll(0,-1,-1);
  ChartRedraw(0);
  //ﾇ瑜��� 肭珞��� �-韋 UGA
  UGA
   (
   ReplicationPortion_P, //ﾄ��� ﾐ襃�韭璋韋.
   NMutationPortion_P,   //ﾄ��� ﾅ��褥�粢���� ���璋韋.
   ArtificialMutation_P, //ﾄ��� ﾈ������粢���� ���璋韋.
   GenoMergingPortion_P, //ﾄ��� ﾇ琲���粽籵��� 肄���.
   CrossingOverPortion_P,//ﾄ��� ﾊ����竟胛粢��.
   //---
   ReplicationOffset_P,  //ﾊ����頽韃�� ��襌褊�� 胙瑙頽 竟�褞籵��
   NMutationProbability_P//ﾂ褞�������� ���璋韋 �琥蒡胛 肄�� � %
   );
  //----------------------------------
  //ﾂ�粢蒟� ����裝�韜 �裼����瑣 �� ���瑙
  show=true;
  ServiceFunction();
  //----------------------------------
  time_end=GetTickCount();
  //----------------------------------
  Print(time_end-time_start," �� - ﾂ�褌� 頌����褊��");
  //----------------------------------
  return(0);
}
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//-----------------------------------------------------------------------+
// ﾑ褞粨���� �������. ﾂ�鍄籵褪�� 韈 UGA.                                 |
// ﾑ��跖� 蓁� 糺粽萵 �琲����裙� 籵�鞨��� ���韲韈頏�褌�� 瑩胚�褊���,      |
//�瑜�韲褞, 蓁� ��������.                                                |
//ﾅ��� � �裨 �褪 �磆�蒻�����, ���珞頸� ������� ������ �瑕:               |
//   void ServiceFunction()                                              |
//   {                                                                   |
//   }                                                                   |
//-----------------------------------------------------------------------+
void ServiceFunction()
{ 
  if(show==true)
  {
    //-----------------------ﾏ褞褌褊���-----------------------------------
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
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//-----------------------------------------------------------------------+
// ﾔ������ ��褊�� ��頌����硴褊����� ���礪. ﾂ�鍄籵褪�� 韈 UGA.            |
// ﾝ�� ��碵�粢��� � 褥�� ���韲韈頏�褌� �������.                          |
//                                                                       |
// ﾄ�� ��韲褞�:                                                          |
// ﾍ�跫� �琺�� ���韲琿���� �瑩瑟褪�� 竟蒻�瑣���.ﾑ�裝�褪 "���肬瑣�"       |
// 竟蒻�瑣�� �� 頌���顆褥�頷 萵���� � ��碣瑣� �鞳�琿� �� �裙�. ﾅ���      |
// 竟�褞褥�褪 ���顆褥�粽 ������� ��鞦���, �� �瑕�韲琿���� 鈿璞褊韃 �     |
// 碯蒟� ����粢��粽籵�� �瑕�韲琿���� ��頌����硴褊����� ���礪             |
// (�珮��� �瑩瑟褪��� 竟蒻�瑣���).                                       |
//-----------------------------------------------------------------------+

//========================================================================
void FitnessFunction(int chromos)
{
  //-----------------------ﾏ褞褌褊���-------------------------------------
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
