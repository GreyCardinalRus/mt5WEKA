//+------------------------------------------------------------------+
//|                                                       fuzzyt.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//| Implementation of Fuzzy library in MetaQuotes Language 5(MQL5)   |
//|                                                                  |
//| The features of the FuzzyNet library include:                    |
//| - Create Mamdani fuzzy model                                     |
//| - Create Sugeno fuzzy model                                      |
//| - Normal membership function                                     |
//| - Triangular membership function                                 |
//| - Trapezoidal membership function                                |
//| - Constant membership function                                   |
//| - Defuzzification method of center of gravity (COG)              |
//| - Defuzzification method of bisector of area (BOA)               |
//| - Defuzzification method of mean of maxima (MeOM)                |
//|                                                                  |
//| If you find any functional differences between Fuzzy for MQL5 and|
//| the original Fuzzy for .Net project , please contact developers  |
//| of MQL5 on the Forum at www.mql5.com.                            |
//|                                                                  |
//| You can report bugs found in the computational algorithms of the |
//| Fuzzy library by notifying the project coordinators              |
//+------------------------------------------------------------------+
//|                         SOURCE LICENSE                           |
//|                                                                  |
//| This program is free software; you can redistribute it and/or    |
//| modify it under the terms of the GNU General Public License as   |
//| published by the Free Software Foundation (www.fsf.org); either  |
//| version 2 of the License, or (at your option) any later version. |
//|                                                                  |
//| This program is distributed in the hope that it will be useful,  |
//| but WITHOUT ANY WARRANTY; without even the implied warranty of   |
//| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the     |
//| GNU General Public License for more details.                     |
//|                                                                  |
//| A copy of the GNU General Public License is available at         |
//| http://www.fsf.org/licensing/licenses                            |
//+------------------------------------------------------------------+
#include <Math\Fuzzy\membershipfunction.mqh>
//+------------------------------------------------------------------+
//| Test_NormalCombinationMembershipFunction()                       |
//+------------------------------------------------------------------+
void Test_NormalCombinationMembershipFunction()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-20;
   double x[]={-4.0,5.1,0.1};
   double b1=1.2;
   double sigma1=0.45;
   double b2=3.1;
   double sigma2=0.9;
   CNormalCombinationMembershipFunction function(b1,sigma1,b2,sigma2);
   for(int i=0; i<ArraySize(x); i++)
     {
      double actual=function.GetValue(x[i]);
      double expected=0.0;
      if(x[i]<1.2)
        {
         expected=MathExp(MathPow(x[i]-b1,2)/(-2.0*MathPow(0.45,2)));
        }
      else if(x[i]>3.1)
        {
         expected=MathExp(MathPow(x[i]-b2,2)/(-2.0*MathPow(0.9,2)));
        }
      if(MathAbs(actual-expected)>1e-20)
        {
         Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
         result=false;
        }
     }
   if(result)
     {
      Print("Success.");
     }
   else
     {
      Print("Failed.");
     }
  }
//+------------------------------------------------------------------+
//| Test_GeneralizedBellShapedMembershipFunction()                   |
//+------------------------------------------------------------------+
void Test_GeneralizedBellShapedMembershipFunction()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-20;
   double x[]={-4,5.1,0.1};
   double a = 2.4;
   double b = 0.9;
   double c = 1.33;
   CGeneralizedBellShapedMembershipFunction function(a,b,c);
   for(int i=0; i<ArraySize(x); i++)
     {
      double actual=function.GetValue(x[i]);
      double expected=1/(1+MathPow(MathAbs((x[i]-a)/c),2*b));
      if(actual!=expected)
        {
         Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
         result=false;
        }
     }
   if(result)
     {
      Print("Success.");
     }
   else
     {
      Print("Failed.");
     }
  }
//+------------------------------------------------------------------+
//| Test_SigmoidalMembershipFunction()                               |
//+------------------------------------------------------------------+
void Test_SigmoidalMembershipFunction()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-20;
   double x[]={-4,4.1,0.1};
   double a = 1.75;
   double c = -M_PI/2;
   CSigmoidalMembershipFunction function(a,c);
   for(int i=0; i<ArraySize(x); i++)
     {
      double actual=function.GetValue(x[i]);
      double expected=1/(1.0+MathExp(-a *(x[i]-c)));
      if(actual!=expected)
        {
         Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
         result=false;
        }
     }
   if(result)
     {
      Print("Success.");
     }
   else
     {
      Print("Failed.");
     }
  }
//+------------------------------------------------------------------+
//| Test_ProductTwoSigmoidalMembershipFunctions()                    |
//+------------------------------------------------------------------+
void Test_ProductTwoSigmoidalMembershipFunctions()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-20;
   double x[]={-4.0,4.1,0.1};
   double a1 = -1.75;
   double c1 = -M_PI/2.0;
   double a2 = 0.972;
   double c2 = 0.43;
   CProductTwoSigmoidalMembershipFunctions function(a1,c1,a2,c2);
   for(int i=0; i<ArraySize(x); i++)
     {
      double actual=function.GetValue(x[i]);
      double expected=((1.0/(1.0+MathExp(-a1 *(x[i]-c1)))) *
                       (1.0/(1.0+MathExp(-a2 *(x[i]-c2)))));
      if(actual!=expected)
        {
         Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
         result=false;
        }
     }
   if(result)
     {
      Print("Success.");
     }
   else
     {
      Print("Failed.");
     }
  }
