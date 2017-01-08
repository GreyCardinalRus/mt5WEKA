//+------------------------------------------------------------------+
//|                                                  WatcherFile.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <gc\Watcher.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CWatcherFile:public  CWatcher
  {
  public:
   bool              Run();
   bool SendNotify();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              CWatcherFile::Run()
  {
   CWatcher::Run();
   SendNotify();
//   SendStatus();
//   SendReport();

  return(true);
  }
bool              CWatcherFile::SendNotify()
  {
    bool ret=true;
   if(changing==0) return(true);
//--- если изменения есть то пишем файл notify.txt
   ResetLastError();
   string filename=expname+"\\"+spamfilename;
   int filehandle=FileOpen(filename,FILE_WRITE|FILE_TXT|FILE_ANSI,'\t',CP_ACP);
   if(filehandle!=INVALID_HANDLE)
     {
      for(int i=0;i<changing;i++)
        {FileWrite(filehandle,ar_sSPAM[i]);}
      FileClose(filehandle);
     }
   else Print("Не удалось открыть файл ",spamfilename,", ошибка",GetLastError());
   changing=0;

  return(true);
  }