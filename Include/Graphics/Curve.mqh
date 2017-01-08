//+------------------------------------------------------------------+
//|                                                        Curve.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Object.mqh>
typedef double(*CurveFunction)(double);
//--- drawing type
enum ENUM_CURVE_TYPE
  {
   CURVE_POINTS,
   CURVE_LINES,
   CURVE_POINTS_AND_LINES,
   CURVE_STEPS,
   CURVE_HISTOGRAM,
   CURVE_NONE
  };
//--- type for the various point shapes that are available 
enum ENUM_POINT_TYPE
  {
   POINT_CIRCLE,
   POINT_SQUARE,
   POINT_DIAMOND,
   POINT_TRIANGLE,
   POINT_TRIANGLE_DOWN,
   POINT_X_CROSS,
   POINT_PLUS,
   POINT_STAR,
   POINT_HORIZONTAL_DASH,
   POINT_VERTICAL_DASH
  };
//+------------------------------------------------------------------+
//| Structure CPoint2D                                               |
//| Usage: 2d point on graphic in Cartesian coordinates              |
//+------------------------------------------------------------------+
struct CPoint2D
  {
   double            x;
   double            y;
  };
//+------------------------------------------------------------------+
//| Class CCurve                                                     |
//| Usage: class to represent the one-dimensional curve              |
//+------------------------------------------------------------------+
class CCurve : public CObject
  {
private:
   uint              m_clr;
   double            m_x[];
   double            m_y[];
   double            m_xmin;
   double            m_xmax;
   double            m_ymin;
   double            m_ymax;
   int               m_size;
   ENUM_CURVE_TYPE   m_type;
   string            m_name;
   //--- lines
   ENUM_LINE_STYLE   m_lines_style;
   bool              m_lines_smooth;
   double            m_lines_tension;
   double            m_lines_step;
   //--- points
   int               m_points_size;
   ENUM_POINT_TYPE   m_points_type;
   bool              m_points_fill;
   uint              m_points_clr;
   //--- steps
   int               m_steps_dimension;
   //--- histogram
   int               m_hisogram_width;
   //--- general property
   bool              m_visible;

public:
                     CCurve(const double &y[],const uint clr,ENUM_CURVE_TYPE type,const string name="");
                     CCurve(const double &x[],const double &y[],const uint clr,ENUM_CURVE_TYPE type,const string name="");
                     CCurve(const CPoint2D &points[],const uint clr,ENUM_CURVE_TYPE type,const string name="");
                     CCurve(CurveFunction function,const double from,const double to,const double step,const uint clr,ENUM_CURVE_TYPE type,const string name="");
                    ~CCurve(void);
   //--- gets the general properties                
   void              GetX(double &x[]) { ArrayCopy(x,m_x); }
   void              GetY(double &y[]) { ArrayCopy(y,m_y); }
   double            XMax(void)        { return(m_xmax);   }
   double            XMin(void)        { return(m_xmin);   }
   double            YMax(void)        { return(m_ymax);   }
   double            YMin(void)        { return(m_ymin);   }
   int               Size(void)        { return(m_size);   }
   //--- update                     
   void              Update(const double &y[]);
   void              Update(const double &x[],const double &y[]);
   void              Update(const CPoint2D &points[]);
   void              Update(CurveFunction function,const double from,const double to,const double step);
   //--- gets or sets general options
   uint              Color(void)                 { return(m_clr);      }
   void              Color(const uint clr)       { m_clr=clr;          }
   ENUM_CURVE_TYPE   Type(void)                  { return(m_type);     }
   void              Type(ENUM_CURVE_TYPE type)  { m_type=type;        }
   string            Name(void)                  { return(m_name);     }
   void              Name(const string name)     { m_name=name;        }
   bool              Visible(void)               { return(m_visible);  }
   void              Visible(const bool visible) { m_visible=visible;  }
   //--- gets or sets the lines properties
   ENUM_LINE_STYLE   LinesStyle(void)                         { return(m_lines_style);   }
   bool              LinesSmooth(void)                        { return(m_lines_smooth);  }
   double            LinesSmoothTension(void)                 { return(m_lines_tension); }
   double            LinesSmoothStep(void)                    { return(m_lines_step);    }
   void              LinesStyle(ENUM_LINE_STYLE style)        { m_lines_style=style;     }
   void              LinesSmooth(const bool smooth)           { m_lines_smooth=smooth;   }
   void              LinesSmoothTension(const double tension) { m_lines_tension=tension; }
   void              LinesSmoothStep(const double step)       { m_lines_step=step;       }
   //--- gets or sets the points properties
   int               PointsSize(void)                 { return(m_points_size); }
   ENUM_POINT_TYPE   PointsType(void)                 { return(m_points_type); }
   bool              PointsFill(void)                 { return(m_points_fill); }
   uint              PointsColor(void)                { return(m_points_clr);  }
   void              PointsSize(const int size)       { m_points_size=size;    }
   void              PointsType(ENUM_POINT_TYPE type) { m_points_type=type;    }
   void              PointsFill(const bool fill)      { m_points_fill=fill;    }
   void              PointsColor(const uint clr)      { m_points_clr=clr;      }
   //--- gets or sets the steps properties
   int               StepsDimension(void)                { return(m_steps_dimension);   }
   void              StepsDimension(const int dimension) { m_steps_dimension=dimension; }
   //--- gets or sets the histogram properties
   int               HistogramWidth(void)            { return(m_hisogram_width); }
   void              HistogramWidth(const int width) { m_hisogram_width=width;   }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCurve::CCurve(const double &y[],const uint clr,ENUM_CURVE_TYPE type,const string name="")
                                                                                       : m_name(name),
m_clr(clr),
m_type(type),
m_visible(false),
m_lines_style(STYLE_SOLID),
m_lines_smooth(false),
m_lines_tension(0.5),
m_lines_step(0.2),
m_points_size(6),
m_points_type(POINT_CIRCLE),
m_points_fill(false),
m_points_clr(clr),
m_steps_dimension(0),
m_hisogram_width(1)
  {
//--- keep y array
   m_size=ArraySize(y);
   ArrayResize(m_x,m_size);
   ArrayCopy(m_y,y);
   m_xmax = m_size-1;
   m_xmin = 0.0;
   m_ymax = 0.0;
   m_ymin = 0.0;
   bool yvalid=false;
//--- find min and max values 
   for(int i=0; i<m_size; i++)
     {
      m_x[i]=i;
      if(MathIsValidNumber(m_y[i]))
        {
         if(!yvalid)
           {
            m_ymax=m_y[i];
            m_ymin= m_y[i];
            yvalid=true;
           }
         else
           {
            //--- find max and min of y
            if(m_ymax<y[i])
               m_ymax=y[i];
            else
            if(m_ymin>y[i])
               m_ymin=y[i];
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCurve::CCurve(const double &x[],const double &y[],const uint clr,ENUM_CURVE_TYPE type,const string name="")
                                                                                                         : m_name(name),
m_clr(clr),
m_type(type),
m_visible(false),
m_lines_style(STYLE_SOLID),
m_lines_smooth(false),
m_lines_tension(0.5),
m_lines_step(0.2),
m_points_size(6),
m_points_type(POINT_CIRCLE),
m_points_fill(false),
m_points_clr(clr),
m_steps_dimension(0),
m_hisogram_width(1)
  {
//--- keep x and y array
   ArrayCopy(m_x,x);
   ArrayCopy(m_y,y);
   m_size = ArraySize(x);
   m_xmax = 0.0;
   m_xmin = 0.0;
   m_ymax = 0.0;
   m_ymin = 0.0;
   bool yvalid=false;
   bool xvalid=false;
//--- find min and max values 
   for(int i=0; i<m_size; i++)
     {
      if(MathIsValidNumber(m_x[i]))
        {
         if(!xvalid)
           {
            m_xmax = x[i];
            m_xmin = x[i];
            xvalid=true;
           }
         else
           {
            //--- find max and min of x
            if(m_xmax<x[i])
               m_xmax=x[i];
            else
            if(m_xmin>x[i])
               m_xmin=x[i];
           }
        }
      if(MathIsValidNumber(m_y[i]))
        {
         if(!yvalid)
           {
            m_ymax = y[i];
            m_ymin = y[i];
            yvalid=true;
           }
         else
           {
            //--- find max and min of y
            if(m_ymax<y[i])
               m_ymax=y[i];
            else
            if(m_ymin>y[i])
               m_ymin=y[i];
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCurve::CCurve(const CPoint2D &points[],const uint clr,ENUM_CURVE_TYPE type,const string name="")
                                                                                              : m_name(name),
m_clr(clr),
m_type(type),
m_visible(false),
m_lines_style(STYLE_SOLID),
m_lines_smooth(false),
m_lines_tension(0.5),
m_lines_step(0.2),
m_points_size(6),
m_points_type(POINT_CIRCLE),
m_points_fill(false),
m_points_clr(clr),
m_steps_dimension(0),
m_hisogram_width(1)
  {
//--- preliminary calculation
   m_size=ArraySize(points);
   ArrayResize(m_x,m_size);
   ArrayResize(m_y,m_size);
   m_xmax = 0.0;
   m_xmin = 0.0;
   m_ymax = 0.0;
   m_ymin = 0.0;
   bool xvalid=false;
   bool yvalid=false;
//--- keep x and y array
   for(int i=0; i<m_size; i++)
     {
      m_x[i] = points[i].x;
      m_y[i] = points[i].y;
      if(MathIsValidNumber(m_x[i]))
        {
         if(!xvalid)
           {
            m_xmax = m_x[i];
            m_xmin = m_x[i];
            xvalid=true;
           }
         else
           {
            //--- find max and min of x
            if(m_xmax<m_x[i])
               m_xmax=m_x[i];
            else
            if(m_xmin>m_x[i])
               m_xmin=m_x[i];
           }
        }
      if(MathIsValidNumber(m_y[i]))
        {
         if(!yvalid)
           {
            m_ymax = m_y[i];
            m_ymin = m_y[i];
            yvalid=true;
           }
         else
           {
            //--- find max and min of y
            if(m_ymax<m_y[i])
               m_ymax=m_y[i];
            else
            if(m_ymin>m_y[i])
               m_ymin=m_y[i];
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CCurve::CCurve(CurveFunction function,const double from,const double to,const double step,const uint clr,ENUM_CURVE_TYPE type,const string name="")
                                                                                                                                                : m_name(name),
m_clr(clr),
m_type(type),
m_visible(false),
m_lines_style(STYLE_SOLID),
m_lines_smooth(false),
m_lines_tension(0.5),
m_lines_step(0.1),
m_points_size(6),
m_points_type(POINT_CIRCLE),
m_points_fill(false),
m_points_clr(clr),
m_steps_dimension(0),
m_hisogram_width(1)
  {
//--- preliminary calculation
   m_size=(int)((to-from)/step)+1;
   ArrayResize(m_x,m_size);
   ArrayResize(m_y,m_size);
   m_xmax = to;
   m_xmin = from;
   m_ymax = 0.0;
   m_ymin = 0.0;
   bool yvalid=false;
//--- keep x and y array
   for(int i=0; i<m_size; i++)
     {
      m_x[i]=from+(i*step);
      m_y[i]=function(m_x[i]);
      if(MathIsValidNumber(m_y[i]))
        {
         if(!yvalid)
           {
            m_ymax=m_y[i];
            m_ymin=m_y[i];
            yvalid=true;
           }
         else
           {
            //--- find max and min of y
            if(m_ymax<m_y[i])
               m_ymax=m_y[i];
            else if(m_ymin>m_y[i])
               m_ymin=m_y[i];
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CCurve::~CCurve(void)
  {
  }
//+------------------------------------------------------------------+
//| Update x and y coordinates of curve                              |
//+------------------------------------------------------------------+
void CCurve::Update(const double &y[])
  {
   int size=ArraySize(y);
//--- keep y array
   if(m_size!=size)
     {
      m_size=size;
      ArrayResize(m_x,m_size);
     }
   ArrayCopy(m_y,y);
   m_xmax = m_size-1;
   m_xmin = 0.0;
   m_ymax = 0.0;
   m_ymin = 0.0;
   bool yvalid=false;
//--- find min and max values 
   for(int i=0; i<m_size; i++)
     {
      m_x[i]=i;
      if(MathIsValidNumber(m_y[i]))
        {
         if(!yvalid)
           {
            m_ymax=m_y[i];
            m_ymin= m_y[i];
            yvalid=true;
           }
         else
           {
            //--- find max and min of y
            if(m_ymax<y[i])
               m_ymax=y[i];
            else
            if(m_ymin>y[i])
               m_ymin=y[i];
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Update x and y coordinates of curve                              |
//+------------------------------------------------------------------+
void CCurve::Update(const double &x[],const double &y[])
  {
//--- keep x and y array
   ArrayCopy(m_x,x);
   ArrayCopy(m_y,y);
   m_size = ArraySize(x);
   m_xmax = 0.0;
   m_xmin = 0.0;
   m_ymax = 0.0;
   m_ymin = 0.0;
   bool yvalid=false;
   bool xvalid=false;
//--- find min and max values 
   for(int i=0; i<m_size; i++)
     {
      if(MathIsValidNumber(m_x[i]))
        {
         if(!xvalid)
           {
            m_xmax = x[i];
            m_xmin = x[i];
            xvalid=true;
           }
         else
           {
            //--- find max and min of x
            if(m_xmax<x[i])
               m_xmax=x[i];
            else
            if(m_xmin>x[i])
               m_xmin=x[i];
           }
        }
      if(MathIsValidNumber(m_y[i]))
        {
         if(!yvalid)
           {
            m_ymax = y[i];
            m_ymin = y[i];
            yvalid=true;
           }
         else
           {
            //--- find max and min of y
            if(m_ymax<y[i])
               m_ymax=y[i];
            else
            if(m_ymin>y[i])
               m_ymin=y[i];
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Update x and y coordinates of curve                              |
//+------------------------------------------------------------------+
void CCurve::Update(const CPoint2D &points[])
  {
   int size=ArraySize(points);
//--- preliminary calculation
   if(size!=m_size)
     {
      m_size=size;
      ArrayResize(m_x,m_size);
      ArrayResize(m_y,m_size);
     }
   m_xmax = 0.0;
   m_xmin = 0.0;
   m_ymax = 0.0;
   m_ymin = 0.0;
   bool xvalid=false;
   bool yvalid=false;
//--- keep x and y array
   for(int i=1; i<m_size; i++)
     {
      m_x[i] = points[i].x;
      m_y[i] = points[i].y;
      if(MathIsValidNumber(m_x[i]))
        {
         if(!xvalid)
           {
            m_xmax = m_x[i];
            m_xmin = m_x[i];
            xvalid=true;
           }
         else
           {
            //--- find max and min of x
            if(m_xmax<m_x[i])
               m_xmax=m_x[i];
            else
            if(m_xmin>m_x[i])
               m_xmin=m_x[i];
           }
        }
      if(MathIsValidNumber(m_y[i]))
        {
         if(!yvalid)
           {
            m_ymax = m_y[i];
            m_ymin = m_y[i];
            yvalid=true;
           }
         else
           {
            //--- find max and min of y
            if(m_ymax<m_y[i])
               m_ymax=m_y[i];
            else
            if(m_ymin>m_y[i])
               m_ymin=m_y[i];
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Update x and y coordinates of curve                              |
//+------------------------------------------------------------------+
void CCurve::Update(CurveFunction function,const double from,const double to,const double step)
  {
   int size=(int)((to-from)/step)+1;
//--- preliminary calculation
   if(size!=m_size)
     {
      m_size=size;
      ArrayResize(m_x,m_size);
      ArrayResize(m_y,m_size);
     }
   m_xmax = to;
   m_xmin = from;
   m_ymax = 0.0;
   m_ymin = 0.0;
   bool yvalid=false;
//--- keep x and y array
   for(int i=0; i<m_size; i++)
     {
      m_x[i]=from+(i*step);
      m_y[i]=function(m_x[i]);
      if(MathIsValidNumber(m_y[i]))
        {
         if(!yvalid)
           {
            m_ymax=m_y[i];
            m_ymin=m_y[i];
            yvalid=true;
           }
         else
           {
            //--- find max and min of y
            if(m_ymax<m_y[i])
               m_ymax=m_y[i];
            else if(m_ymin>m_y[i])
               m_ymin=m_y[i];
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
