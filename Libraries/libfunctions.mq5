//+------------------------------------------------------------------+
//|                                                 LibFunctions.mq5 |
//|                                                    Сергей Грицай |
//|                                               sergey1294@list.ru |
//+------------------------------------------------------------------+
#property library
#property copyright "Сергей Грицай"
#property link      "sergey1294@list.ru"
#property version   "1.00"
//+---------------------------------------------------------------------------------------------------+
//| Функция для создания текстового объекта Label                                                     |
//|    Параметры:                                                                                     |                                                          
//|    nm - наименование объекта                                                                      |                                               
//|    tx - текст                                                                                     |
//|    cn - угол графика для привязки графического объекта                                            |
//|         CORNER_LEFT_UPPER - Центр координат в левом верхнем углу графика                          |
//|         CORNER_LEFT_LOWER - Центр координат в левом нижнем углу графика                           |
//|         CORNER_RIGHT_LOWER - Центр координат в правом нижнем углу графика                         |
//|         CORNER_RIGHT_UPPER - Центр координат в правом верхнем углу графика                        |
//|    cr - положение точки привязки графического объекта                                             |
//|         ANCHOR_LEFT_UPPER - Точка привязки в левом верхнем углу                                   |
//|         ANCHOR_LEFT - Точка привязки слева по центру                                              |
//|         ANCHOR_LEFT_LOWER - Точка привязки в левом нижнем углу                                    |
//|         ANCHOR_LOWER - Точка привязки снизу по центру                                             |
//|         ANCHOR_RIGHT_LOWER - Точка привязки в правом нижнем углу                                  |
//|         ANCHOR_RIGHT - Точка привязки справа по центру                                            |
//|         ANCHOR_RIGHT_UPPER - Точка привязки в правом верхнем углу                                 |
//|         ANCHOR_UPPER - Точка привязки сверху по центру                                            |
//|         ANCHOR_CENTER - Точка привязки строго по центру объекта                                   |
//|    xd - координата X в пикселах                                                                   |                                           
//|    yd - координата Y в пикселах                                                                   |
//|    fn - наименование шрифта                                                                       |                    
//|    fs - размер шрифта в пикселах                                                                  | 
//|    yg - угол наклона текста в градусах. со знаком минус по часовой, со знаком плюс против часовой |                                                                    
//|    ct - цвет текста                                                                               |
//+---------------------------------------------------------------------------------------------------+
void SetLabel(string nm,string tx,ENUM_BASE_CORNER cn,ENUM_ANCHOR_POINT cr,int xd,int yd,string fn,int fs,double yg,color ct)export
  { 
   if(fs<1)fs=1;
   if(ObjectFind(0,nm)<0)ObjectCreate(0,nm,OBJ_LABEL,0,0,0);  //--- создадим объект Label
   ObjectSetString (0,nm,OBJPROP_TEXT,tx);                    //--- установим текст для объекта Label 
   ObjectSetInteger(0,nm,OBJPROP_CORNER,cn);                  //--- установим привязку к углу графика              
   ObjectSetInteger(0,nm,OBJPROP_ANCHOR,cr);                  //--- установим положение точки привязки графического объекта
   ObjectSetInteger(0,nm,OBJPROP_XDISTANCE,xd);               //--- установим координату X
   ObjectSetInteger(0,nm,OBJPROP_YDISTANCE,yd);               //--- установим координату Y
   ObjectSetString (0,nm,OBJPROP_FONT,fn);                    //--- установим шрифт надписи
   ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,fs);                //--- установим размер шрифта    
   ObjectSetDouble (0,nm,OBJPROP_ANGLE,yg);                   //--- установим угол наклона
   ObjectSetInteger(0,nm,OBJPROP_COLOR,ct);                   //--- зададим цвет текста
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);           //--- запретим выделение объекта мышкой   
  }
//+------------------------------------------------------------------+
//| функция для определения типа стрелки по коду шрифта  Wingdings   |
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
//| функция для определения цвета стрелки                            |
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
