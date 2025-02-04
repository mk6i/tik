# QuickChat Package
#
# Make it easy to access chat room that you frequent.
#
# $Revision: 1.7 $

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

# Options the user might want to set.  A user should use
# set ::TIK(options,...), not the tik_default_set

# The url to refresh chats from
#
# FuzzFace00 - 6 April 2000
#
# The old "official" AOL URL, which stopped working sometime ago...
#
# tik_default_set options,quickchat,url http://www.aim.aol.com/tik/aolchats.txt
#
# The URL on FuzzFace's server, which does support this feature...
#
tik_default_set options,quickchat,url "http://www.oaks.yoyodyne.com/cgi-bin/allchats.cgi"


# All packages must be inside a namespace with the
# same name as the file name.

# Set VERSION and VERSDATE using the CVS tags.
namespace eval quickchat {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Quick Chat package $Revision: 1.7 $} \
      ::quickchat::VERSION
  regexp -- { .* } {:$Date: 2001/01/19 01:21:47 $} \
      ::quickchat::VERSDATE
}

namespace eval quickchat {

    variable info

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline register

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        menu .quickChatMenu 
        .toolsMenu add cascade -label [tik_str P_QUICKCHAT_M] -menu .quickChatMenu
        .quickChatMenu add command -label [tik_str P_QUICKCHAT_M_NEW] \
                              -command quickchat::create_newquickchat
        .quickChatMenu add command -label [tik_str P_QUICKCHAT_M_REFRESH] \
                              -command quickchat::download
        .quickChatMenu add separator
        .quickChatMenu add command -label [tik_str P_QUICKCHAT_M_TT] \
                              -command [list quickchat::go "TicToc" 4]
        .quickChatMenu add command -label [tik_str P_QUICKCHAT_M_L] \
                              -command [list quickchat::go "Linux" 4]

        if {[file exists [file join $::TIK(configDir) aolchats.txt]]} {
            # Delay loading until after tikrc by using "after"
	    after 1000 quickchat::loadChats
        }
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
        .toolsMenu delete [tik_str P_QUICKCHAT_M]
        destroy .quickChatMenu
        destroy .newquickchat
    }

    # quickchat::register
    #
    # Arguments:
    #    title    - What to show in the menu
    #    room     - The actual room name
    #    exchange - The exchange the chat room is in, usually 4 for now.
    proc register {title room {exchange 4}} {
        set path [split $title {:}]
        set lpath [llength $path]
        set m .quickChatMenu

        foreach p $path {
            if {$lpath == 1} {
                catch {$m delete $p}
                $m add command -label $p \
                    -command [list quickchat::go $room $exchange]
                continue
            }

            incr lpath -1
            set newm "$m.[normalize $p]"
            if {![winfo exists $newm]} {
                menu $newm
                $m add cascade -label $p -menu $newm
            }
            set m $newm
        }
    }

    proc download {} {
        http::geturl $::TIK(options,quickchat,url) \
            -headers "Pragma no-cache" -command quickchat::dataAvail
    }

    proc dataAvail {token} {
        if {![file isdirectory $::TIK(configDir)]} {
            puts "quickchat: Can't update chatrooms."
            puts "quickchat: Config directory doesn't exists."
            return
        }
        upvar #0 $token state
        set f [open [file join $::TIK(configDir) aolchats.txt] w]
        puts -nonewline $f $state(body)
        close $f
        http::cleanup $token
	loadChats 
    }

    proc loadChats {} {
        # this shouldn't happen, but. . . .
        if {![file isdirectory $::TIK(configDir)]} {
            puts "quickchat: Can't update chatrooms."
            puts "quickchat: Config directory doesn't exists."
            return
        }
         set file "[file join $::TIK(configDir) aolchats.txt]"
        set f [open $file r]
	while { ![eof $f]} {
	    set line [gets $f]
	    foreach {title room exchange} [split $line {;} ] break
	    quickchat::register $title $room $exchange
	}
	close $f
    }

    proc go {room exchange} {
        toc_chat_join $::NSCREENNAME $exchange $room
    }

    proc newquickchat_ok {} {
        if {![winfo exists .newquickchat]} {
            return
        }
        quickchat::register $quickchat::info(title) $quickchat::info(room) \
                       $quickchat::info(exchange)
        destroy .newquickchat
    }

    proc create_newquickchat {} {
        set w .newquickchat

        if {[winfo exists $w]} {
            raise $w
            return
        }

        toplevel $w -class Tik
        wm title $w [tik_str P_QUICKCHAT_N_TITLE]
        wm iconname $w [tik_str P_QUICKCHAT_N_ICON]
        if {$::TIK(options,windowgroup)} {wm group $w .login}

        label $w.info -text [tik_str P_QUICKCHAT_N_WARN]

        set quickchat::info(title) ""
        set quickchat::info(room) ""
        set quickchat::info(exchange) "4"

        frame $w.titleF
        label $w.titleL -text [tik_str P_QUICKCHAT_N_MENU] -anchor se -width 18
        entry $w.titleE -text quickchat::info(title)
        pack $w.titleL $w.titleE -in $w.titleF -side left

        frame $w.roomF
        label $w.roomL -text [tik_str P_QUICKCHAT_N_CHAT] -anchor se -width 18
        entry $w.roomE -text quickchat::info(room)
        pack $w.roomL $w.roomE -in $w.roomF -side left

        frame $w.exchangeF
        label $w.exchangeL -text [tik_str P_QUICKCHAT_N_EX] -anchor se -width 18
        entry $w.exchangeE -text quickchat::info(exchange)
        pack $w.exchangeL $w.exchangeE -in $w.exchangeF -side left

        frame $w.buttons
        button $w.ok -text [tik_str B_OK] -command "quickchat::newquickchat_ok"
        button $w.cancel -text [tik_str B_CANCEL] -command [list destroy $w]
        pack $w.ok $w.cancel -in $w.buttons -side left -padx 2m

        pack $w.info $w.titleF $w.roomF $w.exchangeF -side top
        pack $w.buttons -side bottom
    }
}
