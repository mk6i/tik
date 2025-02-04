#! /bin/sh
# The next line is executed by /bin/sh, but not Tcl \
exec wish $0 ${1+"$@"}

# tik.tcl --
# A Tcl/Tk version of the Java TIC Applet.  This file contains all
# the ui and code that uses the toc.tcl file.
#
# Bugs: bug tracking section on home page
# Home Page: http://tik.sourceforge.net
#
# $Revision: 1.186 $

# Copyright (c) 1998-9 America Online, Inc. All Rights Reserved.
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

#  Please see CHANGES for information on this release.
#  You can always get the latest TiK at http://tik.sourceforge.net


# Set up the available tocs and auths.
set TOCS [list production firewall]
set AUTHS [list production firewall]
set TOC(production,host) toc.oscar.aol.com
set TOC(production,port) 9898 ;# Any port will work
set TOC(firewall,host) toc.oscar.aol.com
set TOC(firewall,port) 20 ;# Any port will work
set AUTH(production,host) login.oscar.aol.com
set AUTH(production,port) 1234 ;# Any port will work
set AUTH(firewall,host) login.oscar.aol.com
set AUTH(firewall,port) 21 ;# Any port will work

set REVISION {TIK:$Revision: 1.186 $}

# Make sure we are in the TiK directory and load the toc routines.
#if {![string match "Windows*" $::tcl_platform(os)]} {
#    cd [file dirname $argv0]
#    catch {cd [file dirname [file readlink $argv0]]}
#}
# USGuruDad fix for bug #103808 poorly implemented by alellis
set ::TIK(SCRIPT,tik.tcl) [::info script]

# check for symlinks
switch -exact [file type $::TIK(SCRIPT,tik.tcl)] {
    link {
        set ::TIK(SCRIPT,tik.tcl) [file join [file dirname $::TIK(SCRIPT,tik.tcl)] \
                                  [file readlink $::TIK(SCRIPT,tik.tcl)]]
    }
    file {
    }
    default {
        puts "How?"
        exit
    }
}
    
switch -exact [file pathtype $::TIK(SCRIPT,tik.tcl)] {
    absolute {
        set ::TIK(BASEDIR) [::file dirname $::TIK(SCRIPT,tik.tcl)]
    }
    relative {
        set ::TIK(BASEDIR) [::file dirname [file join [pwd] $::TIK(SCRIPT,tik.tcl)]]
    }
    volumerelative {
        set curdir [pwd]
        cd [::file dirname $::TIK(SCRIPT,tik.tcl)]
        set ::TIK(BASEDIR) [pwd]
        cd $curdir
        unset curdir
    }
}

source [file join $::TIK(BASEDIR) toc.tcl]

proc tik_load_components {} {
    source [file join $::TIK(BASEDIR) configdir.tcl]
    source [file join $::TIK(BASEDIR) version.tcl]
    source [file join $::TIK(BASEDIR) sag.tcl]
    source [file join $::TIK(BASEDIR) protocol.tcl]
    source [file join $::TIK(BASEDIR) callbacks.tcl]
    source [file join $::TIK(BASEDIR) ui.tcl]
    source [file join $::TIK(BASEDIR) popup.tcl]
    source [file join $::TIK(BASEDIR) buddylist.tcl]
    source [file join $::TIK(BASEDIR) im.tcl]
    source [file join $::TIK(BASEDIR) chat.tcl]
    source [file join $::TIK(BASEDIR) buddymgmt.tcl]
    source [file join $::TIK(BASEDIR) info.tcl]
    source [file join $::TIK(BASEDIR) prefs.tcl]
    source [file join $::TIK(BASEDIR) proxy.tcl]
    source [file join $::TIK(BASEDIR) configandpkg.tcl]
    source [file join $::TIK(BASEDIR) balloonhelp.tcl]
}

tik_load_components

# Set our name for app default stuff
tk appname tik

# Remove the ability to send/receive X events.  If for some reason
# you want this call "tk appname tik" in your ~/tik/.tikrc
catch {rename send {}}

# Destroy all our children
eval destroy [winfo child .]
wm withdraw .

# Set the http user agent
catch {
    package require http 2.0
    http::config -useragent $::VERSION
}
catch {
    package require netscape_remote
    info-netscape list
    package require ns
    ::ns::winlist
}

#######################################################
# tik_create_buddy - 
#######################################################

proc tik_import_config {} {
    set fn [tk_getOpenFile -title [tik_str MISC_ICFG_TITLE]\
        -initialfile "$::NSCREENNAME.config"]

    if {$fn == ""} {
        return
    }

    set f [open $fn r]
    set data [read $f]
    close $f

    set len [llength $data]
    if {($len >= 2) && ([lindex $data 0] == "Version") && 
                       ([lindex $data 1] == "2")} {
        # This is a Java Config

        set config $data
        set data "m 1\n"
        puts "Trying to import a Java Config, this doesn't import Permit/Deny."
        for {set i 2} {$i < $len} {incr i} {
            if {[lindex $config $i] != "Buddy"} {
                continue;
            }

            # Found the Buddy Section
            incr i
            set config [lindex $config $i]
            set len [llength $config]
            for {set i 0} {$i < $len} {incr i} {
                if {[lindex $config $i] != "List"} {
                    continue;
                }

                # Found the Buddy List Section
                incr i
                set config [lindex $config $i]
                set len [llength $config]

                for {set i 0} {$i < $len} {incr i} {
                    append data "g [lindex $config $i]\n"
                    incr i
                    set buds [lindex $config $i]
                    set jlast [expr [llength $buds] - 1]
                    for {set j 0} {$j <= $jlast} {incr j} {
                       set bud [lindex $buds $j]
                       if {$j == $jlast} {
                           append data "b [normalize $bud]\n"
                       } else {
                           set budtmp [lindex $buds [expr {$j + 1}]]
                           if {[string first "\n" $budtmp] == -1} {
                               append data "b [normalize $bud]\n"
                           } else {
                               incr j
                           }
                       }
                    }
                }

                break;
            }
            break;
        }
    } elseif {($len >= 2) && ([lindex $data 0] == "Config") && 
                       ([string trim [lindex $data 1]] == "version 1")} {
        # This is a WIN 95 Config

        set config $data
        set data "m 1\n"
        puts "Trying to import a WIN95 Config, this doesn't import Permit/Deny."
        for {set i 2} {$i < $len} {incr i} {
            if {[string trim [lindex $config $i]] != "Buddy"} {
                continue;
            }

            # Found the Buddy Section
            incr i
            set config [lindex $config $i]
            set len [llength $config]
            for {set i 0} {$i < $len} {incr i} {
                if {[string trim [lindex $config $i]] != "list"} {
                    continue;
                }

                # Found the Buddy List Section
                incr i
                set config [lindex $config $i]
                set lines [split $config "\n\r"]
                foreach line $lines {
                    set line [string trim $line]
                    set len [llength $line]
                    if {$len == 0} continue
                    append data "g [lindex $line 0]\n"
                    for {set i 1} {$i < $len} {incr i} {
                        append data "b [lindex $line $i]\n"
                    }
                }
                break;
            }
            break;
        }
    }

    # Figure out current buddies and remove them
    foreach g $::BUDDYLIST {
        if {$::GROUPS($g,type) != "AIM"} {
            continue
        }
        foreach b $::GROUPS($g,people) {
            lappend buds $b
        }
    }
    toc_remove_buddy $::NSCREENNAME $buds

    # Parse the new config
    tik_parse_config $data
    tik_set_config
    tik_send_init 0
    tik_draw_list T
}

proc tik_export_config {} {
    set fn [tk_getSaveFile -title [tik_str MISC_ECFG_TITLE]\
        -initialfile "$::NSCREENNAME.config"]

    if {$fn != ""} {
        set f [open $fn w]
        puts -nonewline $f $::TIK(config)
        close $f
    }
}

# p_tik_buddy_press --
#     Private routine called when a mouse button is clicked on the buddy
#     list
proc p_tik_buddy_press {y X Y} {
    set str [sag::pos_2_mainstring .buddy.list [sag::nearest .buddy.list $y]]
    set f [string index $str 0]
    if {($f == "+") || ($f == "-")} {
        return
    }

    tik_buddy_popup $str $X $Y
}

