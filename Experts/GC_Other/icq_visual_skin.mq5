//+------------------------------------------------------------------+
//|                                              icq_visual_skin.mq5 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//---
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <Canvas\Canvas.mqh>
#include <Arrays\List.mqh>
#include <icq_mql5.mqh>
//---
#resource "\\Images\\icq_skin.bmp"
#resource "\\Images\\icq_signin.bmp"
#resource "\\Images\\icq_signout.bmp"
#resource "\\Images\\icq_cancel.bmp"

//---
#define CANVAS_NAME     "mySkin"
#define EDIT_LOGIN      "myLogin"
#define EDIT_PASSWORD   "myPassword"
#define EDIT_MESSAGE    "myMessage"
#define EDIT_ADDRESS    "myContact"
#define LABEL_NICKNAME  "myNickName"
#define LABEL_LOGIN     "myLoginEx"
#define LABEL_MSG       "myLabelMsg"
//+------------------------------------------------------------------+
//|   CResource                                                      |
//+------------------------------------------------------------------+
struct CResource
  {
   CRect             rect;
   string            name;
  };
//+------------------------------------------------------------------+
//|   AccoutInfo                                                     |
//+------------------------------------------------------------------+
class CAccountInfo : public CObject
  {
public:
   uint              Login;
   string            Password;
   string            NickName;
  };

//--- global variables
CList account,contact,resource;
CCanvas skin;
CResource r_skin,r_send,r_close,r_clear,r_left1,r_right1,r_left2,r_right2,r_signin,r_signout,r_cancel;
CChartObjectEdit edit_login,edit_password,edit_message,edit_contact;
CChartObjectLabel label_nickname,label_login,label_msg[3];
COscarClient icq;
ENUM_STATE button_state;
//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---   
   EventSetTimer(1);
//--- add accounts
   account.Clear();
   AddInfoToList(account,266690424,"password","avoitenko");
   AddInfoToList(account,641848065,"password","mail");
   AddInfoToList(account,610043094,"password","meduza");

//--- add contacts
   contact.Clear();
   AddInfoToList(contact,641848065,"","mail");
   AddInfoToList(contact,266690424,"","avoitenko");
   AddInfoToList(contact,610043094,"","meduza");

//--- add resource
   SetResourceInfo(r_skin,"::Images\\icq_skin.bmp",0,0,440,240);
   SetResourceInfo(r_signin,"::Images\\icq_signin.bmp",362,50,60,20);
   SetResourceInfo(r_signout,"::Images\\icq_signout.bmp",362,50,60,20);
   SetResourceInfo(r_cancel,"::Images\\icq_cancel.bmp",362,50,60,20);

//--- buttons on the skin
   SetResourceInfo(r_close,"",406,17,16,16);

   SetResourceInfo(r_send,"",362,202,60,20);
   SetResourceInfo(r_clear,"",362,147,60,20);

   SetResourceInfo(r_left1,"",77,50,20,20);
   SetResourceInfo(r_right1,"",99,50,20,20);

   SetResourceInfo(r_left2,"",77,162,20,20);
   SetResourceInfo(r_right2,"",99,162,20,20);

//--- create canvas
   if(!skin.CreateBitmapLabel(CANVAS_NAME,r_skin.rect.left,r_skin.rect.top,1,1))
     {
      Print("Cannot create canvas ",CANVAS_NAME);
      return(INIT_FAILED);
     }

//--- create edit login
   if(edit_login.Create(0,EDIT_LOGIN,0,122,50,100,20))
     {
      edit_login.BackColor(clrWhite);
      edit_login.BorderColor(clrMediumTurquoise);
      edit_login.Color(clrBlack);
      if(account.Total()>0)
        {
         CAccountInfo *info=account.GetFirstNode();
         edit_login.SetString(OBJPROP_TEXT,IntegerToString(info.Login));
        }
     }

