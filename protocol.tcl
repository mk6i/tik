# PROTOCOL LISTENERS

#######################################################
# These are the TOC event listeners we registered.
# You can find the args documented in the PROTOCOL document.

proc SIGN_ON {name version} {
    # The following is true after migration
    if {[llength $::BUDDYLIST] > 0} {  
        tik_send_init 1
    }

    if {$::TIK(INFO,sendinfo)} {
        toc_set_info $name $::TIK(INFO,msg)
    }

#    catch {if {$away::info(sendaway)} {away::set_away $away::info(msg)}}

    # We managed to sign on, now reconnecting is ok
    set ::TIK(reconnect) 1
}

proc CONFIG {name data} {

    set configFile [file join $::TIK(configDir) $::NSCREENNAME.config]

    if {$::TIK(options,localconfig) == 3} {
        # Use the host config and backup locally, unless the
        # host config doesn't exist, then use the local config.

        if {[string length $data] < 5} {
            if {[file exists $configFile]} {
                puts "NOTICE: Host config was empty, using local config."
                set file [open $configFile "r"]
                set data [read $file]
                close $file
            }
        } else {
            set file [open $configFile "w"]
            puts -nonewline $file $data
            close $file
        }
    } elseif {$::TIK(options,localconfig) != 0} {
        # Ignore what we get from host if there is a local file
        if {[file exists $configFile]} {
            set data ""
            set f [open $configFile "r"]
            set data [read $f]
            close $f

            # Send local config to the host.
            if {$::TIK(options,localconfig) == 2} {
                if {[string length $data] > 2000} {
                    tk_messageBox -type ok -message [tik_str E_BIGCONFIG]
                } else {
                    toc_set_config $::NSCREENNAME $data
                }
            }
        }
    }

    tik_parse_config $data

    set ::TIK(IDLE,sent) 0
    tik_non_idle_event
    tik_check_idle
    tik_send_init 1

    set ::TIK(online) 1
    foreach package [lsort -ascii [array names ::TIK pkg,*,pkgname]] {
        set pkgname $::TIK($package)
        ${pkgname}::goOnline
    }

    tik_show_buddy
    tik_draw_list
}

proc NICK {name nick} {
    set ::SCREENNAME $nick

    tik_strs_buddy
}

proc IM_IN {name source msg auto} {
#    if {[info exists ::TIK(getawayuse)]} {
#        if {([info exists getaway::info([normalize $source])] && \
#           ($auto == "auto" || $auto == "T"))} {
#           return
#       }
#       if {($msg == $getaway::info(msg)) && !$::TIK(options,getaway,notify)} {
#           return
#       }
#    }
#    if {[info exists ::TIK(remoteadminuse)]} {
#        if {[regexp {<!--\[.*\]-->} $msg]} {
#            return
#        }
#    }
#    if {[info exists ::TIK(remoteguiuse)]} {
#        if {[regexp {>>>>.*<<<<} $msg]} {
#            return
#        }
#    }
    set xmsg [tik_filter_msg $name IM_IN $msg $source $auto]
    if {$xmsg != ""} {
        tik_receive_im $source $auto $xmsg F
    }
}

proc IM_OUT {name source msg auto} {
#    if {[info exists ::TIK(remoteadminuse)] || [info exists ::TIK(remoteguiuse)]} {
#        if {[regexp {<!--\[.*\]-->} $msg]} {
#            return
#        }
#    }
    set xmsg [tik_filter_msg $name IM_OUT $msg $source $auto]
    if {$xmsg != ""} {
        tik_receive_im $source $auto $xmsg T
    }
}

proc UPDATE_BUDDY {name user online evil signon idle uclass} {
    set bud [normalize $user]
    # For some reason the buddy names have a tab at the end
    # so we're removing it.
    regsub {[\s]$} $user "" user

    if {$user != $::BUDDIES($bud,name)} {
        foreach i $::BUDDIES($bud,indexs) {
            catch {sag::change_mainstring .buddy.list $i $user}
        }
    }

    if {$bud == $::NSCREENNAME} {
        set ::TIK(EVIL,level) $evil
    }

    tik_update_otherstring $bud $idle $evil

    set ::BUDDIES($bud,name) $user
    set o $::BUDDIES($bud,online)
    set ::BUDDIES($bud,online) $online
    set ::BUDDIES($bud,evil) $evil
    set ::BUDDIES($bud,signon) $signon
### FUZZFACE00/IDLE - Save old idle information for later use
    set iii $::BUDDIES($bud,idle)
### FUZZFACE00/IDLE - End Mods
    set ::BUDDIES($bud,idle) $idle
    set u $::BUDDIES($bud,uclass)
    set ::BUDDIES($bud,uclass) $uclass

    tik_update_idle $bud

    tik_title_cim $user $o

    if {$o != $online} {
        tik_update_group_cnts
	tik_update_offline
        if {$online == "T"} {
            set ::BUDDIES($bud,icon) Login
	    tik_draw_list
        } else {
            set ::BUDDIES($bud,icon) Logout
        }

        foreach i $::BUDDIES($bud,indexs) {
            catch {sag::change_icon .buddy.list $i $::BUDDIES($bud,icon)}
        }
        after $::TIK(options,removedelay) tik_removeicon $bud

        if {$bud != $::NSCREENNAME} {
            if {$online == "T"} {
                after 100 tik_play_sound2 $bud Arrive
            } else {
                after 100 tik_play_sound2 $bud Depart
            }
        }

### FUZZFACE00/IDLE
### Check to see if uclass, or idle changed... if so call tik_update_uclass
    } elseif { ($u != $uclass) || ($idle != $iii) } {
### FUZZFACE00/IDLE - End Mods
        tik_update_uclass $bud
    }
    tik_update_ptext $bud
}

