# Routines for doing a Chat Invite

proc p_tik_invite_send {id} {
    set roomid $::TIK(cinvites,$id,roomid)
    set msg $::TIK(cinvites,$id,msg)
    set loc $::TIK(cinvites,$id,loc)
    set peoplew $::TIK(cinvites,$id,peoplew)
    set w $::TIK(cinvites,$id,toplevel)

    if { [string length [string trim $msg]] == 0} {
        tk_messageBox -type ok -message [tik_str E_NOMSG]
        return
    }

    if { [string length $msg] > 200 } {
        tk_messageBox -type ok -message [tik_str E_MSGLONG]
        return
    }

    if { [string length [string trim $loc]] == 0} {
        tk_messageBox -type ok -message [tik_str E_NEEDLOC]
        return
    }

    if { [string length $loc] > 50 } {
        tk_messageBox -type ok -message [tik_str E_LOCLONG]
        return
    }

    set ::TIK(invites,$loc,people) [$peoplew get 0.0 end]
    set ::TIK(invites,$loc,msg) $msg

    if {$roomid != "" } {
        CHAT_JOIN $::NSCREENNAME $roomid $loc
    } else {
        toc_chat_join $::NSCREENNAME 4 $loc
    }
    destroy $w
}
proc p_tik_invite_add {id} {
    set sel [sag::selection .buddy.list]
    set peoplew $::TIK(cinvites,$id,peoplew)

    if {$sel == ""} {
        return
    }

    foreach s $sel {
        set c [string index $s 0]
        if {$c == "+" || $c == "-"} {
            set g [string range $s 2 end]
            if {$::GROUPS($g,type) != "AIM"} {
                continue
            }
            foreach i $::GROUPS($g,people) {
                if {$::BUDDIES($i,online) == "T"} {
                    $peoplew insert end "$::BUDDIES($i,name)\n"
                }
            }
        } else {
            $peoplew insert end "[string trim $s]\n"
        }
    }
}
proc tik_create_invite {{roomid ""} {loc ""}} {
    set cnt 0
    catch {set cnt $::TIK(cinvites,cnt)}
    set ::TIK(cinvites,cnt) [expr $cnt + 1]

    set ::TIK(cinvites,$cnt,roomid) $roomid
    set ::TIK(cinvites,$cnt,msg) [tik_str CINVITE_MSG]

    if {$loc == ""} {
        set ::TIK(cinvites,$cnt,loc) "$::SCREENNAME chat[expr int(rand() * 10000)]"
    } else {
        set ::TIK(cinvites,$cnt,loc) $loc
    }

    set w .invite$cnt
    toplevel $w -class $::TIK(options,chatWMClass)
    wm title $w [tik_str CINVITE_TITLE]
    wm iconname $w [tik_str CINVITE_ICON]
    if {$::TIK(options,windowgroup)} {wm group $w .login}
    set ::TIK(cinvites,$cnt,toplevel) $w

    bind $w <Motion> tik_non_idle_event

    label $w.inviteL -text [tik_str CINVITE_DIR]
    text $w.invite -font $::NORMALFONT -width 40
    set ::TIK(cinvites,$cnt,peoplew) $w.invite
    label $w.messageL -text [tik_str CINVITE_MSGL]
    entry $w.message -font $::NORMALFONT -textvariable ::TIK(cinvites,$cnt,msg) -width 40
    bind $w.message <Return> [list focus $w.location]
    label $w.locationL -text [tik_str CINVITE_LOCL]
    entry $w.location -font $::NORMALFONT -textvariable ::TIK(cinvites,$cnt,loc) -width 40
    bind $w.location <Return> "p_tik_invite_send $cnt; break"

    frame $w.buttons
    button $w.send -text [tik_str B_SEND] -command [list p_tik_invite_send $cnt]
    bind $w <Control-s> "p_tik_invite_send $cnt; break"
    balloonhelp $w.send [tik_str TOOLTIP_B_SEND_INVIT]


    button $w.add -text [tik_str B_ADD] -command [list p_tik_invite_add $cnt]
    bind $w <Control-a> [list p_tik_invite_add $cnt]
    balloonhelp $w.add [tik_str TOOLTIP_B_ADD_INVIT]

    button $w.cancel -text [tik_str B_CANCEL] -command [list destroy $w]
    bind $w <Control-period> [list destroy $w]
    pack $w.send $w.add $w.cancel -in $w.buttons -side left -padx 2m

    pack $w.inviteL $w.invite $w.messageL $w.message $w.locationL $w.location $w.buttons

    if {$loc != ""} {
        $w.location configure -state disabled
    }

    p_tik_invite_add $cnt
}

