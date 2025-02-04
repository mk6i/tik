# CALLBACKS
#######################################################
# This routines are callbacks for buttons and menu selections.

# tik_get_info --
#     Request information on a person
#
# Arguments:
#     name   - SFLAP connection
#     person - get info on

proc tik_get_info {name person} {
    if { $person == "" } {
        tk_messageBox -type ok -message [tik_str E_NEEDINFO]
    } else {
        toc_get_info $name $person
    }
}

# tik_signon --
#     Called when then Signon button is pressed.  This starts the
#     signon process.

proc tik_signon {} {
    if {$::TIK(online)} {
        puts "tik_signon called when already online!"
        return
    }

    # Don't try and reconnect when trying to signon
    set ::TIK(reconnect) 0

    if {[string length [normalize $::SCREENNAME]] < 2} {
        tk_messageBox -type ok -message [tik_str E_NEEDSN]
        return
    }

    if {[string length $::PASSWORD] < 3} {
        tk_messageBox -type ok -message [tik_str E_NEEDPASS]
        return
    }

    set ::BUDDYLIST [list]
    set ::PERMITLIST [list]
    set ::DENYLIST [list]
    catch {unset ::BUDDIES}
    catch {unset ::GROUPS}
    set ::PDMODE 1
    set ::NSCREENNAME [normalize $::SCREENNAME]

    setStatus [tik_str STAT_CONN]

    set auth $::SELECTEDAUTH
    set toc $::SELECTEDTOC

    toc_open $::NSCREENNAME $::TOC($toc,host) $::TOC($toc,port) \
        $::AUTH($auth,host) $::AUTH($auth,port) \
        $::NSCREENNAME $::PASSWORD english $::REVISION \
        $::TIK(proxies,$::USEPROXY,connFunc)
}

# tik_set_color --
#     Allow the user to chose a color for an entry.
# 
# Arguments:
#     type - tik window type
#     desc - color choser window title
#     id   - tik window id

proc tik_set_color { type desc id} {
    set color [tk_chooseColor -initialcolor $::TIK($type,$id,color) -title $desc]
    if {$color == ""} {
        return
    }
    set ::TIK($type,$id,color) $color
    $::TIK($type,$id,msgw) configure -foreground $color
}

# tik_set_default_color --
#     Set the default color for a particular window type
# 
# Arguments:
#     type - The window type.
#     button - The button whose color should be updated
proc tik_set_default_color { type {button 0} } {

    if {[info exists ::TIK(options,$type)] && [string length $::TIK(options,$type)]} {
	set color [tk_chooseColor -initialcolor $::TIK(options,$type)\
		-title [tik_str MISC_DCLR_TITLE]]
    } else {
	set color [tk_chooseColor -title [tik_str MISC_DCLR_TITLE]]
    }

    if {$color == ""} {
        return
    }
    set ::TIK(options,$type) $color

    if {$button != 0} {
	$button configure -background $color -activebackground $color
    }
}

# tik_signoff --
#     Start the signoff process.

proc tik_signoff {} {
    if {!$::TIK(online)} {
        return
    }
#    away::back
    tik_set_config
    tik_close_chats
    toc_close $::NSCREENNAME
    tik_signoff_cim_msgs
    tik_show_login
    setStatus [tik_str STAT_CBACK]
    catch {after cancel $::TIK(IDLE,timer)}
    set ::TIK(IDLE,sent) 0
    set ::TIK(online) 0
    set ::TIK(reconnect) 0
    foreach package [lsort -ascii [array names ::TIK pkg,*,pkgname]] {
        set pkgname $::TIK($package)
        ${pkgname}::goOffline
    }
}

# tik_add_buddy --
#     Add a new buddy/group pair to the internal list of buddies.
#     This does not send anything to the server.
#
# Arguments:
#     group - group the buddy is in
#     name  - name of the buddy

proc tik_add_buddy {group name} {
    if {![info exists ::BUDDIES($name,online)]} {
        set ::BUDDIES($name,type) AIM
        set ::BUDDIES($name,online) F
        set ::BUDDIES($name,icon) ""
        set ::BUDDIES($name,indexs) ""
        set ::BUDDIES($name,popupText) ""
        set ::BUDDIES($name,otherString) ""
        set ::BUDDIES($name,name) $name
        set ::BUDDIES($name,idle) 0
	set ::BUDDIES($name,evil) 0
        set ::BUDDIES($name,uclass) ""
        toc_add_buddy $::NSCREENNAME $name
    }

    if {![info exists ::GROUPS($group,people)]} {
        set ::GROUPS($group,people) [list]
        set ::GROUPS($group,collapsed) F
        set ::GROUPS($group,type) AIM
        set ::GROUPS($group,online) 0
        set ::GROUPS($group,total) 0
        lappend ::BUDDYLIST $group
        lappend ::GROUPS($group,people) $name
        tik_edit_draw_list
    } else {
        lappend ::GROUPS($group,people) $name
        tik_edit_draw_list $group $name
    }
    tik_update_group_cnts

    tik_draw_list
}

