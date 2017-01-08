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
#include <Math\Fuzzy\mamdanifuzzysystem.mqh>
//+------------------------------------------------------------------+
//| Test_Bisector()                                                  |
//+------------------------------------------------------------------+
void Test_Bisector()
  {
   PrintFormat("%s",__FUNCTION__);
   bool result=true;
   double delta=1e-10;
   CMamdaniFuzzySystem system();
   system.DefuzzificationMethod(BisectorDef);
   CTriangularMembershipFunction *function=new CTriangularMembershipFunction(0,5,5);
   double actual=system.Defuzzify(function,0,5);
   double expected=3.5;
   if(MathAbs(actual-expected)>=delta)
     {
      Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
      result=false;
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
//| Test_Centroid()                                                  |
//+------------------------------------------------------------------+
void Test_Centroid()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-1;
   CMamdaniFuzzySystem system();
   system.DefuzzificationMethod(CentroidDef);
   double mean[]={-5,-3,-1,1,3,5};
   double sigma[]={1,2};
   for(int i=0; i<ArraySize(mean); i++)
     {
      for(int j=0; j<ArraySize(sigma); j++)
        {
         CNormalMembershipFunction *function=new CNormalMembershipFunction(mean[i],sigma[j]);
         double actual=system.Defuzzify(function,-10,10);
         double expected=mean[i];
         if(MathAbs(actual-expected)>=delta)
           {
            Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
            result=false;
           }
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
//| Test_Defuzzification()                                           |
//+------------------------------------------------------------------+
void Test_Defuzzification()
  {
   PrintFormat("\n %s",__FUNCTION__);
   bool result=true;
   double delta=1e-12;
   CMamdaniFuzzySystem system();
   double actual=0.0;
   double expected=0.0;
//---  
   system.DefuzzificationMethod(CentroidDef);
   actual=system.Defuzzify(new CNormalMembershipFunction(0,2),-10,10);
   if(MathAbs(actual-expected)>=delta)
     {
      Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
      result=false;
     }
//---
   system.DefuzzificationMethod(BisectorDef);
   actual=system.Defuzzify(new CNormalMembershipFunction(0,2),-10,10);
   if(MathAbs(actual-expected)>=delta)
     {
      Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
      result=false;
     }
//---
   system.DefuzzificationMethod(AverageMaximumDef);
   actual=system.Defuzzify(new CNormalMembershipFunction(0,2),-10,10);
   if(MathAbs(actual-expected)>=delta)
     {
      Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
      result=false;
     }
//---
   system.DefuzzificationMethod(SmallestMaximumDef);
   actual=system.Defuzzify(new CNormalMembershipFunction(0,2),-10,10);
   if(MathAbs(actual-expected)>=delta)
     {
      Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
      result=false;
     }
//---
   system.DefuzzificationMethod(LargestMaximumDef);
   actual=system.Defuzzify(new CNormalMembershipFunction(0,2),-10,10);
   if(MathAbs(actual-expected)>=delta)
     {
      Print("Expected: ",expected," +/- ",delta," ; But was: ",actual);
      result=false;
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
   Test_Bisector();
   Test_Centroid();
   Test_Defuzzification();
  }
//+------------------------------------------------------------------+
