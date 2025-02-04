# Directory Functions
#
# All packages must be inside a namespace with the
# same name as the file name.

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

# Set VERSION and VERSDATE using the CVS tags.
namespace eval dir {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Directory Information package $Revision: 1.4 $} \
      ::dir::VERSION
  regexp -- { .* } {:$Date: 2000/07/13 08:20:29 $} \
      ::dir::VERSDATE
}

namespace eval dir {


############################
#####          package stuff
############################

    variable info

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        toc_register_func * DIR_STATUS dir::DIR_STATUS
        set dir::info(senddir) 0
        set dir::info(web_access) "true"
        menu .dirMenu -tearoff 0
        .toolsMenu add cascade -label "Directory" -menu .dirMenu
        .dirMenu add command -label "Get Dir Info" -command dir::create_get
        .dirMenu add command -label "Edit Dir Info" -command dir::create_set
        .dirMenu add command -label "Edit Keyword Info" -command dir::create_kw_set ;# REMOVE RELEASE
        .dirMenu add command -label "Name Search" -command dir::create_search
        .dirMenu add command -label "Email Search" -command dir::create_em_search
        .dirMenu add command -label "Keyword Search" -command dir::create_kw_search ;# REMOVE RELEASE
        tik_register_buddy_button_func "AIM" "Get Directory" dir::new_create_get

    }

    # All pacakges must have goOnline routine.  Called when the user signs
    # on, or if the user is already online when packages loaded.
    proc goOnline {} {
        if {$dir::info(senddir)} {
            dir::p_set_set_kw
            dir::p_set_set_name
        }
    }

    # All pacakges must have goOffline routine.  Called when the user signs
    # off.  NOT called when the package is unloaded.
    proc goOffline {} {
    }

    # All packages must have a unload routine.  This should remove everything 
    # the package set up.  This is called before load is called when reloading.

    proc unload {} {
        destroy .dirMenu
        toc_unregister_func * DIR_STATUS dir::DIR_STATUS
        destroy .setdir
        destroy .kw_setdir
        destroy .em_searchdir
        destroy .kw_searchdir
        destroy .searchdir
        destroy .getdir
        .toolsMenu delete "Directory"
        tik_unregister_buddy_button_func "AIM" "Get Directory"
    }

###############################
#####          protocol handler
###############################

    proc DIR_STATUS {name status arg} {
        if {$status == 1} {
            set status "successful"
        }

        if {"$arg" == ""} {
            tk_messageBox -type ok -message "Directory operation has $status status."
        } else {
            tk_messageBox -type ok -message "Dir search has $status status ($arg)."
        } 
    }


###################
#####       new get
###################

    proc new_create_get {cname name} {
      set dir::info(sn) $name
      dir::p_get
    }

###################
#####          get
###################

    proc create_get {} {
        set w .getdir

        if {[winfo exists $w]} {
            raise $w
            set dir::info(sn) ""
            focus $w.gsn
            return
        }

        toplevel $w -class Tik
        wm title $w "Get Dir for Screenname"
        wm iconname $w "Get Dir"
        # if {$::TIK(options,windowgroup)} {wm group $w .login}

        frame $w.gsnF
        label $w.gsnlabel -text "Screenname:"
        entry $w.gsn  -textvariable dir::info(sn)
        bind  $w.gsn <Return> "dir::p_get; break"
        pack $w.gsnlabel $w.gsn -in $w.gsnF -side left
        set dir::info(sn) ""
        focus $w.gsn

        pack $w.gsnF -in $w -side top

        frame $w.buttons
        button $w.set -text "Get Dir" -command "dir::p_get"
        button $w.cancel -text "Cancel" -command [list destroy $w]

        pack $w.set $w.cancel -in $w.buttons -side left -padx 2m

        pack $w.buttons -side bottom

    }

    proc get_dir { } {
        
        set dir::info(sn) $sn
    }
    
    proc p_get {} {

        toc_get_dir $::NSCREENNAME "$dir::info(sn)"
        
        destroy .getdir
    }



