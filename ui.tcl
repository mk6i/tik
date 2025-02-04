# UI routines for TiK

#######################################################
# createINPUT --
#     Create an input area based with different properities
#     based on set options.
#
# Arguments:
#     w  - the widget that will be packed in the upper layer, either
#          the widget created, or frame.
#     op - option to check.
#
# Returns:
#     The text or entry widget.

proc createINPUT {w op {width 40}} {
    if { $::TIK(options,$op) == 0} {
        entry $w -font $::NORMALFONT -width $width
        bind [winfo parent $w] <Control-u> "$w delete 0 insert"
        bind [winfo parent $w] <Double-Control-u> "$w delete 0 end"
	bind [winfo parent $w] <Any-Key> +tik_non_idle_event
        return $w
    } elseif { $::TIK(options,$op) > 0 } {
        text $w -font $::NORMALFONT -width 40 \
            -height $::TIK(options,$op) -wrap word
        bind [winfo parent $w] <Control-u> "$w delete 0.0 insert"
        bind [winfo parent $w] <Double-Control-u> "$w delete 0.0 end"
	bind [winfo parent $w] <Any-Key> +tik_non_idle_event
        return $w
    } else {
        frame $w
        text $w.text -font $::NORMALFONT -width 40 \
            -height [string range $::TIK(options,$op) 1 end] -wrap word \
            -yscrollcommand [list $w.textS set]
        scrollbar $w.textS -orient vertical -command [list $w.text yview]
        pack $w.textS -side right -in $w -fill y
        pack $w.text -side left -in $w -fill both -expand 1
        bind [winfo parent $w] <Control-u> "$w.text delete 0.0 insert"
        bind [winfo parent $w] <Double-Control-u> "$w.text delete 0.0 end"
	bind [winfo parent $w] <Any-Key> +tik_non_idle_event
        return $w.text
    }
}

# createHTML --
#     Create a HTML display area, basically just a text area
#     and scrollbar.
#
# Arguments:
#     w - frame name to place everything in.
#
# Results:
#     The text widget.

proc createHTML {w} { 
    frame $w
    scrollbar $w.textS -orient vertical -command [list $w.text yview]
    text $w.text -font $::NORMALFONT -yscrollcommand [list $w.textS set] \
        -state disabled -width 40 -height 10 -wrap word
    pack $w.textS -side right -in $w -fill y
    pack $w.text -side left -in $w -fill both -expand 1

### FUZZFACE00/SCREENCOLORS - SET IM MESSAGE SN COLORS
### Commands to use in tikrc
### set ::TIK(options,mysncolor) blue ; messages sent by you
### set ::TIK(options,othersncolor) red ; messages received by you 
    $w.text tag configure bbold -foreground $::TIK(options,mysncolor) \
     -font $::BOLDFONT
    $w.text tag configure rbold -foreground $::TIK(options,othersncolor) \
      -font $::BOLDFONT
### FUZZFACE00/SCREENCOLORS - END MODIFICATION

    set ::HTML($w.text,linkcnt) 0
    set ::HTML($w.text,hrcnt) 0

    bind $w.text <Configure> "p_updateHRHTML $w.text %w"

    bind [winfo parent $w] <Key-Prior> "$w.text yview scroll -1 pages"
    bind [winfo parent $w] <Key-Next> "$w.text yview scroll 1 pages"

# This is a temporary fix for those that want to copy from IM-style windows
# and can't.  This is pretty ugly, which is why it's not on by default.  
# Someone definitely needs to make this prettier.
    if {[info exists ::TIK(options,COPY)] && $::TIK(options,COPY)} {
        if {$w != ".prefwindow.n.f5.top.awayframe.msg.text"} {
            bind $w.text <KeyPress> {
                if {"%A" != {} && "%K" != "c"} {
                    break
                }
            }
            bind $w.text <Button-1> "$w.text configure -state normal"
            bind $w.text <ButtonRelease-1> "$w.text configure -state disabled"
        }
    }
### End of ugly copy fix.

    return $w.text
}

