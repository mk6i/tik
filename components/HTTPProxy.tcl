# HTTP Proxy
#
# All packages must be inside a namespace with the
# same name as the file name.
#
# This package is capitalized (HTTPProxy) because H comes before h, and this
# package needs to have its goOnline function called before other packages'
#
# $Revision: 1.5 $
#
# Author: Brian Lalor <blalor@hcirisc.cs.binghamton.edu>
# HomePage: http://hcirisc.cs.binghamton.edu/~blalor/tik 


# Set VERSION and VERSDATE using the CVS tags.
namespace eval HTTPProxy {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK HTTPProxy package $Revision: 1.5 $} \
      ::HTTPProxy::VERSION
  regexp -- { .* } {:$Date: 2001/01/18 23:59:03 $} \
      ::HTTPProxy::VERSDATE
}

package require http 2.0

tik_default_set options,HTTPProxy,enable 0

namespace eval HTTPProxy {

    variable directhosts [list localhost 127.0.0.1 [info hostname]]
    variable info

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline proxyFilter

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        menu .httpProxyMenu -tearoff 0
        set HTTPProxy::info(menu) [tik_str P_HTTPPROXY_M]

        .generalMenu add cascade -label [tik_str P_HTTPPROXY_M] -menu .httpProxyMenu
        .httpProxyMenu add command -label [tik_str P_HTTPPROXY_M_CONFIG] -command HTTPProxy::config

        # enable/disable cascade menu
        menu .httpProxyEMenu -tearoff 0
        .httpProxyMenu add cascade -label [tik_str P_HTTPPROXY_M_E] -menu .httpProxyEMenu
        .httpProxyEMenu add radiobutton -label [tik_str B_DISABLED] -value 0 \
                -variable ::TIK(options,HTTPProxy,enable) \
                -command HTTPProxy::enableProxy
        .httpProxyEMenu add radiobutton -label [tik_str B_ENABLED] -value 1 \
                -variable ::TIK(options,HTTPProxy,enable) \
                -command HTTPProxy::enableProxy
    }

    proc enableProxy {} {
        if {$::TIK(options,HTTPProxy,enable)} {
            if { ((! [info exists ::HTTPPROXY]) || ([string length $::HTTPPROXY] == 0))
            ||   ((! [info exists ::HTTPPORT])  || ([string length $::HTTPPROXY] == 0)) } {
                set ::TIK(options,HTTPProxy,enable) 0
                error "HTTP ERROR: Please set HTTPPROXY and HTTPPORT\n"
            } else {
                http::config -proxyfilter HTTPProxy::proxyFilter
            }
        } else {
            http::config -proxyfilter http::ProxyRequired
        }
    }

    # All pacakges must have goOnline routine.  Called when the user signs
    # on, or if the user is already online when packages loaded.
    proc goOnline {} {
#        lappend HTTPProxy::directhosts $::TOC($::SELECTEDTOC,host)
        enableProxy
    }

    # All pacakges must have goOffline routine.  Called when the user signs
    # off.  NOT called when the package is unloaded.
    proc goOffline {} {
    }

    # All packages must have a unload routine.  This should remove everything 
    # the package set up.  This is called before load is called when reloading.
    proc unload {} {
        .generalMenu delete [tik_str P_HTTPPROXY_M]
        destroy .httpProxyEMenu
        destroy .httpProxyMenu
    }

    proc proxyFilter {host} {
        if { [lsearch $HTTPProxy::directhosts ${host}*] != -1 } {
            return [list "" ""]
        } else {
            return [list "$::HTTPPROXY" "$::HTTPPORT"]
        }
    }

    proc config {} {
        set w .proxyconfig
        destroy $w

        toplevel $w -class Tik
        wm title $w [tik_str P_HTTPPROXY_C_TITLE]
        wm iconname $w [tik_str P_HTTPPROXY_C_ICON]
        if {$::TIK(options,windowgroup)} {wm group $w .login}
        label $w.label -text [tik_str P_HTTPPROXY_C_WARN]

        frame $w.tochostF
        label $w.tochostF.l -text [tik_str P_HTTPPROXY_C_HOST] -width 15
        entry $w.tochostF.e -textvariable ::HTTPPROXY \
            -exportselection 0
        pack $w.tochostF.l $w.tochostF.e -side left

        frame $w.tocportF
        label $w.tocportF.l -text [tik_str P_HTTPPROXY_C_PORT] -width 15
        entry $w.tocportF.e -textvariable ::HTTPPORT \
            -exportselection 0
        pack $w.tocportF.l $w.tocportF.e -side left

        button $w.ok -text [tik_str B_OK] -command "destroy $w"
        pack $w.label $w.tochostF $w.tocportF $w.ok -side top
    }
}