//--- create edit password
   if(edit_password.Create(0,EDIT_PASSWORD,0,265,50,93,20))
     {
      edit_password.BackColor(clrWhite);
      edit_password.BorderColor(clrMediumTurquoise);
      edit_password.Color(clrBlack);
      if(account.Total()>0)
        {
         CAccountInfo *info=account.GetFirstNode();
         string pass=info.Password;
         StringFill(pass,'*');
         edit_password.SetString(OBJPROP_TEXT,pass);
        }
     }

//--- create edit contact 
   if(edit_contact.Create(0,EDIT_ADDRESS,0,123,162,100,20))
     {
      edit_contact.BackColor(clrWhite);
      edit_contact.BorderColor(clrMediumTurquoise);
      edit_contact.Color(clrBlack);
      if(contact.Total()>0)
        {
         CAccountInfo *info=contact.GetFirstNode();
         edit_contact.SetString(OBJPROP_TEXT,IntegerToString(info.Login));
        }
     }

//--- create edit message
   if(edit_message.Create(0,EDIT_MESSAGE,0,20,202,338,20))
     {
      edit_message.BackColor(clrWhite);
      edit_message.BorderColor(clrMediumTurquoise);
      edit_message.Color(clrBlack);
     }

//--- label nickname
   if(label_nickname.Create(0,LABEL_NICKNAME,0,265,163))
     {
      label_nickname.Font("Arial");
      label_nickname.FontSize(9);
      label_nickname.Color(clrBlack);
      label_nickname.SetString(OBJPROP_TEXT," ");
      if(contact.Total()>0)
        {
         CAccountInfo *info=contact.GetFirstNode();
         label_nickname.SetString(OBJPROP_TEXT,info.NickName);
        }
     }

//--- label login
   if(label_login.Create(0,LABEL_LOGIN,0,77,20))
     {
      label_login.Font("Arial");
      label_login.FontSize(9);
      label_login.Color(clrBlack);
      label_login.SetString(OBJPROP_TEXT," ");
     }

//--- labels for messages
   for(int i=0;i<3;i++)
     {
      label_msg[i].Create(0,LABEL_MSG+IntegerToString(i),0,26,82 + 20*i);
      label_msg[i].Font("Arial");
      label_msg[i].FontSize(9);
      label_msg[i].Color(clrBlack);
      label_msg[i].SetString(OBJPROP_TEXT," ");
     }

//---
   icq.autocon  = false;
   icq.server   = "login.icq.com";
   icq.port     = 5190;
//---
   button_state=STATE_DISCONNECTED;
//---
   if(!DrawSkin())return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   skin.Destroy();
   edit_login.Delete();
   edit_password.Delete();
   edit_message.Delete();
   edit_contact.Delete();
   label_nickname.Delete();
   label_login.Delete();
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//|   OnTimer                                                        |
//+------------------------------------------------------------------+
void OnTimer()
  {

//--- update button state
   if(button_state!=icq.State())
     {
      button_state=icq.State();
      DrawSkin();
     }

//--- functionality
   switch(icq.State())
     {
      case STATE_CONNECTED:
         icq.uin="                        ";
         if(icq.ReadMessage(icq.uin,icq.msg,icq.len))
           {
            //--- formatting message
            MqlDateTime mqldt;
            datetime dt=TimeLocal();
            TimeToStruct(dt,mqldt);
            string msg=StringFormat("%s (%02d:%02d:%02d) %s",FindNickName(icq.uin),mqldt.hour,mqldt.min,mqldt.sec,icq.msg);
            label_msg[0].SetString(OBJPROP_TEXT,label_msg[1].GetString(OBJPROP_TEXT));
            label_msg[1].SetString(OBJPROP_TEXT,label_msg[2].GetString(OBJPROP_TEXT));
            label_msg[2].SetString(OBJPROP_TEXT,msg);
            //Print(msg);
            PlaySound("alert2");
            ChartRedraw();
           }
         break;

      case STATE_DISCONNECTED:
         break;

      case STATE_PROCESSING:
         break;
     }

  }
