
// Simple one-dimensional multi-layer perceptron
// Contains no load or save facility (sorry!)
import java.awt.*;
import java.applet.*;
import java.io.*;

public class mlp1 extends Applet
{ final int INPMAX = 6;         // Number of inputs
  final int HIDDMAX = 10;   // Number of nodes in the hidden layer
  final int OUTMAX = 5;       // Number of nodes in the output layer
  final int MAX_ITERATION = 10000;  // Number of iterations for training
  
  final int MAXTRAINPAT = 12;    // Maximum number of training patterns
  double trainingPattern[][];     // Stored training patterns
  double desired[][];                  // Stored desired outputs
  double inputs[];                      // Inputs to net during testing

  // I can't use classes or structures - the program doesn't seem to work properly
  // What a nuisance!
  // I'll get the problem solved in the next version of the program

  // hl_weights[x][y] means the weight from input 'x' to hidden layer node 'y'
  double[][] hl_weights = new double[INPMAX][HIDDMAX];
  // hl_change[x][y] means the change in weight since last time step
  double[][] hl_change = new double[INPMAX][HIDDMAX];
  // hl_error contains the error for the node i.e. desired output - actual output
  double[] hl_error = new double[HIDDMAX];
  double hl_threshold[] = new double[HIDDMAX];
  double hl_a[] = new double[HIDDMAX];   // Activation of hidden layer nodes

  // ol[x][y] means the weight from hidden node 'x' to output node 'y'
  double ol_weights[][] = new double[HIDDMAX][OUTMAX];
  // ol_change[x][y] means the change in weight since last time step
  double[][] ol_change = new double[HIDDMAX][OUTMAX];
  double[] ol_error = new double[OUTMAX];
  double ol_threshold[] = new double[OUTMAX];
  double ol_a[] = new double[OUTMAX];    // Activation of output layer nodes

  Button train;                       // Click here to train the network
  Button run;                         // Click here to run the network
  TextField value;

  int trainingPat;           // Identity of training pattern being presented
  int numTrainingPat = 10;  // Number of training patterns used

  public void init ()
  { int i,j;
    setBackground(Color.lightGray);
    trainingPattern = new double[MAXTRAINPAT][INPMAX];
    desired = new double[MAXTRAINPAT][OUTMAX];
    inputs = new double[INPMAX];
    train = new Button("Train");
    add(train);
    run = new Button("Run");
    add(run);
    Label lab = new Label("Type input values here and click component");
    add(lab);
    value = new TextField(10);
    add(value);

    // Initialize the hidden layer neurons
    for (i = 0; i < HIDDMAX; i++)
     { hl_a[i] = 0;
       for (j = 0; j < INPMAX; j++)
         hl_weights[j][i] = Math.random();
       hl_threshold[i] = Math.random();
     }
    // Initialize the output layer neurons
    for (i = 0; i < OUTMAX; i++)
     { ol_a[i] = 0;
       for (j = 0; j < HIDDMAX; j++)
         ol_weights[j][i] = Math.random();
       ol_threshold[i] = Math.random();
     }
  }

  // Draw the grid with the training patterns, the buttons and the network.
  public void paint (Graphics g)
  { int i,j;        // For loop variables
    String s;   // Used in conversion of floating point numbers
  
    // Display all the training patterns
    g.drawString("Training patterns",10,50);
    for (i = 0; i < numTrainingPat; i++)
      { if (i < 4)                    // Draw first four in top row
          drawCombination(i,10 + 50 * i,60,g);
        if (i > 3 && i < 8)      // Draw second four in second row
          drawCombination(i,10 + 50 * (i-4),90 + OUTMAX*10,g);
        if (i > 7)
          drawCombination(i,10 + 50 * (i-8), 120 + OUTMAX*20,g);
      }

    // Draw the + and - symbols for increasing/decreasing the number of training patterns
    g.drawRect(100,35,15,15);
    g.drawRect(115,35,15,15);
    g.drawLine(107,37,107,48);
    g.drawLine(102,42,113,42);
    g.drawLine(118,42,127,42);
    
    // Display the connections from input layer to hidden layer
    for (i = 0; i < INPMAX; i++)
      for (j = 0; j < HIDDMAX; j++)
        g.drawLine(300,50+25*i, 400,50+25*j);
    // Display the connections from hidden layer to output layer
    for (i = 0; i < HIDDMAX; i++)
      for (j = 0; j < OUTMAX; j++)
        g.drawLine(400,50 + 25*i,500,50 + 25*j);
    // Draw the circles to represent ellipses
    g.setColor(Color.blue);
    for (i = 0; i < HIDDMAX; i++)
      g.fillOval(395,45 + 25*i,10,10);
    for (i = 0; i < OUTMAX; i++)
      g.fillOval(495,45 + 25*i,10,10);

    // Draw the ouput activity from the output layer
    g.setColor(Color.black);
    for (i = 0; i < OUTMAX; i++)
     { g.drawRect(510,44 + 25*i,80,12);
       s = Double.toString(ol_a[i]);
       if (s.length() > 12)
         s = s.substring(0,13);
       g.drawString(s,512,55 + 25*i);
     }
     
     // Draw the current inputs to the network
     for (i = 0; i < INPMAX; i++)
      { g.drawRect(210,44 + 25*i, 80, 12);
        s = Double.toString(inputs[i]);
        if (s.length() > 12)
          s = s.substring(0,13);
        g.drawString(s,212,55 + 25*i);
      }
  }

