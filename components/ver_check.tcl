# ver_check.tcl
#
# This plugin checks to see if there is a newer version of TiK available for download.
#
# To avoid 

namespace eval ver_check {
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Version Check $Revision: 1.2 $} \
      ::ver_check::VERSION
  regexp -- { .* } {:$Date: 2001/04/02 17:50:18 $} \
      ::ver_check::VERSDATE
}

tik_default_set options,checkversion 1
tik_default_set options,versionchecktime 3600000
tik_default_set options,versiontimeout 10

namespace eval ver_check {
    namespace export load unload goOnline goOffline
    variable newtik [lindex $::VERSION end]
    variable x "None"
    variable error 0
    
}

proc ver_check::load {} {
    tik_image_load [list "newtik NewTiK.gif"]
    button .buddy.newtik -command "tik_show_url homepage http://tik.sourceforge.net"
    if {$::TIK(options,iconbuttons)} {
        .buddy.newtik configure -image newtik
    } else {
        .buddy.newtik configure -image "" -text [tik_str B_NEWTIK]
    }    
}

proc ver_check::goOnline {} {
    if {$::TIK(options,checkversion)} {
        after 20000 ver_check::wrapper
    } else {
        puts "ver_check:  Version Checking is turned off."
    }
}

proc ver_check::goOffline {} {
    after cancel $ver_check::x
}

proc ver_check::unload {} {
    unset ver_check::newtik
    unset ver_check::x
    destroy .buddy.newtik
}

proc ver_check::wrapper {} {
    if {[catch {http::geturl http://tik.sourceforge.net/version \
                                   -command ver_check::check \
                                   -timeout [expr $::TIK(options,versiontimeout) * 1000]}]} {
        set ver_check::error 1
        puts "ver_check: Error checking version.  Possible host unreachable."
    }
}

proc ver_check::check {token} {
    if {$ver_check::error} {
        return
    }
    
    upvar #0 $token state
    if {$state(status) == "ok"} {
        set ver_check::newtik [string trim $state(body)]
        if {[string is double $ver_check::newtik]} {
	    if {$ver_check::newtik > [lindex $::VERSION end]} {
	        balloonhelp .buddy.newtik [tik_str TOOLTIP_B_NEWTIK $ver_check::newtik]
	        pack .buddy.newtik -in .buddy.bottomF
	    }
        }
        set ver_check::x [after $::TIK(options,versionchecktime) http::geturl \
                                           http://tik.sourceforge.net/version \
                                           -command ver_check::check \
                                           -timeout [expr $::TIK(options,versiontimeout) * 1000]]
                                           
    } elseif {$state(status) == "reset"} {
        puts "ver_check:  User Reset"
        set ver_check::x "None"
    } elseif {$state(status) == "error"} {
        puts "ver_check:  Error!"
        set ver_check::x "None"
    }
    if {[info exists $token]} {
        http::cleanup $token
    }
}
