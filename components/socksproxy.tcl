# Socks Proxy
#
# Provide access to the TOC server through a SOCKS v4 proxy.
#
# $Revision: 1.4 $

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
namespace eval socksproxy {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK SOCKS Proxy package $Revision: 1.4 $} \
      ::socksproxy::VERSION
  regexp -- { .* } {:$Date: 2000/07/13 08:20:29 $} \
      ::socksproxy::VERSDATE
}

namespace eval socksproxy {

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        tik_register_proxy Socks socksproxy::connect socksproxy::config
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
        tik_unregister_proxy Socks
    }

    # connect --
    #     Connect via socks proxy.
    #
    # Arguments:
    #     host  - The ip of the host we are connecting to through socks
    #     port  - The port we are connecting to through socks
    #     sname - Our user name, since some proxies might need it.

    proc connect { host port sname } {
        if { ! [info exists ::SOCKSHOST] || ! [info exists ::SOCKSPORT]} {
            error "SOCKS ERROR: Please set SOCKSHOST and SOCKSPORT\n"
        }

        if { "$host" == "10.10.10.10"} {
            error "SOCKS ERROR: You must set TOC(production,host) to\
                   the IP address of toc.oscar.aol.com\n"
        }

        # Check to make sure the toc host is an ip address.
        set match [scan $host "%d.%d.%d.%d" a b c d]

        if { $match != "4" } {
            error "SOCKS ERROR: TOC Host must be IP address, not name\n"
        }

        set fd [socket $::SOCKSHOST $::SOCKSPORT]
        set data [binary format "ccScccca*c" 4 1 $port $a $b $c $d $sname 0]
        puts -nonewline $fd $data
        flush $fd

        set response [read $fd 8]
        binary scan $response "ccSI" v r port ip

        if { $r != "90"} {
            puts "Request failed code : $r"
            if { $r == "91" } {
                error "The SOCKS proxy denied your request,\
                      this is not a bug with TiK!\n\
                      TiK only supports SOCKS v4, consult\
                      your network administrator for more info."
            } else {
                error "Unknown SOCKS error.  This is not a bug with TiK!\
                       Consult your network administrator for more info."
            }
            return 0
        } 

        return $fd
    }

    proc config {} {
        set w .proxyconfig
        destroy $w

        toplevel $w -class Tik
        wm title $w "Proxy Config: SOCKS Connection"
        wm iconname $w "Proxy Config"
        if {$::TIK(options,windowgroup)} {wm group $w .login}
        label $w.label -text "Change your tikrc to make permanent.\n\
             The TOC servers listen on ALL ports.\n\
             TOC Host MUST be an IP address for SOCKS.\n"

        frame $w.tochostF
        label $w.tochostF.l -text "TOC Host: " -width 15
        entry $w.tochostF.e -textvariable ::TOC($::SELECTEDTOC,host) \
            -exportselection 0
        pack $w.tochostF.l $w.tochostF.e -side left

        frame $w.tocportF
        label $w.tocportF.l -text "TOC Port: " -width 15
        entry $w.tocportF.e -textvariable ::TOC($::SELECTEDTOC,port) \
            -exportselection 0
        pack $w.tocportF.l $w.tocportF.e -side left

        frame $w.sockshostF
        label $w.sockshostF.l -text "SOCKS Host: " -width 15
        entry $w.sockshostF.e -textvariable ::SOCKSHOST \
            -exportselection 0
        pack $w.sockshostF.l $w.sockshostF.e -side left

        frame $w.socksportF
        label $w.socksportF.l -text "SOCKS Port: " -width 15
        entry $w.socksportF.e -textvariable ::SOCKSPORT \
            -exportselection 0
        pack $w.socksportF.l $w.socksportF.e -side left

        button $w.ok -text "Ok" -command "destroy $w"
        pack $w.label $w.tochostF $w.tocportF \
             $w.sockshostF $w.socksportF $w.ok -side top
    }
}
