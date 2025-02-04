#######################
# Gui Preferences System
#
# Written by Daspek
#######################

#format: variable comment

set ::prefile [file join $::TIK(configDir) autopre]
set ::rcfile [file join $::TIK(configDir) autorc]
set ::awayfile [file join $::TIK(configDir) autoaway]

set ::AUTOSCREENNAME ""
set ::AUTOPASSWORD ""
set ::FOCUSPW ""

####################### BEGIN TIKPRE ##########################################
set ::TIK(prelist) \
	[list \
	"::TIK(options,language)" "language to use (strs file)\n\
	###########\n\
	# Minimalist - kjr\n\
	# If you want to make the buddy list less cluttered.  Also need\n\
	# to change the tikstrs and tikrc file.  See example.* \n\
	###########\n\
	"\
	"::TIK(options,padframe)" "0 = Don't pad buddy window."\
	"::TIK(options,sagborderwidth)" "0= Remove border from sag windows\n\n"\
	"::TIK(options,nameonblist)" "Show name on top of buddy list \n\
	\n\
	######################\n\
	# Color Schemes\n\
	# Send any good examples of color schemes to daspek@daspek.com\n\
	# and we will them to this file. (Also let us know if you want your\n\
	# email address listed as a contributor.)\n\
	######################\n\
	\n\
	########## Tic Toc <tictoc-list@aol.net>\n\
	## To set ALL background and foreground colors use:\n\
	#option add *background #000080\n\
	#option add *foreground #ffffff\n\
	#option add *activeBackground #ffcc33\n\
	#option add *activeForeground black\n\
	## To set just the Button background and foreground colors use:\n\
	#option add *Button.activeBackground #ffcc33\n\
	#option add *Button.activeForeground black\n\
	#option add *Button.background #0066ff\n\
	#option add *Button.foreground #000000\n\
	\n\
	########## Yann Dubois <ydubois@sgi4.mcs.sdsmt.edu>\n\
	#option add *background lightblue\n\
	#option add *foreground black\n\
	#option add *activeBackground #000000\n\
	#option add *activeForeground white\n\
	#option add *Button.activeBackground darkblue\n\
	#option add *Button.activeForeground white\n\
	#option add *Button.background white\n\
	#option add *Button.foreground #000000\n\
	\n\
	# To set ALL background and foreground colors to white and dark grey I use:\n\
	#option add *background white\n\
	#option add *foreground #333333\n\
	\n\
	# To make sure the buttons as well are sized correctly I use:\n\
	#option add *font \$::BOLDFONT\n\
	\n\
	########## jvp\n\
	#option add *background #aeb2c3\n\
	#option add *activeBackground #aeb2c3\n\
	#option add *text*Background white\n\
	#option add *list*Background white\n\
	#option add *listS*Background #aeb2c3\n\
	#option add *msg*Background white\n\
	#option add *textS*Background #aeb2c3\n\
	#option add *textS*activeBackground #aeb2c3\n\
	#option add *to*Background white\n\
	#option add *sb*Background #aeb2c3\n\
	#option add *Button.activeBackground #aeb2c3\n\
	#option add *Button.background #aeb2c3\n\
	#option add *Button.font fixed\n\
	\n\
	#########################\n\
	# Modern white theme (default) \n\
	# Renders all text backgrounds white and \n\
	# changes button style to -relief groove\n\
	#########################\n\
	#option add *Button.relief groove\n\
	#option add *Menu.relief groove\n\
	#option add *Text.background white\n\
	#option add *Entry.background white\n\
	#option add *Scrollbar.width 12\n\
	#option add *Menubutton.relief groove\n\
	#option add *list.c*Background white\n\
	\n\
	\n\
	##########################\n\
	# If you wish to use any of the above schemes, \n\
	# comment the following lines and uncomment those\n\
	# of your desired scheme. Alternatively, if you wish\n\
	# to create your own scheme, either use the following\n\
	# approach, resetting every variable, or comment it out\n\
	# and go with the old format above.\n\
	###########################\n\
	"\
        "::TIK(options,defaultbackground)" "Default background for everything. (bypassed by specific bgrounds defined below)"\
        "::TIK(options,scrollbarbackground)" "Scrollbar background"\
        "::TIK(options,buttonbackground)" "Button background"\
        "::TIK(options,buttonfont)" "Button font"\
        "::TIK(options,buttonrelief)" "Button relief (groove, flat, raised, sunken, ridge, solid)"\
        "::TIK(options,menurelief)" "Menu relief (groove, flat, raised, sunken, ridge, solid)"\
        "::TIK(options,textbackground)" "Background of text widgets (IM conversations)"\
        "::TIK(options,textforeground)" "Foreground of text widgets (IM conversations)"\
        "::TIK(options,entrybackground)" "Background of entries"\
        "::TIK(options,entryforeground)" "Foreground of entries"\
        "::TIK(options,scrollbarwidth)" "Scrollbar width"\
        "::TIK(options,menubuttonrelief)" "Menubutton relief (groove, flat, raised, sunken, ridge, solid)"\
        "::TIK(options,activebackground)" "Default background for active widgets"\
        "::TIK(options,listbackground)" "list background"\
        "::TIK(options,buttonforeground)" "Button foreground"\
	"::TIK(options,buddylistbground)" "Buddylist Background"\
        "::TIK(options,tobackground)" "Background of the 'to' entry\n\
	######\n\
	# apply settings to apperances\n\
	setAppearances \n\
	"\
	]


####################### END TIKPRE ############################################

