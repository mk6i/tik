# Routines for IM Conversations

#proc tik_close_ims {} {
#    foreach i [array names ::TIK "imconvs,*toplevel*"] {
#        set name [lindex [split $i {,}] 1]
#        destroy .imConv$name
#    }
#}

proc p_tik_cim_send {name} {
    set w $::TIK(imconvs,$name,msgw)
    if { $::TIK(options,cimheight) == 0} {
        set xmsg [string trimright [$w get]]
    } else {
        set xmsg [string trimright [$w get 0.0 end]]
    }

    set header [string trim [.imConv$name.imBbar.hdr get]]
##########################################################
# if someone wants the footer box back...
#    set footer [string trim [.imConv$name.bbar.ftr get]]
##########################################################
    set ::TIK(imconvs,$name,lasttyped) $xmsg
    
    set msg [tik_filter_msg $::SCREENNAME IM_OUT $xmsg]
    
    if { [string length $msg] == 0 &&
            [string length $xmsg] != 0} {
        if { $::TIK(options,cimheight) == 0} {
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

    set msg "$header$msg"

    if {$::TIK(options,imcolor)} {
        set msg "<FONT COLOR=\"$::TIK(imconvs,$name,color)\">$msg</FONT>"
    }

    if { [string length $msg] > 1950 } {
        tk_messageBox -type ok -message [tik_str E_MSGLONG]
        return
    }

    toc_send_im $::NSCREENNAME $::TIK(imconvs,$name,name) $msg

    if { $::TIK(options,cimheight) == 0} {
        $w delete 0 end
    } else {
        $w delete 0.0 end
    }

## Raise buttons in bar. i could not use $w because it is defined
## differently in this proc than in the below proc
    if {$::TIK(options,buttonbar)} {
	set nname [normalize $name]
	.imConv$nname.imBbar.b configure -relief flat
	.imConv$nname.imBbar.u configure -relief flat
	.imConv$nname.imBbar.i configure -relief flat
	.imConv$nname.imBbar.s configure -relief flat
	.imConv$nname.imBbar.f configure -relief flat
    }
}

proc p_tik_cim_out {connName nick auto msg} {
    tik_receive_im $nick noauto $msg T
}

proc tik_msg_cim {name msg} {
    set nname [normalize $name]

    set w .imConv$nname
    if {![winfo exists $w]} {
        return
    }

    set wt $::TIK(imconvs,$nname,textw)
    $wt configure -state normal
    set tstr [clock format [clock seconds] -format [tik_str CIM_TIMESTAMP]]
    addHTML $wt $msg
    $wt configure -state disabled
}

proc tik_signoff_cim_msgs {} {
    foreach i [array names ::TIK "imconvs,*toplevel*"] {
        set name [lindex [split $i {,}] 1]
        set tstr [clock format [clock seconds] -format [tik_str CIM_TIMESTAMP]]
	tik_msg_cim $name [tik_str CIM_U_LOGOFF $::SCREENNAME $tstr]
    }
}

proc tik_title_cim {name {oonline {UKN}} } {
    set nname [normalize $name]

    set w .imConv$nname
    if {![winfo exists $w]} {
        return
    }

    if {($oonline != "UKN") && ($oonline != $::BUDDIES($nname,online))} {
        set tstr [clock format [clock seconds] -format [tik_str CIM_TIMESTAMP]]
        if {$oonline == "T"} {
            tik_msg_cim $name [tik_str CIM_LOGOFF $name $tstr]
        } else {
            tik_msg_cim $name [tik_str CIM_LOGON $name $tstr]
        }
    }

    set extra [tik_str CIM_EXTRA00]

    catch {
        if {$::BUDDIES($nname,idle) != 0} {
            if {$::BUDDIES($nname,evil) != 0} {
                set extra [tik_str CIM_EXTRA11 $::BUDDIES($nname,idle)\
                              $::BUDDIES($nname,evil)]
            } else {
                set extra [tik_str CIM_EXTRA10 $::BUDDIES($nname,idle)]
            }
        } elseif {$::BUDDIES($nname,evil) != 0} {
            set extra [tik_str CIM_EXTRA01 $::BUDDIES($nname,evil)]
        }
    }

    if {$::TIK(imconvs,$nname,receiveLast)} {
        wm title $w [tik_str CIM_RTITLE $name $extra]
        wm iconname $w [tik_str CIM_RICON $name $extra]
    } else {
        wm title $w [tik_str CIM_STITLE $name $extra]
        wm iconname $w [tik_str CIM_SICON $name $extra]
    }
}

proc tik_update_cim_buttons {} {
    foreach i [array names ::TIK "imconvs,*toplevel*"] {
        set name [lindex [split $i {,}] 1]
        set w .imConv$name
	if {[winfo exists $w]} {
            if {$::TIK(options,iconbuttons)} {
                $w.info configure -image binfo
                $w.warn configure -image bwarn
                $w.send configure -image bsend
	        $w.close configure -image bclose
	        $w.block configure -image bblock
		catch {$w.add configure -image badd}
            } else {
	        $w.info configure -image "" -text [tik_str B_INFO]
	        $w.warn configure -image "" -text [tik_str B_WARN]
	        $w.send configure -image "" -text [tik_str B_SEND]
	        $w.close configure -image "" -text [tik_str B_CLOSE]
	        $w.block configure -image "" -text [tik_str B_BLOCK]
		catch {$w.add configure -image "" -text [tik_str B_ADD]}
            }

	    balloonhelp $w.info  [tik_str TOOLTIP_B_INFO]
	    balloonhelp $w.warn  [tik_str TOOLTIP_B_WARN]
	    balloonhelp $w.send  [tik_str TOOLTIP_B_SEND]
	    balloonhelp $w.close [tik_str TOOLTIP_B_CLOSE]
	    balloonhelp $w.block [tik_str TOOLTIP_B_BLOCK]
	    balloonhelp $w.add   [tik_str TOOLTIP_B_ADD]

        }
    }
    tik_update_other_buttons
}

proc tik_update_other_buttons {} {
    foreach i [array names ::TIK "chats,*name*"] {
        set id [lindex [split $i {,}] 1]
        set w .chats$id
        if {[winfo exists $w]} {
            if {$::TIK(options,iconbuttons)} {
                $w.send configure -image bsend
                $w.whisper configure -image bwhisper
                $w.ignore configure -image bignore
                $w.info configure -image binfo
                $w.im configure -image bim
                $w.invite configure -image binvite
                $w.close configure -image bclose
		$w.add configure -image badd
            } else {
                $w.send configure -image "" -text [tik_str B_SEND]
                $w.whisper configure -image "" -text [tik_str B_WHISPER]
                $w.ignore configure -image "" -text [tik_str B_IGNORE]
                $w.info configure -image "" -text [tik_str B_INFO]
                $w.im configure -image "" -text [tik_str B_IM]
                $w.invite configure -image "" -text [tik_str B_INVITE]
                $w.close configure -image "" -text [tik_str B_CLOSE]
		$w.add configure -image "" -text [tik_str B_ADD]
            }

	    balloonhelp $w.send        [tik_str TOOLTIP_B_SEND]
	    balloonhelp $w.whisper     [tik_str TOOLTIP_B_WHISPER]
	    balloonhelp $w.ignore      [tik_str TOOLTIP_B_IGNORE]
	    balloonhelp $w.info        [tik_str TOOLTIP_B_INFO]
	    balloonhelp $w.im          [tik_str TOOLTIP_B_IM]
	    balloonhelp $w.invite      [tik_str TOOLTIP_B_INVITE]
	    balloonhelp $w.close       [tik_str TOOLTIP_B_CLOSE]
	    balloonhelp $w.add         [tik_str TOOLTIP_B_ADD]

        }
    }
    set cnt 0
    catch {set cnt $::TIK(iims,cnt)}
    for {set i 0} {$i < $cnt} {incr i} {
        set w .iim$i
        if {[winfo exists $w]} {
            if {$::TIK(options,iconbuttons)} {
                $w.send configure -image bsend
                $w.cancel configure -image bclose
            } else {
                $w.send configure -image "" -text [tik_str B_SEND]
                $w.cancel configure -image "" -text [tik_str B_CANCEL]
            }

	    balloonhelp $w.send     [tik_str TOOLTIP_B_SEND]
	    balloonhelp $w.cancel   [tik_str TOOLTIP_B_CANCEL]
        }
    }
}

proc tik_update_buttonbar {} {
    foreach i [array names ::TIK "imconvs,*toplevel*"] {
        set name [lindex [split $i {,}] 1]
	set w .imConv$name
	if {[winfo exists $w]} {
	    if {$::TIK(options,buttonbar)} {
	        pack $w.imBbar -fill x -padx 1
            } else {
	        pack forget $w.imBbar
            }
        }
    }
    foreach i [array names ::TIK "chats,*name*"] {
        set id [lindex [split $i {,}] 1]
        set w .chats$id
        if {[winfo exists $w]} {
            if {$::TIK(options,buttonbar)} {
                pack $w.chatBbar -in $w.left -fill both -expand 1 -side top
            } else {
                pack forget $w.chatBbar
            }
        }
    }
    set cnt 0
    catch {set cnt $::TIK(iims,cnt)}
    for {set i 0} {$i < $cnt} {incr i} {
        set w .iim$i
        if {[winfo exists $w]} {
            if {$::TIK(options,buttonbar)} {
                pack forget $w.iimBbar.color
                pack $w.iimBbar -padx 1 -expand 1 -after $w.top
            } else {
                pack forget $w.iimBbar
            }
        }
    }
}
#####################################################################################################
    proc toggle {button w} {       
        if {[$w.$button cget -relief] == "flat"} {
            $w.$button configure -relief sunken                            
     
        } else {
            $w.$button configure -relief flat
        }
    }

    proc tagput {button w mw tag} {
        if {[$w.$button cget -relief] == "sunken"} {
            $mw insert insert "<$tag>"
        } else {
            $mw insert insert "</$tag>"
        }
    }

    proc emotiput {mw smiley} {
	$mw insert insert " $smiley"
    }

    proc fontput {w mw} {
	if {[$w.f cget -relief] == "sunken"} {
	    # scales make the variable global automatically. sowwy :(
	    global fsize
	    $mw insert end "<font size=\"$fsize\">"
	} else {
	    $mw insert end "</font>"
	}
    }

    proc createBbar {w mw nname} {
	# make sure you declare $w.bbar before you call the createBbar proc
	# w must be the _FULL WINDOW NAME_
	# nname is, naturally, the normalized name of the buddy

	entry $w.hdr -font ::NORMALFONT -width 10
	$w.hdr insert end $::TIK(options,Font,defheader)
	balloonhelp $w.hdr [tik_str TOOLTIP_DEF_HEADER]

	button $w.b -text "B" -relief flat -image bbold -command "toggle b $w; tagput b $w $mw b"      
	balloonhelp $w.b [tik_str TOOLTIP_B_BOLD]

	button $w.i -text "I" -relief flat -image bitalic -command "toggle i $w; tagput i $w $mw i"
	balloonhelp $w.i [tik_str TOOLTIP_B_ITALICS]

	button $w.u -text "U" -relief flat -image bunderline -command "toggle u $w; tagput u $w $mw u"        
	balloonhelp $w.u [tik_str TOOLTIP_B_UNDERLINE]
	
	button $w.s -text "S" -relief flat -image bstrike -command "toggle s $w; tagput s $w $mw s"
	balloonhelp $w.s [tik_str TOOLTIP_B_STRIKEOUT]
	
	button $w.f -text "F" -relief flat -image bfont -command "toggle f $w; fontput $w $mw"
	balloonhelp $w.f        [tik_str TOOLTIP_B_FONTSIZE]

	# scales make the variable global automatically
	scale $w.fontsize -from 0 -to 72 -length 72 -variable fsize -orient horizontal -tickinterval 24 \
		-showvalue false -width 4 -sliderrelief solid -borderwidth 1 -sliderlength 7 -font {-size 8} -state normal
	balloonhelp $w.fontsize [tik_str TOOLTIP_B_FONTSIZE]

	set ::TIK(imconvs,$nname,color) $::TIK(options,defaultimcolor)
	button $w.color -relief flat -image bcolor -command  [list tik_set_color imconvs [tik_str CIM_COL_TITLE] $nname]
	balloonhelp $w.color [tik_str TOOLTIP_B_FONTCOLOR]
	
	####### NOTE ##############################
	# for every additional button added, make #
	# sure you raise it up upon message send. #
	# --daspek                                #
	###########################################
	
	menubutton $w.e -text "E" -image bsmile -relief flat -menu $w.e.emenu
	balloonhelp $w.e [tik_str TOOLTIP_B_SMILEY]

	menu $w.e.emenu -tearoff 0
	$w.e.emenu add command -hidemargin 1 -image smile.gif -command "emotiput $mw \":-)\"" -columnbreak 1
	bind $mw <Control-KeyPress-1> "emotiput $mw \":-)\""
	$w.e.emenu add command -hidemargin 1 -image sad.gif -command "emotiput $mw \":-(\""
	bind $mw <Control-KeyPress-2> "emotiput $mw \":-(\""
	$w.e.emenu add command -hidemargin 1 -image wink.gif -command "emotiput $mw \";-)\""
	bind $mw <Control-KeyPress-3> "emotiput $mw \";-)\""
	$w.e.emenu add command -hidemargin 1 -image tongue.gif -command "emotiput $mw \":-p\""
	bind $mw <Control-KeyPress-4> "emotiput $mw \":-p\""
	$w.e.emenu add command -hidemargin 1 -image scream.gif -command "emotiput $mw \"=-O\"" -columnbreak 1
	bind $mw <Control-KeyPress-5> "emotiput $mw \"=-O\""
	$w.e.emenu add command -hidemargin 1 -image kiss.gif -command "emotiput $mw \":-*\""
	bind $mw <Control-KeyPress-6> "emotiput $mw \":-*\""
	$w.e.emenu add command -hidemargin 1 -image yell.gif -command "emotiput $mw \">:o\""
	bind $mw <Control-KeyPress-7> "emotiput $mw \">:o\""
	$w.e.emenu add command -hidemargin 1 -image smile8.gif -command "emotiput $mw \"8-)\""
	bind $mw <Control-KeyPress-8> "emotiput $mw \"8-)\""
	$w.e.emenu add command -hidemargin 1 -image moneymouth.gif -command "emotiput $mw \":-$\"" -columnbreak 1
	bind $mw <Control--KeyPress-exclam> "emotiput $mw \":-$\""
	$w.e.emenu add command -hidemargin 1 -image burp.gif -command "emotiput $mw \":-!\""
	bind $mw <Control-KeyPress-at> "emotiput $mw \":-!\""
	$w.e.emenu add command -hidemargin 1 -image embarrassed.gif -command "eval {emotiput $mw :-\\\[}"
	bind $mw <Control-KeyPress-numbersign> "eval {emotiput $mw :-\\\[}"
	$w.e.emenu add command -hidemargin 1 -image angel.gif -command "emotiput $mw \"O:-)\""
	bind $mw <Control-KeyPress-dollar> "emotiput $mw \"0:-)\""
	$w.e.emenu add command -hidemargin 1 -image think.gif -command "eval {emotiput $mw :-\\\\}" -columnbreak 1
	bind $mw <Control-KeyPress-percent> "eval {emotiput $mw :-\\\\}"
	$w.e.emenu add command -hidemargin 1 -image cry.gif -command "emotiput $mw \":\'\(\""
	bind $mw <Control-KeyPress-asciicircum> "emotiput $mw \":\'\(\""
	$w.e.emenu add command -hidemargin 1 -image crossedlips.gif -command "emotiput $mw \":-X\""
	bind $mw <Control-KeyPress-ampersand> "emotiput $mw \":-X\""
	$w.e.emenu add command -hidemargin 1 -image bigsmile.gif -command "emotiput $mw \":-D\""
	bind $mw <Control-KeyPress-asterisk> "emotiput $mw \":-D\""

	bind $mw <Alt-i> "$w.i invoke"
	bind $mw <Alt-b> "$w.b invoke"
	bind $mw <Alt-u> "$w.u invoke"
	bind $mw <Alt-f> "$w.f invoke"
	bind $mw <Alt-s> "$w.s invoke"
	bind $mw <Alt-comma> {global fsize; set fsize [expr "$fsize-4"]}
	bind $mw <Alt-period> {global fsize; set fsize [expr "$fsize+4"]}

	if {$::TIK(options,buttonbar)} {
	    pack $w.hdr -side left
	    pack $w.b -side left
	    pack $w.i -side left
	    pack $w.u -side left
	    pack $w.s -side left
	    pack $w.f -side left
	    pack $w.fontsize -side left
	    if {$::TIK(options,imcolor)} {  
		pack $w.color -side left
	    }
	    pack $w.e -side left
	    
	}
    }
	
######################################################################################################
proc tik_create_cim {name} {
    set nname [normalize $name]

    set w .imConv$nname
    if {[winfo exists $w]} {
        tik_title_cim $name
        return
    }

    toplevel $w -class $::TIK(options,imWMClass)
    if {$::TIK(options,windowgroup)} {wm group $w .login}

    if {$::TIK(imconvs,$nname,receiveLast)} {
        set ::TIK(imconvs,$nname,initial) 1
    } else {
        set ::TIK(imconvs,$nname,initial) 0
    }                                                       

    set ::TIK(imconvs,$nname,name) $name
    set ::TIK(imconvs,$nname,toplevel) $w
    set ::TIK(imconvs,$nname,textw) [createHTML $w.textF]
    set ::TIK(imconvs,$nname,flashing) 0
    set ::TIK(imconvs,$nname,background) [$w.textF.textS cget -background]

    set mw [createINPUT $w.msgArea cimheight]
    set ::TIK(imconvs,$nname,msgw) $mw

    frame $w.buttonF

    if {$::TIK(options,iconbuttons)} {
        button $w.info -image binfo -command [list toc_get_info $::NSCREENNAME $nname]
	button $w.warn -image bwarn -command [list tik_create_warn $name F]
        button $w.send -image bsend -command "p_tik_cim_send $nname"
        button $w.close -image bclose -command [list destroy $w]
	button $w.add -image badd -command "tik_create_add buddy \"$name\";destroy $w.add"
	
	

    } else {
        button $w.info -text [tik_str B_INFO] -command [list toc_get_info $::NSCREENNAME $nname]
        button $w.warn -text [tik_str B_WARN] -command [list tik_create_warn $name F]
        button $w.send -text [tik_str B_SEND] -command "p_tik_cim_send $nname"
        button $w.close -text [tik_str B_CLOSE] -command [list destroy $w]
	button $w.add -text [tik_str B_ADD] -command "tik_create_add buddy \"$name\";destroy $w.add"
    }
    
    balloonhelp $w.info  [tik_str TOOLTIP_B_INFO]
    balloonhelp $w.warn  [tik_str TOOLTIP_B_WARN]
    balloonhelp $w.send  [tik_str TOOLTIP_B_SEND]
    balloonhelp $w.close [tik_str TOOLTIP_B_CLOSE]
    balloonhelp $w.add   [tik_str TOOLTIP_B_ADD]

    bind $w <Control-l> [list toc_get_info $::NSCREENNAME $nname]

    bind $w <Control-W> [list tik_create_warn $name T]
    
    if { [expr {$::TIK(options,msgsend) & 1} ] == 1} {
        bind $mw <Return> "p_tik_cim_send $nname; break"
    }
    if { [expr {$::TIK(options,msgsend) & 2} ] == 2} {
        bind $mw <Control-Return> "p_tik_cim_send $nname; break"
    } else {
        bind $mw <Control-Return> " "
    }
    bind $mw <Control-s> "p_tik_cim_send $nname; break"

    ####################################
    # begin block button
    ####################################
    if {$::TIK(options,iconbuttons)} {
        button $w.block -image bblock -command "tik_create_block $nname"
    } else {
        button $w.block -text [tik_str B_BLOCK] -command "tik_create_block $nname"
    }
    balloonhelp $w.block [tik_str TOOLTIP_B_BLOCK]
    ## End block button ################

    bind $mw <Control-period> [list destroy $w]

   pack $w.send $w.info $w.block $w.warn -in $w.buttonF -side left -padx 2m
    
    if {![tik_is_buddy $nname]} {
        pack $w.add -in $w.buttonF -side left -padx 2m
    }

    pack $w.close -in $w.buttonF -side left -padx 2m
    
    pack $w.buttonF -side bottom -pady 2
    if {($::TIK(options,cimheight) != 0) && $::TIK(options,cimexpand)} {
        pack $w.msgArea -fill both -side bottom -expand 1
    } else {
        pack $w.msgArea -fill x -side bottom
    }
    pack $w.textF -expand 1 -fill both -side top
    
    tik_title_cim $name
    focus $mw

    bind $w <Motion> "+tik_flash_im $nname 0"
    bind $w <Motion> {+tik_non_idle_event}
    bind $w <Any-Key> "+tik_flash_im $nname 0"
    bind $w <FocusIn> {+tik_cim_rm_star %W}
    bind $w <FocusOut> {+tik_cim_rm_star %W}
    bind $w <FocusIn> "+tik_flash_im $nname 0"
    bind $w <FocusOut> "+tik_flash_im $nname 0"
    
######## BEGIN BUTTON BAR #####################################
    frame $w.imBbar
    createBbar $w.imBbar $mw $nname
    entry $w.imBbar.ftr -font ::NORMALFONT -width 8
	
    #entry $w.imBbar.hdr -font ::NORMALFONT -width 10
    #$w.imBbar.hdr insert end $::TIK(options,Font,defheader)
    
    # Yes, Jack, I took your footer away! And you're never getting it back! NEVER! :)
    # $w.imBbar.ftr insert end $::TIK(options,Font,deffooter)

    ###################################################################
    # if you'd still like your color button but not the button bar
    # uncomment the following but comment the appropriate statement that
    # packs the button in the button bar. also change $w.bbar.color to
    # $w.color
    # pack $w.color -in $w.buttonF -side left -padx 2m
    ###################################################################


    if {$::TIK(options,buttonbar)} {
	pack $w.imBbar -fill x -padx 1 
    }
}

proc tik_cim_rm_star {window} {
    if {$::TIK(options,focusrmstar)} {
        set w [winfo toplevel $window]
        if {[string first * [wm title $w]] == 0} {
            wm title $w [string range [wm title $w] 1 end ]
	    wm iconname $w [string range [wm iconname $w] 1 end ]
        }
	set nname [string range $w 7 end]
	set ::TIK(imconvs,$nname,receiveLast) 0
    }
}

proc tik_flash_im {nremote doflash} {
    set w .imConv$nremote
    if {![winfo exists $w]} {
        return
    }

    if {!$doflash} {
        $w.textF.textS configure \
            -background $::TIK(imconvs,$nremote,background)
        set ::TIK(imconvs,$nremote,flashing) 0
        return
    } 

    if {! $::TIK(imconvs,$nremote,flashing)} {
        return
    }

    if {$doflash == 1} {
        $w.textF.textS configure \
            -background $::TIK(options,flashimcolor)
        after $::TIK(options,flashimtime) tik_flash_im $nremote 2
    } elseif {$doflash == 2} {
        $w.textF.textS configure \
            -background $::TIK(imconvs,$nremote,background)
        after $::TIK(options,flashimtime) tik_flash_im $nremote 1
    }
}

proc tik_receive_im {remote auto msg us} {
    set nremote [normalize $remote]

    set autostr ""
    if { ($auto == "auto") || ($auto == "T") } {
        set autostr [tik_str CIM_AUTORESP]
    }

    set ::TIK(imconvs,$nremote,receiveLast) [string compare $us "T"]

    tik_create_cim $remote
    if {$us == "T"} {
        tik_play_sound2 $nremote Send
    } else {
        if {$::TIK(imconvs,$nremote,initial)} {
            tik_play_sound2 $nremote Initial
            set ::TIK(imconvs,$nremote,initial) 0
        } else {
            tik_play_sound2 $nremote Receive
        }
    }
    set w $::TIK(imconvs,$nremote,textw)
    $w configure -state normal
    if {$::TIK(options,imtime)} {
        set tstr [clock format [clock seconds] -format [tik_str CIM_TIMESTAMP]]
    } else {
        set tstr ""
    }
    if {$us == "T"} {
        $w insert end "$tstr$::SCREENNAME$autostr: " bbold
    } else {
        $w insert end "$tstr$remote$autostr: " rbold
    }
    addHTML $w "$msg" $::TIK(options,imcolor)
    addHTML $w "\n"
    $w configure -state disabled

    if {$::TIK(options,raiseim)} {
        raise $::TIK(imconvs,$nremote,toplevel)
    }

    if {$::TIK(options,deiconifyim)} {
        wm deiconify $::TIK(imconvs,$nremote,toplevel)
    }

    # Only do flash if a) the option is on b) the message wasn't
    # from us c) our mouse isn't over the window already.
    if {$::TIK(options,flashim) && ($us == "F")} {
        set pwin [winfo containing [winfo pointerx .] [winfo pointery .]]
        if {($pwin == "") || 
            ([winfo toplevel $pwin] != $::TIK(imconvs,$nremote,toplevel))} {
            set ::TIK(imconvs,$nremote,flashing) 1
            tik_flash_im $nremote 1
        }
    }
}


#######################################################
# Routines for sending an initial IM
#######################################################
proc p_tik_iim_send {id w} {
    set to $::TIK(iims,$id,to)
    if { $::TIK(options,iimheight) == 0} {
        set msg [string trimright [$::TIK(iims,$id,msgw) get]]
    } else {
        set msg [string trimright [$::TIK(iims,$id,msgw) get 0.0 end]]
    }
    set ::TIK(imconvs,$id,lasttyped) $msg

    if { [string length [string trim $msg]] == 0} {
        tk_messageBox -type ok -message [tik_str E_NOMSG]
        return
    }

    set msg [tik_filter_msg $::SCREENNAME IM_OUT $msg]
    

    set w $::TIK(iims,$id,toplevel)



    if { [string length [string trim $msg]] == 0} {
        set ::TIK(imconvs,$id,lasttyped) ""
        $w.textArea delete 0.0 end
        return
    }

    if {$::TIK(options,imcolor)} {
        set msg "<FONT COLOR=\"$::TIK(options,defaultimcolor)\">$msg</FONT>"
    }
    
    if { [string length $msg] > 1950 } {
        tk_messageBox -type ok -message [tik_str E_MSGLONG]
        return
    }
    
    set header [string trim [$w.iimBbar.hdr get]]
    set msg "$header$msg"

    destroy $w
    toc_send_im $::NSCREENNAME $to $msg
}

proc tik_create_iim {cname name} {
    set nname [normalize $name]
    set cnt 0
    catch {set cnt $::TIK(iims,cnt)}
    set ::TIK(iims,cnt) [expr $cnt + 1]
    
    set ::TIK(iims,$cnt,to) $name

    set w .iim$cnt
    set ::TIK(iims,$cnt,toplevel) $w

    toplevel $w -class $::TIK(options,imWMClass)
    wm title $w [tik_str IIM_TITLE]
    wm iconname $w [tik_str IIM_ICON]
    if {$::TIK(options,windowgroup)} {wm group $w .login}

    bind $w <Motion> tik_non_idle_event

    frame $w.top
    label $w.toL -text [tik_str IIM_TO]
    entry $w.to -width 16 -relief sunken -textvariable ::TIK(iims,$cnt,to)
    balloonhelp $w.to [tik_str TOOLTIP_IIM_TO]

    pack  $w.toL $w.to -in $w.top -side left

    set tw [createINPUT $w.textArea iimheight]
    set ::TIK(iims,$cnt,msgw) $tw
    bind $w.to <Return> [list focus $tw]

    bind $w <F1> "$tw insert current ayt?" ;# could someone explain this, please?

    if { [expr {$::TIK(options,msgsend) & 1} ] == 1} {
        bind $tw <Return> "p_tik_iim_send $cnt $w; break"
    }
    if { [expr {$::TIK(options,msgsend) & 2} ] == 2} {
        bind $tw <Control-Return> "p_tik_iim_send $cnt $w; break"
    } else {
        bind $tw <Control-Return> " "
    }
    frame $w.iimBbar
   
    createBbar $w.iimBbar $w.textArea $nname

    frame $w.bottom
    
    if {$::TIK(options,iconbuttons)} {
        button $w.send -image bsend -command [list p_tik_iim_send $cnt $w]
        button $w.cancel -image bclose -command [list destroy $w]
    } else {
	button $w.send -text [tik_str B_SEND] -command [list p_tik_iim_send $cnt $w]
	button $w.cancel -text [tik_str B_CANCEL] -command [list destroy $w]
    }

    balloonhelp $w.send   [tik_str TOOLTIP_B_SEND]
    balloonhelp $w.cancel [tik_str TOOLTIP_B_CANCEL]
    
    bind $w <Control-s> "p_tik_iim_send $cnt; break"
    
    bind $w <Control-period> [list destroy $w]
    
    pack $w.send $w.cancel -in $w.bottom -side left -padx 2m
    
    
    
    pack $w.top -side top
    if {$::TIK(options,buttonbar)} {
	pack forget $w.iimBbar.color
	pack $w.iimBbar -padx 1 -expand 1 -after $w.top
    }
    
    pack $w.bottom -side bottom -pady 2

    pack $w.textArea -expand 1 -fill both
    if { $name == ""} {
        focus $w.to
    } else {
        focus $tw
    }

}
