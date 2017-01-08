//+------------------------------------------------------------------+
//|                                                      FANN-EA.mq4 |
//|                              Mariusz Woloszyn & Yury V. Reshetov |
//|                                           Fann2MQL.wordpress.com |
//|                                       Modify by Yury V. Reshetov |
//+------------------------------------------------------------------+
#property copyright "Mariusz Woloszyn & Yury V. Reshetov"
#property link      "Fann2MQL.wordpress.com"

// Include Neural Network package
#include <Fann2MQL.mqh>

// Global defines
#define ANN_PATH	"D:\\FANN\\"
// EA Name
#define NAME		"NM"

//---- input parameters
extern double StopLoss = 180.0;
extern int x = 500;
extern double Lots = 0.1;

static int prevtime = 0;
static int AnnsNumber = 16;
static int AnnInputs = 30;
static bool NeuroFilter = true;
static int DebugLevel = 2;
static double MinimalBalance = 200;
static bool Parallel = false;
static bool SaveAnn = true;

// Global variables

// Path to anns folder
static string AnnPath = "";

// Trade magic number
static int id = 0;

// AnnsArray[ann#] - Array of anns
static int AnnsArray[];

// All anns loded properly status
static bool AnnsLoaded = true;

// AnnOutputs[ann#] - Array of ann returned returned
static double AnnOutputs[];

// InputVector[] - Array of ann input data
static double InputVector[];
//static double InputVector1[];

// Remembered long and short network inputs

void debug (int level, string text) {
    if (DebugLevel >= level) {
	     if (level == 0) {
	        text = "ERROR: " + text;
	     }
	     Print (text);
    }
}



/* Load the ANN */

int ann_load (string path) {
    int ann = -1;

    ann = f2M_create_from_file (path);
    if (ann != -1) {
	  debug (1, "ANN: '" + path + "' loaded successfully with handler " + (string)ann);
    }
    else{

	     /* Create ANN */
	     ann = f2M_create_standard (4, AnnInputs, AnnInputs, AnnInputs / 2 + 1, 1);
	     f2M_set_act_function_hidden (ann, FANN_SIGMOID_SYMMETRIC_STEPWISE);
	     f2M_set_act_function_output (ann, FANN_SIGMOID_SYMMETRIC_STEPWISE);
	     f2M_randomize_weights (ann, -1.0, 1.0);
	     debug (1, "ANN: '" + path + "' created successfully with handler " + (string)ann);
    }
    if (ann == -1) {
	     debug (0, "ERROR INITIALIZING NETWORK!");
    }
    return (ann);
}


/* Save the ANN */

void ann_save (int ann, string path) {
   if (! SaveAnn) {
      return;
   }
   int ret = -1;
   ret = f2M_save (ann, path);
   debug (1, "f2M_save(" + (string)ann + ", " + path + ") returned: " + (string)ret);
}

void ann_destroy (int ann) {
    int ret = -1;
    ret = f2M_destroy (ann);
    debug (1, "f2M_destroy(" + (string)ann + ") returned: " + (string)ret);
}



double ann_run (int ann, double &vector[]) {
    int ret;
    double out;
    ret = f2M_run (ann, vector);
    if (ret < 0) {
	     debug (0, "Network RUN ERROR! ann=" + (string)ann);
	     return (FANN_DOUBLE_ERROR);
    }
    out = f2M_get_output (ann, 0);
    debug (3, "f2M_get_output(" + (string)ann + ") returned: " + (string)out);
    return (out);
}

int anns_run_parallel (int anns_count, int &anns[], double &input_vector[]) {
    int ret;

    ret = f2M_run_parallel (anns_count, anns, input_vector);

    if (ret < 0) {
	     debug (0, "f2M_run_parallel(" + (string)anns_count + ") returned: " + (string)ret);
    }
    return (ret);
}

void ann_prepare_input () {
    int i;
    double res = 0;
	 for(i = 0; i < AnnInputs; i++) {
	 //iRSI(NULL,0,8,PRICE_CLOSE);
      res = (iRSI(Symbol(), 0, 30, PRICE_OPEN) - 50.0) / 50.0; 
      if (MathAbs(res) > 1) {
         if (res > 0) {
            InputVector[i] = 1.0;            
         } else {
            InputVector[i] = -1.0;            
         }
      } else {
         InputVector[i] = res;            
      }
    }
}