proc tik_create_menubar {} {

    menu .menubar -type menubar
    bind .menubar <Motion> tik_non_idle_event
    destroy .fileMenu
    menu .fileMenu -tearoff 0
    .menubar add cascade -label [tik_str M_FILE] -menu .fileMenu -underline 0
    .fileMenu add command -label [tik_str M_FILE_AB] -command tik_create_add \
                          -accelerator Control+a
    .fileMenu add command -label [tik_str M_FILE_EB] -command tik_create_edit \
                          -accelerator Control+e
    .fileMenu add command -label [tik_str M_FILE_PD] -command tik_create_pd \
                          -accelerator Control+p
    .fileMenu add separator
    .fileMenu add command -label [tik_str M_FILE_EBL] -command tik_export_config
    .fileMenu add command -label [tik_str M_FILE_IBL] -command tik_import_config
    .fileMenu add separator
    .fileMenu add command -label [tik_str M_FILE_SO] -command tik_signoff
    .fileMenu add command -label [tik_str M_FILE_Q] -command {tik_signoff;exit}

    destroy .confMenu
    menu .confMenu -tearoff 0
    .menubar add cascade -label [tik_str M_CONF] -menu .confMenu -underline 0

    .confMenu add command -label [tik_str M_CONF_CI] -command tik_create_setinfo
    .confMenu add command -label [tik_str M_CONF_PREF] -command prefwindow
    destroy .reloadMenu
    menu .reloadMenu -tearoff 0
    .confMenu add cascade -label [tik_str M_RELOAD] -menu .reloadMenu
    .reloadMenu add command -label [tik_str M_RELOAD_OPT] -command "tik_source_rc"
    .reloadMenu add command -label [tik_str M_RELOAD_PKG] -command "tik_check_pkg"
    .reloadMenu add command -label [tik_str M_RELOAD_COMPONENTS] -command "tik_load_components; tik_source_rc"

    destroy .generalMenu
    menu .generalMenu -tearoff 0
    .confMenu add cascade -label [tik_str M_GEN] -menu .generalMenu
    .generalMenu add command -label [tik_str M_WARN] -state disabled
    .generalMenu add separator
    .generalMenu add checkbutton -label [tik_str M_GEN_SND] -onvalue 0 -offvalue 1 \
	-variable ::SOUNDPLAYING
    .generalMenu add checkbutton -label [tik_str M_GEN_TOOLTIP] -onvalue 1 -offvalue 0 \
	-variable ::Widget::BalloonHelp::BalloonHelp(enabled)
    .generalMenu add checkbutton -label [tik_str M_GEN_AWAYSND] -onvalue 1 -offvalue 0 \
	                        -variable ::TIK(options,silentaway)
    .generalMenu add checkbutton -label [tik_str M_GEN_PC] -onvalue 1 -offvalue 0 \
                                -variable ::TIK(options,persistent)
    .generalMenu add checkbutton -label [tik_str M_GEN_MRC] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,monitorrc)
    .generalMenu add checkbutton -label [tik_str M_GEN_MPKG] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,monitorpkg)
    .generalMenu add checkbutton -label [tik_str M_GEN_IDLE] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,reportidle)

    destroy .msgSendMenu
    menu .msgSendMenu -tearoff 0
    .generalMenu add cascade -label [tik_str M_MSGSND] -menu .msgSendMenu
    .msgSendMenu add radiobutton -label [tik_str M_MSGSND_0] \
         -variable ::TIK(options,msgsend) -value 0
    .msgSendMenu add radiobutton -label [tik_str M_MSGSND_1] \
         -variable ::TIK(options,msgsend) -value 1
    .msgSendMenu add radiobutton -label [tik_str M_MSGSND_2] \
         -variable ::TIK(options,msgsend) -value 2
    .msgSendMenu add radiobutton -label [tik_str M_MSGSND_3] \
         -variable ::TIK(options,msgsend) -value 3

    destroy .localconfigMenu
    menu .localconfigMenu -tearoff 0
    .generalMenu add cascade -label [tik_str M_LCFG] -menu .localconfigMenu
    .localconfigMenu add radiobutton -label [tik_str M_LCFG_0] \
         -variable ::TIK(options,localconfig) -value 0
    .localconfigMenu add radiobutton -label [tik_str M_LCFG_1] \
         -variable ::TIK(options,localconfig) -value 1
    .localconfigMenu add radiobutton -label [tik_str M_LCFG_2] \
         -variable ::TIK(options,localconfig) -value 2
    .localconfigMenu add radiobutton -label [tik_str M_LCFG_3] \
         -variable ::TIK(options,localconfig) -value 3

    destroy .sflapMenu
    menu .sflapMenu -tearoff 0
    .generalMenu add cascade -label [tik_str M_SFLAP] -menu .sflapMenu
    .sflapMenu add radiobutton -label [tik_str M_SFLAP_0] \
         -variable sflap::debug_level -value 0
    .sflapMenu add radiobutton -label [tik_str M_SFLAP_1] \
         -variable sflap::debug_level -value 1
    .sflapMenu add radiobutton -label [tik_str M_SFLAP_2] \
         -variable sflap::debug_level -value 2

    destroy .languageMenu
    menu .languageMenu -tearoff 0 -postcommand "tik_strs_menu .languageMenu"
    .generalMenu add cascade -label [tik_str M_LANG] -menu .languageMenu

    destroy .displayMenu
    menu .displayMenu -tearoff 0
    .confMenu add cascade -label [tik_str M_DPY] -menu .displayMenu
    .displayMenu add command -label [tik_str M_WARN] -state disabled
    .displayMenu add separator
    .displayMenu add checkbutton -label [tik_str M_DPY_CT] -onvalue 1 -offvalue 0 \
                                -variable ::TIK(options,chattime)
    .displayMenu add checkbutton -label [tik_str M_DPY_IT] -onvalue 1 -offvalue 0 \
                                -variable ::TIK(options,imtime)
    .displayMenu add checkbutton -label [tik_str M_DPY_IR] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,raiseim)
    .displayMenu add checkbutton -label [tik_str M_DPY_ID] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,deiconifyim)
    .displayMenu add checkbutton -label [tik_str M_DPY_CR] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,raisechat)
    .displayMenu add checkbutton -label [tik_str M_DPY_CD] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,deiconifychat)
    .displayMenu add checkbutton -label [tik_str M_DPY_IF] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,flashim)
    .displayMenu add checkbutton -label [tik_str M_DPY_OG] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,showofflinegroup) \
                                -command "tik_draw_list"
    .displayMenu add checkbutton -label [tik_str M_DPY_GRP] -onvalue 1 \
                                -offvalue 0 -variable \
                                ::TIK(options,showgrouptotals) \
                                -command "tik_draw_list T"
    .displayMenu add checkbutton -label [tik_str M_DPY_ICON] -onvalue 1 \
                                -offvalue 0 -variable \
                                ::TIK(options,showicons) \
                                -command "tik_draw_list T"
    .displayMenu add checkbutton -label [tik_str M_DPY_BBAR] -onvalue 1 \
    				-offvalue 0 -variable ::TIK(options,buttonbar) \
                                -command "tik_update_buttonbar"
    .displayMenu add checkbutton -label [tik_str M_DPY_IBT] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,iconbuttons)\
				-command "tik_strs_buddy; tik_update_cim_buttons;"
    .displayMenu add checkbutton -label [tik_str M_DPY_FRS] -onvalue 1 \
                                -offvalue 0 -variable ::TIK(options,focusrmstar)
    .displayMenu add checkbutton -label [tik_str M_DPY_SML] -onvalue 1 \
    				-offvalue 0 -variable ::TIK(options,showsmilies) \
				-command "tik_load_emoticons"
	
    destroy .colorMenu
    menu .colorMenu -tearoff 0
    .confMenu add cascade -label [tik_str M_COLOR] -menu .colorMenu
    .colorMenu add command -label [tik_str M_WARN] -state disabled
    .colorMenu add separator
    .colorMenu add checkbutton -label [tik_str M_COLOR_EI] -onvalue 1 \
        -offvalue 0 -variable ::TIK(options,imcolor)
    .colorMenu add command -label [tik_str M_COLOR_CDI] \
        -command "tik_set_default_color defaultimcolor"
    .colorMenu add checkbutton -label [tik_str M_COLOR_EC] -onvalue 1 \
        -offvalue 0 -variable ::TIK(options,chatcolor)
    .colorMenu add command -label [tik_str M_COLOR_CDC] \
        -command "tik_set_default_color defaultchatcolor"
    .colorMenu add checkbutton -label [tik_str M_COLOR_EBGC] -onvalue 1 \
    	-offvalue 0 -variable ::TIK(options,Font,showbgcolor)

    destroy .fontMenu
    menu .fontMenu -tearoff 0
    .confMenu add cascade -label [tik_str M_FONT] -menu .fontMenu
    .fontMenu add command -label [tik_str M_WARN] -state disabled
    .fontMenu add separator
    .fontMenu add command -label [tik_str M_FONT_CHANGE] \
        -command "tik_set_default_font"
    .fontMenu add checkbutton -label [tik_str M_FONT_SHOWFONTS] -onvalue 1 \
        -offvalue 0 -variable ::TIK(options,Font,showfonts)
    .fontMenu add checkbutton -label [tik_str M_FONT_SHOWSIZES] -onvalue 1 \
        -offvalue 0 -variable ::TIK(options,Font,showfontsizes)
    .fontMenu add checkbutton -label [tik_str M_FONT_USERELSIZE] -onvalue 1 \
        -offvalue 0 -variable ::TIK(options,Font,userelsize)

    destroy .toolsMenu
    menu .toolsMenu -tearoff 0
    .menubar add cascade -label [tik_str M_TOOLS] -menu .toolsMenu -underline 0

    destroy .menubar.help
    menu .menubar.help -tearoff 0
    .menubar add cascade -label [tik_str M_HELP] -menu .menubar.help \
        -underline 0
    .menubar.help add command -label [tik_str M_HELP_ABOUT] \
        -command tik_show_version
    .menubar.help add command -label [tik_str M_HELP_TIK] -command \
        "tik_show_url homepage http://tik.sourceforge.net"
    .menubar.help add command -label [tik_str M_HELP_TCL] -command \
        "tik_show_url homepage http://www.scriptics.com"
    
     
}

