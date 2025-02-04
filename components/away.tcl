# Away Package
# 
# General away message capabilities.
#
# $Revision: 1.25 $

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
namespace eval away {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Away package $Revision: 1.25 $} \
      ::away::VERSION
  regexp -- { .* } {:$Date: 2001/01/14 02:53:58 $} \
      ::away::VERSDATE
}

# Options the user might want to set.  A user should use
# set ::TIK(options,...), not the tik_default_set

# How many times do we send an away message?
tik_default_set options,Away,sendmax -1
tik_default_set options,Away,delay 30000

# Do we send an idle message?
tik_default_set options,Away,sendidle 0

# How many seconds do we wait before sending the idle message.
# This gives us a chance to type a answer before it is sent.
tik_default_set options,Away,idlewait 5

# What is the idle msg?
tik_default_set options,Away,idlemsg \
    "Sorry %n, I'm away from my computer right now. -- %N"

# Added by JJM/FuzzFace00
#
# What command to issue and capture the output from if the user chooses
# to use %F as a substitution in an away message. 
#
# A value of 0 indicates that this feature is disabled
#
# A suggested value for RedHat Linux users would be
#       "/usr/games/fortune"
#
tik_default_set options,Away,Fcommand 0 

# How many characters do we allow in the menu for away messages that don't
# have a set nick?
tik_default_set options,Away,nicklength 25

namespace eval away {

    variable info

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline register

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        toc_register_func * IM_IN away::IM_IN
        toc_register_func * toc_set_idle away::IDLE_SET
        toc_register_func * SIGN_ON away::SIGN_ON
	
