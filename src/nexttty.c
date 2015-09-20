/*    SCCS Id: @(#)nexttty.c     3.0    93/07/30
/* NetHack may be freely redistributed.  See license for details. */
/* tty.c - (NeXT) version */


#define NEED_VARARGS
#include "hack.h"

char erase_char, kill_char;

/*
 * Get initial state of terminal, set ospeed (for termcap routines)
 * and switch off tab expansion if necessary.
 * Called by startup() in termcap.c and after returning from ! or ^Z
 */
void gettty()
{
    erase_char = 127;	    /* DEL */
    kill_char = 21;	    /* cntl-U */
    flags.cbreak = TRUE;
    curx = 1;
    cury = 1;
}

/* reset terminal to original state */
void settty(s)
const char *s;
{
    end_screen();
    if (s) {
	printf(s);
    }
    (void) fflush(stdout);
    /* Do not close the screen, that is done in msexit() */
}

void setftty()
{
}

void introff()
{
}

void intron()
{
}


/* fatal error */
/*VARARGS1*/
void
error VA_DECL(const char *, s)
	VA_START(s);
	VA_INIT(s, char *);
	end_screen();
	putchar('\n');

        {char buf[180];
	vsprintf(buf,s,VA_ARGS);
        printf(buf);
        }	/* Overloaded */
	putchar('\n');
	VA_END();
	exit(0);
}
