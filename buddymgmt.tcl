#######################################################
# Routines for doing a Buddy Add
#######################################################
proc p_tik_add_send {id} {
    set group $::TIK(adds,$id,group)
    set name $::TIK(adds,$id,name)
    set w $::TIK(adds,$id,toplevel)

    if {[string length [normalize $group]] < 2} {
        tk_messageBox -type ok -message [tik_str E_NEEDBGROUP]
        return
    }

    if {[string length [normalize $name]] < 2} {
        tk_messageBox -type ok -message [tik_str E_NEEDBNAME]
        return
    }

    if {$::TIK(adds,$id,mode) == "pd"} {
        tik_add_pd $group [normalize $name]
    } else {
        tik_add_buddy $group [normalize $name]
    }

    # Only send config if not in edit mode
    if {(![winfo exists .edit]) && (![winfo exists .pd])} {
        tik_set_config
    }

    $w.buddyname delete 0 end
    focus $w.buddyname
}

proc tik_create_add {{mode {buddy}} {name {}}} {
    set cnt 0
    catch {set cnt $::TIK(adds,cnt)}
    set ::TIK(adds,cnt) [expr $cnt + 1]

    set w .add$cnt
    toplevel $w -class Tik
    set ::TIK(adds,$cnt,toplevel) $w
    set ::TIK(adds,$cnt,mode) $mode
    set ::TIK(adds,$cnt,name) $name
    wm title $w [tik_str ADDB_TITLE]
    wm iconname $w [tik_str ADDB_ICON]
    if {$::TIK(options,windowgroup)} {wm group $w .login}

    frame $w.top
    label $w.buddynameL -text [tik_str ADDB_NAME]
    entry $w.buddyname -font $::NORMALFONT -width 16 -textvariable ::TIK(adds,$cnt,name)
    if {$mode == "buddy"} {
        bind $w.buddyname <Return> [list focus $w.buddygroup]
    } else {
        bind $w.buddyname <Return> [list p_tik_add_send $cnt]
    }
    pack $w.buddynameL $w.buddyname -in $w.top -side left

    frame $w.middle
    label $w.buddygroupL -text [tik_str ADDB_GROUP]


    if {$mode == "buddy"} {
        set templist [list]
        foreach e $::BUDDYLIST {
            if {$::GROUPS($e,type) == "AIM"} {
                lappend templist $e
            }
        }
        eval tk_optionMenu $w.m ::TIK(adds,$cnt,group) $templist
        $w.m configure -width 16
        entry $w.buddygroup -font $::NORMALFONT -width 16 -textvariable ::TIK(adds,$cnt,group)
        pack $w.buddygroup -in $w.middle -side right
        bind $w.buddygroup <Return> [list p_tik_add_send $cnt]
    } else {
        tk_optionMenu $w.m ::TIK(adds,$cnt,group) Permit Deny
        $w.m configure -width 16
    }
    pack $w.buddygroupL $w.m -in $w.middle -side left

    frame $w.bottom
    button $w.add -text [tik_str B_ADD] -command [list p_tik_add_send $cnt]
    bind $w <Control-a> [list p_tik_add_send $cnt]
    button $w.cancel -text [tik_str B_CLOSE] -command [list destroy $w]
    bind $w <Control-period> [list destroy $w]
    pack $w.add $w.cancel -in $w.bottom -side left -padx 2m

    pack $w.top $w.middle $w.bottom

    focus $w.buddyname
}

#######################################################
# Routines for doing buddy edit
#######################################################
proc tik_edit_draw_list { {group ""} {name ""}} {
    if {[winfo exists .edit] != 1} {
        return
    }

    if {$name == ""} {
        .edit.list delete 0 end

        foreach g $::BUDDYLIST {
            if {$::GROUPS($g,type) == "AIM"} {
                .edit.list insert end $g
                foreach j $::GROUPS($g,people) {
                    .edit.list insert end "   $::BUDDIES($j,name)"
                }
            }
        }
    } else {
        set n 0
        set s [.edit.list size]
        while {1} {
            if {$group == [.edit.list get $n]} {
                break
            }
            incr n
        }
        incr n
        while { ($n < $s) } {
            set t [.edit.list get $n]
            if {[string index $t 0] != " "} {
                break
            }
            incr n
        }
        .edit.list insert $n "   $name"
    }
}

