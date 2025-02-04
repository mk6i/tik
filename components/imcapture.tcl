# IM Capture Package
#
# Capture all IMs that we send and receive.
#             
# $Revision: 1.19 $

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

# All packages must be inside a namespace with the
# same name as the file name.


# Set VERSION and VERSDATE using the CVS tags.
namespace eval imcapture {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK IM Capture package $Revision: 1.19 $} \
      ::imcapture::VERSION
  regexp -- { .* } {:$Date: 2001/04/02 17:02:55 $} \
      ::imcapture::VERSDATE
}

tik_default_set options,imcapture,use 1
tik_default_set options,imcapture,timestamp 0

namespace eval imcapture {

    variable info

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        toc_register_func * toc_send_im imcapture::IM_OUT
        toc_register_func * IM_IN  imcapture::IM_IN
	toc_unregister_func * UPDATE_BUDDY UPDATE_BUDDY
	toc_register_func * UPDATE_BUDDY imcapture::UPDATE_BUDDY
	toc_register_func * UPDATE_BUDDY UPDATE_BUDDY

        menu .imcaptureMenu -tearoff 0
        .toolsMenu add cascade -label [tik_str P_IMCAPTURE_M] -menu .imcaptureMenu
        .imcaptureMenu add checkbutton -label [tik_str P_IMCAPTURE_USE] \
                -onvalue 1 -offvalue 0 -variable ::TIK(options,imcapture,use)
        .imcaptureMenu add checkbutton -label [tik_str P_IMCAPTURE_M_TS] \
                -onvalue 1 -offvalue 0 -variable ::TIK(options,imcapture,timestamp)
        .imcaptureMenu add separator
        .imcaptureMenu add command -label [tik_str P_IMCAPTURE_M_VA] \
                              -command imcapture::view

