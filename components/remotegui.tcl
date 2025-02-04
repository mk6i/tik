# Remote Administration GUI Package
# Written by MZhang and Daspek
#
# $Revision: 1.7 $

# All packages must be inside a namespace with the
# same name as the file name.

# Set VERSION and VERSDATE using the CVS tags.
namespace eval remotegui {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Remote Administration GUI package $Revision: 1.7 $} \
      ::remotegui::VERSION
  regexp -- { .* } {:$Date: 2000/11/04 03:03:22 $} \
      ::remotegui::VERSDATE
}


# Options the user might want to set.  A user should use
# set ::TIK(options,...), not the tik_default_set

namespace eval remotegui {

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    variable info

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        toc_register_func * IM_IN remotegui::IM_IN
        toc_register_func * toc_send_im remotegui::IM_OUT
        tik_register_filter * IM_IN remotegui::filter_IN
        tik_register_filter * IM_OUT remotegui::filter_OUT
        menu .remoteguiMenu -tearoff 0
        .toolsMenu add cascade -label [tik_str P_REMOTEGUI_M] -menu .remoteguiMenu
        .remoteguiMenu add command -label [tik_str P_REMOTEGUI_NEW] \
                -command remotegui::newrgui
        remotegui::enable
    }

    proc enable { {unload 0} } {
        if {!$unload} {
            set ::TIK(remoteguiuse) ""
        } else {
            catch {unset ::TIK(remoteguiuse)}
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
        toc_unregister_func * IM_IN remotegui::IM_IN
        toc_unregister_func * toc_send_im remotegui::IM_OUT
        tik_unregister_filter * IM_IN remotegui::filter_IN
        tik_unregister_filter * IM_OUT remotegui::filter_OUT
        remotegui::enable 1
        .toolsMenu delete [tik_str P_REMOTEGUI_M]
        destroy .remoteguiMenu
    }

    proc IM_IN {connName nick msg auto} {
        if {![info exists ::TIK(remoteguiuse)]} {
            return
        }
        set server [normalize $nick]
        if {[regexp {>>>>.*<<<<} $msg]} {
            if {[winfo exists .rgui$server]} {
                $remotegui::info(rguis,$server) configure -state normal
                addHTML $remotegui::info(rguis,$server) "Server: $msg\n" 1
                $remotegui::info(rguis,$server) configure -state disabled
#                if {[info exists remotegui::info(closenow,$server)]} {
#                    destroy .rgui$server
#                    unset remotegui::info(closenow,$server)
#                }
            }  else {
                tik_receive_im $nick $auto $msg F
            }
        }
    }

    proc IM_OUT {name source msg auto} {
        if {![info exists ::TIK(remoteguiuse)]} {
            return
        }
        set server [normalize $name]
        if {[regexp {<!--(\[.*\])-->} $msg match cmd]} {
            regsub {\[login(\s)\S+\]} $cmd {[login\1(password suppressed)]} cmd
            set msg ">>>>Remote Administration command sent: $cmd<<<<"
            if {[winfo exists .rgui$server]} {
                $remotegui::info(rguis,$server) configure -state normal
                addHTML $remotegui::info(rguis,$server) "Client: $msg\n" 1
                $remotegui::info(rguis,$server) configure -state disabled
            }  else {
                tik_receive_im $source $auto $msg T
            }
        }
    }
    
    proc send {server w {remoteproc "_none_"} } {
	if {$remoteproc == "_none_"} {
	    set remoteproc ""
	}

        if {![winfo exists $w]} {
            return
        }
        set cmd [$w.e get]
	if {$remoteproc != "_none_"} {
	    set cmd "$remoteproc $cmd"
	    set cmd [string trim $cmd]
	}
        if {$cmd == ""} {
            return
        }
        toc_send_im $::NSCREENNAME $server "<!--\[$cmd\]-->"
        $w.e delete 0 end
    }
    
    proc closeconn {server} {
        if {![winfo exists .rgui$server]} {
            return
        }
        if {$::BUDDIES($server,online)} {
            toc_send_im $::NSCREENNAME $server "<!--\[logoff\]-->"
        }
        set remotegui::info(closenow,$server) ""
        destroy .rgui$server
        unset remotegui::info(closenow,$server) ""
    }
    
    proc cmdsend {server cmd} {
	sflap::send $::NSCREENNAME "toc_send_im $server [encode <!--\[$cmd\]-->]"
    }

    proc create_rgui {} {
        if {![winfo exists .newrgui]} {
            return
        }
        set name [.newrgui.server.e get]
        set passwd [.newrgui.passwd.e get]
        set server [normalize $name]
        if {$server == ""} {
            tk_messageBox -type ok -message [tik_str P_REMOTEGUI_ENTER_SERVER]
            raise .newrgui
            focus .newrgui.server.e
            return
        }

        if {![tik_is_buddy $server]} {
            tk_messageBox -type ok -message [tik_str P_REMOTEGUI_INVALID_SERVER]
            raise .newrgui
            focus .newrgui.server.e
            return
        }

        if {$::BUDDIES($server,online) == "F"} {
            tk_messageBox -type ok -message [tik_str P_REMOTEGUI_NOTONLINE]
            raise .newrgui
            focus .newrgui.server.e
            return
        }

        destroy .newrgui
        set w .rgui$server
        
        if {[winfo exists $w]} {
            raise $w
        }    
        
        toplevel $w -class Tik
        wm title $w [tik_str P_REMOTEGUI_TITLE $name]
        wm iconname $w [tik_str P_REMOTEGUI_ICON $name]
        
        set remotegui::info(rguis,$server) [createHTML $w.textF]
        pack $w.textF -fill both -expand 1 -side top
	frame $w.entry
        entry $w.e

        frame $w.buttons
	
	#if {$::TIK(options,iconbuttons)} {
	#    button $w.send -image bsend -command "remotegui::send $server $w"
	#    button $w.close -image bclose -command "remotegui::closeconn $server"
	#} else {
	    button $w.set -text [tik_str P_REMOTEGUI_SETAWAY] -command "remotegui::send $server $w setaway"
	    button $w.back -text [tik_str P_REMOTEGUI_SETBACK] -command "remotegui::cmdsend $server setback"
	    button $w.send -text [tik_str B_SEND] -command "remotegui::send $server $w"
	    button $w.close -text [tik_str B_CLOSE] -command "remotegui::closeconn $server"
        #}

	pack $w.e -fill x -in $w.entry
	pack $w.entry -fill x
        pack $w.set $w.back -in $w.buttons -side left -padx 2m
	pack $w.send $w.close -in $w.buttons -side left -padx 2m
        pack $w.buttons -pady 2
	

        #pack $w.e -fill x -side bottom

        bind $w.e <Return> "$w.send invoke"
        $remotegui::info(rguis,$server) configure -state disabled
        set loginstring "<!--\[login $passwd\]-->"
        sflap::send $::NSCREENNAME "toc_send_im $server [encode $loginstring]"
        focus $w.e
        wm protocol $w WM_DELETE_WINDOW "remotegui::closeconn $server"
    }
    
    proc newrgui {} {
        set w .newrgui

        if {[winfo exists $w]} {
            raise $w
            return
        }

        toplevel $w -class Tik
        if {$::TIK(options,windowgroup)} {wm group $w .login}
        wm title $w [tik_str P_REMOTEGUI_NEW_TITLE]
        wm iconname $w [tik_str P_REMOTEGUI_NEW_ICON]

        frame $w.server
        label $w.server.l -text [tik_str P_REMOTEGUI_SERVER] -width 15
        entry $w.server.e
        pack $w.server.l $w.server.e -side left
        pack $w.server -side top
        frame $w.passwd
        label $w.passwd.l -text [tik_str P_REMOTEGUI_PASSWD] -width 15
        entry $w.passwd.e -show "*"
        pack $w.passwd.l $w.passwd.e -side left
        pack $w.passwd -side top
        
        frame $w.buttons

	if {$::TIK(options,iconbuttons)} {
	    button $w.ok -image bok -command "remotegui::create_rgui"
	    button $w.cancel -image bclose -command [list destroy $w]
	} else {
	    button $w.ok -text [tik_str B_OK] -command "remotegui::create_rgui"
	    button $w.cancel -text [tik_str B_CANCEL] -command [list destroy $w]
	}
        
        pack $w.ok $w.cancel -in $w.buttons -side left -padx 2m
        pack $w.buttons -side bottom
        bind $w.server.e <Return> "focus $w.passwd.e"
        bind $w.passwd.e <Return> "remotegui::create_rgui"
        focus $w.server.e
    }

    proc filter_OUT {connName msg args} {
        if {[info exists ::TIK(remoteguiuse)]} {
            if {[regexp {<!--\[.*\]-->} $msg]} {
                return
            }
        }   
        return $msg
    }

    proc filter_IN {connName msg args} {
        if {[info exists ::TIK(remoteguiuse)]} {
            if {[regexp {>>>>.*<<<<} $msg]} {
                return
            }
        }
        return $msg
    }

}
