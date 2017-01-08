//+------------------------------------------------------------------+
//|                                                 LibFunctions.mq5 |
//|                                                    ������ ������ |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property library
#property copyright "������ ������"
#property link      "sergey1294@list.ru"
#property version   "1.00"
//+---------------------------------------------------------------------------------------------------+
//| ������� ��� �������� ���������� ������� Label                                                     |
//|    ���������:                                                                                     |                                                          
//|    nm - ������������ �������                                                                      |                                               
//|    tx - �����                                                                                     |
//|    cn - ���� ������� ��� �������� ������������ �������                                            |
//|         CORNER_LEFT_UPPER - ����� ��������� � ����� ������� ���� �������                          |
//|         CORNER_LEFT_LOWER - ����� ��������� � ����� ������ ���� �������                           |
//|         CORNER_RIGHT_LOWER - ����� ��������� � ������ ������ ���� �������                         |
//|         CORNER_RIGHT_UPPER - ����� ��������� � ������ ������� ���� �������                        |
//|    cr - ��������� ����� �������� ������������ �������                                             |
//|         ANCHOR_LEFT_UPPER - ����� �������� � ����� ������� ����                                   |
//|         ANCHOR_LEFT - ����� �������� ����� �� ������                                              |
//|         ANCHOR_LEFT_LOWER - ����� �������� � ����� ������ ����                                    |
//|         ANCHOR_LOWER - ����� �������� ����� �� ������                                             |
//|         ANCHOR_RIGHT_LOWER - ����� �������� � ������ ������ ����                                  |
//|         ANCHOR_RIGHT - ����� �������� ������ �� ������                                            |
//|         ANCHOR_RIGHT_UPPER - ����� �������� � ������ ������� ����                                 |
//|         ANCHOR_UPPER - ����� �������� ������ �� ������                                            |
//|         ANCHOR_CENTER - ����� �������� ������ �� ������ �������                                   |
//|    xd - ���������� X � ��������                                                                   |                                           
//|    yd - ���������� Y � ��������                                                                   |
//|    fn - ������������ ������                                                                       |                    
//|    fs - ������ ������ � ��������                                                                  | 
//|    yg - ���� ������� ������ � ��������. �� ������ ����� �� �������, �� ������ ���� ������ ������� |                                                                    
//|    ct - ���� ������                                                                               |
//+---------------------------------------------------------------------------------------------------+
void SetLabel(string nm,string tx,ENUM_BASE_CORNER cn,ENUM_ANCHOR_POINT cr,int xd,int yd,string fn,int fs,double yg,color ct)export
  { 
   if(fs<1)fs=1;
   if(ObjectFind(0,nm)<0)ObjectCreate(0,nm,OBJ_LABEL,0,0,0);  //--- �������� ������ Label
   ObjectSetString (0,nm,OBJPROP_TEXT,tx);                    //--- ��������� ����� ��� ������� Label 
   ObjectSetInteger(0,nm,OBJPROP_CORNER,cn);                  //--- ��������� �������� � ���� �������              
   ObjectSetInteger(0,nm,OBJPROP_ANCHOR,cr);                  //--- ��������� ��������� ����� �������� ������������ �������
   ObjectSetInteger(0,nm,OBJPROP_XDISTANCE,xd);               //--- ��������� ���������� X
   ObjectSetInteger(0,nm,OBJPROP_YDISTANCE,yd);               //--- ��������� ���������� Y
   ObjectSetString (0,nm,OBJPROP_FONT,fn);                    //--- ��������� ����� �������
   ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,fs);                //--- ��������� ������ ������    
   ObjectSetDouble (0,nm,OBJPROP_ANGLE,yg);                   //--- ��������� ���� �������
   ObjectSetInteger(0,nm,OBJPROP_COLOR,ct);                   //--- ������� ���� ������
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);           //--- �������� ��������� ������� ������   
  }
//+------------------------------------------------------------------+
//| ������� ��� ����������� ���� ������� �� ���� ������  Wingdings   |
//+------------------------------------------------------------------+
string arrow(int sig)export
  {
   switch(sig)
     {
      case  0: return(CharToString(251));
      case  1: return(CharToString(233));
      case -1: return(CharToString(234));
     }
   return((string)0);
  }
//+------------------------------------------------------------------+
//| ������� ��� ����������� ����� �������                            |
//+------------------------------------------------------------------+
color Colorarrow(int sig)export
  {
   switch(sig)
     {
      case -1: return(Red);
      case  0:  return(MediumAquamarine);
      case  1:  return(GreenYellow);
     }
   return(0);
  }
//+------------------------------------------------------------------+