        tik_register_buddy_button_func "AIM" "View Capture" imcapture::bbuttonview


    }

    # All pacakges must have goOnline routine.  Called when the user signs
    # on, or if the user is already online when packages loaded.
    proc goOnline {} {
    }

    # All pacakges must have goOffline routine.  Called when the user signs
    # off.  NOT called when the package is unloaded.
    proc goOffline {} {
    }

    # All packages must have a unload routine.  This should remove everything 
    # the package set up.  This is called before load is called when reloading.
    proc unload {} {
        toc_unregister_func * toc_send_im imcapture::IM_OUT
        toc_unregister_func * IM_IN  imcapture::IM_IN
	toc_unregister_func * UPDATE_BUDDY imcapture::UPDATE_BUDDY
        .toolsMenu delete [tik_str P_IMCAPTURE_M]
        destroy .imcaptureMenu
        tik_unregister_buddy_button_func "AIM" "View Capture" 
    }

    proc IM_OUT {connName nick msg auto} {
        if {!$::TIK(options,imcapture,use)} {
            return
        }
        if {![file exists $::TIK(configDir)] || ![file isdirectory $::TIK(configDir)]} {
            puts "imcapture: Loss of capture data."
            puts "imcapture: Config directory doesn't exist."
            return
        }
        set n [normalize $nick]
        # Open the capture file
        set f [open_capture_file $n $nick]
        # Add a new session header if necessary
        add_session_header $n $nick $f
        # Save the im in the file
        set autostr ""
        if { ($auto == "auto") || ($auto == "T") } {
            set autostr [tik_str CIM_AUTORESP]
        }
        puts -nonewline $f [tik_str P_IMCAPTURE_MSGFMT [time_stamp]$::SCREENNAME$autostr $msg]
        close $f

        if {![info exists imcapture::info(menu,$n)]} {
            .imcaptureMenu add command -label "$nick" \
                                  -command "imcapture::view $n"
            set imcapture::info(menu,$n) [.imcaptureMenu index end]
            
        }
    }

    proc IM_IN {connName nick msg auto} {
        if {!$::TIK(options,imcapture,use)} {
            return
        }
        if {![file exists $::TIK(configDir)] || ![file isdirectory $::TIK(configDir)]} {
            puts "imcapture: Loss of capture data."
            puts "imcapture: Config directory doesn't exist."
            return
        }
        set n [normalize $nick]
        # Open the capture file
        set f [open_capture_file $n $nick]
        # Add a new session header if necessary
        add_session_header $n $nick $f
        # Save the im in the file
        set autostr ""
        if { ($auto == "auto") || ($auto == "T") } {
            set autostr [tik_str CIM_AUTORESP]
        }
        puts -nonewline $f [tik_str P_IMCAPTURE_MSGFMT [time_stamp]$nick$autostr [munge_message $msg]]
        close $f

        if {![info exists imcapture::info(menu,$n)]} {
            .imcaptureMenu add command -label "$nick" \
                                  -command "imcapture::view $n"
            set imcapture::info(menu,$n) [.imcaptureMenu index end]
            
        }
    }

    proc UPDATE_BUDDY {name user online evil signon idle uclass} {
        if {!$::TIK(options,imcapture,use)} {
            return
        }
        if {![file exists $::TIK(configDir)] || ![file isdirectory $::TIK(configDir)]} {
            puts "imcapture: Loss of capture data."
            puts "imcapture: Config directory doesn't exist."
            return
        }
        if {$::TIK(options,imtime) || $::TIK(options,imcapture,timestamp)} {
            set bud [normalize $user]
	    if {$online != $::BUDDIES($bud,online)} {
	        set w .imConv$bud
	        if {![winfo exists $w]} {
	            return
	        }
	        set f [open_capture_file $bud $user]
	        set tstr [clock format [clock seconds] -format [tik_str CIM_TIMESTAMP]]
		if {$online == "T"} {
                    puts $f <P>[tik_str CIM_LOGON $user $tstr]</P>
		} else {
                    puts $f <P>[tik_str CIM_LOGOFF $user $tstr]</P>
		}
		close $f
	    }
	}
    }

    proc view {{user {__ALL__}}} {
        if {$user == "__ALL__"} {
            tik_show_url imcapture "file://[file nativename [file join $::TIK(configDir) capture]]"
        } else {
            tik_show_url imcapture "file://[file nativename [file join $::TIK(configDir) capture $user.html]]"
        }
    }

    proc bbuttonview {cname name} {
        set norm [normalize $name]
        tik_show_url imcapture "file://[file nativename [file join $::TIK(configDir) capture $norm.html]]"
    }

    proc open_capture_file {n nick} {
        # Checking for the configDir one more time 
        if {![file exists $::TIK(configDir)] || ![file isdirectory $::TIK(configDir)]} {
            error "imcapture: Somehow you deleted the configDir at just the right time."
        }
        if {![file exists [file join $::TIK(configDir) capture]] || \
            ![file isdirectory [file join $::TIK(configDir) capture]]} {
            # Create and protect the capture dir.
            file mkdir [file join $::TIK(configDir) capture]
            catch {exec chmod og-rwx [file join $::TIK(configDir) capture]}
        }
        if {![file exists [file join $::TIK(configDir) capture $n.html]]} {
            # This is the first IM from this buddy so setup the HTML
            #  page with the beginning stuff:)
            set f [open [file join $::TIK(configDir) capture $n.html] a+]
            fconfigure $f -encoding utf-8
            puts $f [tik_str P_IMCAPTURE_FILEHDR $nick]
        } else {
            set f [open [file join $::TIK(configDir) capture $n.html] a+]
            fconfigure $f -encoding utf-8
        }
        return $f
    }

    proc add_session_header {n nick f} {
        # See if this is a new IM session
        if {![info exists imcapture::info(tod,$n)]} {
            set imcapture::info(tod,$n) 0
        }
        set lt $imcapture::info(tod,$n)
        set ct [clock seconds]
        # Check time difference (display header if more than 15 mins)
        if { ($ct - $lt) > 900 } {
            set tstr [clock format $ct -format "%m/%d/%y %H:%M %p"]
            puts $f [tik_str P_IMCAPTURE_MSGHDR $nick $tstr]
        }
        set imcapture::info(tod,$n) $ct
        return 0
    }

    proc munge_message {msg} {
        set clean $msg
        # Determine if the message is enclosed with <HTML> ... </HTML>
        if {[string first "<HTML>" $msg] == 0} {
            # Find the closing </HTML>
            set lpos [string last "</HTML>" $msg]
            incr lpos -1
            catch {set clean [string range $msg 6 $lpos]}
        }
        return $clean
    }

    proc time_stamp {} {
        if {$::TIK(options,imtime) || $::TIK(options,imcapture,timestamp)} {
            set tstr "[clock format [clock seconds] -format [tik_str CIM_TIMESTAMP]]"
        } else {
            set tstr ""
        }
    }
}
