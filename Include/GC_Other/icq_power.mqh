//+------------------------------------------------------------------+
//|                                                    icq_power.mqh |
//|              Copyright Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|   LUID                                                           |
//+------------------------------------------------------------------+
struct LUID
  {
   uint              LowPart;
   uint              HighPart;
  };
//+------------------------------------------------------------------+
//|   LUID_AND_ATTRIBUTES                                            |
//+------------------------------------------------------------------+
struct LUID_AND_ATTRIBUTES
  {
   LUID              Luid;
   uint              Attributes;
  };
//+------------------------------------------------------------------+
//|   TOKEN_PRIVILEGES                                               |
//+------------------------------------------------------------------+
struct TOKEN_PRIVILEGES
  {
   uint              PrivilegeCount;
   LUID_AND_ATTRIBUTES Privileges[1];
  };

//+------------------------------------------------------------------+
//|   DLL                                                            |
//+------------------------------------------------------------------+
#import "advapi32.dll"
bool OpenProcessToken(uint ProcessHandle,uint DesiredAccess,uint &TokenHandle);
bool LookupPrivilegeValueW(string lpSystemName,string lpName,LUID &lpLuid);
bool AdjustTokenPrivileges(uint TokenHandle,bool DisableAllPrivileges,TOKEN_PRIVILEGES &NewState,uint BufferLength,uint PreviousState,uint ReturnLength);
#import "user32.dll"
bool ExitWindowsEx(uint uFlags,uint dwReason);
#import "kernel32.dll"
uint GetCurrentProcess(void);
//int GetLastError();
#import

//+------------------------------------------------------------------+
//|   Defines                                                        |
//+------------------------------------------------------------------+
#define TOKEN_ADJUST_PRIVILEGES  0x0020
#define TOKEN_QUERY              0x0008
#define SE_SHUTDOWN_NAME         "SeShutdownPrivilege"
#define SE_PRIVILEGE_ENABLED     0x00000002
#define EWX_SHUTDOWN             0x00000001
#define EWX_FORCE                0x00000004

//---
const string  op[2] = {"?","!"};
const string cmd[8] = {"HELP","INFO","SYMB","ORDS","PARAM","ALERT","CLOSE","SHDWN"};
//+----------------------------------------------------------------+
//    commands 
//    syntax: [?|!][command][parameter][value]
//+----------------------------------------------------------------+    
/*
      help - help on commands;
      info - account information;
      symb [symbol] - price of the specified symbol;
      ords [close|sl|tp][value] - opened orders modification;
      param [sl|tp|p0|p1|p2] [value] - variables modification;
      close - close terminal;
      shdwn - turn off PC;             
*/

//+------------------------------------------------------------------+
//|   ExtractSubString                                               |
//+------------------------------------------------------------------+
string ExtractSubString(string source,uint start_pos)
  {
   string dest;
   uint len=StringLen(source);
   bool shift=false;
   uint pos;

   StringInit(dest,len,0);
   pos=0;

   if(start_pos<len)
     {
      for(uint i=start_pos; i<len; i++)
        {
         if(StringGetCharacter(source,i)!=0x20)
           {
            StringSetCharacter(dest,pos++,StringGetCharacter(source,i));
            shift=true; // flag of the text beginning
           }
         else if(shift) break;
        }
     }

   return(dest);
  };
//+------------------------------------------------------------------+
//|   ParseString                                                    |
//+------------------------------------------------------------------+
bool ParseString(string msg,string &part[])//
  {
   bool   ret;
   uint   len;
   uint   start_pos=0;
   string buf=msg;
   string substr;
   ushort chr;

   StringToUpper(buf);//  transform to uppercase for the lines analysis

   StringInit(part[0],20,0);
   StringInit(part[1],20,0);
   StringInit(part[2],20,0);
   StringInit(part[3],20,0);

   for(int i=0; i<5; i++)// extraction of substrings from a string
     {
      substr=ExtractSubString(buf,start_pos);
      if(substr==NULL)break;
      part[i]=substr;
      start_pos=start_pos+StringLen(substr)+1;
     }

//--- Analysis of the substrings
   len=StringLen(part[0]);

   if(len==0) return(false);

   else if(len==1)
     {
      // part0 - if command symbol is absent
      if(!((part[0]==op[0]) || (part[0]==op[1])))return(false);

      // part1-check command text
      ret=false;
      for(int i=0; i<ArrayRange(cmd,0); i++)
        {
         if(StringFind(part[1],cmd[i],0)!=-1)// string found
           {
            ret=true; break;
           }
        }
      return(ret);
     }
   else // if the first substring has more than one char 
     {
      chr=StringGetCharacter(buf,0);
      // part[0]
      if(!((chr=='!') || (chr=='?'))) return(false);

      // part[1]
      ret=false;
      for(int i=0; i<ArrayRange(cmd,0); i++)
        {
         if(StringFind(part[0],cmd[i],1)!=-1)// string found
           {
            part[4] = part[3];
            part[3] = part[2];
            part[2] = part[1];
            part[1] = cmd[i];

            StringSetCharacter(part[0],0,chr);
            StringSetCharacter(part[0],1,0);

            ret=true;
            break;
           }
        }
      return(ret);
     }

   return(true);
  }
//+------------------------------------------------------------------+
//|   ShutdownWindows                                                |
//+------------------------------------------------------------------+
int ShutdownWindows()
  {
   uint              hToken;
   LUID              takeOwnershipValue;
   TOKEN_PRIVILEGES  tkp;
//---
   if(!OpenProcessToken(GetCurrentProcess(),TOKEN_ADJUST_PRIVILEGES|TOKEN_QUERY,hToken)) return(0);
   if(!LookupPrivilegeValueW("",SE_SHUTDOWN_NAME,takeOwnershipValue)) return(0);
//---
   tkp.PrivilegeCount=1;
   tkp.Privileges[0].Luid=takeOwnershipValue;
   tkp.Privileges[0].Attributes=SE_PRIVILEGE_ENABLED;

   if(!AdjustTokenPrivileges(hToken,false,tkp,sizeof(TOKEN_PRIVILEGES),0,0))
   return(0);

   return(ExitWindowsEx(EWX_FORCE|EWX_SHUTDOWN,0));
  }
//+------------------------------------------------------------------+