proc tik_strs_buddy {} {
    wm title .buddy [tik_str BL_TITLE]
    wm iconname .buddy [tik_str BL_ICON]

    ######################################
    # Buddy List Buttons
    ###################################### 

    #
    # Assign tooltips to the buttons
    #
    balloonhelp .buddy.im   [tik_str TOOLTIP_B_IM] 
    balloonhelp .buddy.info [tik_str TOOLTIP_B_INFO]
    balloonhelp .buddy.chat [tik_str TOOLTIP_B_CHAT]

    if {$::TIK(options,iconbuttons)} {
        .buddy.im configure -image bim
        .buddy.info configure -image binfo
        .buddy.chat configure -image bchat
    } else {
       .buddy.im configure -image "" -text [tik_str B_IM]
       .buddy.info configure -image "" -text [tik_str B_INFO]
       .buddy.chat configure -image "" -text [tik_str B_CHAT]
    }

}

proc tik_buddy_enter {x y X Y} {
    set ::TIK(BUDDY,last) ""
    set ::TIK(BUDDY,fast) 0
}

proc tik_buddy_leave {x y X Y} {
    catch {after cancel $::TIK(BUDDY,job)}
    set ::TIK(BUDDY,fast) 0
    tik_buddy_release
}

proc p_tik_buddy_delayed {x y X Y} {
    set ::TIK(BUDDY,fast) 1
    p_tik_buddy_press $y $X $Y
}

proc tik_buddy_motion {x y X Y} {
    set str [sag::pos_2_mainstring .buddy.list [sag::nearest .buddy.list $y]]
    if {$::TIK(BUDDY,last) == $str} {
        return
    } else {
        tik_buddy_release
        catch {after cancel $::TIK(BUDDY,job)}
        set ::TIK(BUDDY,last) $str
        if {$::TIK(BUDDY,fast)} {
            p_tik_buddy_press $y $X $Y
        } else {
            set ::TIK(BUDDY,job) [after 1000 p_tik_buddy_delayed $x $y $X $Y]
        }
    }
}

proc tik_create_buddy {} {
    if {[winfo exists .buddy]} {
        destroy .buddy
    }

    tik_create_menubar

    tik_register_buddy_button_func "AIM" "Send IM" tik_create_iim
    tik_register_buddy_button_func "AIM" "Get Info" toc_get_info

    # Create the Buddy Window
    toplevel .buddy -menu .menubar -class Tik
    if {$::TIK(options,windowgroup)} {wm group .buddy .login}

    bind .buddy <Control-a> tik_create_add
    bind .buddy <Control-e> tik_create_edit
    bind .buddy <Control-p> tik_create_pd
    bind .buddy <Motion> tik_non_idle_event

    wm withdraw .buddy

    set canvas [sag::init .buddy.list 200 300 1 $::SAGFONT #a9a9a9 \
        $::TIK(options,sagborderwidth)]

    label .buddy.myName -textvariable ::NSCREENNAME -font $::BOLDFONT
    if $::TIK(options,nameonblist) {
	pack .buddy.myName
    }

    bind $canvas <Double-Button-1> \
         {tik_lselect .buddy.list tik_double_click tik_handleGroup}
    bind $canvas <ButtonPress-3> {tik_buddy_button3_press %y %X %Y}

    frame .buddy.bottomF
    
    # replace 
    button .buddy.im -command {tik_lselect .buddy.list tik_double_click "-"}

    bind .buddy <Control-i> {tik_lselect .buddy.list tik_double_click "-"}
    button .buddy.info -command {tik_lselect .buddy.list tik_get_info}
    bind .buddy <Control-l> {tik_lselect .buddy.list tik_get_info }
    button .buddy.chat -command {tik_create_invite}
    bind .buddy <Control-c> tik_create_invite
    tik_strs_buddy

    bind $canvas <Enter>  {tik_buddy_enter %x %y %X %Y}
    bind $canvas <Leave>  {tik_buddy_leave %x %y %X %Y}
    bind $canvas <Motion> {tik_buddy_motion %x %y %X %Y}

    if {$::TIK(options,padframe)} {
        pack .buddy.im .buddy.info .buddy.chat -in .buddy.bottomF \
             -side left -padx 2m -pady 2m
    } else {
        pack .buddy.im .buddy.info .buddy.chat -in .buddy.bottomF \
             -side left
    }
        

    pack .buddy.bottomF -side bottom
    if {$::TIK(options,padframe)} {
        pack .buddy.list -fill both -expand 1 -padx 2m -side top
    } else {
        pack .buddy.list -fill both -expand 1 -side top
    }

    wm protocol .buddy WM_DELETE_WINDOW {tik_signoff;exit}
}

#######################################################
# setStatus - Set the status label in the login dialog
#######################################################
proc setStatus {str} {
    .login.status configure -text $str
}

#######################################################
# tik_show_login - Show the login window, we first withdraw
# the buddy window in case it is around.
#######################################################
proc tik_show_login {} {
    if {[winfo exists .buddy]} {
        wm withdraw .buddy
    }

    if {[winfo exists .login]} {
        wm deiconify .login
        raise .login
    }
}

#######################################################
# tik_create_login - 
#######################################################
proc tik_strs_login {} {
    wm title .login [tik_str LOGIN_TITLE]
    wm iconname .login [tik_str LOGIN_ICON]
    .login.prF.more.tocl configure -text [tik_str LOGIN_TOCL]
    .login.prF.more.authl configure -text [tik_str LOGIN_AUTHL]
    .login.prF.more.proxyl configure -text [tik_str LOGIN_PROXYL]
    .login.snL configure -text [tik_str LOGIN_SNL]
    .login.pwL configure -text [tik_str LOGIN_PASSL]
    .login.bF.register configure -text [tik_str LOGIN_REGL] \
        -command "tik_show_url register [tik_str LOGIN_REGURL]"
    balloonhelp .login.bF.register [tik_str TOOLTIP_LOGIN_REGL]

    .login.bF.signon configure -text [tik_str LOGIN_SIGNL]
    balloonhelp .login.bF.signon [tik_str TOOLTIP_LOGIN_SIGNL]

    .login.prF.buttons.config configure -text [tik_str PROXY_CONFIG]
    balloonhelp .login.prF.buttons.config [tik_str TOOLTIP_PROXY_CONFIG]

    .login.prF.buttons.moreb configure -text [tik_str LOGIN_MORE]
    balloonhelp .login.prF.buttons.moreb [tik_str TOOLTIP_LOGIN_MORE]

    bind .login <Control-r> "tik_show_url register [tik_str LOGIN_REGURL]"
}

