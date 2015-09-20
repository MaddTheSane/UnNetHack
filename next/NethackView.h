
#import <appkit/appkit.h>
#import <mach/message.h>

#define FONTSIZE	10
#define SYMROW		10
#define SYMWIDTH	10
#define MAXSYMROWS	4
#define MAXMROWS	6
#define MAXOROWS	2

@interface NethackView:View
{
	id myFont;
	id ShowSymsImage, MonSymsImage, ObjSymsImage;
	id PosBackup;
	NXRect PosRect;
}

- initFrame:(const NXRect *)theFrame;
- hitKey:(char)ch;

- printChar:(char)c x:(int)x y:(int)y;
- printGraphics:(char)c x:(int)x y:(int)y color:(char)col;
- soundOut:(char *)sndname;
- printString:(char *)s x:(int)x y:(int)y;
- bell;
- cls;
- cLineToEndWithX:(int)x y:(int)y;
- setCursorX:(int)x y:(int)y;
- setCursorOff;
- setWin:(BOOL)state;
- setHFont:theFont;

@end