#######################################################
# Routines for doing a Chat Accept
#######################################################
proc p_tik_accept_send {w id} {
    destroy $w
    toc_chat_accept $::NSCREENNAME $id
}
proc tik_create_accept {loc id name msg} {
    set w .accept$id

    toplevel $w -class $::TIK(options,chatWMClass)
    wm title $w [tik_str CACCEPT_TITLE $name]
    wm iconname $w [tik_str CACCEPT_ICON $name]
    if {$::TIK(options,windowgroup)} {wm group $w .login}

    bind $w <Motion> tik_non_idle_event

    label $w.msg -text $msg
    label $w.loc -text [tik_str CACCEPT_LOC $loc]

    frame $w.buttons
    button $w.accept -text [tik_str B_ACCEPT] -command [list p_tik_accept_send $w $id]
    bind $w <Control-a> [list p_tik_accept_send $w $id]
    balloonhelp $w.accept [tik_str TOOLTIP_B_ACCEPT_CHAT]

    button $w.im -text [tik_str B_IM] -command [list tik_create_iim $::NSCREENNAME $name]
    bind $w <Control-i> [list tik_create_iim $::NSCREENNAME $name]
    balloonhelp $w.im [tik_str TOOLTIP_B_IM]

    button $w.info -text [tik_str B_INFO] -command [list toc_get_info $::NSCREENNAME $name]
    bind $w <Control-l> [list toc_get_info $::NSCREENNAME $name]
    balloonhelp $w.info [tik_str TOOLTIP_B_INFO]

    button $w.warn -text [tik_str B_WARN] -command [list tik_create_warn $name F]
    bind $w <Control-W> [list tik_create_warn $name T]
    balloonhelp $w.warn [tik_str TOOLTIP_B_WARN]

    button $w.cancel -text [tik_str B_CANCEL] -command [list destroy $w]
    bind $w <Control-period> [list destroy $w]
    balloonhelp $w.cancel [tik_str TOOLTIP_B_DECLIN_CHAT]

    pack $w.accept $w.im $w.info $w.warn $w.cancel -in $w.buttons -side left -padx 2m

    pack $w.msg $w.loc $w.buttons
}

#######################################################
# Routines for doing a Chat Room
#######################################################

proc tik_close_chats {} {
    foreach i [array names ::TIK "chats,*name*"] {
       p_tik_chat_close [lindex [split $i {,}] 1]
    }
}

proc p_tik_chat_send {id whisper} {
    set w $::TIK(chats,$id,msgw)
    if {$::TIK(options,chatheight) == 0} {
        set xmsg [string trimright [$w get]]
    } else {
        set xmsg [string trimright [$w get 0.0 end]]
    }
    
    set ::TIK(chats,$id,lasttyped) $xmsg

    set msg [tik_filter_msg $::SCREENNAME CHAT_OUT $xmsg $id]

    if {[string length $msg] == 0 &&
            [string length $xmsg] != 0} {
        if {$::TIK(options,chatheight) == 0} {
            $w delete 0 end
        } else {
            $w delete 0.0 end
        }
        return
    }

    if { [string length [string trim $msg]] == 0} {
        tk_messageBox -type ok -message [tik_str E_NOMSG]
        return
    }

    if {$::TIK(options,chatcolor)} {
        set msg "<FONT COLOR=\"$::TIK(chats,$id,color)\">$msg</FONT>"
    }

    if { [string length $msg] > 950 } {
        tk_messageBox -type ok -message [tik_str E_MSGLONG]
        return
    }

    set header [string trim [.chats$id.chatBbar.hdr get]]
    set msg "$header$msg"

    if {$whisper == "T"} {
        set sel [sag::selection $::TIK(chats,$id,list)]
        if {$sel == ""} {
            tk_messageBox -type ok -message [tik_str E_NEEDWHISPER]
            return
        } else {
            foreach e $sel {
                toc_chat_whisper $::NSCREENNAME $id $e $msg
                tik_receive_chat $id $::NSCREENNAME S $msg $e
            }
        }
    } else {
        toc_chat_send $::NSCREENNAME $id $msg
    }

    if { $::TIK(options,chatheight) == 0} {
        $w delete 0 end
    } else {
        $w delete 0.0 end
    }
    if {$::TIK(options,buttonbar)} {
	.chats$id.chatBbar.b configure -relief raised
	.chats$id.chatBbar.u configure -relief raised
	.chats$id.chatBbar.i configure -relief raised
	.chats$id.chatBbar.s configure -relief raised
	.chats$id.chatBbar.f configure -relief raised
    }

}

