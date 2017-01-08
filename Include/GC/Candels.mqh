//+------------------------------------------------------------------+
//|                                                      Candels.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Candel_Type
  {
   CT_None=0,// 
   CT_HangingMan=11,         // 
   CT_BlackHummer=12,        // 
   CT_WhiteHummer=13,// 
   CT_BlackEscimo=14,// 
   CT_WhiteEscimo=15,// 
                     /////////////////
   CT_ShootingStar=21,
   CT_RBlackHummer=22,// 
   CT_RWhiteHummer=23,// 
   CT_RBlackEscimo=24,// 
   CT_RWhiteEscimo=25,// 
   CT_Doji=99               // 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Candel_Type IsCandel(string smbl="",ENUM_TIMEFRAMES tf=0,int shift=0)
  {// ����, ������, �������� ����� (��� ���������� �������)
   int shft_his=7;
   int needcopy=15;
   int shft_cur=0;

   if(""==smbl) smbl=_Symbol;
   if(0==tf) tf=_Period;
   double BufferO[],BufferC[],BufferL[],BufferH[];
   ArraySetAsSeries(BufferO,true); ArraySetAsSeries(BufferC,true);
   ArraySetAsSeries(BufferL,true); ArraySetAsSeries(BufferH,true);
// �������� �������
   if(CopyOpen(smbl,tf,shift,needcopy,BufferO)!=needcopy)   return(CT_None);
   if(CopyClose(smbl,tf,shift,needcopy,BufferC)!=needcopy)  return(CT_None);
   if(CopyLow(smbl,tf,shift,needcopy,BufferL)!=needcopy)    return(CT_None);
   if(CopyHigh(smbl,tf,shift,needcopy,BufferH)!=needcopy)   return(CT_None);
   
   if(MathRound(BufferC[shft_cur]/SymbolInfoDouble(smbl,SYMBOL_POINT))==MathRound(BufferO[shft_cur]/SymbolInfoDouble(smbl,SYMBOL_POINT)))
     { //�������� ����� ��������
      if((BufferH[shft_cur]-(BufferH[shft_cur]-BufferL[shft_cur])/10)<=BufferC[shft_cur])
        {//���� �������� ����� ������� (10% �����)
         if((BufferH[shft_cur]<BufferL[shft_his]))
           {// ��� �����
            return(CT_HangingMan);
           }
        }
      if((BufferL[shft_cur]+(BufferH[shft_cur]-BufferL[shft_cur])/10)>=BufferC[shft_cur])
        {//���� �������� ����� ����� (10% �����)
         if((BufferL[shft_cur]>BufferH[shft_his]))
           {// ��� ������
            return(CT_ShootingStar);
           }
        }
      return(CT_Doji);
     }
   if(BufferC[shft_cur]>BufferO[shft_cur])
     {//�������� ���� �������� = �����
      if((BufferH[shft_cur]-(BufferH[shft_cur]-BufferL[shft_cur])/10)<=BufferC[shft_cur])
        {//���� �������� ����� ������� (10% �����)
         if((BufferL[shft_cur]+(BufferH[shft_cur]-BufferL[shft_cur])/2)<BufferO[shft_cur])
           { // �������� ���������� - ������ ��� �������� ����� 
            if((BufferL[shft_cur]>BufferH[shft_his]))
              {// ��� �����
               if((BufferH[shft_cur]-(BufferH[shft_cur]-BufferL[shft_cur])/4)>BufferO[shft_cur])//������ ������ ��� �������� �����
                  return(CT_WhiteEscimo);
               else  return(CT_WhiteHummer);
              }
           }
        }
      if((BufferL[shft_cur]+(BufferH[shft_cur]-BufferL[shft_cur])/10)>=BufferO[shft_cur])
        {//���� �������� ����� ������� (10% �����)
         if((BufferH[shft_cur]-(BufferH[shft_cur]-BufferL[shft_cur])/2)>BufferC[shft_cur])
           { // �������� ���������� - ������ ��� �������� ����� 
            if((BufferL[shft_cur]>BufferH[shft_his]))
              {// ��� ������
               if((BufferL[shft_cur]+(BufferH[shft_cur]-BufferL[shft_cur])/4)<BufferC[shft_cur])//������ ������ ��� �������� �����
                  return(CT_RWhiteEscimo);
               else  return(CT_RWhiteHummer);
              }
           }
        }
     }
   if(BufferO[shft_cur]>BufferC[shft_cur])
     {//�������� ���� �������� - ������
      if((BufferH[shft_cur]-(BufferH[shft_cur]-BufferL[shft_cur])/10)<=BufferO[shft_cur])
        {//���� �������� ����� ������� (10% �����)
         if((BufferL[shft_cur]+(BufferH[shft_cur]-BufferL[shft_cur])/2)<BufferC[shft_cur])
           { // �������� ���������� - ������ ��� �������� ����� 
            if((BufferL[shft_cur]>BufferH[shft_his]))
              {// ��� �����
               if((BufferH[shft_cur]-(BufferH[shft_cur]-BufferL[shft_cur])/4)>BufferC[shft_cur])//������ ������ ��� �������� �����
                  return(CT_BlackEscimo);
               else  return(CT_BlackHummer);
              }
           }
        }
      if((BufferL[shft_cur]+(BufferH[shft_cur]-BufferL[shft_cur])/10)>=BufferC[shft_cur])
        {//���� �������� ����� ����� (10% �����)
         if((BufferH[shft_cur]-(BufferH[shft_cur]-BufferL[shft_cur])/2)>BufferO[shft_cur])
           { // �������� ���������� - ������ ��� �������� ����� 
            if((BufferL[shft_cur]>BufferH[shft_his]))
              {// ��� ������
               if((BufferL[shft_cur]+(BufferH[shft_cur]-BufferL[shft_cur])/4)<BufferO[shft_cur])//������ ������ ��� �������� �����
                  return(CT_RWhiteEscimo);
               else  return(CT_RWhiteHummer);
              }
           }
        }
     }
   return(CT_None);// ��� ������
  }
//+------------------------------------------------------------------+