proc ERROR {name code data} {
    set args [split $data ":"]
    if {[catch {tk_messageBox -type ok -message [tik_str E_SRV_$code $args]}] != 0} {
        tk_messageBox -type ok -message [tik_str E_SRV_UNK $code $args]
    }
}

proc EVILED {name level user} {
    if {$::TIK(EVIL,level) < $level} {
        if {[string length $user] == 0 } {
            tk_messageBox -type ok -message [tik_str E_AWARN $level]
        } else {
            tk_messageBox -type ok -message [tik_str E_NWARN $level $user]
        }
    }
    set ::TIK(EVIL,level) $level
    tik_strs_buddy
}

proc CHAT_JOIN {name id loc} {
    catch {
        set people $::TIK(invites,$loc,people)
        set msg $::TIK(invites,$loc,msg)

        set p ""
        foreach i [split $people "\n" ] {
            set n [normalize $i]
            if {$n != "" } {
                append p $n
                append p " "
            }
        }

        if {$p != ""} {
            toc_chat_invite $name $id $msg $p
        }

        unset ::TIK(invites,$loc,people)
        unset ::TIK(invites,$loc,msg)
    }

    tik_create_chat $id $loc
}

proc CHAT_LEFT {name id} {
    tik_leave_chat $id
}

proc CHAT_IN {name id source whisper msg} {
    tik_receive_chat $id $source $whisper $msg
}

proc CHAT_UPDATE_BUDDY {name id online blist} {
    set w $::TIK(chats,$id,list)

    if {![winfo exists $w]} {
        return
    }

    foreach p $blist {
        set np [normalize $p]
        if {[info exists ::TIK(chats,$id,people,$np)]} {
            if {$online == "F"} {
                catch {sag::remove $w $::TIK(chats,$id,people,$np)}
                tik_receive_chat $id "*" F [tik_str CHAT_DEPART $p]
                unset ::TIK(chats,$id,people,$np)
            }
        } else {
            if {$online == "T"} {
                if {[info exists ::TIK(options,autoignoredeny)] &&
                    $::TIK(options,autoignoredeny) &&
                    [lsearch -exact $::DENYLIST $np] != -1} {
                        set ::TIK(chats,$id,luzer,$np) 1
                }
                if {[info exists ::TIK(chats,$id,luzer,$np)]} {
                    set ::TIK(chats,$id,people,$np) [sag::add $w 0 "" $p ""\
                        $::TIK(options,ignorecolor) $::TIK(options,buddyocolor)]
                } else {
                    set ::TIK(chats,$id,people,$np) [sag::add $w 0 "" $p ""\
                        $::TIK(options,buddymcolor) $::TIK(options,buddyocolor)]
                }
                tik_receive_chat $id "*" F [tik_str CHAT_ARRIVE $p]
            }
        }
    }
}

proc CHAT_INVITE {name loc id sender msg} {
    tik_create_accept $loc $id $sender $msg
}

proc GOTO_URL {name window url} {
    set toc $::SELECTEDTOC

    if {[string match "http://*" $url]} {
        tik_show_url $window $url
    } else {
        if {$::USEPROXY != "None"} {
            ;# When using a proxy host must be an ip already.
            set ip $::TOC($toc,host)
        } else {
            ;# Not using socks, look up the peer ip.
            set ip [lindex [sflap::peerinfo $name] 0]
        }
        tik_show_url $window "http://$ip:$::TOC($toc,port)/$url"
    }
}

proc PAUSE {name data} {
    puts "PAUSING"
}

proc CONNECTION_CLOSED {name data} {
    tik_signoff_cim_msgs
    tik_close_chats
    tik_show_login
    setStatus [tik_str STAT_CLOSED]
    catch {after cancel $::TIK(IDLE,timer)}
    set ::TIK(IDLE,sent) 0
    set ::TIK(online) 0
    foreach package [lsort -ascii [array names ::TIK pkg,*,pkgname]] {
        set pkgname $::TIK($package)
        ${pkgname}::goOffline
    }

    # TIK(reconnect) is true if it is alright to reconnect
    # TIK(options,persistent) is true if the user wants us to reconnect.
    if {$::TIK(reconnect) && $::TIK(options,persistent)} {
        if {![info exists ::TIK(reconnect_delay)]} {
            set ::TIK(reconnect_delay) 30000
        }
        after $::TIK(reconnect_delay) tik_signon
    }
}