//+------------------------------------------------------------------+
//|   OnChartEvent                                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   CPoint p;
   p.x=(int)lparam;
   p.y=(int)dparam;

   if(id==CHARTEVENT_CLICK)
     {
      //--- click on send
      if(PointInRect(p,r_send.rect))
        {
         ButtonOnClick(r_send);
         string msg=edit_message.GetString(OBJPROP_TEXT);
         edit_message.SetString(OBJPROP_TEXT,"");

         if(icq.State()==STATE_CONNECTED)
           {
            string _contact=edit_contact.GetString(OBJPROP_TEXT);
            if(msg!="" && _contact!="")
               icq.SendMessage(_contact,msg);
           }
         ChartRedraw();
        }

      //--- click on close
      if(PointInRect(p,r_close.rect))
        {
         ButtonOnClick(r_close);
         if(icq.State()==STATE_CONNECTED) icq.Disconnect();
         ExpertRemove();
        }

      //--- click on clear
      if(PointInRect(p,r_clear.rect))
        {
         ButtonOnClick(r_clear);
         for(int i=0;i<3;i++)
            label_msg[i].SetString(OBJPROP_TEXT," ");
         ChartRedraw();
        }

      //--- account left
      if(PointInRect(p,r_left1.rect))
        {
         if(button_state==STATE_CONNECTED)return;

         ButtonOnClick(r_left1);
         if(account.Total()>0)
           {
            //ClickAnimation(r_left1);
            CAccountInfo *info=account.GetPrevNode();
            if(info==NULL)info=account.GetLastNode();
            edit_login.SetString(OBJPROP_TEXT,IntegerToString(info.Login));

            //--- fil password
            string pass=info.Password;
            StringFill(pass,'*');
            edit_password.SetString(OBJPROP_TEXT,pass);
            ChartRedraw();
           }
         return;
        }
      //--- accounts right
      if(PointInRect(p,r_right1.rect))
        {
         if(button_state==STATE_CONNECTED)return;

         ButtonOnClick(r_right1);
         if(account.Total()>0)
           {
            CAccountInfo *info=account.GetNextNode();
            if(info==NULL)info=account.GetFirstNode();
            edit_login.SetString(OBJPROP_TEXT,IntegerToString(info.Login));

            //--- fil password
            string pass=info.Password;
            StringFill(pass,'*');
            edit_password.SetString(OBJPROP_TEXT,pass);
            ChartRedraw();
           }
         return;
        }

      //--- contacts left
      if(PointInRect(p,r_left2.rect))
        {
         ButtonOnClick(r_left2);
         if(contact.Total()>0)
           {
            CAccountInfo *info=contact.GetPrevNode();
            if(info==NULL)info=contact.GetLastNode();
            edit_contact.SetString(OBJPROP_TEXT,IntegerToString(info.Login));
            label_nickname.SetString(OBJPROP_TEXT,info.NickName);
            ChartRedraw();
           }
        }

      //--- contacts right
      if(PointInRect(p,r_right2.rect))
        {
         ButtonOnClick(r_right2);
         if(contact.Total()>0)
           {
            CAccountInfo *info=contact.GetNextNode();
            if(info==NULL)info=contact.GetFirstNode();
            edit_contact.SetString(OBJPROP_TEXT,IntegerToString(info.Login));
            label_nickname.SetString(OBJPROP_TEXT,info.NickName);
            ChartRedraw();
           }

        }

      //--- sign/cancel
      if(PointInRect(p,r_signin.rect))
        {

         switch(button_state)
           {
            case STATE_CONNECTED:
               icq.Disconnect();
               ResourceOnClick(r_signout);
               for(int i=0;i<3;i++)
                  label_msg[i].SetString(OBJPROP_TEXT," ");
               ChartRedraw();
               break;

            case STATE_DISCONNECTED:
              {
               ResourceOnClick(r_signin);

               string login=edit_login.GetString(OBJPROP_TEXT);
               string password=edit_password.GetString(OBJPROP_TEXT);

               if(login!="" && password!="")
                 {
                  if(StringGetCharacter(password,0)=='*')
                     FindPassword(login,password);

                  icq.Login(login);
                  icq.Password(password);
                  //Print(login," ",password);
                  icq.Connect();
                 }
              }
            break;
            //---
            case STATE_PROCESSING:
               ResourceOnClick(r_cancel);
               break;

           }
        }
     }
  }
