#############################################################################
#
# Broadcast package, adapted from TAC by MZhang
#
#############################################################################
#
# Many thanks to smike@users.tmok.com for the broadcast package from TAC that I
# took almost all of this code from.
#
#############################################################################

package require http 2.0

namespace eval bcast {
    regexp -- \
    {[0-9]+\.[0-9]+} {@(#)bcast - Toc Protocol Window $Revision: 1.4 $} \
    ::bcast::VERSION

    regexp -- { .* } {:$Date: 2000/07/13 08:20:29 $} \
    ::bcast::VERSDATE
}

namespace eval bcast {
	
    variable info

    namespace export load unload goOnline goOffline broadcast

    proc load {} {
        toc_register_func * IM_IN bcast::IM_IN
        toc_register_func * toc_send_im bcast::IM_OUT
        if {![info exists bcast::info(names)]} {
            set bcast::info(names) [list]
        }
        set ::TIK(bcastavail) ""
    }

    proc unload {} {
        toc_unregister_func * IM_IN bcast::IM_IN
        toc_unregister_func * toc_send_im bcast::IM_OUT
        unset ::TIK(bcastavail)
    }

    proc goOnline {} {
    }

    proc goOffline {} {
    }

    proc IM_IN {connName nick msg auto} {
        set source [normalize $nick]
        if {[tik_is_buddy $source]} {
            if {[set index [lsearch $bcast::info(names) $source]] == -1} {
                lappend bcast::info(names) $source
            } else {
                set bcast::info(names) [lreplace $bcast::info(names) $index $index]
                lappend bcast::info(names) $source
            }
        }
    }

    proc IM_OUT {connName nick msg auto} {
        set source [normalize $nick]
        if {[tik_is_buddy $source]} {
            if {[set index [lsearch $bcast::info(names) $source]] == -1} {
                lappend bcast::info(names) $source
            } else {
                set bcast::info(names) [lreplace $bcast::info(names) $index $index]
                lappend bcast::info(names) $source
            }
        }
    }

    proc broadcast {msg} {
        set chat 0
        set x [llength $bcast::info(names)]
        regexp {^(\w+\s*)(.*)$} $msg match num rest
        set num [string trim $num]
        if {[lsearch $::BUDDYLIST $num] != -1} {
            set group $num
            set msg $rest
	    } elseif {[string tolower $num] == "all"} {
	        set num $x
            set msg $rest
            set chat 1
	    } elseif {[string tolower $num] == "chats"} {
            set num 0
            set msg $rest
            set chat 1
        } elseif {![string is integer $num]} {
            set num $x
        } else {
            set msg $rest
        }
        
        if {[::info exists group]} {
            foreach name $::GROUPS($group,people) {
                if {($::BUDDIES($name,online) == "T")} {
                    toc_send_im $::NSCREENNAME $name $msg
                }
            }
            return
        }

        if {$chat} {
            foreach i [array names ::TIK "chats,*name*"] {
                set id [lindex [split $i {,}] 1]
                toc_chat_send $::NSCREENNAME $id $msg
            }
        }

        if {$num > $x } { set num $x }
        if {$num == 0} { return }

        for {set i [expr $x - 1]} {$i >= [expr $x - $num]} {incr i -1} {
            set name [lindex $bcast::info(names) $i]
		if {($::BUDDIES($name,online) == "T") && ([winfo exists .imConv$name])} {
                toc_send_im $::NSCREENNAME $name $msg
            }
        }
    }
}
