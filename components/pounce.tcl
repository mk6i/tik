# Pounce Package
#
# Monitor users and inform us when they signon.  You can
# auto send an IM or even execute a command when this happens.
#             
# $Revision: 1.4 $

# Copyright (c) 1998-9 America Online, Inc. All Rights Reserved.
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

# All packages must be inside a namespace with the
# same name as the file name.

# Set VERSION and VERSDATE using the CVS tags.
namespace eval pounce {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Pounce package $Revision: 1.4 $} \
      ::pounce::VERSION
  regexp -- { .* } {:$Date: 2000/07/13 08:20:29 $} \
      ::pounce::VERSDATE
}

namespace eval pounce {

    variable info

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline register

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        toc_register_func * UPDATE_BUDDY pounce::UPDATE_BUDDY

        menu .pounceMenu -tearoff 0
        .toolsMenu add cascade -label [tik_str P_POUNCE_M] -menu .pounceMenu
        .pounceMenu add command -label [tik_str P_POUNCE_M_NEW] \
                              -command pounce::editpounce
        .pounceMenu add separator

        if {![info exists ::TIK(SOUND,Pounce)]} {
            set ::TIK(SOUND,Pounce) Pounce.wav
        }
        tik_register_buddy_button_func "AIM" [tik_str P_POUNCE_M_NEW] pounce::neweditpounce
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
        toc_unregister_func * UPDATE_BUDDY pounce::UPDATE_BUDDY
        .toolsMenu delete [tik_str P_POUNCE_M]
        destroy .pounceMenu
        destroy .editPounce
        tik_unregister_buddy_button_func "AIM" [tik_str P_POUNCE_M_NEW]
    }

    #
    # Wed Jun 28 16:02:22 2000 Pagey
    # Added a new parameter "idlepounce". If this is set then the 
    # pounce will happen when the idle time associated with the buddy
    # goes to zero. 
    #
    proc register { user {onlyonce 0} { playsound 1 } {popim 1} {sendim 0}
		    {msg ""} {notaway 1} {execcmd 0} {cmdstr ""} {idlepounce 0} } {
        set pouncing [normalize $user]

        set pounce::info($pouncing,pounce) 1
        set pounce::info($pouncing,user) $user
        set pounce::info($pouncing,playsound) $playsound
        set pounce::info($pouncing,onlyonce) $onlyonce
        set pounce::info($pouncing,popim) $popim
        set pounce::info($pouncing,sendim) $sendim
        set pounce::info($pouncing,msg) $msg
        set pounce::info($pouncing,execcmd) $execcmd
        set pounce::info($pouncing,cmdstr) $cmdstr
	set pounce::info($pouncing,notaway) $notaway	
	set pounce::info($pouncing,idlepounce) $idlepounce

        if { [info exists pounce::info($pouncing,menulabel)] } {
        } else {
            .pounceMenu add command -label $user \
                    -command "pounce::editpounce $pouncing"
            set pounce::info($pouncing,menulabel) $user
        }
    }

    proc UPDATE_BUDDY {name user online evil signon idle uclass} {
        set nuser [normalize $user]
        if {[info exists pounce::info($nuser,pounce)]} {
              if {($pounce::info($nuser,notaway))} {
                if {([string match "??U" $uclass])} {
                  set pounce::info($nuser,pounce) -1
                }
              }
	    #
	    # Wed Jun 28 16:03:56 2000 Pagey
	    # Pounce when the buddy goes online or if the idle time
	    # for the buddy goes to zero and idlepounce is enabled.
	    #
            if { ($pounce::info($nuser,pounce) > 0) && 
		 ( ($online == "T") || 
		   ( ($idle == 0) && 
		     ($online == "T") && 
		     ($pounce::info($nuser,idlepounce)) 
		     ) 
		   ) } {
                if {$pounce::info($nuser,playsound)} {
                    tik_play_sound $::TIK(SOUND,Pounce)
                }
                
                if {$pounce::info($nuser,onlyonce)} {
                    set pounce::info($nuser,pounce) 0
                    .pounceMenu delete $pounce::info($nuser,menulabel)
		    set pounce::info($nuser,notaway) 0
                } else {
                    # Watch for them to log off and then repounce
                    set pounce::info($nuser,pounce) -1
                }

                if {$pounce::info($nuser,popim)} {
                    tik_create_iim $name $user
                }

                if {$pounce::info($nuser,sendim)} {
                    toc_send_im $name $nuser $pounce::info($nuser,msg)
                }

                if {$pounce::info($nuser,execcmd)} {
                    catch {eval exec $pounce::info($nuser,cmdstr)}
                }
            } elseif { ($pounce::info($nuser,pounce) < 0) && 
		       ( ($online == "F") || 
			 ( ($idle > 0)      && 
			   ($online == "T") && 
			   ($pounce::info($nuser,idlepounce)) 
			   ) 
			 ) 
		     } {
                set pounce::info($nuser,pounce) 1
            }
	    if {$pounce::info($nuser,notaway)} {
		set pounce::info($nuser,pounce) 1
	    }
        }
    }

    proc editpounce_ok {user} {
        if {$user != "__NEW__"} {
            return
        }

        if {$pounce::info(__NEW__,user) == ""} {
          return
        }
        set pouncing [normalize $pounce::info(__NEW__,user)]

        set pounce::info($pouncing,pounce) 1
        set pounce::info($pouncing,user) $pounce::info(__NEW__,user)
        set pounce::info($pouncing,playsound) $pounce::info(__NEW__,playsound)
        set pounce::info($pouncing,onlyonce) $pounce::info(__NEW__,onlyonce)
        set pounce::info($pouncing,popim) $pounce::info(__NEW__,popim)
        set pounce::info($pouncing,sendim) $pounce::info(__NEW__,sendim)
        set pounce::info($pouncing,msg) $pounce::info(__NEW__,msg)
        set pounce::info($pouncing,execcmd) $pounce::info(__NEW__,execcmd)
        set pounce::info($pouncing,cmdstr) $pounce::info(__NEW__,cmdstr)
	set pounce::info($pouncing,notaway) $pounce::info(__NEW__,notaway)
	set pounce::info($pouncing,idlepounce) $pounce::info(__NEW__,idlepounce)

        .pounceMenu add command -label $pounce::info(__NEW__,user) \
                              -command "pounce::editpounce $pouncing"
        set pounce::info($pouncing,menulabel) $pounce::info(__NEW__,user)


    }

    proc editpounce_delete {user} {
        set pounce::info($user,pounce) 0
        .pounceMenu delete $pounce::info($user,menulabel)
    }

    proc neweditpounce {cname name} {
      set norm [normalize $name]
      if {((![info exists pounce::info($norm,user)]) || ($pounce::info($norm,pounce) != 1))} {
          pounce::editpounce
          set pouncing "__NEW__"
          set pounce::info($pouncing,user) "$name"
      } else {
          pounce::editpounce $norm
      }
    }

    proc editpounce {{pouncing {__NEW__}}} {
        set w .editpounce

        if {[winfo exists $w]} {
            raise $w
            return
        }

        toplevel $w -class Tik
        if {$pouncing == "__NEW__"} {
            wm title $w [tik_str P_POUNCE_N_TITLE]
            wm iconname $w [tik_str P_POUNCE_N_ICON]
            set pounce::info($pouncing,user) ""
            set pounce::info($pouncing,playsound) 1
            set pounce::info($pouncing,onlyonce) 1
            set pounce::info($pouncing,popim) 1
            set pounce::info($pouncing,sendim) 0
            set pounce::info($pouncing,msg) ""
            set pounce::info($pouncing,execcmd) 0
            set pounce::info($pouncing,cmdstr) ""
	    set pounce::info($pouncing,notaway) 1
	    set pounce::info($pouncing,idlepounce) 0
        } else {
            wm title $w [tik_str P_POUNCE_E_TITLE]
            wm iconname $w [tik_str P_POUNCE_E_ICON]
        }

        if {$::TIK(options,windowgroup)} {wm group $w .login}
        frame $w.toF
        label $w.tolabel -text [tik_str P_POUNCE_E_TO]
        entry $w.to  -textvariable pounce::info($pouncing,user)
        if {$pouncing != "__NEW__"} {
            $w.to configure -state disabled
        }
        pack $w.tolabel $w.to -in $w.toF -side left

        checkbutton $w.popupim -text [tik_str P_POUNCE_E_POPIM] \
            -variable pounce::info($pouncing,popim)
        checkbutton $w.sendim -text [tik_str P_POUNCE_E_IM] \
            -variable pounce::info($pouncing,sendim)
        entry $w.immsg -textvariable pounce::info($pouncing,msg)
        checkbutton $w.sound -text [tik_str P_POUNCE_E_SOUND] \
            -variable pounce::info($pouncing,playsound)
        checkbutton $w.onlyonce -text [tik_str P_POUNCE_E_ONCE] \
            -variable pounce::info($pouncing,onlyonce)
        checkbutton $w.execcmd -text [tik_str P_POUNCE_E_EXEC] \
            -variable pounce::info($pouncing,execcmd)
	checkbutton $w.notaway -text [tik_str P_POUNCE_E_WNOTAWAY] \
	    -variable pounce::info($pouncing,notaway)
	checkbutton $w.idlepounce -text [tik_str P_POUNCE_E_IDLEPOUNCE] \
	    -variable pounce::info($pouncing,idlepounce) 
        entry $w.cmdstr -textvariable pounce::info($pouncing,cmdstr)


	frame $w.pounceBbar
	createBbar $w.pounceBbar $w.immsg $w.to
	pack forget $w.pounceBbar.color
	pack forget $w.pounceBbar.hdr

        frame $w.buttons

	if {$::TIK(options,iconbuttons)} {
	    button $w.ok -image bok \
		    -command "destroy $w; pounce::editpounce_ok $pouncing"
	    if {$pouncing == "__NEW__"} {
		button $w.cancel -image bclose -command [list destroy $w]
	    } else {
		button $w.cancel -image bdelete \
			-command "destroy $w; pounce::editpounce_delete $pouncing"
	    }
	} else {
	    button $w.ok -text [tik_str B_OK] \
		    -command "destroy $w; pounce::editpounce_ok $pouncing"
	    if {$pouncing == "__NEW__"} {
		button $w.cancel -text [tik_str B_CANCEL] -command [list destroy $w]
	    } else {
		button $w.cancel -text [tik_str B_DELETE] \
			-command "destroy $w; pounce::editpounce_delete $pouncing"
	    }
	}

	pack $w.ok $w.cancel -in $w.buttons -side left -padx 2m
        pack $w.toF -side top
        pack $w.popupim $w.sendim -side top -anchor w -padx 15
	pack $w.pounceBbar
        pack $w.immsg -side top -expand 1 -fill x -anchor w
        pack $w.sound $w.onlyonce $w.notaway $w.execcmd -side top -anchor w -padx 15
        pack $w.cmdstr -side top -expand 1 -fill x -anchor w
        pack $w.idlepounce -side top -expand 1 -fill x -anchor w
        pack $w.buttons -side bottom
        focus $w.to
    }
}