proc tik_leave_chat {id} {
    if {[winfo exists $::TIK(chats,$id,toplevel)]} {
        destroy $::TIK(chats,$id,toplevel)
    }

    foreach i [array names ::TIK "chats,$id,*"] {
        unset ::TIK($i)
    }
}

proc p_tik_chat_close {id} {
    toc_chat_leave $::NSCREENNAME $id
    destroy $::TIK(chats,$id,toplevel)
}

proc tik_chat_add_buddy {id} {
    set sel [sag::selection $::TIK(chats,$id,list)]
    if {$sel == ""} {
        return
    }
    foreach e $sel {
        tik_create_add buddy $e
    }
}   

proc tik_create_chat {id name} {
    set nname [normalize $name]
    set w .chats$id
    if {[winfo exists $w]} {
        return
    }

    toplevel $w -class $::TIK(options,chatWMClass)
    wm title $w [tik_str CHAT_TITLE $name]
    wm iconname $w [tik_str CHAT_ICON $name]
    if {$::TIK(options,windowgroup)} {wm group $w .login}
    set ::TIK(chats,$id,toplevel) $w
    set ::TIK(chats,$id,name) $name

    bind $w <Motion> tik_non_idle_event

    frame $w.left

    set ::TIK(chats,$id,textw) [createHTML $w.textF]

    frame $w.msgF

    set mw [createINPUT $w.msgArea chatheight 30]
    set ::TIK(chats,$id,msgw) $mw
    set ::TIK(chats,$id,lasttyped) "Hello!"
    bind $mw <Control-Down> [list p_history $id]
    bind $mw <Control-Up> [list p_history $id]

    if { [expr {$::TIK(options,msgsend) & 1} ] == 1} {
        bind $mw <Return> "p_tik_chat_send $id F; break"
    }
    if { [expr {$::TIK(options,msgsend) & 2} ] == 2} {
        bind $mw <Control-Return> "p_tik_chat_send $id F; break"
    } else {
        bind $mw <Control-Return> " "
    }


    frame $w.chatBbar
    createBbar $w.chatBbar $mw $nname

    if {$::TIK(options,iconbuttons)} {
	button $w.send -image bsend -command [list p_tik_chat_send $id F]
	button $w.whisper -image bwhisper -command [list p_tik_chat_send $id T]
    } else {
	button $w.send -text [tik_str B_SEND] -command [list p_tik_chat_send $id F]
	button $w.whisper -text [tik_str B_WHISPER] -command [list p_tik_chat_send $id T]
    }
    
    balloonhelp $w.send       [tik_str TOOLTIP_B_SEND]
    balloonhelp $w.whisper    [tik_str TOOLTIP_B_WHISPER]

    pack $w.send $w.whisper -in $w.msgF -side right

    pack $w.msgArea -in $w.msgF -side left -fill x -expand 1

    pack $w.msgF -in $w.left -fill x -side bottom
    pack $w.textF -in $w.left -fill both -expand 1 -side top
    pack $w.chatBbar -in $w.left -fill both -expand 0 -side top

    frame $w.right

    sag::init $w.list 140 100 1 $::SAGFONT #a9a9a9 $::TIK(options,sagborderwidth)
    set ::TIK(chats,$id,list) $w.list
    
    frame $w.r1
    # Ignore button patch change start
    #    button $w.ignore -text [tik_str B_IGNORE] -state disabled

    if {$::TIK(options,iconbuttons)} {
        button $w.ignore -image bignore -command [list p_tik_ignore_luzer $id]
        button $w.add -image badd -command [list tik_chat_add_buddy $id]
    } else {
        button $w.ignore -text [tik_str B_IGNORE] -command [list p_tik_ignore_luzer $id]
        button $w.add -text [tik_str B_ADD] -command [list tik_chat_add_buddy $id]
    }

    balloonhelp $w.ignore    [tik_str TOOLTIP_B_IGNORE]
    balloonhelp $w.add       [tik_str TOOLTIP_B_ADD]

    # Ignore button patch change end
    #    button $w.warn -text [tik_str B_WARN] -command [list tik_lselect $w.list toc_evil] -state disabled
    #bind $w <Control-W> [list tik_lselect $w.list toc_evil T]
    #    pack $w.ignore $w.warn -in $w.r1 -side left
    pack $w.ignore $w.add -in $w.r1 -side left
    
    frame $w.r2

    if {$::TIK(options,iconbuttons)} {
	button $w.info -image binfo -command [list tik_lselect $w.list tik_get_info]
	button $w.im -image bim -command [list tik_lselect $w.list tik_create_iim ]
    } else {
	button $w.info -text [tik_str B_INFO] -command [list tik_lselect $w.list tik_get_info]
	button $w.im -text [tik_str B_IM] -command [list tik_lselect $w.list tik_create_iim ]
    }
    balloonhelp $w.info [tik_str TOOLTIP_B_INFO]
    balloonhelp $w.im   [tik_str TOOLTIP_B_IM]

    bind $w <Control-l> [list tik_lselect $w.list tik_get_info]

    bind $w <Control-i> [list tik_lselect $w.list tik_create_iim ]

    pack $w.info $w.im -in $w.r2 -side left

    frame $w.r3
    if {$::TIK(options,chatcolor)} {
        set ::TIK(chats,$id,color) $::TIK(options,defaultchatcolor)
        #button $w.color -text [tik_str B_COLOR] -command [list tik_set_color chats [tik_str CHAT_COL_TITLE] $id]
        #pack $w.color -in $w.r3 -side left
	$w.chatBbar.color configure -command [list tik_set_color chats [tik_str CHAT_COL_TITLE] $id]
    } else {
	pack forget $w.chatBbar.color
    }

    if {$::TIK(options,iconbuttons)} {
        button $w.invite -image binvite -command [list tik_create_invite $id $name]
	button $w.close -image bclose -command [list p_tik_chat_close $id]
    } else {
        button $w.invite -text [tik_str B_INVITE] -command [list tik_create_invite $id $name]
	button $w.close -text [tik_str B_CLOSE] -command [list p_tik_chat_close $id]
    }

    balloonhelp $w.invite [tik_str TOOLTIP_B_INVITE]
    balloonhelp $w.close  [tik_str TOOLTIP_B_CLOSE]
    
    bind $w <Control-v> [list tik_create_invite $id $name]

    pack $w.invite $w.close -in $w.r3 -side left

    wm protocol $w WM_DELETE_WINDOW [list p_tik_chat_close $id]
    bind $w <Control-period> [list p_tik_chat_close $id]

    pack $w.list -in $w.right -expand 1 -fill both
    pack $w.r1 $w.r2 $w.r3 -in $w.right

    pack $w.right -side right -expand 0 -fill both
    pack $w.left  -side left -expand 1 -fill both
    focus $mw
}

