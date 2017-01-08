//+------------------------------------------------------------------+
//|                                                         GNGU.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Vector
  {
   int               size;
public:
   int size(){return size;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/**  * A class representing a node for all neural algorithms.  *  */
class NodeGNG
  {
protected:
/**    * The maximum number of neighbors of a node    */
   int               MAX_NEIGHBORS;
/**    * The flag for mouse-selection    */
   bool              fixed;
/**    * The flag for the winner.    *  This node is nearest to the input signal.    */
   bool              winner;
/**    * The flag for the second winner.    *  This node is second nearest to the input signal.    */
   bool              second;
/**    * The flag for movement.    *  This node moved from the last position (GNG, LBG).    */
   bool              moved;
/**    * The flag for insertion.    *  This node was inserted last (GNG).    */

   bool              inserted;  /**    * The x index in the grid (GG, SOM).    */
   int               x_grid; /**    * The y index in the grid (GG, SOM).    */
   int               y_grid; /**    * The x-position of the node.    */
   float             x; /**    * The old x-position of the moved node.    */
   float             x_old; /**    * The y-position of the node.    */
   float             y; /**    * The old y-position of the moved node.    */
   float             y_old; /**    * The error of the node.    */
   float             error; /**    * The distance from the input signal.    */
   float             dist; /**    * The utility for GNG-U and LBG-U    */
   float             utility; /**    * The number of neighbors.    */
   int               nNeighbor; /**    * The list of neighbors.    */

   int               neighbor[]; /**    * The list of neighbors.    */
   Vector            signals;  /**    * Return number of signals.    *    * @return		number of signals    */
   int numSignals()
     {
      return(signals.size());
     }
/**    * Add a signal index.    *    * @param sig		The index of the signal    */
   void addSignal(int sig)
     {
      signals.addElement(new Integer(sig));
     }
/**    * Remove a signal index and return the index.    *    * @return		The index of the signal or -1.    */
   int removeSignal()
     {
      int size=signals.size();       if(size<1) return(-1);
      // remove last element from the vector and return it 
      Integer lastSignal=(Integer)signals.lastElement();
      signals.removeElementAt(size-1);
      return(lastSignal.intValue());
     }
/**    * Return the number of neighbors.    *    * @return	Number of neighbors    */
   int numNeighbors()
     {
      return nNeighbor;
     }
/**    * Is there space for more neighbors?    *    * @return	Space enough?    */
   bool moreNeighbors()
     {
      return(MAX_NEIGHBORS!=nNeighbor);
     }
/**    * Returns the i-th neighbor.    *    * @param i	The index of a neighbor    * @return	The index of a node    */
   int neighbor(int i)
     {
      return neighbor[i];
     }
/**    * Deletes the node from the list of neighbors.    *    * @param node	The index of a node    */
   void deleteNeighbor(int node)
     {
      for(int i=0; i<nNeighbor; i++)
        {
         if(node==neighbor[i])
           {
            nNeighbor--;             neighbor[i]=neighbor[nNeighbor];             neighbor[nNeighbor]=-1;
            return;
           }
        }
     }
/**    * Replaces the old node with a new node.  
  *    * @param old		The index of a node   
  * @param newN	The index of a node    * @see ComputeGNG#deleteNode    */

   void replaceNeighbor(int old,int newN)
     {
      for(int i=0; i<nNeighbor; i++)
        {
         if(old==neighbor[i])
           {
            neighbor[i]=newN;             return;
           }
        }
     }
/**    * Is the node a neighbor?    *    * @param n		The index of a node    * @return		Neighbor?    */

   bool isNeighbor(int n)
     {
      for(int i=0; i<nNeighbor; i++)
         if(n==neighbor[i])
            return true;
      return false;
     }
/**    * Add a node to the neighborhood.    *    * @param node	The index of a node    */
   void addNeighbor(int node)
     {
      if(nNeighbor==MAX_NEIGHBORS)
         return;
      neighbor[nNeighbor]=node;
      nNeighbor++;
     }
public:
                     NodeGNG()
     {
      MAX_NEIGHBORS=10;
/**    * The flag for mouse-selection    */
      fixed=false;
/**    * The flag for the winner.    *  This node is nearest to the input signal.    */
      winner=false;
/**   * The flag for the second winner.    *  This node is second nearest to the input signal.    */
      second=false;
/**    * The flag for movement.    *  This node moved from the last position (GNG, LBG).    */
      moved=false;
/**    * The flag for insertion.    *  This node was inserted last (GNG).    */

      inserted=false;  /**    * The x index in the grid (GG, SOM).    */
      x_grid=-1; /**    * The y index in the grid (GG, SOM).    */
      y_grid=-1; /**    * The x-position of the node.    */
      x=0.0f; /**    * The old x-position of the moved node.    */
      x_old=0.0f; /**    * The y-position of the node.    */
      y=0.0f; /**    * The old y-position of the moved node.    */
      y_old=0.0f; /**    * The error of the node.    */
      error=0.0f; /**    * The distance from the input signal.    */
      dist=Float.MAX_VALUE; /**    * The utility for GNG-U and LBG-U    */
      utility=0.0f; /**    * The number of neighbors.    */
      nNeighbor=0; /**    * The list of neighbors.    */
      neighbor[]=new int[MAX_NEIGHBORS];
      signals=new Vector();
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class GridNodeGNG
  {
   NodeGNG           node;
   int               index;
   int               tau;  /**    * Construct the default grid node.    */
   GridNodeGNG()
     {
      tau=0;
      index=-1;
     }
/**    * Construct the grid node and sets the index and node.    */

   void    Init(int index,NodeGNG *node)
     {
      tau=0;       this.index=index;       this.node=node;
     }
  }
//+------------------------------------------------------------------+