# p_update_HRHTML --
#     Private method that takes care of resizing HR rule bars.
proc p_updateHRHTML {w width} {
   set width [expr {$width - 10}]

   for {set i 0} {$i < $::HTML($w,hrcnt)} {incr i} {
       $w.canv$i configure -width $width
   }
}

# addHTML --
#     Add HTML text to a text widget returned by createHTML.  We process
#     most simple HTML, and trash the hard stuff.
#
# Arguments:
#     w    - text area widget.
#     text - html to add to the text area.


proc addHTML {w text {doColor 0}} {
    set bbox [$w bbox "end-1c"]
    set bold 0
    set italic 0
    set underline 0
    set strikeout 0
    set bolditalic 0
    set inlink 0
    set color "000000"
    set bgcolor "ffffff"
    set font 0
    set face ""
    set size 0
    set hasbgcolor 0

    set results [splitHTML $text]

    foreach e $results {
	set tagnum [clock clicks]
	set currfont [eval font create $::TIK(options,Font,basefont)]
        switch -regexp -- $e {
            "^<[fF][oO][nN][tT].*>" {
                if {[regexp -nocase {back="#([0-9a-f]*)"} $e c]} {
                    set bgcolor [string range $c 7 [expr [string length $c]-2]]
                }

                if {[regexp -nocase {color="#([0-9a-f]*)"} $e c]} {
                    set color [string range $c 8 [expr [string length $c]-2]]
                }

		if {[regexp -nocase {face="([a-z0-9 ])*"} $e c]} {
		    set face [string range $c 5 [expr [string length $c]-1]]
		    set font 1
		}

                if {[regexp -nocase {ptsize=([0-9])*} $e c]} {
                    set size [string range $c 7 [expr [string length $c]-1]]
                }

		if {[regexp -nocase {size=([0-9])*} $e c]} {
		    set relsize [string range $c 5 [expr [string length $c]-1]]
		    if {$::TIK(options,Font,userelsize)} {
		        set size [expr $::TIK(options,Font,basesize)+ 2*($relsize-3)]
		    } else {
                        switch $relsize {
                            1 {set size 8}
                            2 {set size 10}
                            3 {set size 12}
                            4 {set size 14}
                            5 {set size 16}
                            6 {set size 18}
                            7 {set size 20}
                            8 {set size 24}
 		        }
                    }
		}
		if {[regexp -nocase {size="([0-9])*"} $e c]} {
		    set size [string range $c 6 [expr [string length $c]-2]]
		}
            }
            "^</[fF][oO][nN][tT].*>" {
                set color "000000"
                set bgcolor "ffffff"
		set font 0
		set size 0
            }
            "^<[bB][oO][dD][yY][^#]*[bB][gG][cC][oO][lL][oO][rR]=\"?#\[0-9a-fA-F\].*>" {
                    catch {set bgcolor [string range $e [expr \
                        [string first "#" $e]+1] [expr [string first "#" $e]+6]]
                    }
                    set bgcolor [string tolower $bgcolor]
		    set hasbgcolor 1
            }       
	    "^</[Bb][Oo][Dd][Yy]>$" {
		set hasbgcolor 0
	    } 

           "^<[bB]>$" {
                set bold 1
            }
            "^</[bB]>$" {
                set bold 0
            }
            "^<[iI]>$" {
                set italic 1
            }
            "^</[iI]>$" {
                set italic 0
            }
            "^<[uU]>$" {
                set underline 1
            }
            "^</[uU]>$" {
                set underline 0
            }
	    "^<(([sS])|([sS][tT][rR][iI][kK][eE][oO][uU][tT])|([sS][tT][rR][iI][kK][eE]))>$" {
	    	set strikeout 1
	    }
	    "^</(([sS])|([sS][tT][rR][iI][kK][eE][oO][uU][tT])|([sS][tT][rR][iI][kK][eE]))>$" {
	    	set strikeout 0
	    }
	    {^<[aA]\s.*[hH][rR][eE][fF].*>$} {
                set inlink 1
                incr ::HTML($w,linkcnt)
                $w tag configure link$::HTML($w,linkcnt) -font $::BOLDFONT \
                    -foreground blue -underline true
                $w tag bind link$::HTML($w,linkcnt) <Enter> {%W configure -cursor hand2}
                $w tag bind link$::HTML($w,linkcnt) <Leave> {
                    regexp {cursor=([^ ]*)} [%W tag names] x cursor
                    %W configure -cursor $cursor
                }
                if {[regexp {"(.*)"} $e match url]} {
                    $w tag bind link$::HTML($w,linkcnt) <ButtonPress> \
                               [list tik_show_url im_url $url]
                    $w tag bind link$::HTML($w,linkcnt) <ButtonPress-3> [list tik_showurl_popup $url %X %Y]
                    $w tag bind link$::HTML($w,linkcnt) <ButtonRelease-3> {tik_showurl_release}
                } else {
                    $w tag bind link$::HTML($w,linkcnt) <ButtonPress> \
                               [list tk_messageBox -type ok -message \
                               "Couldn't parse url from $e"]
                }
            }
            "^</[aA]>$" {
                set inlink 0
            }
            "^<[pP]>$" -
            "^<[pP] ALIGN.*>$" -
            "^<[bB][rR]>$" {
                $w insert end "\n"
            }
            "^<[hH][rR].*>$" {
                canvas $w.canv$::HTML($w,hrcnt) -width 1000 -height 3
                $w.canv$::HTML($w,hrcnt) create line 0 3 1000 3 -width 3
                $w window create end -window $w.canv$::HTML($w,hrcnt) -align center
                $w insert end "\n"
                incr ::HTML($w,hrcnt)
            }
            "^</?[cC][eE][nN][tT][eE][rR].*>$" -
            "^</?[hH][123456].*>$" -
            "^<[iI][mM][gG].*>$" -
            "^</?[tT][iI][tT][lL][eE].*>$" -
            "^</?[hH][tT][mM][lL].*>$" -
            "^</?[bB][oO][dD][yY].*>$" -
            "^</?[pP][rR][eE]>$" -
            "^<!--.*-->$" -
            "^$" {
            }
            default {
                set style [list]
    		regsub -all "&lt;" $e "<" e
    		regsub -all "&gt;" $e ">" e
    		regsub -all "&quot;" $e "\"" e
    		regsub -all "&nbsp;" $e " " e
    		regsub -all "&amp;" $e {\&} e

                if {$bold} {
                    #lappend style bold
		    eval font configure $currfont -weight bold
                }
		if {$underline}  {
		    eval font configure $currfont -underline true
                }
                if {$italic} {
		    eval font configure $currfont -slant italic
                }
                if {$strikeout} {
                    $w tag configure composite$tagnum -overstrike true
                }

                if {$inlink} {
                    set style [list link$::HTML($w,linkcnt)] ;# no style in links
                    lappend style cursor=[$w cget -cursor]
                }

                if {$doColor & 0x1} {
                    $w tag configure color$color -foreground #$color
                    lappend style color$color
                }

                if {($doColor & 0x6) && ($bgcolor != "ffffff")} {
                    $w tag configure bgcolor$bgcolor -background #$bgcolor
                    lappend style bgcolor$bgcolor
                }

		if {$font && $::TIK(options,Font,showfonts)} {
		    eval font configure $currfont -family $face
		}

		if {$size!=0 && $::TIK(options,Font,showfontsizes)} {
		    eval font configure $currfont -size $size
		}

		if {$hasbgcolor && $::TIK(options,Font,showbgcolor) == 1} {
		    $w tag configure composite$tagnum -font $currfont -background #$bgcolor
		} else {
		    $w tag configure composite$tagnum -font $currfont
		}
		lappend style composite$tagnum
		if {$::TIK(options,showsmilies)} {
                    while {[regexp -- [join $::TIK(spatlist) |] $e smilie]} {
                        set index1 [string first $smilie $e]
                        $w insert end [string range $e 0 [expr $index1-1]] $style
                        if {[regexp {^(\s).*} $smilie match temp]} {
                            $w insert end $temp
                        }
			set ind 0
			foreach test $::TIK(spatlist) {
                            if {[regexp -- ^$test$ $smilie]} {
                                set sstring [lindex $::TIK(siconlist) $ind]
                                $w image create end -image $sstring -align center
                                break
                            }
                            incr ind
                        }
                        if {[regexp {.*(\s)$} $smilie match temp]} {
                            $w insert end $temp
                        }
		        set e [string range $e [expr $index1+[string length $smilie]] end]
		    }
                }
                $w insert end $e $style
            }
        }
    }
    if {$bbox != ""} {
        $w see end
    }
}

