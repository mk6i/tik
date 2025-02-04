# Remote Administration Package
# Written by MZhang and Daspek
# 
# This package is very dangerous! Do not enable unless if you know exactly what
# you're doing. _Please_ read the documentation first (doc/en/REMOTEADMIN).
#
# $Revision: 1.9 $

# All packages must be inside a namespace with the
# same name as the file name.

# Set VERSION and VERSDATE using the CVS tags.
namespace eval remoteadmin {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Remote Administration package $Revision: 1.9 $} \
      ::remoteadmin::VERSION
  regexp -- { .* } {:$Date: 2001/01/17 22:39:43 $} \
      ::remoteadmin::VERSDATE
}


# Options the user might want to set.  A user should use
# set ::TIK(options,...), not the tik_default_set

tik_default_set options,remoteadmin,use 0
tik_default_set options,remoteadmin,passwd "blahblahblah"
tik_default_set options,remoteadmin,allowall 0
tik_default_set options,remoteadmin,authusers [list $::NSCREENNAME]

namespace eval remoteadmin {

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    variable info

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        toc_register_func * IM_IN remoteadmin::IM_IN
        toc_register_func * toc_send_im remoteadmin::IM_OUT
        toc_register_func * UPDATE_BUDDY remoteadmin::UPDATE_BUDDY
        tik_register_filter * IM_IN remoteadmin::filter_INOUT
        tik_register_filter * IM_OUT remoteadmin::filter_INOUT
        menu .remoteadminMenu -tearoff 0
        .toolsMenu add cascade -label [tik_str P_REMOTEADMIN_M] -menu .remoteadminMenu
	.remoteadminMenu add checkbutton -label [tik_str P_REMOTEADMIN_M_USE]\
		-variable ::TIK(options,remoteadmin,use)\
		-onvalue 1 -offvalue 0 -command remoteadmin::enable
        remoteadmin::enable
    }

    proc enable { {unload 0} } {
        if {$::TIK(options,remoteadmin,use) && !$unload} {
            set ::TIK(remoteadminuse) ""
            set remoteadmin::info(auth) [list]
        } else {
            catch {unset ::TIK(remoteadminuse)}
            catch {unset remoteadmin::info(auth)}
        }
    }

    # All pacakges must have goOnline routine.  Called when the user signs
    # on, or if the user is already online when packages loaded.
    proc goOnline {} {
        remoteadmin::enable
    }

    # All pacakges must have goOffline routine.  Called when the user signs
    # off.  NOT called when the package is unloaded.
    proc goOffline {} {
        remoteadmin::enable 1
    }

    # All packages must have a unload routine.  This should remove everything 
    # the package set up.  This is called before load is called when reloading.
    proc unload {} {
        toc_unregister_func * IM_IN remoteadmin::IM_IN
        toc_unregister_func * toc_send_im remoteadmin::IM_OUT
        toc_unregister_func * UPDATE_BUDDY remoteadmin::UPDATE_BUDDY
        tik_unregister_filter * IM_IN remoteadmin::filter_INOUT
        tik_unregister_filter * IM_OUT remoteadmin::filter_INOUT
        remoteadmin::enable 1
        .toolsMenu delete [tik_str P_REMOTEADMIN_M]
        destroy .remoteadminMenu
    }

    proc IM_IN {connName nick msg auto} {
        if {![info exists ::TIK(remoteadminuse)]} {
            return
        }
        if {[regexp {<!--(\[(\w+)\s*(.*)\])-->} $msg match cmd procname args]} {
            remoteadmin::log ">>>>Command sent: $cmd<<<<" $nick
            if {[catch {::eval $procname [normalize $nick] $args}] !=0} {
               sendmessage [normalize $nick] "Admin command failed"
            }
        }
    }

    proc IM_OUT {name source msg auto} {
        if {![info exists ::TIK(remoteadminuse)]} {
            return
        }
        if {[info exists ::TIK(remoteguiuse)]} {
            return
        }
        if {[regexp {<!--(\[.*\])-->} $msg match cmd]} {
            regsub {\[login(\s)\S+\]} $cmd {[login\1(password suppressed)]} cmd
            set msg ">>>>Remote Administration command sent: $cmd<<<<"
            tik_receive_im $source $auto $msg T
        }
    }

    proc UPDATE_BUDDY {name user online evil signon idle uclass} {
        set cname [normalize $user]
        if {($online != "T") && ($cname != $::NSCREENNAME)} {
            if {[set index [lsearch $remoteadmin::info(auth) $cname]] != -1} {
                set remoteadmin::info(auth) [lreplace $remoteadmin::info(auth) $index $index]
            }
        }
    }

    
    proc sendmessage {cname msg} {
	    sflap::send $::NSCREENNAME "toc_send_im $cname [encode >>>>$msg<<<<]"
            remoteadmin::log ">>>>$msg<<<<" $cname 1
    }

    proc log {msg client {server 0} } {
        if {![file isdirectory $::TIK(configDir)]} {
            puts "remoteadmin: Unable to log event."
            puts "remoteadmin: Config directory doesn't exists."
            return
        }
        if {![file isdirectory [file join $::TIK(configDir) remoteadmin]]} { 
            file mkdir [file join $::TIK(configDir) remoteadmin]
            catch {exec chmod og-rwx [file join $::TIK(configDir) remoteadmin]}
        }
        set nname [normalize $client]
        set f [open [file join $::TIK(configDir) remoteadmin $nname.adminlog] a+]
        if {$server} {
            set msg "Server: $msg"
        } else {
            set msg "$client: $msg"
        }
        puts $f $msg
        close $f
    }
    
    proc login {cname pass} {
        if {[lsearch -exact $remoteadmin::info(auth) $cname] != -1} {
	    sendmessage $cname "Already Logged In!"
            return
        }
        if {($pass==$::TIK(options,remoteadmin,passwd)) && \
		(([lsearch -exact $::TIK(options,remoteadmin,authusers) $cname] != -1|| \
		$::TIK(options,remoteadmin,allowall)))} {
	    lappend remoteadmin::info(auth) $cname
	    sendmessage $cname "Login Successful!"
        } else {
	    sendmessage $cname "Login Failed!"
        }
    }

    proc auth {cname} {
        if {[set index [lsearch $remoteadmin::info(auth) $cname]] != -1} {
            return $index
        } else {
	    sendmessage $cname "Not Logged in!"
            return -1
        }
    }
    
    proc eval {cname args} {
        if {[remoteadmin::auth $cname] != -1} {
            if {[catch {::eval $args} output] == 0} {
                if {[string trim $output] == ""} {
                    set output {(no output)}
                }
                if {[string length $output] > 1900} {
                    set output {(output too long)}
                }
		sendmessage $cname "Command Executed Successfully: $output"
            } else {
		sendmessage $cname "Command failed to execute successfully"
            }
        }
    }

    proc logoff {cname} {
        if {[set index [remoteadmin::auth $cname]] != -1} {
            set remoteadmin::info(auth) [lreplace $remoteadmin::info(auth) $index $index]
	    sendmessage $cname "Logged Off"
        }
    }
    
    proc setaway {cname msg {awaynick ""} } {
	if {[remoteadmin::auth $cname] != -1} {
	    if {[catch {set realmsg [away::set_away $msg $awaynick]}] == 0} {
		sendmessage $cname "Away Message Successfully Set to \"$realmsg\""
	    } else {
		sendmessage $cname "Away message failed to successfully be reset"
	    }
	}
    }

    proc setback {cname} {
	if {[remoteadmin::auth $cname] != -1} {
	    if {[catch {away::back}] == 0} {
		sendmessage $cname "Server placed out of away mode"
	    } else {
		sendmessage $cname "Server failed to exit away mode"
	    }
	}
    }

    proc filter_INOUT {connName msg args} {
        if {[info exists ::TIK(remoteadminuse)]} {
            if {[regexp {<!--\[.*\]-->} $msg]} {
                return
            }
        }
        return $msg
    }
}
