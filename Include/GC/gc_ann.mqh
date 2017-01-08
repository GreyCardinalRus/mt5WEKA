//+------------------------------------------------------------------+
//|                                                       gc_ann.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//--- используем связные списки из стандартной библиотеки MQL5
#include <Arrays\List.mqh>
//#include <GC\IniFile.mqh>
#include <GC\GetVectors.mqh>
#include <GC\Oracle.mqh>
//--- идентификаторы типов данных для определяемых классов
#define TYPE_CUSTOM_NEURON 0xF001
#define TYPE_GNG_NEURON 0xF002
#define TYPE_GNG_CONNECTION 0xF003
//+------------------------------------------------------------------+
//| базовый класс для представления объектов-нейронов                |
//+------------------------------------------------------------------+
class CCustomNeuron:public CObject
  {
protected:
   int               m_synapses;
   double            m_weights[];
public:
   double            NET;
                     CCustomNeuron();
   void              Init(int synapses);
   int               Synapses();
   void              Init(double &weights[]);
   void              Weights(double &weights[]);
   void              AdaptWeights(double &delta[]);
   virtual void      ProcessVector(double &in[]) {return;}
   virtual int       Type() const          { return(TYPE_CUSTOM_NEURON);}
  };
//+------------------------------------------------------------------+
//| конструктор                                                      |
//+------------------------------------------------------------------+
void CCustomNeuron::CCustomNeuron()
  {
   m_synapses=0;
   NET=0;
  }
//+------------------------------------------------------------------+
//| возвращает размерность входного вектора нейрона    		     |
//| INPUT: нет   						     |
//| OUTPUT: количество "синапсов" нейрона                            |
//+------------------------------------------------------------------+
int CCustomNeuron::Synapses()
  {
   return m_synapses;
  }
//+------------------------------------------------------------------+
//| инициализация нейрона нулевым вектором весов.                    |
//| INPUT: synapses - количество синапсов (входных весов)	     |
//| OUTPUT: нет                                                      |
//+------------------------------------------------------------------+
void CCustomNeuron::Init(int synapses)
  {
   if(synapses<1) return;
   m_synapses=synapses;
   ArrayResize(m_weights,m_synapses);
   ArrayInitialize(m_weights,0);
   NET=0;
  }
//+------------------------------------------------------------------+
//| инициализация весов нейрона заданным вектором.                   |
//| INPUT: weights - вектор данных                                   |
//| OUTPUT: нет                                                      |
//+------------------------------------------------------------------+
void CCustomNeuron::Init(double &weights[])
  {
   if(ArraySize(weights)<1) return;
   m_synapses=ArraySize(weights);
   ArrayResize(m_weights,m_synapses);
   ArrayCopy(m_weights,weights);
   NET=0;
  }
//+------------------------------------------------------------------+
//| получение вектора весов нейрона.                                 |
//| INPUT: нет                                                       |
//| OUTPUT: weights - результат		                             |                        
//+------------------------------------------------------------------+
void CCustomNeuron::Weights(double &weights[])
  {
   ArrayResize(weights,m_synapses);
   ArrayCopy(weights,m_weights);
  }
//+------------------------------------------------------------------+
//| изменить веса нейрона на заданную величину                       |
//| INPUT: delta - корректирующий вектор			     |
//| OUTPUT: нет                                                      |
//+------------------------------------------------------------------+
void CCustomNeuron::AdaptWeights(double &delta[])
  {
   if(ArraySize(delta)!=m_synapses) return;
   for(int i=0;i<m_synapses;i++) m_weights[i]+=delta[i];
   NET=0;
  }
//+------------------------------------------------------------------+
//| отдельный нейрон РНГ-сети                   		     |
//+------------------------------------------------------------------+
class CGCANNNeuron:public CCustomNeuron
  {
public:
   int               uid;
   int               cnt;
   double            Stat;
   double            E;
   double            U;
   double            error;
                     CGCANNNeuron();
   virtual void      ProcessVector(double &in[]);
  };
//+------------------------------------------------------------------+
//| конструктор                                                      |
//+------------------------------------------------------------------+
CGCANNNeuron::CGCANNNeuron()
  {
   E=0;
   U=0;
   error=0;
   cnt=0;
   Stat=0;
  }
