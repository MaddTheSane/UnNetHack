/* next.m
   93/07/31
*/

#define NEED_VARARGS

#include "../include/tradstdc.h"
#import <strings.h>
#import <stdio.h> 
#import "NethackApp.h"
#import "NethackView.h"
#import "next.h"

void WindowPutstr();

/* Global Msg structs */
simpleMsg drawMsg;
stringMsg	putsMsg;
BOOL UseCursor;

/* external declerations */
extern id HackView;
extern char theChar;
extern BOOL NewKey;

extern int main_orig(int argc,char *argv[]);
extern char curx,cury;
extern char tly;
extern int CO;

void start_app(int argc, char *argv[]) {

    [NethackApp new];
    printf("starting nethack ...\n");
    if ([NXApp loadNibFile:"English.Iproj/Nethack.nib" owner:NXApp withNames:NO])
	    [NXApp run];
	    
    [NXApp free];
    exit(0);
}

void nethack_thread(int i)
{
	mutex_lock(NHlock);
	printf("In nethack_thread:\n");
	mutex_unlock(NHlock);
	main_orig(NXArgc, NXArgv);
}

void start_main()
{
	IsReady = NO;
	charbuf = 0;
	NHlock = mutex_alloc();
	start_c = condition_alloc();
	drawMsg.h.msg_simple = TRUE; 	// no ports or out-of-line data
	drawMsg.h.msg_size = sizeof(simpleMsg);
	drawMsg.h.msg_local_port = PORT_NULL;
	drawMsg.h.msg_type = MSG_TYPE_NORMAL;
	drawMsg.t.msg_type_name = MSG_TYPE_BYTE;
	drawMsg.t.msg_type_size = 8;
	drawMsg.t.msg_type_number = MAXDATA;
	drawMsg.t.msg_type_inline = TRUE;	// no out-of-line data will be passed
	drawMsg.t.msg_type_longform = FALSE;	drawMsg.t.msg_type_deallocate = FALSE;
	drawMsg.h.msg_remote_port = [NXApp drawPort]; //set port to send drawing to

	putsMsg.h.msg_simple = TRUE; 	// no ports or out-of-line data
	putsMsg.h.msg_size = sizeof(stringMsg);
	putsMsg.h.msg_local_port = PORT_NULL;
	putsMsg.h.msg_type = MSG_TYPE_NORMAL;
	putsMsg.t.msg_type_name = MSG_TYPE_BYTE;
	putsMsg.t.msg_type_size = 8;
	putsMsg.t.msg_type_number = MAXSDATA;
	putsMsg.t.msg_type_inline = TRUE;	// no out-of-line data will be passed
	putsMsg.t.msg_type_longform = FALSE;	putsMsg.t.msg_type_deallocate = FALSE;
	putsMsg.h.msg_remote_port = [NXApp putsPort]; //set port to send drawing to
	
	printf("detaching cthread:\n");
	cthread_detach(cthread_fork((cthread_fn_t)nethack_thread, (any_t)0));
}

void exit_main(int status)
{
	// Notifying main thread that we are exiting ...
	drawMsg.h.msg_id = EXIT_MSG;
	drawMsg.position[0] = status;
	msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
	cthread_exit(0);
}

char WindowGetchar()
{
	char ch;
	
	mutex_lock(NHlock);
	if(charbuf != 0) {
		ch = charbuf;
		charbuf = 0;
		mutex_unlock(NHlock);
		return ch;
	}
	else {
		while(charbuf == 0)
			condition_wait(start_c, NHlock);
		ch = charbuf;
		charbuf = 0;
		mutex_unlock(NHlock);
		if (ch == 13)
			ch = '\n';
		return ch;
	}
	
}

void WindowPutchar(char c)
{
    drawMsg.h.msg_id = PUTCHAR_MSG;
    drawMsg.c = c;
    drawMsg.typ = TYPE_CHAR;
    drawMsg.position[0] = curx;
    drawMsg.position[1] = cury;
    msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
} 

void WindowGPutchar(char c)
{
    drawMsg.h.msg_id = PUTCHAR_MSG;
    drawMsg.c = c;
    drawMsg.typ = TYPE_GRAPHICS;
    drawMsg.position[0] = curx;
    drawMsg.position[1] = cury;
    msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
} 

void WindowCPutchar(char c, char color)
{
    drawMsg.h.msg_id = PUTCHAR_MSG;
    drawMsg.c = c;
    drawMsg.typ = TYPE_CGRAPHICS;
    drawMsg.col = color;
    drawMsg.position[0] = curx;
    drawMsg.position[1] = cury;
    msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
} 

