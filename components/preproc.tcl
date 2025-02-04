# Preprocessor 
#
# General message munging component.
#
# $Revision: 1.3 $

namespace eval preproc {
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Preprocessor component $Revision: 1.3 $} \
      ::preproc::VERSION
  regexp -- { .* } {:$Date: 2000/11/04 03:03:22 $} \
      ::preproc::VERSDATE
}

tik_default_set options,usepreproc      1 ;# Use preprocessing on messages

namespace eval preproc {

    variable info
    variable filters

    namespace export load unload goOnline goOffline  

    proc load {} {
        tik_register_filter * IM_IN preproc::IM_IN
        tik_register_filter * IM_OUT preproc::IM_OUT
        tik_register_filter * CHAT_IN preproc::CHAT_IN
        tik_register_filter * CHAT_OUT preproc::CHAT_OUT

        menu .preprocMenu -tearoff 0
        .confMenu add cascade -label [tik_str M_PREPROC] -menu .preprocMenu
        .preprocMenu add checkbutton -label [tik_str M_PREPROC_USE] \
            -onvalue 1 -offvalue 0 -variable ::TIK(options,usepreproc)
    }

    proc unload {} {
        tik_unregister_filter * IM_IN preproc::IM_IN
        tik_unregister_filter * IM_OUT preproc::IM_OUT
        tik_unregister_filter * CHAT_IN preproc::CHAT_IN
        tik_unregister_filter * CHAT_OUT preproc::CHAT_OUT
        .confMenu delete [tik_str M_PREPROC]
        destroy .preprocMenu
        unregister_all *
    }

    proc goOnline {} {
    }

    proc goOffline {} {
    }

    # preproc::register
    #    connName = $::SCREENNAME or *
    #    type     = OUT, IN, IM_IN, IM_OUT, CHAT_IN, CHAT_OUT
    #    code     = name of filter function
    #    comments = optional comments explaining filter

    proc register {connName type code {comments ""}} {
        if {$connName != "*"} {
            set connName [normalize $connName]
        }
        if {$type == "OUT"} {
            lappend preproc::filters($connName,IM_OUT) $code
            lappend preproc::filters($connName,CHAT_OUT) $code
        } elseif {$type == "IN"} {
            lappend preproc::filters($connName,IM_IN) $code
            lappend preproc::filters($connName,CHAT_IN) $code
        } else {
            lappend preproc::filters($connName,$type) $code
        }

        if {$comments != ""} {
            set preproc::filters($connName,$type,$code) $comments
        }
    }

    proc unregister {connName type code} {
        if {$connName != "*"} {
            set connName [normalize $connName]
        }
        
        set preproc::filters($connName,$type,$code) ""

        set i [lsearch -exact $preproc::filters($connName,$type) $code]
        if {$i != -1} {
            set preproc::filters($connName,$type) \
                [lreplace $preproc::filters($connName,$type) $i $i]
        }
    }

    proc unregister_all {connName} {
        if {$connName != "*"} {
            set connName [normalize $connName]
        } else {
            set connName "\\\*"
        }

        foreach i [array names preproc::filters "$connName,*"] {
            unset filters($i)
        }
    }

    proc getFilterList {connName func} {
        if {[catch {set all $preproc::filters(*,$func)}] != 0} {
            set all [list]
        }
        if {![catch {set l $preproc::filters($connName,$func)}] } {
            return [concat $all $l]
        }
        return $all
    }

    proc filter_msg {connName type msg args} {
        set funcs [getFilterList $connName $type]
        foreach munge $funcs {
            set msg [$munge $msg $args]
        }
        return $msg
    }

    proc IM_IN {connName msg args} {
        set xmsg [string trim $msg]
        if {!$::TIK(options,usepreproc)} {
            return $xmsg
        }
        return [filter_msg $connName IM_IN $xmsg $args]
    }

    proc IM_OUT {connName msg args} {
        set xmsg [string trim $msg]
        if {!$::TIK(options,usepreproc)} {
            return $xmsg
        }
        return [filter_msg $connName IM_OUT $xmsg $args]
    }

    proc CHAT_IN {connName msg id args} {
        set xmsg [string trim $msg]
        if {!$::TIK(options,usepreproc)} {
            return $xmsg
        } 
        return [filter_msg $connName CHAT_IN $xmsg $id $args]
    }

    proc CHAT_OUT {connName msg id args} {
        set xmsg [string trim $msg]
        if {!$::TIK(options,usepreproc)} {
            return $xmsg
        }
        return [filter_msg $connName CHAT_OUT $xmsg $id $args]
    }
}