####################### BEGIN TIKRC ###########################################
set ::TIK(rclist) \
	[list \
	"::TOC(production,host)" "host of the TOC server"\
	"::TOC(production,port)" "port of the TOC server\n\n"\
	"::USEPROXY" "which proxy type to use (None, Socks, or SSL/HTTP)\n\
	\n\
	################ HTTP PROXY #####################\n\
	# If you need to use a HTTP proxy to access web pages then\n\
	# set these.  This is ONLY for fetching web pages, and NOT used\n\
	# for to connecting to the TOC servers.\n\
	#\n\
	"\
	"::HTTPPROXY" "Hostname of the web proxy"\
	"::HTTPPORT" "Port of the web proxy"\
	"::TIK(options,HTTPProxy,enable)" "Enable the web proxy\n\
	\n\
	################ SOCKS PROXY #####################\n\
	# If you are using SOCKS you need to set the following things. The\n\
	# proxy is used for connecting to the TOC server NOT for fetching web\n\
	# pages. You *MUST* set TOC(production,host) to the ip address of\n\
	# \"toc.oscar.aol.com\".  The suggested way to find out the ip address \n\
	# is \"nslookup toc.oscar.aol.com\" at the command line.  If this\n\
	# this doesn't work please contact your network administrator.\n\
	# We can not tell you the ip address of toc.oscar.aol.com or\n\
	# how to get it, other then the above suggestion.\n\
	#\n\
	# WARNING: The ip address of toc.oscar.aol.com WILL change\n\
	# sometimes.  Currently there is no good way to do a nslookup in tcl\n\
	# that we are aware of, so you WILL need to change it once and a while.\n\
	#\n\
	"\
	"::SOCKSHOST" "Hostname of your socks proxy"\
	"::SOCKSPORT" "Port of your socks proxy"\
	"::TOC(production,host)" "IP of the TOC server\n\
	\n\
	################ SSL/HTTP PROXY #####################\n\
	# If you are using SSL/HTTP you need to set the following things.\n\
	# This is used for connecting to the TOC server NOT for fetching web pages.\n\
	#\n\
	"\
	"::SSLHOST" "Hostname of your ssl proxy"\
	"::SSLPORT" "Port of your ssl proxy \n\
	# The following 3 lines are only required if your proxy requires basic auth"\
	"::SSLNEEDAUTH" "Does your SSL proxy require basic authorization?"\
	"::SSLUSER" "username if auth is needed"\
	"::SSLPASS" "password if auth is needed\n\
	\n\
	################ SIGN ON VARIABLES #####################\n\
	# If you want the screenname or password field filled in.\n\
	# Use ./tik.tcl -roast <pass> to get a roasted version of\n\
	# the password so it isn't in clear text, although it isn't\n\
	# any more secure then clear text.\n\
	\n\
	"\
	"::AUTOSCREENNAME" "your screenname"\
	"::AUTOPASSWORD" "your password"\
	"::FOCUSPW" "automatically focus on password entry\n\
	if {\$::FOCUSPW == 1} {focus .login.pwE}\n\
	"\
	"::AUTOSIGNON" "automatically sign on when TiK is started\n\
	if {\[string length \[normalize \$::AUTOSCREENNAME\]\] > 2 && \[string length \$::AUTOSCREENNAME\] <=16} {set ::SCREENNAME \$::AUTOSCREENNAME}\n\
	if {\[string length \[normalize \$::AUTOSCREENNAME\]\] > 2 && \[string length \$::AUTOSCREENNAME\] <=16 && \[string length \$::AUTOPASSWORD\] >3 && \[string length \$::AUTOPASSWORD\] <=16} {set ::PASSWORD \$::AUTOPASSWORD}\n\
	if {\$::AUTOSIGNON==1} {tik_signon}\n\
	"\
	"::TIK(options,persistent)" "Reconnect when accidentally disconnected\n\
	\n\n\
	## Sound Files - Can use full paths if you want.\n\
	## To turn off an individual sound just uncomment the\n\
	## correct line and change the sound file to \"none\".\n\
	## Alternatively, set the sound file to \"beep\" to\n\
	## beep on different events.\n\
	## You can also have per-buddy sounds for Send/Receive/Initial/Arrive/Depart\n\
	## by setting ::TIK(SOUND,<normalized buddy name>,<event>)\n\
	## set ::TIK(SOUND,johnsmith,Arrive) JohnnyArrived.wav\n\
	"\
	"::SOUNDPLAYING" "1 to disable sound, 0 to enable (no, that is not a mistake)"\
	"::TIK(SOUND,Send)" "Send sound"\
	"::TIK(SOUND,Receive)" "Receive sound"\
        "::TIK(SOUND,Initial)" "Initial IM sound"\
	"::TIK(SOUND,ChatSend)" "Chat send sound"\
	"::TIK(SOUND,ChatReceive)" "Chat receive sound"\
	"::TIK(SOUND,Arrive)" "Buddy arrive sound"\
	"::TIK(SOUND,Depart)" "Buddy depart sound\n\n\
	###########\n\
	# OPTIONS\n\
	#\n\
	# Options that control how the TiK app works.\n\
	###########\n\
	# Default OPTIONS\n\
	"\
	"::TIK(options,imtime)" "Display timestamps in IMs and imcapture"\
	"::TIK(options,chattime)" "Display timestamps in chats and chatcapture\n\n"\
	"::TIK(options,imcapture,use)" "Log all IM's"\
	"::TIK(options,chatcapture,use)" "Log all chats\n\n"\
	"::TIK(options,imcapture,timestamp)" "Always show timestamps in im logs (overrides the above)"\
	"::TIK(options,chatcapture,timestamp)" "Always show timestamps in chat logs (overrides the above)\n\
	\n\
	# Heights:\n\
	#   ==  0 :One Line Entry.  Resizing keeps it 1 line\n\
	#   >=  1 :Text Entry, Multiline.  Resizing may increase number of lines\n\
	#   <= -1 :Text Entry, Multiline.  Same as >=1 but with scroll bar.\n\
	"\
	"::TIK(options,iimheight)" "Initial IM entry height"\
	"::TIK(options,cimheight)" "Conversation IM height"\
	"::TIK(options,chatheight)" "Chat entry height"\
	"::TIK(options,cimexpand)" "If cimheight isn't 0, this determines if the entry expands on resize\n\
	# imcolor & chatcolor are bit fields -- OR the following together\n\
	# 0x1 - Support foreground colors\n\
	# 0x2 - Support character group background colors\n\
	# 0x4 - Support body background colors\n\n\
	"\
	"::TIK(options,imcolor)" "Process IM colors"\
	"::TIK(options,chatcolor)" "Process chat colors\n\n"\
	"::TIK(options,defaultimcolor)" "Default IM color"\
	"::TIK(options,defaultchatcolor)" "Default chat color\n\n"\
	"::TIK(options,windowgroup)" "Group TiK windows together\n\n\
	## WARNING: Tk & some window manangers don't work well together\n\
	## if rasieim, raisechat are turned on, you will see a 2 second pause.\n\
	"\
	"::TIK(options,raiseim)" "Raise IM window on new message"\
	"::TIK(options,deiconifyim)" "Deiconify IM window on new message"\
	"::TIK(options,raisechat)" "Raise chat window on new message"\
	"::TIK(options,deiconifychat)" "Deiconify chat window on new message\n\n"\
	"::TIK(options,monitorrc)" "Monitor tikrc file for changes"\
	"::TIK(options,monitorrctime)" "Check for tikrc file changes how often (milliseconds)"\
	"::TIK(options,monitorpkg)" "Monitor packages for changes"\
	"::TIK(options,monitorpkgtime)" "Check the pkg dir for changes how often (milliseconds)\n\n\
	# When receiving a new message, we can flash the scroll bar.\n\
	"\
	"::TIK(options,flashim)" "Flash IM scrollbar with new msg"\
	"::TIK(options,flashimtime)" "Milliseconds between flashes"\
	"::TIK(options,flashimcolor)" "Flash color\n\n"\
	"::TIK(options,usepreproc)" "Use message preprocessor"\
	"::TIK(options,showofflinegroup)" "Show Offline group on buddy list"\
	"::TIK(options,showgrouptotals)" "Show group totals on buddy list"\
	"::TIK(options,showidletime)" "Show idle time of buddies"\
	"::TIK(options,showevil)" "Show evil level of buddies"\
	"::TIK(options,showicons)" "Show icons on buddy list"\
	"::TIK(options,padframe)" "Pad buddy window?"\
	"::TIK(options,sagborderwidth)" "Border width for sag windows\n\n\
	# 0 - Enter/Ctl-Enter insert NewLine,  Send Button Sends\n\
	# 1 - Ctl-Enter inserts NewLine,  Send Button/Enter Sends\n\
	# 2 - Enter inserts NewLine,  Send Button/Ctl-Enter Sends\n\
	# 3 - No Newlines,  Send Button/Ctl-Enter/Enter Sends\n\
	"\
	"::TIK(options,msgsend)" "Keys with which to send\n\n\
	# 0 - Use the config from the host\n\
	# 1 - Use the config from ~/.tik/NSCREENNAME.config\n\
	# 2 - Use the config from ~/.tik/NSCREENNAME.config & keep this config\n\
	#     on the host.  (Remember the host has a 2k config limit!)\n\
	# 3 - Use the config from the host, but backup locally, if host config\n\
	#     is empty then use local config.\n\
	"\
	"::TIK(options,localconfig)" "Where to get buddy list\n\n"\
	"::TIK(options,reportidle)" "Report idle time"\
	"::TIK(options,idlewatchmouse)" "Watch the global mouse pointer"\
	"::TIK(options,reportidleafter)" "Report idle after this long (seconds)"\
	"::TIK(options,idleupdateinterval)" "Interval for idle update (minutes), 0 to disable\n\n"\
	"::USEBALLOONHELP" "Use ballonhelp?\n\
	if {\$::USEBALLOONHELP} {balloonhelp on} else {balloonhelp off}\n\n\
	# Buddy Colors\n\
	"\
	"::TIK(options,buddymcolor)" "buddy color on buddy list"\
	"::TIK(options,buddyocolor)" "buddy stats color on buddy list"\
	"::TIK(options,groupmcolor)" "group color on buddy list"\
	"::TIK(options,groupocolor)" "group stats color on buddy list\n\n\
	# Window Manager Classes\n\
	"\
	"::TIK(options,imWMClass)" "IM window manager class"\
	"::TIK(options,chatWMClass)" "Chat window manager class\n\n\
	##### Search Field Options ####\n\
	"\
	"::TIK(options,Search,display)" "Show search field"\
	"::TIK(options,Search,default)" "Default search engine\n\n\
	##### Away System Options ####\n\
	## How many times do we send an away message to a particular user?\n\
	## Now by default -1 (infinite) since there is a default delay of 30 seconds\n\
	"\
	"::TIK(options,Away,sendmax)" "away msgs to a particular user (see above)"\
	"::TIK(options,Away,delay)" "If sendmax is -1 (always send), set the away msg delay (milliseconds)\n\n"\
	"::TIK(options,Away,sendidle)" "send an idle message"\
	"::TIK(options,Away,idlewait)" "seconds before idle msg is sent (gives us a chance to type an answer before it is sent)\n\n"\
	"::TIK(options,boxinfo,use)" "Use boxinfo instead of the browser for info and dir"\
	"::TIK(options,boxinfo,geometry)" "dimensions of the boxinfo box\n\n\
	##### Pounce Package Options ####\n\
	# To register people to pounce use (the defaults are included)\n\
	# pounce::register <name> <onlyonce 0> <sound 1> <popim 1> <sendim 0> <msg \"\"> <notaway 1> <execcmd 0> <cmdstr \"\"> <idlepounce 0> \n\
	# Example 1: pounce::register TicTocTikTac \n\
	# Example 2: pounce::register TicTocTikTac 0 1 1 1 \"Auto send this\" 1 0 \"\" 1\n\
	#\n\
	\n\
	###########\n\
	# WM Commands\n\
	#\n\
	# The login window and buddy window are created on start up\n\
	# so you can set the size and stuff here.\n\
	###########\n\
	#wm geometry .buddy 250x800-15+80\n\
	#wm geometry .login +400+400\n\
	\n\
	###########\n\
	# FUNCTIONS\n\
	#\n\
	# Tcl lets you override functions, here are some of the\n\
	# functions you may need to replace, since their default \n\
	# implementation is platform specific.\n\
	###########\n\
	\n\
	# Use the currently open netscape window to display\n\
	# URLS.  Ignore the window param for now.\n\
	\n\
	#proc tik_show_url {window url} {\n\
	##Default: Use Netscape\n\
	#    catch {exec netscape -remote openURL(\$url) &}\n\
	##Use KDE Browser\n\
	#    catch {exec kfmclient exec \$url &}\n\
	#}\n\
	\n\
	# You may have to write your own play sound method, we include\n\
	# some examples here and see tik.tcl for more examples.  Please send \n\
	# any working routines to daspek@daspek.com along with output \n\
	# of `uname -s` and platform info.  SOUNDPLAYING is used to keep \n\
	# multiple sounds from playing at the same time.\n\
	\n\
	##Default Implementation -- \n\
	#   set ::TIK(SOUNDROUTINE) {dd if=\$soundfile of=/dev/audio 2> /dev/null &} \n\
	##Use \"play\" which is already installed on some machines, this usually uses SOXs\n\
	#   set ::TIK(SOUNDROUTINE) {play \$soundfile 2> /dev/null &}\n\
	##SOX Implementation -- Sheraz Sharif\n\
	#   set ::TIK(SOUNDROUTINE) {sox \$soundfile -t .au - > /dev/audio &}\n\
	##NAS (Network Audio System) Implementation -- \n\
	#   set ::TIK(SOUNDROUTINE) {/usr/local/bin/auplay \$soundfile &}\n\
	##Windows 95: wplany Implementation --\n\
	#   set ::TIK(SOUNDROUTINE) {wplany \$soundfile &}\n\
	##ESDPlay Implementation -- Stevie Strickland  \n\
	#   set ::TIK(SOUNDROUTINE) {esdplay \$soundfile &}\n\
	#}\n\
	\n\
	"\
	"::TIK(SOUNDROUTINE)" "command for playing sounds"\
	"::TIK(options,silentaway)" "disable sounds while away\n\n\
	###########\n\
	# Minimalist - kjr\n\
	# If you want to make the buddy list less cluttered.  Also need\n\
	# to change the tikstrs and tikpre file.  See example.* \n\
	###########\n\
	#pack forget .buddy.im            ;# Remove the buttons from the buddy list\n\
	#pack forget .buddy.chat          ;# You can still use Control-\[icl\] to\n\
	#pack forget .buddy.info          ;# im, chat, or get info\n\
	#pack forget .buddy.list.sb       ;# Remove the scrollbar from the buddy list\n\
	\n\
	# Move help Menu to first item in Packages\n\
	#if {\[catch {.menubar delete \[tik_str M_HELP\]}\] == 0} {\n\
	#   .toolsMenu insert 0 cascade -label \[tik_str M_HELP\] -menu .menubar.help\n\
	#}\n\
	\n\
	"\
	"::TIK(options,autoignoredeny)" "automatically ignore blocked people when they enter a chat room"\
	"::TIK(options,fortuneprog)" "location of fortune program"\
	"::TIK(options,fortuneprog)" "location of webster or dictionary program\n\n"\
	"::TIK(options,mysncolor)" "color of our screenname in im's and chats"\
	"::TIK(options,othersncolor)" "color of other screenname in im's and chats\n\n"\
	"::TIK(options,Font,basesize)" "base size of font"\
	"::TIK(options,Font,userelsize)" "use basesize for relative font sizing"\
	"::TIK(options,Font,baseface)" "base font"\
	"::TIK(options,Font,defheader)" "use a default header in the header box"\
	"::TIK(options,Font,deffooter)" "use a default footer\n\
	tik_update_fonts\n\n\
	"\
	"::TIK(options,Font,showbgcolor)" "show background color"\
	"::TIK(options,Font,showfonts)" "display fonts"\
	"::TIK(options,Font,showfontsizes)" "display font sizes\n\n"\
	"::TIK(options,buttonbar)" "show button bar\n\n"\
	"::TIK(options,iconbuttons)" "use graphical buttons instead of textual ones"\
	"::TIK(options,focusrmstar)" "remove star from IM window title upon focus"\
	"::TIK(options,showsmilies)" "show graphical emoticons\n\n\
	##########\n\
	# Setup for graphical emoticons\n\
	##########\n\
	#set ::TIK(smilielist) [list {[0oO][=:]-?\)} angel.gif {[=:]-?D} bigsmile.gif {[=:]-?!} burp.gif {[=:]-?[xX]} crossedlips.gif {[=:]'-?\(} cry.gif {[=:]-?[\]\[]} embarrassed.gif {[=:]-?\*} kiss.gif {[=:]-?\$} moneymouth.gif {[=:]-?\(} sad.gif {[:=]-?[oO]} scream.gif {[=:]-?\)} smile.gif {8-?\)} smile8.gif {[=:](-?\\|-\/)} think.gif {[=:]-?[pPb]} tongue.gif {\;-?\)} wink.gif {>[=:][0oO]} yell.gif]\n\
	\n\
	#tik_load_emoticons\n\n\
	"\
	"::TIK(options,beat,on)" "Turn keepalive on"\
	"::TIK(options,beat,time)" "keepalive interval (milliseconds)"\
	"::TIK(options,beat,debug)" "send debugging msgs to /dev/stderr\n\n"\
	"::TIK(options,getaway,use)" "enable Get Away package"\
	"::TIK(options,getaway,notify)" "notify upon away message request\n\n\n"\
	]