void WindowPuts(char *s)
{
    strcpy(putsMsg.string, s);
    putsMsg.h.msg_id = PUTS_MSG;
    putsMsg.position[0] = curx;
    putsMsg.position[1] = cury;
    msg_send((msg_header_t *)&putsMsg,MSG_OPTION_NONE,0);
}

void WindowFPuts(char *s)
{
    strcpy(putsMsg.string, s);
    putsMsg.h.msg_id = PUTS_MSG;
    putsMsg.position[0] = curx;
    putsMsg.position[1] = cury;
    msg_send((msg_header_t *)&putsMsg,MSG_OPTION_NONE,0);
}

void
WindowPrintf VA_DECL(const char *, s)
	VA_START(s);
	VA_INIT(s, char *);
        {static char buf[180];
	vsprintf(buf,s,VA_ARGS);
	WindowPutstr(buf);
        }	/* Overloaded */
	VA_END();
}

void WindowFlush()
{

}

void
curs(x, y)
register int x, y;
{
   cury = y;
   curx = x;
   if (UseCursor) {
    	drawMsg.h.msg_id = CURS_MSG;
    	drawMsg.c = 0;
   	drawMsg.position[0] = curx;
   	drawMsg.position[1] = cury;
    	msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
    }
}

void
home()
{
    curx = cury = 1;
    drawMsg.h.msg_id = HOME_MSG;
    drawMsg.c = 0;
    drawMsg.position[0] = curx;
    drawMsg.position[1] = cury;
    msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
}

void
clear_screen()
{
    home();
    drawMsg.h.msg_id = CLS_MSG;
    drawMsg.c = 0;
    drawMsg.position[0] = curx;
    drawMsg.position[1] = cury;
    msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
}

void
bell()
{
   //  if (flags.silent) return;
    drawMsg.h.msg_id = BELL_MSG;
    drawMsg.c = 0;
    drawMsg.position[0] = curx;
    drawMsg.position[1] = cury;
    msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
}

void
cl_end()
{
    drawMsg.h.msg_id = CLEND_MSG;
    drawMsg.c = 0;
    drawMsg.position[0] = curx;
    drawMsg.position[1] = cury;
    msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
}

void
WindowPutstr(const char *s)
{
    static char buf[180];
    int pos1=0, i;
    
   //  curx=1; cury=1;
    
    for(i=0;s[i] != 0;i++) {
    	switch(s[i]) {
	case '\n':
		strncpy(buf,s+pos1,i);
		buf[i] = 0;
		pos1 = ++i;
		WindowPuts(buf);
		curx = 1;
		++cury;
		if(cury > tly) tly = cury;
		break;
	case '\b':
		--curx;
		WindowPutchar(' ');
		break;
	default:
		if(curx == CO) {
			strncpy(buf,s+pos1,i);
			buf[i] = 0;
			pos1 = i;
			WindowPuts(buf);
			curx = 1;
			++cury;
			if(cury > tly) tly = cury;
		}
		break;
	}
    }
    WindowPuts(s+pos1);
    curx+=strlen(s+pos1);
}

void WindowCursor(char state)
{
	if (state == FALSE) {
		drawMsg.h.msg_id = CURSOFF_MSG;
    		drawMsg.c = 0;
   		drawMsg.position[0] = curx;
   		drawMsg.position[1] = cury;
    		msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
	}
	UseCursor = (BOOL)state;
}

void WindowWindow(char state)
{
	if (state == FALSE) {
		drawMsg.h.msg_id = WIN_MSG;
    		drawMsg.c = (char)NO;
   		drawMsg.position[0] = curx;
   		drawMsg.position[1] = cury;
    		msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
	} else {
		drawMsg.h.msg_id = WIN_MSG;
    		drawMsg.c = (char)YES;
   		drawMsg.position[0] = curx;
   		drawMsg.position[1] = cury;
    		msg_send((msg_header_t *)&drawMsg,MSG_OPTION_NONE,0);
	}
}

void WindowSound(char *s)
{
    strcpy(putsMsg.string, s);
    putsMsg.h.msg_id = SOUND_MSG;
    putsMsg.position[0] = curx;
    putsMsg.position[1] = cury;
    msg_send((msg_header_t *)&putsMsg,MSG_OPTION_NONE,0);
}
