####################
#		   #
# TiK Buddy Logger #
#		   # 
##################################
#				 #
# Jeff Walter			 #
# WWW:    http://walter.dhs.org/ #
# E-Mail: jeff@walter.dhs.org	 #
# AIM:    isk8ca		 #
#				 #
# Amended by MZhang              #
############################################################################
#									   #
# This addin records when your buddies sign on and off.  It is interesting #
# to try to figure out your friends chatting habits, and somewhat hard.	   #
#									   #
# Seeing how this is the first version I know that it looks really bad.	   #
# Hey! Since when was a good UI ever part of the first release of any	   #
# program.  If you have any ideas don't hesitate to e-mail me.  And if for #
# for some reason you find a bug, please send me info.			   #
#									   #
############################################################################
#								      #
# Thankyou open source software!  Without that I would have never     #
# considered making this addin.  Seeing how I learn best from example #
# I have "borrowed" code from two modules: John "FuzzFace" McMahon's  #
# EyeBall, AOL's TiK.tcl file, and AOL's IM Capture package.	      #
#								      #
#######################################################################
#				      #
# Now, the let's have the good stuff! #
#				      #
#######################################

#################################################################################
#										#
#################################################################################

# Set VERSION and VERSDATE using the CVS tags.
namespace eval buddylog {     
  	regexp -- \
	{[0-9]+\.[0-9]+} {@(#)TiK Buddy Logger $Revision: 1.7 $} \
      	::buddylog::VERSION

  	regexp -- { .* } {:$Date: 2001/04/04 20:02:08 $} \
      	::buddylog::VERSDATE
}

tik_default_set options,buddylog,clockformat  "%b %d, %Y at %H:%M:%S"
#tik_default_set options,buddylog,logfile [file join $::TIK(configDir) buddy.log.html]
tik_default_set options,buddylog,use 0

namespace eval buddylog {

    variable info file

    namespace export load unload goOnline goOffline

        proc load {} {
		menu .buddylogMenu -tearoff 0
                .toolsMenu add cascade -label [tik_str P_BUDDYLOG_M] -menu .buddylogMenu
                .buddylogMenu add command -label [tik_str P_BUDDYLOG_M_ABOUT] -command buddylog::about
                .buddylogMenu add checkbutton -label [tik_str P_BUDDYLOG_M_USE] -onvalue 1 -offvalue 0 -variable ::TIK(options,buddylog,use) -command buddylog::enable
        }

	proc enable { {unloading 0} } {
                set time [get_time]
                if {!$unloading && $::TIK(options,buddylog,use)} {
		        toc_unregister_func * UPDATE_BUDDY UPDATE_BUDDY
		        toc_register_func * UPDATE_BUDDY buddylog::UPDATE_BUDDY
		        toc_register_func * UPDATE_BUDDY UPDATE_BUDDY

		        set outstr [concat [tik_str P_BUDDYLOG_LOAD] $time]
		        wbl [add_html_tags "#00008F" $outstr]
                } else {
		        toc_unregister_func * UPDATE_BUDDY buddylog::UPDATE_BUDDY
                        set outstr [concat [tik_str P_BUDDYLOG_UNLOAD] $time]
                        wbl [add_html_tags "#00008F" $outstr]
                }
	}

	proc unload {} {
		toc_unregister_func * UPDATE_BUDDY buddylog::UPDATE_BUDDY
		.toolsMenu delete [tik_str P_BUDDYLOG_M]
		destroy .buddylogMenu
                buddylog::enable 1
	}

	proc goOnline {} {
                buddylog::enable
	}

	proc goOffline {} {
                buddylog::enable 1
	}

	proc UPDATE_BUDDY { cname user online evil signon idle uclass } {
		
		set time [get_time]
    		set bud [normalize $user]
		
	        if {$bud != $::NSCREENNAME} {
			if {$::BUDDIES($bud,online) != $online} {
	        		if {$online == "T"} {
					set out [concat $bud "signed on on " $time]
                			wbl [add_html_tags "#007F00" $out]
            			} else {
					set out [concat $bud "signed off on " $time]
                			wbl [add_html_tags "#7F0000" $out]
            			}
			}
        	}
	}

	proc add_html_tags {color text} {
		set outstrs [concat "<br><b><FONT COLOR=\042$color\042>$text</FONT></b><br>"]
		return $outstrs
	}

	proc open_log_file {} {
            if { [info exists ::TIK(options,buddylog,logfile)] && \
                 [string length $::TIK(options,buddylog,logfile)]} {
                set ::buddylog::file $::TIK(options,buddylog,logfile)
            } else {
                set ::buddylog::file [file join $::TIK(configDir) buddy.log.html]
            }
            if {![file exists $::buddylog::file]} {
                set f [open $::buddylog::file a+]
                puts $f [concat "<html><head><title>Buddy Logger</title>"]
                puts $f "<meta http-equiv=\042Refresh\042 Content=\04210\042>"
                puts $f "</head>"
                puts $f [concat "<BODY BGCOLOR=\042#FFFFFF\042 TEXT=\042#000000\042 LINK=\042#0000FF\042 VLINK=\042#000080\042 ALINK=\042#FF0000\042>"]
                puts $f [concat "<center><b>TiK Buddy Logger</b></center>"]
                puts $f [concat "<hr><br>"]
            } else {
                set f [open $::buddylog::file a+]
            }
            return $f
    	}

	proc wbl { entry } {
          if {![file exists $::TIK(configDir)] || ![file isdirectory $::TIK(configDir)]} {
              puts "buddylog: Loss of log data."
              puts "buddylog: Config directory doesn't exist."
              return
          }
          set f [open_log_file]
          puts $f $entry
          close $f
        }

	proc get_time {} {
		set cfmt $::TIK(options,buddylog,clockformat) 
		regsub -all -- "%i" $cfmt "" cfmt
		set ltime [clock format [clock seconds] -format $cfmt -gmt 0]
		return $ltime
	}

        proc msgbox {msg title} {

                set w .msgBox

                if {[winfo exists $w]} {
                        raise $w
                        return
                }

                toplevel $w -class Tik
                wm title $w $title
                if {$::TIK(options,windowgroup)} {wm group $w .login}

                text  $w.text -width 60 -height 12 -wrap word

                $w.text insert end \
		$msg

                $w.text configure -state disabled

                button $w.back -text "Ok" -command buddylog::boom

                pack $w.back -side bottom
                pack $w.text -fill both -expand 1 -side top

        }

	proc boom {} {
		catch {destroy .msgBox}
	}

	proc about {} {
		set msg [concat "Version 1.1 - Copyright 1999 Jeff Walter\n" \
		"This package is release under the GPL.\n \n \n" \
		"This package is no-where near complete yet.  I still need\n" \
		"to add more menus and a configuration screen.  Doesn't\n" \
		"sound like much, but to a Tcl/Tk novice like me, it might\n" \
		"be a while.\n" \
                "Amended by MZhang."]
		msgbox  $msg "About Buddy Logger"
	}
}

