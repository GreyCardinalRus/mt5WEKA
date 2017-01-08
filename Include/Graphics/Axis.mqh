//+------------------------------------------------------------------+
//|                                                         Axis.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class CAxis                                                      |
//| Usage: class for create axes on a two-dimensional graphics       |
//+------------------------------------------------------------------+
class CAxis
  {
private:
   double            m_min;
   double            m_max;
   double            m_step;
   color             m_clr;
   string            m_name;
   int               m_name_size;
   int               m_values_size;
   int               m_values_width;
   string            m_values_format;
   bool              m_auto_scale;
   double            m_zero_lever;     // this number is used to determine when an axis scale range should be extended to include the zero value.
   double            m_default_step;   // length of the default step
   double            m_max_labels;     // the maximum number of marks
   double            m_min_grace;      // "grace" value applied to the minimum data range
   double            m_max_grace;      // "grace" value applied to the maximum data range


public:
                     CAxis(void);
                    ~CAxis(void);
   //--- properties
   double            Step(void)              { return(m_step); }
   double            Min(void)               { return(m_min);  }
   void              Min(const double min)   { m_min=min;      }
   double            Max(void)               { return(m_max);  }
   void              Max(const double max)   { m_max=max;      }
   string            Name(void)              { return(m_name); }
   void              Name(const string name) { m_name=name;    }
   //--- default properties 
   color             Color(void)                      { return(m_clr);           }
   void              Color(const color clr)           { m_clr=clr;               }
   bool              AutoScale(void)                  { return(m_auto_scale);    }
   void              AutoScale(const bool auto)       { m_auto_scale=auto;       }
   int               ValuesSize(void)                 { return(m_values_size);   }
   void              ValuesSize(const int size)       { m_values_size=size;      }
   int               ValuesWidth(void)                { return(m_values_width);  }
   void              ValuesWidth(const int width)     { m_values_width=width;    }
   string            ValuesFormat(void)                  { return(m_values_format); }
   void              ValuesFormat(const string format)   { m_values_format=format;  }
   int               NameSize(void)                   { return(m_name_size);     }
   void              NameSize(const int size)         { m_name_size=size;        }
   double            ZeroLever(void)                  { return(m_zero_lever);    }
   void              ZeroLever(const double value)    { m_zero_lever=value;      }
   double            DefaultStep(void)                { return(m_default_step);  }
   void              DefaultStep(const double value)  { m_default_step=value;    }
   double            MaxLabels(void)                  { return(m_max_labels);    }
   void              MaxLabels(const double value)    { m_max_labels=value;      }
   double            MinGrace(void)                   { return(m_min_grace);     }
   void              MinGrace(const double value)     { m_min_grace=value;       }
   double            MaxGrace(void)                   { return(m_max_grace);     }
   void              MaxGrace(const double value)     { m_max_grace=value;       }
   //--- method of automatic axis scaling
   void              SelectAxisScale(void);

private:
   void              ExtensionBoundaries(void);
   double            CalcStepSize(const double range,const double steps);
   double            Mod(const double x,const double y);
   double            CalcBoundedStepSize(const double range,const double max_steps);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CAxis::CAxis(void) : m_auto_scale(true),
                     m_zero_lever(0.25),
                     m_default_step(25.0),
                     m_max_labels(15),
                     m_min_grace(0.01),
                     m_max_grace(0.01),
                     m_clr(clrBlack),
                     m_name_size(0),
                     m_values_size(12),
                     m_values_width(30),
                     m_values_format(NULL)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CAxis::~CAxis(void)
  {
  }
//+------------------------------------------------------------------+
//| Rounds a maximum, minimum values and defines step size.          |
//+------------------------------------------------------------------+
void CAxis::SelectAxisScale(void)
  {
   if(!m_auto_scale)
     {
      if(m_max<m_min)
        {
         m_max=0;
         m_min=0;
        }
      m_step=((m_max-m_min)>m_default_step) ? m_default_step : m_max-m_min;
      return;
     }
   ExtensionBoundaries();
//--- test for trivial condition of range = 0 and pick a suitable default
   if(m_max-m_min<1.0e-30)
     {
      m_max=m_max+0.2 *(m_max==0 ? 1.0 : MathAbs(m_max));
      m_min=m_min-0.2 *(m_min==0 ? 1.0 : MathAbs(m_min));
     }
//--- this is the zero-lever test. If m_min is within the zero lever fraction of the data range,then use zero.
   if(m_min>0 && m_min/(m_max-m_min)<m_zero_lever)
      m_min=0;
//--- repeat the zero-lever test for cases where the m_max is less than zero
   if(m_max<0 && MathAbs(m_max/(m_max-m_min))<m_zero_lever)
      m_max=0;
//--- calculate the new m_step size
   double target_step=m_default_step;
//--- Calculate the m_step size based on target steps
   m_step=CalcStepSize(m_max-m_min,target_step);
   if(m_max_labels<(m_max-m_min)/m_step)
      m_step=CalcBoundedStepSize(m_max-m_min,m_max_labels);
//--- calculate the scale minimum
   m_min=m_min-Mod(m_min,m_step);
//--- calculate the scale maximum
   m_max=Mod(m_max,m_step)==0.0 ? m_max : m_max+m_step-Mod(m_max,m_step);
  }
//+------------------------------------------------------------------+
//| Expands the boundaries to the left and right.                    |
//+------------------------------------------------------------------+
void CAxis::ExtensionBoundaries(void)
  {
   double range=m_max-m_min;
//--- do not let the grace value extend the axis below zero when all the values were positive
   if(m_min<0 || m_min-m_min_grace*range>=0.0)
      m_min=m_min-m_min_grace*range;
//--- do not let the grace value extend the axis above zero when all the values were negative     
   if(m_max>0 || m_max+m_max_grace*range<=0.0)
      m_max=m_max+m_max_grace*range;
//--- calculate new min and max values if they equal 
   if(m_max==m_min)
     {
      if(MathAbs(m_max)>1e-100)
        {
         m_max *= (m_min < 0 ? 0.95 : 1.05 );
         m_min *= (m_min < 0 ? 1.05 : 0.95 );
        }
      else
        {
         m_max = 1.0;
         m_min = -1.0;
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Calculate a m_step size based on a data range.                   |
//+------------------------------------------------------------------+
double CAxis::CalcStepSize(const double range,const double steps)
  {
//--- calculate an initial guess at m_step size   
   double temp=range/steps;
//--- get the magnitude of the m_step size
   double mag=MathFloor(MathLog10(temp));
   double magPow=MathPow(10.0,mag);
//--- calculate most significant digit of the new m_step size
   double magMsd=NormalizeDouble(temp/magPow+.5,0);
//--- promote the MSD to either 1, 2, or 5
   if(magMsd>5.0)
      magMsd=10.0;
   else
   if(magMsd>2.0)
      magMsd=5.0;
   else
   if(magMsd>1.0)
      magMsd=2.0;
//--- return step
   return(magMsd * magPow);
  }
//+------------------------------------------------------------------+
//| Calculate the modulus (remainder) in a safe manner so that divide|
//| by zero errors are avoided                                       |
//+------------------------------------------------------------------+
double CAxis::Mod(const double x,const double y)
  {
//--- check 
   if(y==0)
      return(0);
//--- calculate modulus      
   double temp=x/y;
   return(y * ( temp - MathFloor( temp ) ));
  }
//+------------------------------------------------------------------+
//| Calculate a m_step size based on a data range, limited to a max  |
//| number of steps.                                                 |
//+------------------------------------------------------------------+
double CAxis::CalcBoundedStepSize(const double range,const double max_steps)
  {
//--- calculate an initial guess at m_step size
   double temp=range/max_steps;
//--- get the magnitude of the m_step size
   double mag=MathFloor(MathLog10(temp));
   double magPow=MathPow((double) 10.0,mag);
//--- calculate most significant digit of the new m_step size
   double magMsd=MathCeil(temp/magPow);
//--- promote the MSD to either 1, 2, or 5
   if(magMsd>5.0)
      magMsd=10.0;
   else
   if(magMsd>2.0)
      magMsd=5.0;
   else
   if(magMsd>1.0)
      magMsd=2.0;
//--- return step
   return(magMsd * magPow);
  }
//+------------------------------------------------------------------+