proc p_tik_edit_remove {} {
    set n [.edit.list curselection]
    if { $n == "" } {
        return
    }

    set name [.edit.list get $n]


    if {[string index $name 0] == " "} {
        .edit.list delete $n
        set norm [normalize $name]
        foreach i $::BUDDYLIST {
            if {$::GROUPS($i,type) == "AIM"} {
                incr n -1
                set c 0
                foreach j $::GROUPS($i,people) {
                    if {$n == 0} {
                        set ::GROUPS($i,people) [lreplace $::GROUPS($i,people) $c $c]
                        if {![tik_is_buddy $j]} {
                            toc_remove_buddy $::NSCREENNAME $j
                        }
                        break
                    }
                    incr n -1
                    incr c
                }
                if {$n == 0} {
                    break
                }
            }
        }
    } else {
        set c [lsearch -exact $::BUDDYLIST $name]
        set ::BUDDYLIST [lreplace $::BUDDYLIST $c $c]

        set g $::GROUPS($name,people)
        unset ::GROUPS($name,people)
        unset ::GROUPS($name,collapsed)
        foreach i $g {
            if {![tik_is_buddy $i]} {
                toc_remove_buddy $::NSCREENNAME $i
            }
        }
        tik_edit_draw_list
    }
    tik_update_group_cnts
}

proc p_tik_edit_close {} {
    tik_set_config
    tik_draw_list
    destroy .edit
}

proc tik_create_edit {} {
    if {[winfo exists .edit]} {
        raise .edit
        tik_edit_draw_list
        return
    }

    toplevel .edit -class Tik
    wm title .edit [tik_str EDIT_TITLE]
    wm iconname .edit [tik_str EDIT_ICON]
    if {$::TIK(options,windowgroup)} {wm group .edit .login}

    frame .edit.listf
    scrollbar .edit.scroll -orient vertical -command [list .edit.list yview]
    listbox .edit.list -exportselection false -yscrollcommand [list .edit.scroll set]
    pack .edit.scroll -in .edit.listf -side right -fill y
    pack .edit.list -in .edit.listf -side left -expand 1 -fill both

    frame .edit.buttons
    button .edit.add -text [tik_str B_ADD] -command tik_create_add
    bind .edit <Control-a> tik_create_add
    button .edit.remove -text [tik_str B_REMOVE] -command p_tik_edit_remove
    bind .edit <Control-r> p_tik_edit_remove
    button .edit.close -text [tik_str B_CLOSE] -command p_tik_edit_close
    bind .edit <Control-period> p_tik_edit_close
    pack .edit.add .edit.remove .edit.close -in .edit.buttons -side left -padx 2m

    pack .edit.buttons -side bottom
    pack .edit.listf -fill both -expand 1 -side top
    wm protocol .edit WM_DELETE_WINDOW {p_tik_edit_close}
    tik_edit_draw_list
}

#######################################################
# Routines for doing permit deny
#######################################################

proc tik_pd_draw_list { {group ""} {name ""}} {
    if {[winfo exists .pd] != 1} {
        return
    }

    .pd.list delete 0 end

    .pd.list insert end "Permit"
    foreach i $::PERMITLIST {
        .pd.list insert end "   $i"
    }
    .pd.list insert end "Deny"
    foreach i $::DENYLIST {
        .pd.list insert end "   $i"
    }
}

proc p_tik_pd_remove {} {
    set n [.pd.list curselection]
    if { $n == "" } {
        return
    }
    incr n -1
    set k 0
    foreach i $::PERMITLIST {
        if {$n == 0} {
            set ::PERMITLIST [lreplace $::PERMITLIST $k $k]
        }
        incr k
        incr n -1
    }

    incr n -1
    set k 0
    foreach i $::DENYLIST {
        if {$n == 0} {
            set ::DENYLIST [lreplace $::DENYLIST $k $k]
        }
        incr k
        incr n -1
    }

    tik_pd_draw_list
}

proc p_tik_pd_close {} {
    tik_set_config
    destroy .pd

    # This will flash us, but who cares, I am lazy. :(
    toc_add_permit $::NSCREENNAME
    toc_add_deny $::NSCREENNAME

    # Set everyone off line since we will get updates
    foreach g $::BUDDYLIST {
        foreach b $::GROUPS($g,people) {
            if {$::BUDDIES($b,type) == "AIM"} {
                set ::BUDDIES($b,online) F
            }
        }
    }

    # Send up the data
    if {$::PDMODE == "3"} {
        toc_add_permit $::NSCREENNAME $::PERMITLIST
    } elseif {$::PDMODE == "4"} {
        toc_add_deny $::NSCREENNAME $::DENYLIST
    }
    tik_draw_list
}