proc tik_receive_chat {id remote whisper msg {whispersto {}}} {
# Ignore button patch add start
    set s [normalize $remote]
    if {[info exists ::TIK(chats,$id,luzer,$s)]} {
        return
    }
# Ignore button patch add end
    if {[normalize $remote] == $::NSCREENNAME} {
        tik_play_sound $::TIK(SOUND,ChatSend)
    } else {
        tik_play_sound $::TIK(SOUND,ChatReceive)
    }

    set whisperstr ""
    if { $whisper == "T" } {
        set whisperstr [tik_str CHAT_WHISPER]
    } elseif { $whisper == "S" } {
        set whisperstr [tik_str CHAT_WHISPERTO $whispersto]
    }

    set w $::TIK(chats,$id,toplevel)

    if {![winfo exists $w]} {
        return
    }

    if {$::TIK(options,chattime)} {
        set tstr [clock format [clock seconds] -format [tik_str CHAT_TIMESTAMP]]
    } else {
        set tstr ""
    }

    set textw $::TIK(chats,$id,textw)

    $textw configure -state normal
    addHTML $textw "<b>$tstr$remote$whisperstr:</b> "
    addHTML $textw "$msg" $::TIK(options,chatcolor)
    addHTML $textw "\n"
    $textw configure -state disabled

    if {$::TIK(options,raisechat)} {
        raise $w
    }

    if {$::TIK(options,deiconifychat)} {
        wm deiconify $w
    }
    # Start: Highlight the person when someone whispers to you so
    # that you dont't have to select it manually for whispering
    if { $whisper == "T" } {
        set winName $::TIK(chats,$id,list)
        sag::clearSelection $winName
        set length [llength $sag::windows($winName,displaylist)]
        for { set idx 0 } { $idx < $length } { incr idx } {
            set obj [lindex $sag::windows($winName,displaylist) $idx]
            set mainstr $sag::buddydata($winName,$obj,mainstr)

            if { $mainstr == $remote } {
               break 
}
        }
        lappend sag::windows($winName,selected) $idx
        sag::hilight $winName $idx $idx highlight
    }
    # End
}