//+------------------------------------------------------------------+
//| рассчитывается "расстояние" от нейрона до входного вектора       |
//| INPUT: in - вектор данных                                        |
//| OUTPUT: нет                                                      |
//| REMARK: в переменную error помещается текущее "расстояние",      |
//|         "локальная ошибка" содержится в другой переменной,       |
//|         которая называется E                                                     
//+------------------------------------------------------------------+
void CGCANNNeuron::ProcessVector(double &in[])
  {
   if(ArraySize(in)!=m_synapses) return;

   error=0;
   NET=0;
   for(int i=0;i<m_synapses;i++)
     {
      error+=(in[i]-m_weights[i])*(in[i]-m_weights[i]);
     }
  }
//+------------------------------------------------------------------+
//| класс, определяющий соединение(связь) между двумя нейронами      |
//+------------------------------------------------------------------+
class CGCANNConnection:public CObject
  {
public:
   int               uid1;
   int               uid2;
   int               age;
                     CGCANNConnection();
                    ~CGCANNConnection();
   virtual int       Type() const          { return(TYPE_GNG_CONNECTION);}
  };
//+------------------------------------------------------------------+
//| конструктор                                                      |
//+------------------------------------------------------------------+
CGCANNConnection::CGCANNConnection()
  {
   age=0;
//Print("N+");  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CGCANNConnection::~CGCANNConnection()
  {
//Print("N-");  
  }
//+------------------------------------------------------------------+
//| связный список нейронов                                          |
//+------------------------------------------------------------------+
class CGCANNNeuronList:public CList
  {
public:
   //--- конструктор   
                     CGCANNNeuronList() {MathSrand((int)TimeLocal());}
   CGCANNNeuron     *Append();
   void              Init(double &v1[],double &v2[]);
   CGCANNNeuron     *Find(int uid);
   void              FindWinners(CGCANNNeuron *&Winner,CGCANNNeuron *&SecondWinner);
  };
//+------------------------------------------------------------------+
//| добавляет  "пустой" нейрон в конец списка                        |
//| INPUT: нет                                                       |
//| OUTPUT: указатель на новый нейрон                                |
//+------------------------------------------------------------------+
CGCANNNeuron *CGCANNNeuronList::Append()
  {
   if(m_first_node==NULL)
     {
      m_first_node= new CGCANNNeuron;
      m_last_node = m_first_node;
     }
   else
     {
      GetLastNode();
      m_last_node=new CGCANNNeuron;
      m_curr_node.Next(m_last_node);
      m_last_node.Prev(m_curr_node);
     }
   m_curr_node=m_last_node;
   m_curr_idx=m_data_total++;

   while(true)
     {
      int rnd=MathRand();
      if(!CheckPointer(Find(rnd)))
        {
         ((CGCANNNeuron *)m_curr_node).uid=rnd;
         break;
        }
     }
//---
   return(m_curr_node);
  }
//+------------------------------------------------------------------+
//| инициализация списка путем создания двух нейронов, заданных      |
//| векторами весов                                                  |
//| INPUT: v1,v2 - векторы весов                                     |
//| OUTPUT: нет                                                      |
//+------------------------------------------------------------------+
void CGCANNNeuronList::Init(double &v1[],double &v2[])
  {
   Clear();
   Append();
   ((CGCANNNeuron *)m_curr_node).Init(v1);
   Append();
   ((CGCANNNeuron *)m_curr_node).Init(v2);
  }
//+------------------------------------------------------------------+
//| поиск нейрона по uid                                             |
//| INPUT: uid - уникальный идентификатор нейрона                    |
//| OUTPUT: указатель на нейрон в случае удачи, NULL в противном     |
//+------------------------------------------------------------------+
CGCANNNeuron *CGCANNNeuronList::Find(int uid)
  {
   if(NULL==GetFirstNode()) return(NULL);
   do
     {
      if(((CGCANNNeuron *)m_curr_node).uid==uid)
         return(m_curr_node);
     }
   while(CheckPointer(GetNextNode()));
   return(NULL);
  }
//+------------------------------------------------------------------+
//| поиск двух "лучших" нейронов в мсмысле минимальной текущей ошибки|
//| INPUT: нет                                                       |
//| OUTPUT: Winner - нейрон, "ближайший" к входному вектору          |
//|         SecondWinner - второй "ближайший" нейрон                 |
//+------------------------------------------------------------------+
void CGCANNNeuronList::FindWinners(CGCANNNeuron *&Winner,CGCANNNeuron *&SecondWinner)
  {
   double err_min=0;
   Winner=NULL;
   if(!CheckPointer(GetFirstNode())) return;
   do
     {
      if(!CheckPointer(Winner) || ((CGCANNNeuron *)m_curr_node).error<err_min)
        {
         err_min= ((CGCANNNeuron *)m_curr_node).error;
         Winner = m_curr_node;
        }
     }
   while(CheckPointer(GetNextNode()));

   err_min=0;
   SecondWinner=NULL;
   GetFirstNode();
   do
     {
      if(m_curr_node!=Winner)
         if(!CheckPointer(SecondWinner) || ((CGCANNNeuron *)m_curr_node).error<err_min)
           {
            err_min=((CGCANNNeuron *)m_curr_node).error;
            SecondWinner=m_curr_node;
           }
     }
   while(CheckPointer(GetNextNode()));
   m_curr_node=Winner;
  }
//+------------------------------------------------------------------+
//| связный список соединений между нейронами                        |
//+------------------------------------------------------------------+
class CGCANNConnectionList:public CList
  {
public:
   CGCANNConnection *Append();
   void              Init(int uid1,int uid2);
   CGCANNConnection *Find(int uid1,int uid2);
   CGCANNConnection *FindFirstConnection(int uid);
   CGCANNConnection *FindNextConnection(int uid);
  };
//+------------------------------------------------------------------+
//| добавляет "пустое" соединение в конец списка                     |
//| INPUT: нет                                                       |
//| OUTPUT: указатель на новую связь                                 |
//+------------------------------------------------------------------+
CGCANNConnection *CGCANNConnectionList::Append()
  {
   if(m_first_node==NULL)
     {
      m_first_node= new CGCANNConnection;
      m_last_node = m_first_node;
     }
   else
     {
      GetLastNode();
      m_last_node=new CGCANNConnection;
      m_curr_node.Next(m_last_node);
      m_last_node.Prev(m_curr_node);
     }
   m_curr_node=m_last_node;
   m_curr_idx=m_data_total++;
//---
   return(m_curr_node);
  }
//+------------------------------------------------------------------+
//| инициализация списка путем создания одного соединения            |
//| INPUT: uid1,uid2 - идентификаторы нейронов для соединения        |
//| OUTPUT: нет                                                      |
//+------------------------------------------------------------------+
void CGCANNConnectionList::Init(int uid1,int uid2)
  {
   Append();
   ((CGCANNConnection *)m_first_node).uid1 = uid1;
   ((CGCANNConnection *)m_first_node).uid2 = uid2;
   m_last_node = m_first_node;
   m_curr_node = m_first_node;
   m_curr_idx=0;
  }
//+------------------------------------------------------------------+
//| проверка наличия связи между заданными нейронами                 |
//| INPUT: uid1,uid2 - идентификаторы нейронов                       |
//| OUTPUT: указатель на соединение в случае его наличия, или NULL   |
//+------------------------------------------------------------------+
CGCANNConnection *CGCANNConnectionList::Find(int uid1,int uid2)
  {
   if(!CheckPointer(GetFirstNode())) return(NULL);
   do
     {
      if((((CGCANNConnection *)m_curr_node).uid1==uid1 && ((CGCANNConnection *)m_curr_node).uid2==uid2)
         || (((CGCANNConnection *)m_curr_node).uid1==uid2 && ((CGCANNConnection *)m_curr_node).uid2==uid1))
         return(m_curr_node);
     }
   while(CheckPointer(GetNextNode()));
   return(NULL);
  }
//+------------------------------------------------------------------+
//| поиск первого топологического соседа заданного нейрона, начиная  |
//| с первого элемента списка                                        |
//| INPUT: uid - идентификатор нейрона                               |
//| OUTPUT: указатель на соединение в случае его наличия, или NULL   |
//+------------------------------------------------------------------+
CGCANNConnection *CGCANNConnectionList::FindFirstConnection(int uid)
  {
   if(!CheckPointer(GetFirstNode())) return(NULL);
   while(true)
     {
      if(((CGCANNConnection *)m_curr_node).uid1==uid || ((CGCANNConnection *)m_curr_node).uid2==uid) break;
      if(!CheckPointer(GetNextNode())) return(NULL);
     }
   return(m_curr_node);
  }
//+------------------------------------------------------------------+
//| поиск первого топологического соседа заданного нейрона, начиная  |
//| с элемента списка, следующего за текущим                         |
//| INPUT: uid - идентификатор нейрона                               |
//| OUTPUT: указатель на соединение в случае его наличия, или NULL   |
//+------------------------------------------------------------------+
CGCANNConnection   *CGCANNConnectionList::FindNextConnection(int uid)
  {
   if(!CheckPointer(GetCurrentNode())) return(NULL);
   while(true)
     {
      if(!CheckPointer(GetNextNode())) return(NULL);
      if(((CGCANNConnection *)m_curr_node).uid1==uid || ((CGCANNConnection *)m_curr_node).uid2==uid) break;
     }
   return(m_curr_node);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| основной класс, представляющий собственно алгоритм РНГ           |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGCANN:public COracleANN
  {
public:
   //--- связные списки объектов-нейронов и связей между ними
   CGCANNNeuronList *Neurons;
   CGCANNConnectionList *Connections;
   //--- параметры алгоритма
   bool              ClearTraning;
   string            Functions_Array[10];
   int               Functions_Count[10];
   int               Max_Functions;
   int               iteration_number;
   int               lambda;
   int               age_max;
   double            alpha;
   double            beta;
   double            eps_w;
   double            eps_n;
   int               max_nodes;
   double            max_E;
   double            maximun_E;
   double            average_E;
   double            koeff;

                     CGCANN();
                    ~CGCANN();
   virtual bool      Draw(int window,datetime &time[],int w,int h);
   virtual void      Init(int __input_dimension,
                          int __lambda,
                          int __age_max,
                          double __alpha,
                          double __beta,
                          double __eps_w,
                          double __eps_n,
                          int __max_nodes,
                          double __max_E,
                          double __k=1000);

   virtual bool      CustomLoad(int file_handle);
   virtual bool      CustomSave(int file_handle);
   double            forecast(string smbl,int shift,bool train);

   CGCANNNeuron     *ProcessVector(double &in[],double train=NULL);
   virtual bool      StoppingCriterion();
   virtual string    Type() const          { return("CGGNGCANN");}
   //  virtual double    forecast(int shift=0,bool train=false);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGCANN::forecast(string smbl,int shift,bool train)
  {
   if(GetVector(smbl,shift,train))
     {
      CGCANNNeuron     *r;
//      if(debug) Print("ov0= ",OutputVector[0]);
      if(train) r=ProcessVector(InputVector,OutputVector[0]);
      else r=ProcessVector(InputVector);
      //if(r.error> max_E) return(0);
      //if(debug)
      //  {
      //   string outstr="shift="+(string)shift+" ";
      //   for(int i=0;i<num_input();i++) outstr+=(string)InputVector[i]+" ";
      //   Print((string)r.uid+" error="+(string)r.error+outstr);
      //  }
      if(0==r.cnt) return(0);
      return(r.Stat/r.cnt);
     }
   else
     {
      if(debug) Print("GV ret false sft=",shift);
      return(0);
     }

  }
//+------------------------------------------------------------------+
//| конструктор                                                      |
//+------------------------------------------------------------------+
CGCANN::CGCANN(void)
  {
   Neurons=new CGCANNNeuronList();
   Connections=new CGCANNConnectionList();

   Neurons.FreeMode(true);
   Connections.FreeMode(true);
  }
//+------------------------------------------------------------------+
//| деструктор                                                       |
//+------------------------------------------------------------------+
CGCANN::~CGCANN(void)
  {
//Neurons.
   delete Neurons;
   delete Connections;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGCANN::CustomLoad(int fileid)
  {
   bool     resb=false;
   string outstr="";
   int i=0,sp,ep;

   if(fileid!=INVALID_HANDLE)
     {
      outstr=FileReadString(fileid);//   [Common]
      while(outstr!="[Neurons]")
        {
         //     if("AnnType=CGCANN"!=FileReadString(fileid)){FileClose(fileid);return(false);};//AnnType=CGCANN
         //        if(StringFind(outstr,"input_dimension")==0)input_dimension=(int)StringToInteger(StringSubstr(outstr,StringLen("input_dimension=")));
         sp=1+StringFind(outstr,"=");ep=StringFind(outstr," ",sp+1);
         if("max_E"==StringSubstr(outstr,0,sp-1)) max_E=StringToDouble(StringSubstr(outstr,sp,ep-sp));
         outstr=FileReadString(fileid);
         if(""==outstr) return(false);
        }
      if(ClearTraning) return(true);
      outstr=FileReadString(fileid);
      double weights[];  ArrayResize(weights,num_input());
      CGCANNNeuron *tmp;
      while(outstr!="")
        {
         tmp=Neurons.Append();
         sp=1+StringFind(outstr,"=");ep=StringFind(outstr," ",sp+1);
         tmp.cnt=(int)StringToInteger(StringSubstr(outstr,sp,ep-sp));
         sp=1+ep;ep=StringFind(outstr," ",sp+1);
         tmp.Stat=StringToDouble(StringSubstr(outstr,sp,ep-sp));
         sp=ep;//ep=StringLen(outstr);
         for(i=0;i<num_input();i++)
           {
            ep=StringFind(outstr," ",sp+1);
            if(-1==ep) ep=sp-1;//Print(StringSubstr(outstr,sp,ep-sp));
            weights[i]=StringToDouble(StringSubstr(outstr,sp,ep-sp));
            sp=ep;
           }
         tmp.Init(weights);
         //         Print("tmp.Stat="+tmp.Stat+" tmp.cnt="+tmp.cnt+" '"+StringSubstr(outstr,sp)+"'");
         outstr=FileReadString(fileid);
        }
      //FileClose(fileid);
      resb=true;
     }
   else resb=false;

   return(resb);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGCANN::CustomSave(int file_handle)
  {

   string outstr="";int i;
   FileWriteString(file_handle,"AnnType="+(string)Type()+"\n");
   FileWriteString(file_handle,"max_E="+(string)max_E+" // maximum error\n");
   FileWriteString(file_handle,"[Neurons]\n");
   double weights[];
   CGCANNNeuron *tmp;//,*W1,*W2;
                     //CGCANNConnection *tmpc;
   tmp=Neurons.GetFirstNode();

   while(CheckPointer(tmp))
     {
      tmp.Weights(weights);
      outstr="";
      outstr+=(string)(tmp.cnt)+" "+(string)(MathRound(tmp.Stat*1000)/1000);
      for(i=0;i<num_input();i++) outstr+=" "+(string)weights[i];
      FileWriteString(file_handle,(string)tmp.uid+"="+outstr+"\n");
      tmp=Neurons.GetNextNode();
     }

   return(true);
  }
//+------------------------------------------------------------------+
//| инициализирует алгоритм с помощью двух векторов входных данных   |
//| INPUT: v1,v2 - входные векторы                                   |
//|        __lambda - количество итераций, после которого происходит |
//|        вставка нового нейрона                                    |
//|        __age_max - максимальный возраст соединения               |
//|        __alpha, __beta - используются для адаптации ошибок       |
//|        __eps_w, __eps_n - используются для адаптации весов       |
//|        __max_nodes - ограничение размера сети                    |
//| OUTPUT: нет                                                     |
//+------------------------------------------------------------------+


bool CGCANN::StoppingCriterion()
  {
   return(false);
  }
//+------------------------------------------------------------------+
//| класс алгоритма GNG with Utility factor                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| инициализирует алгоритм с помощью двух векторов входных данных   |
//| INPUT: v1,v2 - входные векторы                                   |
//|        __lambda - количество итераций, после которого происходит |
//|        вставка нового нейрона                                    |
//|        __age_max - максимальный возраст соединения               |
//|        __alpha, __beta - используются для адаптации ошибок       |
//|        __eps_w, __eps_n - используются для адаптации весов       |
//|        __max_nodes - ограничение размера сети                    |
//|        __k - характеристика памяти для нестационарных входов     |
//| OUTPUT: нет                                                      |
//+------------------------------------------------------------------+
void CGCANN::Init(int __input_dimension,
                  //                 double &v1[],
                  //                 double &v2[],
                  int __lambda,
                  int __age_max,
                  double __alpha,
                  double __beta,
                  double __eps_w,
                  double __eps_n,
                  int __max_nodes,
                  double __max_E,
                  double __k)
  {
   iteration_number=0;
//input_dimension=__input_dimension;
   lambda=__lambda;
   age_max=__age_max;
   alpha= __alpha;
   beta = __beta;
   eps_w = __eps_w;
   eps_n = __eps_n;
   max_nodes=__max_nodes;
   max_E=__max_E;
   koeff=__k;

  }
//+------------------------------------------------------------------+
//| основная функция алгоритма                                       |
//| INPUT: in - вектор входных данных                                |
//|        train - если true, запускать обучение, в противном случае |
//|        только рассчитать выходные значения нейронов              |
//| OUTPUT: true, если выпоняется условие останова, иначе false      |
//+------------------------------------------------------------------+
CGCANNNeuron*CGCANN::ProcessVector(double &in[],double train=NULL)
  {
   if(ArraySize(in)!=num_input()) return(NULL);

   int i;

   CGCANNNeuron *tmp=Neurons.GetFirstNode();
   while(CheckPointer(tmp))
     {
      tmp.ProcessVector(in);
      tmp=Neurons.GetNextNode();
     }
   CGCANNNeuron *Winner,*SecondWinner;
   if(2>Neurons.Total())
     {
      Winner=Neurons.Append();
      Winner.Init(in);
      Winner.cnt++;
      Winner.Stat+=train;
      return(Winner);
     }
   Neurons.FindWinners(Winner,SecondWinner);

   if(train==NULL)
     {
 //     if(debug) Print("tr=null");
      return(Winner);
     }
   if(Winner.error<max_E)
     {
      Winner.cnt++;
      Winner.Stat+=train;
      double delta[],weights[];
      Winner.Weights(weights);
      ArrayResize(delta,num_input());

      for(i=0;i<num_input();i++) delta[i]=(in[i]-weights[i])/Winner.cnt;
      Winner.AdaptWeights(delta);
//      if(debug) Print(Winner.uid," ",Winner.cnt);
      //--- Обновить локальную ошибку и полезность нейрона-победителя        
      Winner.E+=Winner.error;

     }
   else
     {
//      if(debug) Print("Winner.error=",Winner.error);
      Winner=Neurons.Append();
      Winner.Init(in);
      Winner.cnt++;
      Winner.Stat+=train;

     }

//   iteration_number++;
//
////--- Найти два нейрона, ближайших к in[], т.е. узлы с векторами весов 
////--- Ws и Wt, такими, что ||Ws-in||^2 минимальное, а ||Wt-in||^2 -    
////--- второе минимальное значение расстояния среди всех узлов .        
////--- Под обозначением ||*|| понимается евклидова норма                
//
////CGCANNNeuron *Winner,*SecondWinner;
////Neurons.FindWinners(Winner,SecondWinner);
//
////--- Обновить локальную ошибку и полезность нейрона-победителя        
//
//   Winner.E+=Winner.error;
//   Winner.U+=SecondWinner.error-Winner.error;
//
////--- Сместить нейрон-победитель и всех его топологических соседей(т.е.
////--- все нейроны, имеющие соединение с победителем) в сторону входного
////--- вектора на расстояния, равные долям eps_w и eps_n от полного.    
//
//   double delta[],weights[];
//
//   Winner.Weights(weights);
//   ArrayResize(delta,input_dimension);
//
//   for(i=0;i<input_dimension;i++) delta[i]=eps_w*(in[i]-weights[i]);
//   Winner.AdaptWeights(delta);
//
////--- Увеличить на 1 возраст всех соединений, исходящих от победителя. 
//
//   CGCANNConnection *tmpc=Connections.FindFirstConnection(Winner.uid);
//   while(CheckPointer(tmpc))
//     {
//      if(tmpc.uid1==Winner.uid) tmp = Neurons.Find(tmpc.uid2);
//      if(tmpc.uid2==Winner.uid) tmp = Neurons.Find(tmpc.uid1);
//
//      if(!CheckPointer(tmp)) continue;
//      tmp.Weights(weights);
//      for(i=0;i<input_dimension;i++) delta[i]=eps_n*(in[i]-weights[i]);
//      tmp.AdaptWeights(delta);
//
//      tmpc.age++;
//
//      tmpc=Connections.FindNextConnection(Winner.uid);
//     }
//
////--- Если два лучших нейрона соединены, обнулить возраст их связи.    
////--- В противном случае создать связь между ними.                     
//
//   tmpc=Connections.Find(Winner.uid,SecondWinner.uid);
//   if(tmpc) tmpc.age=0;
//   else
//     {
//      Connections.Append();
//      tmpc=Connections.GetLastNode();
//      tmpc.uid1 = Winner.uid;
//      tmpc.uid2 = SecondWinner.uid;
//      tmpc.age=0;
//     }
//
////--- Удалить все соединения, возраст которых превышает age_max.       
////--- Если после этого у нейрона с минимальной полезностью этот        
////--- показатель более, чем в k раз меньше максимальной ошибки, 
////--- удалить этот нейрон.      
//
//   tmpc=Connections.GetFirstNode();
//   while(CheckPointer(tmpc))
//     {
//      if(tmpc.age>age_max)
//        {
//         Connections.DeleteCurrent();
//         tmpc=Connections.GetCurrentNode();
//        }
//      else tmpc=Connections.GetNextNode();
//     }
//   tmp=Neurons.GetFirstNode();
//   while(CheckPointer(tmp))
//     {
//      if(!Connections.FindFirstConnection(tmp.uid) && Neurons.Total()>2)
//        {
//         Neurons.DeleteCurrent();
//         tmp=Neurons.GetCurrentNode();
//        }
//      else tmp=Neurons.GetNextNode();
//     }
//
//   tmp=Neurons.GetFirstNode();
//   double max_error=0;
//   double min_U=0;
//   CGCANNNeuron *useless=NULL;
//
//   if(CheckPointer(tmp))
//     {
//      max_error=tmp.error;
//      min_U=tmp.U;
//      useless=tmp;
//     }
//   while(CheckPointer(tmp=Neurons.GetNextNode()))
//     {
//      if(tmp.error>max_error)
//        {
//         max_error=tmp.error;
//        }
//      if(tmp.U<min_U)
//        {
//         min_U=tmp.U;
//         useless=tmp;
//        }
//     }
//
//   if(min_U!=0 && max_error/min_U>koeff && Neurons.Total()>2)
//     {
//      Print("Delete...");
//      Neurons.Delete(Neurons.IndexOf(useless));
//     }
//
////--- Если номер текущей итерации кратен lambda, и предельный размер   
////--- сети не достигнут, создать новый нейрон r по следующим правилам  
//
//   CGCANNNeuron *u,*v;
//   if(iteration_number%lambda==0 && Neurons.Total()<max_nodes)
//     {
//
//      //--- 1.Найти нейрон u с наибольшей локальной ошибкой.               
//
//      tmp=Neurons.GetFirstNode();
//      u=tmp;
//      while(CheckPointer(tmp=Neurons.GetNextNode()))
//        {
//         if(tmp.E>u.E)
//            u=tmp;
//        }
//      if(u.E>max_E)
//        {
//         //--- 2.Среди соседей u найти узел u с наибольшей локальной ошибкой. 
//
//         tmpc=Connections.FindFirstConnection(u.uid);
//         if(tmpc.uid1==u.uid) v=Neurons.Find(tmpc.uid2);
//         else v=Neurons.Find(tmpc.uid1);
//         while(CheckPointer(tmpc=Connections.FindNextConnection(u.uid)))
//           {
//            if(tmpc.uid1==u.uid) tmp=Neurons.Find(tmpc.uid2);
//            else tmp=Neurons.Find(tmpc.uid1);
//            if(tmp.E>v.E)
//               v=tmp;
//           }
//
//         //--- 3.Создать узел r "посредине" между u и v.                      
//         //---   Вычислить его фактор полезности                              
//
//         double wr[],wu[],wv[];
//
//         u.Weights(wu);
//         v.Weights(wv);
//         ArrayResize(wr,input_dimension);
//         for(i=0;i<input_dimension;i++) wr[i]=(wu[i]+wv[i])/2;
//         // "закрутим" в гиперкуб!
//         double sq=0;
//         for(i=0;i<input_dimension;i++) sq+=wr[i]*wr[i]; sq=MathSqrt(sq); //if(0==sq) return(false);
//         for(i=0;i<input_dimension;i++) wr[i]=wr[i]/sq;
//
//         //\ 
//         CGCANNNeuron *r=Neurons.Append();
//         r.Init(wr);
//
//         r.U=(u.U+v.U)/2;
//
//         //--- 4.Заменить связь между u и v на связи между u и r, v и r       
//
//         tmpc=Connections.Append();
//         tmpc.uid1=u.uid;
//         tmpc.uid2=r.uid;
//
//         tmpc=Connections.Append();
//         tmpc.uid1=v.uid;
//         tmpc.uid2=r.uid;
//
//         Connections.Find(u.uid,v.uid);
//         Connections.DeleteCurrent();
//
//         //--- 5.Уменьшить ошибки нейронов u и v, установить значение ошибки  
//         //---   нейрона r таким же, как у u.                                 
//
//         u.E*=alpha;
//         v.E*=alpha;
//         r.E = u.E;
//        }
//     }
////--- Уменьшить ошибки и полезность всех нейронов на долю beta 	     

   tmp=Neurons.GetFirstNode();
   maximun_E=0;average_E=0;
   while(CheckPointer(tmp))
     {
      //tmp.E*=(1-beta);
      //tmp.U*=(1-beta);
      //average_E+=tmp.E*tmp.E;
      if(maximun_E<tmp.E) maximun_E=tmp.E;
      tmp=Neurons.GetNextNode();
     }
   average_E=MathSqrt(average_E)/Neurons.Total();
//--- Проверить критерий останова                                      
   Neurons.FindWinners(Winner,SecondWinner);
   return(Winner);
  }
//+------------------------------------------------------------------+
bool CGCANN::Draw(int window,datetime &time[],int w,int h)
  {
//Print("Draw "+w+" "+h);
   int j;
//--- на графике необходимо удалить старые нейроны и связи, чтобы потом нарисовать новые
   for(j=ObjectsTotal(0)-1;j>=0;j--)
     {
      string name=ObjectName(0,j);
      if(StringFind(name,"Neuron_")>=0)
        {
         ObjectDelete(0,name);
        }
      else if(StringFind(name,"Connection_")>=0)
        {
         ObjectDelete(0,name);
        }
     }
   double weights[];
   CGCANNNeuron *tmp,*W1,*W2;
//CGCANNConnection *tmpc;

   Neurons.FindWinners(W1,W2);

//--- отрисовка нейронов
   tmp=Neurons.GetFirstNode();
   while(CheckPointer(tmp)!=POINTER_INVALID)
     {
      tmp.Weights(weights);

      ObjectCreate(0,"Neuron_"+(string)tmp.uid,OBJ_ARROW,window,time[(int)(weights[0]*w/2.1+w/2.05)],weights[1]*h/2.1+h/2);
      ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_ARROWCODE,158);

      ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Blue);
      if(tmp.Stat>0.1) ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Green);
      if(tmp.Stat<-0.1) ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Red);
      //--- победитель цветом Lime, второй лучший Green, остальные Red
      //if(tmp==W1) ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Lime);
      //else if(tmp==W2) ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,Green);
      //else ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_COLOR,White);

      ObjectSetInteger(0,"Neuron_"+(string)tmp.uid,OBJPROP_BACK,false);
      tmp=Neurons.GetNextNode();
     }
//            //--- отрисовка связей
//            tmpc=GNGAlgorithm.Connections.GetFirstNode();
//            while(CheckPointer(tmpc))
//              {
//               int x1=0,x2=0;
//               double y1=0,y2=0;
//
//               tmp=GNGAlgorithm.Neurons.Find(tmpc.uid1);
//               if(tmp!=NULL)
//                 {
//                  tmp.Weights(weights);
//                  x1=(int)(weights[0]*400+500);y1=weights[1];
//                 }
//               tmp=GNGAlgorithm.Neurons.Find(tmpc.uid2);
//               if(tmp!=NULL)
//                 {
//                  tmp.Weights(weights);
//                  x2=(int)(weights[0]*400+500);y2=weights[1];
//                 }
//               ObjectCreate(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJ_TREND,window,time[x1],y1*45+49,time[x2],y2*45+49);
//               ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_WIDTH,1);
//               ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_STYLE,STYLE_DOT);
//               ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_COLOR,Yellow);
//               ObjectSetInteger(0,"Connection_"+(string)tmpc.uid1+"_"+(string)tmpc.uid2,OBJPROP_BACK,false);
//               tmpc=GNGAlgorithm.Connections.GetNextNode();
//              }
//--- меняем информационную метку
//ObjectSetString(0,"Label_samples",OBJPROP_TEXT,"Total samples: "+string(ts+1));
   ObjectSetString(0,"Label_neurons",OBJPROP_TEXT,"Total neurons: "+string(Neurons.Total()));
   ObjectSetString(0,"Label_age",OBJPROP_TEXT,"  ME="+(string)maximun_E);
   ObjectSetString(0,"Label_ae",OBJPROP_TEXT,"Average E="+(string)average_E);
   return(true);
  }
//+------------------------------------------------------------------+
