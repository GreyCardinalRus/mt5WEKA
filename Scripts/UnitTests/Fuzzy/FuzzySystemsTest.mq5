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
#include <Math\Fuzzy\MamdaniFuzzySystem.mqh>
#include <Math\Fuzzy\SugenoFuzzySystem.mqh>
//+------------------------------------------------------------------+
//| Test_TipingProblem()                                             |
//+------------------------------------------------------------------+
void Test_TipingProblem()
  {
   PrintFormat(" %s",__FUNCTION__);
//--- Mamdani Fuzzy System  
   CMamdaniFuzzySystem *fsTips=new CMamdaniFuzzySystem();
//--- Create first input variables for the system
   CFuzzyVariable *fvService=new CFuzzyVariable("service",0.0,10.0);
   fvService.Terms().Add(new CFuzzyTerm("poor", new CTriangularMembershipFunction(-5.0, 0.0, 5.0)));
   fvService.Terms().Add(new CFuzzyTerm("good", new CTriangularMembershipFunction(0.0, 5.0, 10.0)));
   fvService.Terms().Add(new CFuzzyTerm("excellent", new CTriangularMembershipFunction(5.0, 10.0, 15.0)));
   fsTips.Input().Add(fvService);
//--- Create second input variables for the system
   CFuzzyVariable *fvFood=new CFuzzyVariable("food",0.0,10.0);
   fvFood.Terms().Add(new CFuzzyTerm("rancid", new CTrapezoidMembershipFunction(0.0, 0.0, 1.0, 3.0)));
   fvFood.Terms().Add(new CFuzzyTerm("delicious", new CTrapezoidMembershipFunction(7.0, 9.0, 10.0, 10.0)));
   fsTips.Input().Add(fvFood);
//--- Create Output
   CFuzzyVariable *fvTips=new CFuzzyVariable("tips",0.0,30.0);
   fvTips.Terms().Add(new CFuzzyTerm("cheap", new CTriangularMembershipFunction(0.0, 5.0, 10.0)));
   fvTips.Terms().Add(new CFuzzyTerm("average", new CTriangularMembershipFunction(10.0, 15.0, 20.0)));
   fvTips.Terms().Add(new CFuzzyTerm("generous", new CTriangularMembershipFunction(20.0, 25.0, 30.0)));
   fsTips.Output().Add(fvTips);
//--- Create three Mamdani fuzzy rule
   CMamdaniFuzzyRule *rule1 = fsTips.ParseRule("if (service is poor )  or (food is rancid) then tips is cheap");
   CMamdaniFuzzyRule *rule2 = fsTips.ParseRule("if ((service is good)) then tips is average");
   CMamdaniFuzzyRule *rule3 = fsTips.ParseRule("if (service is excellent) or (food is delicious) then (tips is generous)");
//--- Add three Mamdani fuzzy rule in system
   fsTips.Rules().Add(rule1);
   fsTips.Rules().Add(rule2);
   fsTips.Rules().Add(rule3);
//--- Set input value
   CList *in=new CList;
   CDictionary_Obj_Double *p_od_Service=new CDictionary_Obj_Double;
   CDictionary_Obj_Double *p_od_Food=new CDictionary_Obj_Double;
//--- Testing values
   double Food=6.5;
   double Service=9.8;
   double expected=24.3;
   p_od_Service.SetAll(fvService,Service);
   p_od_Food.SetAll(fvFood,Food);
   in.Add(p_od_Service);
   in.Add(p_od_Food);
//--- Get result
   CList *result;
   CDictionary_Obj_Double *p_od_Tips;
   result=fsTips.Calculate(in);
   p_od_Tips=result.GetNodeAtIndex(0);
   double actual=NormalizeDouble(p_od_Tips.Value(),1);
   delete in;
   delete result;
   delete fsTips;
   if(expected!=actual)
     {
      Print("Expected: ",expected," ; But was: ",actual);
      Print("Failed.");
     }
   else
     {
      Print("Success.");
     }
  }
