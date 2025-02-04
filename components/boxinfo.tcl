#############################################################################
#
# Info and directory information in pop-up box
# Cannibalized from eyeball by MZhang
#
#############################################################################
#
# Many thanks to FuzzFace for the eyeball package that I took almost all of
# this code from. It's a drop-in replacement for GOTO_URL
#
#############################################################################

package require http 2.0

namespace eval boxinfo {
        regexp -- \
        {[0-9]+\.[0-9]+} {@(#)boxinfo - Toc Protocol Window $Revision: 1.9 $} \
        ::boxinfo::VERSION

        regexp -- { .* } {:$Date: 2001/01/19 01:21:47 $} \
        ::boxinfo::VERSDATE
}

tik_default_set options,boxinfo,use 1
tik_default_set options,boxinfo,geometry "300x350"

namespace eval boxinfo {
	
	variable info

	namespace export load unload goOnline goOffline update_use

	proc load {} {
		if {$::TIK(options,boxinfo,use)} {
			toc_unregister_func * GOTO_URL GOTO_URL
			toc_register_func * GOTO_URL boxinfo::GOTO_URL
		}

		menu .boxinfoMenu -tearoff 0
		.toolsMenu add cascade -label [tik_str P_BOXINFO_M] -menu .boxinfoMenu
		.boxinfoMenu add checkbutton -label [tik_str P_BOXINFO_M_USE] \
			-onvalue 1 -offvalue 0 -variable ::TIK(options,boxinfo,use) \
			-command "boxinfo::update_use"
	}

	proc unload {} {
		if {$::TIK(options,boxinfo,use)} {
			toc_unregister_func * GOTO_URL boxinfo::GOTO_URL
			toc_register_func * GOTO_URL GOTO_URL
		}
		.toolsMenu delete [tik_str P_BOXINFO_M]
		destroy .boxinfoMenu
	}

	proc goOnline {} {
	}

	proc goOffline {} {
	}

	proc update_use {} {
		if {$::TIK(options,boxinfo,use)} {
			toc_unregister_func * GOTO_URL GOTO_URL
			toc_register_func * GOTO_URL boxinfo::GOTO_URL
		} else {
			toc_unregister_func * GOTO_URL boxinfo::GOTO_URL
			toc_register_func * GOTO_URL GOTO_URL
		}
	}

	proc GOTO_URL { cname window url } {
		set toc $::SELECTEDTOC
		if {[string match "http://*" $url]} {
			tik_show_url $window $url
		} else {
			if {$::USEPROXY != "None"} {
				;# When using a proxy host must be an ip already
				set ip $::TOC($toc,host)
			} else {
				;# Not using socks, look up the peer ip.
				set ip [lindex [sflap::peerinfo $cname] 0]
			}
			set tgtURL "http://$ip:$::TOC($toc,port)/$url"
                  http::geturl $tgtURL -command boxinfo::process
		}
	}

# This parser works well (?) with get info requests
# Still experimental for get directory requests

	proc process {token} {
		upvar #0 $token state
		if {[regexp -- {<H3>Dir Results</H3>} $state(body)]} {
			set dirinfo 1
			set name $state(url)
		} else {
			set dirinfo 0
			regsub -- {.*Username : <B>([\w\d ]+)</B>.*} $state(body) {\1} name
		}
		set nname [normalize $name]
		set w .infobox$nname
		if {![winfo exists $w]} {
			toplevel $w -class Tik
			if {$dirinfo} {
				wm title $w [tik_str P_BOXINFO_DIR]
			} else {
				wm title $w [tik_str P_BOXINFO_INFO $name]
			}
			if {$::TIK(options,windowgroup)} {wm group $w .login}
			set boxinfo::info($nname) [createHTML $w.textF]
			pack $w.textF -fill both -expand 1 -side top
			if {$::TIK(options,iconbuttons)} {
			    button $w.close -image bclose -command [list destroy $w]
			} else {
			    button $w.close -text [tik_str B_CLOSE] -command [list destroy $w]
			}
			pack $w.close -side bottom
			wm geometry $w $::TIK(options,boxinfo,geometry)
		} else {
			$boxinfo::info($nname) configure -state normal
			$boxinfo::info($nname) del 0.0 end
			$boxinfo::info($nname) configure -state disabled
                }
# change the header
		regsub -all -- "<TITLE>"  $state(body) "<B>"      foo 
		regsub -all -- "</TITLE>" $foo         "</B><HR>" foo 
		regsub -all -- "<HEAD>"   $foo         ""         foo 
		regsub -all -- "</HEAD>"  $foo         ""         foo 
		regsub -- {<BODY BGCOLOR=#CCCCCC>} $foo {<BODY>} foo
# change the icon data to text
		regsub -all -- "<IMG SRC=\042aol_icon.gif\042>" $foo \
			 "<BR>Type : <B>AOL User</B>" foo 
		regsub -all -- "<IMG SRC=\042free_icon.gif\042>" $foo \
			 "<BR>Type : <B>Registered Internet User</B>" foo 
		regsub -all -- "<IMG SRC=\042dt_icon.gif\042>" $foo \
			 "<BR>Type : <B>Trial Internet User</B>" foo 
		regsub -all -- "<IMG SRC=\042admin_icon.gif\042>" $foo \
			 "<BR>Type : <B>OSCAR Admin User</B>" foo 
# get rid of the icon legend
		regsub -all -- "<I>Legend:</I>.*" $foo "" foo 
# get rid of CRs
		regsub -all -- "\n" $foo  "" foo 
# Directory Info Code (experimental)
		regsub -all -- "<TABLE>" $foo  ""     foo 
		regsub -all -- "</TABLE>" $foo ""     foo
		regsub -all -- "<H3>"    $foo  "<B>"  foo 
		regsub -all -- "</H3>"   $foo  "</B>" foo
		regsub -all -- "<TR>"    $foo  "<HR>" foo
		regsub -all -- "</TR>"    $foo ""     foo
		regsub -all -- "<TD>"    $foo  ""     foo
		regsub -all -- "</TD>"   $foo  ""     foo
		regsub -all -- "</HTML>.*" $foo "</HTML>" foo
                regsub -all -- \x00 $foo "" foo

# Actually do the output 
		$boxinfo::info($nname) configure -state normal
                catch {set foo [away::expand $foo $::SCREENNAME]}
		addHTML $boxinfo::info($nname) "$foo" 1
		$boxinfo::info($nname) configure -state disabled
		$boxinfo::info($nname) yview moveto 0
            http::cleanup $token
	}
}
