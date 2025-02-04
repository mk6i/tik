# util.tcl --
#
# This file contains general utility routines.
#
# $Revision: 1.8 $

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

# normalize --
#     Convert a string to just lowercase and
#     strip out all non letters or numbers.
#
# Arguments:
#     str - The string to normalize
#
proc normalize {str} {
    set str [string tolower $str]
    regsub -all {[^a-z0-9#]} $str "" str
    return $str
}

# roast_password --
#     Roast a password so it isn't sent in "clear text" over
#     the wire, although it is still trivial to decode.
#
# Arguments:
#     pass - The password to roast

proc roast_password {pass} {
    set CODE "Tic/Toc"
    set CODELEN [string length $CODE]
    set cpw "0x"

    set i 0
    foreach ch [split $pass ""] {
        binary scan [string index $CODE [expr $i % $CODELEN]] c bc
        binary scan $ch c bch
        append cpw [format "%02x" [expr $bch ^ $bc]]
        incr i
    }
    return $cpw
}

# encode -- 
#     Convert a string so it can be passed through TOC safely.
#
# Arguments:
#     str - the string to encode
proc encode {str} {
    append s {"}
    foreach i [split $str {}] {
        if { ($i == "\\") || \
             ($i == "\}") || \
             ($i == "\{") || \
             ($i == "\(") || \
             ($i == "\)") || \
             ($i == "\]") || \
             ($i == "\[") || \
             ($i == "\$") || \
             ($i == "\"")} {
            append s "\\"
        }
        append s $i
    }

    append s {"}
    return $s
}

# splitHTML -- 
#     Split a HTML message into a list of tags and text.
#
# Arguments:
#     str - The string to split
proc splitHTML {str} {
   while {1} {
       set e [string first "<" $str]
       if {$e == -1} {
           lappend results $str
           break
       }

       set t [string range $str $e end]
       if {![string match {<[/a-zA-Z!]*} $t]} {
           lappend results [string range $str 0 $e]
           set str [string range $str [expr $e+1] end]
           continue
       }

       lappend results [string range $str 0 [expr $e-1]]
       set str $t

       set e [string first ">" $str]
       set d [string first "<" [string range $str 1 end]]
       if {($d != -1) && ($e > $d)} {
           lappend results "[string range $str 0 [expr $d-1]]" 
           set str [string range $str $d end]
       } else {
            if {$e == -1} {
                lappend $str
                break
            }
           lappend results [string range $str 0 $e]
           set str [string range $str [expr $e+1] end]
       }
   }
   return $results
}

set UTIL(BASE64) {ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/}

# toBase64 -- 
#     Convert a binary string into base 64.  This might not be the 
#     most tcl efficient way to do it.
#
# Arguments:
#     input - The binary string to convert

proc toBase64 {input} {
    set len [string length $input]
    incr len -1
    set i 0

    while {$i <= $len} {
        binary scan $input "x${i}c" a
        incr i

        if { $i < $len} {
            binary scan $input "x${i}cc" b c

            append output [string index $::UTIL(BASE64) \
                [expr ($a>>2) & 0x3f]]
            append output [string index $::UTIL(BASE64) \
                [expr (($a<<4) & 0x30) + (($b >> 4) & 0x0f)]]
            append output [string index $::UTIL(BASE64) \
                [expr (($b<<2) & 0x3c) + (($c >> 6) & 0x03)]]
            append output [string index $::UTIL(BASE64) \
                [expr $c & 0x3f]]
        } elseif { $i <= $len} {
            binary scan $input "x${i}c" b

            append output [string index $::UTIL(BASE64) \
                [expr ($a>>2) & 0x3f]]
            append output [string index $::UTIL(BASE64) \
                [expr (($a<<4) & 0x30) + (($b >> 4) & 0x0f)]]
            append output [string index $::UTIL(BASE64) \
                [expr (($b<<2) & 0x3c)]]
            append output "="
        } else {
            append output [string index $::UTIL(BASE64) \
                [expr ($a>>2) & 0x3f]]
            append output [string index $::UTIL(BASE64) \
                [expr (($a<<4) & 0x30)]]
            append output "="
            append output "="
        }

        incr i 2
    }

    return $output
}

# fromBase64 -- 
#     Convert a ascii base 64 string into a binary string.  This might 
#     not be the most tcl efficient way to do it.
#
# Arguments:
#     input - The base 64 string to convert

proc fromBase64 {input} {
    set b1 0
    set b4 0
    set n 0

    foreach ch [split $input {}] {
        binary scan $ch "c" nch

        if {$nch >= 65 && $nch <= 90} {
            set b1 [expr $nch - 65] ;# A-Z
        } elseif {$nch >= 97 && $nch <= 122} {
            set b1 [expr $nch - 71] ;# a-z
        } elseif {$nch >= 48 && $nch <= 57} {
            set b1 [expr $nch + 4] ;# 0-9
        } elseif {$nch == 43} {
            set b1 62 ;# +
        } elseif {$nch == 43} {
            set b1 47 ;# /
        } elseif {$nch == 61} {
            if {$n == 3} {
                append output [binary format c [expr ($b4 >> 10) & 0xff]]
                append output [binary format c [expr ($b4 >> 2) & 0xff]]
            } elseif {$n == 2} {
                append output [binary format c [expr ($b4 >> 4) & 0xff]]
            }
            break
        }
        set b4 [expr ($b4 << 6) | ($b1 & 0xff)]
        incr n
        if {$n == 4} {
            append output [binary format c [expr ($b4 >> 16) & 0xff]]
            append output [binary format c [expr ($b4 >> 8) & 0xff]]
            append output [binary format c [expr $b4 & 0xff]]
            set n 0
        }
    }

    return $output
}

proc rot13 {str} {
    return [rotn 13 $str]
}

proc rotn {n str} {
    if {$n <= 0} {
        return $str
    }
    set abc "abcdefghijklmnopqrstuvwxyz"
    set ABC "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    set newline ""; # why the hell is this here?
    for {set i 0} {$i < [string length "$str"]} {incr i} {
        set char "[string index "$str" $i]"
        set j [string first "$char" "$abc"]
        if {$j != -1} {
            append rotated "[string index "$abc" [expr ($j+$n)%26]]"
            continue
        }
        set j [string first "$char" "$ABC"]
        if {$j != -1} {
            append rotated "[string index "$ABC" [expr ($j+$n)%26]]"
            continue
        }
        append rotated "$char"
    }
    return $rotated
}

proc lame {str} {
    set str [string tolower $str]
    set fromstr "abcdefghijklmnopqrstuvwxyz012358?!"
    set tostr   "48�D3FGH1JK1M�0�Q�57�VWX�Z����SB��"
    
    set newline "" ; # see rotn above
    for {set i 0} {$i < [string length "$str"]} {incr i} {
        set char "[string index "$str" $i]"
        set j [string first "$char" "$fromstr"]
        if {$j != -1} {
            append stupified "[string index "$tostr" $j]"
            if {[expr 2 * rand()] > 1} {
            }
            continue
        }
        append stupified "$char"
    }
    return $stupified
}

proc strrev {str} {
    set ist [split $str ""]
    set b "" 

    foreach element $ist {
        set b [linsert $b 0 $element]
    }
    return [join $b ""]
}
 
proc version_check {url} {
    ::http::config -accept "text/*"
    set token [::http::geturl $url -timeout [expr $::TIK(options,versiontimeout) * 1000]]
    upvar #0 $token state
    if {$state(status) == "ok"} {
	set newver [string trim $state(body)]
	if {[string is double $newver]} {
	    http::cleanup $token
	    return $newver
	} else {
	    http::cleanup $token
	    return $::VERSION
	}
    }
    elseif {$state(status) == "reset"} {puts  "User Reset"}
    elseif {$state(status) == "error"} {puts "Error!"}
}