	set ::awaymsgcount 0
        set away::info(msg)      ""
        set away::info(msgnick)  ""
        set away::info(sendaway) 0
        menu .awayMenu -tearoff 0
        .toolsMenu add cascade -label [tik_str P_AWAY_M] -menu .awayMenu
        .awayMenu add command -label [tik_str P_AWAY_M_NEW] \
                              -command away::create_newaway
        .awayMenu add checkbutton -label [tik_str P_AWAY_M_IDLE] \
                                -variable ::TIK(options,Away,sendidle)
        .awayMenu add command -label [tik_str P_AWAY_M_SETIDLE] \
                              -command "away::create_newaway 1"
        .awayMenu add separator
    }

    # All pacakges must have goOnline routine.  Called when the user signs
    # on, or if the user is already online when packages loaded.
    proc goOnline {} {
    }

    # All pacakges must have goOffline routine.  Called when the user signs
    # off.  NOT called when the package is unloaded.
    proc goOffline {} {
        if {!($::TIK(reconnect) && $::TIK(options,persistent))} {
            away::back
        }
    }

    # All packages must have a unload routine.  This should remove everything 
    # the package set up.  This is called before load is called when reloading.
    proc unload {} {
        toc_unregister_func * IM_IN away::IM_IN
        toc_unregister_func * toc_set_idle away::IDLE_SET
        toc_unregister_func * SIGN_ON away::SIGN_ON
        .toolsMenu delete [tik_str P_AWAY_M]
        destroy .awayMenu
    }

    proc SIGN_ON {connName data} {
        if { $away::info(sendaway) } {away::set_away $away::info(msgnick)}
    }

    proc IDLE_SET {connName idlesecs} {
        if {($idlesecs == 0) && !$away::info(sendaway)} {
            foreach i [array names away::info "sentto,*"] {
                unset away::info($i)
            }
        }
    }

    proc sendmsg {delay source msg} {
        # Check to see if this is an idle message and we have become unidle
        if {($delay != 0) && !$::TIK(IDLE,sent)} {
            return
        }

        toc_send_im $::NSCREENNAME $source [away::expand $msg $source] auto
    }

    proc IM_IN {name source msg auto} {
        set nname [normalize $source]

        set msg [tik_filter_msg $name IM_IN $msg $source $auto]
        if {$msg == ""} {
            return
        }

        if {$away::info(sendaway)} {
            set msg $away::info(msg)
            set delay 0
        } elseif {$::TIK(options,Away,sendidle) && $::TIK(IDLE,sent)} {
            set msg $::TIK(options,Away,idlemsg)
            set delay $::TIK(options,Away,idlewait)
        } else {
            return
        }

        set nsrc [normalize $source]

        # Don't send away message more than max times to the same person
        if {![info exists away::info(sentto,$nsrc)]} {
            set away::info(sentto,$nsrc) 0
        }

        if {$away::info(sentto,$nsrc) < $::TIK(options,Away,sendmax)
            || (($::TIK(options,Away,sendmax) == -1) && ![info exists away::info(delay,$nsrc)])} {
            regsub -all -- {[]["${}\\]} $msg {\\&} msg
            after [expr $delay * 1000] away::sendmsg $delay \"$source\" \"$msg\" 
            if {$::TIK(options,Away,sendmax) == -1} {
                set away::info(delay,$nsrc) ""
                after $::TIK(options,Away,delay) "unset away::info(delay,$nsrc)"
            }

            incr away::info(sentto,[normalize $source])

            if {$delay != 0} {
                tik_msg_cim $source [tik_str P_AWAY_IDLE $delay]
            }
        } 
    }


# %n - Who sent the IM
# %N - Your screen name
# %i - Idle time in seconds
# %I - Idle time in minutes
# %e - Your current evil level 
# %j - Last TiK Event (Local Time)
# %J - Last TiK Event (UTC/GMT)
# %t - Current Time (Local)
# %T - Current Time (UTC/GMT)
# %d - Current Date (mm/dd/yy)
# %D - Current Date (mm/dd/yyyy)
# %F - Execute Command and Return Output 
# %% - A percent sign

    proc expand {msg nick} {
        set omsg ""
        set inp 0
        if {$::TIK(options,Away,Fcommand)!=0} {
	    set ocommand ""
	    foreach i [split $::TIK(options,Away,Fcommand) {}] {
		if {$inp} {
		    switch -exact -- $i {
			"n" {append ocommand $nick}
			"N" {append ocommand $::SCREENNAME}
			"i" {append ocommand [expr [clock seconds] - $::TIK(IDLE,last_event)]}
			"I" {append ocommand [expr ([clock seconds] - $::TIK(IDLE,last_event))/60]}
			"e" {append ocommand $::TIK(EVIL,level)}
			"j" {append ocommand [clock format $::TIK(IDLE,last_event)]}
			"J" {append ocommand [clock format $::TIK(IDLE,last_event) -gmt 1]}
			"t" {append ocommand [clock format [clock seconds] -format "%H:%M:%S %p"]}
			"T" {append ocommand [clock format [clock seconds] -gmt 1 ]}
			"d" {append ocommand [clock format [clock seconds] -format "%m/%d/%y"]}
                  "D" {append ocommand [clock format [clock seconds] -format "%m/%d/%Y"]}
			"%" {append ocommand "%"}
			default {append ocommand "%$i"}
		    }
		    set inp 0
		} elseif {$i == "%"} {
		    set inp 1
		} else {
		    append ocommand $i
		}
	    }	    
	    set spooge [eval exec $ocommand]
        } else {
                set spooge "NOTE: Fcommand not enabled!"
        } 

        set inp 0
        foreach i [split $msg {}] {
            if {$inp} {
                switch -exact -- $i {
                "n" {append omsg $nick}
                "N" {append omsg $::SCREENNAME}
                "i" {append omsg [expr [clock seconds] - $::TIK(IDLE,last_event)]}
                "I" {append omsg [expr ([clock seconds] - $::TIK(IDLE,last_event))/60]}
                "e" {append omsg $::TIK(EVIL,level)}
                "j" {append omsg [clock format $::TIK(IDLE,last_event)]}
                "J" {append omsg [clock format $::TIK(IDLE,last_event) -gmt 1]}
                "t" {append omsg [clock format [clock seconds] -format "%H:%M:%S %p"]}
                "T" {append omsg [clock format [clock seconds] -gmt 1 ]}
                "d" {append omsg [clock format [clock seconds] -format "%m/%d/%y"]}
                "D" {append omsg [clock format [clock seconds] -format "%m/%d/%Y"]}
                "F" {append omsg $spooge}
                "%" {append omsg "%"}
                 default {append omsg "%$i"}
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

    proc back {} {
        away::set_away
        catch {destroy .awaymsg}
        if {$::TIK(online)} {
            toc_set_away $::NSCREENNAME
        }
    }

    proc set_away {{awaymsg "_NOAWAY_"} {awaynick "_NONICK_"} } {
        if {$awaymsg == "_NOAWAY_"} {
            foreach i [array names away::info "sentto,*"] {
                unset away::info($i)
            }
            set away::info(sendaway) 0
            return
        } 

        if {($awaynick == "_NONICK_") || ($awaynick == "")} {
	    #regsub -all -- {"} $awaymsg {\"} awaymsg
            if {[info exists away::info(awaynicks,$awaymsg)]} {
                set awaynick $awaymsg
                set awaymsg $away::info(awaynicks,$awaymsg)
            } else {
                if {[string length $awaymsg] > $::TIK(options,Away,nicklength)} {
                    set awaynick [string range $awaymsg 0 [expr $::TIK(options,Away,nicklength) -1]]...
                } else {
                    set awaynick $awaymsg
                }
            }
        }
        if {[regexp -- {[]["${}\\]} $awaynick]} {
            set awaynick "InvalidNick[clock seconds]"
        }
        set away::info(awaynicks,$awaynick) $awaymsg
        away::register $awaymsg $awaynick

	catch {destroy .awaymsg}
	toc_set_away $::NSCREENNAME

        set away::info(msg) $awaymsg
        set away::info(msgnick) $awaynick
        set away::info(sendaway) 1

        set w .awaymsg

        if {[winfo exists $w]} {
            raise $w
            $w.text configure -state normal
            $w.text delete 0.0 end
            $w.text insert end $awaymsg
            $w.text configure -state disabled
            return
        }

        toplevel $w -class Tik
        wm title $w [tik_str P_AWAY_TITLE]
        wm iconname $w [tik_str P_AWAY_ICON]
        if {$::TIK(options,windowgroup)} {wm group $w .login}

        text  $w.text -width 40 -height 8 -wrap word
        $w.text insert end $awaymsg
        $w.text configure -state disabled

        if {$::TIK(options,Away,Fcommand)!=0} {
	    #
	    # This causes the Fcommand to be executed but not as a part
	    # of a away-reply to a buddy's message. This would not 
	    # be the correct behavior when the Fcommand is used to send
	    # an email, for example. So I have disabled this for the 
	    # time being. --Pagey
	    #
	    # set spooge [eval exec $::TIK(options,Away,Fcommand)]
	    set spooge "`$::TIK(options,Away,Fcommand)`"
        } else {
                set spooge "NOTE: Fcommand not enabled!"
        } 

        set ret $awaymsg

	regsub -all "%F" $awaymsg $spooge awaymsg

        toc_set_away $::NSCREENNAME $awaymsg

	if {$::TIK(options,iconbuttons)} {
	    button $w.back -image bback -command away::back
	} else {
	    button $w.back -text [tik_str P_AWAY_BACK] -command away::back
	}
        pack $w.back -side bottom
        pack $w.text -fill both -expand 1 -side top

        wm protocol $w WM_DELETE_WINDOW {away::back}

        return $ret
    }

    proc listawaysinmenu {menu} {
	$menu delete 3 end
	$menu add separator
	foreach t [lsort -dictionary [array names away::info "awaynicks*"]] {
	    set t [string trimleft $t "awaynicks"]
	    set t [string trimleft $t ","]
	    if [string length $t] {
		$menu add command -label $t \
                    -command [list away::set_away $away::info(awaynicks,$t) $t]
	    }
	}
    }
    
    proc register {awaymsg {awaynick "_NONICK_"} } {
        if {$awaynick == "_NONICK_" || $awaynick == ""} {
            if {[string length $awaymsg] > $::TIK(options,Away,nicklength)} {
                set awaynick [string range $awaymsg 0 [expr $::TIK(options,Away,nicklength) - 1]]...
            } else {
                set awaynick $awaymsg
            }
        }
        if {[regexp -- {[]["${}\\]} $awaynick]} {
            set awaynick "InvalidNick[clock seconds]"
        }
        set away::info(awaynicks,$awaynick) $awaymsg
        catch {.awayMenu delete $awaynick}
        #.awayMenu add command -label $awaynick -command [list away::set_away $awaymsg $awaynick]
	listawaysinmenu .awayMenu
    }

    proc newaway_ok {idle} {
        if {![winfo exists .newaway.text]} {
            return
        }
        set awaymsg [string trim [.newaway.text get 0.0 end]]

        if {$idle} {
            set ::TIK(options,Away,idlemsg) $awaymsg
        } else {
            set awaynick [string trim [.newaway.nick.e get]]
            away::set_away $awaymsg $awaynick
        }
        destroy .newaway
    }

    proc create_newaway {{idle 0}} {
        set w .newaway

        if {[winfo exists $w]} {
            raise $w
            return
        }

        toplevel $w -class Tik
        if {$::TIK(options,windowgroup)} {wm group $w .login}
       text $w.text -width 40 -height 8 -wrap word

        if {!$idle} {
            wm title $w [tik_str P_AWAY_NEW_TITLE]
            wm iconname $w [tik_str P_AWAY_NEW_ICON]
            label $w.info -text [tik_str P_AWAY_NEW_MSG]
            pack $w.info -side top
            frame $w.nick
            label $w.nick.l -text [tik_str P_AWAY_NEW_NICK] -width 15
            entry $w.nick.e
            pack $w.nick.l $w.nick.e -side left
            pack $w.nick -side top
            focus $w.nick.e
            bind $w.nick.e <Return> "focus $w.text"
        } else {
            wm title $w [tik_str P_AWAY_IDLE_TITLE]
            wm iconname $w [tik_str P_AWAY_IDLE_ICON]
            $w.text insert 0.0 $::TIK(options,Away,idlemsg)
            label $w.info -text [tik_str P_AWAY_IDLE_MSG]
            pack $w.info -side top

            frame $w.delayF
            label $w.delayL -text [tik_str P_AWAY_IDLE_DELAY]
            entry $w.delayE -textvariable ::TIK(options,Away,idlewait)
            pack $w.delayL $w.delayE -in $w.delayF -side left
            pack $w.delayF -side top
        }

        frame $w.buttons

	if {$::TIK(options,iconbuttons)} {
	    button $w.ok -image bok -command "away::newaway_ok $idle"
	    button $w.cancel -image bclose -command [list destroy $w]
	} else {
	    button $w.ok -text [tik_str B_OK] -command "away::newaway_ok $idle"
	    button $w.cancel -text [tik_str B_CANCEL] -command [list destroy $w]
	}

        pack $w.ok $w.cancel -in $w.buttons -side left -padx 2m

        pack $w.buttons -side bottom
        pack $w.text -fill both -expand 1 -side top

	bind $w <Control-period> "$w.cancel invoke"

	if { [expr {$::TIK(options,msgsend) & 1} ] == 1} {
	    bind $w.text <Return> "$w.ok invoke; break"
	}
	if { [expr {$::TIK(options,msgsend) & 2} ] == 2} {
	    bind $w.text <Control-Return> "$w.ok invoke; break"
	} else {
	    bind $w.text <Control-Return> " "
	}
    }
}

# Hack
proc tik_register_away {msg} {
    puts [tik_str P_AWAY_REG_NOTICE]
    return [away::register $msg]
}
