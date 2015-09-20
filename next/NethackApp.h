
#import <appkit/appkit.h>
#import "NethackView.h"
#import "next.h"


@interface NethackApp : Application
{
    id infoPanel;		/* the Info... panel */
    id prefPanel;		/* the Preferences... panel */
    id useSound;		/* the Use Sound Button */
    id commPanel;		/* Commands shortcut panel */
    id nethackView;	/* the nethack playing view */
    port_t drawPort;	/* Ports for inter-thread drawing mechanism */
    port_t putsPort;
    id myFont;			/* Font object for nethack font */
}


/* Target/Action methods */

- info:sender;
- prefs:sender;
- commands:sender;
- changePrefs:sender;
- handleCommand:sender;
- quitGame:sender;

/* PUBLIC methods */
- draw:(simpleMsg *)msg;
- (port_t)drawPort;
- (port_t)putsPort;

/* Application delegate methods */

- appDidInit:(Application *)sender;

@end