# tik_lselect --
#     Used as the callback for dealing with the buddy list.
#     it allows you to set up two different commands to be called
#     based on if the item selected is a group or not.
#
# Arguements:
#     list     - list widget
#     command  - command if a normal buddy
#     gcommand - command if a group.  A "-" for gcommand means
#                call the $command argument with no args.

proc tik_lselect {list command {gcommand ""}} {
    set sel [sag::selection $list]

    set name $::NSCREENNAME

    if {$sel == ""} {
        if {$command != ""} {
            $command $name ""
        }
        return
    }

    foreach s $sel {
        set c [string index $s 0]
        if {$c == "+" || $c == "-"} {
            if {$gcommand == "-"} {
                $command $name ""
            } elseif {$gcommand != "" } {
                $gcommand $name [string range $s 2 end]
            }
        } else {
            if {$command != ""} {
                $command $name [string trim $s]
            }
        }
    }
}

# tik_handleGroup -
#     Double Click callback for groups.  This collapses the groups.
#
# Arguments:
#     name  - unused
#     group - the group to collapse

proc tik_handleGroup {name group} {
    if {$::GROUPS($group,collapsed) == "T"} {
        set ::GROUPS($group,collapsed) "F"
    } else {
        set ::GROUPS($group,collapsed) "T"
    }

    tik_draw_list
}


