//+------------------------------------------------------------------+
//|                                                     NeuroNet.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#define iMaxLayer	5
#define iMaxNeuron	100
#define iMaxPattern	5000
// ���� ����� (LayerType) (� ��������������� ������� ��������)
#define ltIn	0
#define ltOut	1
#define ltBack	2
#define ltKoh	3

#define RAND_MAX 1

//double Math_Abs(double x);
//int Sign(double x);
//double Sigmoid(double x);
//int TradeDir(double x);// ����������� ��������
//------------------------------------------------
class CNeuroNet //: public CObject  
  {
public:
   int               nCycle;      // ����� ������ �������� �� ��������
   int               nPattern;   // ����� ��������� ���������
   int               nLayer;      // ����� ��������� �����
   double            Delta;   // ��������� ����������� ������ ������
   int               nNeuron[iMaxLayer];         // ����� �������� � ���� (�� �����)
   int               LayerType[iMaxLayer];      // ���� ����� (�� �����)
   double            W[iMaxLayer][iMaxNeuron][iMaxNeuron];// ���� �� �����
   double            dW[iMaxLayer][iMaxNeuron][iMaxNeuron];// ��������� ����
   double            Thresh[iMaxLayer][iMaxNeuron];      // �����
   double            dThresh[iMaxLayer][iMaxNeuron];      // ��������� ������
   double            Out[iMaxLayer][iMaxNeuron];         // �������� ������
   double            OutArr[iMaxNeuron];               // ������������� �������� ������ ���� ��������
   int               IndexWin[iMaxNeuron];               // ������������� ������� �������� ���� ��������
   double            Err[iMaxLayer][iMaxNeuron][iMaxNeuron];// ������

   double            Speed;         // �������� ��������
   double            Impuls;         // ������� ��������

   double            in[100][iMaxPattern];   // ������ ������� ��������
   double            out[10][iMaxPattern];   // ������ �������� ��������
   double            pout[10];            // ���������� ������ �������� ��������
   double            bar[4][iMaxPattern];      // ����, �� ������� ������
   int               TradePos;   // ����������� ������
   double            ProfitPos;   // ���������� �������/������ ������

public:
                     CNeuroNet();
   virtual          ~CNeuroNet();
   // �������
   void              Init(int aPattern=1,int aLayer=1,int aCycle=10000,double aDelta=0.01,double aSpeed=0.1,double aImpuls=0.1);
   // ������� ��������
   void              CalculateLayer();   // ������ ������ ����
   void              CalculateError();   // ������ ������ /��� ������� Target/
   void              ChangeWeight();   // ������������� �����
   bool              TrainNetwork();   // �������� ����
   void              CalculateLayer(int L);   // ������ ������ ���� ��������
   void              CalculateError(int L); // ������ ������ ���� ��������
   void              ChangeWeight(int L);   // ������������� ����� ��� �������� ����
   bool              TrainNetwork(int L);   // �������� ���� ��������

   bool              TrainMPS();   // �������� ���� �� ��������� �������� �������

                                   // ������ ��� ������ � ������� �����
   bool              bInProc;   // ���� ����� � ������� TrainNetwork
   bool              bStop;      // ���� ��� ��������������� ����������� ������� TrainNetwork
   int               loop;
   int               pat;
   int               iMaxErr;   // ������� � ������������ �������
   double            dMaxErr;   // ������������ ������
   double            sErr;   // ������� ������ ��������
   int               iNeuron;   // ������������ ����� ��������
   int               iWinNeuron;   // ����� ��������

   int               WinNeuron[iMaxNeuron]; // ������ �������� ��������
   int               NeuroPat[iMaxPattern][iMaxNeuron]; // ������ �������� ��������

   void              LinearCovariation();   // ������������ �������
   void              SaveW();            // ������ ��������� ���������� 
  };
//+------------------------------------------------------------------+
int Sign(double x)
  {
   if(x>=0) return(1); else return(-1);
  }
//------------------------------------------------
double Math_Abs(double x)
  {
   if(x>=0) return(x); else return(-x);
  }


double Sigmoid(double x)// ���������� ������������� ������� ���������
  {
   return(1/(1+exp(-x)));
  }
//------------------------------------------------
int TradeDir(double x)// ����������� ��������
  {
   if(x>=0.5) return(1); else return(-1);
  }
//------------------------------------------------

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
CNeuroNet::CNeuroNet()
  {
   nCycle=10000; Delta=0.01; nPattern=1;
   sErr=0; loop=0; pat=0; iMaxErr=0; dMaxErr=0; bInProc=false; bStop=false;
  }