//+------------------------------------------------------------------+
//|   LoadBitmap                                                     |
//+------------------------------------------------------------------+
bool LoadBitmap(CCanvas &canvas,CResource &res,int shift=0)
  {
   uint data[];
   uint width;
   uint height;

//--- get bitmap data
   if(!ResourceReadImage("\\Experts\\"+MQLInfoString(MQL_PROGRAM_NAME)+res.name,data,width,height))
     {
      Print("Cannot load resource image ",res.name);
      return(false);
     }

//--- resize
   if(canvas.Width()<(int)(width+res.rect.left) || canvas.Height()<(int)(height+res.rect.top))
      canvas.Resize((int)(width+res.rect.left),(int)(height+res.rect.top));

//--- fill,
   for(uint x=0; x<width; x++)
      for(uint y=0; y<height; y++)
         canvas.PixelSet(res.rect.left+x+shift,res.rect.top+y+shift,data[width*y+x]);

   res.rect.Height(height);
   res.rect.Width(width);

   return(true);
  }
//+------------------------------------------------------------------+
//|   DrawText                                                       |
//+------------------------------------------------------------------+
//void DrawText(CCanvas &canvas,const string text,CPoint &point)
void DrawText(CCanvas &canvas,const string text,const int x,const int y)
  {
   canvas.FontSet("Arial",16);
   canvas.TextOut(x,y,text,clrBlack);
  }
//+------------------------------------------------------------------+
//|   AddInfoToList                                                  |
//+------------------------------------------------------------------+
void AddInfoToList(CList &list,const uint login,const string password,const string nick_name)
  {
   list.Add(new CAccountInfo);
   CAccountInfo *info=list.GetCurrentNode();
   info.Login=login;
   info.Password=password;
   info.NickName=nick_name;
  }
//+------------------------------------------------------------------+
//|   SetResourceInfo                                                |
//+------------------------------------------------------------------+
void SetResourceInfo(CResource &res,const string name,const int x,const int y,const int width,const int height)
  {
   res.name=name;
   res.rect.LeftTop(x,y);
   res.rect.Height(height);
   res.rect.Width(width);
  }
//+------------------------------------------------------------------+
//|   DrawSkin                                                       |
//+------------------------------------------------------------------+
bool DrawSkin()
  {
   skin.Erase();

//--- background
   if(!LoadBitmap(skin,r_skin))return(false);

   switch(button_state)
     {
      case STATE_CONNECTED:
         if(!LoadBitmap(skin,r_signout))return(false);
         label_login.SetString(OBJPROP_TEXT,icq.Login());
         break;
      case STATE_DISCONNECTED:
         if(!LoadBitmap(skin,r_signin))return(false);
         label_login.SetString(OBJPROP_TEXT," ");
         break;
      case STATE_PROCESSING:
         if(!LoadBitmap(skin,r_cancel))return(false);
         label_login.SetString(OBJPROP_TEXT," ");
         break;
     }
//---
   skin.Update();
//---   
   return(true);
  }
