/* NethackApp.m
 * 
 * 3/29/94	added defaults support / preferences
 */

#import "NethackApp.h"
#import "appkit/Font.h"
#import "next.h"

extern int main_orig(int argc,char *argv[]);
extern void moveloop();
extern void start_main();

#define MAXCOMMTAG	27

/* globals: */
id HackView = nil;

/* translation table: tag -> command key */
char CommKeys[] = "/i+:^\\d,rqzeaocklwWPTuRt#p@";

void getAppDirectory (char *appDirectory)
{
    FILE *process;
    char command[256];
    char *suffix;

    strcpy (appDirectory,NXArgv[0]);
    if (appDirectory[0] == '/') { 		/* if absolute path */
        if (suffix = rindex(appDirectory,'/')) 
            *suffix  = '\0'; 			/* remove executable name */
    } else {
	sprintf(command,"which '%s'\n",NXArgv[0]);
	process=popen(command,"r");
	fscanf(process,"%s",appDirectory);
	pclose(process);
	if (suffix = rindex(appDirectory,'/')) 
	    *suffix  = '\0'; 			/* remove executable name */
	chdir(appDirectory);
	getwd(appDirectory);
    }  
}

@implementation NethackApp : Application

- init
{
  // static NXDefaultsVector NetHackDefaults = {
   // 	{"UseSound", "YES"},
   // 	{NULL}
  // };

  [super init];
  infoPanel = nil;
  commPanel = nil;
   // moved to appDidInit due to defaults bug
  // Register defaults system:
  // NXRegisterDefaults([NXApp appName], NetHackDefaults);

  return self;
}

- free
{
  [myFont free];
  [super free];
  return nil;
}

- info:sender
/*
 * Brings up the information panel.
 */
{
    if (!infoPanel) {
	[self loadNibSection:"InfoPanel.nib" owner:self withNames:NO fromZone:[self zone]];
	[infoPanel setFrameAutosaveName:"InfoPanel"];
    }

    [infoPanel orderFront:self];

    return self;
}

- prefs:sender
/*
 * Brings up the preferences panel.
 */
{
    if (!prefPanel) {
	[self loadNibSection:"PrefPanel.nib" owner:self withNames:NO fromZone:[self zone]];
	[prefPanel setFrameAutosaveName:"prefPanel"];
    }

    // Updating button ...
    if (strcmp(NXGetDefaultValue([NXApp appName], "UseSound"), "YES") == 0)
    	[useSound setState:YES];
    else
    	[useSound setState:NO];
    [prefPanel orderFront:self];

    return self;
}

- commands:sender
/*
 * Brings up the commands panel.
 */
 {
    if (!commPanel) {
	[self loadNibSection:"Commands.nib" owner:self withNames:NO fromZone:[self zone]];
	[commPanel setFrameAutosaveName:"commPanel"];
    }

    [commPanel setBecomeKeyOnlyIfNeeded:YES];
    [commPanel orderFront:self];

    return self;
}

- changePrefs:sender
{
    if ([useSound state])
    	NXWriteDefault([NXApp appName], "UseSound", "YES");
    else
    	NXWriteDefault([NXApp appName], "UseSound", "NO");
    return self;
}

- handleCommand:sender
{
	id myCell;
	int t;
	
	myCell = [sender selectedCell];
	t=[myCell tag];
	if (t <= MAXCOMMTAG && t != 0)
		[HackView hitKey:CommKeys[t-1]];
	return self;
}

- quitGame:sender
{
	[HackView hitKey:'Q'];
	return self;
}

- draw:(simpleMsg *)msg
{
    switch(msg->h.msg_id) {
        case PUTCHAR_MSG:
		switch(msg->typ) {
			case TYPE_CHAR:
				[HackView printChar:msg->c x:msg->position[0] y:msg->position[1]];
				break;
			case TYPE_GRAPHICS:
				[HackView printGraphics:msg->c x:msg->position[0] y:msg->position[1] color:WHITE];
				break;
			case TYPE_CGRAPHICS:
				[HackView printGraphics:msg->c x:msg->position[0] y:msg->position[1] color:msg->col];
				break;
		}
		break;
        case BELL_MSG:
		[HackView bell];
		break;
        case CLS_MSG:
		[HackView cls];
		break;
        case HOME_MSG:
		break;
        case CLEND_MSG:
		[HackView cLineToEndWithX:msg->position[0] y:msg->position[1]];
		break;
        case EXIT_MSG:
		printf("exited with %d.\n", msg->position[0]);
		[self terminate:self];
		break;
        case CURS_MSG:
		[HackView setCursorX:msg->position[0] y:msg->position[1]];
		break;
        case CURSOFF_MSG:
		[HackView setCursorOff];
		break;
        case WIN_MSG:
		[HackView setWin:(BOOL)(msg->c)];
		break;
 	default:
		/* Should never happen! */
		NXRunAlertPanel(NULL,"Unknown message ID in draw port !!!!", NULL, NULL, NULL);
		break;
    }
    return self;
}

- drawString:(stringMsg *)msg
{
    switch(msg->h.msg_id) {
        case PUTS_MSG:
		[HackView printString:msg->string x:msg->position[0] y:msg->position[1]];
		break;
        case SOUND_MSG:
		[HackView soundOut:msg->string];
		break;
 	default:
		/* Should never happen! */
		NXRunAlertPanel(NULL,"Unknown message ID in string port !!!!", NULL, NULL, NULL);
		break;
    }
    return self;
}

static void msgHandler(msg,self)
  simpleMsg *msg;
  id self;
{    
    [self draw:msg];
}

static void msgSHandler(msg,self)
  stringMsg *msg;
  id self;
{    
    [self drawString:msg];
}

- (port_t)drawPort
/* This method returns the port allocated by the main thread.  All drawing 
 * messages are sent to this port. 
 */
{
   return drawPort;
}

- (port_t)putsPort
/* This method returns the port allocated by the main thread.  String drawing 
 * messages are sent to this port. 
 */
{
   return putsPort;
}

- appDidInit:(Application *)sender
{
    char myAppDir[180];
    static NXDefaultsVector NetHackDefaults = {
    	{"UseSound", "YES"},
    	{NULL}
    };

    // Register defaults system:
    NXRegisterDefaults([NXApp appName], NetHackDefaults);
    getAppDirectory(myAppDir);
    chdir(myAppDir);
    HackView = nethackView;
    [HackView allocateGState];
    [[HackView window] useOptimizedDrawing:YES];
    port_allocate(task_self(), &drawPort);
    DPSAddPort(drawPort,msgHandler,sizeof(simpleMsg),self,NX_MODALRESPTHRESHOLD +1);
    port_allocate(task_self(), &putsPort);
    DPSAddPort(putsPort,msgSHandler,sizeof(stringMsg),self,NX_MODALRESPTHRESHOLD +1);

    myFont = [Font newFont:"Courier" size:FONTSIZE style:0 matrix:NX_IDENTITYMATRIX];
    fontx = [myFont getWidthOf:"W"];
    [HackView setHFont:myFont];
    printf("view setup. main_orig:\n");
    start_main();
    
    return self;
}


@end