proc tik_create_login {} {

    if {$::TIK(options,supportnotify) && $::UNSUPPORTED} {
	tk_messageBox -type ok -message "WARNING!\n\n\
		You are using a version of Tcl/Tk\
		older than 8.1! Some extended features\
		of TiK (such as graphical emoticons\
		and the message preprocessor) may\
		be partially or completely disabled\
		and/or function immproperly. This message\
		will go away when you upgrade to Tcl/Tk 8.1.\n\n\
		A new version of Tcl/Tk can be found at\n\
		http://dev.scriptics.com\n\n\
		(To disable this message now, add          \n\
		set ::TIK(options,supportnotify) 0\n\
		to your tikpre file)"
    }

    if {[winfo exists .login]} {
        destroy .login
    }

    toplevel .login -class Tik
    wm command .login [concat $::argv0 $::argv]
    wm group .login .login

    wm withdraw .login

    label .login.logo -image logo
    label .login.status

    frame .login.prF -border 1 -relief solid
    frame .login.prF.more
    frame .login.prF.buttons

    frame .login.prF.more.tocF
    label .login.prF.more.tocl -width 13 
    eval tk_optionMenu .login.prF.more.tocs ::SELECTEDTOC $::TOCS
    .login.prF.more.tocs configure -width 10
    pack .login.prF.more.tocl .login.prF.more.tocs -in .login.prF.more.tocF -side left -expand 1

    frame .login.prF.more.authF
    label .login.prF.more.authl -width 13
    eval tk_optionMenu .login.prF.more.auths ::SELECTEDAUTH $::AUTHS
    .login.prF.more.auths configure -width 10
    pack .login.prF.more.authl .login.prF.more.auths -in .login.prF.more.authF -side left -expand 1

    frame .login.prF.more.proxyf
    label .login.prF.more.proxyl -width 13
    menubutton .login.prF.more.proxies -textvariable ::USEPROXY -indicatoron 1 \
            -menu .login.prF.more.proxies.menu \
            -bd 2 -highlightthickness 2 -anchor c \
            -direction flush
    menu .login.prF.more.proxies.menu -tearoff 0
    tik_register_proxy None "" "tik_noneproxy_config"
    pack .login.prF.more.proxyl .login.prF.more.proxies -in .login.prF.more.proxyf -side left -expand 1
    pack .login.prF.more.tocF .login.prF.more.authF .login.prF.more.proxyf

    frame .login.snF
    entry .login.snE -font $::NORMALFONT -width 16 -relief sunken -textvariable ::SCREENNAME
    label .login.snL -width 13
    pack .login.snL .login.snE -in .login.snF -side left -expand 1

    frame .login.pwF
    label .login.pwL -width 13
    entry .login.pwE -font $::NORMALFONT -width 16 -relief sunken -textvariable ::PASSWORD -show "*"
    pack .login.pwL .login.pwE -in .login.pwF -side left -expand 1

    frame .login.bF
    button .login.bF.register
    button .login.bF.signon -command tik_signon
    pack .login.bF.register .login.bF.signon -side left -expand 1
    pack .login.bF.signon -side left -expand 1

    tik_register_proxy None "" "tik_noneproxy_config"

    proc showMore {} {       
        if {[.login.prF.buttons.moreb cget -relief] == "raised"} {
            .login.prF.buttons.moreb configure -relief sunken -text [tik_str LOGIN_LESS]
	    balloonhelp .login.prF.buttons.moreb [tik_str TOOLTIP_LOGIN_LESS]

	    pack .login.prF.more
     
        } else {
            .login.prF.buttons.moreb configure -relief raised -text [tik_str LOGIN_MORE]
	    balloonhelp .login.prF.buttons.moreb [tik_str TOOLTIP_LOGIN_MORE]

	    pack forget .login.prF.more
        }
    }

    button .login.prF.buttons.moreb -command "showMore" -relief raised
    button .login.prF.buttons.config -command \
        {$::TIK(proxies,$::USEPROXY,configFunc)}
    pack .login.prF.buttons.config -side left -expand 1
    pack .login.prF.buttons.moreb -side left -expand 1

    tik_strs_login

    pack .login.logo .login.status .login.snF .login.pwF .login.bF .login.prF .login.prF.buttons -expand 0 -fill x -ipady 1m


 
    bind .login.snE <Return> { focus .login.pwE }
    bind .login.pwE <Return> { tik_signon }
    bind .login <Control-s> { tik_signon }
    bind .login <Control-r> "tik_show_url register [tik_str LOGIN_REGURL]"
    focus .login.snE

    wm protocol .login WM_DELETE_WINDOW {tik_signoff;exit}
}

##########################################################
# Routine to register for single click middle button stuff
##########################################################
proc tik_register_buddy_button_func {btype name cb} {
    set ::TIK(BBUT,$btype,$name,callback) $cb
    set b3popup .bbuttonpopup$btype
    if {![winfo exists $b3popup]} {
        menu $b3popup -tearoff 0
    }
    .bbuttonpopup$btype add command -label $name -command \
        "tik_register_buddy_button_cb {$btype} {$name}"
}

proc tik_unregister_buddy_button_func {btype name} {
    .bbuttonpopup$btype delete $name
    set ::TIK(BBUT,$btype,$name,callback) ""
}

proc tik_register_buddy_button_cb {btype name} {
    if {$::TIK(BBUT,pname) != ""} {
        $::TIK(BBUT,$btype,$name,callback) $::NSCREENNAME $::TIK(BBUT,pname)
    }
}


proc tik_popup_buddy_window {y X Y} {
   set ::TIK(BBUT,pname) $y
   set norm [normalize $y]
   if {[winfo exists .bbuttonpopup$::BUDDIES($norm,type)]} {
        tk_popup .bbuttonpopup$::BUDDIES($norm,type) $X $Y
   }
}

proc tik_buddy_button3_press {y X Y} {
    set str [sag::pos_2_mainstring .buddy.list [sag::nearest .buddy.list $y]]
    set f [string index $str 0]
    if {($f == "+") || ($f == "-")} {
        return
    }
    if {$str != ""} {
        tik_popup_buddy_window $str $X $Y
    }
}

#######################################################
# Capability routines

proc tik_add_capability {cap} {
    if {[lsearch -exact $::TIK(CAPS) $cap] != -1} {
        return
    }
    lappend ::TIK(CAPS) $cap
    if {$::TIK(online)} {
        toc_set_caps \"$::SCREENNAME\" $::TIK(CAPS)
    }
}

proc tik_remove_capability {cap} {
    set i [lsearch -exact $::TIK(CAPS) $cap]
    if {$i == -1} {
        return
    }
    set ::TIK(CAPS) [lreplace $::TIK(CAPS) $i $i]
    if {$::TIK(online)} {
        toc_set_caps $::SCREENNAME $::TIK(CAPS)
    }
}

#######################################################
# String Routines
#######################################################
proc tik_set_str {name value} {
    set ::TIK(STRINGS,$name) $value
}

proc tik_str {name args} {
    set str $::TIK(STRINGS,$name)
    set omsg ""
    set inp 0
    foreach i [split $str {}] {
        if {$inp} {
            switch -exact -- $i {
            "n" {append omsg $::SCREENNAME}
            "N" {append omsg $::NSCREENNAME}
            "i" {append omsg [expr [clock seconds] - $::TIK(IDLE,last_event)]}
            "I" {append omsg [expr ([clock seconds] - $::TIK(IDLE,last_event))/60]}
            "e" {append omsg $::TIK(EVIL,level)}
            "0" -
            "1" -
            "2" -
            "3" -
            "4" {append omsg [lindex $args $i]}
            "%" {append omsg "%"}
            }
            set inp 0
        } elseif {$i == "%"} {
            set inp 1
        } else {
            append omsg $i
        }
    }
    return $omsg
}

proc tik_strs_menu {menu} {
    $menu delete 0 end
    set labels ""
    foreach files [glob -nocomplain "[file join $::TIK(BASEDIR) strs *.strs]"] {
        lappend labels [file rootname [file tail $files]]
    }
    foreach files [glob -nocomplain "[file join $::TIK(configDir) strs *.strs]"] {
        if { [lsearch $labels [set files [file rootname \
              [file tail $files]]]] == "-1" } {
            lappend labels $files
        }
    }
    foreach file [lsort -dictionary $labels] {
        $menu add radiobutton -variable ::TIK(options,language) \
            -value $file -label $file -command tik_load_strs
    }
}    

proc tik_load_strs {{initial 0}} {
    if {!$initial} {
        destroy .menubar
        foreach package [lsort -ascii [array names ::TIK pkg,*,pkgname]] {
            set pkgname $::TIK($package)
            catch {${pkgname}::unload}
        }
    }

    tik_source strs $::TIK(options,dlanguage).strs
    if {($::TIK(options,language) != $::TIK(options,dlanguage)) } {
        tik_source strs $::TIK(options,language).strs
    }

    if {[file exists $::TIK(strsfile)]} {
        source $::TIK(strsfile)
    }

    if {!$initial} {
        tik_create_menubar
        .buddy configure -menu .menubar
        tik_strs_buddy
        tik_strs_login
        foreach package [lsort -ascii [array names ::TIK pkg,*,pkgname]] {
            set pkgname $::TIK($package)
            catch {
                ${pkgname}::load
                ${pkgname}::goOnline
            }
        }
    }
}

#
# New wrapper code for directory compatibility between Global and Per-User
# relative file access.

