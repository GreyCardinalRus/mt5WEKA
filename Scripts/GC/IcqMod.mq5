//+------------------------------------------------------------------+
//|                                                       IcqMod.mq5 |
//|                                                     GreyCardinal |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "GreyCardinal"
#property link      "http://www.mql5.com"
#property version   "1.00"
struct ICQ_CLIENT
{
        uchar status;
        ushort sequence;
        ulong sock;
};

#import "IcqMod.dll"
   ulong ICQConnect(ICQ_CLIENT& client, uchar& host[], ushort port, uchar& login[], uchar& pass[], int proxy);
   void  ICQClose(ICQ_CLIENT& client);
   ulong ICQSendMsg(ICQ_CLIENT& client, uchar& uin[], uchar& message[]);
   ulong ICQReadMsg(ICQ_CLIENT& client, uchar& uin[], uchar& msg[], int& msglen);
#import

void OnStart()
{
   // ��������� ������ � ������ �������� ��� �������� � dll
   uchar login[], password[], server[];
   StringToCharArray("645990858", login);
   StringToCharArray("Forex7", password);
   StringToCharArray("login.icq.com", server);
   
   // ������������
   ICQ_CLIENT client;
   ICQConnect(client, server, 5190, login, password, 0);
   
   for (;;)
   {
      uchar uinR[10], msgR[512];
      int len = 0;
      
      // ��������� �� �������� ���������
      ICQReadMsg(client, uinR, msgR, len);
      
      if (len > 0)
      {
         string uinStr = CharArrayToString(uinR), // UIN �����������
            msgStr = CharArrayToString(msgR);     // ���������
            
         uchar msgS[];
         // ��������� ����� ���������� ��������: � �������� �������
         StringToCharArray("��������: " + msgStr, msgS);
         ICQSendMsg(client, uinR, msgS); 
      }

      Sleep(100);
   }
  }