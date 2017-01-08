#define ICQ_CONNECT_STATUS_OK				0xFFFFFFFF
#define ICQ_CONNECT_STATUS_RECV_ERROR		0xFFFFFFFE
#define ICQ_CONNECT_STATUS_SEND_ERROR		0xFFFFFFFD
#define ICQ_CONNECT_STATUS_CONNECT_ERROR	0xFFFFFFFC
#define ICQ_CONNECT_STATUS_AUTH_ERROR		0xFFFFFFFB

#define ICQ_CLIENT_STATUS_CONNECTED			1
#define ICQ_CLIENT_STATUS_DISCONNECTED		2

#define ICQ_DATA_TYPE_UIN					0x01
#define ICQ_DATA_TYPE_DATA					0x02
#define ICQ_DATA_TYPE_CLIENT				0x03
#define ICQ_DATA_TYPE_ERROR_URL				0x04
#define ICQ_DATA_TYPE_RECONECT_HERE			0x05
#define ICQ_DATA_TYPE_COOKIE				0x06
#define ICQ_DATA_TYPE_SNAC_VERSION			0x07
#define ICQ_DATA_TYPE_ERROR_SUBCODE			0x08
#define ICQ_DATA_TYPE_DISCONECT_REASON		0x09
#define ICQ_DATA_TYPE_RECONECT_HOST			0x0A
#define ICQ_DATA_TYPE_URL					0x0B
#define ICQ_DATA_TYPE_DEBUG_DATA			0x0C
#define ICQ_DATA_TYPE_SERVICE				0x0D
#define ICQ_DATA_TYPE_CLIENT_COUNTRY		0x0E
#define ICQ_DATA_TYPE_CLIENT_LNG			0x0F
#define ICQ_DATA_TYPE_SCRIPT				0x10
#define ICQ_DATA_TYPE_USER_EMAIL			0x11
#define ICQ_DATA_TYPE_OLD_PASSWORD			0x12
#define ICQ_DATA_TYPE_REG_STATUS			0x13
#define ICQ_DATA_TYPE_DISTRIB_NUMBER		0x14
#define ICQ_DATA_TYPE_PERSONAL_TEXT			0x15
#define ICQ_DATA_TYPE_CLIENT_ID				0x16
#define ICQ_DATA_TYPE_CLI_MAJOR_VER			0x17
#define ICQ_DATA_TYPE_CLI_MINOR_VER			0x18
#define ICQ_DATA_TYPE_CLI_LESSER_VER		0x19
#define ICQ_DATA_TYPE_CLI_BUILD_NUMBER		0x1A

#define SOCKET_CLIENT_STATUS_CONNECTED		1
#define SOCKET_CLIENT_STATUS_DISCONNECTED	2
#define SOCKET_CONNECT_STATUS_ERROR			1000
#define SOCKET_CONNECT_STATUS_OK			0

#define HTONS(a) (((0xFF&a)<<8) + ((0xFF00&a)>>8))
#define CELL_SIZE  8


#pragma pack(1)

typedef struct _SOCKET_CLIENT
{
	BYTE status;
	USHORT sequence;
	ULONG32 sock;
} SOCKET_CLIENT, *PSOCKET_CLIENT;

typedef struct _SINGLE_FD_SET
{
	UINT32 fd_count;
    ULONG32 fd_sock;
} SINGLE_FD_SET, *PSINGLE_FD_SET;


typedef struct _ICQ_HEADER
{
	BYTE cmd;
	BYTE channel;
	USHORT sequence;
	USHORT datalen;
} ICQ_HEADER, *PICQ_HEADER;

typedef struct _ICQ_MSG_HEADER
{
	USHORT family;
	USHORT subtype;
	USHORT flags;
	ULONG requestid;
	ULONG msgid[2];
	USHORT channel;
	BYTE namesize;
} ICQ_MSG_HEADER, *PICQ_MSG_HEADER;


typedef struct _ICQ_CLIENT
{
	BYTE status;
	USHORT sequence;
	ULONG sock;
} ICQ_CLIENT, *PICQ_CLIENT;

#define MAX_DATA_LEN 8192

  
typedef struct _RAWPKT 
{
	char Data[MAX_DATA_LEN];
	USHORT Len;
} RAWPKT, *PRAWPKT;


#pragma pack()

const unsigned char SNAC0102[] = {0x00, 0x01, 0x00, 0x03, 0x01, 0x10, 0x02, 0x8A, 0x00, 0x02,
	0x00, 0x01, 0x01, 0x10, 0x02, 0x8A, 0x00, 0x03, 0x00, 0x01, 0x01, 0x10, 0x02, 0x8A, 0x00, 0x15,
	0x00, 0x01, 0x01, 0x10, 0x02, 0x8A, 0x00, 0x04, 0x00, 0x01, 0x01, 0x10, 0x02, 0x8A, 0x00, 0x06,
	0x00, 0x01, 0x01, 0x10, 0x02, 0x8A, 0x00, 0x09, 0x00, 0x01, 0x01, 0x10, 0x02, 0x8A, 0x00, 0x0A,
	0x00, 0x01, 0x01, 0x10, 0x02, 0x8A};

#define HTONS(a) (((0xFF&a)<<8) + ((0xFF00&a)>>8))
#define HTOHL(x)(ULONG)((((ULONG)(x)<<24)&0xFF000000)^ \
                        (((ULONG)(x)<< 8)&0x00FF0000)^ \
                        (((ULONG)(x)>> 8)&0x0000FF00)^ \
                        (((ULONG)(x)>>24)&0x000000FF))

const wchar_t tag[6][8]   = { 
								  {0x3C,0x48,0x54,0x4D,0x4C,0x3E,0x00},			// <HTML>
								  {0x3C,0x2F,0x48,0x54,0x4D,0x4C,0x3E,0x00},	// </HTML>
								  {0x3C,0x42,0x4F,0x44,0x59,0x00},				// <BODY
								  {0x3C,0x2F,0x42,0x4F,0x44,0x59,0x3E,0x00},	// </BODY>
								  {0x3C,0x46,0x4F,0x4E,0x54,0x00},				// <FONT
								  {0x3C,0x2F,0x46,0x4F,0x4E,0x54,0x00}			// </FONT>
								};												

const unsigned char key[]={0xF3, 0x26, 0x81, 0xC4, 0x39, 0x86, 0xDB, 0x92, 0x71, 0xA3, 0xB9, 0xE6, 0x53, 0x7A, 0x95, 0x7c};