################# END TIKRC #########################################################
	
proc old_rc_check {rcfile autofile} {
    if {[catch {open $rcfile r 0600} realrc]} {
        bgerror "File wasn't openned properly."
    }
    set oldrc 1
    while {[gets $realrc line] >= 0} {
        if {$line == "# <!! PREFS don't touch this line !!>"} {
            set oldrc 0
            break 
        }
    }
    close $realrc
    if {$oldrc} {
        if {[catch {open $rcfile a 0600} realrc]} {
            bgerror "File wasn't openned properly."
        }
        puts $realrc ""
        puts $realrc "# <!! PREFS don't touch this line !!>"
        puts $realrc "# This line allows the preferences system to work."
        puts $realrc "catch \{source \[file join \$::TIK(configDir) $autofile\]\}"
        close $realrc
    }
}

proc parsepre {} {
    set prefcount 1
    set varcount 1
    set i 1
    foreach t $::TIK(prelist) {
	if {$i} {
	    set ::prevars($prefcount) "$t"
	    set prefcount [expr $prefcount +1]
	} else {
	    set ::precomments($varcount) " ;# $t"
	    set varcount [expr $varcount +1]
	}
	set i [expr 1-$i]
    }
}

proc parserc {} {
    set prefcount 1
    set varcount 1
    set i 1
    foreach t $::TIK(rclist) {
	if {$i} {
	    set ::rcvars($prefcount) "$t"
	    set prefcount [expr $prefcount +1]
	} else {
	    set ::rccomments($varcount) " ;# $t"
	    set varcount [expr $varcount +1]
	}
	set i [expr 1-$i]
    }
}

