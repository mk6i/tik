# Popup Routines
#######################################################

# tik_buddy_popup --
#     Generic routine for showing the popup for a buddy
#     at a given location.
#
# Arguments:
#     bud - The buddy to show information about, this might not
#           actually be a buddy in the true sense, since stocks can be.
#     X   - The x root position
#     Y   - The y root position

proc tik_buddy_popup {bud X Y} {
    set w .buddypopup
    catch {destroy $w}

    set nstr [normalize $bud]
    if {$nstr == ""} {
        return
    }
    toplevel $w -border 1 -relief solid
    wm overrideredirect .buddypopup 1

    set textlist $::BUDDIES($nstr,popupText)

    set nlen 0
    set vlen 0
    foreach {name value} $textlist {
        set nl [string length $name]
        set vl [string length $value]

        if {$nl > $nlen} {
            set nlen $nl
        }
        if {$vl > $vlen} {
            set vlen $vl
        }
    }

    set i 0
    foreach {name value} $textlist {
        label $w.name$i -text $name -width $nlen -anchor se
        label $w.value$i -text $value -width $vlen -anchor sw
        grid $w.name$i $w.value$i -in $w
        incr i
    }

    set width [expr ($vlen + $nlen) * 10]
    set height [expr ($i * 25)]
    set screenwidth [winfo screenwidth $w]
    set screenheight [winfo screenheight $w]

    incr Y 5
    incr X 5

    if {$X < 0} {
        set X 0
    } elseif {[expr $X + $width] > $screenwidth} {
        set X [expr $screenwidth - $width]
    }

    if {[expr $Y + $height] > $screenheight} {
        set Y [expr $screenheight - $height]
    }

    wm geometry $w +$X+$Y
}

# tik_buddy_release --
#     Hide the buddy popup.
proc tik_buddy_release {} {
    catch {destroy .buddypopup}
}

# tik_showurl_popup --
#     Generic routine for showing a URL, which is just a string
#
# Arguments:
#     url - The url (or string) to show
#     X   - The x root position
#     Y   - The y root position

proc tik_showurl_popup {url X Y} {
    set w .urlpopup
    catch {destroy $w}

    if {$url == ""} {
        return
    }
    toplevel $w -border 1 -relief solid
    wm overrideredirect $w 1

    set nlen [string length $url]

    label $w.url -text $url
    pack $w.url

    set width $nlen
    set height 25
    set screenwidth [winfo screenwidth $w]
    set screenheight [winfo screenheight $w]

    if {$X < 0} {
        set X 0
    } elseif {[expr $X + $width] > $screenwidth} {
        set X [expr $screenwidth - $width]
    }

    if {[expr $Y + $height] > $screenheight} {
        set Y [expr $screenheight - $height]
    }

    wm geometry $w +$X+$Y
}

# tik_showurl_release --
#     Hide the url popup.
proc tik_showurl_release {} {
    catch {destroy .urlpopup}
}
