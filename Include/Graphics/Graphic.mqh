//+------------------------------------------------------------------+
//|                                                     CGraphic.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Canvas\Canvas.mqh>
#include <Arrays\ArrayObj.mqh>
#include "Curve.mqh"
#include "Axis.mqh"
#include "ColorGenerator.mqh"
//--- tick position
enum ENUM_MARK_POSITION
  {
   MARK_EXTERNAL,
   MARK_INTERNAL,
   MARK_MIDDLE
  };
//+------------------------------------------------------------------+
//| Structure CBackground                                            |
//| Usage: background on a two-dimensional graphics                  |
//+------------------------------------------------------------------+
struct CBackground
  {
   color             clr;
   color             clr_main;
   color             clr_sub;
   string            main;
   string            sub;
   int               size_main;
   int               size_sub;
  };
//+------------------------------------------------------------------+
//| Structure CCurveHistory                                          |
//| Usage: history of curves on a two-dimensional graphics           |
//+------------------------------------------------------------------+
struct CCurveHistory
  {
   int               name_width;
   int               name_size;
   int               symbol_size;
   int               count_total;
   int               count_points;
   int               count_lines;
   int               count_histogram;
  };
//+------------------------------------------------------------------+
//| Structure CGrid                                                  |
//| Usage: grid on a two-dimensional graphics                        |
//+------------------------------------------------------------------+
struct CGrid
  {
   color             clr_line;
   color             clr_background;
   color             clr_circle;
   color             clr_axis_line;
   color             clr_frame;
   int               r_circle;
   bool              has_circle;
  };