# tik_double_click --
#     The user double clicked on a buddy, call the registered double
#     click method for the buddy.
#
# Arguments:
#     name  - the SFLAP connection
#     buddy - the buddy that was double clicked.

proc tik_double_click {name buddy} {
    set nbud [normalize $buddy]
    if {[info exists ::BUDDIES($nbud,doubleClick)]} {
        $::BUDDIES($nbud,doubleClick) $name $buddy
    } else {
        tik_create_iim $name $buddy
    }
}

# tik_show_buddy --
#     Show the buddy window, we first withdraw
#     the login window in case it is around.

proc tik_show_buddy {} {
    if {[winfo exists .login]} {
        wm withdraw .login
    }

    if {[winfo exists .buddy]} {
        wm deiconify .buddy
        raise .buddy
    }
}


###########################################
###########################################
###########################################
####  This is the ui file, so let's    ####
####  just put additional widgets,     ####
####  etc. here. below is notebook.tcl ####
###########################################


################## Begin notebook widget ###################
# A Notebook widget for Tcl/Tk
# $Revision: 1.33 $
#
# Copyright (C) 1996,1997,1998 D. Richard Hipp
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
# 
# You should have received a copy of the GNU Library General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA  02111-1307, USA.
#
# Author contact information:
#   drh@acm.org
#   http://www.hwaci.com/drh/


#
# Create a new notebook widget
#
proc Notebook:create {w args} {
  global Notebook
  set Notebook($w,width) 400
  set Notebook($w,height) 300
  set Notebook($w,pages) {}
  set Notebook($w,top) 0
  set Notebook($w,pad) 5
  set Notebook($w,fg,on) black
  set Notebook($w,fg,off) grey50
  canvas $w -bd 0 -highlightthickness 0 -takefocus 0
  set Notebook($w,bg) [$w cget -bg]
  bind $w <1> "Notebook:click $w %x %y"
  bind $w <Configure> "Notebook:scheduleExpand $w"
  eval Notebook:config $w $args
}