proc tik_create_pd {} {
    if {[winfo exists .pd]} {
        raise .pd
        tik_pd_draw_list
        return
    }

    toplevel .pd -class Tik
    wm title .pd [tik_str PD_TITLE]
    wm iconname .pd [tik_str PD_ICON]
    if {$::TIK(options,windowgroup)} {wm group .pd .login}

    frame .pd.radios
    radiobutton .pd.all -value 1 -variable ::PDMODE \
       -text [tik_str PD_MODE_1]
    radiobutton .pd.permit -value 3 -variable ::PDMODE \
       -text [tik_str PD_MODE_3]
    radiobutton .pd.deny -value 4 -variable ::PDMODE \
       -text [tik_str PD_MODE_4]
    pack .pd.all .pd.permit .pd.deny -in .pd.radios

    frame .pd.listf
    scrollbar .pd.scroll -orient vertical -command [list .pd.list yview]
    listbox .pd.list -exportselection false -yscrollcommand [list .pd.scroll set]
    pack .pd.scroll -in .pd.listf -side right -fill y
    pack .pd.list -in .pd.listf -side left -expand 1 -fill both

    frame .pd.buttons
    button .pd.add -text [tik_str B_ADD] -command "tik_create_add pd"
    bind .pd <Control-a> tik_create_add
    button .pd.remove -text [tik_str B_REMOVE] -command p_tik_pd_remove
    bind .pd <Control-r> p_tik_pd_remove
    button .pd.close -text [tik_str B_CLOSE] -command p_tik_pd_close
    bind .pd <Control-period> p_tik_pd_close
    pack .pd.add .pd.remove .pd.close -in .pd.buttons -side left -padx 2m

    pack .pd.buttons -side bottom
    pack .pd.radios .pd.listf -fill both -expand 1 -side top
    tik_pd_draw_list
}

#######################################################
# Routines for Warn Confirmation
#######################################################
proc p_tik_warn_send {name} {
    toc_evil $::NSCREENNAME $name $::TIK(warnanon)
    destroy .warn
}

proc tik_create_warn {name anon} {
    set w .warn
    if {[winfo exists $w]} {
        raise $w
        return
    }

    toplevel $w -class Tik
    wm title $w [tik_str WARN_TITLE $name]
    wm iconname $w [tik_str WARN_TITLE $name]
    if {$::TIK(options,windowgroup)} {wm group $w .login}

    bind $w <Motion> tik_non_idle_event

    set ::TIK(warnanon) $anon

    label $w.l1 -text [tik_str WARN_L1 $name]
    checkbutton $w.anon -text [tik_str WARN_ANON] -variable ::TIK(warnanon) \
        -onvalue T -offvalue F
    label $w.l2 -text [tik_str WARN_L2 $name]


    frame $w.buttonF
				
    if {$::TIK(options,iconbuttons)} {
        button $w.warn -image bwarn -command [list p_tik_warn_send $name]
        button $w.cancel -image bclose -command "destroy $w"
    } else {
        button $w.warn -text [tik_str B_WARN] -command [list p_tik_warn_send $name]
	button $w.cancel -text [tik_str B_CANCEL] -command "destroy $w"
    }

    bind $w <Control-w> [list p_tik_warn_send $name]

    bind $w <Control-period> "destroy $w"
    pack $w.warn $w.cancel -in $w.buttonF -side left -padx 2m

    pack $w.l1 $w.anon $w.l2 $w.buttonF -side top
}

#######################################################
# Routines for the "Buddy" Block Button
#######################################################
proc tik_block_buddy {name} {
    tik_add_pd deny $name
    p_tik_pd_close
}

proc tik_create_block {name} {
    set w .block
    if {[winfo exists $w]} {
	raise $w
	return
    }
    toplevel $w -class Tik
    wm title $w [tik_str BLOCK_TITLE $name]
    wm iconname $w [tik_str BLOCK_TITLE $name]

    if {$::TIK(options,windowgroup)} {wm group $w .login}

    bind $w <Motion> tik_non_idle_event

    label $w.body -text [tik_str BLOCK_BODY $name]

    frame $w.buttonF

    if {$::TIK(options,iconbuttons)} {
        button $w.block -image bblock -command "tik_block_buddy $name; destroy $w"
        button $w.cancel -image bclose -command "destroy $w"
    } else {
        button $w.block -text [tik_str B_BLOCK] -command "tik_block_buddy $name; destroy $w"
	button $w.cancel -text [tik_str B_CANCEL] -command "destroy $w"
    }

    bind $w <Control-period> "destroy $w"
    
    pack $w.block $w.cancel -in $w.buttonF -side left -padx 2m
    pack $w.body $w.buttonF -side top
}
