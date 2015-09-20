/* NethackView.m
 */

#import "NethackView.h"
#import "next.h"
#import "objsymdef.h"


/* color conversion table: */
float colortbl[16][3] = { {0,0,0}, {0.7,0,0}, {0,0.7,0}, {0.25,0.33,0.55}, {0,0,0.7}, {0.7,0,0.7}, 
					{0,0.7,0.7}, {0.5,0.5,0.5}, {0,0,0}, {1,0.5,0}, {0,1,0}, {1,1,0}, {0,0,1},
					 {1,0,1}, {0,1,1}, {1,1,1}   };

/* symbol conversion table: */
char Symtbl[180] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 89, 104, 96, 0, 109, 97, 91, 0, 99, 98, 108, 111, 0, 0, 110, 106, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 93, 92, 0, 107, 0, 105, 88, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 103, 90, 95, 0, 101, 102, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 0, 0, 0, 94, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

BOOL WinDraw = NO;

@implementation NethackView

- initFrame:(const NXRect *)theFrame
{
	char imgPath[180];
	id NHImages;
	
	printf("initFrame ...\n");
	[super initFrame:theFrame];
	myFont = nil;
	ShowSymsImage = nil;
	MonSymsImage = nil;
	ObjSymsImage = nil;
	
		
	[[NXBundle mainBundle] getPath:imgPath forResource:"NHImages" ofType:"bundle"];
	NHImages = [[NXBundle alloc] initForDirectory:imgPath];
	// Loading symbol images:
	[NHImages getPath:imgPath forResource:"DefSyms" ofType:"tiff"];
	ShowSymsImage = [[NXImage allocFromZone:[self zone]]  initFromFile: imgPath];
	if (!ShowSymsImage) {
		NXRunAlertPanel(NULL,"Couldn't open def images.", NULL, NULL, NULL);
		[NXApp terminate:self];
	}
	[NHImages getPath:imgPath forResource:"MonSyms" ofType:"tiff"];
	MonSymsImage = [[NXImage allocFromZone:[self zone]]  initFromFile: imgPath];
	if (!MonSymsImage) {
		NXRunAlertPanel(NULL,"Couldn't open mon images.", NULL, NULL, NULL);
		[NXApp terminate:self];
	}
	[NHImages getPath:imgPath forResource:"ObjSyms" ofType:"tiff"];
	ObjSymsImage = [[NXImage allocFromZone:[self zone]]  initFromFile: imgPath];
	if (!ObjSymsImage) {
		NXRunAlertPanel(NULL,"Couldn't open obj images.", NULL, NULL, NULL);
		[NXApp terminate:self];
	}
	return self;
}

- drawSelf:(const NXRect *)re:(int)co
{
	return self;
}


- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)acceptsFirstMouse
{
	return YES;
}

- hitKey:(char)ch
{
	mutex_lock(NHlock);
	if (charbuf == 0) {
		charbuf = ch;
		mutex_unlock(NHlock);
	} else {
		mutex_unlock(NHlock);
		/* printf("Missed key!\n"); */
		return self;
	}
	condition_signal(start_c);
	return self;
}

- keyDown:(NXEvent *)te
{
	mutex_lock(NHlock);
	if (charbuf == 0) {
		charbuf = te->data.key.charCode;
		mutex_unlock(NHlock);
	} else {
		mutex_unlock(NHlock);
		/* printf("Missed key!\n"); */
		return self;
	}
	condition_signal(start_c);
	return self;
}

- printChar:(char)c x:(int)x y:(int)y /* This is the main function for printing simple chars*/
{
	static char ch[2];
	float rx,ry;
	
	ch[0] = c;
	ch[1] = 0;
	
	[self lockFocus];
	CLEARBG
    	[myFont set];
	PSsetgray(NX_WHITE);
	if(y >= 2 && y <= (HHEIGHT-2)) {
		rx = SYMWIDTH * x;
		ry = (HHEIGHT-y)*SYMWIDTH;
	} else {
		rx = X_PS(x);
		ry = Y_PS(y);
	}
	PSmoveto(rx, ry);
	if ( c >= ' ' && c < '~' )
		PSshow(ch);
	[self unlockFocus];
	return self;
}