# tik_where_nonOverride
#   Checks for a file relative to the main TiK directory first.  
#   If found, returns that location for the file.  Otherwise, 
#   checks for the file relative to the configDir (~/.tik).  If
#   found, returns that location.  If neither pans out, the 
#   procedure returns as such.  TiK doesn't make use of this one
#   as much as the next so that users can customize their experience
#   more without affecting the basic, official installation of TiK.

proc tik_where_nonOverride { type file } {
    switch -exact $type {
        main {
            set path ""
        }
        strs {
            set path "strs"
        }
        packages {
            set path "packages"
        }
        media {
            set path "media"
        }
    }
    if { [file exists [file join $::TIK(BASEDIR) $path $file]] } {
        return [file join $::TIK(BASEDIR) $path $file]
    } elseif { [file exists [file join $::TIK(configDir) $path $file]] } {
        return [file join $::TIK(configDir) $path $file]
    } else {
        return "none"
    }
}

# tik_where_Override
#   Just like tik_where_nonOverride, except this checks relative to
#   the configDir (~/.tik) first.

proc tik_where_Override { type file } {
    switch -exact $type {
        main {
            set path ""
        }
        strs {
            set path "strs"
        }
        packages {
            set path "packages"
        }
        media {
            set path "media"
        }
    }
    if { [file exists [file join $::TIK(configDir) $path $file]] } {
        return [file join $::TIK(configDir) $path $file]
    } elseif { [file exists [file join $::TIK(BASEDIR) $path $file]] } {
        return [file join $::TIK(BASEDIR) $path $file]
    } else {
        return "none"
    }
}
# tik_image_load 
#   Wrapper for image loading that takes a list as an argument and
#   cycles through the list doing that good image stuff that it 
#   should

proc tik_image_load { image_list } {
    foreach image_set $image_list {
        set image_file [tik_where_Override media [lindex $image_set 1]]
        if { $image_file != "none"} {
            image create photo [lindex $image_set 0] -file $image_file
        }
    }
}

proc tik_parse_emoticons {} {
    set t 1
    set ::TIK(spatlist) [list]
    set ::TIK(siconlist) [list]
    foreach e $::TIK(smilielist) {
        if {$t} {
	    lappend ::TIK(spatlist) "(^|\\s)($e)($|\\s)"
        } else {
	    lappend ::TIK(siconlist) $e
        }
        set t [expr !$t]
    }
}

proc tik_load_emoticons {} {
    tik_parse_emoticons
    set ::TIK(simagelist) [list]
    foreach image $::TIK(siconlist) {
        lappend ::TIK(simagelist) [list $image $image]
    }
    tik_image_load $::TIK(simagelist)
}

proc tik_update_fonts {} {
    set ::TIK(options,Font,basefont) "-family $::TIK(options,Font,baseface) -size $::TIK(options,Font,basesize) -underline 0 -overstrike 0"
    set ::NORMALFONT [eval font create $::TIK(options,Font,basefont) -weight normal ]
    set ::BOLDFONT [eval font create $::TIK(options,Font,basefont) -weight bold ]
}

proc tik_set_default_font {} {
    set w .fontconfig

    if {[winfo exists $w]} {
        raise $w
	return
    }

    set tempFace $::TIK(options,Font,baseface)
    set tempSize $::TIK(options,Font,basesize)

    toplevel $w -class Tik
    wm title $w [tik_str FONT_TITLE]
    wm iconname $w [tik_str FONT_ICON]
    if {$::TIK(options,windowgroup)} {wm group $w .login}
    label $w.label -text [tik_str FONT_WARN]

    frame $w.faceF
    label $w.faceF.l -text [tik_str FONT_FACE] -width 15
    entry $w.faceF.e -textvariable ::TIK(options,Font,baseface)
    pack $w.faceF.l $w.faceF.e -side left

    frame $w.sizeF
    label $w.sizeF.l -text [tik_str FONT_SIZE] -width 15
    entry $w.sizeF.e -textvariable ::TIK(options,Font,basesize)
    pack $w.sizeF.l $w.sizeF.e -side left

    frame $w.buttons
    button $w.ok -text [tik_str B_OK] -command "tik_update_fonts; destroy $w"
    button $w.cancel -text [tik_str B_CANCEL] -command "set ::TIK(options,Font,baseface) {$tempFace}; set ::TIK(options,Font,basesize) $tempSize; destroy $w"
    pack $w.ok $w.cancel -in $w.buttons -side left -padx 2m

    pack $w.buttons -side bottom
    pack $w.label $w.faceF $w.sizeF -side top
}

# tik_source
#   If you need to source a file that could be relative to either the main directory 
#   or the config directory, use this procedure.  Also, by using this procedure you 
#   allow files relative to the config directory override and enhance files found 
#   in the main directory.  If you only want to source a SPECIFIC file, then use 
#   the normal source command.  

proc tik_source { type file } {
    switch -exact $type {
        main {
            set path ""
        }
        strs {
            set path "strs"
        }
        packages {
            set path "packages"
        }
    }
    if { [file exists [file join $::TIK(BASEDIR) $path $file]] } {
        source [file join $::TIK(BASEDIR) $path $file]
    }
    if { [file exists [file join $::TIK(configDir) $path $file]] } {
        source [file join $::TIK(configDir) $path $file]
    }
}
#######################################################
# MAIN
#######################################################

set ::UNSUPPORTED 0
if {$::tcl_version < 8.1} {
    set ::UNSUPPORTED 1
}

proc update_unsup {} {
    if {$::UNSUPPORTED} {
        set ::TIK(options,showsmilies) 0
    }
}

if {$::tcl_platform(platform) == "unix" && $::tk_version<8.3} {
    bind Text <4> {
        %W yview scroll -5 units
    }
    bind Text <5> {
        %W yview scroll 5 units
    }
    bind Listbox <4> {
        %W yview scroll -5 units
    }
    bind Listbox <5> {
        %W yview scroll 5 units
    }
}                    
# Globals
set ::TIK(INFO,sendinfo) 0
set ::TIK(INFO,msg) ""
set ::TIK(INFO,updatedynamicinfo) 0
set ::TIK(INFO,dynupdateinterval) 5
set ::TIK(IDLE,sent) 0
set ::TIK(IDLE,timer) 0
set ::TIK(EVIL,level) 0
set ::TIK(IDLE,last_event) [clock seconds]
set ::TIK(IDLE,XY) [winfo pointerxy .]
set ::TIK(rcfile,mtime) 0
set ::TIK(aliasfile,mtime) 0
set ::TIK(online) 0
set ::TIK(CAPS) ""
## please globally define all images here to avoid redefinitions
set image_list [list "bim im.gif" "binfo info.gif" "bchat chat.gif" \
                     "Login Login.gif" "Logout Logout.gif" "AOL AOL.gif" \
                     "logo Logo.gif" "Admin Admin.gif" "Idle Idle.gif" \
                     "uparrow uparrow.gif" "downarrow downarrow.gif" \
                     "Away Away.gif" "DT DT.gif" "Oscar Oscar.gif" \
                     "bclose close.gif" "bwarn warn.gif" "bblock block.gif" \
                     "bsend send.gif" "badd add.gif" "bitalic italic.gif" \
                     "bunderline underline.gif" "bfont font.gif" \
                     "bcolor color.gif" "bbold bold.gif" "bsmile bsmile.gif" \
		     "bstrike strike.gif" "binvite invite.gif" \
		     "bignore ignore.gif" "bwhisper whisper.gif" \
		     "bback back.gif" "bok ok.gif" "bdelete delete.gif" ]
tik_image_load $image_list

# When there's more than one copy of a package, which has precedence, 
# the user settings or global?  Set to "1" in tikrc to choose
# user packages over global.
set ::TIK(packages,user_preferred) 0

set ::USEPROXY None

# Default OPTIONS
set ::TIK(options,silentaway) 0    ;# Disable silent away mode
set ::TIK(options,supportnotify) 1 ;# Popup Tcl/Tk < 8.1 warning upon loading TiK?
set ::TIK(options,imtime)     1    ;# Display timestamps in IMs?
set ::TIK(options,chattime)   1    ;# Display timestamps in Chats?

# Heights:  
#   ==  0 :One Line Entry.  Resizing keeps it 1 line
#   >=  1 :Text Entry, Multiline.  Resizing may increase number of lines
#   <= -1 :Text Entry, Multiline.  Same as >=1 but with scroll bar.
set ::TIK(options,iimheight)  4    ;# Initial IM Entry Height
set ::TIK(options,cimheight)  0    ;# Converation IM Entry Height
set ::TIK(options,chatheight) 0    ;# Chat Entry Height

set ::TIK(options,cimexpand)   0   ;# If cimheight is not 0, then this
                                   ;# determins if the entry area expands
                                   ;# on resize.

