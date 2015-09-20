/*    nexttcap.c 12/93 */
/* NEXTSTEP graphical version file */
/* NetHack may be freely redistributed.  See license for details. */

#include <ctype.h>	/* for isdigit() */

#define FONTSIZE	12

#define MAXPCHARS	35
#define MAXMCHARS	(MAXPCHARS+59)
#define SYMOFFS	128

boolean IBMgraphics = FALSE;


static char HO[] = "\233H";         /* Home         CSI H */
static char CL[] = "\f";            /* Clear        FF */
static char CE[] = "\233K";         /* Erase EOL    CSI K */
static char UP[] = "\x0B";          /* Cursor up    VT */
static char ND[] = "\233C";         /* Cursor right CSI C */
static char XD[] = "\233B";         /* Cursor down  CSI B */
static char BC[] = "\b";            /* Cursor left  BS */
static char MR[] = "\2337m";        /* Reverse on   CSI 7 m */
static char ME[] = "\2330m";        /* Reverse off  CSI 0 m */

#ifdef TEXTCOLOR
static char SO[] = "\23337m";       /* Use colormap entry #7 (red) */
static char SE[] = "\2330m";
#else
static char SO[] = "\2337m";        /* Inverse video */
static char SE[] = "\2330m";
#endif

#ifdef TEXTCOLOR
/*
 * Map our next-specific colormap into the colormap specified in color.h.
 * See nextwind.c for the next specific colormap.
 */
static int foreg[16] = { 0, 7, 4, 2, 6, 5, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0 };
static int backg[16] = { 1, 0, 0, 0, 0, 0, 0, 0, 1, 7, 4, 2, 6, 5, 3, 1 };
#endif

/* Symbol arrays used to map graphical images: */
symbol_array nextsyms = {
    SYMOFFS+1, /* stone */
    SYMOFFS+2, /* vwall */
    SYMOFFS+3, /* hwall */
    SYMOFFS+4, /* tlcorn */
    SYMOFFS+5, /* trcorn */
    SYMOFFS+6, /* blcorn */
    SYMOFFS+7, /* brcorn */
    SYMOFFS+8, /* crwall */
    SYMOFFS+9, /* tuwall */
    SYMOFFS+10, /* tdwall */
    SYMOFFS+11, /* tlwall */
    SYMOFFS+12, /* trwall */
    SYMOFFS+13, /* vbeam */
    SYMOFFS+14, /* hbeam */
    SYMOFFS+15, /* lslant */
    SYMOFFS+16, /* rslant */
    SYMOFFS+17, /* ndoor */
    SYMOFFS+18, /* vodoor */
    SYMOFFS+19, /* hodoor */
    SYMOFFS+20, /* cdoor */
    SYMOFFS+21, /* room */
    SYMOFFS+22, /* corr */
    SYMOFFS+23, /* upstair */
    SYMOFFS+24, /* dnstair */
    SYMOFFS+25, /* trap */
    SYMOFFS+26, /* web */
    SYMOFFS+27, /* pool */
    SYMOFFS+28, /* fountain */	/* used ifdef FOUNTAINS */
    SYMOFFS+29, /* sink */	/* used ifdef SINKS */
    SYMOFFS+30, /* throne */	/* used ifdef THRONES */
    SYMOFFS+31, /* altar */	/* used ifdef ALTARS */
    SYMOFFS+32, /* upladder */	/* used ifdef STRONGHOLD */
    SYMOFFS+33, /* dnladder */	/* used ifdef STRONGHOLD */
    SYMOFFS+34, /* dbvwall */	/* used ifdef STRONGHOLD */
    SYMOFFS+35, /* dbhwall */	/* used ifdef STRONGHOLD */
};


void
startup()
{
#ifdef TEXTCOLOR
    register int c;
#endif
    /* (void) Initialize();  */      /* This opens screen, window, console, &c */
    CO = COLNO;
    LI = ROWNO+3;               /* used in pri.c and pager.c */

    /* Set the default map symbols */
    (void) memcpy((genericptr_t) showsyms, 
	(genericptr_t) nextsyms, sizeof showsyms);

    set_whole_screen();
    CD = "\233J";               /* used in pager.c */

#ifdef TEXTCOLOR
    /*
     * Perform amiga to color.h colormap conversion - Please note that the
     * console device can only handle 8 foreground and 8 background colors
     * while color.h defines 8 basic and 8 hilite colors.  Hilite colors
     * are handled as inverses.  For instance, a hilited green color will
     * appear as green background with a black foreground.
     */
    for (c = 0; c < SIZE(hilites); c++) {
        hilites[c] = (char *) alloc(sizeof("E0;33;44m"));
        Sprintf(hilites[c], "\2333%d;4%dm", foreg[c], backg[c]);
    }

    HI = "\2331m";              /* Bold (hilight) */
    HE = "\2330m";              /* Plain */
#else
    HI = "\2334m";              /* Underline */
    HE = "\2330m";              /* Plain */
#endif
}

void
start_screen()
{
}

void
end_screen()
{
    clear_screen();
}

/* Cursor movements */
extern xchar curx, cury;

#ifdef CLIPPING
/* if (x,y) is currently viewable, move the cursor there and return TRUE */
boolean
win_curs(x, y)
int x, y;
{
	if (clipping && (x<=clipx || x>=clipxmax || y<=clipy || y>=clipymax))
		return FALSE;
	y -= clipy;
	x -= clipx;
	curs(x, y+2);
	return TRUE;
}
#endif


void
cmov(x, y)
register int x, y;
{
	cury = y;
	curx = x;
}



void
standoutbeg()
{
   // xputs(SO);
}

void
standoutend()
{
  //  xputs(SE);
}

void
revbeg()
{
     //   xputs(MR);
}

#if 0   /* if you need one of these, uncomment it */
void
boldbeg()
{
    //    xputs("\2331m");        /* CSI 1 m */
}

void
blinkbeg()
{
        /* No blink available */
}

void
dimbeg()
/* not in most termcap entries */
{
        /* No dim available, use italics */
    //    xputs("\2333m");        /* CSI 3 m */
}
#endif

void
m_end()
{
    //    xputs(ME);
}

void
backsp()
{
 //   xputs(BC);
}


void
graph_on() {
//	if (AS) xputs(AS);
}

void
graph_off() {
//	if (AE) xputs(AE);
}

void
delay_output() {
    /* delay 50 ms */
    (void) fflush(stdout);
    /*Delay(2L); */
}

void
cl_eos()
{                /* must only be called with curx = 1 */
  //  xputs(CD);
}
