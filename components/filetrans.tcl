# File Transfer Package --
#
# Support AIM File Transfer
#             
# All packages must be inside a namespace with the
# same name as the file name.

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


# Set VERSION and VERSDATE using the CVS tags.
namespace eval filetrans {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK File Transfer package $Revision: 1.6 $} \
      ::filetrans::VERSION
  regexp -- { .* } {:$Date: 2001/04/02 18:17:26 $} \
      ::filetrans::VERSDATE
}

namespace eval filetrans {

    variable info

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        set filetrans::info(uuid) 09461343-4C7F-11D1-8222-444553540000

        tik_add_capability $filetrans::info(uuid)
        toc_register_func * RVOUS_PROPOSE  filetrans::RVOUS_PROPOSE

#        destroy .filetransMenu
#        menu .filetransMenu -tearoff 0
#        .toolsMenu add cascade -label [tik_str P_FILETRANS_M] -menu .filetransMenu
#        .filetransMenu add command -label [tik_str P_FILETRANS_M_SEND] \
#                              -command filetrans::send

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
        toc_unregister_func * RVOUS_PROPOSE  filetrans::RVOUS_PROPOSE
#        .toolsMenu delete [tik_str P_FILETRANS_M]
#        destroy .filetransMenu
        tik_remove_capability $filetrans::info(uuid)
    }

    proc RVOUS_PROPOSE {connName user uuid cookie seq rip pip vip port tlvs} {
        # Check to see if we handle this UUID
        if {$uuid != $filetrans::info(uuid)} {
            return
        }

        set fTtlv "ABC"
        for {set i 0} {$i < [llength $tlvs]} {incr i 2} {
            set tag [lindex $tlvs $i]
            #puts "$i tag = >$tag<"
            if {$tag == "10001"} {
                set fTtlv [lindex $tlvs [expr $i + 1]]
                break;
            }
        }
        if {"$fTtlv" == "ABC"} {
            return
        }

        binary scan $fTtlv "SSIa*" subtype files totalsize name 
        #puts "subtype = $subtype files=$files totalsize=$totalsize name=$name"

        if {$subtype != 1} {
            tk_messageBox -type ok -message [tik_str P_FILETRANS_E_UKNTRAN $user]
            return
        }

        #puts "port = $port"
        #puts "name = $name"

#
# hack applied by fuzzface00
#
# Version 1.12.1 - Clean backslashes and colons out of filenames
# to prevent errors in the dialog box. 
#
regsub -all -- "\\\\" "$name" "/" xname
regsub -all -- ":" "$xname" "/" xname

        if {$vip != $pip} {
            set msg [tik_str P_FILETRANS_A_BAD $user $totalsize $xname]
        } else {
            set msg [tik_str P_FILETRANS_A_GOOD $user $totalsize $xname]
        }
#end hack

        set w .filetransA$user

        set filetrans::info($cookie,w) $w
        set filetrans::info($cookie,name) $name
        set filetrans::info($cookie,user) $user
        set filetrans::info($cookie,pip) $pip
        set filetrans::info($cookie,port) $port

        toplevel $w -class Tik
        wm title $w [tik_str P_FILETRANS_A_TITLE $name]
        wm iconname $w [tik_str P_FILETRANS_A_ICON $name]
        if {$::TIK(options,windowgroup)} {wm group $w .login}

        bind $w <Motion> tik_non_idle_event

        label $w.msg -text $msg

        frame $w.buttons
        button $w.accept -text Accept -command "filetrans::accept $cookie"
        bind $w <Control-a> "filetrans::accept $cookie"
        button $w.im -text IM -command [list tik_create_iim $::NSCREENNAME $user]
        bind $w <Control-i> [list tik_create_iim $::NSCREENNAME $user]
        button $w.info -text Info -command [list toc_get_info $::NSCREENNAME $user]
        bind $w <Control-l> [list toc_get_info $::NSCREENNAME $user]
        button $w.warn -text Warn -command [list toc_evil $::NSCREENNAME $user F]
        bind $w <Control-W> [list toc_evil $::NSCREENNAME $user T]
        button $w.cancel -text Cancel -command [list filetrans::cancel $cookie]
        bind $w <Control-period> [list filetrans::cancel $cookie]
        pack $w.accept $w.info $w.warn $w.cancel -in $w.buttons -side left -padx 2m

        pack $w.msg $w.buttons
    }

    proc accept {cookie} {
        destroy $filetrans::info($cookie,w)

        set initial $filetrans::info($cookie,name)
        regsub -all -- ":" $initial "/" initial
        regsub -all -- "\\\\" $initial "/" initial
        set initial [file tail $initial]

        set fn [tk_getSaveFile -title [tik_str P_FILETRANS_A_SAVE] \
            -initialfile $initial]
        set filetrans::info($cookie,fn) $fn

        toc_rvous_accept $::NSCREENNAME $filetrans::info($cookie,user) \
            $cookie $filetrans::info(uuid) ""
#           [list 
#           2 [toBase64 $filetrans::info($cookie,pip)]\
#           5 [toBase64 $filetrans::info($cookie,port)]]

        if {$fn != ""} {
            set ofd [open $fn w]
            set filetrans::info($cookie,ofd) $ofd
            fconfigure $ofd -translation binary
            set sfd [socket $filetrans::info($cookie,pip) $filetrans::info($cookie,port)]
            set filetrans::info($cookie,sfd) $sfd
            fconfigure $sfd -translation binary
            fileevent $sfd readable [list filetrans::receive_header $cookie]
        }
    }

    proc cancel {cookie} {
        destroy $filetrans::info($cookie,w)
        toc_rvous_cancel $::NSCREENNAME $filetrans::info($cookie,user) \
            $cookie $filetrans::info(uuid) ""
    }

    proc receive_header {cookie} {
        set fd $filetrans::info($cookie,sfd)

        set header [read $fd 6]
        binary scan $header "a4S" bMagic wHdrLen

        set header [read $fd [expr $wHdrLen - 6]]
        binary scan $header "Sa8SSSSSSIIIIIIIIIIa32ccca69a16SSa*" wHdrType \
            bCookie wEncryption wCompression wTotalNumFiles wNumFilesLeft \
            wTotalNumParts wNumPartsLeft dwTotalFilesize dwFilesize \
            dwModifiedTime dwChecksum dwResForkRecvdChecksum dwResForkSize \
            dwCreationTime dwResForkChecksum dwNumRecvd dwRecvdChecksum \
            bIDstring bFlags bListNameOffset bListSizeOffset bDummy \
            bMacFileInfo wNameEncoding wNameLanguage bName

        set bCookie [fromBase64 $cookie]

        foreach i {bMagic wHdrLen wHdrType bCookie \
            wEncryption wCompression wTotalNumFiles wNumFilesLeft \
            wTotalNumParts wNumPartsLeft dwTotalFilesize dwFilesize \
            dwModifiedTime dwChecksum dwResForkRecvdChecksum dwResForkSize \
            dwCreationTime dwResForkChecksum dwNumRecvd dwRecvdChecksum \
            bIDstring bFlags bListNameOffset bListSizeOffset bDummy \
            bMacFileInfo wNameEncoding wNameLanguage bName} {

            set filetrans::info($cookie,$i) [set $i]
           # puts "$i = >[set $i]< ([string length [set $i]])"
        }


        # We don't want any stinking extra Mac crap. :)
        set wTotalNumParts 1
        set wNumPartsLeft 1
        set dwResForkSize 0

        # Save all the fields.
        set filetrans::info($cookie,need) $dwFilesize
        foreach i {bMagic wHdrLen wHdrType bCookie \
            wEncryption wCompression wTotalNumFiles wNumFilesLeft \
            wTotalNumParts wNumPartsLeft dwTotalFilesize dwFilesize \
            dwModifiedTime dwChecksum dwResForkRecvdChecksum dwResForkSize \
            dwCreationTime dwResForkChecksum dwNumRecvd dwRecvdChecksum \
            bIDstring bFlags bListNameOffset bListSizeOffset bDummy \
            bMacFileInfo wNameEncoding wNameLanguage bName} {

            set filetrans::info($cookie,$i) [set $i]
        }

        if {$wHdrType != 0x0101} {
            puts "Header type we don't know."
            return
        }

        if {$wEncryption != 0} {
            puts "We don't support encryption!"
            filetrans::cancel $cookie
            return
        }

        if {$wCompression != 0} {
            puts "We don't support compression!"
            filetrans::cancel $cookie
            return
        }

        # Send back header
        set h [binary format "Sa8SSSSSSIIIIIIIIIIa32ccca69a16SSa*" 0x0202 \
            $bCookie 0 0 $wTotalNumFiles $wNumFilesLeft $wTotalNumParts \
            $wNumPartsLeft $dwTotalFilesize $dwFilesize $dwModifiedTime \
            $dwChecksum $dwResForkRecvdChecksum $dwResForkSize \
            $dwCreationTime $dwResForkChecksum $dwNumRecvd $dwRecvdChecksum \
            "TIK" $bFlags $bListNameOffset $bListSizeOffset $bDummy \
            $bMacFileInfo $wNameEncoding $wNameLanguage $bName]

        set hh [binary format "a4S" $bMagic [expr [string length $h] + 6]]
        puts -nonewline $fd $hh
        puts -nonewline $fd $h
        flush $fd

        fconfigure $fd -blocking false -translation binary
	fileevent $fd readable {}
	set ::filetrans::info($cookie,start) [clock seconds]
	::filetrans::receive_file $cookie $fd $::filetrans::info($cookie,ofd) 0
    }

    proc scalePie {window basex basey} {
	set winx [winfo width $window]
	set winy [winfo height $window]
	if ![info exists ::filetrans::last($window)] {
	    set ::filetrans::last($window) [list $basex $basey]
	}
	foreach {basex basey} $::filetrans::last($window) {}
	set ::filetrans::last($window) [list $winx $winy]
	$window scale all 0 0 [expr {double($winx)/$basex}] \
            [expr {double($winy)/$basey}]
    }

    proc progressMeter {cookie} {
	set base .progress$cookie
	if ![winfo exists $base] {
	    toplevel $base
	    pack [label $base.label -width 40 -anchor w -justify left] -expand 0 -fill y -side right
	    pack [canvas $base.prog -width 84 -height 84 -borderwidth 1] -expand 1 -fill both -side right
	    $base.prog create oval 4 4 80 80 -width 0 -fill darkgrey -outline darkgrey -tags all
	    $base.prog create arc 2 2 78 78 -width 0 -start 90 -style pieslice -outline darkgrey -tags all
	    bind $base.prog <Destroy> [list ::filetrans::cancel $cookie]
            set ::filetrans::info($cookie,lastupdate) 0
	    bind $base.prog <Configure> "::filetrans::scalePie %W 84 84"
	}

        # Don't update more then once a second.
        set curtime [clock seconds]
        if {$curtime == $::filetrans::info($cookie,lastupdate)} {
            return
        }
        set ::filetrans::info($cookie,lastupdate) $curtime
	set fn $::filetrans::info($cookie,fn)
	set type get
	set send $::filetrans::info($cookie,dwFilesize)
	set rebyte $::filetrans::info($cookie,need)
	set sent [expr {$send - $rebyte}]
	set nick $::filetrans::info($cookie,user)
	set elapsed [expr {$curtime - $::filetrans::info($cookie,start)}]
	set speed [expr {double($sent)/($elapsed + 1)}]
	set to [expr {$type == "send" ? "to" : "from"}]
	set left [expr {round((double($elapsed)/($sent+1)) * $send) - $elapsed}]
	set tail [file tail $fn]
	set spc [expr {round(($sent/double($send))*100)}]
	set lpc [expr {round(($rebyte/double($send))*100)}]
	set leftformat  [::filetrans::ftime $left]
	set sentformat  [::filetrans::filesize $sent %.2f]
	set speedformat [::filetrans::filesize $speed %.1f]
	set progformat  [::filetrans::filesize $send %.2f]
	set elpformat   [::filetrans::ftime $elapsed]
	$base.label configure -text \
            "File: $tail $to $nick\nBytes Remaining: $rebyte ($lpc%)\nTime Remaining: $leftformat\nTransferred: $sentformat/$progformat\nTotal Time: $elpformat\nSpeed: $speedformat/sec"
	
	wm title $base "$spc% of $tail from $nick ($leftformat remains)"
	set id 2
	set c [$base.prog coords $id]
	if ![catch {expr double($sent) / $send} ex] {
	    if [catch {expr {$ex * 360}} m] {
                set m [expr {[$base.prog itemcget $id -extent] +10}]
            }
	    set inc [expr {int($ex * 254)}]
	    set color [format #00%.2x%.2x $inc $inc]
	    if {$m > 359} {
                set m 359.99999999
            }
	    $base.prog itemconfigure $id -fill $color -extent [expr {-($m)}]
	}
	update
    }

    proc ftime {int} {
	return [format {%.2d:%.2d:%.2d} [expr {$int/3600}] \
            [expr {($int/60)%60}] [expr {$int%60}]]
    }

    proc filesize {int {format %s}} {
	set int [expr {double($int)}]
	if {$int > 1000000000} {
	    set int [expr {$int/1073741824}]
	    set type gbytes ;#hah
	} elseif {$int > 1000000} {
	    set int [expr {$int/1048576}]
	    set type mbytes
	} elseif {$int > 1000} {
	    set int [expr {$int/1024}]
	    set type kbytes
	} else {
	    set type bytes
	}
	return "[format $format $int] $type"
    }

    proc receive_file {cookie from to datalen {error ""}} {
#        puts "receive_file: $filetrans::info($cookie,need)";
        set fd $filetrans::info($cookie,sfd)

        if {[eof $fd] || $error != ""} {
           puts "FILETRANS SOCKET ERROR: $fd / $error";
           close $fd
        }

#        puts "got len = $datalen"
	incr filetrans::info($cookie,need) -$datalen
	if [catch {::filetrans::progressMeter $cookie} x] {
            tk_messageBox -title $::errorCode -message $x\n$::errorInfo
        }

        if {$filetrans::info($cookie,need) == 0} {
            # Make sure the screen is updated
            set ::filetrans::info($cookie,lastupdate) 0
            catch {::filetrans::progressMeter $cookie}

            # Remove cancel binding
	    bind .progress$cookie <Destroy> ""

            close $filetrans::info($cookie,ofd)

            # Set local var from fields
            foreach i {bMagic wHdrLen wHdrType bCookie \
                wEncryption wCompression wTotalNumFiles wNumFilesLeft \
                wTotalNumParts wNumPartsLeft dwTotalFilesize dwFilesize \
                dwModifiedTime dwChecksum dwResForkRecvdChecksum dwResForkSize \
                dwCreationTime dwResForkChecksum dwNumRecvd dwRecvdChecksum \
                bIDstring bFlags bListNameOffset bListSizeOffset bDummy \
                bMacFileInfo wNameEncoding wNameLanguage bName} {

                set $i $filetrans::info($cookie,$i)
            }

            set dwNumRecvd $dwFilesize
            set wNumPartsLeft 0
            set wNumFilesLeft 0
            set dwRecvdChecksum $dwChecksum

            # Send back that we got the file.
            set h [binary format "Sa8SSSSSSIIIIIIIIIIa32ccca69a16SSa*" 0x0204 \
                $bCookie 0 0 $wTotalNumFiles $wNumFilesLeft $wTotalNumParts \
                $wNumPartsLeft $dwTotalFilesize $dwFilesize $dwModifiedTime \
                $dwChecksum $dwResForkRecvdChecksum $dwResForkSize \
                $dwCreationTime $dwResForkChecksum $dwNumRecvd \
                $dwRecvdChecksum "TIK" $bFlags $bListNameOffset \
                $bListSizeOffset $bDummy $bMacFileInfo $wNameEncoding \
                $wNameLanguage $bName]

            set hh [binary format "a4S" $bMagic [expr [string length $h] + 6]]
            puts -nonewline $fd $hh
            puts -nonewline $fd $h
            catch {close $fd}
        } else {
            set needs $filetrans::info($cookie,need)
	    set amount [expr {$needs > 1024 ? 1024 : $needs}]
	    eval [list fcopy $from $to -command [list ::filetrans::receive_file $cookie $from $to]] -size $amount
	}
    }
}
