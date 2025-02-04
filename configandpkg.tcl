# Routines to monitor config files and packages
#######################################################

# Since it doesn't seem pkgrc is currently being used, I
# decided to steal it for the place TiK looks to see the
# desired load preference for packages.  If you don't want
# TiK to load a package place the following in pkgrc:
#
# set ::TIK(options,$pkgname,load) 0
#
#    where $pkgname is the name of the package you don't
#    want to load.

proc tik_source_pkgrc {} {
    if {[file exists $::TIK(pkgfile)]} {
        catch {source $::TIK(pkgfile)}
    }
}

proc tik_source_rc {} {
    set temp $::SCREENNAME
    source $::TIK(rcfile)
    set ::SCREENNAME $temp
}

# tik_check_rc --
#     Montior the ~/.tik/tikrc file for changes.  The method
#     is called by a timer.

proc tik_check_rc {} {
    after $::TIK(options,monitorrctime) tik_check_rc
    if { ! $::TIK(options,monitorrc) || ! [file exists $::TIK(rcfile)] } {
        return
    }

    file stat $::TIK(rcfile) vals

    if {$vals(mtime) != $::TIK(rcfile,mtime)} {
        puts "$::TIK(rcfile) changed, reloading."
        set ::TIK(rcfile,mtime) $vals(mtime)
        tik_source_rc
    }
    update_unsup

    # Check to see if pkgrc has changed, and if so update it.
    if {[file exists $::TIK(pkgfile)]} {
        file stat $::TIK(pkgfile) vals
        if {$vals(mtime) != $::TIK(pkgfile,mtime)} {
            puts "$::TIK(pkgfile) changed, reloading."
            set ::TIK(pkgfile,mtime) $vals(mtime)
            tik_source_pkgrc
        }
    }
}

# tik_check_pkg --
#     This routine is called to load the packages.  It is also
#     called as a timer callback that checks so often for
#     changes in the packages.
#
# Arguments:
#     timer - 1 if this is a timer callback.
proc tik_check_pkg {{timer {0}}} {
    if {$timer} {
        after $::TIK(options,monitorpkgtime) tik_check_pkg 1
    }

    if { ($timer && ! $::TIK(options,monitorpkg) ) } {
        return
    }

    # Checks official components found in {Main Tik Directory}/components
    set official_comp [tik_check_officialcomp]
    # Checks global packages found in {Main TiK Directory}/packages
    set official_pkg [tik_check_officialpkg] 
    # Checks user-supplied packages found in ~/.tik/packages
    set user_defined_pkg [tik_check_userpkg]
    # Components are not user-specific

    # This part makes sure we take out duplicate package files based on user
    # preferences.  
    if { !($::TIK(packages,user_preferred)) } {
	tik_load_packages [tik_package_nodup $official_comp $user_defined_pkg]
        tik_load_packages [tik_package_nodup $official_pkg $user_defined_pkg]
    } else {
	tik_load_packages [tik_package_nodup $user_defined_pkg $official_comp]
        tik_load_packages [tik_package_nodup $user_defined_pkg $official_pkg]
    }
}

# tik_package_nodup
#   This procedure makes sure that no files from the second input varialbe
#   match any from the first, then returns
proc tik_package_nodup { list1 list2 } {
    set pkg_names ""
    set packages ""
    if { ($list1 == "none") && ($list2 == "none") } {
        return "none"
    }
    if { !($list1 == "none") } {
        foreach file $list1 {
            lappend packages $file
            lappend pkg_names [file rootname [file tail $file]]
        }
    }
    if { !($list2 == "none") } {
        foreach file $list2 {
            if {([lsearch $pkg_names [file rootname [file tail $file]]]) == "-1" } {
                lappend packages $file
            }
        }
    }
    return $packages
}

# Wrapper for official component loading
proc tik_check_officialcomp {} {
    if {![file exists [file join $::TIK(BASEDIR) $::TIK(compDir)]] } {
	return "none"
    }
    set files [lsort -dictionary [glob -nocomplain -- \
	    [file join $::TIK(BASEDIR) $::TIK(compDir) *.tcl]]]
    return $files
}

# Wrapper for global package loading
proc tik_check_officialpkg {} {
    if { ! [file exists [file join $::TIK(BASEDIR) $::TIK(pkgDir)]] } {
        return "none"
    }
    set files [lsort -dictionary [glob -nocomplain -- \
                    [file join $::TIK(BASEDIR) $::TIK(pkgDir) *.tcl]]]
    return $files
}