//+------------------------------------------------------------------+
//|   ButtonOnClick                                                  |
//+------------------------------------------------------------------+
bool ButtonOnClick(CResource &res)
  {
   uint data[];
   int width;
   int height;

//--- get bitmap data
   if(!ResourceReadImage("\\Experts\\"+MQLInfoString(MQL_PROGRAM_NAME)+r_skin.name,data,width,height))
     {
      Print("Cannot load resource image ",r_skin.name);
      return(false);
     }

//--- resize
   if(skin.Width()<(int)(width+r_skin.rect.left) || skin.Height()<(int)(height+r_skin.rect.top))
      skin.Resize((int)(width+r_skin.rect.left),(int)(height+r_skin.rect.top));



   skin.Erase();

//--- button down
   for(int x=0; x<width; x++)
      for(int y=0; y<height; y++)
        {

         if(x>=res.rect.left && x<=res.rect.right &&
            y>=res.rect.top && y<=res.rect.bottom)
           {
            skin.PixelSet(r_skin.rect.left+x,r_skin.rect.top+y,data[width*(y-1)+x-1]);
            skin.PixelSet(r_skin.rect.left+x+1,r_skin.rect.top+y+1,data[width*y+x]);
           }
         else
            skin.PixelSet(r_skin.rect.left+x,r_skin.rect.top+y,data[width*y+x]);
        }

   switch(button_state)
     {
      case STATE_CONNECTED: if(!LoadBitmap(skin,r_signout))return(false);break;
      case STATE_DISCONNECTED: if(!LoadBitmap(skin,r_signin))return(false); break;
      case STATE_PROCESSING: if(!LoadBitmap(skin,r_cancel))return(false);  break;
     }

   skin.Update();

//---
   Sleep(70);

//--- button up
   skin.Erase();

   for(int x=0; x<width; x++)
      for(int y=0; y<height; y++)
         skin.PixelSet(r_skin.rect.left+x,r_skin.rect.top+y,data[width*y+x]);

   switch(button_state)
     {
      case STATE_CONNECTED: if(!LoadBitmap(skin,r_signout))return(false);break;
      case STATE_DISCONNECTED: if(!LoadBitmap(skin,r_signin))return(false); break;
      case STATE_PROCESSING: if(!LoadBitmap(skin,r_cancel))return(false);  break;
     }

   skin.Update();
   return(true);
  }
//+------------------------------------------------------------------+
//|   ResourceOnClick                                                |
//+------------------------------------------------------------------+
bool ResourceOnClick(CResource &res)
  {
   skin.Erase();
//--- background
   if(!LoadBitmap(skin,r_skin))return(false);
   if(!LoadBitmap(skin,res,1))return(false);

   skin.Update();
   Sleep(70);
   skin.Erase();
//--- background
   if(!LoadBitmap(skin,r_skin))return(false);
   if(!LoadBitmap(skin,res))return(false);

   skin.Update();

   return(true);
  }
//+------------------------------------------------------------------+
//|   FindPassword                                                   |
//+------------------------------------------------------------------+
bool FindPassword(const string login,string &password)
  {
   int total= account.Total();
   for(int i=0;i<total;i++)
     {
      CAccountInfo *info=account.GetNodeAtIndex(i);
      if(IntegerToString(info.Login)==login)
        {
         password=info.Password;
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|   FindNickName                                                   |
//+------------------------------------------------------------------+
string FindNickName(const string uin)
  {
   int total= contact.Total();
   for(int i=0;i<total;i++)
     {
      CAccountInfo *info=contact.GetNodeAtIndex(i);
      if(StringCompare(IntegerToString(info.Login),uin,false)==0)return(info.NickName);
     }
   return(uin);
  }
//+------------------------------------------------------------------+
//|   PointInRect                                                    |
//+------------------------------------------------------------------+
bool PointInRect(CPoint &point,CRect &rect)
  {
   if(point.x>=rect.left && point.x<=rect.right &&
      point.y>=rect.top && point.y<=rect.bottom)return(true);
   return(false);
  }
//+------------------------------------------------------------------+