//------------------------------------------------
CNeuroNet::~CNeuroNet()
  {
  }
//------------------------------------------------
void CNeuroNet::Init(int aPattern,int aLayer,int aCycle,double aDelta,double aSpeed,double aImpuls)
  {
// �������������� ����������
   nCycle=aCycle; Delta=aDelta; nPattern=aPattern; nLayer=aLayer+1; Speed=aSpeed; Impuls=aImpuls;
   if(nPattern>iMaxPattern)
     {
      //AfxMessageBox("�� ������ ����� ��������!");
      nPattern=iMaxPattern;
     }
// �������������� ����
   int N,pN,L;
// ���������� ���� �����
   LayerType[0]=ltIn;   // �������� ���� (������ ��������)
                        //	LayerType[1]=ltKoh;	// ������ ���� ���� �������� ��� ������������� ������� ��������
   LayerType[nLayer]=ltOut; // ��������� ����
   for(L=1;L<nLayer;L++) LayerType[L]=ltBack; // ������� ���� � ������� ��������� ���������������

                                              //srand(time(NULL)); // ������������� �������
   double p=0.00001;
// �������� ������� � ������ ��������� ����
   for(L=1;L<nLayer;L++)
     {
      for(N=0;N<nNeuron[L];N++)
        {
         for(pN=0;pN<nNeuron[L-1];pN++)
           {
            dW[L][N][pN]=0; W[L][N][pN]=p+double(rand())/RAND_MAX;
           }
         dThresh[L][N]=0; Thresh[L][N]=p+double(rand())/RAND_MAX;
        }
     }
// ������������ ������� � ����� �� [-1,1]
   LinearCovariation();

/*	L=1; // ��������� ���� ���� ��������
	for(N=0;N<nNeuron[L];N++)
	{
		p=0; for(pN=0;pN<nNeuron[L-1];pN++) p+=W[L][N][pN]*W[L][N][pN];
		p=sqrt(p); for(pN=0;pN<nNeuron[L-1];pN++) W[L][N][pN]=W[L][N][pN]/p;
		// ��� ���� �� ��������
		for(pN=0;pN<nNeuron[L-1];pN++) W[L][N][pN]=1/sqrt(nNeuron[L]);
	}
*/
  }
//------------------------------------------------
void CNeuroNet::CalculateLayer() // ������ ������ ����
  {
   int N,pN,L;
   double sum;

   for(L=1;L<nLayer;L++) // �������� �� �����
     {
      switch(LayerType[L]) // ���������� ��� ����
        {
         case ltBack: // ���� - ����� ��������� ���������������
            for(N=0;N<nNeuron[L];N++)
              {
               sum=0;
               for(pN=0;pN<nNeuron[L-1];pN++)
                  sum+=W[L][N][pN]*Out[L-1][pN];
               Out[L][N]=Sigmoid(sum+Thresh[L][N]);
              }
            break;
         case ltKoh: // ���� ��������
            CalculateLayer(L);
            break;
        }
     }
  }
//------------------------------------------------
void CNeuroNet::CalculateLayer(int L) // ������ ������ ���� ��������
  {
   if(LayerType[L]!=ltKoh) return;// ������ ���� ��������

   int N,pN; double Max=0;
   for(N=0;N<nNeuron[L];N++) // ������� ������ ��������
     {
      Out[L][N]=0;
      for(pN=0;pN<nNeuron[L-1];pN++) Out[L][N]+=W[L][N][pN]*Out[L-1][pN];
      OutArr[N]=Out[L][N];  IndexWin[N]=N;
     }
// ��������� ������ ������� �� ��������
   bool b=true;
   while(b)
     {
      b=false;
      for(N=1;N<nNeuron[L];N++)
        {
         if(OutArr[N]>OutArr[N-1])
           {
            Max=OutArr[N]; OutArr[N]=OutArr[N-1]; OutArr[N-1]=Max;
            pN=IndexWin[N]; IndexWin[N]=IndexWin[N-1]; IndexWin[N-1]=pN; b=true;
           }
        }
     }
// ���������� ���������� ����, ������� ������� ��������� ������� � ��������� �����
// ������� �� ��������� �� ����� ������ ��������, 
// ���������� ����� �� ������ ������������� �����������
   double h=nNeuron[L]-((double)(loop)/(double)(10*nNeuron[L]));
   if(h<1) h=1; if(h>nNeuron[L]) h=nNeuron[L];
   iWinNeuron=1;
  }