// Get Outpust

void run_anns () {
   int i;

   if (Parallel) {
	  anns_run_parallel (AnnsNumber, AnnsArray, InputVector);
   }

   for (i = 0; i < AnnsNumber; i++) {
	  if (Parallel) {
	    AnnOutputs[i] = f2M_get_output (AnnsArray[i], 0);
	  } else {
	    AnnOutputs[i] = ann_run (AnnsArray[i], InputVector);
	  }
  }
}

void ann_train (int ann, double &input_vector[], double &output_vector[]) {
    if (f2M_train (ann, input_vector, output_vector) == -1) {
	     debug (0, "Network TRAIN ERROR! ann=" + (string)ann);
    }
    debug (3, "ann_train(" + (string)ann + ") succeded");
}

// PNN section

double ann_pnn() {
    int i;
    double ret;

    if (AnnsNumber < 1) {
	     return (-1);
	 }

    for (i = 0; i < AnnsNumber; i++) {
	     ret += AnnOutputs[i];
    }

    ret = 2 * ret / AnnsNumber;

    Print("Wise result: " + (string)ret);
    return (ret);
}


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init () {
    int i, ann;

    prevtime = TimeCurrent();

    if (AnnInputs < 3) {
	     debug (0, "AnnInputs too low!");
    }
    // Compute AnnPath
    id = StopLoss;
    
    AnnPath = ANN_PATH+ Symbol()+ "-"+ id;

    // Initialize anns
    ArrayResize (AnnsArray, AnnsNumber);
    for (i = 0; i < AnnsNumber; i++) {
	     ann = ann_load (AnnPath + "." + (string)i + ".net");
	     if (ann < 0) {
	        AnnsLoaded = false;
	     }
	     AnnsArray[i] = ann;
    }
    ArrayResize (AnnOutputs, AnnsNumber);
    ArrayResize (InputVector, AnnInputs);

    // Initialize Intel TBB threads
    f2M_parallel_init ();

    return (0);
}

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit () {
    int i;

    // Deinitialize anns
    for (i = AnnsNumber - 1; i >= 0; i--) {
	     ann_save (AnnsArray[i], AnnPath + "." + (string)i + ".net");
	     ann_destroy (AnnsArray[i]);
    }

    // Deinitialize Intel TBB threads
    f2M_parallel_deinit ();

    return (0);
}

bool trade_allowed () {
   if (!AnnsLoaded) {
	  return (false);
	}

    /* Trade only on first tick of a bar and there's enough funds */
    //if (IsTradeAllowed() && AccountBalance () > MinimalBalance) {
	     return (true);
    //}

    return (false);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start () {

    if (prevtime == TimeCurrent()) {
      return(0);
    }
    prevtime = TimeCurrent();
    
    int i = 0;

    double train_output[1];
    


    /* Is trade allowed? */
    if (!trade_allowed ()) {
	     return (-1);
    }


   int total = OrdersTotal();
   for (i = 0; i < total; i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         return(0);      
      }
   }

   // Adaptive part
   if (IsOptimization() || IsTesting()) {
      total = OrdersHistoryTotal();
      if (total > 0) {
         OrderSelect(total - 1, SELECT_BY_POS, MODE_HISTORY);   
         if (OrderProfit() < 0) {
            if (OrderType() == OP_SELL) {
               train_output[0] = 1; 
            } else {
               train_output[0] = -1; 
            }
            // Learning
            for (i = 0; i < AnnsNumber; i++) {
		       ann_train (AnnsArray[i], InputVector, train_output);
		      }
         
        }
      }
   }
   
   /* Prepare and run neural networks */
   ann_prepare_input ();
   // Get Outputs
   run_anns ();
   // Get Results
   double res = ann_pnn();
   
   // Trade
   
   int ticket = 0;
   
   RefreshRates();
   if (res > 0) {
      ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 2, Ask -  StopLoss * Point, Ask + StopLoss * Point, WindowExpertName(), 0, 0, Blue);
   } else {
      ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, 2, Bid +  StopLoss * Point, Bid - StopLoss * Point, WindowExpertName(), 0, 0, Red);
   }
   if (ticket >= 0) {
      ann_prepare_input ();
   }
   return (0);
}