###################
#####          set
###################

    proc create_set {} {
        set w .setdir

        if {[winfo exists $w]} {
            raise $w
            return
        }

        toplevel $w -class Tik
        wm title $w "Temporary Info Change"
        wm iconname $w "Info Change"
        # if {$::TIK(options,windowgroup)} {wm group $w .login}

        frame $w.fnF
        label $w.fnlabel -text "First name" -width 14 -anchor e
        entry $w.fn  -textvariable dir::info(fn)
        bind  $w.fn <Return> "focus $w.mn"
        pack $w.fnlabel $w.fn -in $w.fnF -side left

        pack $w.fnF -in $w -side top

        frame $w.mnF
        label $w.mnlabel -text "Middle name" -width 14 -anchor e
        entry $w.mn  -textvariable dir::info(mn)
        bind  $w.mn <Return> "focus $w.ln"
        pack $w.mnlabel $w.mn -in $w.mnF -side left

        pack $w.mnF -in $w -side top

        frame $w.lnF
        label $w.lnlabel -text "Last name" -width 14 -anchor e
        entry $w.ln  -textvariable dir::info(ln)
        bind  $w.ln <Return> "focus $w.md"
        pack $w.lnlabel $w.ln -in $w.lnF -side left -anchor w

        pack $w.lnF -in $w -side top

        frame $w.mdF
        label $w.mdlabel -text "Maiden name" -width 14 -anchor e
        entry $w.md  -textvariable dir::info(md)
        bind  $w.md <Return> "focus $w.city"
        pack $w.mdlabel $w.md -in $w.mdF -side left

        pack $w.mdF -in $w -side top

        frame $w.cityF
        label $w.citylabel -text "City" -width 14 -anchor e
        entry $w.city -textvariable dir::info(city)
        bind  $w.city <Return> "focus $w.state"
        pack $w.citylabel $w.city -in $w.cityF -side left

        pack $w.cityF -in $w -side top

        frame $w.stateF
        label $w.statelabel -text "State" -width 14 -anchor e
        entry $w.state  -textvariable dir::info(state)
        bind  $w.state <Return> "focus $w.country"
        pack $w.statelabel $w.state -in $w.stateF -side left

        pack $w.stateF -in $w -side top

        frame $w.countryF
        label $w.countrylabel -text "Country" -width 14 -anchor e
        entry $w.country  -textvariable dir::info(country)
        bind  $w.country <Return> "dir::p_set_set_name ; break"
        pack $w.countrylabel $w.country -in $w.countryF -side left

        pack $w.countryF -in $w -side top

        label $w.info -text "This will NOT change your $::TIK(rcfile)\nUse: dir::set_dir fn mn ln mn city state country web_access kw1 kw2 kw3 kw4 kw5"

        frame $w.buttons
        button $w.set -text "Set Dir" -command "dir::p_set_set_name"
        button $w.cancel -text "Cancel" -command [list destroy $w]
        pack $w.set $w.cancel -in $w.buttons -side left -padx 2m

        pack $w.info -side top
        pack $w.buttons -side bottom

    }

    proc set_dir {fn mn ln md city state country web_access kw1 kw2 kw3 kw4 kw5} {
        
        set dir::info(fn) $fn
        set dir::info(mn) $mn
        set dir::info(ln) $ln
        set dir::info(md) $md
        set dir::info(city) $city
        set dir::info(state) $state
        set dir::info(country) $country
        set dir::info(web_access) $web_access
        set dir::info(kw1) $kw1
        set dir::info(kw2) $kw2
        set dir::info(kw3) $kw3
        set dir::info(kw4) $kw4
        set dir::info(kw5) $kw5

        set dir::info(senddir) 1
    }
    
    proc p_set_set_name {} {
        set dir::info(senddir) 1
        toc_set_dir $::NSCREENNAME "$dir::info(fn)\:$dir::info(mn)\:$dir::info(ln)\:$dir::info(md)\:$dir::info(city)\:$dir::info(state)\:$dir::info(country)\:$dir::info(web_access)"
        
        destroy .setdir
    }