  // Draw a combination of a training pattern and the desired output
  public void drawCombination(int which, int x, int y, Graphics g)
  { int i;   // For loop variable
    for (i = 0; i < INPMAX; i++)
      filledRect(g,x,y+i*10,10,10,trainingPattern[which][i]);
    for (i = 0; i < OUTMAX; i++)
      filledRect(g,x+15,y+i*10,10,10,desired[which][i]);
    // Draw a rectangle round the combination
    g.setColor(Color.black);
    g.drawRect(x-5,y-5,35,OUTMAX*10+20);
  }

  // Draw a filled rectangle with a given x, y, width, height. The parameter 'val' specifies
  // what colour to fill it with
  public void filledRect (Graphics g, int x, int y, int width, int height, double val)
  { g.setColor(Color.black);
    g.drawRect(x,y,width,height);
    setColour(g,val);
    g.fillRect(x+1,y+1,width-2,height-2);  // Careful not to draw over black outline
  }

  // Set the colour according to the grid value 'v' (a decimal)
  public void setColour(Graphics g,double v)
  { int temp = (int)(v * 10);   // Converts to integer so that I can use 'switch'
    switch (temp)
     { case 0 : g.setColor(Color.white); break;
       case 3 : g.setColor(Color.lightGray); break;
       case 5 : g.setColor(Color.gray); break;
       case 7 : g.setColor(Color.darkGray); break;
       case 10 : g.setColor(Color.black); break;
     }
  }

  public boolean action (Event e, Object arg)
  { if (e.target instanceof TextField)   // If clicked on text field, enter value
      { int newValue = Integer.parseInt(value.getText());
         repaint();    // Redraw with new value in text field
      }
    if (e.target == run)
     { run_net();
       repaint();
     }
    if (e.target == train)
     { train_net();
       repaint();
     }
    return true;
  }

  // Tackle button clicks at position x,y
  public boolean mouseDown (Event e, int x, int y)
  { int i,j;
    boolean redraw = false;

    // Has the mouse been clicked over the input part of a training pattern?
    for (i = 0; i < numTrainingPat; i++)
     for (j = 0; j < INPMAX; j++)
      { int xx,yy;
        if (i < 4)                     // Co-ordinates for first row
          { xx = 10 + 50*i;
            yy = 60 + 10*j;
          }
        else if (i > 3 && i < 8)      // Co-ordinates for second row
          { xx = 10 + 50*(i-4);
            yy = 90 + 10*j + OUTMAX*10;
          }
        else                     // Co-ordinates for third row
          { xx = 10 + 50*(i-8);
            yy = 120 + 10*j + OUTMAX*20;
          }
        if (x > xx && x < xx+10 && y > yy && y < yy+10)
          { trainingPattern[i][j] = increase(trainingPattern[i][j]);
            redraw = true;
          }
     }

    // Has the mouse been clicked over the output part of a training pattern?
    for (i = 0; i < numTrainingPat; i++)
      for (j = 0; j < OUTMAX; j++)
      { int xx,yy;
         if (i < 4)
           { xx = 25 + 50*i;           // Co-ordinates for first row
             yy = 60 + 10*j;
           }
         else if (i > 3 && i < 8)    // Co-ordinates for second row
           { xx = 25 + 50*(i-4);
             yy = 90 + 10*j + OUTMAX*10;
           }
         else                                // Co-ordinates for third row
           { xx = 25 + 50*(i-8);
             yy = 120 + 10*j + OUTMAX*20;
           }
         if (x > xx && x < xx+10 && y > yy && y < yy+10)
          { desired[i][j] = increase(desired[i][j]);
            redraw = true;
          }
      }

    // Has the mouse been clicked on the + or - to change the number of training patterns?
    if (x > 100 && x < 115 && y > 35 && y < 50 && numTrainingPat < MAXTRAINPAT)
      { numTrainingPat++;
        redraw = true;
      }
    if (x > 115 && x < 130 && y > 35 && y < 50 && numTrainingPat > 1)
      { numTrainingPat--;
        redraw = true;
      }

    // Has the mouse been clicked over an input box to the network?
    // If so, copy the value in the text area into the input box
    for (i = 0; i < INPMAX; i++)
      if (x > 210 && x < 290 && y > 44 + 25*i && y < 56 + 25*i)
        { Float F = Float.valueOf(value.getText());
          inputs[i] = F.floatValue();
          redraw = true;
        }

    if (redraw == true)
      repaint();
    return true;
  }

