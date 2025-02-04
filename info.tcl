# Routines for INFO
#######################################################

proc tik_set_info {info} {
    set ::TIK(INFO,msg) $info
    set ::TIK(INFO,sendinfo) 1
}

proc p_tik_setinfo_set {} {
    if {![winfo exists .setinfo.text]} {
        return
    }

    set ::TIK(INFO,msg) [.setinfo.text get 0.0 end]
    set ::TIK(INFO,sendinfo) 1
    toc_set_info $::NSCREENNAME $::TIK(INFO,msg)
    destroy .setinfo
}

proc tik_show_version {} {
    global env tcl_platform
    set w .showver

    if {[winfo exists $w]} {
            raise $w
            return
    }

    toplevel $w -class Tik
    wm title $w [tik_str ABOUT_TITLE $::VERSION]
    wm iconname $w [tik_str ABOUT_ICON $::VERSION]

    label .showver.logo -image logo
    label .showver.status


    label $w.info1 -text [tik_str INFO_L1]
    label $w.info2 -text [tik_str INFO_L2 $::VERSION]
    if {[string equal unix $tcl_platform(platform)]} {
      label $w.info3 -text [format {%s / %s} [info hostname] $env(DISPLAY)]
    }
    label $w.info4 -text [tik_str INFO_L3 $::tcl_patchLevel]
    label $w.info5 -text [tik_str INFO_L4 $::tk_patchLevel]

    if {$::UNSUPPORTED} {
	label $w.unsupported -text \
		"You are running an old version of\n\
		Tcl/Tk and, consequently, some features\n\
		(smileys and the preprocessor) may be\n\
		disabled, either fully or partially,\n\
		and/or not work properly.\n\n\
		Please get the latest Tcl/Tk at\n\
		http://dev.scriptics.com"
    }

    sag::init $w.list 300 100 1 $:::SAGFONT #a9a9a9 $::TIK(options,sagborderwidth)

    set pkglist [list ]
    foreach {pkg name} [array get ::TIK pkg,*,pkgname] {
        lappend pkglist $name
    }

    set pkglist [lsort -dictionary $pkglist]

    foreach {name} $pkglist {
        set version "*UNKNOWN*"
        set versdate "*UNKNOWN*"
        set ocolor red
        catch {
            set version [set ${name}::VERSION]
            set versdate [set ${name}::VERSDATE]
            set ocolor black
        }
        sag::add $w.list 0 "" $name "$version ($versdate)" black $ocolor
    }

    frame $w.buttons
    button $w.cancel -text [tik_str B_OK] -command [list destroy $w]
    pack $w.cancel -in $w.buttons -side left -padx 2m
    pack .showver.logo .showver.status
    pack $w.info1 -side top
    pack $w.info2 -side top
    if {[string equal unix $tcl_platform(platform)]} {
      catch {pack $w.info3 -side top}
    }
    pack $w.info4 -side top
    pack $w.info5 -side top
    if {$::UNSUPPORTED} {
	pack $w.unsupported -side top
    }
    pack $w.buttons -side bottom
    pack $w.list -fill both -expand 1 -padx 2m -side top
}


proc tik_create_setinfo {} {
    set w .setinfo

    if {[winfo exists $w]} {
        raise $w
        return
    }

    toplevel $w -class Tik
    wm title $w [tik_str INFO_TITLE]
    wm iconname $w [tik_str INFO_ICON]
    if {$::TIK(options,windowgroup)} {wm group $w .login}

    text  $w.text -width 40 -height 10 -wrap word
    $w.text insert end $::TIK(INFO,msg)

    label $w.info -text [tik_str INFO_MSG]
    frame $w.buttons
    button $w.set -text [tik_str B_SETINFO] -command "p_tik_setinfo_set"
    button $w.cancel -text [tik_str B_CANCEL] -command [list destroy $w]
    pack $w.set $w.cancel -in $w.buttons -side left -padx 2m

    pack $w.info -side top
    pack $w.buttons -side bottom
    pack $w.text -fill both -expand 1 -side top
}

proc tik_update_dynamic_info {} {
    if {$::TIK(INFO,updatedynamicinfo)} {
	catch {after cancel $::dyninfotimer}
	set ::dyninfotimer [after [expr $::TIK(INFO,dynupdateinterval) * 60000] tik_update_dynamic_info]
	toc_set_info $::NSCREENNAME $::TIK(INFO,msg)
    }
}