set ::TIK(options,imcolor)          1           ;# Process IM colors?
set ::TIK(options,defaultimcolor)   "#000000"   ;# Default IM color
set ::TIK(options,chatcolor)        1           ;# Process Chat colors?
set ::TIK(options,defaultchatcolor) "#000000"   ;# Default Chat color

set ::TIK(options,flashim)          1           ;# Flash IM sb when new msg
set ::TIK(options,flashimtime)      500         ;# ms between flashes
set ::TIK(options,flashimcolor)     blue        ;# Flash color is

set ::TIK(options,windowgroup)   0     ;# Group all TiK windows together? 
set ::TIK(options,raiseim)       0     ;# Raise IM window on new message
set ::TIK(options,deiconifyim)   0     ;# Deiconify IM window on new message
set ::TIK(options,raisechat)     0     ;# Raise Chat window on new message
set ::TIK(options,deiconifychat) 0     ;# Deiconify Chat window on new message
set ::TIK(options,monitorrc)     1     ;# Monitor rc file for changes?
set ::TIK(options,monitorrctime) 20000 ;# Check for rc file changes how often (millisecs)
set ::TIK(options,monitorpkg)     1     ;# Monitor pkgs for changes?
set ::TIK(options,monitorpkgtime) 20000 ;# Check the pkg dir for changes how often (millisecs)
set ::TIK(options,checkversion) 1       ;# Check for a new version of TiK
set ::TIK(options,versionchecktime) 3600000 ;# Check for new version how often (millisecs)
set ::TIK(options,versiontimeout) 10    ;# Timeout for version check (seconds)
set ::TIK(options,usealias) 1           ;# Use aliases instead of screen names when possible
set ::TIK(options,aliastime) 20000      ;# Check for alias file changes how often (millisecs)

set ::TIK(options,nameonblist) 0        ;# Show name on top of buddy list
set ::TIK(options,showofflinegroup) 1   ;# Show the Offline group
set ::TIK(options,showgrouptotals) 1    ;# Show the group totals
set ::TIK(options,showidletime)    1    ;# Show the idle time of buddies
set ::TIK(options,showevil)        1	;# Show the evil level of buddies
set ::TIK(options,showicons)       1    ;# Show the icons
set ::TIK(options,padframe)        1    ;# Pad Buddy Window?
set ::TIK(options,sagborderwidth)  2    ;# Border width for sag windows.
set ::TIK(options,removedelay)    10000 ;# Buddy removal delay when departing.

set ::TIK(options,iconbuttons)     1    ;# Use icon instead of text buttons
set ::TIK(options,buttonbar)       1    ;# Show button bar by default