#######################################################################
# QuickPounce and PounceRightOff:
# sloppy, inelegant abominations brought to you by Daspek
######################################################################
proc pounceRightOff {name} {
puts "You just pounced right off a cliff. Feature not yet implemented."
}

proc newqpounce {cname name} {
    set norm [normalize $name]
    if {((![info exists pounce::info($norm,user)]) || ($pounce::info($norm,pounce) != 1))} {
	quickpounce
	set pouncing "__NEW__"
	set pounce::info($pouncing,user) "$name"
    } else {
	quickpounce $norm
    }
}


proc quickpounce {{pouncing {__NEW__}}} {
    set w .quickpounce
    
    if {[winfo exists $w]} {
	raise $w
	return
    }
    
    toplevel $w -class Tik
    if {$pouncing == "__NEW__"} {
	wm title $w [tik_str P_QPOUNCE_N_TITLE]
	wm iconname $w [tik_str P_QPOUNCE_N_ICON]
	set pounce::info($pouncing,user) ""
	set pounce::info($pouncing,playsound) 1
	set pounce::info($pouncing,onlyonce) 1
	set pounce::info($pouncing,popim) 0
	set pounce::info($pouncing,sendim) 1
	set pounce::info($pouncing,msg) ""
	set pounce::info($pouncing,execcmd) 0
	set pounce::info($pouncing,cmdstr) ""
	set pounce::info($pouncing,notaway) 1
	set pounce::info($pouncing,idlepounce) 0
    } else {
	wm title $w [tik_str P_QPOUNCE_N_TITLE]
	wm iconname $w [tik_str P_QPOUNCE_N_ICON]
    }
    
    frame $w.heading
    frame $w.qpounceBbar
    frame $w.bottom
    label $w.heading.top -text [tik_str P_QPOUNCE_M]
    label $w.bottom.msg -text [tik_str P_QPOUNCE_MSG]
    pack $w.heading.top -in $w.heading
    pack $w.bottom.msg -in $w.bottom

    if {$::TIK(options,windowgroup)} {wm group $w .login}
    frame $w.toF
    label $w.tolabel -text [tik_str P_QPOUNCE_E_TO]
    entry $w.to  -textvariable pounce::info($pouncing,user)
    if {$pouncing != "__NEW__"} {
	$w.to configure -state disabled
    }
    pack $w.tolabel $w.to -in $w.toF -side left
    
    checkbutton $w.popupim -text [tik_str P_POUNCE_E_POPIM] \
	    -variable pounce::info($pouncing,popim)
    checkbutton $w.sendim -text [tik_str P_POUNCE_E_IM] \
	    -variable pounce::info($pouncing,sendim)
    

    # use createINPUT to make a multiline text entry like that of the initial im box
    # BUT! this doesnt seem to work because pounce requires an 'entry' widget
    #set pounce::info($pouncing,msg) [createINPUT $w.immsg iimheight]

    entry $w.immsg -textvariable pounce::info($pouncing,msg) 
	

    createBbar $w.qpounceBbar $w.immsg $w.to
    pack forget $w.qpounceBbar.color
    pack forget $w.qpounceBbar.hdr
        ##########################################################
        # Since we're going for a relatively simple quick pounce,
	# all the selections for these fancy features have been
	# commented out.
	##########################################################
	#checkbutton $w.sound -text [tik_str P_POUNCE_E_SOUND] \
	#	-variable pounce::info($pouncing,playsound)
	#checkbutton $w.onlyonce -text [tik_str P_POUNCE_E_ONCE] \
	#	 -variable pounce::info($pouncing,onlyonce)
	#checkbutton $w.execcmd -text [tik_str P_POUNCE_E_EXEC] \
	#	-variable pounce::info($pouncing,execcmd)
	#checkbutton $w.notaway -text "Pounce While Not Away" \
	#	-variable pounce::info($pouncing,notaway)
	#entry $w.cmdstr -textvariable pounce::info($pouncing,cmdstr)
	#############################################################
    frame $w.buttons

    if {$::TIK(options,iconbuttons)} {
	button $w.ok -image bok \
		-command "destroy $w; pounce::editpounce_ok $pouncing"
	if {$pouncing == "__NEW__"} {
	    button $w.cancel -image bclose -command [list destroy $w]
	} else {
	    button $w.cancel -image bdelete \
		    -command "destroy $w; pounce::editpounce_delete $pouncing"
	}
    } else {
	button $w.ok -text [tik_str B_OK] \
		-command "destroy $w; pounce::editpounce_ok $pouncing"
	if {$pouncing == "__NEW__"} {
	    button $w.cancel -text [tik_str B_CANCEL] -command [list destroy $w]
	} else {
	    button $w.cancel -text [tik_str B_DELETE] \
		    -command "destroy $w; pounce::editpounce_delete $pouncing"
	}
    }
    pack $w.ok $w.cancel -in $w.buttons -side left -padx 2m
    
    pack $w.heading $w.toF -side top
    # pack $w.popupim $w.sendim -side top -anchor w -padx 15
    pack $w.qpounceBbar
    pack $w.immsg -side top -expand 1 -fill x -anchor w
    # pack $w.sound $w.notaway -side top -anchor w -padx 15
    # pack $w.cmdstr -side top -expand 1 -fill x -anchor w
    pack $w.buttons
    pack $w.bottom -side bottom
    focus $w.immsg


    #set pounce::info($pouncing,msg) "$header pounce::info($pouncing,msg)"

    # bind buttons abiding by the preferences
    if { [expr {$::TIK(options,msgsend) & 1} ] == 1} {
        bind $w.immsg <Return> "destroy $w; pounce::editpounce_ok $pouncing"
    }
    if { [expr {$::TIK(options,msgsend) & 2} ] == 2} {
        bind $w.immsg <Control-Return> "destroy $w; pounce::editpounce_ok $pouncing"
    } else {
        bind $w.immsg <Control-Return> " "
    }
}