# Wrapper for user-specified package loading
proc tik_check_userpkg {} {
    if { ! [file exists [file join $::TIK(configDir) $::TIK(pkgDir)]] } {
        return "none"
    }
    set files [lsort -dictionary [glob -nocomplain -- \
                             [file join $::TIK(configDir) $::TIK(pkgDir) *.tcl]]]
    return $files
}

# Main package loader
proc tik_load_packages {files} {
    if { $files == "none" } {
        return
    }
    foreach pkg $files {
        file stat $pkg vals
        set pkgname [file rootname [file tail $pkg] ]
        if {(![info exists ::TIK(options,$pkgname,load)]) || \
              ($::TIK(options,$pkgname,load) == "")} {
            set ::TIK(options,$pkgname,load) 1
        }
        if {!($::TIK(options,$pkgname,load))} {
            if {[info exists ::TIK(pkg,$pkg,mtime)]} {
                unset ::TIK(pkg,$pkg,mtime)
            }
            if {[lsearch [namespace children] ::${pkgname}] != "-1"} {
                catch {${pkgname}::unload}
                namespace delete $pkgname
            }
            continue
        }
        if {![info exists ::TIK(pkg,$pkg,mtime)]} {
            set ::TIK(pkg,$pkg,mtime) $vals(mtime)
            set ::TIK(pkg,$pkg,pkgname) $pkgname
            source $pkg
            ${pkgname}::load
        } elseif {$vals(mtime) != $::TIK(pkg,$pkg,mtime)} {
            puts "Need to reload package $pkgname from $pkg"
            set ::TIK(pkg,$pkg,mtime) $vals(mtime)
            catch {${pkgname}::unload} ;# This should print out 
                                        # the error on failure someday.
            namespace delete $pkgname
            source $pkg
            ${pkgname}::load
            if {$::TIK(online)} {
                ${pkgname}::goOnline
            }
        }
    }
}

proc tik_default_set {var val} {
    if {![info exists ::TIK($var)]} {
        set ::TIK($var) $val
    }
}

# tik_register_filter
#        connName = $::SCREENNAME or *
#        type     = IM_IN, IM_OUT, CHAT_IN, CHAT_OUT
#        func     = name of function being registered

proc tik_register_filter {connName type func} {
    if {$connName != "*"} {
        set connName [normalize $connName]
    }
    lappend ::FILTERS($connName,$type) $func
}

# tik_unregister_filter
#        connName = $::SCREENNAME or *
#        type     = IM_IN, IM_OUT, CHAT_IN, CHAT_OUT
#        func     = name of function being unregistered

proc tik_unregister_filter {connName type func} {
    if {$connName != "*"} {
        set connName [normalize $connName]
    }
    set i [lsearch -exact $::FILTERS($connName,$type) $func]
    if {$i != -1} {
        set ::FILTERS($connName,$type) \
             [lreplace $::FILTERS($connName,$type) $i $i]
    }
}

# tik_unregister_all_filters
#        connName = $::SCREENNAME or *

proc tik_unregister_all_filters {connName} {
    if {$connName != "*"} {
        set connName [normalize $connName]
    } else {
        set connName "\\\*"
    }
    foreach i [array names ::FILTERS "$connName,*"] {
        unset ::FILTERS($i)
    }
}

# tik_getMsgFilters
#        called from tik_filter_msg
#        connName should be $::NSCREENNAME

proc tik_getMsgFilters {connName type} {
    if {[catch {set all $::FILTERS(*,$type)}]} {
        set all [list]
    }
    if {![catch {set b $::FILTERS($connName,$type)}]} {
        return [concat $all $b]
    }
    return $all
}

# tik_filter_msg
#        connName = $::SCREENNAME or *
#        type     = IM_IN, IM_OUT, CHAT_IN, CHAT_OUT
#        msg      = text to be filtered
#        args     = any extra arguments for filter

proc tik_filter_msg {connName type msg args} {
    if {$connName != "*"} {
        set connName [normalize $connName]
    }
    set funcs [tik_getMsgFilters $connName $type]
    foreach i $funcs {
        set msg [$i $connName $msg $args]
    }
    return $msg
}