# tik_add_pd --
#     Add a new permit/deny person.  This doesn't change
#     anything on the server.
#
# Arguments:
#     group - either permit or deny
#     name  - the person to permit/deny

proc tik_add_pd {group name} {
    if {$group == "Permit"} {
        lappend ::PERMITLIST $name
    } else {
        lappend ::DENYLIST $name
    }
    tik_pd_draw_list
}

# tik_set_config --
#     Create a string that represents the current buddylist and permit/deny
#     settings.  Based on options we send this config to the host and/or
#     the local disk.

proc tik_set_config {} {
    set str ""
    append str "m $::PDMODE\n"
    foreach p $::PERMITLIST {
        append str "p $p\n"
    }
    foreach d $::DENYLIST {
        append str "d $d\n"
    }
    foreach g $::BUDDYLIST {
        if {$::GROUPS($g,type) != "AIM"} {
            continue
        }
        append str "g $g\n"
        foreach b $::GROUPS($g,people) {
            append str "b $::BUDDIES($b,name)\n"
        }
    }

    if {($::TIK(options,localconfig) > 0) && [file isdirectory $::TIK(configDir)]} {
        set file [open "[file join $::TIK(configDir) $::NSCREENNAME.config]" "w"]
        puts -nonewline $file $str
        close $file
    } 
    
    if { $::TIK(options,localconfig) != 1} {
        if {[string length $str] > 2000} {
            tk_messageBox -type ok -message [tik_str E_BIGCONFIG]
        } else {
            toc_set_config $::NSCREENNAME $str
        }
    }
    set ::TIK(config) $str
}

# tik_send_init --
#     Send the TOC server initialization sequence.  Basically
#     the buddy list, permit/deny mode, followed by toc_init_done.
#
# Arguments:
#     first - If not the first we don't do the toc_init_done,
#             and we also clear the permit/deny settings before sending.

proc tik_send_init {first} {
    foreach g $::BUDDYLIST {
        if {$::GROUPS($g,type) != "AIM"} {
            continue
        }
        foreach b $::GROUPS($g,people) {
            lappend buds $b
        }
    }

    if {![info exists buds]} {
        tik_add_buddy Buddies [normalize $::SCREENNAME]
    } else {
        toc_add_buddy $::NSCREENNAME $buds
    }

    if {!$first} {
        # This will flash us, but who cares, I am lazy. :(
        toc_add_permit $::NSCREENNAME
        toc_add_deny $::NSCREENNAME
    }

    if {$::PDMODE == "3"} {
        toc_add_permit $::NSCREENNAME $::PERMITLIST
    } elseif {$::PDMODE == "4"} {
        toc_add_deny $::NSCREENNAME $::DENYLIST
    }

    if {$first} {
        toc_init_done $::SCREENNAME
        if {$::TIK(CAPS) != ""} {
            toc_set_caps $::SCREENNAME $::TIK(CAPS)
        }
    }
}

# tik_is_buddy --
#     Check to see if a name is on our buddy list.
#
# Arguments:
#     name - buddy to look for.

proc tik_is_buddy {name} {
    foreach g $::BUDDYLIST {
        if {$::GROUPS($g,type) == "AIM"} {
            foreach b $::GROUPS($g,people) {
                if {$b == $name} {
                    return 1
                }
            }
        }
    }

    return 0
}

# tik_show_url --
#     Routine that is called to display a url.  By default
#     on UNIX we just call netscape, on windows we use start.
#
# Arguments:
#     window - The window name to display the url in, ignored here
#     url    - The url to display.
proc tik_show_url {window url} {
    if {[string match "*NT*" $::tcl_platform(os)]} {
        catch {exec cmd /c start $url &}
    } else {
        if {[string match "Windows*" $::tcl_platform(os)]} {
            catch {exec start $url &}
        } else {
          if {[string length [namespace children :: ns]] > 0} {
              catch {
                 if {[llength [::ns::winlist]] > 0} {
                     ::ns::openURL $url
                     return
                 }
              }
          } elseif {[string length [::info commands send-netscape]] > 0} {
              catch {
                 if {[llength [::info-netscape list]] > 0} {
                    ::send-netscape openURL($url)
                    return
                 }
             }
          }
          if {[catch {exec netscape -remote openURL($url)}]} {
	      catch {exec netscape $url &}
          }
        }
    }
}