proc filter_default {xmsg id args} {
    set msg [string trim $xmsg]
    if {!$::TIK(options,usepreproc)} {
	    return $msg
    }
    if {[regexp -nocase -- {(/[a-z0-9]+)} $msg]} {
        if {[info exists ::TIK(bcastavail)]} {
            if {[regexp -nocase -- {^/b.*cast\s+(.+)$} $msg match mymsg]} {
                bcast::broadcast $mymsg
	        set msg ""
            }
        } 
        if {[regexp -nocase -- {^/(lit|literal|pre)\s(.+)$} $msg match match mymsg]} {
            return $mymsg
        } elseif {[regexp -nocase -- {^/msg\s+([[:alnum:]]+)\s+(.+)$} $msg match nick mymsg]} {
            toc_send_im $::NSCREENNAME [normalize $nick] $mymsg
            set msg ""
        } elseif {[regexp -nocase -- {^/eval\s+(.+)$} $msg match mymsg]} {
            eval $mymsg
            set msg ""
        } elseif {[regexp -nocase -- {^/(exec|local)\s+(.+)$} $msg match match mymsg]} {
            catch {eval exec $mymsg} msg
        } elseif {[regexp -nocase -- {^/rot([0-9]*)\s+(.+)$} $msg match n mymsg]} {
            if {[string length $n] == 0} {
                set msg [rot13 $mymsg]
            } else {
                set msg [rotn $n $mymsg]
            }
        } elseif {[regexp -nocase -- {^/nick\s+(.+)$} $msg match mymsg]} {
            toc_format_nickname $::NSCREENNAME $mymsg
            set msg ""
        } elseif {($id != -1) && [regexp -nocase -- {^/ignore\s+(.+)$} $msg match mymsg]} {
            p_tik_ignore $id $mymsg
            set msg ""
        } elseif {[regexp -nocase -- {^/ignore\s+.+$} $msg]} {
            set msg ""
        } elseif {[regexp -nocase -- {^/(crazy|eleet|lame)\s+(.+)$} $msg match match mymsg]} {
            set msg [lame $mymsg]
        } elseif {[regexp -nocase -- {^/(bw|rev)\s+(.+)$} $msg match match mymsg]} {
            set msg [strrev $mymsg]
        } elseif {[regexp -nocase -- {^/passw(or)?d\s+([^\s]+)\s+([^\s]+)$} $msg match match oldp newp]} {
            toc_change_passwd $::NSCREENNAME $oldp $newp
            set msg ""
#            } elseif {[regexp -nocase -- {^/warn[ 	]+.+$} $msg]} {
#               regsub -nocase -- {^/warn[ 	]+(.+)$} $msg {\1} mymsg
#                if { $id != -1 } {
#                    toc_chat_evil $::NSCREENNAME $id [normalize $mymsg] "anon"
#                }
#                set msg ""
        } elseif {[regexp -nocase -- {^/away\s+(.+)$} $msg match awaymsg]} {
            catch {away::set_away $awaymsg}
            set msg ""
        } elseif {[regexp -nocase -- {^/(away|back)$} $msg]} {
            catch {away::back}
            set msg ""
        } elseif {[regexp -nocase -- {^/(fortune|yow)$} $msg]} {
            set msg [eval exec $::TIK(options,fortuneprog)]
            return $msg
        } elseif {[regexp -nocase -- {^/(fortune|yow)\s+(.+)$} $msg match match mymsg]} { 
            set msg [eval exec $::TIK(options,fortuneprog) $mymsg] 
            return $msg
        } elseif {[regexp -nocase -- {^/(lookup|dict|webster|word|define)\s+(.+)$} $msg match match mymsg]} {
            set msg [eval exec $::TIK(options,websterprog) $mymsg]
            return $msg
        } elseif {[regexp -nocase -- {^/url\s+([^\s]+)\s*([^\s]*)} $msg match url anchor]} {
            if {[string length $anchor] == 0} {
                set msg "<a href=\"$url\">$url</a>"
            } else {
                set msg "<a href=\"$url\">$anchor</a>"
            }
            return $msg
        } elseif {[regexp -nocase -- {^/exit$} $msg]} {
            tik_signoff
            exit
        } elseif {[regexp -nocase -- {^/brb$} $msg]} {
            catch {away::set_away "brb"}
            set msg ""
        } elseif {[regexp -nocase -- {^/signoff} $msg]} {
            tik_signoff
            set msg ""
        } 
        regsub -nocase -all -- {^/time|(\s)/time} $msg "\\1[clock format [clock seconds] -format "%H:%M:%S"]" msg
        regsub -nocase -all -- {^/date|(\s)/date} $msg "\\1[clock format [clock seconds] -format "%b %d, %Y"]" msg
        regsub -nocase -all -- {^/day|(\s)/day} $msg "\\1[clock format [clock seconds] -format "%A"]" msg
        regsub -nocase -- {^/me} $msg "<-" msg
        regsub -nocase -all -- {(\s)/me} $msg "\\1$::SCREENNAME" msg
    }
    set temp [list]
    foreach line [split $msg \n] {
        set templine [list]
        foreach c [split $line] {
            if {![regexp -nocase -- {href} $c]} {
	        regsub -nocase -- {^(mailto|http|https|ftp|gopher|news|file|rlogin|telnet|nntp|tn3270)(:[^\s]+)} $c {<a href="\1\2">\1\2</a>} c
	        regsub -nocase -- {^(ftp|news|gopher)\.([-[:alnum:]]+\.)+(com|org|net|edu|gov|mil|[[:alpha:]]{2})(\/.*)?$} $c {<a href="\1://\0">\0</a>} c
	        regsub -nocase -- {^(ftp|news|gopher)\.([-[:alnum:]]+\.)+(com|org|net|edu|gov|mil|[[:alpha:]]{2})([^\w])} $c {<a href="\1://\1.\2\3">\1.\2\3</a>\4} c
	        regsub -nocase -- {^([-[:alnum:]]+\.)+(com|org|net|edu|gov|mil|[[:alpha:]]{2})(\/.*)?$} $c {<a href="http://\0">\0</a>} c
	        regsub -nocase -- {^(([-[:alnum:]]+\.)+)(com|org|net|edu|gov|mil|[[:alpha:]]{2})([^\w])} $c {<a href="http://\1\3">\1\3</a>\4} c
	        regsub -- {^[-\w\.]+\@[-[:alnum:]\.]+} $c {<a href="mailto:\0">\0</a>} c
            }
            regsub -all -- {\\n} $c "<br>" c
            lappend templine $c
        }
        set templine [join $templine]
        lappend temp $templine
    }
    set msg [join $temp \n]
    return $msg
}

# set filter_default_comments {
# These are the original default preprocessor filters
# }

# preproc::register * OUT filter_default $filter_default_comments
preproc::register * OUT filter_default

