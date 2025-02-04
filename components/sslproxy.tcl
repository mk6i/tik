# SSLProxy Proxy
#
# Provide access the TOC server using a HTTP proxy that supports
# the CONNECT method
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
namespace eval sslproxy {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK SSLProxy package $Revision: 1.4 $} \
      ::sslproxy::VERSION
  regexp -- { .* } {:$Date: 2000/07/13 08:20:29 $} \
      ::sslproxy::VERSDATE
}

if {![info exists ::SSLNEEDAUTH]} {
    set ::SSLNEEDAUTH 0
}

namespace eval sslproxy {

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        tik_register_proxy "SSL/HTTP" sslproxy::connect sslproxy::config
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
        tik_unregister_proxy "SSL/HTTP"
    }

    # connect --
    #     Connect via socks proxy.
    #
    # Arguments:
    #     host  - The ip of the host we are connecting to through socks
    #     port  - The port we are connecting to through socks
    #     sname - Our user name, since some proxies might need it.

    proc connect { host port sname } {
        if { ! [info exists ::SSLHOST] || ! [info exists ::SSLPORT]} {
            error "SSL ERROR: Please set SSLHOST and SSLPORT\n"
        }

        set fd [socket $::SSLHOST $::SSLPORT]
        fconfigure $fd -translation binary
        puts -nonewline $fd "CONNECT $host:$port HTTP/1.0\r\n"
        if {$::SSLNEEDAUTH} {
            if { ! [info exists ::SSLUSER] || ! [info exists ::SSLPASS]} {
                error "SSL ERROR: Please set SSLUSER and SSLPASS\n"
            }
            puts -nonewline $fd \
                "Proxy-Authorization: Basic [toBase64 "$::SSLUSER:$::SSLPASS"]\r\n"
        }
        puts -nonewline $fd "\r\n"
        flush $fd

        set firstline [string trim [gets $fd]]
        puts "SSL: $firstline"
        while {1} {
            set line [string trim [gets $fd]]
            if {$line == ""} {
                break;
            }
            puts "SSL: $line"
        }

        if {[string first "200" $firstline] == -1} {
            error "Some kind of SSL error, check the output."
            return 0
        }
        return $fd
    }

    proc config {} {
        set w .proxyconfig
        destroy $w

        toplevel $w -class Tik
        wm title $w "Proxy Config: SSL/HTTP Connection"
        wm iconname $w "Proxy Config"
        if {$::TIK(options,windowgroup)} {wm group $w .login}
        label $w.label -text "Change your tikrc to make permanent.\n\
             SSL Proxies usually require the TOC Port\n\
             to be set to 443 or 563.\n"

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


        frame $w.sslhostF
        label $w.sslhostF.l -text "SSL Host: " -width 15
        entry $w.sslhostF.e -textvariable ::SSLHOST \
            -exportselection 0
        pack $w.sslhostF.l $w.sslhostF.e -side left

        frame $w.sslportF
        label $w.sslportF.l -text "SSL Port: " -width 15
        entry $w.sslportF.e -textvariable ::SSLPORT \
            -exportselection 0
        pack $w.sslportF.l $w.sslportF.e -side left

        checkbutton $w.sslup -text "Use SSL Basic Authorization" \
             -variable ::SSLNEEDAUTH

        frame $w.ssluserF
        label $w.ssluserF.l -text "SSL User: " -width 15
        entry $w.ssluserF.e -textvariable ::SSLUSER \
            -exportselection 0
        pack $w.ssluserF.l $w.ssluserF.e -side left

        frame $w.sslpassF
        label $w.sslpassF.l -text "SSL Pass: " -width 15
        entry $w.sslpassF.e -textvariable ::SSLPASS \
            -exportselection 0 -show "*"
        pack $w.sslpassF.l $w.sslpassF.e -side left

        button $w.ok -text "Ok" -command "destroy $w"
        pack $w.label $w.tochostF $w.tocportF \
             $w.sslhostF $w.sslportF $w.sslup $w.ssluserF \
             $w.sslpassF $w.ok -side top
    }
}