#####################
#####          kl set
#####################

    proc create_kw_set {} {
        set w .kw_setdir

        if {[winfo exists $w]} {
            raise $w
            return
        }

        toplevel $w -class Tik
        wm title $w "Temporary Keyword Change"
        wm iconname $w "Keyword Change"
        # if {$::TIK(options,windowgroup)} {wm group $w .login}

        frame $w.kw1F
        label $w.kw1label -text "Keyword 1" -width 14 -anchor e
        entry $w.kw1  -textvariable dir::info(kw1)
        bind  $w.kw1 <Return> "focus $w.kw2"
        pack $w.kw1label $w.kw1 -in $w.kw1F -side left

        frame $w.kw2F
        label $w.kw2label -text "Keyword 2" -width 14 -anchor e
        entry $w.kw2  -textvariable dir::info(kw2)
        bind  $w.kw2 <Return> "focus $w.kw3"
        pack $w.kw2label $w.kw2 -in $w.kw2F -side left

        frame $w.kw3F
        label $w.kw3label -text "Keyword 3" -width 14 -anchor e
        entry $w.kw3  -textvariable dir::info(kw3)
        bind  $w.kw3 <Return> "focus $w.kw4"
        pack $w.kw3label $w.kw3 -in $w.kw3F -side left

        frame $w.kw4F
        label $w.kw4label -text "Keyword 4" -width 14 -anchor e
        entry $w.kw4  -textvariable dir::info(kw4)
        bind  $w.kw4 <Return> "focus $w.kw5"
        pack $w.kw4label $w.kw4 -in $w.kw4F -side left

        frame $w.kw5F
        label $w.kw5label -text "Keyword 5" -width 14 -anchor e
        entry $w.kw5  -textvariable dir::info(kw5)
        bind  $w.kw4 <Return> "dir::p_set_set_kw; break"
        pack $w.kw5label $w.kw5 -in $w.kw5F -side left

        label $w.info -text "This will NOT change your $::TIK(rcfile)\nUse: dir::set_dir fn mn ln mn city state country web_access kw1 kw2 kw3 kw4 kw5"

        frame $w.buttons
        button $w.set -text "Set Dir" -command "dir::p_set_set_kw"
        button $w.cancel -text "Cancel" -command [list destroy $w]
        pack $w.set $w.cancel -in $w.buttons -side left -padx 2m

        pack $w.info -side top
        pack $w.buttons -side bottom

    }

    proc p_set_set_kw {} {
        set dir::info(senddir) 1
        toc_set_dir $::NSCREENNAME "\:\:\:\:\:\:\:$dir::info(web_access)\:$dir::info(kw1)\:$dir::info(kw2)\:$dir::info(kw3)\:$dir::info(kw4)\:$dir::info(kw5)"
        
        destroy .kw_setdir
    }



#####################
#####          search
#####################


     proc create_search {} {
        set w .searchdir

        if {[winfo exists $w]} {
            raise $w
            return
        }

        toplevel $w -class Tik
        wm title $w "Search Directory for Information"
        wm iconname $w "Search"
        # if {$::TIK(options,windowgroup)} {wm group $w .login}

        frame $w.dfnF
        label $w.dfnlabel -text "First name" -width 14 -anchor e
        entry $w.dfn  -textvariable dir::info(dfn)
        bind  $w.dfn <Return> "focus $w.dmn"
        pack $w.dfnlabel $w.dfn -in $w.dfnF -side left

        pack $w.dfnF -in $w -side top

        frame $w.dmnF
        label $w.dmnlabel -text "Middle name" -width 14 -anchor e
        entry $w.dmn  -textvariable dir::info(dmn)
        bind  $w.dmn <Return> "focus $w.dln"
        pack $w.dmnlabel $w.dmn -in $w.dmnF -side left

        pack $w.dmnF -in $w -side top

        frame $w.dlnF
        label $w.dlnlabel -text "Last name" -width 14 -anchor e
        entry $w.dln  -textvariable dir::info(dln)
        bind  $w.dln <Return> "focus $w.dmd"
        pack $w.dlnlabel $w.dln -in $w.dlnF -side left

        pack $w.dlnF -in $w -side top

        frame $w.dmdF
        label $w.dmdlabel -text "Maiden name" -width 14 -anchor e
        entry $w.dmd  -textvariable dir::info(dmd)
        bind  $w.dmd <Return> "focus $w.dcity"
        pack $w.dmdlabel $w.dmd -in $w.dmdF -side left

        pack $w.dmdF -in $w -side top

        frame $w.dcityF
        label $w.dcitylabel -text "City" -width 14 -anchor e
        entry $w.dcity -textvariable dir::info(dcity)
        bind  $w.dcity <Return> "focus $w.dstate"
        pack $w.dcitylabel $w.dcity -in $w.dcityF -side left

        pack $w.dcityF -in $w -side top

        frame $w.dstateF
        label $w.dstatelabel -text "State" -width 14 -anchor e
        entry $w.dstate  -textvariable dir::info(dstate)
        bind  $w.dstate <Return> "focus $w.dcountry"
        pack $w.dstatelabel $w.dstate -in $w.dstateF -side left

        pack $w.dstateF -in $w -side top

        frame $w.dcountryF
        label $w.dcountrylabel -text "Country" -width 14 -anchor e
        entry $w.dcountry  -textvariable dir::info(dcountry)
        bind  $w.dcountry <Return> "dir::p_search; break"

        pack $w.dcountrylabel $w.dcountry -in $w.dcountryF -side left

        pack $w.dcountryF -in $w -side top

        frame $w.buttons

        button $w.set -text "Search Dir" -command "dir::p_search"
        button $w.cancel -text "Cancel" -command [list destroy $w]
        pack $w.set $w.cancel -in $w.buttons -side left -padx 2m

        pack $w.buttons -side bottom

    }

    proc search_dir {fn mn ln md city state country email} {
        
        set dir::info(dfn) $fn
        set dir::info(dmn) $mn
        set dir::info(dln) $ln
        set dir::info(dmd) $md
        set dir::info(dcity) $city
        set dir::info(dstate) $state
        set dir::info(dcountry) $country
        set dir::info(demail) $email
    }
    
    proc p_search {} {
        toc_dir_search $::NSCREENNAME "$dir::info(dfn)\:$dir::info(dmn)\:$dir::info(dln)\:$dir::info(dmd)\:$dir::info(dcity)\:$dir::info(dstate)\:$dir::info(dcountry)"
        
        destroy .searchdir
    }