- printGraphics:(char)c x:(int)x y:(int)y color:(char)col /* This is the main function for printing graphical symbols */
{
	static char ch[2];
	static NXRect myRect = { {10.0, 10.0}, {0.0, 0.0}};
	static NXPoint myPoint;
	static unsigned char tch;
	
	ch[0] = c;
	ch[1] = 0;
	myPoint.x = x * SYMWIDTH;
	myPoint.y = (HHEIGHT-y) * SYMWIDTH;
	myRect.size.width = 10.0;
	myRect.size.height = 10.0;
	
	[self lockFocus];
	tch = (unsigned char)c;
	if (tch != 0 && tch > SYMOFFS && tch <= SYMOFFS + MAXPCHARS) {
		tch-=SYMOFFS;
		myRect.origin.x = ((tch-1) % SYMROW) * SYMWIDTH;
		myRect.origin.y = (MAXSYMROWS - ((tch-1) / SYMROW)-1) * SYMWIDTH;
		[ShowSymsImage composite:NX_COPY fromRect:&myRect toPoint:&myPoint];
		[self unlockFocus];
		return self;
	}
	c = Symtbl[(int)c];	/* else do symbol tabel conversion */
	if (c != 0 && c <= MAXMCHARS) {
		c-= MAXPCHARS;
		PSsetrgbcolor(colortbl[(int)col][0], colortbl[(int)col][1],colortbl[(int)col][2]);
		PSrectfill(myPoint.x, myPoint.y, SYMWIDTH, SYMWIDTH);
		myRect.origin.x = ((c-1) % SYMROW) * SYMWIDTH;
		myRect.origin.y = (MAXMROWS - ((c-1) / SYMROW)-1) * SYMWIDTH;
		[MonSymsImage composite:NX_SOVER fromRect:&myRect toPoint:&myPoint];
		[self unlockFocus];
		return self;
	}
	if (c != 0 && c <= MAXOBCHARS) {
		c-= MAXMCHARS;
		PSsetrgbcolor(colortbl[(int)col][0], colortbl[(int)col][1],colortbl[(int)col][2]);
		PSrectfill(myPoint.x, myPoint.y, SYMWIDTH, SYMWIDTH);
		myRect.origin.x = ((c-1) % SYMROW) * SYMWIDTH;
		myRect.origin.y = (MAXOROWS - ((c-1) / SYMROW)-1) * SYMWIDTH;
		[ObjSymsImage composite:NX_SOVER fromRect:&myRect toPoint:&myPoint];
		[self unlockFocus];
		return self;
	}
	/* else print char */
	PSsetgray(NX_BLACK);
	PSrectfill(x*SYMWIDTH,(HHEIGHT-y)*SYMWIDTH, SYMWIDTH, SYMWIDTH);
    	[myFont set];
	PSsetrgbcolor(colortbl[(int)col][0], colortbl[(int)col][1],colortbl[(int)col][2]);
	PSmoveto(myPoint.x, myPoint.y);
	if ( c >= ' ' && c < '~' )
		PSshow(ch);
	[self unlockFocus];
	return self;
}

- setCursorX:(int)x y:(int)y
{
	[self lockFocus];
	if (PosBackup) {
		[PosBackup drawIn:&PosRect];
		[PosBackup free];
		PosBackup = nil;
	}
	NXSetRect(&PosRect, x*SYMWIDTH, (HHEIGHT-y)*SYMWIDTH, SYMWIDTH, SYMWIDTH);
	PosBackup = [[NXBitmapImageRep alloc] initData:NULL fromRect:&PosRect];
	PSsetgray(1.0);
	PSsetalpha(0.5);
	PScompositerect(x*SYMWIDTH,(HHEIGHT-y)*SYMWIDTH, SYMWIDTH, SYMWIDTH, NX_SOVER);
	[self unlockFocus];
	return self;
}

- setCursorOff
{
	[self lockFocus];
	if (PosBackup) {
		[PosBackup drawIn:&PosRect];
		[PosBackup free];
		PosBackup = nil;
	}
	[self unlockFocus];
	return self;
}

- setWin:(BOOL)state
{
	WinDraw = state;
	return self;
}

- soundOut: (char *)sndname
{
	char sndPath[180];
	id NHSounds;
	id theSound;
	
	// Look if we are allowed to play sound ...
	if (strcmp(NXGetDefaultValue([NXApp appName], "UseSound"), "NO") == 0)
		return self;
	theSound = nil;
	[[NXBundle mainBundle] getPath:sndPath forResource:"NHSounds" ofType:"bundle"];
	NHSounds = [[NXBundle alloc] initForDirectory:sndPath];
	// Get path for soundfile:
	[NHSounds getPath:sndPath forResource:sndname ofType:"snd"];
	[Sound addName:sndname fromSoundfile:sndPath];
	theSound = [Sound findSoundFor:sndname];
	if (theSound)
		[theSound play];
	return self;
}

- printString:(char *)s x:(int)x y:(int)y
{
	int i;
	static char buf[180];
	float rx,ry;
	
	[self lockFocus];
    	[myFont set];
	if (y == 1) {
		CLEARBGL(strlen(s));
		}

	PSsetgray(NX_WHITE);
	if (!WinDraw)
		PSmoveto(X_PS(x), Y_PS(y));
	else {
		rx = SYMWIDTH * x;
		ry = (HHEIGHT-y)*SYMWIDTH;
		PSmoveto(rx, ry);
	}
	i = -1;
	while (s[++i] != 0)
		if (!( s[i] >= ' ' && s[i] < '~' ))
			buf[i] = ' ';
		else
			buf[i] = s[i];
	buf[i] = 0;
	PSshow(buf);
	[self unlockFocus];
	return self;
}

- bell
{
	NXBeep();
	return self;
}

- cls
{
	[self lockFocus];
	PSsetgray(NX_BLACK);
	PSmoveto(0,0);
	PSrectfill(bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
	PSsetgray(NX_WHITE);
	[self unlockFocus];
	return self;
}

- cLineToEndWithX:(int)x y:(int)y
{
	float rx,ry;
	
	[self lockFocus];
	PSsetgray(NX_BLACK);
	if(y >= 2 && y <= (HHEIGHT-2)) {
		rx = SYMWIDTH * x;
		ry = (HHEIGHT-y)*SYMWIDTH;
	} else {
		rx = X_PS(x);
		ry = (HHEIGHT-y)*FONTSIZE-2;
	}
	PSrectfill(rx,ry,bounds.size.width,FONTSIZE);
	[self unlockFocus];
	return self;
}

- setHFont:theFont
{
	myFont = theFont;
	return self;
}

@end
