/*	SCCS Id: @(#)nextconf.h	3.0	93/07/30
/* NetHack may be freely redistributed.  See license for details. */

#ifdef NEXT
#ifndef NEXTCONF_H
#define NEXTCONF_H


/* This is unix: */
#define UNIX
#define ULTRIX

/* using colors and graphics : */
#define TEXTCOLOR
#define ASCIIGRAPH

/* define any of the following that are appropriate */
/* #define NETWORK	/* if running on a networked system */


/*
 * Define DEF_PAGER as your default pager, e.g. "/bin/cat" or "/usr/ucb/more"
 * If defined, it can be overridden by the environment variable PAGER.
 * Hack will use its internal pager if DEF_PAGER is not defined.
 * (This might be preferable for security reasons.)
 * #define DEF_PAGER	".../mydir/mypager"
 */



/*
 * If you define MAIL, then the player will be notified of new mail
 * when it arrives.  If you also define DEF_MAILREADER then this will
 * be the default mail reader, and can be overridden by the environment
 * variable MAILREADER; otherwise an internal pager will be used.
 * A stat system call is done on the mailbox every MAILCKFREQ moves.
 */

#define MAIL			/* Deliver mail during the game */


#define	DEF_MAILREADER	"/usr/bin/mail"
#define	MAILCKFREQ	50



#ifdef COMPRESS
/* Some implementations of compress need a 'quiet' option.
 * If you've got one of these versions, put -q here.
 * You can also include any other strange options your compress needs.
 * If you have a normal compress, just leave it commented out.
 */
/* #define COMPRESS_OPTIONS	"-q"	/* */
#endif

#define	FCMASK	0660	/* file creation mask */


/*
 * The remainder of the file should not need to be changed.
 */


#include	<sys/time.h>

#define	HLOCK	"perm"	/* an empty file used for locking purposes */
#define LLOCK	"safelock"	/* link to previous */

#ifndef REDO
#define Getchar getchar
#else
#define tgetch getchar
#endif

#define SHELL		/* do not delete the '!' command */

#include "system.h"

# ifndef DGUX
#define memcpy(d, s, n)		bcopy(s, d, n)
#define memcmp(s1, s2, n)	bcmp(s2, s1, n)
# endif

/* Use the high quality random number routines. */
#define Rand()	random()
#define Srand(seed) srandom(seed)

/* Use Window functions if not in makedefs.c or lev_lex.c */

#if (!defined(MAKEDEFS_C) && !defined(LEV_LEX_C) && !defined(PANIC_C))

#undef getchar
#undef putchar
#undef fflush


#define getchar()   WindowGetchar()
#define putchar(c)  WindowPutchar(c)
#define puts(s)     WindowPuts(s)
#define fputs(s,f)  WindowFPuts(s)
#define printf	    WindowPrintf
#define fflush(fp)  WindowFlush()

#define xputs	    WindowFPuts
#define xputc	    WindowPutchar

#define g_putch(ch)	WindowGPutchar(ch)

#endif

#endif /*NEXTCONF_H /* */
#endif /* NEXT /* */