#####################
#####          search
#####################


     proc create_em_search {} {
        set w .em_searchdir

        if {[winfo exists $w]} {
            raise $w
            return
        }

        toplevel $w -class Tik
        wm title $w "Search Directory by Email"
        wm iconname $w "Email Search"
        # if {$::TIK(options,windowgroup)} {wm group $w .login}

        frame $w.demailF
        label $w.demaillabel -text "Email" -width 14 -anchor e
        entry $w.demail  -textvariable dir::info(demail)
        bind  $w.demail <Return> "dir::p_emsearch; break"

        pack $w.demaillabel $w.demail -in $w.demailF -side left

        pack $w.demailF -in $w -side top

        frame $w.buttons

        button $w.set -text "Email Search" -command "dir::p_emsearch"
        button $w.cancel -text "Cancel" -command [list destroy $w]
        pack $w.set $w.cancel -in $w.buttons -side left -padx 2m

        pack $w.buttons -side bottom

    }

    proc emsearch_dir {email} {
        
        set dir::info(demail) $email
    }
    
    proc p_emsearch {} {
        toc_dir_search $::NSCREENNAME "\:\:\:\:\:\:\:$dir::info(demail)"
        
        destroy .em_searchdir
    }

#############################
#####          keyword search
#############################


     proc create_kw_search {} {
        set w .kw_searchdir

        if {[winfo exists $w]} {
            raise $w
            return
        }

        toplevel $w -class Tik
        wm title $w "Search Directory by Keywords"
        wm iconname $w "Keyword Search"
        # if {$::TIK(options,windowgroup)} {wm group $w .login}

        frame $w.dfnF
        label $w.dfnlabel -text "Keyword" -width 14 -anchor e
        entry $w.dfn  -textvariable dir::info(dkw)
        bind  $w.dfn <Return> "dir::p_kw_search; break"
        pack $w.dfnlabel $w.dfn -in $w.dfnF -side left

        pack $w.dfnF -in $w -side top

        frame $w.buttons

        button $w.set -text "Search Dir" -command "dir::p_kw_search"
        button $w.cancel -text "Cancel" -command [list destroy $w]
        pack $w.set $w.cancel -in $w.buttons -side left -padx 2m

        pack $w.buttons -side bottom

    }

    proc kw_search_dir {kw} {
        
        set dir::info(dkw) $kw
    }
    
    proc p_kw_search {} {
        toc_dir_search $::NSCREENNAME "\:\:\:\:\:\:\:\:\:\:$dir::info(dkw)"
        
        destroy .kw_searchdir
    }
}


