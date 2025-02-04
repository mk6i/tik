# Chat Capture Package
#
# Capture all chat sessions that we are involved.
#             
# $Revision: 1.6 $

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
namespace eval chatcapture {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Chat Capture package $Revision: 1.6 $} \
      ::chatcapture::VERSION
  regexp -- { .* } {:$Date: 2001/04/02 17:02:55 $} \
      ::chatcapture::VERSDATE
}


tik_default_set options,chatcapture,use 1
tik_default_set options,chatcapture,timestamp 0

namespace eval chatcapture {

    variable info

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        toc_register_func * CHAT_JOIN chatcapture::CHAT_JOIN
        toc_register_func * CHAT_IN  chatcapture::CHAT_IN
        toc_register_func * CHAT_UPDATE_BUDDY  chatcapture::CHAT_UPDATE_BUDDY
        toc_register_func * CHAT_LEFT  chatcapture::CHAT_LEFT

        menu .chatcaptureMenu -tearoff 0
        .toolsMenu add cascade -label [tik_str P_CHATCAPTURE_M] -menu .chatcaptureMenu
        .chatcaptureMenu add checkbutton -label [tik_str P_CHATCAPTURE_USE] \
                -onvalue 1 -offvalue 0 -variable ::TIK(options,chatcapture,use)
        .chatcaptureMenu add checkbutton -label [tik_str P_CHATCAPTURE_M_TS] \
                -onvalue 1 -offvalue 0 -variable ::TIK(options,chatcapture,timestamp)
        .chatcaptureMenu add separator
        .chatcaptureMenu add command -label [tik_str P_CHATCAPTURE_M_VA] \
                              -command chatcapture::view
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
        toc_unregister_func * CHAT_JOIN chatcapture::CHAT_JOIN
        toc_unregister_func * CHAT_IN  chatcapture::CHAT_IN
        toc_unregister_func * CHAT_UPDATE_BUDDY  chatcapture::CHAT_UPDATE_BUDDY
        toc_unregister_func * CHAT_LEFT  chatcapture::CHAT_LEFT
        .toolsMenu delete [tik_str P_CHATCAPTURE_M]
        destroy .chatcaptureMenu
    }

    proc CHAT_JOIN {name id loc} {
        if {!$::TIK(options,chatcapture,use)} {
            return
        }
        if {![file exists $::TIK(configDir)] || \
            ![file isdirectory $::TIK(configDir)]} {
            puts "chatcapture: Loss of capture data for this chatroom."
            puts "chatcapture: Config directory doesn't exists."
            return
        }
        set n [normalize $loc]
        # Open the capture file
        set f [open_chat_capture_file $n $loc]
        # Add a new session header 
        add_session_header $loc $f

        if {![info exists chatcapture::info(menu,$n)]} {
            .chatcaptureMenu add command -label "$loc" \
                                  -command "chatcapture::view $n"
            set chatcapture::info(menu,$n) [.chatcaptureMenu index end]
            
        }
        set chatcapture::info($id) $f
    }

    proc CHAT_LEFT {name id} {
        if {!$::TIK(options,chatcapture,use)} {
            return
        }
        if {![info exists ::chatcapture::info($id)]} {
            puts "chatcapture: CHAT_LEFT - output failure"
            return
        }
        # Add a session footer 
        add_session_footer $chatcapture::info($id)
        close $chatcapture::info($id)
        set chatcapture::info($id) ""
    }

    proc CHAT_IN {name id source whisper msg} {
        if {!$::TIK(options,chatcapture,use)} {
            return
        }
        if {![info exists ::chatcapture::info($id)]} {
            puts "chatcapture: CHAT_IN - output failure"
            return
        }
        set n [normalize $source]
        if {! [info exists ::TIK(chats,$id,luzer,$n)]} {
            set f $chatcapture::info($id)
            puts -nonewline $f [tik_str P_CHATCAPTURE_MSGFMT [time_stamp]$source [munge_message $msg]]
            flush $f
        }
    }

    proc CHAT_UPDATE_BUDDY {name id online blist} {
        if {!$::TIK(options,chatcapture,use)} {
            return
        }
        if {![info exists ::chatcapture::info($id)]} {
            puts "chatcapture: CHAT_UPDATE_BUDDY - output failure"
            return
        }
        set f $chatcapture::info($id)
        foreach p $blist {
            if {$online == "F"} {
                puts -nonewline $f [tik_str P_CHATCAPTURE_DEPART [time_stamp]$p]
            }
            if {$online == "T"} {
                puts -nonewline $f [tik_str P_CHATCAPTURE_ARRIVE [time_stamp]$p]
            }
        }
        flush $f
    }

    proc open_chat_capture_file {n name} {
        if {![file exists $::TIK(configDir)] || \
            ![file isdirectory $::TIK(configDir)]} {
            error "chatcapture: Somehow you deleted the configDir at just the right time."
        }
        if {![file exists [file join $::TIK(configDir) chatcapture]] || \
            ![file isdirectory [file join $::TIK(configDir) chatcapture]]} {
            # Create and protect the capture dir.
            file mkdir [file join $::TIK(configDir) chatcapture]
            catch {exec chmod og-rwx [file join $::TIK(configDir) chatcapture]}
        }
        if {![file exists [file join $::TIK(configDir) chatcapture $n.html]]} {
            # This is the first chat room  so setup the HTML
            #  page with the beginning stuff:)
            set f [open [file join $::TIK(configDir) chatcapture $n.html] a+]
            fconfigure $f -encoding utf-8
            puts $f [tik_str P_CHATCAPTURE_FILEHDR $name]
        } else {
            set f [open [file join $::TIK(configDir) chatcapture $n.html] a+]
            fconfigure $f -encoding utf-8
        }
        return $f
    }

    proc add_session_header {name f} {
        set ct [clock seconds]
        set tstr [clock format $ct -format "%m/%d/%y %H:%M %p"]
        puts $f [tik_str P_CHATCAPTURE_MSGHDR $name $tstr]
        return 0
    }

    proc add_session_footer {f} {
        set ct [clock seconds]
        set tstr [clock format $ct -format "%m/%d/%y %H:%M %p"]
        puts $f [tik_str P_CHATCAPTURE_FOOTER $tstr]
        return 0
    }

    proc view {{name {__ALL__}}} {
        if {$name == "__ALL__"} {
            tik_show_url chatcapture "file://[file nativename [file join $::TIK(configDir) chatcapture]]"
        } else {
            set n [normalize $name]
            tik_show_url chatcapture "file://[file nativename [file join $::TIK(configDir) chatcapture $name.html]]"
        }
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
        if {$::TIK(options,chattime) || $::TIK(options,chatcapture,timestamp)} {
            set tstr "[clock format [clock seconds] -format [tik_str CHAT_TIMESTAMP]]"
        } else {
            set tstr ""
        }
    }

}
