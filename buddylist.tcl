# Buddy List routines

proc tik_parse_config {data} {
    set ::BUDDYLIST [list]
    set ::PERMITLIST [list]
    set ::DENYLIST [list]
    set ::PDMODE 1

    set ::TIK(config) $data
    set lines [split $data "\n"]
    foreach i $lines {
        switch -exact -- [string index $i 0] {
        "b" {
            # For some reason, the buddy names have a tab at the end
            # so we're removing it.
            regsub -all -- {[\s]$} $i "" i
            set bud [normalize [string range $i 2 end]]
            set ::BUDDIES($bud,type) AIM
            set ::BUDDIES($bud,online) F
            set ::BUDDIES($bud,name) [string range $i 2 end]
            set ::BUDDIES($bud,idle) 0
            set ::BUDDIES($bud,evil) 0
            set ::BUDDIES($bud,indexs) ""
            set ::BUDDIES($bud,popupText) ""
            set ::BUDDIES($bud,otherString) ""
            set ::BUDDIES($bud,uclass) ""
            incr ::GROUPS($group,total)
            lappend ::GROUPS($group,people) $bud
        } 
        "d" {
            set deny [string range $i 2 end]
            lappend ::DENYLIST $deny
        }
        "g" {
            set group [string range $i 2 end]
            lappend ::BUDDYLIST $group
            lappend ::GROUPS($group,collapsed) F
            set ::GROUPS($group,people) [list]
            set ::GROUPS($group,type) AIM
            set ::GROUPS($group,online) 0
            set ::GROUPS($group,total) 0
        }
        "m" {
            set ::PDMODE [string range $i 2 end]
        }
        "p" {
            set permit [string range $i 2 end]
            lappend ::PERMITLIST $permit
        }
        }
    }
    set ::GROUPS(Offline,collapsed) T
    set ::GROUPS(Offline,type) Offline
    set ::GROUPS(Offline,people) [list]
    set ::GROUPS(Offline,total) 0
    set ::GROUPS(Offline,online) 0
}

proc tik_update_offline {} {
    if {$::TIK(options,showofflinegroup)} {
        if {[lsearch -exact $::BUDDYLIST Offline] == -1} {
            lappend ::BUDDYLIST Offline
        }
        tik_update_offline_group
    } else {
        if {[set index [lsearch -exact $::BUDDYLIST Offline]] != -1} {
            set ::BUDDYLIST [lreplace $::BUDDYLIST $index $index]
        }
    }
}

proc tik_update_idle {bud} {
    if {$::TIK(options,idleupdateinterval) > 0} {
        catch {after cancel $::BUDDIES($bud,idleafter)}
        if {$::TIK(online)} {
            if {$::BUDDIES($bud,idle) != 0} {
                set ::BUDDIES($bud,idleafter) \
                    [after [expr $::TIK(options,idleupdateinterval) * 60000] \
                     update_idle_sub $bud]
            }
        }
    }
}

proc update_idle_sub {bud} {
    if {$::TIK(online)} {
        if {$::BUDDIES($bud,idle) != 0} {
            incr ::BUDDIES($bud,idle) $::TIK(options,idleupdateinterval)
            tik_update_otherstring $bud 0 0 1
            tik_title_cim $bud
            tik_update_ptext $bud
            tik_update_idle $bud
        }
    }
}

proc tik_update_otherstring {bud idle evil {idleupdate 0} } {
    set ::BUDDIES($bud,otherString) ""
    set spc ""
    
    if {$idleupdate} {
        set idle $::BUDDIES($bud,idle)
        set evil $::BUDDIES($bud,evil)
    }

    if {$::TIK(options,showidletime) || $::TIK(options,showevil)} {
        if {$::TIK(options,showidletime) && ($idle != 0)} {
            append ::BUDDIES($bud,otherString) [tik_str BL_IDLEDSP $idle]
	    set spc " "
        }

	if {$::TIK(options,showevil) && ($evil != 0)} {
	    append ::BUDDIES($bud,otherString) $spc [tik_str BL_EVILSP $evil]
        }

        if {$idleupdate || ($idle != $::BUDDIES($bud,idle)) || ($evil != $::BUDDIES($bud,evil))} {
            foreach i $::BUDDIES($bud,indexs) {
                catch {sag::change_otherstring .buddy.list $i \
                       $::BUDDIES($bud,otherString)}
            }
        }
    }
}