#
# Change configuration options for the notebook widget
#
proc Notebook:config {w args} {
  global Notebook
  foreach {tag value} $args {
    switch -- $tag {
      -width {
        set Notebook($w,width) $value
      }
      -height {
        set Notebook($w,height) $value
      }
      -pages {
        set Notebook($w,pages) $value
      }
      -pad {
        set Notebook($w,pad) $value
      }
      -bg {
        set Notebook($w,bg) $value
      }
      -fg {
        set Notebook($w,fg,on) $value
      }
      -disabledforeground {
        set Notebook($w,fg,off) $value
      }
    }
  }

  #
  # After getting new configuration values, reconstruct the widget
  #
  $w delete all
  set Notebook($w,x1) $Notebook($w,pad)
  set Notebook($w,x2) [expr $Notebook($w,x1)+2]
  set Notebook($w,x3) [expr $Notebook($w,x2)+$Notebook($w,width)]
  set Notebook($w,x4) [expr $Notebook($w,x3)+2]
  set Notebook($w,y1) [expr $Notebook($w,pad)+2]
  set Notebook($w,y2) [expr $Notebook($w,y1)+2]
  set Notebook($w,y5) [expr $Notebook($w,y1)+30]
  set Notebook($w,y6) [expr $Notebook($w,y5)+2]
  set Notebook($w,y3) [expr $Notebook($w,y6)+$Notebook($w,height)]
  set Notebook($w,y4) [expr $Notebook($w,y3)+2]
  set x $Notebook($w,x1)
  set cnt 0
  set y7 [expr $Notebook($w,y1)+10]
  foreach p $Notebook($w,pages) {
    set Notebook($w,p$cnt,x5) $x
    set id [$w create text 0 0 -text $p -anchor nw -tags "p$cnt t$cnt"]
    set bbox [$w bbox $id]
    set width [lindex $bbox 2]
    $w move $id [expr $x+10] $y7
    $w create line \
       $x $Notebook($w,y5)\
       $x $Notebook($w,y2) \
       [expr $x+2] $Notebook($w,y1) \
       [expr $x+$width+16] $Notebook($w,y1) \
       -width 2 -fill white -tags p$cnt
    $w create line \
       [expr $x+$width+16] $Notebook($w,y1) \
       [expr $x+$width+18] $Notebook($w,y2) \
       [expr $x+$width+18] $Notebook($w,y5) \
       -width 2 -fill black -tags p$cnt
    set x [expr $x+$width+20]
    set Notebook($w,p$cnt,x6) [expr $x-2]
    if {![winfo exists $w.f$cnt]} {
      frame $w.f$cnt -bd 0
    }
    $w.f$cnt config -bg $Notebook($w,bg)
    place $w.f$cnt -x $Notebook($w,x2) -y $Notebook($w,y6) \
      -width $Notebook($w,width) -height $Notebook($w,height)
    incr cnt
  }
  $w create line \
     $Notebook($w,x1) [expr $Notebook($w,y5)-2] \
     $Notebook($w,x1) $Notebook($w,y3) \
     -width 2 -fill white
  $w create line \
     $Notebook($w,x1) $Notebook($w,y3) \
     $Notebook($w,x2) $Notebook($w,y4) \
     $Notebook($w,x3) $Notebook($w,y4) \
     $Notebook($w,x4) $Notebook($w,y3) \
     $Notebook($w,x4) $Notebook($w,y6) \
     $Notebook($w,x3) $Notebook($w,y5) \
     -width 2 -fill black
  $w config -width [expr $Notebook($w,x4)+$Notebook($w,pad)] \
            -height [expr $Notebook($w,y4)+$Notebook($w,pad)] \
            -bg $Notebook($w,bg)
  set top $Notebook($w,top)
  set Notebook($w,top) -1
  Notebook:raise.page $w $top
}