proc parseaway {str} {
    set t [string length $str]
    while {[regsub -- {(\n|<br>)$} $str {} str]} {}
    while {$t} {
	if {[string index $str $t] == "\n"} {
	    set str [string replace $str $t $t "<br>"]
	}
	incr t -1
    }
    regsub -all -- {[]["${}\\]} $str {\\&} str
    return $str
}

proc writepre {} {
    parsepre
    set preout [open $::prefile w 0600]
    
    puts $preout "\
	    ###########\n\
	    # DO NOT EDIT.\n\
	    # \n\
	    # Automatically generated by the preferences system.\n\
	    #\n\
	    # Comments are for educational purposes.\n\
	    ###########\n\
	    \n"
    set t 1
    while {$t<=[array size ::prevars]} {
	if {$t<=[array size ::prevars]} {
	    #
	    # Get the variable name from the list of preferences
	    # variables.
	    #
	    set var_value $::prevars($t)
	    set var_comment $::precomments($t)

	    if { [info exists $var_value] && [expr $$var_value] != "" } {
		#
		# If the variable named in the list of preferences
		# exists then we extract its value into var_value
		# and then write a statement for setting the variable
		# value into the preffile. 
		#
		set var_value [expr $$var_value]
		puts $preout "set $::prevars($t) $var_value $var_comment"
	    } else {
		#
		# If the variable does not exist, then we write a commented 
		# statement in the preffile which sets the value of that variable
		# to an empty string.
		#
		puts $preout "# set $::prevars($t) \"\" $var_comment"
	    }
	    
	    set t [expr $t+1]
	}
    }
    close $preout
    old_rc_check $::TIK(prefile) autopre
}

proc writerc {} {
    parserc
    set rcout [open $::rcfile w 0600]
    puts $rcout "\
	###########\n\
	# DO NOT EDIT.\n\
	# \n\
	# Automatically generated by the preferences system.\n\
      # \n\
      # Comments are for educational purposes. \n\
	###########\n\
	\n\
	################ OPEN PORT PROXY #####################\n\
	\n\
	# The TOC servers listen to EVERY port, if 5190 is blocked on your system\n\
	# change it.  Many firewalls leave ports 21, 25, 80, or 6000 open.\n\n"
    set t 1
    while {$t<=[array size ::rcvars]} {
	if {$t<=[array size ::rcvars]} {
	    #
	    # Get the variable name from the list of preferences
	    # variables.
	    #
	    set var_value $::rcvars($t)
	    set var_comment $::rccomments($t)
	    if { [info exists $var_value] && [expr $$var_value] != "" } {
		#
		# If the variable named in the list of preferences
		# exists and is not an empty string then we extract 
		# its value into var_value and then write a statement
		# for setting the variable value into the preffile. 
		#
		set var_value [expr $$var_value]
		puts $rcout "set $::rcvars($t) $var_value $var_comment"
	    } else {
                #
                # If the variable does not exist or is an empty string, 
                # then we write a commented statement in the preffile which  
                # sets the value of that variable to an empty string for
                # future reference.
                #
            puts $rcout "# set $::rcvars($t) \"\" $var_comment"
	    }
	    incr t
	}
    }
    close $rcout
    old_rc_check $::TIK(rcfile) autorc
}

proc writeaway {} {
    if { ![info exists ::TIK(options,Away,Fcommand)] || $::TIK(options,Away,Fcommand) == "" } {
	set ::TIK(options,Away,Fcommand) 0
    }
    set awayout [open $::awayfile w 0600]
    puts $awayout "\
	    ##############################\n\
          # DON'T EDIT.\n\
          # Automatically generated by the \n\
          # preferences system.\n\
          # \n\
          # Comments below are for educational \n\ 
          # purposes. \n\
          #\n\
          \n\
	    # What command to use for %F substitution in away messages. Set to 0 to disable.\n\
	    # You can also use any of the %x codes in the Fcommand.\n\
	    # For example, if you are using a unix, the following two commands will send you an email at\n\
	    # someone@somewhere.com when a buddy tries to reach you.\n\
	    #\n\
	    # set ::TIK(options,Away,Fcommand) \"echo \\\"AIM Message from %n at %t\\\" | mail someone@somewhere.com\"\n\
	    #\n"
    puts $awayout "set ::TIK(options,Away,Fcommand) \"$::TIK(options,Away,Fcommand)\""
    puts $awayout "\n\
	    #########\n\
	    # Buddy Info\n\
	    # If you would like your .signature\n\
	    # file to be your info, use:\n\
	    # tik_set_info \[exec cat \[file join \[file nativename ~ \] \".signature\"\]\]\n\
	    #########\n"
    puts $awayout "set ::TIK(INFO,updatedynamicinfo) \"$::TIK(INFO,updatedynamicinfo)\""
    puts $awayout "set ::TIK(INFO,dynupdateinterval) \"$::TIK(INFO,dynupdateinterval)\""
    puts $awayout "tik_set_info \{$::TIK(INFO,msg)\}"
    puts $awayout "set ::TIK(options,Away,idlemsg) \"$::TIK(options,Away,idlemsg)\""
    puts $awayout "\n\
	    ##########\n\
	    # Away Messages\n\
	    ##########\n"
    foreach t [lsort -dictionary [array names away::info "awaynicks*"]] {
	set t [string trimleft $t "awaynicks"]
	set t [string trimleft $t ","]
	set msg $away::info(awaynicks,$t)
	set msg [parseaway $msg]
	if {$t != $msg} {
	    puts $awayout "away::register \"$msg\" \"$t\""
	} else {
	    puts $awayout "away::register \"$msg\""
	}
    }
    close $awayout
    old_rc_check $::TIK(awayfile) autoaway
}

proc reloadfiles {} {
    source $::TIK(prefile)
    tik_source_rc
    source $::TIK(awayfile)
}


proc writefiles {} {
    writepre
    writerc
    writeaway
}

proc optrefresh {option window} {
    if {$option == "sound"} {
	if {$::SOUNDPLAYING} {
	    pack forget $window
	} else {
	    pack $window
	}
    }
}

proc updateproxy {hostentry portentry usernameentry passwordentry proxybutton authbutton} {
    if {$::PROXYENABLED} {
	if {$::USEPROXY == "None"} {set ::USEPROXY Socks}
	if {$::USEPROXY == "Socks"} {
	    $hostentry configure -textvariable ::SOCKSHOST -state normal -background white
	    $portentry configure -textvariable ::SOCKSPORT -state normal -background white
	    $usernameentry configure -state disabled -background lightgray
	    $passwordentry configure -state disabled -background lightgray
	    $proxybutton configure -state normal
	    $authbutton configure -state disabled
	    set ::SSLNEEDAUTH 0
	} 
	if {$::USEPROXY == "SSL/HTTP"} {
	    $hostentry configure -textvariable ::SSLHOST -state normal -background white
	    $portentry configure -textvariable ::SSLPORT -state normal -background white
	    $proxybutton configure -state normal
	    $authbutton configure -state normal
	    if {$::SSLNEEDAUTH} {
		$usernameentry configure -state normal -background white
		$passwordentry configure -state normal -background white
	    } else {
		$usernameentry configure -state disabled -background lightgray
		$passwordentry configure -state disabled -background lightgray
	    }
	}
	if {$::USEPROXY == "None"} {
	    #$hostentry configure -state disabled -background lightgray
	    #$portentry configure -state disabled -background lightgray
	    #$usernameentry configure -state disabled -background lightgray
	    #$passwordentry configure -state disabled -background lightgray
	    #$proxybutton configure -state disabled
	    #$authbutton configure -state disabled
	    #set ::PROXYENABLED 0
	}
    } else {
	$hostentry configure -state disabled -background lightgray
	$portentry configure -state disabled -background lightgray
	$usernameentry configure -state disabled -background lightgray
	$passwordentry configure -state disabled -background lightgray
	$proxybutton configure -state disabled
	$authbutton configure -state disabled
	set ::SSLNEEDAUTH 0
	set ::USEPROXY "None"
    }
}

proc flashrefresh {timel time colorl color} {
    if {$::TIK(options,flashim)} {
	$timel configure -foreground black
	$time configure -state normal -background white
	$colorl configure -foreground black
	$color configure -background $::TIK(options,flashimcolor) -state normal
    } else {
	$timel configure -foreground darkgray
	$time configure -state disabled -background lightgray
	$colorl configure -foreground darkgray
	$color configure -background lightgray -state disabled
    }
}

proc prefwindow { {delay 0} } {
    if {$delay} {destroy .installwindow}
    set w .prefwindow
    if {[winfo exists $w]} {
	raise $w
	return
    }
    
    toplevel $w -class Tik
    wm title $w [tik_str CONFIG_MAIN_TITLE]
    wm iconname $w [tik_str CONFIG_MAIN_ICONNAME]


    if {$delay} {grab $w}
    
    Notebook:create $w.n -pages {Connection General Appearance "Appearance II" Sounds Away} -width 610 -height 440 -pad 20
    pack $w.n -fill both -expand 1

    set con [Notebook:frame $w.n Connection]
       set srvf [frame $con.serverframe -border 1 -relief groove]
          set sft [frame $srvf.t]
          label $sft.l -text [tik_str CONFIG_CONNECT_TOC_TITLE]
       set srvb [frame $srvf.b]
          label $srvb.hostl -text [tik_str CONFIG_CONNECT_TOC_HOST]
          entry $srvb.host -textvariable ::TOC(production,host)
          label $srvb.portl -text [tik_str CONFIG_CONNECT_TOC_PORT]
          entry $srvb.port -textvariable ::TOC(production,port)
          pack $srvf -pady 5
          pack $sft
          pack $sft.l
          pack $srvb
          grid $srvb.hostl -column 0 -row 0 -sticky w
          grid $srvb.host -column 1 -row 0 -sticky w
          grid $srvb.portl -column 0 -row 1 -sticky w
          grid $srvb.port -column 1 -row 1 -sticky w
          button $srvb.setdef -command "set ::TOC(production,host) toc.oscar.aol.com; set ::TOC(production,port) 9898" \
		  -text [tik_str CONFIG_CONNECT_TOC_DEFAULT]
    grid $srvb.setdef -column 2 -row 0 -sticky e
       set pf [frame $con.proxyframe -border 1 -relief groove]
          set pft [frame $pf.t]
             checkbutton $pft.proxy -variable ::PROXYENABLED -text [tik_str CONFIG_CONNECT_PROXY_CB]
             pack $pft.proxy
             pack $pft
          set pfrf [frame $pf.rf]
          set pfb [frame $pfrf.b -border 1 -relief groove]
             set pfbt [frame $pfb.t]
                label $pfbt.l -text [tik_str CONFIG_CONNECT_PROXY_PTITLE]
                pack $pfbt $pfbt.l
             set pfbs [frame $pfb.s]
                label $pfbs.hostl -text [tik_str CONFIG_CONNECT_PROXY_HOST]
                entry $pfbs.host 
                label $pfbs.portl -text [tik_str CONFIG_CONNECT_PROXY_PORT]
                entry $pfbs.port
                pack $pfbs
                grid $pfbs.hostl -column 0 -row 0 -sticky w
                grid $pfbs.host -column 1 -row 0 -sticky w
                grid $pfbs.portl -column 0 -row 1 -sticky w
                grid $pfbs.port -column 1 -row 1 -sticky w
            pack $pfb -side left -padx 5 -pady 10
            pack $pf
         set pfp [frame $pfrf.p -border 1 -relief groove]
            set pfpt [frame $pfp.t]
                label $pfpt.t -text [tik_str CONFIG_CONNECT_PROXY_PROTOCOL]
            pack $pfpt $pfpt.t
            set pfpb [frame $pfp.b]
               menubutton $pfpb.proxies -textvariable ::USEPROXY -indicatoron 1 \
                  -menu $pfpb.proxies.menu \
                  -bd 2 -highlightthickness 2 -anchor c \
                  -direction flush
               menu $pfpb.proxies.menu -tearoff 0
            pack $pfpb.proxies
            pack $pfpb
         pack $pfp -padx 5 -pady 10
         pack $pfrf     
	 set pfa [frame $pf.a -border 1 -relief groove]
	    set pfat [frame $pfa.t]
               label $pfat.l -text [tik_str CONFIG_CONNECT_AUTH_TITLE]
               checkbutton $pfat.c -variable ::SSLNEEDAUTH -text [tik_str CONFIG_CONNECT_AUTH_CB]
	       pack $pfat.l
               pack $pfat.c
            pack $pfat
            set pfab [frame $pfa.b]
	       label $pfab.usernamel -text [tik_str CONFIG_CONNECT_AUTH_USERNAME]
	       entry $pfab.username -textvariable ::SSLUSER
	       label $pfab.passwordl -text [tik_str CONFIG_CONNECT_AUTH_PASS]
	       entry $pfab.password -textvariable ::SSLPASS -show "*" -exportselection 0
               grid $pfab.usernamel -column 0 -row 0 -sticky w
	       grid $pfab.username -column 1 -row 0 -sticky w
	       grid $pfab.passwordl -column 0 -row 1 -sticky w
	       grid $pfab.password -column 1 -row 1 -sticky w
         pack $pfab 
	 pack $pfa -side bottom

         set recon [frame $con.recon]
            checkbutton $recon.c -variable ::TIK(options,persistent) -text [tik_str CONFIG_CONNECT_RECONNECT_CB]
            checkbutton $recon.verchk -variable ::TIK(options,checkversion) -text [tik_str CONFIG_CONNECT_VERCHECK]
            grid $recon.c -sticky w
            grid $recon.verchk -sticky w
        pack $recon
    $pfpb.proxies.menu add radiobutton -label Socks -variable ::USEPROXY -value "Socks" -command "updateproxy $pfbs.host $pfbs.port $pfab.username $pfab.password $pfpb.proxies $pfat.c"
    $pfpb.proxies.menu add radiobutton -label "SSL/HTTP" -variable ::USEPROXY -value "SSL/HTTP" -command "updateproxy $pfbs.host $pfbs.port $pfab.username $pfab.password $pfpb.proxies $pfat.c"
    $pft.proxy configure -command "updateproxy $pfbs.host $pfbs.port $pfab.username $pfab.password $pfpb.proxies $pfat.c"
    $pfat.c configure -command "updateproxy $pfbs.host $pfbs.port $pfab.username $pfab.password $pfpb.proxies $pfat.c"
    updateproxy $pfbs.host $pfbs.port $pfab.username $pfab.password $pfpb.proxies $pfat.c
    
    set app [Notebook:frame $w.n Appearance]
    set im [frame $app.im -border 1 -relief groove]
       set iml [frame $im.l]
          label $iml.l -text [tik_str CONFIG_APP_IMTITLE]
          pack $iml.l $iml
       set imb [frame $im.b]
          checkbutton $imb.imt -variable ::TIK(options,imtime) -text [tik_str CONFIG_APP_IMTIMESTAMPS]
          checkbutton $imb.chatt -variable ::TIK(options,chattime) -text [tik_str CONFIG_APP_CHATTIMESTAMPS]
    
    ######################
    ####
    ##   Some of the labels will contain spaces preceding the text.
    ##   AT THIS POINT THEY MUST REMAIN
    ##   This has been done to save space by reducing the use of
    ##   columns when gridding. There may be more efficient ways
    ##   of doing this, but, until they are implemented, do not remove the spaces.
    ####
    #####################

    proc refreshcolor {button color} {
	if { [info exists $color] && [expr $$color] != "" } {
	    set color [expr $$color]
	    $button configure -activebackground $color -background $color
	}
    }
    
          label $imb.iimheightl -text "        [tik_str CONFIG_APP_IIMHEIGHT]"
          entry $imb.iimheight -textvariable ::TIK(options,iimheight) -width 3
          label $imb.cimheightl -text "        [tik_str CONFIG_APP_IMHEIGHT]"
          entry $imb.cimheight -textvariable ::TIK(options,cimheight) -width 3
          checkbutton $imb.cimexpand -variable ::TIK(options,cimexpand) -text [tik_str CONFIG_APP_CIMEXPAND]
          checkbutton $imb.procim -variable ::TIK(options,imcolor) -text [tik_str CONFIG_APP_IMCOLORS]
          checkbutton $imb.procchat -variable ::TIK(options,chatcolor) -text [tik_str CONFIG_APP_CHATCOLORS]
          label $imb.imcolorl -text "        [tik_str CONFIG_APP_MYIMCOLOR]"
          button $imb.imcolor -command "tik_set_default_color defaultimcolor $imb.imcolor"
          label $imb.chatcolorl -text "        [tik_str CONFIG_APP_MYCHATCOLOR]"
          button $imb.chatcolor -command "tik_set_default_color defaultchatcolor $imb.chatcolor"
          checkbutton $imb.flashim -variable ::TIK(options,flashim) -text [tik_str CONFIG_APP_FLASHSB]
          label $imb.flashimtimel -text "        [tik_str CONFIG_APP_FLASHINTERVAL]"
          entry $imb.flashimtime -textvariable ::TIK(options,flashimtime) -width 3
          label $imb.flashcolorl -text "        [tik_str CONFIG_APP_FLASHCOLOR]"
          button $imb.flashcolor -command "tik_set_default_color flashimcolor $imb.flashcolor"
          checkbutton $imb.bbar -variable ::TIK(options,buttonbar) -text [tik_str CONFIG_APP_SHOWBBAR]
          checkbutton $imb.emote -variable ::TIK(options,showsmilies) -text [tik_str CONFIG_APP_SHOWEMOTES]
          checkbutton $imb.star -variable ::TIK(options,focusrmstar) -text [tik_str CONFIG_APP_FOCUSRMSTAR]
          label $imb.msnl -text "       [tik_str CONFIG_APP_MYSNCOLOR]"
          button $imb.msn -command "tik_set_default_color mysncolor $imb.msn"
          label $imb.osnl -text "       [tik_str CONFIG_APP_OTHERSNCOLOR]"
          button $imb.osn -command "tik_set_default_color othersncolor $imb.osn"
    
          refreshcolor $imb.imcolor ::TIK(options,defaultimcolor)
          refreshcolor $imb.chatcolor ::TIK(options,defaultchatcolor)
          refreshcolor $imb.flashcolor ::TIK(options,flashimcolor)
          refreshcolor $imb.msn ::TIK(options,mysncolor)
          refreshcolor $imb.osn ::TIK(options,othersncolor)

          checkbutton $imb.raiseim -variable ::TIK(options,raiseim) -text [tik_str CONFIG_APP_RAISEIM]
          checkbutton $imb.deiconifyim -variable ::TIK(options,deiconifyim) -text [tik_str CONFIG_APP_DEICONIFYIM]
          checkbutton $imb.raisechat -variable ::TIK(options,raisechat) -text [tik_str CONFIG_APP_RAISECHAT]
          checkbutton $imb.deiconifychat -variable ::TIK(options,deiconifychat) -text [tik_str CONFIG_APP_DEICONIFYCHAT]
          grid $imb.imt -column 0 -row 0 -sticky w
          grid $imb.chatt -column 0 -row 1 -sticky w
          grid $imb.iimheight -column 0 -row 2 -sticky w
          grid $imb.iimheightl -column 0 -row 2 -sticky w
          grid $imb.cimheight -column 0 -row 3 -sticky w
          grid $imb.cimheightl -column 0 -row 3 -sticky w
          grid $imb.cimexpand -column 0 -row 4 -sticky w
          grid $imb.msn -column 0 -row 5 -sticky w 
          grid $imb.msnl -column 0 -row 5 -sticky w
          grid $imb.procim -column 1 -row 0 -sticky w
          grid $imb.procchat -column 1 -row 1 -sticky w
          grid $imb.imcolor -column 1 -row 2 -sticky w
          grid $imb.imcolorl -column 1 -row 2 -sticky w
          grid $imb.chatcolorl -column 1 -row 3 -sticky w
          grid $imb.chatcolor -column 1 -row 3 -sticky w
          grid $imb.emote -column 1 -row 4 -sticky w
          grid $imb.osnl -column 1 -row 5 -sticky w
          grid $imb.osn -column 1 -row 5 -sticky w
          grid $imb.flashim -column 3 -row 0 -sticky w
          grid $imb.flashcolorl -column 3 -row 1 -sticky w
          grid $imb.flashcolor -column 3 -row 1 -sticky w
          grid $imb.flashimtimel -column 3 -row 2 -sticky w
          grid $imb.flashimtime -column 3 -row 2 -sticky w
          grid $imb.bbar -column 3 -row 3 -sticky w
          grid $imb.star -column 3 -row 4 -sticky w
          grid $imb.raiseim -column 3 -row 5 -sticky w
          grid $imb.raisechat -column 0 -row 6 -sticky w
          grid $imb.deiconifychat -column 1 -row 6 -sticky w
          grid $imb.deiconifyim -column 3 -row 6 -sticky w

          $imb.flashim configure -command "flashrefresh $imb.flashimtimel $imb.flashimtime $imb.flashcolorl $imb.flashcolor"
          if {!$::TIK(options,flashim)} {flashrefresh $imb.flashimtimel $imb.flashimtime $imb.flashcolorl $imb.flashcolor}
	  set rframe [frame $app.rframe]
	  set budl [frame $rframe.buddylist -border 1 -relief groove]
	  set blt [frame $budl.title]
	     label $blt.t -text [tik_str CONFIG_APP_BUDDYTITLE]
	  pack $blt.t $blt
          set bl [frame $budl.body]
          checkbutton $bl.offline -variable ::TIK(options,showofflinegroup) -text [tik_str CONFIG_APP_SHOWOFFLINE]
	  checkbutton $bl.gtotals -variable ::TIK(options,showgrouptotals) -text [tik_str CONFIG_APP_GROUPTOTALS]
	  checkbutton $bl.idle -variable ::TIK(options,showidletime) -text [tik_str CONFIG_APP_BUDDYIDLE]
	  checkbutton $bl.evil -variable ::TIK(options,showevil) -text [tik_str CONFIG_APP_BUDDYEVIL]
	  checkbutton $bl.icon -variable ::TIK(options,showicons) -text [tik_str CONFIG_APP_SHOWICONS]
	  checkbutton $bl.pad -variable ::TIK(options,padframe) -text [tik_str CONFIG_APP_PADBUDDYWIN]
	  label $bl.sagwidthl -text "        [tik_str CONFIG_APP_SAGBORDER]"
	  entry $bl.sagwidth -textvariable ::TIK(options,sagborderwidth) -width 2
	  label $bl.buddycolorl -text "        [tik_str CONFIG_APP_BUDDYCOLOR]"
	  button $bl.buddycolor -command "tik_set_default_color buddymcolor $bl.buddycolor"
	  label $bl.buddystatsl -text "        [tik_str CONFIG_APP_BSTATSCOLOR]"
	  button $bl.buddystats -command "tik_set_default_color buddyocolor $bl.buddystats"
	  label $bl.blistcolorl -text "        [tik_str CONFIG_APP_BLISTCOLOR]"
	  button $bl.blistcolor -command "tk_messageBox -icon warning -type ok -message \"[tik_str CONFIG_APP_BUDDYCOLORMSG]\"; tik_set_default_color buddylistbground $bl.blistcolor"
	  label $bl.groupcolorl -text "        [tik_str CONFIG_APP_GROUPCOLOR]"
	  button $bl.groupcolor -command "tik_set_default_color groupmcolor $bl.groupcolor"
	  label $bl.groupstatsl -text "        [tik_str CONFIG_APP_GSTATSCOLOR]"
	  button $bl.groupstats -command "tik_set_default_color groupocolor $bl.groupstats"
	  checkbutton $bl.search -variable ::TIK(options,Search,display) -text [tik_str CONFIG_APP_SHOWSEARCH]
	  label $bl.defsearchl -text [tik_str CONFIG_APP_SEARCHENG]
	  menubutton $bl.defsearch -textvariable ::TIK(options,Search,default) -menu $bl.defsearch.menu
	  menu $bl.defsearch.menu -tearoff 0
	  foreach t {NetFind "Deja News" AltaVista Yahoo SearchSpaniel "SearchSpaniel-All" Metacrawler Infoseek Google GoogleLinux TOC} {
	      $bl.defsearch.menu add radiobutton -label $t -variable ::TIK(options,Search,default) -value $t
	  }
	  checkbutton $bl.iconbuttons -variable ::TIK(options,iconbuttons) -text [tik_str CONFIG_APP_ICONBUTTONS]

	  refreshcolor $bl.buddycolor ::TIK(options,buddymcolor)
	  refreshcolor $bl.buddystats ::TIK(options,buddyocolor)
	  refreshcolor $bl.blistcolor ::TIK(options,buddylistbground)
	  refreshcolor $bl.groupcolor ::TIK(options,groupmcolor)
	  refreshcolor $bl.groupstats ::TIK(options,groupocolor)
	  

	  grid $bl.offline -column 0 -row 0 -sticky w
	  grid $bl.gtotals -column 0 -row 1 -sticky w
	  grid $bl.idle -column 0 -row 2 -sticky w
	  grid $bl.evil -column 0 -row 3 -sticky w
	  grid $bl.icon -column 0 -row 4 -sticky w

	  grid $bl.pad -column 1 -row 0 -sticky w
	  grid $bl.sagwidthl -column 1 -row 1 -sticky w
	  grid $bl.sagwidth -column 1 -row 1 -sticky w
	  grid $bl.buddycolorl -column 1 -row 2 -sticky w
	  grid $bl.buddycolor -column 1 -row 2  -sticky w
	  grid $bl.buddystatsl -column 1 -row 3 -sticky w
	  grid $bl.buddystats -column 1 -row 3 -sticky w
	  grid $bl.iconbuttons -column 1 -row 4 -sticky w
	  
	  grid $bl.blistcolorl -column 2 -row 0 -sticky w
	  grid $bl.blistcolor -column 2 -row 0 -sticky w 
	  grid $bl.groupcolorl -column 2 -row 1 -sticky w
	  grid $bl.groupcolor -column 2 -row 1 -sticky w
	  grid $bl.groupstatsl -column 2 -row 2 -sticky w
	  grid $bl.groupstats -column 2 -row 2 -sticky w
	  grid $bl.search -column 2  -row 3 -sticky w
	  grid $bl.defsearchl -column 2 -row 4 -sticky e
	  grid $bl.defsearch -column 3 -row 4 -sticky w
      pack $im ;#-side left
      pack $budl
      pack $bl
      pack $imb

      set bh [frame $rframe.balloonhelp -border 1 -relief groove ]
      pack $rframe ;#-side left
      set bht [frame $bh.title]
	  #label $bht.t -text [tik_str CONFIG_APP_BALLOONTITLE]
	  #pack $bht.t
      pack $bht
      set bhb [frame $bh.body]
          checkbutton $bhb.usebh -variable ::USEBALLOONHELP -text [tik_str CONFIG_APP_BALLOONUSE]
	  checkbutton $bhb.showsn -variable ::TIK(options,nameonblist) -text [tik_str CONFIG_APP_NAMEONBLIST]
          grid $bhb.usebh -column 0 -row 0 -sticky w
	  grid $bhb.showsn -column 1 -row 0 -sticky w
      pack $bhb
      pack $bh -fill x 

	
    set app2 [Notebook:frame $w.n "Appearance II"]
	  set lang [frame $app2.lang -border 1 -relief groove]
	  set langt [frame $lang.title]
	  label $langt.title -text [tik_str CONFIG_APP_LANGTITLE]
	  pack $langt.title $langt
	  set langb [frame $lang.body]
	  label $langb.lang -text [tik_str CONFIG_APP_LANG]
	  menubutton $langb.langmenu -indicatoron 1 -menu $langb.langmenu.menu -text $::TIK(options,language)
	  menu $langb.langmenu.menu -postcommand "tik_strs_menu $langb.langmenu.menu" -tearoff 0
	  grid $langb.lang -column 0 -row 0 -sticky w
	  grid $langb.langmenu -column 1 -row 0 -sticky w
	  pack $langb $lang
	  set am [frame $app2.main -border 1 -relief groove]
	  label $am.bgroundl -text "       [tik_str CONFIG_APP_BGROUND]"
	  button $am.bground -command "tik_set_default_color defaultbackground $am.bground"
	  label $am.abgroundl -text "       [tik_str CONFIG_APP_ABGROUND]"
	  button $am.abground -command "tik_set_default_color activebackground $am.abground"
	  label $am.tbgroundl -text "       [tik_str CONFIG_APP_TEXTBGROUND]"
	  button $am.tbground -command "tik_set_default_color textbackground $am.tbground"
	  label $am.tfgroundl -text "       [tik_str CONFIG_APP_TEXTFGROUND]"
	  button $am.tfground -command "tik_set_default_color textforeground $am.tfground"
	  label $am.ebgroundl -text "       [tik_str CONFIG_APP_ENTRYBGROUND]"
	  button $am.ebground -command "tik_set_default_color entrybackground $am.ebground"
	  label $am.efgroundl -text "       [tik_str CONFIG_APP_ENTRYFGROUND]"
	  button $am.efground -command "tik_set_default_color entryforeground $am.efground"
	  label $am.sbgroundl -text "       [tik_str CONFIG_APP_SBBGROUND]"
	  button $am.sbground -command "tik_set_default_color scrollbarbackground $am.sbground"
	  label $am.bbgroundl -text "       [tik_str CONFIG_APP_BBGROUND]"
	  button $am.bbground -command "tik_set_default_color buttonbackground $am.bbground"
	  label $am.buttonfontl -text [tik_str CONFIG_APP_BFONT]
	  menubutton $am.buttonfont -indicatoron 1 -menu $am.buttonfont.menu
	  menu $am.buttonfont.menu
	  label $am.buttonreliefl -text [tik_str CONFIG_APP_BRELIEF]
	  menubutton $am.buttonrelief -indicatoron 1 -menu $am.buttonrelief.menu
	  menu $am.buttonrelief.menu
	  label $am.menureliefl -text [tik_str CONFIG_APP_MRELIEF]
	  menubutton $am.menurelief -indicatoron 1 -menu $am.menurelief.menu
	  menu $am.menurelief.menu
	  label $am.mbreliefl -text [tik_str CONFIG_APP_MBRELIEF]
	  menubutton $am.mbrelief -indicatoron 1 -menu $am.mbrelief.menu
	  menu $am.mbrelief.menu
	  label $am.sbwidthl -text "       [tik_str CONFIG_APP_SBWIDTH]"
	  entry $am.sbwidthe -width "3" -textvariable ::TIK(options,scrollbarwidth)
	  scrollbar $am.sbwidth
	  button $am.sbwidthb -command "sbrefresh $am.sbwidth" -text [tik_str CONFIG_APP_SBAPPLY]
	  

	  refreshcolor $am.bground ::TIK(options,defaultbackground)
	  refreshcolor $am.abground ::TIK(options,activebackground)
	  refreshcolor $am.tbground ::TIK(options,textbackground)
	  refreshcolor $am.tfground ::TIK(options,textforeground)
	  refreshcolor $am.ebground ::TIK(options,entrybackground)
	  refreshcolor $am.efground ::TIK(options,entryforeground)
	  refreshcolor $am.sbground ::TIK(options,scrollbarbackground)
	  refreshcolor $am.bbground ::TIK(options,buttonbackground)
	  
	  proc listfonts {fontmenu} {
	      $fontmenu.menu delete 0 end
	      set count 1
	      foreach f [lsort -dictionary [font families]] {
		  if {$count >= 20} {
		      $fontmenu.menu add radiobutton -variable ::TIK(options,buttonfont) -label $f -columnbreak 1; set count 0
		  } else { 
		      $fontmenu.menu add radiobutton -variable ::TIK(options,buttonfont) -label $f -command "refreshbutton button font $fontmenu"
		  }
		  incr count
	      }
	  }
	  
	  listfonts $am.buttonfont

	  proc refreshbutton {type1 type2 menu} {
	      if {[info exists ::TIK(options,$type1$type2)] && [string length $::TIK(options,$type1$type2)]} {
		  if {$type2 == "relief"} {
		      $menu configure -text $::TIK(options,$type1$type2) -relief $::TIK(options,$type1$type2)
		  } else {
		      $menu configure -text $::TIK(options,$type1$type2) -font "{$::TIK(options,$type1$type2)}"
		  }
	      } else {
		  $menu configure -text [tik_str CONFIG_APP_SELECT]
		  set ::TIK(options,$type1$type2) \"\"
	      }
	  }
	  refreshbutton button font $am.buttonfont
	  refreshbutton button relief $am.buttonrelief
	  refreshbutton menu relief $am.menurelief
	  refreshbutton menubutton relief $am.mbrelief

	  if [info exists ::TIK(options,defaultbackground)] {
	      catch { $am.bground configure \
		      -background $::TIK(options,defaultbackground) \
		      -activebackground $::TIK(options,defaultbackground)
	  }
      }
      
      proc listreliefs {type reliefmenu} {
	  $reliefmenu.menu delete 0 end
	  set tclneedsmorefeatures relief
	  foreach r {groove raised sunken flat ridge solid} {
	      $reliefmenu.menu add radiobutton -variable ::TIK(options,[concat $type$tclneedsmorefeatures]) \
		      -label $r -command "refreshbutton $type relief $reliefmenu"
	  }
      }
      
      listreliefs button $am.buttonrelief
      listreliefs menu $am.menurelief
      listreliefs menubutton $am.mbrelief
      
      
      proc sbrefresh {sb} {
	  if {[info exists ::TIK(options,scrollbarwidth)] && [string length $::TIK(options,scrollbarwidth)]} {
	      $sb configure -width $::TIK(options,scrollbarwidth)
	  } else {
	      set ::TIK(options,scrollbarwidth) [$sb cget -width]
	  }
      }
      sbrefresh $am.sbwidth
      
      grid $am.bgroundl -column 0 -row 0 -sticky w
      grid $am.bground -column 0 -row 0 -sticky w
      grid $am.abgroundl -column 0 -row 1 -sticky w
      grid $am.abground -column 0 -row 1 -sticky w
      grid $am.tbgroundl -column 0 -row 2 -sticky w
      grid $am.tbground -column 0 -row 2 -sticky w
      grid $am.tfgroundl -column 0 -row 3 -sticky w
      grid $am.tfground -column 0 -row 3 -sticky w
      grid $am.ebgroundl -column 0 -row 4 -sticky w
      grid $am.ebground -column 0 -row 4 -sticky w
      grid $am.efgroundl -column 0 -row 5 -sticky w
      grid $am.efground -column 0 -row 5 -sticky w
      grid $am.sbgroundl -column 0 -row 6 -sticky w
      grid $am.sbground -column 0 -row 6 -sticky w
      grid $am.bbgroundl -column 0 -row 7 -sticky w
      grid $am.bbground -column 0 -row 7 -sticky w
      grid $am.buttonfontl -column 0 -row 8 -sticky w
      grid $am.buttonfont -column 1 -row 8 -sticky w
      grid $am.buttonreliefl -column 0 -row 9 -sticky w
      grid $am.buttonrelief -column 1 -row 9 -sticky w
      grid $am.menureliefl -column 0 -row 10 -sticky w
      grid $am.menurelief -column 1 -row 10 -sticky w
      grid $am.mbreliefl -column 0 -row 11 -sticky w
      grid $am.mbrelief -column 1 -row 11 -sticky w
      grid $am.sbwidthl -column 0 -row 12 -sticky w
      grid $am.sbwidthe -column 0 -row 12 -sticky w
      grid $am.sbwidthb -column 1 -row 13 -sticky w
      grid $am.sbwidth -column 2 -row 13 -sticky w
      pack $am

      
      proc browsesounds {sound} {
	  set types {
	      {{Sound Files} {.wav .au}}
	      {{wave files} {.wav}}
	      {{au files} {.au}}
	      {{All files} *}
	  }
	  set $sound [tk_getOpenFile -filetypes $types -initialdir [file join $::TIK(BASEDIR) media]]
      }
      
      
      set sound [Notebook:frame $w.n Sounds]
      set soundl [frame $sound.l]
      label $soundl.l -text [tik_str CONFIG_SOUND_L1]
      pack $soundl.l $soundl
      
      set soundt [frame $sound.top]
      checkbutton $soundt.c -variable ::SOUNDPLAYING -offvalue 1 -onvalue 0 \
	      -text [tik_str CONFIG_SOUND_ENABLE] -command "optrefresh sound $sound.options"
      checkbutton $soundt.s -variable ::TIK(options,silentaway) -text [tik_str CONFIG_SOUND_SILENT]
      label $soundt.routinel -text [tik_str CONFIG_SOUND_ROUTINE]
      entry $soundt.routine -textvariable ::TIK(SOUNDROUTINE)
      label $soundt.spacer -text "\n"

      pack $soundt
      grid $soundt.c -column 0 -row 0 -sticky w
      grid $soundt.s -column 0 -row 1 -sticky w
      grid $soundt.routinel -column 0 -row 2 -sticky w
      grid $soundt.routine -column 1 -row 2 -sticky w
      grid $soundt.spacer -column 0 -row 3 -sticky w

    frame $sound.options
    label $sound.options.sendl -text [tik_str CONFIG_SOUND_SEND]
    entry $sound.options.send -textvariable ::TIK(SOUND,Send)
    button $sound.options.sendb -command "browsesounds ::TIK(SOUND,Send)" -text [tik_str CONFIG_SOUND_BROWSE]
    button $sound.options.sendp -command "tik_play_sound3 Send" -text [tik_str CONFIG_SOUND_PREVIEW]
    label $sound.options.receivel -text [tik_str CONFIG_SOUND_RECEIVE]
    entry $sound.options.receive -textvariable ::TIK(SOUND,Receive)
    button $sound.options.receiveb -command "browsesounds ::TIK(SOUND,Receive)" -text [tik_str CONFIG_SOUND_BROWSE]
    button $sound.options.receivep -command "tik_play_sound3 Receive" -text [tik_str CONFIG_SOUND_PREVIEW]
    label $sound.options.initiall -text [tik_str CONFIG_SOUND_INITIAL]
    entry $sound.options.initial -textvariable ::TIK(SOUND,Initial)
    button $sound.options.initialb -command "browsesounds ::TIK(SOUND,Initial)" -text [tik_str CONFIG_SOUND_BROWSE]
    button $sound.options.initialp -command "tik_play_sound3 Initial" -text [tik_str CONFIG_SOUND_PREVIEW]
    label $sound.options.chatsendl -text [tik_str CONFIG_SOUND_CHATSEND]
    entry $sound.options.chatsend -textvariable ::TIK(SOUND,ChatSend)
    button $sound.options.chatsendb -command "browsesounds ::TIK(SOUND,ChatSend)" -text [tik_str CONFIG_SOUND_BROWSE]
    button $sound.options.chatsendp -command "tik_play_sound3 ChatSend" -text [tik_str CONFIG_SOUND_PREVIEW]
    label $sound.options.chatreceivel -text [tik_str CONFIG_SOUND_CHATREC]
    entry $sound.options.chatreceive -textvariable ::TIK(SOUND,ChatReceive)
    button $sound.options.chatreceiveb -command "browsesounds ::TIK(SOUND,ChatReceive)" -text [tik_str CONFIG_SOUND_BROWSE]
    button $sound.options.chatreceivep -command "tik_play_sound3 ChatReceive" -text [tik_str CONFIG_SOUND_PREVIEW]
    label $sound.options.arrivel -text [tik_str CONFIG_SOUND_ARRIVE]
    entry $sound.options.arrive -textvariable ::TIK(SOUND,Arrive)
    button $sound.options.arriveb -command "browsesounds ::TIK(SOUND,Arrive)" -text [tik_str CONFIG_SOUND_BROWSE]
    button $sound.options.arrivep -command "tik_play_sound3 Arrive" -text [tik_str CONFIG_SOUND_PREVIEW]
    label $sound.options.departl -text [tik_str CONFIG_SOUND_DEPART]
    entry $sound.options.depart -textvariable ::TIK(SOUND,Depart)
    button $sound.options.departb -command "browsesounds ::TIK(SOUND,Depart)" -text [tik_str CONFIG_SOUND_BROWSE]
    button $sound.options.departp -command "tik_play_sound3 Depart" -text [tik_str CONFIG_SOUND_PREVIEW]

   #pack $sound.l $sound.c $sound.s $sound.routinel $sound.routine

    grid $sound.options.sendl -column 0 -row 0 -sticky w 
    grid $sound.options.send -column 1 -row 0 -sticky w
    grid $sound.options.sendb -column 2 -row 0 -sticky w
    grid $sound.options.sendp -column 3 -row 0 -sticky w
    grid $sound.options.receivel -column 0 -row 1 -sticky w
    grid $sound.options.receive -column 1 -row 1 -sticky w
    grid $sound.options.receiveb -column 2 -row 1 -sticky w 
    grid $sound.options.receivep -column 3 -row 1 -sticky w
    grid $sound.options.chatsendl -column 0 -row 2 -sticky w
    grid $sound.options.chatsend -column 1 -row 2 -sticky w
    grid $sound.options.chatsendb -column 2 -row 2 -sticky w
    grid $sound.options.chatsendp -column 3 -row 2 -sticky w
    grid $sound.options.chatreceivel -column 0 -row 3 -sticky w
    grid $sound.options.chatreceive -column 1 -row 3 -sticky w
    grid $sound.options.chatreceiveb -column 2 -row 3 -sticky w
    grid $sound.options.chatreceivep -column 3 -row 3 -sticky w
    grid $sound.options.arrivel -column 0 -row 4 -sticky w
    grid $sound.options.arrive -column 1 -row 4 -sticky w
    grid $sound.options.arriveb -column 2 -row 4 -sticky w
    grid $sound.options.arrivep -column 3 -row 4 -sticky w
    grid $sound.options.departl -column 0 -row 5 -sticky w
    grid $sound.options.depart -column 1 -row 5 -sticky w
    grid $sound.options.departb -column 2 -row 5 -sticky w
    grid $sound.options.departp -column 3 -row 5 -sticky w
    grid $sound.options.initiall -column 0 -row 6 -sticky w
    grid $sound.options.initial -column 1 -row 6 -sticky w
    grid $sound.options.initialb -column 2 -row 6 -sticky w
    grid $sound.options.initialp -column 3 -row 6 -sticky w
    if {$::SOUNDPLAYING == 0} {
	pack $sound.options
    }

    set gen [Notebook:frame $w.n General]
    set gentop [frame $gen.top]
    set sf [frame $gentop.signon -border 1 -relief groove]
    set sfl [frame $sf.l]
    label $sfl.l -text [tik_str CONFIG_GEN_SIGNON]
    set sfb [frame $sf.b]
    set sfbv [frame $sfb.v]
    set sfbc [frame $sfb.c]
    label $sfbv.snl -text [tik_str CONFIG_GEN_SCREENNAME]
    entry $sfbv.sn -textvariable ::AUTOSCREENNAME -width 16
    label $sfbv.pwl -text [tik_str CONFIG_GEN_PASSWORD]
    entry $sfbv.pw -textvariable ::AUTOPASSWORD -show "*" -width 16
    checkbutton $sfbc.as -variable ::AUTOSIGNON -text [tik_str CONFIG_GEN_AUTOSIGNON]
    pack $sf -side left -padx 10 -pady 5
    pack $sfl $sfl.l
    grid $sfbv.snl -column 0 -row 0 -sticky w
    grid $sfbv.sn -column 1 -row 0 -sticky w
    grid $sfbv.pwl -column 0 -row 1  -sticky w
    grid $sfbv.pw -column 1 -row 1 -sticky w
    grid $sfbc.as -column 0 -row 3 -sticky w
    pack $sfb.v
    pack $sfb.c
    pack $sfb
    set sdebug [frame $gentop.sflapdebug -border 1 -relief groove]
    set sdt [frame $sdebug.title]
    label $sdt.l -text [tik_str CONFIG_GEN_SFLAP]
    pack $sdt.l $sdt
    set sdb [frame $sdebug.body]
    radiobutton $sdb.0 -variable sflap::debug_level -value 0 -text [tik_str M_SFLAP_0]
    radiobutton $sdb.1 -variable sflap::debug_level -value 1 -text [tik_str M_SFLAP_1]
    radiobutton $sdb.2 -variable sflap::debug_level -value 2 -text [tik_str M_SFLAP_2]
    grid $sdb.0 -column 0 -row 0 -sticky w
    grid $sdb.1 -column 0 -row 1 -sticky w
    grid $sdb.2 -column 0 -row 2 -sticky w
    pack $sdb
    pack $sdebug -side right
    pack $gentop
    set middle [frame $gen.middle]
    set logf [frame $middle.logframe -border 1 -relief groove]
    set logft [frame $logf.title]
    label $logft.t -text [tik_str CONFIG_GEN_LOGSTITLE]
    pack $logft.t $logft
    set logb [frame $logf.body]
    checkbutton $logb.imuse -variable ::TIK(options,imcapture,use) -text [tik_str CONFIG_GEN_LOGIM]
    checkbutton $logb.chatuse -variable ::TIK(options,chatcapture,use) -text [tik_str CONFIG_GEN_LOGCHAT]
    checkbutton $logb.imstamp -variable ::TIK(options,imcapture,timestamp) -text [tik_str CONFIG_GEN_TIMEIMLOGS]
    checkbutton $logb.chatstamp -variable ::TIK(options,chatcapture,timestamp) -text [tik_str CONFIG_GEN_TIMECHATLOGS]
    grid $logb.imuse -column 0 -row 0 -sticky w
    grid $logb.chatuse -column 0 -row 1 -sticky w
    grid $logb.imstamp -column 0 -row 2 -sticky w
    grid $logb.chatstamp -column 0 -row 3 -sticky w
    pack $logb -padx 5
    set keyf [frame $middle.keyframe -border 1 -relief groove]
    set keyt [frame $keyf.title]
    label $keyt.t -text [tik_str CONFIG_GEN_SENDKEYS]
    pack $keyt.t $keyt
    set keyb [frame $keyf.body]
    radiobutton $keyb.0 -variable ::TIK(options,msgsend) -value 0 -text [tik_str CONFIG_GEN_KEY0]
    radiobutton $keyb.1 -variable ::TIK(options,msgsend) -value 1 -text [tik_str CONFIG_GEN_KEY1]
    radiobutton $keyb.2 -variable ::TIK(options,msgsend) -value 2 -text [tik_str CONFIG_GEN_KEY2]
    radiobutton $keyb.3 -variable ::TIK(options,msgsend) -value 3 -text [tik_str CONFIG_GEN_KEY3]
    grid $keyb.0 -column 0 -row 0 -sticky w
    grid $keyb.1 -column 0 -row 1 -sticky w
    grid $keyb.2 -column 0 -row 2 -sticky w
    grid $keyb.3 -column 0 -row 3 -sticky w
    pack $keyb
    pack $logf -side left -padx 2
    pack $keyf -side right -padx 3
    set fm [frame $middle.filemonitor -border 1 -relief groove]
    set fmt [frame $fm.title]
    label $fmt.t -text [tik_str CONFIG_GEN_FILEMON]
    pack $fmt.t $fmt
    set fmb [frame $fm.body]
    checkbutton $fmb.rc -variable ::TIK(options,monitorrc) -text [tik_str CONFIG_GEN_MONITORRC]
    label $fmb.rctimel -text "           [tik_str CONFIG_GEN_RCTIME]"
    entry $fmb.rctime -textvariable ::TIK(options,monitorrctime) -width 5
    checkbutton $fmb.pkg -variable ::TIK(options,monitorpkg) -text [tik_str CONFIG_GEN_PACKAGEMON]
    label $fmb.pkgtimel -text "           [tik_str CONFIG_GEN_PACKAGETIME]"
    entry $fmb.pkgtime -textvariable ::TIK(options,monitorpkgtime) -width 5
    grid $fmb.rc -column 0 -row 0 -sticky w
    grid $fmb.rctimel -column 0 -row 1 -sticky w
    grid $fmb.rctime -column 0 -row 1 -sticky w
    grid $fmb.pkg -column 0 -row 2 -sticky w
    grid $fmb.pkgtimel -column 0 -row 3 -sticky w
    grid $fmb.pkgtime -column 0 -row 3 -sticky w
    pack $fmb
    pack $fm
    pack $middle
    set bottom [frame $gen.bottom]
    set idlef [frame $bottom.idleframe -border 1 -relief groove]
    checkbutton $idlef.ri -variable ::TIK(options,reportidle) -text [tik_str CONFIG_GEN_REPORTIDLE]
    checkbutton $idlef.wm -variable ::TIK(options,idlewatchmouse) -text [tik_str CONFIG_GEN_IDLEMOUSE]
    label $idlef.afterl -text [tik_str CONFIG_GEN_IDLEAFTER]
    entry $idlef.after -textvariable ::TIK(options,reportidleafter) -width 4
    label $idlef.afterl2 -text [tik_str CONFIG_GEN_IDLESEC]
    label $idlef.updatel -text [tik_str CONFIG_GEN_IDLEUPDATE]
    entry $idlef.update -textvariable ::TIK(options,idleupdateinterval) -width 4
    label $idlef.updatel2 -text [tik_str CONFIG_GEN_IDLEMIN]
    pack $bottom
    pack $idlef -pady 5 -fill x -padx 10
    grid $idlef.ri -column 0 -row 0 -sticky w
    grid $idlef.wm -column 2 -row 0 -sticky w
    grid $idlef.afterl -column 0 -row 1 -sticky w
    grid $idlef.after -column 1 -row 1 -sticky w
    grid $idlef.afterl2 -column 2 -row 1 -sticky w
    grid $idlef.updatel -column 0 -row 2 -sticky w
    grid $idlef.update -column 1 -row 2 -sticky w
    grid $idlef.updatel2 -column 2 -row 2 -sticky w
    pack $bottom -fill x
    set cs [frame $gen.configstorage -border 1 -relief groove]
    set cst [frame $cs.t]
    label $cst.t -text [tik_str CONFIG_GEN_BUDDYSTORE]
    pack $cst.t $cst
    set csb [frame $cs.body]
    radiobutton $csb.0 -variable ::TIK(options,localconfig) -value 0 -text [tik_str CONFIG_GEN_BUDDY0]
    radiobutton $csb.1 -variable ::TIK(options,localconfig) -value 1 -text [tik_str CONFIG_GEN_BUDDY1]
    radiobutton $csb.2 -variable ::TIK(options,localconfig) -value 2 -text [tik_str CONFIG_GEN_BUDDY2]
    radiobutton $csb.3 -variable ::TIK(options,localconfig) -value 3 -text [tik_str CONFIG_GEN_BUDDY3]
    grid $csb.0 -column 0 -row 0 -sticky w
    grid $csb.1 -column 0 -row 1 -sticky w
    grid $csb.2 -column 0 -row 2 -sticky w
    grid $csb.3 -column 0 -row 3 -sticky w 
    pack $csb
    pack $cs

############################################################################ 
# The following code was taken from examples 27-22 and 27-3
# of Brent Welch's book, Practical Programming in Tcl and Tk, second edition.
#
    proc Scroll_set {scrollbar geoCmd offset size} {
	if {$offset != 0.0 || $size != 1.0 } {
	    eval $geoCmd ;# Make sure it is visible
	}
	$scrollbar set $offset $size
    }

    proc scrolledlistbox {f args} {
	frame $f
	listbox $f.list \
		-xscrollcommand [list Scroll_set $f.xscroll \
             		[list grid $f.xscroll -row 1 -column 0 -sticky we]] \
		-yscrollcommand [list Scroll_set $f.yscroll \
        		[list grid $f.yscroll -row 0 -column 1 -sticky ns]]
	eval {$f.list configure} $args
	scrollbar $f.xscroll -orient horizontal \
		-command [list $f.list xview]
	scrollbar $f.yscroll -orient vertical \
		-command [list $f.list yview]
	grid $f.list -sticky news
	grid rowconfigure $f 0 -weight 1
	grid columnconfigure $f 0 -weight 1
	return $f.list
    }
#
# end of book code
#############################################################################

	set awaypage [Notebook:frame $w.n Away]
	set top [frame $awaypage.top -border 1 -relief groove]
	set af [frame $top.awayframe]
	set lf [frame $af.listboxframe]
	set lbox [scrolledlistbox $lf.listbox -background white]
	label $lf.label -text [tik_str CONFIG_AWAY_AWAYLABELS]
	frame $af.msg
	createHTML $af.msg.text
	label $af.msg.label -text [tik_str CONFIG_AWAY_MESSAGEHDR]
	frame $af.msg.bbar
	label $af.msg.bbar.label -text [tik_str CONFIG_AWAY_LABELHDR]
	entry $af.msg.bbar.nick -width 10
	pack $af.msg.bbar.label $af.msg.bbar.nick -side left
	createBbar $af.msg.bbar $af.msg.text.text _NONE_
	button $top.add -text [tik_str CONFIG_AWAY_ADD]
	button $top.edit -state disabled -text [tik_str CONFIG_AWAY_EDIT]
	button $top.delete -state disabled -text [tik_str CONFIG_AWAY_DELETE]
	pack forget $af.msg.bbar.color
	pack forget $af.msg.bbar.hdr
	pack $lf.label
	pack $af.msg.label
	pack $lf -side left
	pack $af
	pack $lf.listbox
	pack $af.msg -side left
	pack $af.msg.text
	pack $top.add $top.edit $top.delete -side left
	pack $top
	
	proc listaways {lbox} {
	    $lbox delete 0 end
	    foreach t [lsort -dictionary [array names away::info "awaynicks*"]] {
		set t [string trimleft $t "awaynicks"] ;# for some reason, string trimleft $t "awaynicks," cuts too much
		set t [string trimleft $t ","]         ;# off of some variables. anyone care to shed some light on this? 
		if [string length $t] {
		    $lbox insert end $t
		}
	    }
	    $lbox insert end ""
	    $lbox insert end "Idle Message"
	    $lbox insert end "My Buddy Info"
	}
	listaways $lbox
	set ::CURRAWAY "_NONE_"
	
    
	proc nickrename {oldnick newnick} {
	    set away::info(awaynicks,$newnick) $away::info(awaynicks,$oldnick)
	    unset away::info(awaynicks,$oldnick)
	}
	
	proc editmode {status} {
	    set af .prefwindow.n.f5.top.awayframe
	    set top .prefwindow.n.f5.top
	    set lbox $af.listboxframe.listbox.list
	    $top.edit configure -state normal
	    $top.delete configure -state normal
	    $af.msg.bbar.nick configure -state normal -background white
	    
	    if {$status == 1} {

		if {$::CURRAWAY == "::TIK(INFO,msg)" || $::CURRAWAY == "::TIK(options,Away,idlemsg)"} {
		    $top.delete configure -state disabled
		    $af.msg.bbar.nick delete 0 end		   
		    $af.msg.bbar.nick configure -state disabled -background lightgray
		}
		pack $af.msg.bbar
		$af.msg.text.text configure -state normal
		$top.edit configure -command "editmode edit" -text [tik_str CONFIG_AWAY_EDITDONE]
		set selection [string trimleft $::CURRAWAY "away::info(awaynicks"]
		set selection [string trimleft $selection ","]
		set selection [string trimright $selection ")"]
		$af.msg.bbar.nick delete 0 end
		$af.msg.bbar.nick insert 0 $selection
	    } elseif {$status == 0} {
		if {$::CURRAWAY != "_NONE_"} {
		    set $::CURRAWAY [$af.msg.text.text get 0.0 end]
		    if {$::CURRAWAY == "::TIK(INFO,msg)"} {
			set ::TIK(INFO,sendinfo) 1
			toc_set_info $::NSCREENNAME $::TIK(INFO,msg)
		    }
		}
		pack forget $af.msg.bbar
		$af.msg.text.text configure -state disabled
		$top.edit configure -command "editmode 1" -text [tik_str CONFIG_AWAY_EDIT]
		$top.add configure -command "editmode add" -text [tik_str CONFIG_AWAY_ADD]
		$af.msg.text.text delete 0.0 end
	    } elseif {$status == "delete"} {
		if {$::CURRAWAY != "_NONE_"} {
		    unset $::CURRAWAY
		    $top.delete configure -state disabled
		    $top.edit configure -state disabled
		    set ::CURRAWAY "_NONE_"
		}
		pack forget $af.msg.bbar
		$af.msg.text.text configure -state disabled
		$top.edit configure -command "editmode 1" -text [tik_str CONFIG_AWAY_EDIT]
		listaways $lbox
		away::listawaysinmenu .awayMenu
	    } elseif {$status == "edit"} {
		set selection [string trimleft $::CURRAWAY "away::info(awaynicks"]
		set selection [string trimleft $selection ","]
		set selection [string trimright $selection ")"]
		if {[$af.msg.bbar.nick get] != "$selection"} {
		    if {$::CURRAWAY != "::TIK(INFO,msg)" && $::CURRAWAY != "::TIK(options,Away,idlemsg)"} {
			nickrename $selection [$af.msg.bbar.nick get]
		    }
		    #set ::CURRAWAY "_NONE_"
		    listaways $lbox
		    away::listawaysinmenu .awayMenu
		}
		editmode 0
	    } elseif {$status == "add"} {
		set ::CURRAWAY "_NONE_"
		pack $af.msg.bbar
		$af.msg.text.text configure -state normal
		$af.msg.text.text delete 0.0 end
		$af.msg.bbar.nick delete 0 end
		$top.edit configure -state disabled
		$top.add configure -command "editmode addend" -text [tik_str CONFIG_AWAY_ADDDONE]
	    } elseif {$status == "addend"} {
            set tempmsg [$af.msg.text.text get 0.0 end]
            set tempnick [$af.msg.bbar.nick get]
		if {![string length $tempnick]} {
                set tempnick [string range $tempmsg 0 [expr $::TIK(options,Away,nicklength) -1]]...
		} 
            if {[regexp -- {[]["${}\\]} $tempnick]} {
                set tempnick "InvalidNick[clock seconds]"
            }
            set away::info(awaynicks,$tempnick) $tempmsg
            unset tempmsg
            unset tempnick
		pack forget $af.msg.bbar
		$af.msg.text.text configure -state disabled
		$top.edit configure -command "editmode 1" -text [tik_str CONFIG_AWAY_EDIT]
		$top.add configure -command "editmode add" -text [tik_str CONFIG_AWAY_ADD]
		listaways $lbox
		away::listawaysinmenu .awayMenu
	    }
	}
	
	$top.edit configure -command "editmode 1"
	$top.delete configure -command "editmode delete"
	$top.add configure -command "editmode add"
	
	bind $lbox <ButtonRelease-1> {
	    set af ".prefwindow.n.f5.top.awayframe"
	    set selection [$af.listboxframe.listbox.list get [$af.listboxframe.listbox.list nearest %y]]
	    set choice away::info(awaynicks,$selection)
	    editmode 0
	    if [info exists $choice] {
		.prefwindow.n.f5.top.edit configure -state normal
		$af.msg.text.text configure -state normal
		set ::CURRAWAY "$choice"
		$af.msg.text.text delete 0.0 end 
            set cleanMsg [expr $$::CURRAWAY]
            while {[regsub -- {(\n|<br>)$} $cleanMsg {} cleanMsg]} {}
            $af.msg.text.text insert 0.0 $cleanMsg
		$af.msg.text.text configure -state disabled
	    } elseif {$selection == ""} {
		set ::CURRAWAY "_NONE_"
		.prefwindow.n.f5.top.edit configure -state disabled
		.prefwindow.n.f5.top.delete configure -state disabled
		$af.msg.text.text configure -state normal
		$af.msg.text.text delete 0.0 end
		$af.msg.text.text configure -state disabled
	    } elseif {$selection == "Idle Message"} {
		.prefwindow.n.f5.top.edit configure -state normal
		.prefwindow.n.f5.top.delete configure -state disabled
		$af.msg.text.text configure -state normal
		set ::CURRAWAY "::TIK(options,Away,idlemsg)"
		$af.msg.text.text delete 0.0 end
		$af.msg.text.text insert 0.0 [expr $$::CURRAWAY]
		$af.msg.text.text configure -state disabled
	    } elseif {$selection == "My Buddy Info"} {
		.prefwindow.n.f5.top.edit configure -state normal
		.prefwindow.n.f5.top.delete configure -state disabled
		$af.msg.text.text configure -state normal
		set ::CURRAWAY "::TIK(INFO,msg)"
		$af.msg.text.text delete 0.0 end
		$af.msg.text.text insert 0.0 [expr $$::CURRAWAY]
		$af.msg.text.text configure -state disabled
	    }
	}
	
	
	set opts [frame $awaypage.options -border 1 -relief groove]
	label $opts.awaydelayl -text "            [tik_str CONFIG_AWAY_AWAYDELAY]"
	entry $opts.awaydelay -textvariable ::TIK(options,Away,delay) -width 6 
	checkbutton $opts.idle -variable ::TIK(options,Away,sendidle) -text [tik_str CONFIG_AWAY_IDLEUSE]
	label $opts.idledelayl -text "       [tik_str CONFIG_AWAY_IDLEDELAY]"
	entry $opts.idledelay -textvariable ::TIK(options,Away,idlewait) -width 3
	checkbutton $opts.usegetaway -variable ::TIK(options,getaway,use) -text [tik_str CONFIG_AWAY_USEGETAWAY]
	checkbutton $opts.notifygetaway -variable ::TIK(options,getaway,notify) -text [tik_str CONFIG_AWAY_NOTIFYGETAWAY]
	checkbutton $opts.dynamicinfo -variable ::TIK(INFO,updatedynamicinfo) -text [tik_str CONFIG_AWAY_UPDYNINFO]
	label $opts.dynupintervall -text "       [tik_str CONFIG_AWAY_UPDYINTERVAL]"
	entry $opts.dynupinterval -textvariable ::TIK(INFO,dynupdateinterval) -width 3
	
	grid $opts.awaydelayl -column 0 -row 0 -sticky w
	grid $opts.awaydelay -column 0 -row 0 -sticky w
	grid $opts.idle -column 0 -row 1 -sticky w
	grid $opts.idledelayl -column 0 -row 2 -sticky w
	grid $opts.idledelay -column 0 -row 2 -sticky w
	grid $opts.usegetaway -column 0 -row 3 -sticky w
	grid $opts.notifygetaway -column 0 -row 4 -sticky w
	grid $opts.dynamicinfo -column 0 -row 5 -sticky w
	grid $opts.dynupintervall -column 0 -row 6 -sticky w
	grid $opts.dynupinterval -column 0 -row 6 -sticky w
	
	pack $opts -side right
	
	set bottom [frame $awaypage.bottom -border 1 -relief groove]
	set dyna [frame $bottom.dynacodes]
	set dh [frame $dyna.heading]
	set db [frame $dyna.body]
	label $dh.heading -text [tik_str CONFIG_AWAY_CODEHEADING]
	label $db.n -text "%n"
	label $db.nl -text [tik_str CONFIG_AWAY_NCODE]
	label $db.cn -text "%N"
	label $db.cnl -text [tik_str CONFIG_AWAY_CNCODE]
	label $db.i -text "%i"
	label $db.il -text [tik_str CONFIG_AWAY_ICODE]
	label $db.ci -text "%I"
	label $db.cil -text [tik_str CONFIG_AWAY_CICODE]
	label $db.e -text "%e"
	label $db.el -text [tik_str CONFIG_AWAY_ECODE]
	label $db.j -text "%j"
	label $db.jl -text [tik_str CONFIG_AWAY_JCODE]
	label $db.cj -text "%J"
	label $db.cjl -text [tik_str CONFIG_AWAY_CJCODE]
	label $db.t -text "%t"
	label $db.tl -text [tik_str CONFIG_AWAY_TCODE]
	label $db.ct -text "%T"
	label $db.ctl -text [tik_str CONFIG_AWAY_CTCODE]
	label $db.f -text "%F"
	label $db.fl -text [tik_str CONFIG_AWAY_FCODE]
	entry $db.fe -textvariable ::TIK(options,Away,Fcommand)
	label $db.p -text "%%"
	label $db.pl -text [tik_str CONFIG_AWAY_PCODE]
	
	pack $bottom $dyna $dh $dh.heading $db
	grid $db.n -column 0 -row 0 -sticky w
	grid $db.nl -column 1 -row 0 -sticky w
	grid $db.cn -column 0 -row 1 -sticky w
	grid $db.cnl -column 1 -row 1 -sticky w
	grid $db.i -column 0 -row 2 -sticky w
	grid $db.il -column 1 -row 2 -sticky w
	grid $db.ci -column 0 -row 3 -sticky w
	grid $db.cil -column 1 -row 3 -sticky w
	grid $db.e -column 0 -row 4 -sticky w
	grid $db.el -column 1 -row 4 -sticky w
	grid $db.j -column 0 -row 5 -sticky w
	grid $db.jl -column 1 -row 5 -sticky w
	grid $db.cj -column 2 -row 0 -sticky w
	grid $db.cjl -column 3 -row 0 -sticky w
	grid $db.t -column 2 -row 1 -sticky w
	grid $db.tl -column 3 -row 1 -sticky w
	grid $db.ct -column 2 -row 2 -sticky w
	grid $db.ctl -column 3 -row 2 -sticky w
	grid $db.f -column 2 -row 3 -sticky w
	grid $db.fl -column 3 -row 3 -sticky w
	grid $db.fe -column 3 -row 4 -sticky w
	grid $db.p -column 2 -row 5 -sticky w
	grid $db.pl -column 3 -row 5 -sticky w
	
	set packages [Notebook:frame $w.n Packages]
	
    button $w.ok -text [tik_str CONFIG_BOTTOM_OK] -command "writefiles; destroy $w; reloadfiles"
    button $w.cancel -text [tik_str CONFIG_BOTTOM_CANCEL] -command "destroy $w"
    button $w.apply -text [tik_str CONFIG_BOTTOM_APPLY] -command "writefiles; reloadfiles"
    pack $w.apply $w.cancel $w.ok -side right
    if {$delay} {
	tkwait window $w
    }
}






