//+����������������������������������������������������������������������+
//|                                                       JQS UGA v1.0.0 |
//|                                       Copyright � 2010, JQS aka Joo. |
//|                                     http://www.mql4.com/ru/users/joo |
//|                                  https://login.mql5.com/ru/users/joo |
//+����������������������������������������������������������������������+
//���������� "�������������� ������������� ��������� UGAlib"             |
//������������� ������������� ��������� ������������� �������.           |
//+����������������������������������������������������������������������+

//----------------------���������� ����������-----------------------------
double Chromosome[];            //����� �������������� ���������� ������� - �����
                                //(��������: ���� ��������� ���� � �.�.)-���������
int    ChromosomeCount     =0;  //����������� ��������� ���������� �������� � �������
int    TotalOfChromosomesInHistory=0;//����� ���������� �������� � �������
int    ChrCountInHistory   =0;  //���������� ���������� �������� � ���� ��������
int    GeneCount           =0;  //���������� ����� � ���������

double RangeMinimum        =0.0;//������� ��������� ������
double RangeMaximum        =0.0;//�������� ��������� ������
double Precision           =0.0;//��� ������
int    OptimizeMethod      =0;  //1-�������, ����� ������ - ��������

int    FFNormalizeDigits   =0;  //���-�� ������ ����� ������� � �������� �����������������
int    GeneNormalizeDigits =0;  //���-�� ������ ����� ������� � �������� �����

double Population   [][1000];   //���������
double Colony       [][500];    //������� ��������
int    PopulChromosCount   =0;  //������� ���������� �������� � ���������
int    Epoch               =0;  //���-�� ���� ��� ���������
int    AmountStartsFF=0;        //���������� �������� ������� �����������������
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//�������� ������� UGA
void UGA
 (
 double ReplicationPortion, //���� ����������.
 double NMutationPortion,   //���� ������������ �������.
 double ArtificialMutation, //���� ������������� �������.
 double GenoMergingPortion, //���� ������������� �����.
 double CrossingOverPortion,//���� �������������.
 //---
 double ReplicationOffset,  //����������� �������� ������ ���������
 double NMutationProbability//����������� ������� ������� ���� � %
 )
{ 
  //����� ����������, ������������ ������ ���� ���
  MathSrand((int)TimeLocal());
  //-----------------------����������-------------------------------------
  int    chromos=0, gene  =0;//������� �������� � �����
  int    resetCounterFF   =0;//������� ������� "���� ��� ���������"
  int    currentEpoch     =1;//����� ������� �����
  int    SumOfCurrentEpoch=0;//����� "���� ��� ���������"
  int    MinOfCurrentEpoch=Epoch;//����������� "���� ��� ���������"
  int    MaxOfCurrentEpoch=0;//������������ "���� ��� ���������"
  int    epochGlob        =0;//����� ���������� ����
  // ������� [���������� ���������(�����)][���������� ������ � �������]
  ArrayResize    (Population,GeneCount+1);
  ArrayInitialize(Population,0.0);
  // ������� �������� [���������� ���������(�����)][���������� ������ � �������]
  ArrayResize    (Colony,GeneCount+1);
  ArrayInitialize(Colony,0.0);
  // ���� ��������
  // [���������� ���������(�����)][���������� �������� � �����]
  double          historyHromosomes[][100000];
  ArrayResize    (historyHromosomes,GeneCount+1);
  ArrayInitialize(historyHromosomes,0.0);
  //----------------------------------------------------------------------
  //--------------�������� ������������ ������� ����������----------------
  //...���������� �������� ������ ���� �� ������ 2
  if(ChromosomeCount<=1)  ChromosomeCount=2;
  if(ChromosomeCount>500) ChromosomeCount=500;
  //----------------------------------------------------------------------
  //======================================================================
  // 1) ������� ��������������                                     �����1)
  ProtopopulationBuilding ();
  //======================================================================
  // 2) ���������� ����������������� ������ �����                  �����2)
  //��� 1-�� �������
  for(chromos=0;chromos<ChromosomeCount;chromos++)
    for(gene=1;gene<=GeneCount;gene++)
      Colony[gene][chromos]=Population[gene][chromos];

  GetFitness(historyHromosomes);

  for(chromos=0;chromos<ChromosomeCount;chromos++)
    Population[0][chromos]=Colony[0][chromos];

  //��� 2-�� �������
  for(chromos=ChromosomeCount;chromos<ChromosomeCount*2;chromos++)
    for(gene=1;gene<=GeneCount;gene++)
      Colony[gene][chromos-ChromosomeCount]=Population[gene][chromos];

  GetFitness(historyHromosomes);

  for(chromos=ChromosomeCount;chromos<ChromosomeCount*2;chromos++)
    Population[0][chromos]=Colony[0][chromos-ChromosomeCount];
  //======================================================================
  // 3) ����������� ��������� � �����������                         ����3)
  RemovalDuplicates();
  //======================================================================
  // 4) �������� ��������� ���������                               �����4)
  for(gene=0;gene<=GeneCount;gene++)
    Chromosome[gene]=Population[gene][0];
  //======================================================================
  ServiceFunction();

  //�������� ���� ������������� ��������� � 5 �� 6
  while(currentEpoch<=Epoch)
  {
    //====================================================================
    // 5) ��������� UGA                                            �����5)
    CycleOfOperators
     (
     historyHromosomes,
     //---
     ReplicationPortion, //���� ����������.
     NMutationPortion,   //���� ������������ �������.
     ArtificialMutation, //���� ������������� �������.
     GenoMergingPortion, //���� ������������� �����.
     CrossingOverPortion,//���� �������������.
     //---
     ReplicationOffset,  //����������� �������� ������ ���������
     NMutationProbability//����������� ������� ������� ���� � %
     );
    //====================================================================
    // 6) �������� ���� ������� ������� � ������ ��������� ���������. 
    // ���� ��������� ������� ������� ����� ���������,
    // �������� ���������.                                         �����6)
    //���� ����� ����������� - �����������
    if(OptimizeMethod==1)
    {
      //���� ������ ��������� ��������� ����� ���������
      if(Population[0][0]<Chromosome[0])
      {
        //������� ��������� ���������
        for(gene=0;gene<=GeneCount;gene++)
          Chromosome[gene]=Population[gene][0];
        ServiceFunction();
        //������� ������� "���� ��� ���������"
        if(currentEpoch<MinOfCurrentEpoch)
          MinOfCurrentEpoch=currentEpoch;
        if(currentEpoch>MaxOfCurrentEpoch)
          MaxOfCurrentEpoch=currentEpoch;
        SumOfCurrentEpoch+=currentEpoch; currentEpoch=1; resetCounterFF++;
      }
      else
        currentEpoch++;
    }
    //���� ����� ����������� - ������������
    else
    {
      //���� ������ ��������� ��������� ����� ���������
      if(Population[0][0]>Chromosome[0])
      {
        //������� ��������� ���������
        for(gene=0;gene<=GeneCount;gene++)
          Chromosome[gene]=Population[gene][0];
        ServiceFunction();
        //������� ������� "���� ��� ���������"
        if(currentEpoch<MinOfCurrentEpoch)
          MinOfCurrentEpoch=currentEpoch;
        if(currentEpoch>MaxOfCurrentEpoch)
          MaxOfCurrentEpoch=currentEpoch;
        SumOfCurrentEpoch+=currentEpoch; currentEpoch=1; resetCounterFF++;
      }
      else
        currentEpoch++;
    }
    //====================================================================
    //������ ��� ���� �����....
    epochGlob++;
  }
  Print("������ ����� ����=",epochGlob," ����� �������=",resetCounterFF);
  Print("MinOfCurrentEpoch",MinOfCurrentEpoch,
        " AverageOfCurrentEpoch",NormalizeDouble((double)SumOfCurrentEpoch/(double)resetCounterFF,2),
        " MaxOfCurrentEpoch",MaxOfCurrentEpoch);
  Print(ChrCountInHistory," - ���������� ��������");
  Print(AmountStartsFF," - ����� ���-�� �������� FF");
  Print(TotalOfChromosomesInHistory," - ����� ���-�� �������� � �������");
  Print(NormalizeDouble(100.0-((double)ChrCountInHistory*100.0/(double)TotalOfChromosomesInHistory),2),"% ����������");
  Print(Chromosome[0]," - ������ ���������");
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//�������� ��������������
void ProtopopulationBuilding()
{ 
  PopulChromosCount=ChromosomeCount*2;
  //��������� ��������� ����������� �� ����������
  //...������ � ��������� RangeMinimum...RangeMaximum
  for(int chromos=0;chromos<PopulChromosCount;chromos++)
  {
    //������� � 1-�� ������� (0-�� -�������������� ��� VFF) 
    for(int gene=1;gene<=GeneCount;gene++)
      Population[gene][chromos]=
       NormalizeDouble(SelectInDiscreteSpace(RNDfromCI(RangeMinimum,RangeMaximum),RangeMinimum,RangeMaximum,Precision,3),GeneNormalizeDigits);
    TotalOfChromosomesInHistory++;
  }
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//��������� ����������������� ��� ������ �����.
void GetFitness
 (
 double &historyHromosomes[][100000]
 )
{ 
  for(int chromos=0;chromos<ChromosomeCount;chromos++)
    CheckHistoryChromosomes(chromos,historyHromosomes);
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//�������� ��������� �� ���� ��������.
void CheckHistoryChromosomes
 (
 int     chromos,
 double &historyHromosomes[][100000]
 )
{ 
  //-----------------------����������-------------------------------------
  int   Ch1=0;  //������ ��������� �� ����
  int   Ge =0;  //������ ����
  int   cnt=0;  //������� ���������� �����. ���� ���� ���� ��� ���������� 
                //- ��������� ���������� ����������
  //----------------------------------------------------------------------
  //���� � ���� �������� ���� ���� ���������
  if(ChrCountInHistory>0)
  {
    //��������� ��������� � ����, ����� ����� ����� ��
    for(Ch1=0;Ch1<ChrCountInHistory && cnt<GeneCount;Ch1++)
    {
      cnt=0;
      //������� ����, ���� ������ ���� ������ ���-�� ����� � ���� ���������� ���������� ����
      for(Ge=1;Ge<=GeneCount;Ge++)
      {
        if(Colony[Ge][chromos]!=historyHromosomes[Ge][Ch1])
          break;
        cnt++;
      }
    }
    //���� ��������� ���������� ����� ������� ��, ����� ����� ������� ������� �� ����
    if(cnt==GeneCount)
      Colony[0][chromos]=historyHromosomes[0][Ch1-1];
    //���� ��� ����� �� ��������� � ����, �� ���������� ��� �� FF...
    else
    {
      FitnessFunction(chromos);
      //.. � ���� ���� ����� � ���� ��������
      if(ChrCountInHistory<100000)
      {
        for(Ge=0;Ge<=GeneCount;Ge++)
          historyHromosomes[Ge][ChrCountInHistory]=Colony[Ge][chromos];
        ChrCountInHistory++;
      }
    }
  }
  //���� ���� ������, ���������� ��� �� FF � �������� � � ����
  else
  {
    FitnessFunction(chromos);
    for(Ge=0;Ge<=GeneCount;Ge++)
      historyHromosomes[Ge][ChrCountInHistory]=Colony[Ge][chromos];
    ChrCountInHistory++;
  }
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//���� ���������� UGA
void CycleOfOperators
 (
 double &historyHromosomes[][100000],
 //---
 double    ReplicationPortion, //���� ����������.
 double    NMutationPortion,   //���� ������������ �������.
 double    ArtificialMutation, //���� ������������� �������.
 double    GenoMergingPortion, //���� ������������� �����.
 double    CrossingOverPortion,//���� �������������.
 //---
 double    ReplicationOffset,  //����������� �������� ������ ���������
 double    NMutationProbability//����������� ������� ������� ���� � %
 )
{
  //-----------------------����������-------------------------------------
  double          child[];
  ArrayResize    (child,GeneCount+1);
  ArrayInitialize(child,0.0);

  int gene=0,chromos=0, border=0;
  int    i=0,u=0;
  double p=0.0,start=0.0;
  double          fit[][2];
  ArrayResize    (fit,6);
  ArrayInitialize(fit,0.0);

  //������� ���������� ���� � ����� ���������.
  int T=0;
  //----------------------------------------------------------------------

  //������� ���� ���������� UGA
  double portion[6];
  portion[0]=ReplicationPortion; //���� ����������.
  portion[1]=NMutationPortion;   //���� ������������ �������.
  portion[2]=ArtificialMutation; //���� ������������� �������.
  portion[3]=GenoMergingPortion; //���� ������������� �����.
  portion[4]=CrossingOverPortion;//���� �������������.
  portion[5]=0.0;

  //------------------------���� ���������� UGA---------
  //��������� ����� ������� ��������� 
  while(T<ChromosomeCount)
  {
    //============================
    for(i=0;i<6;i++)
    {
      fit[i][0]=start;
      fit[i][1]=start+MathAbs(portion[i]-portion[5]);
      start=fit[i][1];
    }
    p=RNDfromCI(fit[0][0],fit[4][1]);
    for(u=0;u<5;u++)
    {
      if((fit[u][0]<=p && p<fit[u][1]) || p==fit[u][1])
        break;
    }
    //============================
    switch(u)
    {
    //---------------------
    case 0:
      //------------------------����������--------------------------------
      //���� ���� ����� � ����� �������, �������� ����� �����
      if(T<ChromosomeCount)
      {
        Replication(child,ReplicationOffset);
        //������� ����� ����� � ����� �������
        for(gene=1;gene<=GeneCount;gene++) Colony[gene][T]=child[gene];
        //���� ����� ������, ������� ���������� ������
        T++;
        TotalOfChromosomesInHistory++;
      }
      //---------------------------------------------------------------
      break;
      //---------------------
    case 1:
      //---------------------������������ �������-------------------------
      //���� ���� ����� � ����� �������, �������� ����� �����
      if(T<ChromosomeCount)
      {
        NaturalMutation(child,NMutationProbability);
        //������� ����� ����� � ����� �������
        for(gene=1;gene<=GeneCount;gene++) Colony[gene][T]=child[gene];
        //���� ����� ������, ������� ���������� ������
        T++;
        TotalOfChromosomesInHistory++;
      }
      //---------------------------------------------------------------
      break;
      //---------------------
    case 2:
      //----------------------������������� �������-----------------------
      //���� ���� ����� � ����� �������, �������� ����� �����
      if(T<ChromosomeCount)
      {
        ArtificialMutation(child,ReplicationOffset);
        //������� ����� ����� � �����  �������
        for(gene=1;gene<=GeneCount;gene++) Colony[gene][T]=child[gene];
        //���� ����� ������, ������� ���������� ������
        T++;
        TotalOfChromosomesInHistory++;
      }
      //---------------------------------------------------------------
      break;
      //---------------------
    case 3:
      //-------------����������� ����� � ��������������� ������-----------
      //���� ���� ����� � ����� �������, �������� ����� �����
      if(T<ChromosomeCount)
      {
        GenoMerging(child);
        //������� ����� ����� � ����� ������� 
        for(gene=1;gene<=GeneCount;gene++) Colony[gene][T]=child[gene];
        //���� ����� ������, ������� ���������� ������
        T++;
        TotalOfChromosomesInHistory++;
      }
      //---------------------------------------------------------------
      break;
      //---------------------
    default:
      //---------------------------������������---------------------------
      //���� ���� ����� � ����� �������, �������� ����� �����
      if(T<ChromosomeCount)
      {
        CrossingOver(child);
        //������� ����� ����� � �����  �������
        for(gene=1;gene<=GeneCount;gene++) Colony[gene][T]=child[gene];
        //���� ����� ������, ������� ���������� ������
        T++;
        TotalOfChromosomesInHistory++;
      }
      //---------------------------------------------------------------

      break;
      //---------------------
    }
  }//����� ����� ���������� UGA--

  //��������� ����������������� ������ ����� � ������� ��������
  GetFitness(historyHromosomes);

  //������� �������� � �������� ���������
  if(PopulChromosCount>=ChromosomeCount)
  {
    border=ChromosomeCount;
    PopulChromosCount=ChromosomeCount*2;
  }
  else
  {
    border=PopulChromosCount;
    PopulChromosCount+=ChromosomeCount;
  }
  for(chromos=0;chromos<ChromosomeCount;chromos++)
    for(gene=0;gene<=GeneCount;gene++)
      Population[gene][chromos+border]=Colony[gene][chromos];

  //���������� ��������� � ���������� �����������
  RemovalDuplicates();
}//����� �-��
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//����������
void Replication
 (
 double &child[],
 double  ReplicationOffset
 )
{
  //-----------------------����������-------------------------------------
  double C1=0.0,C2=0.0,temp=0.0,Maximum=0.0,Minimum=0.0;
  int address_mama=0,address_papa=0;
  //----------------------------------------------------------------------
  SelectTwoParents(address_mama,address_papa);
  //-------------------���� �������� �����--------------------------------
  for(int i=1;i<=GeneCount;i++)
  {
    //----��������� ������ ���� � ���� --------
    C1 = Population[i][address_mama];
    C2 = Population[i][address_papa];
    //------------------------------------------
    //������������ ��������, ��� �� ����� �� ����� �� ��������� ���������
    if(C1 < RangeMinimum)   C1 = RangeMinimum;
    if(C1 > RangeMaximum)   C1 = RangeMaximum;
    if(C2 < RangeMinimum)   C2 = RangeMinimum;
    if(C2 > RangeMaximum)   C2 = RangeMaximum;
    //------------------------------------------------------------------
    //....��������� ���������� � ���������� �� ���,
    //���� �1>C2, �������� �� �������
    if(C1>C2)
    {
      temp = C1; C1=C2; C2 = temp;
    }
    //--------------------------------------------
    //�������� ������� �������� ������ ����
    Minimum = C1-((C2-C1)*ReplicationOffset);
    Maximum = C2+((C2-C1)*ReplicationOffset);
    //--------------------------------------------
    //������������ ��������, ��� �� ����� �� ����� �� ��������� ���������
    if(Minimum < RangeMinimum) Minimum = RangeMinimum;
    if(Maximum > RangeMaximum) Maximum = RangeMaximum;
    //---------------------------------------------------------------
    temp=RNDfromCI(Minimum,Maximum);
    child[i]=
     NormalizeDouble(SelectInDiscreteSpace(temp,RangeMinimum,RangeMaximum,Precision,3),GeneNormalizeDigits);
  }
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//������������ �������.
void NaturalMutation
 (
 double &child[],
 double  NMutationProbability
 )
{
  //-----------------------����������-------------------------------------
  int    address=0;
  double prob=0.0;
  //----------------------------------------------------------------------
  if(NMutationProbability<0.0)
    prob=0.0;
  if(NMutationProbability>100.0)
    prob=100.0;
  //-----------------����� ��������------------------------
  SelectOneParent(address);
  //---------------------------------------
  for(int i=1;i<=GeneCount;i++)
    if(RNDfromCI(0.0,100.0)<prob)
      child[i]=NormalizeDouble(SelectInDiscreteSpace(RNDfromCI(RangeMinimum,RangeMaximum),RangeMinimum,RangeMaximum,Precision,3),GeneNormalizeDigits);
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//������������� �������.
void ArtificialMutation
 (
 double &child[],
 double  ReplicationOffset
 )
{
  //-----------------------����������-------------------------------------
  double C1=0.0,C2=0.0,temp=0.0,Maximum=0.0,Minimum=0.0,p=0.0;
  int address_mama=0,address_papa=0;
  //----------------------------------------------------------------------
  //-----------------����� ���������------------------------
  SelectTwoParents(address_mama,address_papa);
  //--------------------------------------------------------
  //-------------------���� �������� �����------------------------------
  for(int i=1;i<=GeneCount;i++)
  {
    //----��������� ������ ���� � ���� --------
    C1 = Population[i][address_mama];
    C2 = Population[i][address_papa];
    //------------------------------------------
    //������������ ��������, ��� �� ����� �� ����� �� ��������� ���������
    if(C1 < RangeMinimum)   C1 = RangeMinimum;
    if(C1 > RangeMaximum)   C1 = RangeMaximum;
    if(C2 < RangeMinimum)   C2 = RangeMinimum;
    if(C2 > RangeMaximum)   C2 = RangeMaximum;
    //------------------------------------------------------------------
    //....��������� ���������� � ���������� �� ���,
    //���� �1>C2, �������� �� �������
    if(C1>C2)
    {
      temp=C1; C1=C2; C2=temp;
    }
    //--------------------------------------------
    //�������� ������� �������� ������ ����
    Minimum=C1-((C2-C1)*ReplicationOffset);
    Maximum=C2+((C2-C1)*ReplicationOffset);
    //--------------------------------------------
    //������������ ��������, ��� �� ����� �� ����� �� ��������� ���������
    if(Minimum < RangeMinimum) Minimum = RangeMinimum;
    if(Maximum > RangeMaximum) Maximum = RangeMaximum;
    //---------------------------------------------------------------
    p=MathRand();
    if(p<16383.5)
    {
      temp=RNDfromCI(RangeMinimum,Minimum);
      child[i]=
       NormalizeDouble(SelectInDiscreteSpace(temp,RangeMinimum,RangeMaximum,Precision,3),GeneNormalizeDigits);
    }
    else
    {
      temp=RNDfromCI(Maximum,RangeMaximum);
      child[i]=
       NormalizeDouble(SelectInDiscreteSpace(temp,RangeMinimum,RangeMaximum,Precision,3),GeneNormalizeDigits);
    }
  }
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//������������� �����.
void GenoMerging
 (
 double &child[]
 )
{
  //-----------------------����������-------------------------------------
  int  address=0;
  //----------------------------------------------------------------------
  for(int i=1;i<=GeneCount;i++)
  {
    //-----------------����� ��������------------------------
    SelectOneParent(address);
    //--------------------------------------------------------
    child[i]=Population[i][address];
  }
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//������������.
void CrossingOver
 (
 double &child[]
 )
{
  //-----------------------����������-------------------------------------
  int address_mama=0,address_papa=0;
  //----------------------------------------------------------------------
  //-----------------����� ���������------------------------
  SelectTwoParents(address_mama,address_papa);
  //--------------------------------------------------------
  //��������� ����� �������
  int address_of_gene=(int)MathFloor((GeneCount-1)*(MathRand()/32767.5));

  for(int i=1;i<=GeneCount;i++)
  {
    //----�������� ���� ������--------
    if(i<=address_of_gene+1)
      child[i]=Population[i][address_mama];
    //----�������� ���� ����--------
    else
      child[i]=Population[i][address_papa];
  }
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//����� ���� ���������.
void SelectTwoParents
 (
 int &address_mama,
 int &address_papa
 )
{
  //-----------------------����������-------------------------------------
  int cnt=1;
  address_mama=0;//����� ����������� ����� � ���������
  address_papa=0;//����� ��������� ����� � ���������
  //----------------------------------------------------------------------
  //----------------------------����� ���������--------------------------
  //������ ������� ������� ������ ���������.
  while(cnt<=10)
  {
    //��� ����������� �����
    address_mama=NaturalSelection();
    //��� ��������� �����
    address_papa=NaturalSelection();
    if(address_mama!=address_papa)
      break;
  }
  //---------------------------------------------------------------------
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//����� ������ ��������.
void SelectOneParent
 (
 int &address//����� ������������ ����� � ���������
 )
{
  //-----------------------����������-------------------------------------
  address=0;
  //----------------------------------------------------------------------
  //----------------------------����� ��������--------------------------
  address=NaturalSelection();
  //---------------------------------------------------------------------
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//������������ �����.
int NaturalSelection()
{
  //-----------------------����������-------------------------------------
  int    i=0,u=0;
  double p=0.0,start=0.0;
  double          fit[][2];
  ArrayResize    (fit,PopulChromosCount);
  ArrayInitialize(fit,0.0);
  double delta=(Population[0][0]-Population[0][PopulChromosCount-1])*0.01-Population[0][PopulChromosCount-1];
  //----------------------------------------------------------------------

  for(i=0;i<PopulChromosCount;i++)
  {
    fit[i][0]=start;
    fit[i][1]=start+MathAbs(Population[0][i]+delta);
    start=fit[i][1];
  }
  p=RNDfromCI(fit[0][0],fit[PopulChromosCount-1][1]);

  for(u=0;u<PopulChromosCount;u++)
    if((fit[u][0]<=p && p<fit[u][1]) || p==fit[u][1])
      break;

  return(u);
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//�������� ���������� � ����������� �� VFF
void RemovalDuplicates()
{
  //-----------------------����������-------------------------------------
  int             chromosomeUnique[1000];//������ ������ ������� ������������ 
                                         //������ ���������: 0-��������, 1-����������
  ArrayInitialize(chromosomeUnique,1);   //�����������, ��� ���������� ���
  double          PopulationTemp[][1000];
  ArrayResize    (PopulationTemp,GeneCount+1);
  ArrayInitialize(PopulationTemp,0.0);

  int Ge =0;                             //������ ����
  int Ch =0;                             //������ ���������
  int Ch2=0;                             //������ ������ ���������
  int cnt=0;                             //�������
  //----------------------------------------------------------------------

  //----------------------������ ���������---------------------------1
  //�������� ������ �� ���� ��� ���������...
  for(Ch=0;Ch<PopulChromosCount;Ch++)
  {
    //���� �� ��������...
    if(chromosomeUnique[Ch]!=0)
    {
      //�������� ������ �� ����...
      for(Ch2=0;Ch2<PopulChromosCount;Ch2++)
      {
        if(Ch!=Ch2 && chromosomeUnique[Ch2]!=0)
        {
          //������� ������� ���������� ���������� �����
          cnt=0;
          //������� ����, ���� ���������� ���������� ����
          for(Ge=1;Ge<=GeneCount;Ge++)
          {
            if(Population[Ge][Ch]!=Population[Ge][Ch2])
              break;
            else
              cnt++;
          }
          //���� ��������� ���������� ����� ������� ��, ������� ����� �����
          //..��������� ���������� ����������
          if(cnt==GeneCount)
            chromosomeUnique[Ch2]=0;
        }
      }
    }
  }
  //������� ��������� ���������� ���������� ��������
  cnt=0;
  //��������� ���������� ��������� �� ��������� �����
  for(Ch=0;Ch<PopulChromosCount;Ch++)
  {
    //���� ��������� ���������, ��������� �, ���� ���, �������� � ���������
    if(chromosomeUnique[Ch]==1)
    {
      for(Ge=0;Ge<=GeneCount;Ge++)
        PopulationTemp[Ge][cnt]=Population[Ge][Ch];
      cnt++;
    }
  }
  //�������� ���������� "����� ��������" �������� �������� ���������� ��������
  PopulChromosCount=cnt;
  //������ ���������� ��������� ������� � ������ ��� ���������� �������� 
  //..������������ ��������� 
  for(Ch=0;Ch<PopulChromosCount;Ch++)
    for(Ge=0;Ge<=GeneCount;Ge++)
      Population[Ge][Ch]=PopulationTemp[Ge][Ch];
  //=================================================================1

  //----------------������������ ���������---------------------------2
  PopulationRanking();
  //=================================================================2
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//������������ ���������.
void PopulationRanking()
{
  //-----------------------����������-------------------------------------
  int cnt=1, i = 0, u = 0;
  double          PopulationTemp[][1000];           //��������� ��������� 
  ArrayResize    (PopulationTemp,GeneCount+1);
  ArrayInitialize(PopulationTemp,0.0);

  int             Indexes[];                        //������� ��������
  ArrayResize    (Indexes,PopulChromosCount);
  ArrayInitialize(Indexes,0);
  int    t0=0;
  double          ValueOnIndexes[];                 //VFF ���������������
                                                    //..�������� ��������
  ArrayResize    (ValueOnIndexes,PopulChromosCount);
  ArrayInitialize(ValueOnIndexes,0.0); double t1=0.0;
  //----------------------------------------------------------------------

  //��������� ������� �� ��������� ������� temp2 � 
  //...��������� ������ ������ �� ������������ �������
  for(i=0;i<PopulChromosCount;i++)
  {
    Indexes[i] = i;
    ValueOnIndexes[i] = Population[0][i];
  }
  if(OptimizeMethod==1)
  {
    while(cnt>0)
    {
      cnt=0;
      for(i=0;i<PopulChromosCount-1;i++)
      {
        if(ValueOnIndexes[i]>ValueOnIndexes[i+1])
        {
          //-----------------------
          t0 = Indexes[i+1];
          t1 = ValueOnIndexes[i+1];
          Indexes   [i+1] = Indexes[i];
          ValueOnIndexes   [i+1] = ValueOnIndexes[i];
          Indexes   [i] = t0;
          ValueOnIndexes   [i] = t1;
          //-----------------------
          cnt++;
        }
      }
    }
  }
  else
  {
    while(cnt>0)
    {
      cnt=0;
      for(i=0;i<PopulChromosCount-1;i++)
      {
        if(ValueOnIndexes[i]<ValueOnIndexes[i+1])
        {
          //-----------------------
          t0 = Indexes[i+1];
          t1 = ValueOnIndexes[i+1];
          Indexes   [i+1] = Indexes[i];
          ValueOnIndexes   [i+1] = ValueOnIndexes[i];
          Indexes   [i] = t0;
          ValueOnIndexes   [i] = t1;
          //-----------------------
          cnt++;
        }
      }
    }
  }
  //�������� ��������������� ������ �� ���������� ��������
  for(i=0;i<GeneCount+1;i++)
    for(u=0;u<PopulChromosCount;u++)
      PopulationTemp[i][u]=Population[i][Indexes[u]];
  //��������� ��������������� ������ �������
  for(i=0;i<GeneCount+1;i++)
    for(u=0;u<PopulChromosCount;u++)
      Population[i][u]=PopulationTemp[i][u];
}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//��������� ��������� ����� �� ��������� ���������.
double RNDfromCI(double RangeMinimum,double RangeMaximum) 
{ return(RangeMinimum+((RangeMaximum-RangeMinimum)*MathRand()/32767.5));}
//������������������������������������������������������������������������

//������������������������������������������������������������������������
//����� � ���������� ������������.
//������:
//1-��������� �����
//2-��������� ������ 
//�����-�� ����������
double SelectInDiscreteSpace
 (
 double In, 
 double InMin, 
 double InMax, 
 double step, 
 int    RoundMode
 )
{
  if(step==0.0)
    return(In);
  // ��������� ������������ ������
  if( InMax < InMin )
  {
    double temp = InMax; InMax = InMin; InMin = temp;
  }
  // ��� ��������� - ������ ���������� �������
  if( In < InMin ) return( InMin );
  if( In > InMax ) return( InMax );
  if( InMax == InMin || step <= 0.0 ) return( InMin );
  // �������� � ��������� ��������
  step = (InMax - InMin) / MathCeil ( (InMax - InMin) / step );
  switch( RoundMode )
  {
  case 1:  return( InMin + step * MathFloor ( ( In - InMin ) / step ) );
  case 2:  return( InMin + step * MathCeil  ( ( In - InMin ) / step ) );
  default: return( InMin + step * MathRound ( ( In - InMin ) / step ) );
  }
}
//������������������������������������������������������������������������
