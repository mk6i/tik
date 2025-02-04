# File Control Package
# Written by MZhang
#
# $Revision: 1.7 $

# All packages must be inside a namespace with the
# same name as the file name.

# Set VERSION and VERSDATE using the CVS tags.
namespace eval control {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK File Control package $Revision: 1.7 $} \
      ::control::VERSION
  regexp -- { .* } {:$Date: 2001/01/17 22:39:43 $} \
      ::control::VERSDATE
}


# Options the user might want to set.  A user should use
# set ::TIK(options,...), not the tik_default_set

tik_default_set options,control,use 0
#tik_default_set options,control,file [file join $::TIK(configDir) tik_control]
tik_default_set options,control,time 10000

namespace eval control {

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    variable info

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        menu .controlMenu -tearoff 0
        .toolsMenu add cascade -label [tik_str P_CONTROL_M] -menu .controlMenu
	.controlMenu add checkbutton -label [tik_str P_CONTROL_M_USE]\
		-variable ::TIK(options,control,use)\
		-onvalue 1 -offvalue 0
        control::startup
    }

    # All pacakges must have goOnline routine.  Called when the user signs
    # on, or if the user is already online when packages loaded.
    proc goOnline {} {
    }

    # All pacakges must have goOffline routine.  Called when the user signs
    # off.  NOT called when the package is unloaded.
    proc goOffline {} {
    }

    # All packages must have a unload routine.  This should remove everything 
    # the package set up.  This is called before load is called when reloading.
    proc unload {} {
        catch {after cancel $control::info(chkafter)}
        file delete [file join $::TIK(configDir) tik_control]
        .toolsMenu delete [tik_str P_CONTROL_M]
        destroy .controlMenu
    }

    proc check_control {} {

        set control::info(chkafter) [after $::TIK(options,control,time) control::check_control]
        if {!$::TIK(options,control,use) || ! [file exists $::TIK(options,control,file)]} {
            return
        }

        if {([file attributes $::TIK(SCRIPT,tik.tcl) -owner] != [file attributes $::TIK(options,control,file) -owner]) || ([file attributes $::TIK(options,control,file) -permissions] != "00600")} {
            puts "wrong permissions or owner!"
            return
        }

        set mtime [file mtime $::TIK(options,control,file)]
        if {$mtime != $control::info(mtime)} {
            set control::info(mtime) $mtime
            puts "executing control file instructions"
            catch {source $::TIK(options,control,file)}
        }
    }

    proc startup {} {
        if {![file isdirectory $::TIK(configDir)]} {
            # keep checking until the config directory is created
            after 5000 control::startup
            return
        }
        if {![info exists ::TIK(options,control,file)]} {
            set ::TIK(options,control,file) [file join $::TIK(configDir) tik_control]
        }
        close [open $::TIK(options,control,file) w]
        set control::info(mtime) [file mtime $::TIK(options,control,file)]
        if {$::tcl_platform(platform) == "unix"} {
            file attributes $::TIK(options,control,file) -permissions 00600
            control::check_control
        }
    }

}
