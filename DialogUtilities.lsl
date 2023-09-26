// Dialog
// llDialog utilities and patterns
// Timberwoof Lupindo

// This script demonstrates how to use llDialog
// and gives some useful utilities for setting up
// radio buttons, checkboxes, and inactive buttons. 

// Tehse variables set up the communication between this script
// and the avatar that clicked it. They should always be the same. 
integer menuChannel = 0;
integer menuListen = 0;
key menuAgentKey = "";
string menuIdentifier;

// These variables are useful in many places. 
string buttonBlank = " ";
string buttonClose = "Close";
string buttonMain = "Main";

// ----------------------------------------------
// These variables set up the demonstration menu.
// Three ordinary buttons to demonstrate the Active Button feature. 
string button1 = "Button 1";
string button2 = "Button 2";
string button3 = "Button 3";
integer doButton1 = TRUE;
integer doButton2 = FALSE;
integer doButton3 = TRUE;

// Radio buttons let you select one thing from a set. 
// Only one of them can be active at a time,
// so there's one variable that sets the active state. 
string radio1 = "Radio 1"; 
string radio2 = "Radio 2"; 
string radio3 = "Radio 3"; 
string radioState = "Radio 2";

// Checkboxes let you turn them on and off. 
// Any number of them can be active at a time,
// so each one has its own state variable. 
string checkbox1 = "Checkbox 1";
string checkbox2 = "Checkbox 2";
string checkbox3 = "Checkbox 3";
integer checkboxState1 = TRUE;
integer checkboxState2 = TRUE;
integer checkboxState3 = FALSE;

// If you want the script to report what's going on, set this to TRUE;
integer OPTION_DEBUG = FALSE;
sayDebug(string message)
{
    if (OPTION_DEBUG)
    {
        llOwnerSay(message);
    }
}

// -----------------
// Utility Functions

string menuCheckbox(string title, integer onOff)
// Make checkbox menu item out of a button title and boolean state.
// title is the text that will show up on the button.
// onOff determines the state of the checkbox.
{
    string checkbox;
    if (onOff)
    {
        checkbox = "☒";
    }
    else
    {
        checkbox = "☐";
    }
    return checkbox + " " + title;
}

list menuRadioButton(string title, string match)
// Make radio button menu item out of a button and the state text.
// title is the text that will show up on the button.
// match is the current state of the radio buttons. 
{
    string radiobutton;
    if (title == match)
    {
        radiobutton = "●";
    }
    else
    {
        radiobutton = "○";
    }
    return [radiobutton + " " + title];
}

list menuButtonActive(string title, integer onOff)
// Make a menu button be the text or the Inactive symbol
// title is the text that will show up on the button.
// onOff tells whether the option should be active.
// Using this gives two benefits. 
// It helps keep the buttons arranged the same way.
// It informs the user that the option is not available. 
{
    string button;
    if (onOff)
    {
        button = title;
    }
    else
    {
        button = "["+title+"]";
    }
    return [button];
}

setUpMenu(string identifier, key avatarKey, string message, list buttons)
// wrapper to do all the calls that make a simple menu dialog.
// - adds required buttons such as Close or Main
// - sets up the menu channel, listen, and timer event
// - calls llDialog
// parameters:
// identifier - sets menuIdentifier, the later context for the command
// avatarKey - uuid of who clicked
// message - text for top of blue menu dialog
// buttons - list of button texts
{
    sayDebug("setUpMenu "+identifier);

    // If this is not the main menu, 
    // then add a button for it. 
    if (identifier != buttonMain) {
        buttons = buttons + [buttonMain];
    }
    buttons = buttons + ["Close"];

    // remember what menu this was for later handling.
    menuIdentifier = identifier;
    // set up communications on a randomly generated channel
    menuChannel = -(llFloor(llFrand(10000)+1000));
    menuListen = llListen(menuChannel, "", avatarKey, "");
    // Set the timer so we can remove the listen 
    llSetTimerEvent(30);
    // Launch the dialog
    llDialog(avatarKey, message, buttons, menuChannel);
}