//+------------------------------------------------------------------+
//| Test_TypicalFuzzyControlSystem()                                 |
//+------------------------------------------------------------------+
void Test_TypicalFuzzyControlSystem()
  {
   PrintFormat("\n %s",__FUNCTION__);
//--- Sugeno Fuzzy System  
   CSugenoFuzzySystem *fsCruiseControl=new CSugenoFuzzySystem();
//--- Create first input variables for the system
   CFuzzyVariable *fvSpeedError=new CFuzzyVariable("SpeedError",-20.0,20.0);
   fvSpeedError.Terms().Add(new CFuzzyTerm("slower",new CTriangularMembershipFunction(-35.0,-20.0,-5.0)));
   fvSpeedError.Terms().Add(new CFuzzyTerm("zero", new CTriangularMembershipFunction(-15.0, -0.0, 15.0)));
   fvSpeedError.Terms().Add(new CFuzzyTerm("faster", new CTriangularMembershipFunction(5.0, 20.0, 35.0)));
   fsCruiseControl.Input().Add(fvSpeedError);
//--- Create second input variables for the system
   CFuzzyVariable *fvSpeedErrorDot=new CFuzzyVariable("SpeedErrorDot",-5.0,5.0);
   fvSpeedErrorDot.Terms().Add(new CFuzzyTerm("slower", new CTriangularMembershipFunction(-9.0, -5.0, -1.0)));
   fvSpeedErrorDot.Terms().Add(new CFuzzyTerm("zero", new CTriangularMembershipFunction(-4.0, -0.0, 4.0)));
   fvSpeedErrorDot.Terms().Add(new CFuzzyTerm("faster", new CTriangularMembershipFunction(1.0, 5.0, 9.0)));
   fsCruiseControl.Input().Add(fvSpeedErrorDot);
//--- Create Output
   CSugenoVariable *svAccelerate=new CSugenoVariable("Accelerate");
   double coeff1[3]={0.0,0.0,0.0};
   svAccelerate.Functions().Add(fsCruiseControl.CreateSugenoFunction("zero",coeff1));
   double coeff2[3]={0.0,0.0,1.0};
   svAccelerate.Functions().Add(fsCruiseControl.CreateSugenoFunction("faster",coeff2));
   double coeff3[3]={0.0,0.0,-1.0};
   svAccelerate.Functions().Add(fsCruiseControl.CreateSugenoFunction("slower",coeff3));
   double coeff4[3]={-0.04,-0.1,0.0};
   svAccelerate.Functions().Add(fsCruiseControl.CreateSugenoFunction("func",coeff4));
   fsCruiseControl.Output().Add(svAccelerate);
//--- Craete Sugeno fuzzy rules
   AddSugenoFuzzyRule(fsCruiseControl,fvSpeedError,fvSpeedErrorDot,svAccelerate,"slower","slower","faster");
   AddSugenoFuzzyRule(fsCruiseControl,fvSpeedError,fvSpeedErrorDot,svAccelerate,"slower","zero","faster");
   AddSugenoFuzzyRule(fsCruiseControl,fvSpeedError,fvSpeedErrorDot,svAccelerate,"slower","faster","zero");
   AddSugenoFuzzyRule(fsCruiseControl,fvSpeedError,fvSpeedErrorDot,svAccelerate,"zero","slower","faster");
   AddSugenoFuzzyRule(fsCruiseControl,fvSpeedError,fvSpeedErrorDot,svAccelerate,"zero","zero","func");
   AddSugenoFuzzyRule(fsCruiseControl,fvSpeedError,fvSpeedErrorDot,svAccelerate,"zero","faster","slower");
   AddSugenoFuzzyRule(fsCruiseControl,fvSpeedError,fvSpeedErrorDot,svAccelerate,"faster","slower","zero");
   AddSugenoFuzzyRule(fsCruiseControl,fvSpeedError,fvSpeedErrorDot,svAccelerate,"faster","zero","slower");
   AddSugenoFuzzyRule(fsCruiseControl,fvSpeedError,fvSpeedErrorDot,svAccelerate,"faster","faster","slower");
//--- Set input value and get result
   CList *in=new CList;
   CDictionary_Obj_Double *p_od_Error=new CDictionary_Obj_Double;
   CDictionary_Obj_Double *p_od_ErrorDot=new CDictionary_Obj_Double;
   double Speed_Error=18.3;
   double Speed_ErrorDot=-3.5;
   double expected=-16.7;
   p_od_Error.SetAll(fvSpeedError,Speed_Error);
   p_od_ErrorDot.SetAll(fvSpeedErrorDot,Speed_ErrorDot);
   in.Add(p_od_Error);
   in.Add(p_od_ErrorDot);
//--- Get result
   CList *result;
   CDictionary_Obj_Double *p_od_Accelerate;
   result=fsCruiseControl.Calculate(in);
   p_od_Accelerate=result.GetNodeAtIndex(0);
   double actual=NormalizeDouble(p_od_Accelerate.Value()*100,1);
   delete in;
   delete result;
   delete fsCruiseControl;
   if(expected!=actual)
     {
      Print("Expected: ",expected," ; But was: ",actual);
      Print("Failed.");
     }
   else
     {
      Print("Success.");
     }
  }
//+------------------------------------------------------------------+
//| AddSugenoFuzzyRule()                                             |
//+------------------------------------------------------------------+
void AddSugenoFuzzyRule(CSugenoFuzzySystem *fs,CFuzzyVariable *fv1,CFuzzyVariable *fv2,CSugenoVariable *sv,
                        const string value1,const string value2,const string result)
  {
   CSugenoFuzzyRule *rule=fs.EmptyRule();
   rule.Condition().Op(OperatorType::And);
   rule.Condition().ConditionsList().Add(rule.CreateCondition(fv1, fv1.GetTermByName(value1)));
   rule.Condition().ConditionsList().Add(rule.CreateCondition(fv2, fv2.GetTermByName(value2)));
   rule.Conclusion().Var(sv);
   INamedValue *sf=sv.GetFuncByName(result);
   rule.Conclusion().Term(sf);
   fs.Rules().Add(rule);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Test_TipingProblem();
   Test_TypicalFuzzyControlSystem();
  }
//+------------------------------------------------------------------+