# Update the user class display for a buddy
proc tik_update_uclass {bud} {
    switch -glob -- $::BUDDIES($bud,uclass) {
    "??U" {
        set ::BUDDIES($bud,icon) Away
    }
    "A?*" {
        set ::BUDDIES($bud,icon) AOL
    }
    "?A*" {
        set ::BUDDIES($bud,icon) Admin
    }
    "?O*" {
        set ::BUDDIES($bud,icon) Oscar
    }
    "?U*" {
        set ::BUDDIES($bud,icon) DT
    }
    default {
        set ::BUDDIES($bud,icon) ""
        return; 
    }
    } ;# SWITCH

### FUZZFACE00/IDLE - Set the idle icon if appropriate 
# Do we want to see idle info ?
    if {$::TIK(options,showidletime)} {
# Check to see if the user is idle...
      if { $::BUDDIES($bud,idle) != 0 } {
# Check to see the user is NOT away
        if { $::BUDDIES($bud,icon) != "Away" } {
            set ::BUDDIES($bud,icon) Idle
        }
      } 
    } 
### FUZZFACE00/IDLE - End Mods

    catch {
        foreach i $::BUDDIES($bud,indexs) {
            catch {sag::change_icon .buddy.list $i $::BUDDIES($bud,icon)}
        }
    }
}

# Update the popup text for a buddy
proc tik_update_ptext {bud} {
    set ::BUDDIES($bud,popupText) [list \
        $::BUDDIES($bud,name): ""\
        [tik_str BL_IDLE] $::BUDDIES($bud,idle) \
        [tik_str BL_EVIL] "$::BUDDIES($bud,evil)%" \
        [tik_str BL_ONLINE] ]

    if {$::BUDDIES($bud,online) == "T"} {
##############################################################
	# for lack of a better place, this was put in the
	# popup update section.
	if {[info exists ::BUDDIES($bud,doubleClick)]} {
	    unset ::BUDDIES($bud,doubleClick)
	}
##############################################################
        lappend ::BUDDIES($bud,popupText) [clock format $::BUDDIES($bud,signon)]
    } else {
        lappend ::BUDDIES($bud,popupText) [tik_str BL_NOTONLINE]
    }

    lappend ::BUDDIES($bud,popupText) [tik_str BL_UCLASS]

    set class ""
    if {[string index $::BUDDIES($bud,uclass) 0] == "A"} {
        append class "AOL"
    }

    if {($class != "") && ([string index $::BUDDIES($bud,uclass) 1] != " ")} {
        append class ", "
    }

    switch -exact -- [string index $::BUDDIES($bud,uclass) 1] {
    "A" {
        append class "Admin"
    }
    "O" {
        append class "Oscar"
    }
    "U" {
        append class "Oscar Trial"
    }
    } ;# SWITCH
    lappend ::BUDDIES($bud,popupText) $class

    lappend ::BUDDIES($bud,popupText) [tik_str BL_STATUS]
    switch -exact -- [string index $::BUDDIES($bud,uclass) 2] {
    "U" {
        lappend ::BUDDIES($bud,popupText) [tik_str BL_STAT_AWAY]
    }
    default {
	# in a nutshell, if user is idle show "idle" else show "available"
	# i dont know what letter code coincides with idle, so i did it this way
	if {$::TIK(options,showidletime)} {
	    if { $::BUDDIES($bud,idle) != 0 } {
		    lappend ::BUDDIES($bud,popupText) [tik_str BL_STAT_IDLE]
	    } else {
		lappend ::BUDDIES($bud,popupText) [tik_str BL_STAT_AVAIL]
	}
    }
}
} ;# SWITCH
}

# Change from the Login/Logout icon to a "normal" icon.
proc tik_removeicon {bud} {
    if {!$::TIK(online)} {
        return
    }

    set ::BUDDIES($bud,icon) ""
    catch {
        foreach i $::BUDDIES($bud,indexs) {
            catch {sag::change_icon .buddy.list $i ""}
        }
    }

    if {$::BUDDIES($bud,online) == "F"} {
        tik_draw_list T
    } else {
        tik_update_uclass $bud
    }
}

