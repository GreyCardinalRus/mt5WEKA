#import "fanndouble32.dll"
//#import "fanndouble64.dll"

//int f2M_create_standard(int num_layers,int l1num,int l2num,int l3num,int l4num);
int f2M5_create_standard(int num_layers,int l1num,int l2num,int l3num,int l4num);
int f2M5_create_from_file(uchar &path[]);
int f2M5_run(int ann,double &input_vector[]);
int f2M5_destroy(int ann);
int f2M5_destroy_all_anns();

double f2M5_get_output(int ann,int output);
int  f2M5_get_num_input(int ann);
int  f2M5_get_num_output(int ann);

int f2M5_train(int ann,double &input_vector[],double &output_vector[]);
int f2M5_train_fast(int ann,double &input_vector[],double &output_vector[]);
int f2M5_randomize_weights(int ann,double min_weight,double max_weight);
double f2M5_get_MSE(int ann);
int f2M5_save(int ann,char &path[]);
int f2M5_reset_MSE(int ann);
int f2M5_test(int ann,double &input_vector[],double &output_vector[]);
int f2M5_set_act_function_layer(int ann,int activation_function,int layer);
int f2M5_set_act_function_hidden(int ann,int activation_function);
int f2M5_set_act_function_output(int ann,int activation_function);

/* Threads functions */
int f2M5_threads_init(int num_threads);
int f2M5_threads_deinit();
//int f2M5_parallel_init();
//int f2M5_parallel_deinit();
int f2M5_run_threaded(int anns_count,int &anns[],double &input_vector[]);
int f2M5_run_parallel(int anns_count,int &anns[],double &input_vector[]);
///* Data training */
int f2M5_train_on_file(int ann,uchar &path[],int max_epoch,float desired_error);
#import
#define FANN_DOUBLE_ERROR	-1000000000

#define FANN_LINEAR                     0
#define FANN_THRESHOLD	                1
#define FANN_THRESHOLD_SYMMETRIC        2
#define FANN_SIGMOID                    3
#define FANN_SIGMOID_STEPWISE           4
#define FANN_SIGMOID_SYMMETRIC          5
#define FANN_SIGMOID_SYMMETRIC_STEPWISE 6
#define FANN_GAUSSIAN                   7
#define FANN_GAUSSIAN_SYMMETRIC         8
#define FANN_GAUSSIAN_STEPWISE          9
#define FANN_ELLIOT                     10
#define FANN_ELLIOT_SYMMETRIC           11
#define FANN_LINEAR_PIECE               12
#define FANN_LINEAR_PIECE_SYMMETRIC     13
#define FANN_SIN_SYMMETRIC              14
#define FANN_COS_SYMMETRIC              15
#define FANN_SIN                        16
#define FANN_COS                        17

#define FANN_TRAIN_INCREMENTAL			0
#define FANN_TRAIN_BATCH				1
#define FANN_TRAIN_RPROP				2
#define FANN_TRAIN_QUICKPROP			3
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int f2M5_create_from_file(string path)
  {
   char p[];
   StringToCharArray(path,p);
   return(f2M5_create_from_file(p));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int f2M5_save(int ann_,string path)
  {
   char p[];
   StringToCharArray(path,p);
   return(f2M5_save(ann_,p));
  }

//+------------------------------------------------------------------+
