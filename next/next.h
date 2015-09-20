/* next.h
   93/08/02
*/

#import <mach/cthreads.h>
#import "../include/color.h"

#define MAXPCHARS	35
#define SYMOFFS	128

#define HHEIGHT	24
 
#define X_PS(x)	fontx*x
#define Y_PS(y)	FONTSIZE*(HHEIGHT-y)
#define CLEARBG	PSsetgray(NX_BLACK); \
PSrectfill(x*fontx,(HHEIGHT-y)*FONTSIZE-2,FONTSIZE,FONTSIZE);
#define CLEARBGL(l)	PSsetgray(NX_BLACK); \
PSrectfill(x*fontx,(HHEIGHT-y)*FONTSIZE-2,FONTSIZE*l,FONTSIZE);

#define TYPE_CHAR	0
#define TYPE_GRAPHICS	1
#define TYPE_CGRAPHICS	2

#define MAXDATA 11	/* Message struct used to send drawing messages */
typedef struct {
    msg_header_t h;
    msg_type_t t;
    int position[2];	/* position of cursor */
    char c;	/* char to print */
    char typ;	/* type */
    char col;	/* color */
} simpleMsg;

#define MAXSDATA 188	/* Message struct used to send string drawing messages */
typedef struct {
    msg_header_t h;
    msg_type_t t;
    int position[2];	/* position of cursor */
    char string[180];	/* string to print */
} stringMsg;

#define PUTCHAR_MSG 0	/* Constants to identify the different messages */
#define PUTS_MSG 1  
#define CLS_MSG 2  
#define BELL_MSG 3
#define HOME_MSG 4
#define CLEND_MSG	5
#define EXIT_MSG	6
#define CURS_MSG	7
#define CURSOFF_MSG	8
#define WIN_MSG	9
#define SOUND_MSG		10

void WindowPrintf(const char *, ...);

mutex_t		NHlock;
condition_t	start_c;
volatile BOOL	IsReady;
volatile char	charbuf;
volatile char NHstring[180];
float fontx;
