//+------------------------------------------------------------------+
//|                                                      Neurons.mqh |
//|                                             Copyright 2010, alsu |
//|                                                 alsufx@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, alsu"
#property link      "alsufx@gmail.com"

//--- используем связные списки из стандартной библиотеки MQL5
#include <Arrays\List.mqh>

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
   int               Layer;
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
   Layer=-1;
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
class CGNGNeuron:public CCustomNeuron
  {
public:
   int               uid;
   double            E;
   double            U;
   double            error;
                     CGNGNeuron();
   virtual void      ProcessVector(double &in[]);
  };
//+------------------------------------------------------------------+
//| конструктор                                                      |
//+------------------------------------------------------------------+
CGNGNeuron::CGNGNeuron()
  {
   E=0;
   U=0;
   error=0;
  }
//+------------------------------------------------------------------+
//| рассчитывается "расстояние" от нейрона до входного вектора       |
//| INPUT: in - вектор данных                                        |
//| OUTPUT: нет                                                      |
//| REMARK: в переменную error помещается текущее "расстояние",      |
//|         "локальная ошибка" содержится в другой переменной,       |
//|         которая называется E                                                     
//+------------------------------------------------------------------+
void CGNGNeuron::ProcessVector(double &in[])
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
class CGNGConnection:public CObject
  {
public:
   int               uid1;
   int               uid2;
   int               age;
                     CGNGConnection();
                     ~CGNGConnection();
   virtual int       Type() const          { return(TYPE_GNG_CONNECTION);}
  };
//+------------------------------------------------------------------+
//| конструктор                                                      |
//+------------------------------------------------------------------+
CGNGConnection::CGNGConnection()
  {
   age=0;
   //Print("N+");  
   }
CGNGConnection::~CGNGConnection()
  {
   //Print("N-");  
 }
//+------------------------------------------------------------------+
//| связный список нейронов                                          |
//+------------------------------------------------------------------+
class CGNGNeuronList:public CList
  {
public:
   //--- конструктор   
                     CGNGNeuronList() {MathSrand((int)TimeLocal());}
   CGNGNeuron       *Append();
   void              Init(double &v1[],double &v2[]);
   CGNGNeuron       *Find(int uid);
   void              FindWinners(CGNGNeuron *&Winner,CGNGNeuron *&SecondWinner);
  };
//+------------------------------------------------------------------+
//| добавляет  "пустой" нейрон в конец списка                        |
//| INPUT: нет                                                       |
//| OUTPUT: указатель на новый нейрон                                |
//+------------------------------------------------------------------+
CGNGNeuron *CGNGNeuronList::Append()
  {
   if(m_first_node==NULL)
     {
      m_first_node= new CGNGNeuron;
      m_last_node = m_first_node;
     }
   else
     {
      GetLastNode();
      m_last_node=new CGNGNeuron;
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
         ((CGNGNeuron *)m_curr_node).uid=rnd;
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
void CGNGNeuronList::Init(double &v1[],double &v2[])
  {
   Clear();
   Append();
   ((CGNGNeuron *)m_curr_node).Init(v1);
   Append();
   ((CGNGNeuron *)m_curr_node).Init(v2);
  }
//+------------------------------------------------------------------+
//| поиск нейрона по uid                                             |
//| INPUT: uid - уникальный идентификатор нейрона                    |
//| OUTPUT: указатель на нейрон в случае удачи, NULL в противном     |
//+------------------------------------------------------------------+
CGNGNeuron *CGNGNeuronList::Find(int uid)
  {
   if(!GetFirstNode()) return(NULL);
   do
     {
      if(((CGNGNeuron *)m_curr_node).uid==uid)
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
void CGNGNeuronList::FindWinners(CGNGNeuron *&Winner,CGNGNeuron *&SecondWinner)
  {
   double err_min=0;
   Winner=NULL;
   if(!CheckPointer(GetFirstNode())) return;
   do
     {
      if(!CheckPointer(Winner) || ((CGNGNeuron *)m_curr_node).error<err_min)
        {
         err_min= ((CGNGNeuron *)m_curr_node).error;
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
         if(!CheckPointer(SecondWinner) || ((CGNGNeuron *)m_curr_node).error<err_min)
           {
            err_min=((CGNGNeuron *)m_curr_node).error;
            SecondWinner=m_curr_node;
           }
     }
   while(CheckPointer(GetNextNode()));
   m_curr_node=Winner;
  }
//+------------------------------------------------------------------+
//| связный список соединений между нейронами                        |
//+------------------------------------------------------------------+
class CGNGConnectionList:public CList
  {
public:
   CGNGConnection   *Append();
   void              Init(int uid1,int uid2);
   CGNGConnection   *Find(int uid1,int uid2);
   CGNGConnection   *FindFirstConnection(int uid);
   CGNGConnection   *FindNextConnection(int uid);
  };
//+------------------------------------------------------------------+
//| добавляет "пустое" соединение в конец списка                     |
//| INPUT: нет                                                       |
//| OUTPUT: указатель на новую связь                                 |
//+------------------------------------------------------------------+
CGNGConnection *CGNGConnectionList::Append()
  {
   if(m_first_node==NULL)
     {
      m_first_node= new CGNGConnection;
      m_last_node = m_first_node;
     }
   else
     {
      GetLastNode();
      m_last_node=new CGNGConnection;
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
void CGNGConnectionList::Init(int uid1,int uid2)
  {
   Append();
   ((CGNGConnection *)m_first_node).uid1 = uid1;
   ((CGNGConnection *)m_first_node).uid2 = uid2;
   m_last_node = m_first_node;
   m_curr_node = m_first_node;
   m_curr_idx=0;
  }
//+------------------------------------------------------------------+
//| проверка наличия связи между заданными нейронами                 |
//| INPUT: uid1,uid2 - идентификаторы нейронов                       |
//| OUTPUT: указатель на соединение в случае его наличия, или NULL   |
//+------------------------------------------------------------------+
CGNGConnection *CGNGConnectionList::Find(int uid1,int uid2)
  {
   if(!CheckPointer(GetFirstNode())) return(NULL);
   do
     {
      if((((CGNGConnection *)m_curr_node).uid1==uid1 && ((CGNGConnection *)m_curr_node).uid2==uid2)
         ||(((CGNGConnection *)m_curr_node).uid1==uid2 && ((CGNGConnection *)m_curr_node).uid2==uid1))
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
CGNGConnection *CGNGConnectionList::FindFirstConnection(int uid)
  {
   if(!CheckPointer(GetFirstNode())) return(NULL);
   while(true)
     {
      if(((CGNGConnection *)m_curr_node).uid1==uid || ((CGNGConnection *)m_curr_node).uid2==uid) break;
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
CGNGConnection   *CGNGConnectionList::FindNextConnection(int uid)
  {
   if(!CheckPointer(GetCurrentNode())) return(NULL);
   while(true)
     {
      if(!CheckPointer(GetNextNode())) return(NULL);
      if(((CGNGConnection *)m_curr_node).uid1==uid || ((CGNGConnection *)m_curr_node).uid2==uid) break;
     }
   return(m_curr_node);
  }
//+------------------------------------------------------------------+