//------------------------------------------------
void CNeuroNet::CalculateError() // ������ ������
  {
   int N,nN,L;
   double sum;
   for(L=nLayer-1; L>0;L--) // �������� �� �����
     {
      if(LayerType[L]==ltKoh) break; // ������ �� ��� ��������
      switch(LayerType[L+1]) // ���������� ��� ���������� ����
        {
         case ltOut: // �������� ������ 
            for(N=0;N<nNeuron[L];N++) // ��������� ������ �������� ��������� ����
            Err[L][N][0]=Out[L][N]*(1-Out[L][N])*(Out[L+1][N]-Out[L][N]);
            break;
         case ltBack: // ������� ���� �� ������ ��������� ���������������
            for(N=0;N<nNeuron[L];N++) // �������� �� �������� � ����
              {
               sum=0;
               for(nN=0;nN<nNeuron[L+1];nN++) sum+=Err[L+1][nN][0]*W[L+1][nN][N];
               Err[L][N][0]=Out[L][N]*(1-Out[L][N])*sum;
              }
            break;
        }
     }
  }
//------------------------------------------------
void CNeuroNet::CalculateError(int L) // ������ ������ ���� ��������
  {
   if(LayerType[L]!=ltKoh) return;// ������ ���� ��������

   int N,pN;
// �������� �������� ������� ��������� �� ���������� ������� ��������
   Speed=0.2-sqrt(double(loop)/double(nNeuron[L]*1e4)); if(Speed<0.0005) Speed=0.0005;
// �������� �� ���������� ������ �������� � ������� �� ���������
   for(N=0;N<nNeuron[L];N++)
     {
      for(pN=0;pN<nNeuron[L-1];pN++)
        {
         Err[L][N][pN]=Out[L-1][pN]-W[L][N][pN];
         dW[L][N][pN]=Speed*Err[L][N][pN];//+Impuls*dW[L][N][pN];
        }
     }
  }
//------------------------------------------------
void CNeuroNet::ChangeWeight() // ������������� �����
  {
   int pN,N,L,ea;
   double max=0;
   for(L=nLayer-1;L>0;L--)
     {
      switch(LayerType[L]) // ���������� ��� ����
        {
         case ltBack: // ���� - ����� ��������� ���������������
            for(N=0;N<nNeuron[L];N++) // ������� ������������ ������
            if(Math_Abs(Err[L][N][0])>Math_Abs(max)) { max=Err[L][N][0]; ea=N; }
            // ������ ���� ��� ������
            for(N=0;N<nNeuron[L];N++)
              {
               for(pN=0;pN<nNeuron[L-1];pN++)
                 {
                  // ��� ������ "�������" �������� ��������
                  if(N==ea) dW[L][N][pN]=2*Speed*Err[L][N][0]*Out[L-1][pN]+Impuls*dW[L][N][pN];
                  else dW[L][N][pN]=Speed*Err[L][N][0]*Out[L-1][pN]+Impuls*dW[L][N][pN];
                  //���� ������������� ����� ���������
                  if(Math_Abs(dW[L][N][pN])<1e-8) dW[L][N][pN]=1e-7*Sign(dW[L][N][pN]);
                  W[L][N][pN]+=dW[L][N][pN];
                 }
               // ��� ������ "�������" �������� ��������
               if(N==ea) dThresh[L][N]=2*Speed*Err[L][N][0]+Impuls*dThresh[L][N];
               else dThresh[L][N]=Speed*Err[L][N][0]+Impuls*dThresh[L][N];
               //���� ������������� ����� ���������
               if(Math_Abs(dThresh[L][N])<1e-8) dThresh[L][N]=10*dThresh[L][N];
               Thresh[L][N]+=dThresh[L][N];
              }
            break;
        }
     }
  }
//------------------------------------------------
void CNeuroNet::ChangeWeight(int L) // ������������� ����� ��� ��������
  {
   int pN,N,i;
   double h=double(nPattern)/double(nNeuron[L]);
// ������������ ���� ���������� ����
   if(LayerType[L]!=ltKoh) return;// ������ ���� ��������

   N=0; i=0; // � ��������� ��������������!
   while(i<iWinNeuron && N<nNeuron[L])
     {
      //		if (WinNeuron[IndexWin[N]]<int(h+1))
        {
         WinNeuron[IndexWin[N]]++; // ������� ������� �����������
         for(pN=0;pN<nNeuron[L-1];pN++)
            W[L][IndexWin[N]][pN]+=dW[L][IndexWin[N]][pN];
         i++;
        }
      N++;
     }
   N=nNeuron[L]-1;
   if(i<iWinNeuron)
      for(pN=0;pN<nNeuron[L-1];pN++) W[L][IndexWin[N]][pN]+=dW[L][IndexWin[N]][pN];
  }