//+------------------------------------------------------------------+
//| Class CGraphic                                                   |
//| Usage: class for drawing two-dimensional graphics                |
//+------------------------------------------------------------------+
class CGraphic
  {
private:
   CArrayObj         m_arr_curves;
   CCanvas           m_canvas;
   //--- parameters background 
   int               m_height;
   int               m_width;
   //--- parameters work space
   int               m_left;
   int               m_rigth;
   int               m_up;
   int               m_down;
   //--- size of dash on the axes
   int               m_mark_size;
   //--- scaling parameters
   double            m_dx;
   double            m_dy;
   //--- element of graphic
   CAxis             m_x;                    // x axis
   CAxis             m_y;                    // y axis   
   CGrid             m_grid;                 // grid   
   CBackground       m_background;           // backgroud
   CCurveHistory     m_history;              // history
   //--- generates color curves
   CColorGenerator   m_generator;
   //--- distance between the elements
   int               m_gap;
   //--- coordinates and values for axes
   int               m_xc[];
   int               m_yc[];
   string            m_xvalues[];
   string            m_yvalues[];
   int               m_xsize;
   int               m_ysize;
   bool              m_xupdate;
   bool              m_yupdate;

public:
                     CGraphic(void);
                    ~CGraphic(void);
   //--- gets or sets gap 
   int               GapSize(void)            { return(m_gap); }
   void              GapSize(const int size)  { m_gap=size;    }
   //--- gets or sets major mark size
   int               MajorMarkSize(void)           { return(m_mark_size); }
   void              MajorMarkSize(const int size) { m_mark_size=size;    }
   //--- axis properties
   CAxis            *XAxis(void) { return GetPointer(m_x); }
   CAxis            *YAxis(void) { return GetPointer(m_y); }
   //--- gets the curve history properties
   int               HistoryNameWidth(void)              { return(m_history.name_width);  }
   int               HistoryNameSize(void)               { return(m_history.name_size);   }
   int               HistorySymbolSize(void)             { return(m_history.symbol_size); }
   //--- sets the curve history properties
   void              HistoryNameWidth(const int width)   { m_history.name_width=width;    }
   void              HistoryNameSize(const int size)     { m_history.name_size=size;      }
   void              HistorySymbolSize(const int size)   { m_history.symbol_size=size;    }
   //--- gets the grid properties
   color             GridLineColor(void)        { return(m_grid.clr_line);       }
   color             GridAxisLineColor(void)    { return(m_grid.clr_axis_line);  }
   color             GridBackgroundColor(void)  { return(m_grid.clr_background); }
   int               GridCircleRadius(void)     { return(m_grid.r_circle);       }
   color             GridCircleColor(void)      { return(m_grid.clr_circle);     }
   bool              GridHasCircle(void)        { return(m_grid.has_circle);     }
   //--- sets the grid properties
   void              GridLineColor(const color clr)         { m_grid.clr_line=clr;       }
   void              GridAxisLineColor(const color clr)     { m_grid.clr_axis_line=clr;  }
   void              GridBackgroundColor(const color clr)   { m_grid.clr_background=clr; }
   void              GridCircleRadius(const int r)          { m_grid.r_circle=r;         }
   void              GridCircleColor(const color clr)       { m_grid.clr_circle=clr;     }
   void              GridHasCircle(const bool has)          { m_grid.has_circle=has;     }
   //--- gets the background properties
   color             BackgroundColor(void)       { return(m_background.clr);       }
   color             BackgroundMainColor(void)   { return(m_background.clr_main);  }
   color             BackgroundSubColor(void)    { return(m_background.clr_sub);   }
   string            BackgroundMain(void)        { return(m_background.main);      }
   string            BackgroundSub(void)         { return(m_background.sub);       }
   int               BackgroundMainSize(void)    { return(m_background.size_main); }
   int               BackgroundSubSize(void)     { return(m_background.size_sub);  }
   //--- sets the background properties
   void              BackgroundColor(const color clr)       { m_background.clr=clr;        }
   void              BackgroundMainColor(const color clr)   { m_background.clr_main=clr;   }
   void              BackgroundSubColor(const color clr)    { m_background.clr_sub=clr;    }
   void              BackgroundMain(const string main)      { m_background.main=main;      }
   void              BackgroundSub(const string sub)        { m_background.sub=sub;        }
   void              BackgroundMainSize(const int size)     { m_background.size_main=size; }
   void              BackgroundSubSize(const int size)      { m_background.size_sub=size;  }
   //--- create/attach/destroy
   bool              Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   bool              Attach(const int chart_id,const string objname);
   bool              Attach(const long chart_id,const string objname,const int width,const int height);
   void              Destroy(void);
   //--- main properties
   string            ChartObjectName(void)   { return(m_canvas.ChartObjectName()); }
   string            ResourceName(void)      { return(m_canvas.ResourceName());    }
   //--- redraw all object on screen
   bool              Redraw(const bool rescale=false);
   //--- update object on screen
   void              Update(const bool redraw=true);
   //--- methods for add new curve 
   CCurve           *CurveAdd(const double &y[],ENUM_CURVE_TYPE type,const string name=NULL);
   CCurve           *CurveAdd(const double &x[],const double &y[],ENUM_CURVE_TYPE type,const string name=NULL);
   CCurve           *CurveAdd(const CPoint2D &points[],ENUM_CURVE_TYPE type,const string name=NULL);
   CCurve           *CurveAdd(CurveFunction function,const double from,const double to,const double step,ENUM_CURVE_TYPE type,const string name=NULL);
   CCurve           *CurveAdd(const double &x[],const double &y[],const uint clr,ENUM_CURVE_TYPE type,const string name=NULL);
   CCurve           *CurveAdd(const double &y[],const uint clr,ENUM_CURVE_TYPE type,const string name=NULL);
   CCurve           *CurveAdd(const CPoint2D &points[],const uint clr,ENUM_CURVE_TYPE type,const string name=NULL);
   CCurve           *CurveAdd(CurveFunction function,const double from,const double to,const double step,const uint clr,ENUM_CURVE_TYPE type,const string name=NULL);
   //--- methods for draw curve
   bool              CurvePlotAll(void);
   bool              CurvePlot(const int index);
   //--- methods for work with curves
   int               CurvesTotal(void);
   CCurve           *CurveGetByIndex(const int index);
   CCurve           *CurveGetByName(const string name);
   bool              CurveRemoveByIndex(const int index);
   bool              CurveRemoveByName(const string name);
   //--- methods for add new elements
   bool              MarksToAxisAdd(const double &marks[],const int mark_size,ENUM_MARK_POSITION position,const int dimension=0);
   void              TextAdd(const int x,const int y,const string text,const uint clr,const uint alignment=0);
   void              TextAdd(const CPoint &point,const string text,const uint clr,const uint alignment=0);
   void              LineAdd(const int x1,const int y1,const int x2,const int y2,const uint clr,const uint style);
   void              LineAdd(const CPoint &point1,const CPoint &point2,const uint clr,const uint style);
   //--- methods for settings text parameters
   bool              FontSet(const string name,const int size,const uint flags=0,const uint angle=0) { return(m_canvas.FontSet(name,size,flags,angle)); }
   void              FontGet(string &name,int &size,uint &flags,uint &angle)                         { m_canvas.FontGet(name,size,flags,angle);         }

protected:
   //--- methods for plot curve
   void              PointsPlot(CCurve *curve);
   void              LinesPlot(CCurve *curve);
   void              PointsAndLinesPlot(CCurve *curve);
   void              StepsPlot(CCurve *curve);
   void              HistogramPlot(CCurve *curve);
   //--- methods for create graphic elements 
   void              CreateWorkspace(void);
   void              CreateGrid(void);
   void              CreateBackground(void);
   void              CreateXName(void);
   void              CreateYName(void);
   void              CreateAxes(void);
   void              CreateHistory(void);
   //--- methods for settings internal parameters
   void              SetDefaultParameters(void);
   void              ResetParameters(void);
   //--- methods for calculation internal parameters
   void              CalculateBoundaries(void);
   void              CalculateMaxMinValues(void);
   void              CalculateXAxis(void);
   void              CalculateYAxis(void);
   //--- methods for smoothing curve
   void              Spline(double &x[],double &y[],int &size,double tension,double step);
   void              CalcCurveBezierEndp(const double xend,const double yend,const double xadj,const double yadj,const double tension,double &x,double &y);
   void              CalcCurveBezier(const double &x[],const double &y[],const int i,const double tension,double &x1,double &y1,double &x2,double &y2);
   double            CalcBezierX(const double t,const double x0,const double x1,const double x2,const double x3);
   double            CalcBezierY(const double t,const double y0,const double y1,const double y2,const double y3);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CGraphic::CGraphic(void) : m_height(0.0),m_width(0.0)
  {
   SetDefaultParameters();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CGraphic::~CGraphic(void)
  {
  }
//+------------------------------------------------------------------+
//| Crete workspace on graphic                                       |
//+------------------------------------------------------------------+
void CGraphic::CreateWorkspace(void)
  {
//--- coordinates
   int x1 = m_left;
   int y1 = m_up;
   int x2 = m_width-m_rigth;
   int y2 = m_height-m_down;
//--- draw background of workspace
   m_canvas.FillRectangle(x1+1,y1+1,x2-1,y2-1,ColorToARGB(m_grid.clr_background,255));
  }
//+------------------------------------------------------------------+
//| Create grid on graphic                                           |
//+------------------------------------------------------------------+
void CGraphic::CreateGrid(void)
  {
   int xc0=-1.0;
   int yc0=-1.0;
   for(int i=1; i<m_ysize-1; i++)
     {
      if(StringToDouble(m_yvalues[i])==0.0)
         yc0=m_yc[i];
      else
         m_canvas.LineHorizontal(m_left+1,m_width-m_rigth,m_yc[i],m_grid.clr_line);
      for(int j=1; j<m_xsize-1; j++)
        {
         if(i==1)
           {
            if(StringToDouble(m_xvalues[j])==0.0)
               xc0=m_xc[j];
            else
               m_canvas.LineVertical(m_xc[j],m_height-m_down-1,m_up+1,m_grid.clr_line);
           }
         //-- draw circle
         if(m_grid.has_circle)
           {
            m_canvas.FillCircle(m_xc[j],m_yc[i],m_grid.r_circle,m_grid.clr_circle);
            m_canvas.CircleWu(m_xc[j],m_yc[i],m_grid.r_circle,m_grid.clr_circle);
           }
        }
     }
//---
   if(yc0>0)
      m_canvas.LineHorizontal(m_left+1,m_width-m_rigth,yc0,m_grid.clr_axis_line);
   if(xc0>0)
      m_canvas.LineVertical(xc0,m_height-m_down-1,m_up+1,m_grid.clr_axis_line);
//---
  }
//+------------------------------------------------------------------+
//| Create background, main and sub title                            |
//+------------------------------------------------------------------+
void CGraphic::CreateBackground(void)
  {
//--- coordinates
   int x1 = 0;
   int y1 = 0;
   int x2 = m_width;
   int y2 = m_height;
//--- create background
   m_canvas.FillRectangle(0,0,m_width,m_up-1,ColorToARGB(m_background.clr,255));
   m_canvas.FillRectangle(0,m_height-m_down+1,m_width,m_height,ColorToARGB(m_background.clr,255));
   m_canvas.FillRectangle(0,m_up,m_left-1,m_height-m_down,ColorToARGB(m_background.clr,255));
   m_canvas.FillRectangle(m_width-m_rigth+1,m_up,m_width,m_height-m_down,ColorToARGB(m_background.clr,255));
//--- set main title
   if(m_background.main!=NULL && m_background.size_main!=0)
     {
      m_canvas.FontSet("Arial",m_background.size_main,FW_HEAVY);
      int x=int((x2+x1-m_canvas.TextWidth(m_background.main))/2.0);
      m_canvas.TextOut(x,m_gap,m_background.main,ColorToARGB(m_background.clr_main,255));
      m_canvas.FontFlagsSet(0);
     }
//--- set sub title
   if(m_background.sub!=NULL && m_background.size_sub!=0)
     {
      m_canvas.FontSet("Arial",m_background.size_sub,FW_MEDIUM);
      int x=int((x2+x1-m_canvas.TextWidth(m_background.sub))/2.0);
      int y=m_height-m_gap-m_background.size_sub;
      m_canvas.TextOut(x,y,m_background.sub,ColorToARGB(m_background.clr_sub,255));
      m_canvas.FontFlagsSet(0);
     }
  }
//+------------------------------------------------------------------+
//| Create x axis name on graphic                                    |
//+------------------------------------------------------------------+
void CGraphic::CreateXName(void)
  {
   if(m_x.NameSize()!=0 && m_x.Name()!=NULL)
     {
      m_canvas.FontSizeSet(m_x.NameSize());
      m_canvas.TextOut((int)((m_width-m_canvas.TextWidth(m_x.Name()))/2.0),m_height-m_x.NameSize()-m_background.size_sub-2*m_gap,m_x.Name(),ColorToARGB(m_x.Color(),255));
     }
  }
//+------------------------------------------------------------------+
//| Create y axis name on graphic                                    |
//+------------------------------------------------------------------+
void CGraphic::CreateYName(void)
  {
   if(m_y.NameSize()!=0 && m_y.Name()!=NULL)
     {
      m_canvas.FontSizeSet(m_y.NameSize());
      m_canvas.FontAngleSet(900);
      m_canvas.TextOut(m_gap,(int)((m_height+m_canvas.TextWidth(m_x.Name()))/2.0),m_y.Name(),ColorToARGB(clrBlack,255));
      m_canvas.FontAngleSet(0);
     }
  }
//+------------------------------------------------------------------+
//| Create axes on graphic                                           |
//+------------------------------------------------------------------+
void CGraphic::CreateAxes(void)
  {
//---  
   int x1=m_left;
   int x2=m_left-m_mark_size;
   int y1=m_height-m_down;
   int y2=m_height-m_down+m_mark_size;
//--- create frame
   m_canvas.Rectangle(m_left,m_up,m_width-m_rigth,m_height-m_down,m_grid.clr_frame);
//--- set font y
   m_canvas.FontSizeSet(m_y.ValuesSize());
//--- create x axis
   for(int i=0; i<m_ysize; i++)
     {
      string yvalue=m_yvalues[i];
      int yh=m_canvas.TextHeight(yvalue);
      if(m_canvas.TextWidth(yvalue)>m_y.ValuesWidth())
        {
         while(m_canvas.TextWidth(yvalue+"...")>m_y.ValuesWidth())
           {
            yvalue=StringSubstr(yvalue,0,StringLen(yvalue)-1);
           }
         yvalue+="...";
        }
      //--- draw mark and set y value
      int yi_width=m_canvas.TextWidth(yvalue);
      m_canvas.TextOut(m_left-yi_width-m_mark_size-m_gap,m_yc[i]-yh/2,yvalue,ColorToARGB(clrBlack,255),TA_LEFT);
      if(m_mark_size>0.0)
         m_canvas.LineHorizontal(x1,x2,m_yc[i],ColorToARGB(clrBlack,255));
     }
//--- create y axis
   m_canvas.FontSizeSet(m_x.ValuesSize());
   for(int i=0; i<m_xsize; i++)
     {
      string xvalue=m_xvalues[i];
      int xw=m_canvas.TextWidth(xvalue);
      //--- draw mark and set y value
      m_canvas.TextOut(m_xc[i]-xw/2,y2+m_gap,xvalue,ColorToARGB(clrBlack,255));
      if(m_mark_size>0.0)
         m_canvas.LineVertical(m_xc[i],y1,y2,ColorToARGB(clrBlack,255));
     }
//---        
  }
//+------------------------------------------------------------------+
//| Create graphic                                                   |
//+------------------------------------------------------------------+
bool CGraphic::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
//--- preliminary calculation
   int width=x2-x1;
   int height=y2-y1;
   if(width>0 && height>0)
     {
      m_width=width;
      m_height=height;
      //--- create object
      if(!ObjectCreate(chart,name,OBJ_BITMAP_LABEL,subwin,0,0))
         return(false);
      //--- customize object
      if(!ObjectSetInteger(chart,name,OBJPROP_XDISTANCE,x1) || 
         !ObjectSetInteger(chart,name,OBJPROP_YDISTANCE,y1))
        {
         ObjectDelete(chart,name);
         return(false);
        }
      //--- attach object
      if(!m_canvas.Attach(chart,name,width,height))
        {
         ResourceFree("::"+name);
         ObjectDelete(chart,name);
         return(false);
        }
     }
//--- success
   return(true);
  }
//+------------------------------------------------------------------+
//| Attach new object with bitmap resource                           |
//+------------------------------------------------------------------+
bool CGraphic::Attach(const int chart_id,const string objname)
  {
   if(m_canvas.Attach(chart_id,objname))
     {
      m_width=m_canvas.Width();
      m_height=m_canvas.Height();
      //--- success
      return(true);
     }
//--- failed
   return(false);
  }
//+------------------------------------------------------------------+
//| Attach new object without bitmap resource                        |
//+------------------------------------------------------------------+
bool CGraphic::Attach(const long chart_id,const string objname,const int width,const int height)
  {
   if(m_canvas.Attach(chart_id,objname,width,height))
     {
      m_width=m_canvas.Width();
      m_height=m_canvas.Height();
      //--- success
      return(true);
     }
//--- failed
   return(false);
  }
//+------------------------------------------------------------------+
//| Remove graphic from chart                                        |
//+------------------------------------------------------------------+
void CGraphic::Destroy(void)
  {
   SetDefaultParameters();
   m_generator.Reset();
   m_canvas.Destroy();
  }
//+------------------------------------------------------------------+
//| Add new curve on graphic                                         |
//+------------------------------------------------------------------+
CCurve *CGraphic::CurveAdd(const double &y[],ENUM_CURVE_TYPE type,const string name=NULL)
  {
   return CurveAdd(y,m_generator.Next(),type,name);
  }
//+------------------------------------------------------------------+
//| Add new curve on graphic                                         |
//+------------------------------------------------------------------+
CCurve *CGraphic::CurveAdd(const double &x[],const double &y[],ENUM_CURVE_TYPE type,const string name=NULL)
  {
   return CurveAdd(x,y,m_generator.Next(),type,name);
  }
//+------------------------------------------------------------------+
//| Add new curve on graphic                                         |
//+------------------------------------------------------------------+
CCurve *CGraphic::CurveAdd(const CPoint2D &points[],ENUM_CURVE_TYPE type,const string name=NULL)
  {
   return CurveAdd(points,m_generator.Next(),type,name);
  }
//+------------------------------------------------------------------+
//| Add new curve on graphic                                         |
//+------------------------------------------------------------------+
CCurve *CGraphic::CurveAdd(CurveFunction function,const double from,const double to,const double step,ENUM_CURVE_TYPE type,const string name=NULL)
  {
   return CurveAdd(function,from,to,step,m_generator.Next(),type,name);
  }
//+------------------------------------------------------------------+
//| Add new curve on graphic                                         |
//+------------------------------------------------------------------+
CCurve *CGraphic::CurveAdd(const double &y[],const uint clr,ENUM_CURVE_TYPE type,const string name=NULL)
  {
//--- create new curve
   CCurve *curve=new CCurve(y,clr,type,name);
//--- set max and min values
   if(m_arr_curves.Total()==0)
     {
      if(m_x.AutoScale())
        {
         m_x.Max(curve.XMax());
         m_x.Min(curve.XMin());
        }
      if(m_y.AutoScale())
        {
         m_y.Max(curve.YMax());
         m_y.Min(curve.YMin());
        }
      m_xupdate = true;
      m_yupdate = true;
     }
   else
     {
      //--- find max of x
      if(m_x.Max()<curve.XMax() && m_x.AutoScale())
        {
         m_x.Max(curve.XMax());
         m_xupdate=true;
        }
      //--- find min of x
      if(m_x.Min()>curve.XMin() && m_x.AutoScale())
        {
         m_x.Min(curve.XMin());
         m_xupdate=true;
        }
      //--- find max of y
      if(m_y.Max()<curve.YMax() && m_y.AutoScale())
        {
         m_y.Max(curve.YMax());
         m_yupdate=true;
        }
      //--- find min of y
      if(m_y.Min()>curve.YMin() && m_y.AutoScale())
        {
         m_y.Min(curve.YMin());
         m_yupdate=true;
        }
     }
//--- add curve
   m_arr_curves.Add(curve);
   return(curve);
  }
//+------------------------------------------------------------------+
//| Add new curve on graphic                                         |
//+------------------------------------------------------------------+
CCurve *CGraphic::CurveAdd(const double &x[],const double &y[],const uint clr,ENUM_CURVE_TYPE type,const string name=NULL)
  {
   int xSize = ArraySize(x);
   int ySize = ArraySize(y);
//--- check
   if(xSize!=ySize)
      return(NULL);
//--- create new curve
   CCurve *curve=new CCurve(x,y,clr,type,name);
//--- set max and min values
   if(m_arr_curves.Total()==0)
     {
      if(m_x.AutoScale())
        {
         m_x.Max(curve.XMax());
         m_x.Min(curve.XMin());
        }
      if(m_y.AutoScale())
        {
         m_y.Max(curve.YMax());
         m_y.Min(curve.YMin());
        }
      m_xupdate = true;
      m_yupdate = true;
     }
   else
     {
      //--- find max of x
      if(m_x.Max()<curve.XMax() && m_x.AutoScale())
        {
         m_x.Max(curve.XMax());
         m_xupdate=true;
        }
      //--- find min of x
      if(m_x.Min()>curve.XMin() && m_x.AutoScale())
        {
         m_x.Min(curve.XMin());
         m_xupdate=true;
        }
      //--- find max of y
      if(m_y.Max()<curve.YMax() && m_y.AutoScale())
        {
         m_y.Max(curve.YMax());
         m_yupdate=true;
        }
      //--- find min of y
      if(m_y.Min()>curve.YMin() && m_y.AutoScale())
        {
         m_y.Min(curve.YMin());
         m_yupdate=true;
        }
     }
//--- add curve
   m_arr_curves.Add(curve);
   return(curve);
  }
//+------------------------------------------------------------------+
//| Add new curve on graphic                                         |
//+------------------------------------------------------------------+
CCurve *CGraphic::CurveAdd(const CPoint2D &points[],const uint clr,ENUM_CURVE_TYPE type,const string name=NULL)
  {
//--- create new curve 
   CCurve *curve=new CCurve(points,clr,type,name);
//--- set max and min values
   if(m_arr_curves.Total()==0)
     {
      if(m_x.AutoScale())
        {
         m_x.Max(curve.XMax());
         m_x.Min(curve.XMin());
        }
      if(m_y.AutoScale())
        {
         m_y.Max(curve.YMax());
         m_y.Min(curve.YMin());
        }
      m_xupdate = true;
      m_yupdate = true;
     }
   else
     {
      //--- find max of x
      if(m_x.Max()<curve.XMax() && m_x.AutoScale())
        {
         m_x.Max(curve.XMax());
         m_xupdate=true;
        }
      //--- find min of x
      if(m_x.Min()>curve.XMin() && m_x.AutoScale())
        {
         m_x.Min(curve.XMin());
         m_xupdate=true;
        }
      //--- find max of y
      if(m_y.Max()<curve.YMax() && m_y.AutoScale())
        {
         m_y.Max(curve.YMax());
         m_yupdate=true;
        }
      //--- find min of y
      if(m_y.Min()>curve.YMin() && m_y.AutoScale())
        {
         m_y.Min(curve.YMin());
         m_yupdate=true;
        }
     }
//--- add curve
   m_arr_curves.Add(curve);
   return(curve);
  }
//+------------------------------------------------------------------+
//| Add new curve on graphic                                         |
//+------------------------------------------------------------------+
CCurve *CGraphic::CurveAdd(CurveFunction function,const double from,const double to,const double step,const uint clr,ENUM_CURVE_TYPE type,const string name=NULL)
  {
//--- check
   if(from>=to || step<=0 || step>=MathAbs(to-from))
      return(NULL);
//--- create new curve 
   CCurve *curve=new CCurve(function,from,to,step,clr,type,name);
//--- set max and min values
   if(m_arr_curves.Total()==0)
     {
      if(m_x.AutoScale())
        {
         m_x.Max(curve.XMax());
         m_x.Min(curve.XMin());
        }
      if(m_y.AutoScale())
        {
         m_y.Max(curve.YMax());
         m_y.Min(curve.YMin());
        }
      m_xupdate = true;
      m_yupdate = true;
     }
   else
     {
      //--- find max of x
      if(m_x.Max()<curve.XMax() && m_x.AutoScale())
        {
         m_x.Max(curve.XMax());
         m_xupdate=true;
        }
      //--- find min of x
      if(m_x.Min()>curve.XMin() && m_x.AutoScale())
        {
         m_x.Min(curve.XMin());
         m_xupdate=true;
        }
      //--- find max of y
      if(m_y.Max()<curve.YMax() && m_y.AutoScale())
        {
         m_y.Max(curve.YMax());
         m_yupdate=true;
        }
      //--- find min of y
      if(m_y.Min()>curve.YMin() && m_y.AutoScale())
        {
         m_y.Min(curve.YMin());
         m_yupdate=true;
        }
     }
//--- add curve
   m_arr_curves.Add(curve);
   return(curve);
  }
//+------------------------------------------------------------------+
//| Add ticks to current graphic                                     |
//+------------------------------------------------------------------+
bool CGraphic::MarksToAxisAdd(const double &marks[],const int mark_size,ENUM_MARK_POSITION position,const int dimension=0)
  {
   int originalX=m_left;
   int originalY=m_height-m_down;
//--- check dimension
   if(dimension==0)
     {
      int y1=m_height-m_down;
      int y2=m_height-m_down;
      //--- calculate y coordinates for marks
      switch(position)
        {
         case MARK_INTERNAL:
            y1-=mark_size;
            break;
         case MARK_EXTERNAL:
            y2+=mark_size;
            break;
         case MARK_MIDDLE:
            y1-=mark_size/2;
            y2+=mark_size/2;
            break;
        }
      //--- draw marks to x axis
      for(int i=0; i<ArraySize(marks); i++)
        {
         int x=originalX+(int)((marks[i]-m_x.Min())*m_dx);
         m_canvas.LineVertical(x,y1,y2,ColorToARGB(clrBlack,255));
        }
     }
   else
   if(dimension==1)
     {
      int x1=m_left;
      int x2=m_left;
      //--- calculate x coordinates for marks
      switch(position)
        {
         case MARK_INTERNAL:
            x2+=mark_size;
            break;
         case MARK_EXTERNAL:
            x1-=mark_size;
            break;
         case MARK_MIDDLE:
            x2+=mark_size/2;
            x1-=mark_size/2;
            break;
        }
      //--- draw marks to y axis
      for(int i=0; i<ArraySize(marks); i++)
        {
         int y=originalY -(int)((marks[i]-m_y.Min())*m_dy);
         m_canvas.LineHorizontal(x1,x2,y,ColorToARGB(clrBlack,255));
        }
     }
   else
      return(false);
//--- success
   return(true);
  }
//+------------------------------------------------------------------+
//| Add text to graphic                                              |
//+------------------------------------------------------------------+
void CGraphic::TextAdd(const int x,const int y,const string text,const uint clr,const uint alignment=0)
  {
//--- check
   if(StringLen(text)<1)
      return;
//--- set text
   m_canvas.TextOut(x,y,text,clr,alignment);
  }
//+------------------------------------------------------------------+
//| Add text to graphic                                              |
//+------------------------------------------------------------------+
void CGraphic::TextAdd(const CPoint &point,const string text,const uint clr,const uint alignment=0)
  {
//--- check
   if(StringLen(text)<1)
      return;
//--- set text
   m_canvas.TextOut(point.x,point.y,text,clr,alignment);
  }
//+------------------------------------------------------------------+
//| Add line to graphic                                              |
//+------------------------------------------------------------------+
void CGraphic::LineAdd(const int x1,const int y1,const int x2,const int y2,const uint clr,const uint style)
  {
   m_canvas.LineWu(x1,y1,x2,y2,clr,style);
  }
//+------------------------------------------------------------------+
//| Add line to graphic                                              |
//+------------------------------------------------------------------+
void CGraphic::LineAdd(const CPoint &point1,const CPoint &point2,const uint clr,const uint style)
  {
   m_canvas.LineWu(point1.x,point1.y,point2.x,point2.y,clr,style);
  }
//+------------------------------------------------------------------+
//| Draws all curves                                                 |
//+------------------------------------------------------------------+
bool CGraphic::CurvePlotAll(void)
  {
   ResetParameters();
   CalculateBoundaries();
//--- updare axes
   if(m_xupdate)
      CalculateXAxis();
   if(m_yupdate)
      CalculateYAxis();
//--- create workspace and grid
   CreateWorkspace();
   CreateGrid();
//--- draw all curves
   for(int i=0; i<m_arr_curves.Total(); i++)
     {
      //--- gets the curve
      CCurve *curve=m_arr_curves.At(i);

      if(!CheckPointer(curve))
         return(false);
      curve.Visible(true);

      //--- draws depending on the type of curve
      switch(curve.Type())
        {
         case CURVE_POINTS:
            PointsPlot(curve);
            break;
         case CURVE_LINES:
            LinesPlot(curve);
            break;
         case CURVE_POINTS_AND_LINES:
            PointsAndLinesPlot(curve);
            break;
         case CURVE_STEPS:
            StepsPlot(curve);
            break;
         case CURVE_HISTOGRAM:
            HistogramPlot(curve);
            break;
         case CURVE_NONE:
            break;
        }
     }
//--- create background
   CreateBackground();
//--- create names for axes
   CreateXName();
   CreateYName();
//--- create axes
   CreateAxes();
//--- create history  
   CreateHistory();
//--- success
   return(true);
  }
//+------------------------------------------------------------------+
//| Draws a curve by index                                           |
//+------------------------------------------------------------------+
bool CGraphic::CurvePlot(const int index)
  {
   CCurve *curve=dynamic_cast<CCurve*>(m_arr_curves.At(index));
   if(CheckPointer(curve)==POINTER_DYNAMIC)
      curve.Visible(true);
   else
      return(false);
//--- 
   ResetParameters();
   CalculateBoundaries();
//--- update axes
   if(m_xupdate)
      CalculateXAxis();
   if(m_yupdate)
      CalculateYAxis();
//--- create workspace and grid
   CreateWorkspace();
   CreateGrid();
//--- draw all curves
   for(int i=0; i<m_arr_curves.Total(); i++)
     {
      //--- gets the curve
      curve=dynamic_cast<CCurve*>(m_arr_curves.At(i));

      if(CheckPointer(curve)!=POINTER_DYNAMIC)
         return(false);
      if(!curve.Visible())
         continue;
      //--- draws depending on the type of curve
      switch(curve.Type())
        {
         case CURVE_POINTS:
            PointsPlot(curve);
            break;
         case CURVE_LINES:
            LinesPlot(curve);
            break;
         case CURVE_POINTS_AND_LINES:
            PointsAndLinesPlot(curve);
            break;
         case CURVE_STEPS:
            StepsPlot(curve);
            break;
         case CURVE_HISTOGRAM:
            HistogramPlot(curve);
            break;
         case CURVE_NONE:
            break;
        }
     }
//--- create background
   CreateBackground();
//--- create names for axes
   CreateXName();
   CreateYName();
//--- create axes
   CreateAxes();
//--- create history
   CreateHistory();
//--- success
   return(true);
  }
//+------------------------------------------------------------------+
//| Redraw grahic                                                    |
//+------------------------------------------------------------------+
bool CGraphic::Redraw(const bool rescale=false)
  {
   ResetParameters();
   CalculateBoundaries();
   if(rescale)
     {
      CalculateMaxMinValues();
     }
//--- update axes
   if(m_xupdate)
      CalculateXAxis();
   if(m_yupdate)
      CalculateYAxis();
//--- create workspace and grid
   CreateWorkspace();
   CreateGrid();
//--- draw all curves
   for(int i=0; i<m_arr_curves.Total(); i++)
     {
      //--- gets the curve
      CCurve *curve=dynamic_cast<CCurve*>(m_arr_curves.At(i));

      if(CheckPointer(curve)!=POINTER_DYNAMIC)
         return(false);
      if(!curve.Visible())
         continue;
      //--- draws depending on the type of curve
      switch(curve.Type())
        {
         case CURVE_POINTS:
            PointsPlot(curve);
            break;
         case CURVE_LINES:
            LinesPlot(curve);
            break;
         case CURVE_POINTS_AND_LINES:
            PointsAndLinesPlot(curve);
            break;
         case CURVE_STEPS:
            StepsPlot(curve);
            break;
         case CURVE_HISTOGRAM:
            HistogramPlot(curve);
            break;
         case CURVE_NONE:
            break;
        }
     }
//--- create background
   CreateBackground();
//--- create names for axes
   CreateXName();
   CreateYName();
//--- create axes
   CreateAxes();
//--- create hictory  
   CreateHistory();
//--- success
   return(true);
  }
//+------------------------------------------------------------------+
//| Update graphic on screen (redraw)                                |
//+------------------------------------------------------------------+  
void CGraphic::Update(const bool redraw=true)
  {
   m_canvas.Update(redraw);
  }
//+------------------------------------------------------------------+
//| Gets the number of curves on the graphic                         |
//+------------------------------------------------------------------+
int CGraphic::CurvesTotal(void)
  {
   return(m_arr_curves.Total());
  }
//+------------------------------------------------------------------+
//| Gets the curve in the specified index                            |
//+------------------------------------------------------------------+
CCurve *CGraphic::CurveGetByIndex(const int index)
  {
   return(m_arr_curves.At(index));
  }
//+------------------------------------------------------------------+
//| Gets the curve by name                                           |
//+------------------------------------------------------------------+
CCurve *CGraphic::CurveGetByName(const string name)
  {
//--- try to find curve by name
   for(int i=0; i<m_arr_curves.Total(); i++)
     {
      CCurve *curve=dynamic_cast<CCurve*>(m_arr_curves.At(i));
      if(curve.Name()==name)
         return(curve);
     }
//--- failed
   return(NULL);
  }
//+------------------------------------------------------------------+
//| Remove the curve in the specified index                          |
//+------------------------------------------------------------------+
bool CGraphic::CurveRemoveByIndex(const int index)
  {
   CCurve *curve=dynamic_cast<CCurve*>(m_arr_curves.Detach(index));
   if(CheckPointer(curve)==POINTER_DYNAMIC)
     {
      delete curve;
      return(true);
     }
   else
     {
      return(false);
     }
  }
//+------------------------------------------------------------------+
//| Remove the curve by name                                         |
//+------------------------------------------------------------------+
bool CGraphic::CurveRemoveByName(const string name)
  {
   for(int i=0; i<m_arr_curves.Total(); i++)
     {
      CCurve *curve=m_arr_curves.At(i);
      if(curve.Name()==name)
        {
         if(CheckPointer(curve)==POINTER_DYNAMIC)
           {
            delete m_arr_curves.Detach(i);
            return(true);
           }
         else
           {
            return(false);
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Draws a curve points                                             |
//+------------------------------------------------------------------+
void CGraphic::PointsPlot(CCurve *curve)
  {
   int size=curve.Size();
   double x[],y[];
//--- gets the coordinates of the curve
   curve.GetX(x);
   curve.GetY(y);
//--- check
   if(ArraySize(x)==0 || ArraySize(y)==0)
      return;
//--- check points size
   if(curve.PointsSize()==0)
      return;
//--- calculate originals of x and y
   int originalX = m_left;
   int originalY = m_height-m_down;
//--- draw 
   for(int i=0; i<size; i++)
     {
      //--- check coordinates
      if(!MathIsValidNumber(x[i]) || !MathIsValidNumber(y[i]))
         continue;
      int xc=originalX + (int)((x[i]-m_x.Min())*m_dx);
      int yc=originalY - (int)((y[i]-m_y.Min())*m_dy);
      int r=curve.PointsSize()/2;
      if(r>0)
        {
         switch(curve.PointsType())
           {
            case POINT_CIRCLE:
              {
               //--- draw fill circle
               if(curve.PointsFill())
                  m_canvas.FillCircle(xc,yc,curve.PointsSize()/2,curve.PointsColor());
               //--- draw circle
               m_canvas.CircleWu(xc,yc,curve.PointsSize()/2,curve.Color());
               break;
              }
            case POINT_SQUARE:
              {
               //--- draw square
               m_canvas.Rectangle(xc-r,yc-r,xc+r,yc+r,curve.Color());
               //--- draw fill square
               if(curve.PointsFill())
                  m_canvas.FillRectangle(xc-r+1,yc-r+1,xc+r-1,yc+r-1,curve.PointsColor());
               break;
              }
            case POINT_DIAMOND:
              {
               int xc1=xc+1-r;
               int yc1=yc;
               int xc2=xc;
               int yc2=yc+1-r;
               //--- draw diamond
               m_canvas.Line(xc-r,yc,xc,yc-r,curve.Color());
               m_canvas.Line(xc,yc-r,xc+r,yc,curve.Color());
               m_canvas.Line(xc+r,yc,xc,yc+r,curve.Color());
               m_canvas.Line(xc,yc+r,xc-r,yc,curve.Color());
               //--- draw fill diamond
               if(curve.PointsFill())
                 {
                  int count=(curve.PointsSize()%2==0) ? curve.PointsSize()-1 : curve.PointsSize()-2;
                  for(int j=0; j<count; j++)
                    {
                     m_canvas.Line(xc1,yc1,xc2,yc2,curve.PointsColor());
                     if(j%2==0)
                       {
                        yc2++;
                        xc1++;
                       }
                     else
                       {
                        xc2++;
                        yc1++;
                       }
                    }
                 }
               break;
              }
            case POINT_TRIANGLE:
              {
               //--- draw triangle
               m_canvas.TriangleWu(xc,yc-r,xc-r,yc+r,xc+r,yc+r,curve.Color());
               //--- draw fill triangle
               if(curve.PointsFill())
                 {
                  int dy=-r;
                  int dx=0;
                  int count=(curve.PointsSize()%2==0) ? curve.PointsSize()-1 : curve.PointsSize()-2;
                  for(int j=0; j<count; j++, dy++)
                    {
                     m_canvas.LineHorizontal(xc-dx+1,xc+dx,yc+1+dy,curve.PointsColor());
                     if(j%2==0)
                        dx++;
                    }
                 }
               break;
              }
            case POINT_TRIANGLE_DOWN:
              {
               //--- draw down triangle
               m_canvas.TriangleWu(xc,yc+r,xc-r,yc-r,xc+r,yc-r,curve.Color());
               //--- draw fill triangle
               if(curve.PointsFill())
                 {
                  int dy=r;
                  int dx=0;
                  int count=(curve.PointsSize()%2==0) ? curve.PointsSize()-1 : curve.PointsSize()-2;
                  for(int j=0; j<count; j++, dy--)
                    {
                     m_canvas.LineHorizontal(xc-dx+1,xc+dx,yc-1+dy,curve.PointsColor());
                     if(j%2==0)
                        dx++;
                    }
                 }
               break;
              }
            case POINT_X_CROSS:
              {
               //--- draw x cross
               m_canvas.Line(xc+r,yc+r,xc-r,yc-r,curve.Color());
               m_canvas.Line(xc-r,yc+r,xc+r,yc-r,curve.Color());
               break;
              }
            case POINT_PLUS:
              {
               //--- draw plus
               m_canvas.LineHorizontal(xc+r+1,xc-r,yc,curve.Color());
               m_canvas.LineVertical(xc,yc+r,yc-r,curve.Color());
               break;
              }
            case POINT_STAR:
              {
               //--- draw plus
               m_canvas.LineHorizontal(xc+r+1,xc-r,yc,curve.Color());
               m_canvas.LineVertical(xc,yc+r,yc-r,curve.Color());
               //--- draw x cross
               m_canvas.Line(xc+r,yc+r,xc-r,yc-r,curve.Color());
               m_canvas.Line(xc-r,yc+r,xc+r,yc-r,curve.Color());
               break;
              }
            case POINT_HORIZONTAL_DASH:
              {
               //--- draw horizontal line
               m_canvas.LineHorizontal(xc+r+1,xc-r,yc,curve.Color());
               break;
              }
            case POINT_VERTICAL_DASH:
              {
               //--- draw vertical line
               m_canvas.LineVertical(xc,yc+r,yc-r,curve.Color());
               break;
              }
           }
        }
      else
        {
         m_canvas.PixelSet(xc,yc,curve.Color());
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Draws a curve lines                                              |
//+------------------------------------------------------------------+
void CGraphic::LinesPlot(CCurve *curve)
  {
   int size;
   double x[],y[];
//--- gets the coordinates of the curve
   size=curve.Size();
   curve.GetX(x);
   curve.GetY(y);
//--- check
   if(ArraySize(x)==0 || ArraySize(y)==0)
      return;
//--- calculate originals of x and y
   int originalX = m_left;
   int originalY = m_height-m_down;
//--- coordinates
   int  xc[];
   int  yc[];

   int discontinuity[];
//--- find gaps of curve   
   for(int i=0; i<size; i++)
     {
      if(!MathIsValidNumber(x[i]) || !MathIsValidNumber(y[i]))
        {
         ArrayResize(discontinuity,ArraySize(discontinuity)+1,size);
         discontinuity[ArraySize(discontinuity)-1]=i;
        }
     }
//--- get the tension for spline
   double tension=curve.LinesSmoothTension();
//--- check whether the curve breaks 
   if(ArraySize(discontinuity)==0)
     {
      //--- perform smoothing if need
      if(curve.LinesSmooth() && size>2 && tension>0.0 && tension<=1.0)
         Spline(x,y,size,tension,curve.LinesSmoothStep());
      //--- calculate coordinates of curve
      ArrayResize(xc,size);
      ArrayResize(yc,size);
      for(int i=0; i<size; i++)
        {
         xc[i]=originalX + (int)((x[i]-m_x.Min())*m_dx);
         yc[i]=originalY - (int)((y[i]-m_y.Min())*m_dy);
        }
      //--- draw curve
      if(size>1)
         m_canvas.PolylineWu(xc,yc,curve.Color(),curve.LinesStyle());
      else
      if(size==1)
         m_canvas.PixelSet(xc[0],yc[0],curve.Color());
     }
   else
     {
      for(int j=0; j<=ArraySize(discontinuity); j++)
        {
         double xj[];
         double yj[];
         int sizej=0;
         if(j==0)
           {
            sizej=discontinuity[0];
            ArrayCopy(xj,x,0,0,sizej);
            ArrayCopy(yj,y,0,0,sizej);
           }
         else
         if(j==ArraySize(discontinuity))
           {
            sizej=size-discontinuity[j-1]-1;
            ArrayCopy(xj,x,0,discontinuity[j-1]+1,sizej);
            ArrayCopy(yj,y,0,discontinuity[j-1]+1,sizej);
           }
         else
           {
            sizej=discontinuity[j]-discontinuity[j-1]-1;
            ArrayCopy(xj,x,0,discontinuity[j-1]+1,sizej);
            ArrayCopy(yj,y,0,discontinuity[j-1]+1,sizej);
           }
         //--- perform smoothing if need
         if(curve.LinesSmooth() && sizej>2 && tension>0.0 && tension<=1.0)
            Spline(xj,yj,sizej,tension,curve.LinesSmoothStep());
         //--- calculate coordinates path of curve
         ArrayResize(xc,sizej,size);
         ArrayResize(yc,sizej,size);
         for(int i=0; i<sizej; i++)
           {
            xc[i]=originalX + (int)((xj[i]-m_x.Min())*m_dx);
            yc[i]=originalY - (int)((yj[i]-m_y.Min())*m_dy);
           }
         //--- draw path of curve
         if(sizej>1)
            m_canvas.PolylineWu(xc,yc,curve.Color(),curve.LinesStyle());
         else
         if(sizej==1)
            m_canvas.PixelSet(xc[0],yc[0],curve.Color());
        }
     }
  }
//+------------------------------------------------------------------+
//| Draws a curve points over lines                                  |
//+------------------------------------------------------------------+
void CGraphic::PointsAndLinesPlot(CCurve *curve)
  {
   LinesPlot(curve);
   PointsPlot(curve);
  }
//+------------------------------------------------------------------+
//| Draws a curve steps                                              |
//+------------------------------------------------------------------+
void CGraphic::StepsPlot(CCurve *curve)
  {
   int size=curve.Size();
   double x[],y[];
//--- gets the coordinates of the curve
   curve.GetX(x);
   curve.GetY(y);
//--- calculate originals of x and y
   int originalX = m_left;
   int originalY = m_height-m_down;
//--- coordinates
   int xc[],yc[];
   size=(size*2)-1;
   ArrayResize(xc,size);
   ArrayResize(yc,size);
   int index=0;
   if(curve.StepsDimension()==0)
     {
      //--- x
      for(int i=0; i<size-1; i+=2,index++)
        {
         xc[i]=originalX+(int)((x[index]-m_x.Min())*m_dx);
         xc[i+1]=originalX+(int)((x[index+1]-m_x.Min())*m_dx);
         yc[i]=originalY -(int)((y[index]-m_y.Min())*m_dy);
         yc[i+1]=yc[i];
        }
     }
   else
   if(curve.StepsDimension()==1)
     {
      //--- y
      for(int i=0; i<size-1; i+=2,index++)
        {
         xc[i]=originalX+(int)((x[index]-m_x.Min())*m_dx);
         xc[i+1]=xc[i];
         yc[i]=originalY -(int)((y[index]-m_y.Min())*m_dy);
         yc[i+1]=originalY -(int)((y[index+1]-m_y.Min())*m_dy);
        }
     }
   xc[size-1]=originalX + (int)((x[index]-m_x.Min())*m_dx);
   yc[size-1]=originalY - (int)((y[index]-m_y.Min())*m_dy);
   m_canvas.PolylineWu(xc,yc,curve.Color(),curve.LinesStyle());
  }
//+------------------------------------------------------------------+
//| Draws a curve histogram                                          |
//+------------------------------------------------------------------+
void CGraphic::HistogramPlot(CCurve *curve)
  {
   int size=curve.Size();
   double x[],y[];
//--- historgram parametrs
   int histogram_width=curve.HistogramWidth();
//--- check historgram 
   if(histogram_width<=0)
      return;
//--- gets the coordinates of the curve
   curve.GetX(x);
   curve.GetY(y);
//--- check
   if(ArraySize(x)==0 || ArraySize(y)==0)
      return;
//--- calculate originals of x and y
   int originalX = m_left;
   int originalY = m_height-m_down;
//--- draw 
   for(int i=0; i<size; i++)
     {
      //--- check coordinates
      if(!MathIsValidNumber(x[i]) || !MathIsValidNumber(y[i]))
         continue;
      int xc=originalX + (int)((x[i]-m_x.Min())*m_dx);
      int yc=originalY - (int)((y[i]-m_y.Min())*m_dy);
      int yc0 = originalY - (int)((0.0-m_y.Min())*m_dy);
      int xc1 = xc - histogram_width/2;
      int xc2 = xc + histogram_width/2;
      int yc1 = yc;
      int yc2 = (originalY>yc0 && yc0>0) ? yc0 : originalY;
      //---
      if(yc1>yc2)
         yc2++;
      else
         yc2--;
      //---
      m_canvas.FillRectangle(xc1,yc1,xc2,yc2,curve.Color());
     }
//---
  }
//+------------------------------------------------------------------+
//| Create history of curves in the right side of the graphic        |
//+------------------------------------------------------------------+
void CGraphic::CreateHistory(void)
  {
   for(int i=0; i<m_arr_curves.Total(); i++)
     {
      CCurve *curve=dynamic_cast<CCurve*>(m_arr_curves.At(i));
      //--- check
      if(CheckPointer(curve)!=POINTER_DYNAMIC)
         return;
      if(!curve.Visible())
         continue;
      //--- calculate y coordinate
      int yc=m_up+m_history.name_size/2+m_history.name_size*m_history.count_total;
      //--- gets the curve name
      string name=curve.Name();
      //--- draw symbol
      switch(curve.Type())
        {
         case CURVE_STEPS:
         case CURVE_POINTS_AND_LINES:
         case CURVE_LINES:
           {
            //--- coordinates 
            int xc1=m_width-m_rigth+m_gap;
            int xc2=m_width-m_rigth+m_gap+m_history.symbol_size;
            m_canvas.LineWu(xc1,yc,xc2,yc,curve.Color(),curve.LinesStyle());
            if(curve.Type()==CURVE_LINES)
              {
               if(name==NULL)
                 {
                  name="Lines "+IntegerToString(m_history.count_lines++);
                  curve.Name(name);
                 }
               break;
              }
            else
            if(curve.Type()==CURVE_STEPS)
              {
               if(name==NULL)
                 {
                  name="Steps "+IntegerToString(m_history.count_lines++);
                  curve.Name(name);
                 }
               break;
              }
           }
         case CURVE_POINTS :
           {
            //--- coordinates 
            int xc=m_width-m_rigth+m_gap+m_history.symbol_size/2;
            int r=(m_history.symbol_size)/3;
            if(r>0)
              {
               switch(curve.PointsType())
                 {
                  case POINT_CIRCLE:
                    {
                     //--- draw fill circle
                     if(curve.PointsFill())
                        m_canvas.FillCircle(xc,yc,r,curve.PointsColor());
                     //--- draw circle
                     m_canvas.CircleWu(xc,yc,r,curve.Color());
                     break;
                    }
                  case POINT_SQUARE:
                    {
                     //--- draw square
                     m_canvas.Rectangle(xc-r,yc-r,xc+r,yc+r,curve.Color());
                     //--- draw fill square
                     if(curve.PointsFill())
                        m_canvas.FillRectangle(xc-r+1,yc-r+1,xc+r-1,yc+r-1,curve.PointsColor());
                     break;
                    }
                  case POINT_DIAMOND:
                    {
                     int xc1=xc+1-r;
                     int yc1=yc;
                     int xc2=xc;
                     int yc2=yc+1-r;
                     //--- draw diamond
                     m_canvas.Line(xc-r,yc,xc,yc-r,curve.Color());
                     m_canvas.Line(xc,yc-r,xc+r,yc,curve.Color());
                     m_canvas.Line(xc+r,yc,xc,yc+r,curve.Color());
                     m_canvas.Line(xc,yc+r,xc-r,yc,curve.Color());
                     //--- draw fill diamond
                     if(curve.PointsFill())
                       {
                        int count=((r*2)%2==0) ? (r*2)-1 : (r*2)-2;
                        for(int j=0; j<count; j++)
                          {
                           m_canvas.Line(xc1,yc1,xc2,yc2,curve.PointsColor());
                           if(j%2==0)
                             {
                              yc2++;
                              xc1++;
                             }
                           else
                             {
                              xc2++;
                              yc1++;
                             }
                          }
                       }
                     break;
                    }
                  case POINT_TRIANGLE:
                    {
                     //--- draw triangle
                     m_canvas.TriangleWu(xc,yc-r,xc-r,yc+r,xc+r,yc+r,curve.Color());
                     //--- draw fill triangle
                     if(curve.PointsFill())
                       {
                        int dy=-r;
                        int dx=0;
                        int count=((r*2)%2==0) ? (r*2)-1 : (r*2)-2;
                        for(int j=0; j<count; j++, dy++)
                          {
                           m_canvas.LineHorizontal(xc-dx+1,xc+dx,yc+1+dy,curve.PointsColor());
                           if(j%2==0)
                              dx++;
                          }
                       }
                     break;
                    }
                  case POINT_TRIANGLE_DOWN:
                    {
                     //--- draw down triangle
                     m_canvas.TriangleWu(xc,yc+r,xc-r,yc-r,xc+r,yc-r,curve.Color());
                     //--- draw fill triangle
                     if(curve.PointsFill())
                       {
                        int dy=r;
                        int dx=0;
                        int count=((r*2)%2==0) ? (r*2)-1 : (r*2)-2;
                        for(int j=0; j<count; j++, dy--)
                          {
                           m_canvas.LineHorizontal(xc-dx+1,xc+dx,yc-1+dy,curve.PointsColor());
                           if(j%2==0)
                              dx++;
                          }
                       }
                     break;
                    }
                  case POINT_X_CROSS:
                    {
                     //--- draw x cross
                     m_canvas.Line(xc+r,yc+r,xc-r,yc-r,curve.Color());
                     m_canvas.Line(xc-r,yc+r,xc+r,yc-r,curve.Color());
                     break;
                    }
                  case POINT_PLUS:
                    {
                     //--- draw plus
                     m_canvas.LineHorizontal(xc+r+1,xc-r,yc,curve.Color());
                     m_canvas.LineVertical(xc,yc+r,yc-r,curve.Color());
                     break;
                    }
                  case POINT_STAR:
                    {
                     //--- draw plus
                     m_canvas.LineHorizontal(xc+r+1,xc-r,yc,curve.Color());
                     m_canvas.LineVertical(xc,yc+r,yc-r,curve.Color());
                     //--- draw x cross
                     m_canvas.Line(xc+r,yc+r,xc-r,yc-r,curve.Color());
                     m_canvas.Line(xc-r,yc+r,xc+r,yc-r,curve.Color());
                     break;
                    }
                  case POINT_HORIZONTAL_DASH:
                    {
                     //--- draw horizontal line
                     m_canvas.LineHorizontal(xc+r+1,xc-r,yc,curve.Color());
                     break;
                    }
                  case POINT_VERTICAL_DASH:
                    {
                     //--- draw vertical line
                     m_canvas.LineVertical(xc,yc+r,yc-r,curve.Color());
                     break;
                    }
                 }
              }
            else
              {
               if(curve.PointsSize()>0)
                  m_canvas.PixelSet(xc,yc,curve.Color());
              }
            if(curve.Type()==CURVE_POINTS)
              {
               if(name==NULL)
                 {
                  name="Points "+IntegerToString(m_history.count_points++);
                  curve.Name(name);
                 }
              }
            else
            if(curve.Type()==CURVE_POINTS_AND_LINES)
              {
               if(name==NULL)
                 {
                  name="Points and Lines "+IntegerToString(m_history.count_points++);
                  curve.Name(name);
                 }
              }
            break;
           }
         case CURVE_HISTOGRAM :
           {
            //--- coordinates 
            int xc1=m_width-m_rigth+m_gap+m_history.symbol_size/6;
            int yc1=yc-m_history.symbol_size*1/3;
            int xc2=m_width-m_rigth+m_gap+(m_history.symbol_size*5)/6;
            int yc2=yc+m_history.symbol_size*1/3;
            m_canvas.FillRectangle(xc1,yc1,xc2,yc2,curve.Color());
            if(name==NULL)
              {
               name="Histogram "+IntegerToString(m_history.count_histogram++);
               curve.Name(name);
              }
            break;
           }
        };
      //--- trim the name
      m_canvas.FontSizeSet(m_history.name_size);
      if(m_canvas.TextWidth(name)>m_history.name_width)
        {
         while(m_canvas.TextWidth(name+"...")>m_history.name_width)
            name=StringSubstr(name,0,StringLen(name)-1);
         name+="...";
        }
      //--- coordinates 
      int xct=m_width-m_rigth+2*m_gap+m_history.symbol_size;
      int yct=yc-m_history.name_size/2;
      //--- draw text
      m_canvas.TextOut(xct,yct,name,ColorToARGB(clrBlack,255));
      m_history.count_total++;
     }
  }
//+------------------------------------------------------------------+
//| Reset current current parameters og graphic                      |
//+------------------------------------------------------------------+
void CGraphic::SetDefaultParameters(void)
  {
//---  
   m_xupdate=false;
   m_yupdate=false;
   m_xsize=0;
   m_ysize=0;
//--- sets the default values for graphic  
   m_mark_size=3;
   m_gap=4;
//--- sets the default values for history
   m_history.name_width=60;
   m_history.symbol_size=11;
   m_history.name_size=12;
   m_history.count_points=0;
   m_history.count_lines=0;
   m_history.count_histogram=0;
//--- sets the default values for x and y axis
   m_x.Name(NULL);
   m_y.Name(NULL);
//--- sets the default values for grid
   m_grid.clr_line=clrWhiteSmoke;
   m_grid.clr_axis_line=clrSilver;
   m_grid.clr_frame=clrBlack;
   m_grid.clr_background=clrWhite;
   m_grid.r_circle=0;
   m_grid.clr_circle=clrWhite;
   m_grid.has_circle=false;
//--- sets the default values for background
   m_background.clr=clrWhite;
   m_background.clr_main= clrBlack;
   m_background.clr_sub = clrBlack;
   m_background.main= NULL;
   m_background.sub = NULL;
   m_background.size_main= 0;
   m_background.size_sub = 0;
  }
//+------------------------------------------------------------------+
//| Reset parametres                                                 |
//+------------------------------------------------------------------+
void CGraphic::ResetParameters(void)
  {
//--- reset boundaries 
   m_left=0;
   m_rigth=5;
   m_up=5;
   m_down=0;
//--- reset curve of history
   m_history.count_total=0;
//--- reset color generator
   m_generator.Reset();
  }
//+------------------------------------------------------------------+
//| Calculate boundaries for workspace                               |
//+------------------------------------------------------------------+
void  CGraphic::CalculateBoundaries(void)
  {
   if(m_width>0 && m_height>0)
     {
      m_rigth+=m_history.symbol_size+m_history.name_width+3*m_gap;
      m_up+=m_background.size_main+2*m_gap;
      m_down+=m_background.size_sub+m_x.ValuesSize()+m_x.NameSize()+4*m_gap;
      m_left+=m_y.NameSize()+m_mark_size+m_y.ValuesWidth()+4*m_gap;
     }
   else
     {
      ZeroMemory(m_rigth);
      ZeroMemory(m_up);
      ZeroMemory(m_down);
      ZeroMemory(m_left);
     }
  }
//+------------------------------------------------------------------+
//| Calculate the min and max values for both axes on all curves     |
//+------------------------------------------------------------------+
void CGraphic::CalculateMaxMinValues(void)
  {
   int size=m_arr_curves.Total();
   double xmax=0.0;
   double xmin=0.0;
   double ymax=0.0;
   double ymin=0.0;
   if(size>0)
     {
      bool valid=false;
      for(int i=0; i<size; i++)
        {
         CCurve *curve=dynamic_cast<CCurve*>(m_arr_curves.At(i));
         if(CheckPointer(curve)==POINTER_DYNAMIC)
           {
            if(!valid)
              {
               xmax = curve.XMax();
               xmin = curve.XMin();
               ymax = curve.YMax();
               ymin = curve.YMin();
               valid=true;
              }
            else
              {
               //--- find max of x
               if(xmax<curve.XMax())
                  xmax=curve.XMax();
               //--- find min of x
               if(xmin>curve.XMin())
                  xmin=curve.XMin();
               //--- find max of y
               if(ymax<curve.YMax())
                  ymax=curve.YMax();
               //--- find min of y
               if(ymin>curve.YMin())
                  ymin=curve.YMin();
              }
           }
        }
     }
   if(m_x.AutoScale())
     {
      m_x.Max(xmax);
      m_x.Min(xmin);
     }
   if(m_y.AutoScale())
     {
      m_y.Max(ymax);
      m_y.Min(ymin);
     }
   m_xupdate=true;
   m_yupdate=true;
  }
//+------------------------------------------------------------------+
//| Calculate coordinates and values for x axis                      |
//+------------------------------------------------------------------+
void CGraphic::CalculateXAxis(void)
  {
//---
   m_x.SelectAxisScale();
//--- calculate scaling parameters
   double xf1=m_left;
   double xf2=m_width-m_rigth;
//---
   double x_size=(m_x.Max()-m_x.Min());
   double xf_size=xf2-xf1;
//--- keep scaling parameters  
   m_dx=xf_size/x_size;
//---
   int originalX=m_left;
//---
   m_xsize=(int)MathRound((m_x.Max()-m_x.Min())/m_x.Step())+1;
   ArrayResize(m_xc,m_xsize);
   ArrayResize(m_xvalues,m_xsize);
   for(int i=0; i<m_xsize; i++)
     {
      double x=m_x.Min()+(i*m_x.Step());
      if(x>m_x.Max())
         x=m_x.Max();
      //--- calculate real coordinate
      if(i==0)
         m_xc[i]=m_left;
      else
      if(i==m_xsize-1)
         m_xc[i]=m_width-m_rigth;
      else
         m_xc[i]=originalX+(int)((x-m_x.Min())*m_dx);
      //--- create value name
      string xformat=m_x.ValuesFormat();
      m_xvalues[i]=(xformat==NULL) ? StringFormat("%7g",x) : StringFormat(xformat,x);
      StringTrimLeft(m_xvalues[i]);
      StringTrimRight(m_xvalues[i]);
     }
//---
   m_xupdate=false;
  }
//+------------------------------------------------------------------+
//| Calculate coordinates and values for y axis                      |
//+------------------------------------------------------------------+
void CGraphic::CalculateYAxis(void)
  {
//---   
   m_y.SelectAxisScale();
//--- calculate scaling parameters
   double yf1=m_up;
   double yf2=m_height-m_down;
//---
   double y_size=(m_y.Max()-m_y.Min());
   double yf_size=yf2-yf1;
//--- keep scaling parameters  
   m_dy=yf_size/y_size;
//---
   int originalY=m_height-m_down;
//---
   m_ysize=(int)MathRound((m_y.Max()-m_y.Min())/m_y.Step())+1;
   ArrayResize(m_yc,m_ysize);
   ArrayResize(m_yvalues,m_ysize);
   for(int i=0; i<m_ysize; i++)
     {
      double y=m_y.Min()+(i*m_y.Step());
      if(y>m_y.Max())
         y=m_y.Max();
      //--- calculate real coordinate
      if(i==m_ysize-1)
         m_yc[i]=m_up;
      else
      if(i==0)
         m_yc[i]=m_height-m_down;
      else
         m_yc[i]=originalY -(int)((y-m_y.Min())*m_dy);
      //--- create value name
      string yformat=m_y.ValuesFormat();
      m_yvalues[i]=(yformat==NULL) ? StringFormat("%7g",y) : StringFormat(yformat,y);
      StringTrimLeft(m_yvalues[i]);
      StringTrimRight(m_yvalues[i]);
     }
//---
   m_yupdate=false;
  }
//+------------------------------------------------------------------+
//| Approximates cardinal spline with Bezier curves.                 |
//+------------------------------------------------------------------+
void CGraphic::Spline(double &x[],double &y[],int &size,double tension,double step)
  {
   double x1=0.0f,x2=0.0f,y1=0.0f,y2=0.0f;
   tension*=0.3;
//--- coordinates of Bezier curve
   double xc[];
   double yc[];
//--- initialize control points
   double ptX[];
   double ptY[];
   int    size_pt=size*3-2;

   ArrayResize(ptX,size_pt);
   ArrayResize(ptY,size_pt);
//--- calculation of control points
   CalcCurveBezierEndp(x[0],y[0],x[1],y[1],tension,x1,y1);

   ptX[0] = x[0];
   ptY[0] = y[0];
   ptX[1] = x1;
   ptY[1] = y1;

   for(int i=0; i<size-2; i++)
     {
      CalcCurveBezier(x,y,i,tension,x1,y1,x2,y2);
      ptX[3*i+2] = x1;
      ptY[3*i+2] = y1;
      ptX[3*i+3] = x[i+1];
      ptY[3*i+3] = y[i+1];
      ptX[3*i+4] = x2;
      ptY[3*i+4] = y2;
     }
   CalcCurveBezierEndp(x[size-1],y[size-1],x[size-2],y[size-2],tension,x1,y1);

   ptX[size_pt-2] = x1;
   ptY[size_pt-2] = y1;
   ptX[size_pt-1] = x[size-1];
   ptY[size_pt-1] = y[size-1];
//--- calculation of the coordinates of Bezier curves   
   int index=0;
   for(int i=0; i<size-1; i++)
     {
      //--- Euclidean distance between two neighboring points     
      double distance=MathSqrt(MathPow(x[i+1]-x[i],2)+MathPow(y[i+1]-y[i],2));
      int size_i=(step>0.0) ?(int)(distance/step) : 1;
      if(size_i<1)
         size_i=2;
      ArrayResize(xc,ArraySize(xc)+size_i,1024);
      ArrayResize(yc,ArraySize(yc)+size_i,1024);
      for(int t=0; t<size_i; t++,index++)
        {
         xc[index]=CalcBezierX((double)t/size_i,ptX[3*i],ptX[3*i+1],ptX[3*i+2],ptX[3*i+3]);
         yc[index]=CalcBezierY((double)t/size_i,ptY[3*i],ptY[3*i+1],ptY[3*i+2],ptY[3*i+3]);
        }
     }
   ArrayCopy(x,xc);
   ArrayCopy(y,yc);
//--- keep size x and y array
   size=index;
  }
//+------------------------------------------------------------------+
//| Calculates Bezier points from cardinal spline endpoints.         |
//+------------------------------------------------------------------+
void CGraphic::CalcCurveBezierEndp(const double xend,const double yend,const double xadj,const double yadj,const double tension,double &x,double &y)
  {
   x = (tension * (xadj - xend) + xend);
   y = (tension * (yadj - yend) + yend);
  }
//+------------------------------------------------------------------+
//| Calculates Bezier points from cardinal spline points             |
//+------------------------------------------------------------------+
void CGraphic::CalcCurveBezier(const double &x[],const double &y[],const int i,const double tension,double &x1,double &y1,double &x2,double &y2)
  {
   double xdiff,ydiff;
//--- calculate tangent 
   xdiff = x[i+2] - x[i];
   ydiff = y[i+2] - y[i];
//--- apply tangent to get control points 
   x1 = x[i+1] - tension * xdiff;
   y1 = y[i+1] - tension * ydiff;
   x2 = x[i+1] + tension * xdiff;
   y2 = y[i+1] + tension * ydiff;
//---
  }
//+------------------------------------------------------------------+
//| Calculate x coordinate of Bezier curve                           |
//+------------------------------------------------------------------+
double CGraphic::CalcBezierX(const double t,const double x0,const double x1,const double x2,const double x3)
  {
   return(x0*MathPow((1-t),3)+
          x1*3*t*MathPow((1-t),2)+
          x2*3*MathPow(t,2) *(1-t)+
          x3*MathPow(t,3));
  }
//+------------------------------------------------------------------+
//| Calculate y coordinate of Bezier curve                           |
//+------------------------------------------------------------------+
double CGraphic::CalcBezierY(const double t,const double y0,const double y1,const double y2,const double y3)
  {
   return(y0*MathPow((1-t),3)+
          y1*3*t*MathPow((1-t),2)+
          y2*3*MathPow(t,2) *(1-t)+
          y3*MathPow(t,3));
  }
//+------------------------------------------------------------------+
//| Create graphic of one curve and return resource name             |
//+------------------------------------------------------------------+
string GraphPlot(const double &y[],ENUM_CURVE_TYPE type=CURVE_POINTS,string objname=NULL)
  {
   CGraphic graphic;
   ulong    width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   ulong    height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- create graphic
   bool res=false;
   objname = (objname==NULL) ? "Graphic" : objname;
   if(ObjectFind(0,objname)>=0)
      res=graphic.Attach(0,objname);
   else
      res=graphic.Create(0,objname,0,65,45,(int)(0.6*width),(int)(0.65*height));
   if(!res)
      return(NULL);
//--- add curves
   graphic.CurveAdd(y,type);
//--- plot curves
   graphic.CurvePlotAll();
   graphic.Update();
//--- return resource name
   return graphic.ChartObjectName();
  }
//+------------------------------------------------------------------+
//| Create graphic of one curve and return resource name             |
//+------------------------------------------------------------------+
string GraphPlot(const double &x[],const double &y[],ENUM_CURVE_TYPE type=CURVE_POINTS,string objname=NULL)
  {
   CGraphic graphic;
   ulong    width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   ulong    height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- create graphic
   bool res=false;
   objname = (objname==NULL) ? "Graphic" : objname;
   if(ObjectFind(0,objname)>=0)
      res=graphic.Attach(0,objname);
   else
      res=graphic.Create(0,objname,0,65,45,(int)(0.6*width),(int)(0.65*height));
   if(!res)
      return(NULL);
//--- add curves
   graphic.CurveAdd(x,y,type);
//--- plot curves
   graphic.CurvePlotAll();
   graphic.Update();
//--- return resource name
   return graphic.ChartObjectName();
  }
//+------------------------------------------------------------------+
//| Create graphic of two curve and return resource name             |
//+------------------------------------------------------------------+  
string GraphPlot(const double &x1[],const double &y1[],const double &x2[],const double &y2[],ENUM_CURVE_TYPE type=CURVE_POINTS,string objname=NULL)
  {
   CGraphic graphic;
   ulong    width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   ulong    height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- create graphic
   bool res=false;
   objname = (objname==NULL) ? "Graphic" : objname;
   if(ObjectFind(0,objname)>=0)
      res=graphic.Attach(0,objname);
   else
      res=graphic.Create(0,objname,0,65,45,(int)(0.6*width),(int)(0.65*height));
   if(!res)
      return(NULL);
//--- add curves
   graphic.CurveAdd(x1,y1,type);
   graphic.CurveAdd(x2,y2,type);
//--- plot curves
   graphic.CurvePlotAll();
   graphic.Update();
//--- return resource name
   return graphic.ChartObjectName();
  }
//+------------------------------------------------------------------+
//| Create graphic of three curve and return resource name           |
//+------------------------------------------------------------------+  
string GraphPlot(const double &x1[],const double &y1[],const double &x2[],const double &y2[],const double &x3[],const double &y3[],ENUM_CURVE_TYPE type=CURVE_POINTS,string objname=NULL)
  {
   CGraphic graphic;
   ulong    width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   ulong    height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- create graphic
   bool res=false;
   objname = (objname==NULL) ? "Graphic" : objname;
   if(ObjectFind(0,objname)>=0)
      res=graphic.Attach(0,objname);
   else
      res=graphic.Create(0,objname,0,65,45,(int)(0.6*width),(int)(0.65*height));
   if(!res)
      return(NULL);
//--- add curves
   graphic.CurveAdd(x1,y1,type);
   graphic.CurveAdd(x2,y2,type);
   graphic.CurveAdd(x3,y3,type);
//--- plot curves
   graphic.CurvePlotAll();
   graphic.Update();
//--- return resource name
   return graphic.ChartObjectName();
  }
//+------------------------------------------------------------------+
//| Create graphic of one curve and return resource name             |
//+------------------------------------------------------------------+
string GraphPlot(const CPoint2D &points[],ENUM_CURVE_TYPE type=CURVE_POINTS,string objname=NULL)
  {
   CGraphic graphic;
   ulong    width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   ulong    height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- create graphic
   bool res=false;
   objname = (objname==NULL) ? "Graphic" : objname;
   if(ObjectFind(0,objname)>=0)
      res=graphic.Attach(0,objname);
   else
      res=graphic.Create(0,objname,0,65,45,(int)(0.6*width),(int)(0.65*height));
   if(!res)
      return(NULL);
//--- add curves
   graphic.CurveAdd(points,type);
//--- plot curves
   graphic.CurvePlotAll();
   graphic.Update();
//--- return resource name
   return graphic.ChartObjectName();
  }
//+------------------------------------------------------------------+
//| Create graphic of two curve and return resource name             |
//+------------------------------------------------------------------+  
string GraphPlot(const CPoint2D &points1[],const CPoint2D &points2[],ENUM_CURVE_TYPE type=CURVE_POINTS,string objname=NULL)
  {
   CGraphic graphic;
   ulong    width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   ulong    height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- create graphic
   bool res=false;
   objname = (objname==NULL) ? "Graphic" : objname;
   if(ObjectFind(0,objname)>=0)
      res=graphic.Attach(0,objname);
   else
      res=graphic.Create(0,objname,0,65,45,(int)(0.6*width),(int)(0.65*height));
   if(!res)
      return(NULL);
//--- add curves
   graphic.CurveAdd(points1,type);
   graphic.CurveAdd(points2,type);
//--- plot curves
   graphic.CurvePlotAll();
   graphic.Update();
//--- return resource name
   return graphic.ChartObjectName();
  }
//+------------------------------------------------------------------+
//| Create graphic of three curve and return resource name           |
//+------------------------------------------------------------------+  
string GraphPlot(const CPoint2D &points1[],const CPoint2D &points2[],const CPoint2D &points3[],ENUM_CURVE_TYPE type=CURVE_POINTS,string objname=NULL)
  {
   CGraphic graphic;
   ulong    width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   ulong    height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- create graphic
   bool res=false;
   objname = (objname==NULL) ? "Graphic" : objname;
   if(ObjectFind(0,objname)>=0)
      res=graphic.Attach(0,objname);
   else
      res=graphic.Create(0,objname,0,65,45,(int)(0.6*width),(int)(0.65*height));
   if(!res)
      return(NULL);
//--- add curves
   graphic.CurveAdd(points1,type);
   graphic.CurveAdd(points2,type);
   graphic.CurveAdd(points3,type);
//--- plot curves
   graphic.CurvePlotAll();
   graphic.Update();
//--- return resource name
   return graphic.ChartObjectName();
  }
//+------------------------------------------------------------------+
//| Create graphic of one curve and return resource name             |
//+------------------------------------------------------------------+
string GraphPlot(CurveFunction function,const double from,const double to,const double step,ENUM_CURVE_TYPE type=CURVE_POINTS,string objname=NULL)
  {
   CGraphic graphic;
   ulong    width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   ulong    height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- create graphic
   bool res=false;
   objname = (objname==NULL) ? "Graphic" : objname;
   if(ObjectFind(0,objname)>=0)
      res=graphic.Attach(0,objname);
   else
      res=graphic.Create(0,objname,0,65,45,(int)(0.6*width),(int)(0.65*height));
   if(!res)
      return(NULL);
//--- add curves
   graphic.CurveAdd(function,from,to,step,type);
//--- plot curves
   graphic.CurvePlotAll();
   graphic.Update();
//--- return resource name
   return graphic.ChartObjectName();
  }
//+------------------------------------------------------------------+
//| Create graphic of two curve and return resource name             |
//+------------------------------------------------------------------+  
string GraphPlot(CurveFunction function1,CurveFunction function2,const double from,const double to,const double step,ENUM_CURVE_TYPE type=CURVE_POINTS,string objname=NULL)
  {
   CGraphic graphic;
   ulong    width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   ulong    height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- create graphic
   bool res=false;
   objname = (objname==NULL) ? "Graphic" : objname;
   if(ObjectFind(0,objname)>=0)
      res=graphic.Attach(0,objname);
   else
      res=graphic.Create(0,objname,0,65,45,(int)(0.6*width),(int)(0.65*height));
   if(!res)
      return(NULL);
//--- add curves
   graphic.CurveAdd(function1,from,to,step,type);
   graphic.CurveAdd(function2,from,to,step,type);
//--- plot curves
   graphic.CurvePlotAll();
   graphic.Update();
//--- return resource name
   return graphic.ChartObjectName();
  }
//+------------------------------------------------------------------+
//| Create graphic of three curve and return resource name           |
//+------------------------------------------------------------------+  
string GraphPlot(CurveFunction function1,CurveFunction function2,CurveFunction function3,const double from,const double to,const double step,ENUM_CURVE_TYPE type=CURVE_POINTS,string objname=NULL)
  {
   CGraphic graphic;
   ulong    width = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   ulong    height= ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
//--- create graphic
   bool res=false;
   objname = (objname==NULL) ? "Graphic" : objname;
   if(ObjectFind(0,objname)>=0)
      res=graphic.Attach(0,objname);
   else
      res=graphic.Create(0,objname,0,65,45,(int)(0.6*width),(int)(0.65*height));
   if(!res)
      return(NULL);
//--- add curves
   graphic.CurveAdd(function1,from,to,step,type);
   graphic.CurveAdd(function2,from,to,step,type);
   graphic.CurveAdd(function3,from,to,step,type);
//--- plot curves 
   graphic.CurvePlotAll();
   graphic.Update();
//--- return resource name
   return graphic.ChartObjectName();
  }
//+------------------------------------------------------------------+