mainMenu(key avatarKey) {
    string message = "This demonstrates Timberwoof Lupindo's menu utilities.";

    if (menuAgentKey != "" & menuAgentKey != avatarKey) {
        llInstantMessage(avatarKey, "The menu is being accessed by someone else.");
        sayDebug("Told " + llKey2Name(avatarKey) +
             "that the menu is being accessed by someone else.");
        return;
    }
    
    // The values for duButton, radioState, and checkboxState 
    // can be set here or anywhere. 
    // This code uses those states to set up the buttons. 
    list buttons = [];
    buttons = buttons + menuButtonActive(button1, doButton1);
    buttons = buttons + menuButtonActive(button2, doButton2);
    buttons = buttons + menuButtonActive(button3, doButton3);
    buttons = buttons + menuRadioButton(radio1, radioState);
    buttons = buttons + menuRadioButton(radio2, radioState);
    buttons = buttons + menuRadioButton(radio3, radioState);
    buttons = buttons + menuCheckbox(checkbox1, checkboxState1);
    buttons = buttons + menuCheckbox(checkbox2, checkboxState2);
    buttons = buttons + menuCheckbox(checkbox3, checkboxState3);
    buttons = buttons + buttonBlank;
    buttons = buttons + buttonMain;

    // make the menu happen
    setUpMenu(buttonMain, avatarKey, message, buttons);
}

doMainMenu(key avatarKey, string message) {
    // Processing the menu commands is encapsulated here.
    sayDebug("doMainMenu("+message+")");
    
    // The first three buttons actually do things 
    if (message == button1) {
        llSay(0,message);
    } else if (message == button2) {
        llSay(0,message);
    } else if (message == button3) {
        llSay(0,message);
        
    // The radio buttons and checkboxes only change their state
    // so the effects are seen the next time the menu is called. 
    // The rest of your code can do things with the states. 
    } else if (message == radio1) {
        radioState = radio1;
    } else if (message == radio2) {
        radioState = radio2;
    } else if (message == radio3) {
        radioState = radio3;
    } else if (message == checkbox1) {
        checkboxState1 = !checkboxState1;
    } else if (message == checkbox2) {
        checkboxState2 = !checkboxState2;
    } else if (message == checkbox3) {
        checkboxState3 = !checkboxState3;
    }
}

default {
    state_entry() {
        sayDebug("state_entry");
    }

    touch_start(integer total_number) {
        mainMenu(llDetectedKey(0));
    }

    listen(integer channel, string name, key avatarKey, string message) {
        // Receive messages including from the menu. 
        sayDebug("listen name:"+name+" message:"+message);

        // listen can receive messages from other things, 
        // so we handle the menus in this if statement.
        if (channel == menuChannel) {
            // Some of the buttons have doohickeys in the front
            // so they need to be stripped off
            // before we can recognize the buttons. 
            string messageButtonTrimmed = message;
            list striplist = ["☒ ","☐ ","● ","○ "];
            integer i;
            for (i=0; i < llGetListLength(striplist); i = i + 1) {
                string thing = llList2String(striplist, i);
                integer whereThing = llSubStringIndex(messageButtonTrimmed, thing);
                if (whereThing > -1) {
                    integer thingLength = llStringLength(thing)-1;
                    messageButtonTrimmed = llDeleteSubString(messageButtonTrimmed, 
                    whereThing, whereThing + thingLength);
                }
            }
            sayDebug("listen messageButtonTrimmed:"+messageButtonTrimmed+
                " menuIdentifier: "+menuIdentifier);

            // reset the menu setup
            llListenRemove(menuListen);
            menuListen = 0;
            menuChannel = 0;
            menuAgentKey = "";
            llSetTimerEvent(0);

            if (message == buttonClose) {
                return;
            }

            // Main button
            if (message == buttonMain) {
                mainMenu(avatarKey);
            } else if (menuIdentifier == buttonMain) {
                doMainMenu(avatarKey, messageButtonTrimmed);
            } else {
                sayDebug("ERROR: did not process menuIdentifier "+menuIdentifier);
            }
        }
    }

    timer()
    {
        // reset the menu setup
        llListenRemove(menuListen);
        menuListen = 0;
        menuChannel = 0;
        menuAgentKey = "";
        llSetTimerEvent(0);
    }
}