//------------------------------------------------
bool CNeuroNet::TrainNetwork() // �������� �����
  {
   int i,ipat;
   bool bError=true;
   double err,ser2,dmax;
   bInProc=true;
   loop=1;
   while(!bStop && (bError || (nCycle>0 && loop<nCycle))) // ������ � ���� ��������
     {
      for(pat=0;pat<nPattern;pat++) // �������� �� ������� � ������� ����
        {
         for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][pat]; // ����� ��������� ������
         for(i=0;i<nNeuron[nLayer];i++) Out[nLayer][i]=out[i][pat]; // ����� ������ ���������� �������
         CalculateLayer(); // ���������� �����
         CalculateError(); // ���������� ������
         ChangeWeight(); // ���������������� ����
        }
      bError=false; // ���� ����� ��������
      dmax=0; ser2=0;
      for(pat=0; pat<nPattern;pat++) // ��������� �������� ��������
        {
         for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][pat]; // ����� ��������� ������
         for(i=0;i<nNeuron[nLayer];i++) Out[nLayer][i]=out[i][pat]; // ����� ������ ���������� �������
         CalculateLayer(); // ���������� �����
                           // ���� ���� � ����� ������� ���� ������, �� ���������� ��������
         for(i=0;i<nNeuron[nLayer-1];i++)
           {
            err=Out[nLayer][i]-Out[nLayer-1][i];   // �������� ������
            if(Math_Abs(err)>Delta) bError=true;   // ��������� � ���������
            if(Math_Abs(err)>Math_Abs(dmax)) { ipat=pat; dmax=err; }// ������������
            ser2+=(err*err);// ������������������
           }
        }
      sErr=ser2; dMaxErr=dmax; iMaxErr=ipat;
      loop++;
     }
   bInProc=false;
   return(!bError);// ���������� ��������� �������� - ������ ������� ��� ���
  }
//------------------------------------------------
bool CNeuroNet::TrainNetwork(int L) // �������� ���� ��������
  {
   if(LayerType[L]!=ltKoh) return(false);// ������ ���� ��������

   int N,pN,ipat;
   bool bError=true;
   double ser2,dmax,Alfa,err,Betta;
   bInProc=true;
   loop=1; L=1;
   while(!bStop && (bError || (nCycle>0 && loop<nCycle))) // ������ � ���� ��������
     {
      //		iNeuron=0; // �������� ������� �������� �����������
      for(N=0;N<nNeuron[L];N++) { for(pN=0;pN<nNeuron[L];pN++) WinNeuron[N]=0; }
      for(pat=0;pat<nPattern;pat++) { for(N=0;N<nNeuron[L];N++) NeuroPat[pat][N]=0; }
      // ���������� ����� �������� ����������
      Alfa=double(loop)/1e5; if(Alfa>1) Alfa=1;
      Alfa=1; Betta=(1-Alfa)/sqrt(nNeuron[L-1]);
      for(pat=0;pat<nPattern;pat++) // �������� �� ������� � ������� ����
        {
         // ����� ��������� ������
         for(N=0;N<nNeuron[L-1];N++) Out[L-1][N]=Alfa*in[N][pat]+Betta;
         CalculateLayer(L); // ���������� �����
         CalculateError(L); // ��������� ������ ����
         ChangeWeight(L); // ����������������� ����
         NeuroPat[pat][IndexWin[0]]++; // ��������������� ������� �� �������
                                       //			if (iWinNeuron>iNeuron) iNeuron=iWinNeuron;
         if(pat==1) iNeuron=IndexWin[0];
        }

      //		bError=false; // ���� ����� ��������
      dmax=WinNeuron[0]; pat=0;
      // ������� ������� ������� ����������
      for(N=0;N<nNeuron[L];N++) if(WinNeuron[N]>dmax) { dmax=WinNeuron[N]; pat=N; }
      // ������� ����� ��������� ������ � ����� "�����" ����������
      for(N=0;N<nNeuron[L];N++)
        {
         //			if (WinNeuron[N]==0) 
         //				for(pN=0;pN<nNeuron[L-1];pN++) W[L][N][pN]=W[L][pat][pN]; 
        }

      dmax=0;
      for(pat=0; pat<nPattern;pat++) // ��������� �������� ��������
        {
         ser2=0;
         // ����� ��������� ������
         for(N=0;N<nNeuron[L-1];N++) Out[L-1][N]=Alfa*in[N][pat]+Betta;
         CalculateLayer(L); // ���������� �����
         CalculateError(L); // ��������� ������ ����
         for(N=0;N<iWinNeuron;N++) // ������� ������������������ ������
           {
            for(pN=0;pN<nNeuron[L-1];pN++) // �������������� ������ ����
              {
               err=Math_Abs(Err[L][IndexWin[N]][pN]);
               ser2+=(err*err);
               if(err>dmax) { ipat=pat; dmax=err; }   // ��������� ������������
              }
           }
         // ���� ���� � ����� ������� ���� ������� ������, �� ���������� ��������
         if(ser2>Delta) bError=true;   // ��������� � ���������
        }
      sErr=ser2; dMaxErr=dmax; iMaxErr=ipat;
      loop++;
      // ��������� ���������� � ����
      //		if (loop==4000) SaveW();

     }
   bInProc=false;
   return(!bError);// ���������� ��������� �������� - ������ ������� ��� ���
  }