# tik_play_sound --
#     Play a sound file.   This is platform dependant, and will
#     need to be changed or overridden on some platforms.
#
# Arguments:
#     soundfile - The sound file to play.

proc tik_play_sound {soundfile_in} {
    if {($soundfile_in == "none") || $::SOUNDPLAYING} {
        return
    }

    if {[winfo exists .awaymsg] && $::TIK(options,silentaway)} {
	return
    }

    if {$soundfile_in == "beep"} {
    	bell
	set ::SOUNDPLAYING 1
	after 500 set ::SOUNDPLAYING 0
	return
    }

    set soundfile [tik_where_Override media $soundfile_in]

    if {$soundfile == "none"} {
        return
    }

    set ::SOUNDPLAYING 1
    after [expr [file size $soundfile] / 8] set ::SOUNDPLAYING 0

    if { [info exists ::TIK(SOUNDROUTINE)] && [string length $::TIK(SOUNDROUTINE)] } {
        catch {eval exec $::TIK(SOUNDROUTINE) $soundfile}
    } else {
        switch -glob -- $::tcl_platform(os) {
	"Linux*" {
	    catch {exec play $soundfile 2> /dev/null &}
	}
        "IRIX*" {
            catch {exec /usr/sbin/playaifc -p $soundfile 2> /dev/null &}
        }
        "OSF1*" {
            catch {exec /usr/bin/mme/decsound -play $soundfile 2> /dev/null &}
        }
        "HP*" {
            catch {exec /opt/audio/bin/send_sound $soundfile 2> /dev/null &}
        }
        "AIX*" {
            catch {exec /usr/lpp/UMS/bin/run_ums audio_play -f $soundfile 2> /dev/null &} 
        }
        "UnixWare*" -
        "SunOS*" {
            catch {exec dd if=$soundfile of=/dev/audio 2> /dev/null &}
        }
        "Windows*" {
            catch {exec C:/WINDOWS/rundll32.exe C:/WINDOWS/SYSTEM/amovie.ocx,RunDll /play /close $soundfile &}
        }
        default {
            catch {exec dd if=$soundfile of=/dev/audio 2> /dev/null &}
        }
        };# SWITCH
    }
}

# tik_play_sound2 --
#     Wrapper for tik_play_sound that trys to find a unique sound
#     based on a normalized name first, before playing the default.
#
# Arguments:
#     norm      - The normalized name.
#     sound     - The sound to play.
proc tik_play_sound2 {norm sound} {
    if {[info exists ::TIK(SOUND,$norm,$sound)]} {
        tik_play_sound $::TIK(SOUND,$norm,$sound)
    } else {
        tik_play_sound $::TIK(SOUND,$sound)
    }
}

# tik_play_sound3 --
#     Wrapper for tik_play_sound that plays a sound based on
#     its name
proc tik_play_sound3 {sound} {
    tik_play_sound $::TIK(SOUND,$sound)
}

# tik_non_idle_event --
#     Called when an event happens that indicates we are not idle.
#     We check to see if we previous said we were idle, and change
#     that.

proc tik_non_idle_event {} {
    set ::TIK(IDLE,last_event) [clock seconds]
    if {$::TIK(IDLE,sent)} {
        set ::TIK(IDLE,sent) 0
        toc_set_idle $::NSCREENNAME 0
    }
}

# tik_check_idle --
#     Timer that checks to see if the last non idle event
#     happened more then 15 minutes ago.  If it did we tell the
#     server that we are idle.

proc tik_check_idle {} {
    set cur [clock seconds]

    if {$::TIK(options,idlewatchmouse)} {
        set XY [winfo pointerxy .]

        if {$XY != $::TIK(IDLE,XY)} {
            set ::TIK(IDLE,XY) $XY
            tik_non_idle_event
        }
    }

    if {!$::TIK(IDLE,sent)} {
        if {$cur - $::TIK(IDLE,last_event) > $::TIK(options,reportidleafter)} {
            # Only actually send up idle time to the server if the user wants.
            if {$::TIK(options,reportidle)} {
                toc_set_idle $::NSCREENNAME \
                    [expr ($cur - $::TIK(IDLE,last_event))]
                set ::TIK(IDLE,sent) 1
            }
        }
    }
    set ::TIK(IDLE,timer) [after 30000 tik_check_idle]
}