#
# This routine is called whenever the mouse-button is pressed over
# the notebook.  It determines if any page should be raised and raises
# that page.
#
proc Notebook:click {w x y} {
  global Notebook
  if {$y<$Notebook($w,y1) || $y>$Notebook($w,y6)} return
  set N [llength $Notebook($w,pages)]
  for {set i 0} {$i<$N} {incr i} {
    if {$x>=$Notebook($w,p$i,x5) && $x<=$Notebook($w,p$i,x6)} {
      Notebook:raise.page $w $i
      break
    }
  }
}

#
# For internal use only.  This procedure raised the n-th page of
# the notebook
#
proc Notebook:raise.page {w n} {
  global Notebook
  if {$n<0 || $n>=[llength $Notebook($w,pages)]} return
  set top $Notebook($w,top)
  if {$top>=0 && $top<[llength $Notebook($w,pages)]} {
    $w move p$top 0 2
  }
  $w move p$n 0 -2
  $w delete topline
  if {$n>0} {
    $w create line \
       $Notebook($w,x1) $Notebook($w,y6) \
       $Notebook($w,x2) $Notebook($w,y5) \
       $Notebook($w,p$n,x5) $Notebook($w,y5) \
       $Notebook($w,p$n,x5) [expr $Notebook($w,y5)-2] \
       -width 2 -fill white -tags topline
  }
  $w create line \
    $Notebook($w,p$n,x6) [expr $Notebook($w,y5)-2] \
    $Notebook($w,p$n,x6) $Notebook($w,y5) \
    -width 2 -fill white -tags topline
  $w create line \
    $Notebook($w,p$n,x6) $Notebook($w,y5) \
    $Notebook($w,x3) $Notebook($w,y5) \
    -width 2 -fill white -tags topline
  set Notebook($w,top) $n
  raise $w.f$n
}

#
# Change the page-specific configuration options for the notebook
#
proc Notebook:pageconfig {w name args} {
  global Notebook
  set i [lsearch $Notebook($w,pages) $name]
  if {$i<0} return
  foreach {tag value} $args {
    switch -- $tag {
      -state {
        if {"$value"=="disabled"} {
          $w itemconfig t$i -fg $Notebook($w,fg,off)
        } else {
          $w itemconfig t$i -fg $Notebook($w,fg,on)
        }
      }
      -onexit {
        set Notebook($w,p$i,onexit) $value
      }
    }
  }
}

#
# This procedure raises a notebook page given its name.  But first
# we check the "onexit" procedure for the current page (if any) and
# if it returns false, we don't allow the raise to proceed.
#
proc Notebook:raise {w name} {
  global Notebook
  set i [lsearch $Notebook($w,pages) $name]
  if {$i<0} return
  if {[info exists Notebook($w,p$i,onexit)]} {
    set onexit $Notebook($w,p$i,onexit)
    if {"$onexit"!="" && [eval uplevel #0 $onexit]!=0} {
      Notebook:raise.page $w $i
    }
  } else {
    Notebook:raise.page $w $i
  }
}

#
# Return the frame associated with a given page of the notebook.
#
proc Notebook:frame {w name} {
  global Notebook
  set i [lsearch $Notebook($w,pages) $name]
  if {$i>=0} {
    return $w.f$i
  } else {
    return {}
  }
}

#
# Try to resize the notebook to the next time we become idle.
#
proc Notebook:scheduleExpand w {
  global Notebook
  if {[info exists Notebook($w,expand)]} return
  set Notebook($w,expand) 1
  after idle "Notebook:expand $w"
}

#
# Resize the notebook to fit inside its containing widget.
#
proc Notebook:expand w {
  global Notebook
  set wi [expr [winfo width $w]-($Notebook($w,pad)*2+4)]
  set hi [expr [winfo height $w]-($Notebook($w,pad)*2+36)]
  Notebook:config $w -width $wi -height $hi
  catch {unset Notebook($w,expand)}
}

######### End notebook widget #########################