//------------------------------------------------
void CNeuroNet::LinearCovariation()// ������������ ������� �� [0,1]
  {
   int pat,N,pN,L,k=1;
   double max,min;
// ������� �������
   for(N=0; N<nNeuron[0]; N++) // �� ���� �������� �������� ����
     {
      min=in[N][0]; // ���� ������� �� ���� �������
      for(pat=0; pat<nPattern; pat++) if(in[N][pat]<min) min=in[N][pat];
      // ��������� �� �������� ������������ �������� 
      for(pat=0; pat<nPattern; pat++) in[N][pat]-=min;
      max=in[N][0]; // ���� �������� �� ���� �������
      for(pat=0; pat<nPattern; pat++) if(in[N][pat]>max) max=in[N][pat];
      // ������ �� [-1,1]
      for(pat=0; pat<nPattern; pat++) in[N][pat]=2*(in[N][pat]/max)-1;
     }
/*
	for(pat=0;pat<nPattern;pat++)	// ��������� ������� ������ �� ���� �����
	{
		p=0;
		for(N=0;N<nNeuron[0];N++) p+=in[N][pat]*in[N][pat];
		p=sqrt(p);
		for(N=0;N<nNeuron[0];N++) in[N][pat]=in[N][pat]/p;
	}
*/
// ���� �����
   for(L=0; L<nLayer; L++)
     {
      if(LayerType[L]==ltBack && nNeuron[L]>1)
        {
         for(pN=0; pN<nNeuron[L-1]; pN++)
           {
            min=W[L][0][pN]; // ���� ������� �� ���� �������
            for(N=0; N<nNeuron[L]; N++) if(W[L][N][pN]<min) min=W[L][N][pN];
            // ��������� �� �������� ������������ �������� 
            for(N=0; N<nNeuron[L]; N++) W[L][N][pN]-=min;
            max=W[L][0][pN]; // ���� �������� �� ���� �������
            for(N=0; N<nNeuron[L]; N++) if(W[L][N][pN]>max) max=W[L][N][pN];
            // ������ �� [-1,1]
            for(N=0; N<nNeuron[L]; N++) W[L][N][pN]=2*(W[L][N][pN]/max)-1;
           }
        }
      if(LayerType[L]==ltBack && nNeuron[L]==1) // ���� � ���� ������ ���� ������
        {
         N=0;
         min=W[L][0][0]; // ���� ������� �� ���� �������
         for(pN=0; pN<nNeuron[L-1]; pN++) if(W[L][N][pN]<min) min=W[L][N][pN];
         // ��������� �� �������� ������������ �������� 
         for(pN=0; pN<nNeuron[L-1]; pN++) W[L][N][pN]-=min;
         max=W[L][N][0]; // ���� �������� �� ���� �������
         for(pN=0; pN<nNeuron[L-1]; pN++) if(W[L][N][pN]>max) max=W[L][N][pN];
         // ������ �� [-1,1]
         for(pN=0; pN<nNeuron[L-1]; pN++) W[L][N][pN]=2*(W[L][N][pN]/max)-1;
        }
     }
  }
//------------------------------------------------
void CNeuroNet::SaveW() // ��������� ���������� � ����
  {
//int N, pN, L=1;
//CFile file;
//CString FileName= "F:\\ForexWork\\MetaTraders\\MetaTrader 4 Ft-Trade\\experts\\files\\NeuroWgh.dat";
//file.Open(FileName, CFile::modeCreate); file.Close();
//file.Open(FileName, CFile::modeWrite);
//// ���������� ����
//for(N=0;N<nNeuron[L];N++) 
//{
//	for(pN=0;pN<nNeuron[L-1];pN++) 
//		file.Write(&W[L][N][pN], sizeof(double));
//}
//file.Flush(); file.Close();
  }
//------------------------------------------------
bool CNeuroNet::TrainMPS() // �������� �����
  {
   int i,ipat;
   bool bError=true;
   double ser2,dmax=0;
   double TP=50;
   bInProc=true; bStop=false;
   loop=1;
   while(!bStop && (bError || (nCycle>0 && loop<nCycle))) // ������ � ���� ��������
     {
      ser2=0;
      pat=0; // ��������� ����� ��� ������� �������
      for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][pat]; // ����� ��������� ������
      CalculateLayer(); // ���������� �����
                        // ���� ����� ������ ����, �� �������, ����� �������
      TradePos=TradeDir(Out[nLayer-1][0]); ipat=pat;

      for(pat=1;pat<nPattern;pat++) // �������� �� ������� � ������� ����
        {
         for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][pat]; // ����� ��������� ������
         CalculateLayer(); // ���������� �����
                           // ������� �������/������ �� ����� �������� [3]
         ProfitPos=1e4*TradePos*(bar[3][pat]-bar[3][ipat]);
         // ���� ���������� ����������� �������� ��� �������� ����-�����
         if(/*TradeDir(Out[nLayer-1][0])!=TradePos || */ProfitPos>=TP || ProfitPos<=-TP)
           {
            // ������������ ����
            if(pat==48)
               CalculateLayer(); // ���������� �����
            ser2+=ProfitPos;
            // ������ �������� ����� ����
            Out[nLayer][0]=Sigmoid(0.1*TradePos*ProfitPos);
            // ����� ��������� ������, �� �������� �����������
            for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][ipat];
            CalculateLayer(); // ���������� �����
            CalculateError(); // ���������� ������
            ChangeWeight(); // ���������������� ����
            if(pat==48)
               CalculateLayer(); // ���������� �����
            // ��������� �� ����� �����
            for(i=0;i<nNeuron[0];i++) Out[0][i]=in[i][pat];
            CalculateLayer(); // ���������� �����
                              // ���� ����� ������ ����, �� �������, ����� �������
            TradePos=TradeDir(Out[nLayer-1][0]);
            ipat=pat;
           }
        }

      sErr=ser2; dMaxErr=ser2; iMaxErr=(int)ser2;
      loop++;
     }
   bInProc=false;
   return(!bError);// ���������� ��������� �������� - ������ ������� ��� ���
  }
class CWorkThread //: public CWinThread
{
	//DECLARE_DYNCREATE(CWorkThread)
public:
	int nBAR;	// ����� ����� ��� �������� (����� ��������� ��������)
	int nIN;		// ����������� ����� (����� �������� � �������)
	int nOUT;	// ����������� ������ 
	CNeuroNet NN; // ����

	CWorkThread();
	virtual ~CWorkThread();
	
	void ProcessedMsg();		// ��������� �������

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CWorkThread)
	public:
	virtual bool InitInstance();
	//virtual bool PreTranslateMessage(MSG* pMsg);
	//}}AFX_VIRTUAL

	// Generated message map functions
	//{{AFX_MSG(CWorkThread)
		// NOTE - the ClassWizard will add and remove member functions here.
	//}}AFX_MSG

	//DECLARE_MESSAGE_MAP()
};

CWorkThread::CWorkThread()
{
}
//------------------------------------------------
bool CWorkThread::InitInstance()
{
	return (true);
}
//------------------------------------------------
CWorkThread::~CWorkThread()
{
}

//BEGIN_MESSAGE_MAP(CWorkThread, CWinThread)
	//{{AFX_MSG_MAP(CWorkThread)
		// NOTE - the ClassWizard will add and remove mapping macros here.
	//}}AFX_MSG_MAP
//END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CWorkThread message handlers

void CWorkThread::ProcessedMsg()
{
	// ��������� ��������� 
//	CFile file;
//	int i, j, k;
//	CString FileName; // ����� ����� ������ 
//	FileName= "F:\\ForexWork\\MetaTraders\\MetaTrader 4 Ft-Trade\\experts\\files\\MA25_15.in";
//	file.Open(FileName, CFile::modeRead);
//	// ������ ��������� �����
//	file.Read(&nBAR, sizeof(int));// ����� ��������
//	file.Read(&nIN, sizeof(int)); // ����������� �����
//	file.Read(&nOUT, sizeof(int));// ����������� ������
//	// ����� �� ����� �����
//	for (i=0; i<nBAR; i++) for (j=0; j<nIN; j++) file.Read(&NN.in[j][i], sizeof(double)); 
//	// ����� �� ����� ������
//	for (i=0; i<nBAR; i++) for (j=0; j<nOUT; j++) file.Read(&NN.out[j][i], sizeof(double));
//	file.Close(); // ������� ���� ������
//
//	FileName= "F:\\ForexWork\\MetaTraders\\MetaTrader 4 Ft-Trade\\experts\\files\\MA25_15.bar";
//	file.Open(FileName, CFile::modeRead);
//	// ����� �� ����� ����
//	for (i=0; i<nBAR; i++)  for (j=0; j<4; j++) file.Read(&NN.bar[j][i], sizeof(double)); 
//	file.Close(); // ������� ���� ������
//
//	NN.nNeuron[0]=nIN;	// ����������� �������� ������� ������
//	NN.nNeuron[1]=2*nIN;// ����� �������� � ���� // ��������
//	NN.nNeuron[2]=nIN;	// ����� �������� � ���� 
//	NN.nNeuron[3]=5;	// ����� �������� � ���� 
//	NN.nNeuron[4]=nOUT;	// ����� �������� � �������� ���� (����������� ��������� � Target)
//	NN.nNeuron[5]=nOUT;	// ����������� ��������� �������� ������� ������
//	NN.Init(1000, 4, 6000, 1e-8, 0.15, 0.15); // ������� ���� � ����
//
////	NN.TrainNetwork(1);	// ���������������� ����� �� ���� ��������
//	NN.TrainMPS();	// ������ �������� ����
//
//	// ��������� ���� � ���� ��� ���������� MQL
//	file.Open(FileName+".wgh", CFile::modeCreate); file.Close();
//	file.Open(FileName+".wgh", CFile::modeWrite);
//	// ���������� ��������� �����
//	file.Write(&nIN, sizeof(int)); // ����������� �����
//	file.Write(&nOUT, sizeof(int));// ����������� ������
//	file.Write(&NN.nLayer, sizeof(int));// ����������� ����
//	// ���������� ����� ����� � �� �����������
//	for (k=0; k<NN.nLayer; k++) file.Write(&NN.nNeuron[k], sizeof(int)); // ��� �����
//	// ���������� ���� � ������ � ����
//	for (k=1; k<NN.nLayer; k++)
//		for (i=0; i<NN.nNeuron[k]; i++)
//		{
//			for (j=0; j<NN.nNeuron[k-1]; j++)
//				file.Write(&NN.W[k][i][j], sizeof(double));	// ���� ����
//			file.Write(&NN.Thresh[k][i], sizeof(double));	// ����� ��� ������ �������
//		}
//	file.Flush(); file.Close();
//
//	// �������� ��������� � ���������� ������
//	AfxGetMainWnd()->PostMessage(WM_COMMAND, WT_END_JOB, 0);
}
//------------------------------------------------
//BOOL CWorkThread::PreTranslateMessage(MSG* pMsg) 
//{
//	switch (pMsg->message)
//	{
//	case WM_COMMAND:
//		switch (pMsg->wParam)
//		{
//		case WT_HAVE_JOB:
//			ProcessedMsg(); // ������������
//			break;
//		}
//		break;
//	}
//	return CWinThread::PreTranslateMessage(pMsg);
//}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//#define PUPIL	0
//#define TEACHER	1
//
//
//
////------------------------------------------------
//class CLayer //: public CObject  
//{
//public:
//	int	Type;				// ���� //������-�������
//	int nNeuron;			// ����� �������� � ����
//	double W[500][500];		// ���
//	double cW[500][500];	// ��������� ����
//	double Thresh[500];		// �����
//	double cThresh[500];	// ��������� ������
//	double Out[500];		// �������� ������
//	double Err[500];		// ������
//	CLayer *prev;			// ���������� ���� (��� ������� ������)
//	CLayer *next;			// ��������� ���� (��� BackPropagation)
//	double Speed;			// �������� ��������
//	double Impuls;			// ������� ��������
//
//	// ������� ��� ������
//	void CalculateLayer();	// ������ ������ ����
//	void CalculateError();	// ������ ������ /��� ������� Target/
//	void ChangeWeight();	// ������������� �����
//
//public:
//	CLayer();
//	virtual ~CLayer();
//	// �������
//	void Init(int aType=TEACHER, CLayer *ap=NULL, CLayer *an=NULL, double aSpeed=0.6, double aImpuls=0.6);
//	void SetNeuron(int aNeuron=1);
//};
//
//CLayer::CLayer()
//{
//	Type=TEACHER; nNeuron=0;
//	prev=NULL; next=NULL;
//	Speed=0.6; Impuls=0.6;
//}
////------------------------------------------------
//void CLayer::Init(int aType, CLayer *ap, CLayer *an, double aSpeed, double aImpuls)
//{
//	Speed=aSpeed;
//	Impuls=aImpuls;
//	prev=ap; next=an;
//	Type=aType; 
//}
////------------------------------------------------
//void CLayer::SetNeuron(int aNeuron)
//{
//	nNeuron=aNeuron;
//	if (Type==TEACHER || prev==NULL)	return;
//	int j,i;
//	for(i=0;i<nNeuron;i++)	// �������� �������
//	{
//		for(j=0;j<prev->nNeuron;j++) cW[i][j]=0;
//		cThresh[i]=0;
//	}
//	// ������ ��������� ����
//	srand((unsigned)time(NULL)); // ������������� �������
//	double p=0.00001;
//	for(i=0; i<nNeuron;i++)
//	{ 
//		for(j=0; j<prev->nNeuron;j++)	W[i][j]=p+double(rand())/RAND_MAX;
//		Thresh[i]=p+double(rand())/RAND_MAX;
//	}
//}
////------------------------------------------------
//CLayer::~CLayer()
//{
//}
////------------------------------------------------
//void CLayer::CalculateLayer() // ������ ������ ����
//{
//	if (Type==TEACHER)	return;
//	prev->CalculateLayer();	// ��������� ����� ����������� ���� // ���� �������� 
//	int i,j;
//	double sum;
//	for(i=0;i<nNeuron;i++)
//	{ 
//		sum=0;
//		for(j=0;j<prev->nNeuron;j++) sum+=W[i][j]*prev->Out[j];
//		Out[i]=Sigmoid(sum+Thresh[i]);
//	}
//}
////------------------------------------------------
//void CLayer::CalculateError() // ������ ������
//{
//	if (Type==TEACHER)	return;
//	int i, j; 
//	double sum;
//	if (next->Type==TEACHER)	// ���� ��� �������� ����, �� ����� ������� ����� next->Out	
//		for(i=0;i<nNeuron;i++) 
//			Err[i]=Out[i]*(1-Out[i])*(next->Out[i]-Out[i]);
//	else	//	����� ����������� ��� ������� ����
//		for(i=0;i<nNeuron;i++)
//		{ 
//			sum=0;
//			for(j=0;j<next->nNeuron;j++) sum+=next->Err[j]*next->W[j][i];
//			Err[i]=Out[i]*(1-Out[i])*sum;
//		}
//	prev->CalculateError();	// ��������� ������ ��� ����������� ���� // ���� �������� 
//}
////------------------------------------------------
//void CLayer::ChangeWeight() // ������������� �����
//{
//	if (Type==TEACHER)	return;
//	int j, i, ea;
//	double max=0;
//
//	// ������� ������������ ������
//	for(i=0;i<nNeuron;i++) if (MathAbs(Err[i])>MathAbs(max))	{	max=Err[i]; ea=i; }
//	// ������ ���� ��� ������
//	for(i=0;i<nNeuron;i++)
//	{
//		for(j=0;j<prev->nNeuron;j++) 
//		{
//			// ��� ������ "�������" �������� ��������
//			if (i==ea) cW[i][j]=2*Speed*Err[i]*prev->Out[j]+Impuls*cW[i][j];
//			else cW[i][j]=Speed*Err[i]*prev->Out[j]+Impuls*cW[i][j];
//			//���� ������������� ����� ���������
//			if (MathAbs(cW[i][j])<1e-6) cW[i][j]=1e-5*Sign(cW[i][j]);
//			W[i][j]+=cW[i][j];
//		}
//			// ��� ������ "�������" �������� ��������
//		if (i==ea) cThresh[i]=2*Speed*Err[i]+Impuls*cThresh[i];
//		else cThresh[i]=Speed*Err[i]+Impuls*cThresh[i];
//		//���� ������������� ����� ���������
//		if (MathAbs(cThresh[i])<1e-6) cThresh[i]=1e-5*Sign(cThresh[i]);
//		Thresh[i]+=cThresh[i];
//	}
//	prev->ChangeWeight();	// ������ ���� ����������� ���� // ���� �������� 
//}
////------------------------------------------------