# Update the online/total counts for each of the groups.
proc tik_update_group_cnts {} {
    foreach g $::BUDDYLIST {
        set ::GROUPS($g,online) 0
        set ::GROUPS($g,total) 0
        foreach b $::GROUPS($g,people) {
            incr ::GROUPS($g,total)
            if {$::BUDDIES($b,online) != "F"} {
                incr ::GROUPS($g,online)
            }
        }

        if {$::TIK(options,showgrouptotals)} {
            set totals "($::GROUPS($g,online)/$::GROUPS($g,total))"
        } else {
            set totals ""
        }
        catch {sag::change_otherstring .buddy.list $::GROUPS($g,index) $totals}
    }
}

proc OfflineDoubleClick {name buddy} {
    newqpounce $name $buddy
}

proc tik_update_offline_group {} {
    set ::GROUPS(Offline,total) 0
    set ::GROUPS(Offline,totalbuddies) 0
    set ::GROUPS(Offline,people) [list]
    set ::GROUPS(Offline,online) 0
    foreach g $::BUDDYLIST {
        if {$::GROUPS($g,type) == "AIM"} {
            foreach j $::GROUPS($g,people) {
                incr ::GROUPS(Offline,totalbuddies)
                if {$::BUDDIES($j,online) == "F"} {
                    lappend ::GROUPS(Offline,people) $j
		    set ::BUDDIES($j,doubleClick) OfflineDoubleClick
			set ::BUDDIES($j,popupText) [list \
				$j \n \
				Status: Offline]
		    incr ::GROUPS(Offline,total)
		}
	    }
	}
    }
}

 proc tik_draw_list { {clearFirst T}} {
    tik_update_offline
    if {![winfo exists .buddy.list]} {
        return
    }

    sag::icons_enable .buddy.list $::TIK(options,showicons)

    if {$clearFirst != "F"} {
        sag::remove_all .buddy.list
        foreach i $::BUDDYLIST {
            foreach j $::GROUPS($i,people) {
                set ::BUDDIES($j,indexs) ""
            }
        }
    }

    set n 0
    foreach i $::BUDDYLIST {
        if {$::TIK(options,showgrouptotals)} {
            if {$i == "Offline"} {
                set totals "($::GROUPS($i,total)/$::GROUPS($i,totalbuddies))"
            } else {
	        set totals "($::GROUPS($i,online)/$::GROUPS($i,total))"
            }
        } else {
            set totals ""
        }

        if {$::TIK(options,showicons)} {
            set indent 16
        } else {
            set indent 0
        }

        incr n
        if {$::GROUPS($i,collapsed) != "T"} {
            if {$clearFirst != "F"} {
                set ::GROUPS($i,index) [sag::add .buddy.list -10 "" "- $i" \
                    $totals \
                    $::TIK(options,groupmcolor) $::TIK(options,groupocolor)]
            }
            foreach j $::GROUPS($i,people) {
                set normj [normalize $::BUDDIES($j,name)]
                set normn [normalize [sag::pos_2_mainstring .buddy.list $n]]
                if {$::BUDDIES($j,online) == "T"} {
                    if {$normj != $normn} {
                        lappend ::BUDDIES($j,indexs) [sag::insert .buddy.list \
                            $n $indent $::BUDDIES($j,icon) $::BUDDIES($j,name) \
                            $::BUDDIES($j,otherString) \
                            $::TIK(options,buddymcolor) $::TIK(options,buddyocolor)]
                    }
                    incr n
                } elseif {$i == "Offline"} {
                    if {$normj != $normn} {
                        lappend ::BUDDIES($j,indexs) [sag::insert .buddy.list \
                            $n $indent "" $::BUDDIES($j,name) \
                            $::BUDDIES($j,otherString) \
                            $::TIK(options,buddymcolor) $::TIK(options,buddyocolor)]
                    }
                    incr n
                } else {
                    if {$normj == $normn} {
                        sag::remove .buddy.list [sag::pos_2_index .buddy.list $n]
                    }
                }
            }
        } else {
            if {$clearFirst != "F"} {
                set ::GROUPS($i,index) [sag::add .buddy.list -10 "" "+ $i" \
                    $totals \
                    $::TIK(options,groupmcolor) $::TIK(options,groupocolor)]
            }
        }
    }
}
