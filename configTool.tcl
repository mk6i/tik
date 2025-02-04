#! /bin/sh
# The next line is executed by /bin/sh, but not Tcl \
exec tclsh $0 ${1+"$@"}

# configTool.tcl --
#
# Signon to toc, send config from a file, and sign off.
# Currently this is a simple Tcl application, someday
# it might be a nice Tk app.  Also would be nice
# if it could handle importing Java .aim/AIM.cfg files.
#
# $Revision: 1.6 $

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

# Make sure we are in the tik directory and load the toc routines.
cd [file dirname $argv0]
catch {cd [file dirname [file readlink $argv0]]}
source toc.tcl

########### GLOBALS ###########

set TOCHOST  toc.oscar.aol.com
set TOCPORT  5190

set REVISION {configTool.tcl:$Revision: 1.6 $}

########### EVENTS ###########

proc put_signon {name data} {
    puts "Signed on."

    toc_init_done $name
    set file [open "$::FILENAME" "r"]
    set config [read $file]
    toc_set_config $name $config
    close $file

    puts "Sent Config from file '$::FILENAME'."

    after 1000
    toc_close $name

    puts "Quiting."
}

proc get_config {name data} {
    puts "Got config from TOC."

    set file [open "$::FILENAME" "w"]
    puts -nonewline $file $data
    close $file

    puts "Saved config to file '$::FILENAME'."

    after 1000
    toc_close $name

    puts "Quiting."
}

########### MAIN ###########

# Register which events we are interested in

if {($argc < 3) || ($argc > 4)} {
    puts "Usage: $argv0 (get|put) <username> <password> { <filename> }" 
    exit 1
}

set func [string tolower [lindex $argv 0]]
if {$func == "get"} {
    toc_register_func * CONFIG    get_config
} elseif {$func == "put"} {
    toc_register_func * SIGN_ON   put_signon
} else {
    puts "Usage: $argv0 (get|put) <username> <password> { <filename> }" 
    exit 1
}

set user [normalize [lindex $argv 1]]
set pass [lindex $argv 2]

if {$argc == 4} {
    set ::FILENAME [lindex $argv 3]
} else {
    set ::FILENAME $user
}

toc_open $user $TOCHOST $TOCPORT login.oscar.aol.com 5190 \
         $user $pass english $::REVISION

# Block forever and handle all the events
catch {vwait DONE}