  // Increase the doubleing point value
  public double increase (double v)
  { int temp = (int)(v * 10);           // 'switch' doesn't like double, so recast as int
    switch (temp)
    { case 0 : v = 0.3f; break;
      case 3 : v = 0.5f; break;
      case 5 : v = 0.7f; break;
      case 7 : v = 1.0f; break;
      case 10 : v = 0.0f;
    }
    return v;
  }

  // Sigmoid function
  public double f (double x)
  { return 1 / (1 + Math.exp(-x));
  }

  // Run the neural net
  public void run_net ()
  { int i,j;
    double sum;
    for (i = 0; i < HIDDMAX; i++)
      { sum = 0;
        for (j = 0; j < INPMAX; j++)
          sum += inputs[j] * hl_weights[j][i];
        hl_a[i] = f(sum - hl_threshold[i]);
      }
    for (i = 0; i < OUTMAX; i++)
      { sum = 0;
        for (j = 0; j < HIDDMAX; j++)
          sum += hl_a[j] * ol_weights[j][i];
        ol_a[i] = f(sum - ol_threshold[i]);
      }
  }

  // Train the net using back propagation
  public void train_net ()
  { int i;
    for (i = 0; i < MAX_ITERATION; i++)
      for (trainingPat = 0; trainingPat < numTrainingPat; trainingPat++)
        { value.setText(Integer.toString(trainingPat));
          repaint();
          run_net();         // Firstly, run the network forwards
          blank_change_values();
          calculate_output_layer_errors();
          calculate_hidden_layer_errors();
          weight_change();
        }
  }

  // Blank out 'change' values in the neurons ready for back propagation
  public void blank_change_values ()
  { int i,j;
    for (i = 0; i < INPMAX; i++)
     for (j = 0; j < HIDDMAX; j++)
      hl_change[i][j] = 0;
    for (i = 0; i < HIDDMAX; i++)
     for (j = 0; j < OUTMAX; j++)
      ol_change[i][j] = 0;
  }

  public void calculate_output_layer_errors ()
  { int i;
    for (i = 0; i < OUTMAX; i++)
      ol_error[i] = (desired[trainingPat][i] - ol_a[i]) * ol_a[i] * (1 - ol_a[i]);
  }

  public void calculate_hidden_layer_errors ()
  { int i,j;
    double sum;
    for (i = 0; i < HIDDMAX; i++)      // Go through all the hidden layer nodes
     { sum = 0;
       for (j = 0; j < OUTMAX; j++)
        sum = sum + ol_error[j] * ol_weights[i][j];
       hl_error[i] = hl_a[i] * (1 - hl_a[i]) * sum;
     }
  }

  public void weight_change ()
  { final double GAIN = 0.9;
    final double ACL = 0.9;      // ACL is the acceleration value
    int i,j,m;

    // Firstly, change the output layer weights
    for (i = 0; i < OUTMAX; i++)
      { for (j = 0; j < HIDDMAX; j++)
          { ol_change[j][i] = GAIN * ol_error[i] * hl_a[j] + ACL * ol_change[j][i];
            ol_weights[j][i] += ol_change[j][i];
          }
        // ol[i].t_change = GAIN * ol[i].error * 1 + ACL * ol[i].t_change;
        // ol[i].threshold = ol[i].threshold + ol[i].t_change
      }

    // Secondly, change the hidden layer weights
    for (i = 0; i < HIDDMAX; i++)
      { for (j = 0; j < INPMAX; j++)
          { hl_change[j][i] = GAIN * hl_error[i] * trainingPattern[trainingPat][j] + ACL * hl_change[j][i];
            hl_weights[j][i] += hl_change[j][i];
          }
      }
  }
}

