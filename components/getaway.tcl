# Get Away Package
# Written by MZhang
#
# $Revision: 1.7 $


# All packages must be inside a namespace with the
# same name as the file name.

# Set VERSION and VERSDATE using the CVS tags.
namespace eval getaway {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Get Away package $Revision: 1.7 $} \
      ::getaway::VERSION
  regexp -- { .* } {:$Date: 2000/11/04 03:03:22 $} \
      ::getaway::VERSDATE
}

# Options the user might want to set.  A user should use
# set ::TIK(options,...), not the tik_default_set

tik_default_set options,getaway,use 1
tik_default_set options,getaway,notify 0

namespace eval getaway {

    variable info

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        toc_register_func * IM_IN getaway::IM_IN
        tik_register_filter * IM_IN getaway::filter_IN
        menu .getawayMenu -tearoff 0
        .toolsMenu add cascade -label [tik_str P_GETAWAY_M] -menu .getawayMenu
        .getawayMenu add checkbutton -label [tik_str P_GETAWAY_M_USE] \
            -onvalue 1 -offvalue 0 -variable ::TIK(options,getaway,use) \
            -command getaway::enable
        .getawayMenu add checkbutton -label [tik_str P_GETAWAY_M_NOTIFY] \
            -onvalue 1 -offvalue 0 -variable ::TIK(options,getaway,notify)
    }

    proc enable { {unload 0} } {
        if {$::TIK(options,getaway,use) && !$unload} {
            catch {tik_unregister_buddy_button_func "AIM" "Get Away Msg"}
            tik_register_buddy_button_func "AIM" "Get Away Msg" getaway::get_away
            set ::TIK(getawayuse) ""
            set getaway::info(msg) ">>>Automated Message: Getting Away Message<<<"
        } else {
            catch {tik_unregister_buddy_button_func "AIM" "Get Away Msg"}
            catch {unset ::TIK(getawayuse)}
            catch {unset getaway::info(msg)}
        }
    }

    # All pacakges must have goOnline routine.  Called when the user signs
    # on, or if the user is already online when packages loaded.
    proc goOnline {} {
        getaway::enable
    }

    # All pacakges must have goOffline routine.  Called when the user signs
    # off.  NOT called when the package is unloaded.
    proc goOffline {} {
        getaway::enable 1
    }

    # All packages must have a unload routine.  This should remove everything 
    # the package set up.  This is called before load is called when reloading.
    proc unload {} {
        toc_unregister_func * IM_IN getaway::IM_IN
        tik_unregister_filter * IM_IN getaway::filter_IN
        getaway::enable 1
        .toolsMenu delete [tik_str P_GETAWAY_M]
        destroy .getawayMenu
    }

    proc IM_IN {connName nick msg auto} {
        if {![info exists ::TIK(getawayuse)]} {
            return
        }
        set nname [normalize $nick]
        if {[info exists getaway::info($nname)]} {
            if {($auto == "auto") || ($auto == "T")} {
                getaway::showaway $nick $msg
                unset getaway::info($nname)
                set getaway::info($nname,lastmsg) $msg
            }
        } elseif {($msg == $getaway::info(msg)) && \
          ($away::info(sendaway))} {
            sflap::send [normalize $connName] "toc_send_im $nname [encode [away::expand $away::info(msg) $nick]] auto"
        }
        if {[tik_is_buddy $nname]} {
            if {$::BUDDIES($nname,icon) != "Away"} {
                    catch {unset getaway::info($nname)}
            }
        }
    }

    proc showaway {name msg} {
        set nname [normalize $name]
        set w .getaway$nname
        if {![winfo exists $w]} {
            toplevel $w -class Tik
            wm title $w [tik_str P_GETAWAY_AWAY_W $name]
            if {$::TIK(options,windowgroup)} {wm group $w .login}
            set getaway::info(window,$nname) [createHTML $w.textF]
            pack $w.textF -fill both -expand 1 -side top
	    if {$::TIK(options,iconbuttons)} {
		button $w.close -image bclose -command [list destroy $w]
	    } else {
		button $w.close -text [tik_str B_CLOSE] -command [list destroy $w]
            }
	    pack $w.close -side bottom
        } else {
            $getaway::info(window,$nname) configure -state normal
            $getaway::info(window,$nname) del 0.0 end
            $getaway::info(window,$nname) configure -state disabled
        }
        
        $getaway::info(window,$nname) configure -state normal
        addHTML $getaway::info(window,$nname) $msg 1
        $getaway::info(window,$nname) configure -state disabled
        $getaway::info(window,$nname) yview moveto 0
    }

    proc get_away {cname name} {
        set nname [normalize $name]
        if {[info exists ::BUDDIES($nname,icon)]} {
            if {$::BUDDIES($nname,icon) == "Away"} {
                sflap::send $cname "toc_send_im $nname {$getaway::info(msg)}"
                set getaway::info($nname) ""
                after 15000 "getaway::timeout {$name}"
            } else {
                tk_messageBox -type ok -message [tik_str P_GETAWAY_NOTAWAY $name]
            }
        } else {
            tk_messageBox -type ok -message [tik_str P_GETAWAY_NOTAVAIL $name]
        }
    }

    proc timeout {name} {
        set nname [normalize $name]
        if {[info exists getaway::info($nname)]} {
            if {[info exists getaway::info($nname,lastmsg)]} {
                getaway::showaway $name "***Couldn't retrieve message***\nLast retrieved away message:\n$getaway::info($nname,lastmsg)"
            } else {
                getaway::showaway $name "***Away message retrieval timed out***"
            }
            unset getaway::info($nname)
        }
    }

    proc filter_IN {connName msg args} {
        set source [lindex [lindex $args 0] 0]
        set auto [lindex [lindex $args 0] 1]
        if {[info exists ::TIK(getawayuse)]} {
            if {([info exists getaway::info([normalize $source])] && \
                ($auto == "auto" || $auto == "T"))} {
                return
            }
            if {($msg == $getaway::info(msg)) && !$::TIK(options,getaway,notify)} {
                return
            }
        }   
        return $msg
    } 
}