//+------------------------------------------------------------------+
//| Test_TrapezoidMembershipFunction()                               |
//+------------------------------------------------------------------+
void Test_TrapezoidMembershipFunction()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-20;
   double x[]={-4,3.1,0.1};
   double x1 = -4;
   double x2 = -4;
   double x3 = 2;
   double x4 = M_PI;
   CTrapezoidMembershipFunction function(x1,x2,x3,x4);
   for(int i=0; i<ArraySize(x); i++)
     {
      double actual=function.GetValue(x[i]);
      double expected=1.0;
      if(x[i]>2 && x[i]<M_PI)
        {
         expected=(-x[i]/(x4-x3))+(x4/(x4-x3));
        }
      else if(x[i]>M_PI)
        {
         expected=0;
        }
      if(actual!=expected)
        {
         Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
         result=false;
        }
     }
   if(result)
     {
      Print("Success.");
     }
   else
     {
      Print("Failed.");
     }
  }
//+------------------------------------------------------------------+
//| Test_NormalMembershipFunction()                                  |
//+------------------------------------------------------------------+
void Test_NormalMembershipFunction()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-20;
   double x[]={-4,5.1,0.1};
   double b=1.33;
   double sigma=0.45;
   CNormalMembershipFunction function(b,sigma);
   for(int i=0; i<ArraySize(x); i++)
     {
      double actual=function.GetValue(x[i]);
      double expected=MathExp(MathPow(x[i]-1.33,2.0)/(-2.0 * MathPow(0.45,2.0)));
      if(actual!=expected)
        {
         Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
         result=false;
        }
     }
   if(result)
     {
      Print("Success.");
     }
   else
     {
      Print("Failed.");
     }
  }
//+------------------------------------------------------------------+
//| Test_TriangularMembershipFunction()                              |
//+------------------------------------------------------------------+
void Test_TriangularMembershipFunction()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-20;
   double x[]={-4,4.1,0.1};
   double x1 = -M_PI;
   double x2 = -M_E/2.0;
   double x3 = M_PI/5.0;
   CTriangularMembershipFunction function(x1,x2,x3);
   for(int i=0; i<ArraySize(x); i++)
     {
      double actual=function.GetValue(x[i]);
      double expected=0;
      if(x[i]==x2)
        {
         expected=1;
        }
      else if(x[i]>x1 && x[i]<x2)
        {
         expected=(x[i]/(x2-x1)) -(x1/(x2-x1));
        }
      else if(x[i]>x2 && x[i]<x3)
        {
         expected=(-x[i]/(x3-x2))+(x3/(x3-x2));
        }
      if(actual!=expected)
        {
         Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
         result=false;
        }
     }
   if(result)
     {
      Print("Success.");
     }
   else
     {
      Print("Failed.");
     }
  }
//+------------------------------------------------------------------+
//| Test_ConstantMembershipFunction()                                |
//+------------------------------------------------------------------+
void Test_ConstantMembershipFunction()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-20;
   double x[]={-4,4.1,0.1};
   double value=1.0;
   CConstantMembershipFunction function(1.0);
   for(int i=0; i<ArraySize(x); i++)
     {
      double actual=function.GetValue(x[i]);
      double expected=value;
      if(actual!=expected)
        {
         Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
         result=false;
        }
     }
   if(result)
     {
      Print("Success.");
     }
   else
     {
      Print("Failed.");
     }
  }
//+------------------------------------------------------------------+
//| Test_P_S_Z_ShapedMembershipFunction()                            |
//+------------------------------------------------------------------+
void Test_P_S_Z_ShapedMembershipFunction()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-20;
   double x[]={-4.0,4.1,0.1};
   CZ_ShapedMembershipFunction zfunction(MathExp(1.0),M_PI);
   CS_ShapedMembershipFunction sfunction(-1.0/137.0,M_PI/2.0);
   CP_ShapedMembershipFunction pfunction(MathExp(1.0),M_PI,-1.0/137.0,M_PI/2.0);
   for(int i=0; i<ArraySize(x); i++)
     {
      double actual=pfunction.GetValue(x[i]);
      double expected=zfunction.GetValue(x[i])*sfunction.GetValue(x[i]);
      if(actual!=expected)
        {
         Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
         result=false;
        }
     }
   if(result)
     {
      Print("Success.");
     }
   else
     {
      Print("Failed.");
     }
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Test_NormalCombinationMembershipFunction();
   Test_GeneralizedBellShapedMembershipFunction();
   Test_SigmoidalMembershipFunction();
   Test_ProductTwoSigmoidalMembershipFunctions();
   Test_TrapezoidMembershipFunction();
   Test_NormalMembershipFunction();
   Test_TriangularMembershipFunction();
   Test_ConstantMembershipFunction();
   Test_P_S_Z_ShapedMembershipFunction();
  }
//+------------------------------------------------------------------+