set ::TIK(options,focusrmstar)     0    ;# Remove star from IM window on focus
set ::TIK(options,showsmilies)     1    ;# Show graphical emoticons
set ::TIK(smilielist) [list {[0oO][=:]-?\)} angel.gif {[=:]-?D} bigsmile.gif {[=:]-?!} burp.gif {[=:]-?[xX]} crossedlips.gif {[=:]'-?\(} cry.gif {[=:]-?[\]\[]} embarrassed.gif {[=:]-?\*} kiss.gif {[=:]-?\$} moneymouth.gif {[=:]-?\(} sad.gif {[:=]-?[oO]} scream.gif {[=:]-?\)} smile.gif {8-?\)} smile8.gif {[=:](-?\\|-\/)} think.gif {[=:]-?[pPb]} tongue.gif {\;-?\)} wink.gif {>[=:][0oO]} yell.gif]

# 0 - Enter/Ctl-Enter insert NewLine,  Send Button Sends
# 1 - Ctl-Enter inserts NewLine,  Send Button/Enter Sends
# 2 - Enter inserts NewLine,  Send Button/Ctl-Enter Sends
# 3 - No Newlines,  Send Button/Ctl-Enter/Enter Sends
set ::TIK(options,msgsend) 1

# 0 - Use the config from the host
# 1 - Use the config from ~/.tik/NSCREENNAME.config
# 2 - Use the config from ~/.tik/NSCREENNAME.config & keep this config
#     on the host.  (Remember the host has a 2k config limit!)
# 3 - Use the config from the host, but backup locally, if host config
#     is empty then use local config.
set ::TIK(options,localconfig) 3

# 0 - Don't report idle time
# 1 - Report idle time
set ::TIK(options,reportidle) 1
set ::TIK(options,idlewatchmouse) 1    ;# Watch the global mouse pointer
set ::TIK(options,reportidleafter) 900 ;# Report idle after this long (secs)
set ::TIK(options,idleupdateinterval) 1 ;# Interval for idle updating (mins), 0 to disable.

# Buddy Colors
set ::TIK(options,buddymcolor) black
set ::TIK(options,buddyocolor) blue
set ::TIK(options,groupmcolor) black
set ::TIK(options,groupocolor) red
# Ignore button patch add start
set ::TIK(options,ignorecolor) red     ;# Ignore color
# Ignore button patch add end
### FUZZFACE00/SCREENCOLORS - IM ScreenName colors
set ::TIK(options,mysncolor) blue
set ::TIK(options,othersncolor) red
### FUZZFACE00/SCREENCOLORS -  END MODS 

# Sound Names
set ::TIK(SOUND,ChatSend)     Send.au
set ::TIK(SOUND,ChatReceive)  Receive.au
set ::TIK(SOUND,Send)         Send.au
set ::TIK(SOUND,Initial)      Receive.au
set ::TIK(SOUND,Receive)      Receive.au
set ::TIK(SOUND,Arrive)       BuddyArrive.au
set ::TIK(SOUND,Depart)       BuddyLeave.au
# yes,  0 enables sound, 1 disables it. . . don't ask why
set ::SOUNDPLAYING 0

# Window Manager Classes
set ::TIK(options,imWMClass) Tik
set ::TIK(options,chatWMClass) Tik

set ::TIK(options,persistent) 0 ;# Reconnect when accidentally disconnected

set ::TIK(options,dlanguage) English ;# Default strs file to use
set ::TIK(options,language)  English ;# Override defaults fromstrs file to use

# Register the callbacks, we are cheesy and use the
# same function names as the message names.
toc_register_func * SIGN_ON           SIGN_ON
toc_register_func * CONFIG            CONFIG
toc_register_func * NICK              NICK
toc_register_func * IM_IN             IM_IN
toc_register_func * toc_send_im       IM_OUT
toc_register_func * UPDATE_BUDDY      UPDATE_BUDDY
toc_register_func * ERROR             ERROR
toc_register_func * EVILED            EVILED
toc_register_func * CHAT_JOIN         CHAT_JOIN
toc_register_func * CHAT_IN           CHAT_IN
toc_register_func * CHAT_UPDATE_BUDDY CHAT_UPDATE_BUDDY
toc_register_func * CHAT_INVITE       CHAT_INVITE
toc_register_func * CHAT_LEFT         CHAT_LEFT
toc_register_func * GOTO_URL          GOTO_URL
toc_register_func * PAUSE             PAUSE
toc_register_func * CONNECTION_CLOSED CONNECTION_CLOSED
toc_register_func * ADMIN_NICK_STATUS ADMIN_NICK_STATUS
toc_register_func * ADMIN_PASSWD_STATUS ADMIN_PASSWD_STATUS

# Set up the fonts that we use for all "entry" and "text" widgets.
set ::TIK(options,Font,basesize) 12
set ::TIK(options,Font,userelsize) 0
set ::TIK(options,Font,baseface) "helvetica"
set ::TIK(options,Font,basefont) "-family $::TIK(options,Font,baseface) -size $::TIK(options,Font,basesize) -underline 0 -overstrike 0" 
set ::TIK(options,Font,showbgcolor) 0
set ::TIK(options,Font,showfonts) 1
set ::TIK(options,Font,showfontsizes) 1
set ::TIK(options,showhdrftr) 0
set ::TIK(options,Font,defheader) ""
set ::TIK(options,Font,deffooter) ""
set ::SAGFONT [eval font create $::TIK(options,Font,basefont) -family helvetica -size -12 -weight normal ]
set ::NORMALFONT [eval font create $::TIK(options,Font,basefont) -weight normal ]
set ::BOLDFONT [eval font create $::TIK(options,Font,basefont) -weight bold ]

set ::TIK(INFO,msg) {This is my <B>Cool</B> instant messaging client, TiK!  Get it at <a href=\"http://tik.sourceforge.net\">http://tik.sourceforge.net</a>}

#########################
# apperance settings
#########################
set ::USEBALLOONHELP 1

set ::TIK(options,buttonrelief) groove
set ::TIK(options,menurelief) groove
set ::TIK(options,textbackground) white
set ::TIK(options,textforeground) black
set ::TIK(options,entrybackground) white
set ::TIK(options,entryforeground) black
set ::TIK(options,scrollbarwidth) 12
set ::TIK(options,menubuttonrelief) groove
set ::TIK(options,buddylistbground) white

proc setAppearances {} {
    if {[info exists ::TIK(options,defaultbackground)] && [string length $::TIK(options,defaultbackground)]} {option add *background $::TIK(options,defaultbackground)}
    if {[info exists ::TIK(options,scrollbarbackground)] && [string length $::TIK(options,scrollbarbackground)]} {option add *Scrollbar.background $::TIK(options,scrollbarbackground)}
    if {[info exists ::TIK(options,buttonbackground)] && [string length $::TIK(options,buttonbackground)]} {option add *Button.background $::TIK(options,buttonbackground)}
    if {[info exists ::TIK(options,buttonfont)] && [string length $::TIK(options,buttonfont)]} {option add *Button.font $::TIK(options,buttonfont)}
    if {[info exists ::TIK(options,buttonrelief)] && [string length $::TIK(options,buttonrelief)]} {option add *Button.relief $::TIK(options,buttonrelief)}
    if {[info exists ::TIK(options,menurelief)] && [string length $::TIK(options,menurelief)]} {option add *Menu.relief $::TIK(options,menurelief)}
    if {[info exists ::TIK(options,textbackground)] && [string length $::TIK(options,textbackground)]} {option add *Text.background $::TIK(options,textbackground)}
    if {[info exists ::TIK(options,textforeground)] && [string length $::TIK(options,textforeground)]} {option add *Text.foreground $::TIK(options,textforeground)}
    if {[info exists ::TIK(options,entrybackground)] && [string length $::TIK(options,entrybackground)]} {option add *Entry.background $::TIK(options,entrybackground)}
    if {[info exists ::TIK(options,entryforeground)] && [string length $::TIK(options,entryforeground)]} {option add *Entry.foreground $::TIK(options,entryforeground)}
    if {[info exists ::TIK(options,scrollbarwidth)] && [string length $::TIK(options,scrollbarwidth)]} {option add *Scrollbar.width $::TIK(options,scrollbarwidth)}
    if {[info exists ::TIK(options,menubuttonrelief)] && [string length $::TIK(options,menubuttonrelief)]} {option add *Menubutton.relief $::TIK(options,menubuttonrelief)}
    if {[info exists ::TIK(options,activebackground)] && [string length $::TIK(options,activebackground)]} {option add *activeBackground $::TIK(options,activebackground)}
    if {[info exists ::TIK(options,listbackground)] && [string length $::TIK(options,listbackground)]} {option add *list*Background $::TIK(options,listbackground)}
    if {[info exists ::TIK(options,buttonforeground)] && [string length $::TIK(options,buttonforeground)]} {option add *Button.foreground $::TIK(options,buttonbackground)}
    if {[info exists ::TIK(options,tobackground)] && [string length $::TIK(options,tobackground)]} {option add *to*Background $::TIK(options,tobackground)}
    if {[info exists ::TIK(options,buddylistbground)] && [string length $::TIK(options,buddylistbground)]} {option add *list.c*Background $::TIK(options,buddylistbground)}
}

setAppearances

proc argCheck {arg i l} {
    if {$i >= $l} {
        puts "$::argv0: Missing argument for $arg, try -H for usage."
        exit 1;
    }
}

# Parse Options
set largv [llength $argv]
for {set i 0} {$i < $largv} {incr i} {
    set arg [lindex $argv $i]
    switch -glob -- $arg {
    "-H" -
    "-h" -
    "-help" {
        puts "$argv0 Usage:"
        puts " -H              This message"
        puts " -sflap <level>  SFLAP debug level"
        puts " -config <dir>   Use <dir> instead of ~/.tik"
        puts " -user <user>    Use <user>, overrides rc files"
        puts " -pass <pass>    User <pass>, overrides rc files"
        puts " -roast <pass>   Roast a password for use in ~/.tik"
	puts " -eval <command> Run command, like it was part of TiK"
        exit 0
    }
    "-sflap" {
        incr i
        argCheck $arg $i $largv
        set sflap::debug_level [lindex $argv $i]
    }
    "-dir*" -
    "-config*" {
        incr i
        argCheck $arg $i $largv
        set ::TIK(configDir) [lindex $argv $i]
    }
    "-prefile" -
    "-rcfile" {
        puts "The option $arg is no longer supported, instead use -config <dir>"
        exit 0
    }
    "-u" - 
    "-user" {
        incr i
        argCheck $arg $i $largv
        set ::TIK(clUser) [lindex $argv $i]
    }
    "-p" - 
    "-pass" {
        incr i
        argCheck $arg $i $largv
        set ::TIK(clPass) [lindex $argv $i]
    }
    "-roast" {
        incr i
        argCheck $arg $i $largv
        puts -nonewline "\nPlace \"set PASSWORD "
        puts "0x[roast_password [lindex $argv $i]]\" in your $::TIK(configDir)/tikrc file.\n"
        puts -nonewline "WARNING: While not in clear text, people can still "
        puts "decode your password."
        exit 0
    }
    "-eval" {
    	incr i
    	argCheck $arg $i $largv
    	eval [lindex $argv $i]
    }
    default {
        puts "$::argv0: Unknown argument '$arg', try -H for usage."
        exit 1;
    }
    } ;# SWITCH
}

set ::TIK(prefile)   [file join $::TIK(configDir) tikpre]
set ::TIK(rcfile)    [file join $::TIK(configDir) tikrc]
set ::TIK(strsfile)  [file join $::TIK(configDir) tikstrs]
set ::TIK(awayfile)  [file join $::TIK(configDir) awayrc]
set ::TIK(pkgfile)   [file join $::TIK(configDir) pkgrc]
set ::TIK(aliasfile) [file join $::TIK(configDir) alias]
set ::TIK(pkgfile,mtime) 0
set ::TIK(compDir)   components
set ::TIK(pkgDir)    packages
set ::SCREENNAME ""
set ::NSCREENNAME ""

proc tik_write_examples {} {
    foreach {file var} {awayrc awayfile \
                        pkgrc  pkgfile  \
                        tikpre prefile  \
                        tikrc  rcfile   \
                        tikstrs strsfile} {
        # I kept the directory check to avoid a race condition
        # where someone deletes the directory before the loop
        # is finished.
        if {[file exists $::TIK(configDir)] && ![file exists $::TIK($var)]} {
            if {[file exists [file join $::TIK(BASEDIR) "example.$file"]]} {
                puts "Copying example $file file to $::TIK(configDir)"
                file copy [file join $::TIK(BASEDIR) "example.$file"] $::TIK($var)
            } else {
                puts "This distribution of TiK did not come with the example $file file."
                puts "Please visit http://tik.sourceforge.net for the full TiK distribution."
            }
        }
    }
}

proc makeconfigdir {} {
    puts "Creating the directory $::TIK(configDir)"	
    if {[catch {file attributes $::TIK(configDir) -permissions 0700} errMsg]} {
        puts "Warning: Failed to set permissions on $::TIK(configDir): $errMsg"
    }
    puts "Creating the directory [file join $::TIK(configDir) $::TIK(pkgDir)]"
    file mkdir [file join $::TIK(configDir) $::TIK(pkgDir)]
    if {[catch {exec chmod og-rwx [file join $::TIK(configDir) $::TIK(pkgDir)]} errMsg]} {
        puts "Warning: Failed to set permissions on [file join $::TIK(configDir) $::TIK(pkgDir)]: $errMsg"
    }
    tik_write_examples
    # Create the per-user directories if needed
    set ::TIK(userDirs) [list packages media strs]
    foreach directory $::TIK(userDirs) {
        set dirPath [file normalize [file join $::TIK(configDir) $directory]]
        if {![file exists $dirPath]} {
            if {[catch {file mkdir $dirPath} errMsg]} {
                puts "Error: Failed to create directory $dirPath - $errMsg"
            }
        }
    }
    set ::TIK(prefile)   [file join $::TIK(configDir) tikpre]
    set ::TIK(rcfile)    [file join $::TIK(configDir) tikrc]
    set ::TIK(strsfile)  [file join $::TIK(configDir) tikstrs]
    set ::TIK(awayfile)  [file join $::TIK(configDir) awayrc]
    set ::TIK(pkgfile)   [file join $::TIK(configDir) pkgrc]
}


tik_load_strs 1
tik_load_emoticons

if {[file exists ~/.tikrc]} {
    puts -nonewline "This version of TiK now uses $::TIK(rcfile) instead "
    puts "of ~/.tikrc.  You should:"
    puts "   mkdir ~/.tik"
    puts "   mv ~/.tikrc $::TIK(rcfile)"
    puts "   ....etc, for the rest of your rc files" 
} elseif { ! [file exists $::TIK(configDir)] } {
    catch {
        puts "$::VERSION:  Copyright (c) 1998-9 America Online, Inc. All Rights Reserved."
        puts "Please read tik/COPYING and tik/LICENSE"
        puts ""

	set w .installwindow
	toplevel $w
	set top [frame $w.top]
	label $top.logo -image logo
	label $top.heading -text "Thank you for choosing the TiK as your instant messenger."
	label $top.l1 -text "The installer reports that this is your first installation of TiK"
	label $top.l2 -text "on this computer. To start out, you must specify what you want"
	label $top.l3 -text "your configuration directory to be.\n"
	label $top.l4 -text "TiK detected that your os is $::tcl_platform(os)\n"
	label $top.l5 -text "Please select a configuration directory."
	pack $top
	
	grid $top.logo -column 0 -row 0 -sticky n
	grid $top.heading -column 0 -row 1 -sticky n
	grid $top.l1 -column 0 -row 2 -sticky w
	grid $top.l2 -column 0 -row 3 -sticky w
	grid $top.l3 -column 0 -row 4 -sticky w
	grid $top.l4 -column 0 -row 5 -sticky w
	grid $top.l5 -column 0 -row 6 -sticky w

	set ::configdirlocation "default"

	proc writeconfig {} {
	    if [file writable [file join $::TIK(BASEDIR) "configdir.tcl"]] {
		set configfile [open [file join $::TIK(BASEDIR) "configdir.tcl"] w 0600]
		if {$::configdirlocation == "default" && $::tcl_platform(platform) == "unix"} {
		    puts $configfile "set ::TIK(configDir) \[file join \[file nativename ~\] \".tik\"\]"
		} elseif {$::configdirlocation == "default" && $::tcl_platform(platform) == "windows"} {
		    puts $configfile "set ::TIK(configDir) \[file join \$::TIK(BASEDIR) \"config\"\]"
		} else {
		    puts $configfile "set ::TIK(configDir) $::TIK(configDir)"
		}
		close $configfile
	    }
	    source [file join $::TIK(BASEDIR) "configdir.tcl"]
	}
	
    
	if [file writable [file join $::TIK(BASEDIR) "configdir.tcl"]] {
	    
	    proc refreshdirs {rb1 e1 b1} {
		if {$::configdirlocation == "default"} {
		    $rb1 configure -state normal
		    $e1 configure -state disabled -background lightgray
		    $b1 configure -state disabled
		} else {
		    $rb1 configure -state normal
		    $e1 configure -state normal -background white
		    $b1 configure -state normal
		}
	    }   
	    set body [frame $w.body]
	    pack $body
	    radiobutton $body.default -variable ::configdirlocation -value "default"
	    radiobutton $body.user -variable ::configdirlocation -value "user" -text "User defined"
	    entry $body.dir -textvariable ::TIK(configDir)
	    button $body.browse -command "set ::TIK(configDir) \[tk_chooseDirectory\]" -text "Browse"
	    
	    $body.user configure -command "refreshdirs $body.default $body.dir $body.browse"
	    refreshdirs $body.default $body.dir $body.browse
	    
	    grid $body.default -column 0 -row 7 -sticky e
	    grid $body.user -column 0 -row 8 -sticky ns
	    grid $body.dir -column 0 -row 9 -sticky ns
	    grid $body.browse -column 1 -row 9 -sticky ns
	    
	    if {$::tcl_platform(platform) == "unix"} {
		set ::configdirlocation "default"
		$body.default configure -text "Default  ( ~/.tik/ )" -command "set ::TIK(configDir) \[file join \[file nativename ~\] \".tik\"\]; refreshdirs $body.default $body.dir $body.browse"
	    } elseif {$::tcl_platform(platform) == "windows"} {
		bell
		set ::configdirlocation "default"
		bell
		$body.default configure -text "Default  ( tik\\config )" -command "set ::TIK(configDir) \[file join \$::TIK(BASEDIR) \"config\"\]; refreshdirs $body.default $body.dir $body.browse"
		bell
	    } else {
		puts "NOOO!"
		bell
		set ::configdirlocation "user"
		$body.default configure -text "None" -state disabled
	    }
	
	    refreshdirs $body.default $body.dir $body.browse
	} else  {
	    label $top.noperm -text "\n\nSorry, but you lack the permissions to edit the config directory file."
	    grid $top.noperm -column 0 -row 7 -sticky w
	}
    set bottom [frame $w.bottom]
    label $bottom.l1 -text "'Advanced' writes a default set of tikrc and tikpre files."
    label $bottom.l2 -text "'Next' continues on to the gui preferences system."
    button $bottom.advanced -command "writeconfig; makeconfigdir; writepre; writerc; writeaway; destroy $w" -text "Advanced"
    button $bottom.exit -command "exit" -text "Exit"
    button $bottom.next -command "writeconfig; makeconfigdir; prefwindow 1" -text "Next"
    
    grid $bottom.l1 -column 1 -row 0 -sticky n
    grid $bottom.l2 -column 1 -row 1 -sticky n
    grid $bottom.advanced -column 0 -row 2 -sticky w
    grid $bottom.exit -column 1 -row 2 -sticky n
    grid $bottom.next -column 2 -row 2 -sticky w
	pack $bottom
	grab $w
    }
}

tik_write_examples

# Load the pre user config
if {[file exists $::TIK(prefile)]} {
    source $::TIK(prefile)
}

# Create the windows
tik_create_login
tik_create_buddy

# Show the login screen and set the initial status to the version of TiK.
tik_show_login
setStatus $::VERSION

# 
if [file exists $::TIK(pkgfile)] {
    source $::TIK(pkgfile)
    file stat $::TIK(pkgfile) pkgstat
    set ::TIK(pkgfile,mtime) $pkgstat(mtime)
    unset pkgstat
}

# Load the packages
tik_check_pkg 0

if [info exists .prefwindow] {
    tkwait window .prefwindow
}

# Load the user config
if {[file exists $::TIK(rcfile)] == 1} {
    source $::TIK(rcfile)
    
    if [file exists $::TIK(awayfile)] {
	source $::TIK(awayfile)
    }

    file stat $::TIK(rcfile) info
    set ::TIK(rcfile,mtime) $info(mtime)
}

update_unsup


catch {set SCREENNAME $TIK(clUser)}
catch {set PASSWORD $TIK(clPass)}

tik_check_rc
tik_check_pkg 1
tik_update_dynamic_info

# don't use this anymore
proc tik_ping {args} {}

# Ignore button patch add start
proc p_tik_ignore_luzer {id} {
    set w $::TIK(chats,$id,list)
       
    set sel [sag::selection $::TIK(chats,$id,list)]
    if {$sel == ""} {
        tk_messageBox -type ok -message [tik_str E_CHOOSEIGNRD]
        return
    } else {
        foreach s $sel {
            p_tik_ignore $id $s
        }
    }
}


# Ignore button patch add start

proc ADMIN_NICK_STATUS {connName args} {
    tk_messageBox -type ok -message [tik_str P_NICK_CHANGED]
    return
}

proc ADMIN_PASSWD_STATUS {connName args} {
    tk_messageBox -type ok -message [tik_str P_PASSWD_CHANGED]
    return
}

proc p_history {id} {
    set w $::TIK(chats,$id,msgw)
    if { $::TIK(options,chatheight) == 0} {
        set str [string trim [$w get]]
        if {$str != ""} {
            set ::TIK(chats,$id,lasttyped) [$w get]
        }
        $w delete 0 end
        $w insert 0 $::TIK(chats,$id,lasttyped)
    } else {
        set str [string trim [$w get 0.0 end]]
        if {$str != ""} {
            set ::TIK(chats,$id,lasttyped) [$w get 0.0 end]
        }
        $w delete 0.0 end
        $w insert 0.0 $::TIK(chats,$id,lasttyped)
    }
}

proc p_tik_ignore {id s} {
    set w $::TIK(chats,$id,list)

    set ns [normalize $s]
    if {[info exists ::TIK(chats,$id,luzer,$ns)]} {
        catch {sag::remove $w $::TIK(chats,$id,people,$ns)}
        unset ::TIK(chats,$id,luzer,$ns)
        set ::TIK(chats,$id,people,$ns) [sag::add $w 0 "" $s ""\
            $::TIK(options,buddymcolor) $::TIK(options,buddyocolor)]
    } else {
        catch {sag::remove $w $::TIK(chats,$id,people,$ns)}
        set ::TIK(chats,$id,luzer,$ns) 1
        set ::TIK(chats,$id,people,$ns) [sag::add $w 0 "" $s ""\
        $::TIK(options,ignorecolor) $::TIK(options,buddyocolor)] 
    }
}
