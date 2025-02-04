#############################################################################
#
# TiK Keepalive Package (aka beat)
#
#############################################################################
#
# John "FuzzFace" McMahon
# WWW:    http://www.oaks.yoyodyne.com/tik/
# E-Mail: fuzzface@io.com
# AIM:    FuzzFace00
#
#############################################################################
#
# Provide a heartbeat/keepalive capability in TiK.  Primarily
# useful for those users behind firewalls that time out connections
# if they are perceived to idle.
#
#############################################################################
#
# Many code examples borrowed from other TiK packages.  My thanks
# to all the authors of TiK and the TiK packages.  Ain't open source
# software wonderful!
#
#############################################################################
#
# All packages must be inside a namespace with the
# same name as the file name.
#
# This version of Revision yields an internal package identifier readable
# to the program, even when not using the package manager, as well as
# working with both the `ident(1)' and `what(1)' utilities:
#

namespace eval beat {
	regexp -- \
	{[0-9]+\.[0-9]+} {@(#)beat - TiK Keepalive package $Revision: 1.4 $} \
        ::beat::VERSION

	regexp -- { .* } {:$Date: 2000/07/13 08:20:29 $} \
	::beat::VERSDATE
}

#############################################################################
#############################################################################
#############################################################################
#
# Options the user might want to set.  A user should use
# set ::TIK(options,...), not the tik_default_set
#
#############################################################################
#
# Keepalive Transmission on/off (0=no, 1=yes)
#
tik_default_set options,beat,on		1
#
#---------------------------------------------------------------------------
#
# Time between keepalives (in milliseconds)
#
# This should be set to the highest value possible.  Basically you need
# to balance between sending enough keepalive to actually keep your dial-up,
# firewall, tin can connection up AND not bombarding the TOC server with
# useless keepalives.
#
# This option has a minimum value of 30000 (30 Seconds)
#
tik_default_set options,beat,time	240000
#
#---------------------------------------------------------------------------
#
# Debug messages to stderr (0=no, 1=yes)
#
tik_default_set options,beat,debug	0
#
#---------------------------------------------------------------------------
#
# Send beat times to ticker (0=no, 1=Local Time, 2=UTC, 3=Internet Time)
#
# See www.swatch.com for details on Internet Time.
#
tik_default_set options,beat,ticker	0	
#
#---------------------------------------------------------------------------
#
# Use tearoff menus to control this package
#
# If you are going to use this option, insert the command in 
# ~/.tik/tikpre not in ~/.tik/tikrc.
#
tik_default_set options,beat,rip	0	
#
#############################################################################
#############################################################################
#############################################################################

namespace eval beat {

	variable info

	# Must export at least: load, unload, goOnline, goOffline
	namespace export load unload goOnline goOffline

	# All packages must have a load routine.  This should do most
	# of the setup for the package.  Called only once.

	proc load {} {
	
		if {$::TIK(options,beat,debug)} \
			{puts stderr "Running beat load"} 
		menu .beatMenu -tearoff $::TIK(options,beat,rip) \
			-title "Keepalive - Settings" 
		menu .beatMenu.timer -tearoff $::TIK(options,beat,rip) \
			-title "Keepalive - Transmit Interval" 
		menu .beatMenu.ticker -tearoff $::TIK(options,beat,rip) \
			-title "Keepalive - Ticker Output" 
		.toolsMenu add cascade -label "Keepalive" -menu .beatMenu

#		.beatMenu add command -label "Keepalive Settings" \
#			-state disabled

		.beatMenu add command -label \
			"Changes are NOT saved to ~/.tik/tikrc" -state disabled
		.beatMenu add separator

		.beatMenu add checkbutton -label "Enabled" -onvalue 1 \
		-offvalue 0 -variable ::TIK(options,beat,on) \
		-command beat::resetbeat

		.beatMenu add cascade -label "Transmit Interval" \
		-menu .beatMenu.timer

		.beatMenu.timer add command -label \
			"Use the highest setting that works" -state disabled
		.beatMenu.timer add separator

		.beatMenu.timer add radiobutton -label "30 Seconds" \
			-value 30000 \
		-variable ::TIK(options,beat,time) -command beat::resetbeat

		.beatMenu.timer add radiobutton -label "1 Minute" -value 60000 \
		-variable ::TIK(options,beat,time) -command beat::resetbeat

		.beatMenu.timer add radiobutton -label "2 Minutes" \
			-value 120000 \
		-variable ::TIK(options,beat,time) -command beat::resetbeat

		.beatMenu.timer add radiobutton -label "4 Minutes" \
			-value 240000 \
		-variable ::TIK(options,beat,time) -command beat::resetbeat

		.beatMenu.timer add radiobutton -label "8 Minutes" \
			-value 480000 \
		-variable ::TIK(options,beat,time) -command beat::resetbeat

		.beatMenu.timer add radiobutton -label "16 Minutes" \
			-value 960000 \
		-variable ::TIK(options,beat,time) -command beat::resetbeat

		.beatMenu add cascade -label "Ticker Output" -menu \
			.beatMenu.ticker

		.beatMenu add checkbutton -label \
			"Debug Output to stderr" -onvalue 1 \
		-offvalue 0 -variable ::TIK(options,beat,debug) \
		-command beat::resetbeat

		.beatMenu.ticker add radiobutton -label "OFF" -value 0 \
		-variable ::TIK(options,beat,ticker) -command beat::resetbeat

		.beatMenu.ticker add radiobutton -label "Local Time" -value 1 \
		-variable ::TIK(options,beat,ticker) -command beat::resetbeat

		.beatMenu.ticker add radiobutton -label \
			"UTC (GMT) Time" -value 2 \
		-variable ::TIK(options,beat,ticker) -command beat::resetbeat

		.beatMenu.ticker add radiobutton -label \
			"Internet Time" -value 3 \
		-variable ::TIK(options,beat,ticker) -command beat::resetbeat

		.beatMenu add command -label "About..." \
			-command beat::aboutBox

		if {$::TIK(options,beat,debug)} \
			{puts stderr "Ending beat load" }
	}

	proc aboutBox {} {

		if {$::TIK(options,beat,debug)} {puts stderr "in aboutBox" }

		set w .beatmsg

		if {[winfo exists $w]} {
			raise $w
			if {$::TIK(options,beat,debug)} \
				{puts stderr "Window exists - out of aboutBox" }
			return
		}

		toplevel $w -class Tik
		wm title $w "About beat"
		wm iconname $w "About beat"
		if {$::TIK(options,windowgroup)} {wm group $w .login}

		text  $w.text -width 40 -height 8 -wrap word

		$w.text insert end \
"beat - A keepalive package for TiK\n\nBy John 'FuzzFace' McMahon\nE-mail: fuzzface@io.com\nWeb: http://www.oaks.yoyodyne.com/tik/\n\nVersion: $::beat::VERSION\nDate:   $::beat::VERSDATE UTC (GMT)" 

		$w.text configure -state disabled

		button $w.back -text "Done" -command beat::boom 

		pack $w.back -side bottom
		pack $w.text -fill both -expand 1 -side top
		if {$::TIK(options,beat,debug)} {puts stderr "out of aboutBox" }

	}

	proc boom {} {
		if {$::TIK(options,beat,debug)} {puts stderr "in boom{}" }
		catch {destroy .beatmsg}
		if {$::TIK(options,beat,debug)} {puts stderr "out boom{}" }
	}

    # All pacakges must have goOnline routine.  Called when the user signs
    # on, or if the user is already online when packages loaded.
	proc goOnline {} {

		if {$::TIK(options,beat,debug)} \
			{puts stderr "Running beat goOnline{}"}

		catch { after cancel $beat::info(timer) }

		if { $::TIK(options,beat,on)==0 } {
			if { $::TIK(options,beat,debug) } {
				puts stderr \
				"Not Enabled - Ending beat goOnline{}"
			}
			return
		}

		beat::resetbeat

		if {$::TIK(options,beat,debug)==1} \
			{puts stderr "Enabled - Ending beat goOnline{}"}
	}

  # All packages must have goOffline routine.  Called when the user signs
  # off.  NOT called when the package is unloaded.
	proc goOffline {} {
		if {$::TIK(options,beat,debug) == 1} {
			puts stderr "Running beat goOffline{}"
		}

		catch {after cancel $beat::info(timer)}

		if {$::TIK(options,beat,debug) == 1} {
			puts stderr "Running beat goOffline{}"
		}
	}

  # All packages must have a unload routine.  This should remove everything 
  # the package set up.  This is called before load is called when reloading.
	proc unload {} {
		if {$::TIK(options,beat,debug) == 1} {
			puts stderr "Running beat::unload"
		}
		.toolsMenu delete "Keepalive"
		destroy .beatMenu
		destroy .beatMenu.timer
		destroy .beatMenu.ticker

		set w .beatmsg

		if {[winfo exists $w]} {
			if {$::TIK(options,beat,debug)==1} \
				{puts stderr "Killing the About Box"}
			beat::boom
		}

		if {$::TIK(options,beat,debug) == 1} {
			puts stderr "Leaving beat::unload"
		}
	}

	proc resetbeat {} {

			if {$::TIK(options,beat,debug) == 1} {
			puts stderr "Running beat resetbeat{}"
		}

		catch {after cancel $beat::info(timer)}

#########################################################################
#
# Heavily borrowed from sflap::send
#
#########################################################################
# Target screen name

		set name [normalize $::NSCREENNAME]

		if {$::TIK(options,beat,debug) == 1} {
			puts stderr "- Debug Output      = On"
			puts stderr \
			"- Keepalives        = $::TIK(options,beat,on)"
			puts stderr \
			"- Interval          = $::TIK(options,beat,time)"
			puts stderr \
			"- Ticker output     = $::TIK(options,beat,ticker)"
			puts stderr \
			"- Outsequence       = $sflap::info($name,outseq)"
			puts stderr \
			"- Use Tearoff Menus = $::TIK(options,beat,rip)"
		}

		if {$::TIK(options,beat,on) == 1} {

# Format keepalive packet (The value 5 indicates a keepalive)

set data [binary format "acSSa*c" "*" 5 $sflap::info($name,outseq) 1 "" 0]

# Increment sflap outsequence number

set sflap::info($name,outseq) [expr ($sflap::info($name,outseq)+1)&0xffff]

			if {$::TIK(options,beat,debug) == 1} {
				puts stderr \
			"- New Outsequence   = $sflap::info($name,outseq)"
			}

# Send it & Flush...

puts -nonewline $sflap::info($name,fd) $data
flush $sflap::info($name,fd)

#########################################################################

			set epoch [clock seconds]

			if {$::TIK(options,beat,debug) == 1} {
				set outstring [clock format $epoch -gmt 0]
			puts stderr "- Time Of Day       = $outstring"
			}

			if {$::TIK(options,beat,ticker) == 1} {
				if {[winfo exists .ticker]} {
					ticker::newsflash \
					[clock format $epoch -gmt 0]
				}
			}

			if {$::TIK(options,beat,ticker) == 2} {
				if {[winfo exists .ticker]} {
					ticker::newsflash \
					[clock format $epoch -gmt 1]
				}
			}

			if {$::TIK(options,beat,ticker) == 3} {
				if {[winfo exists .ticker]} {
					set epoch [clock seconds]
					set sincemidnight \
						[expr $epoch%(60*60*24)]
					set adjplusone \
						[expr $sincemidnight+3600]
					set perthousand \
					[expr $adjplusone*1000/(60*60*24)]
					set beats [expr $perthousand%1000]
					ticker::newsflash \
						[format \
						"@%03.0f (Internet Time)" \
						$beats]
				}
			}
			catch {after cancel $beat::info(timer)}

			if {$::TIK(options,beat,debug) == 1} {
				puts stderr "* Starting the timer... "
			}

			if {$::TIK(options,beat,time) < 30000} {
				if {$::TIK(options,beat,debug) == 1} {
					puts stderr \
	"Setting timer to minimum (30 secs), was $::TIK(options,beat,time) ms."
				}
				set ::TIK(options,beat,time) 30000
			}

			set beat::info(timer) \
				[after $::TIK(options,beat,time) \
				beat::resetbeat]
		}

		if {$::TIK(options,beat,debug) == 1} {
			puts stderr "Leaving beat resetbeat{}"
		}
	}
}
