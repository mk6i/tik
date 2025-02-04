# Search Package
#
# Provide a search box at the bottom of the buddy list
# used to search some common search engines.
#
# $Revision: 1.5 $

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
namespace eval search {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK Search package $Revision: 1.5 $} \
      ::search::VERSION
  regexp -- { .* } {:$Date: 2000/09/21 01:55:56 $} \
      ::search::VERSDATE
}

package require http 2.0

# Options the user might want to set.  A user should use
# set ::TIK(options,...), not the tik_default_set

tik_default_set options,Search,display 1
tik_default_set options,Search,default NetFind

namespace eval search {

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    variable info

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        menu .searchMenu -tearoff 0
        .toolsMenu add cascade -label [tik_str P_SEARCH_M] -menu .searchMenu
        .searchMenu add checkbutton -label [tik_str P_SEARCH_M_SHOW] \
                -variable ::TIK(options,Search,display) -command search::display

        # To add a new engine just stick it here, and
        # the %FIND% in the url will be replaced with the search string.
        set search::info(Engine,NetFind) \
                {http://netfind.aol.com/search.gw?search=%FIND%&lk=excite_netfind2_us&nrm=n&pri=on&xls=b&xll=40}
        set search::info(Engine,Deja\ News) \
                {http://search.dejanews.com/dnquery.xp?QRY=%FIND%&defaultOp=AND&LNG=ALL&ST=QS&svcclass=dncurrent&DBS=1}
        set search::info(Engine,AltaVista) \
                {http://www.altavista.com/cgi-bin/query?pg=q&what=web&fmt=&q=%FIND%}
        set search::info(Engine,Yahoo) \
                {http://search.yahoo.com/bin/search?p=%FIND%}
        set search::info(Engine,SearchSpaniel) \
                {http://www.searchspaniel.com/cgi-bin/spaniel.pl?criteria=%FIND%&displaymode=window&metacrawler=yes&onramp=yes&dogpile=yes&startingpoint=yes&searchcom=yes}
        set search::info(Engine,SearchSpaniel-All) \
                {http://www.searchspaniel.com/cgi-bin/spaniel.pl?criteria=%FIND%&displaymode=window&altavista=yes&excite=yes&infoseek=yes&linkstar=yes&lycos=yes&magellan=yes&northernlight=yes&webcrawler=yes&yahoo=yes&infohiway=yes&looksmart=yes&linkmonster=yes}
        set search::info(Engine,Metacrawler) \
                {http://search.go2net.com/crawler?general=%FIND%&method=0&target=&region=0&rpp=20&timeout=5&hpe=10}
        set search::info(Engine,Infoseek) \
                {http://infoseek.go.com/Titles?qt=%FIND%&col=WW&sv=IS&lk=noframes}
        set search::info(Engine,Google) \
                {http://google.com/search?q=%FIND%}
        set search::info(Engine,GoogleLinux) \
                {http://google.com/linux?q=%FIND%}

    }


    # All pacakges must have goOnline routine.  Called when the user signs
    # on, or if the user is already online when packages loaded.
    proc goOnline {} {
        display
        destroy .engineMenu
        menu .engineMenu -tearoff 0
        .searchMenu add cascade -label [tik_str P_SEARCH_ENGINE] -menu .engineMenu
        .engineMenu add radiobutton -label "TOC" -variable ::TIK(options,Search,default)
        foreach i [lsort -dictionary [array names search::info Engine,*]] {
            set lab [lindex [split $i ,] 1]
            if {$lab == "TOC"} { continue }
            .engineMenu add radiobutton -label $lab -variable ::TIK(options,Search,default)
        }
    }

    # All pacakges must have goOffline routine.  Called when the user signs
    # off.  NOT called when the package is unloaded.
    proc goOffline {} {
    }

    # All packages must have a unload routine.  This should remove everything 
    # the package set up.  This is called before load is called when reloading.
    proc unload {} {
        .toolsMenu delete [tik_str P_SEARCH_M]
        destroy .searchMenu
        destroy .engineMenu
        destroy .buddy.searchF
    }

    proc display {} {
        set w .buddy.searchF
        destroy $w

        if {!$::TIK(options,Search,display)} {
            return
        }

        set search::info(searchfor) [tik_str P_SEARCH_STR]
        frame $w
        entry $w.input -exportselection false -textvariable search::info(searchfor)
        bind $w.input <Return> search::doSearch
        bind $w.input <ButtonPress-3> {tk_popup .engineMenu %X %Y}

        pack $w.input -in $w -side top -expand 1 -fill x

        pack $w -in .buddy -before .buddy.bottomF -side bottom -fill x
        $w.input selection range 0 end
        focus $w.input
    }

    proc doSearch {} {
        if {$::TIK(options,Search,default) == "TOC"} {
            toc_dir_search $::NSCREENNAME $search::info(searchfor)
        } else {
            set url $search::info(Engine,$::TIK(options,Search,default))
            regsub -all -- "%FIND%" $url [http::formatQuery $search::info(searchfor)] url
            tik_show_url "Find" $url
        }
        .buddy.searchF.input selection range 0 end
    }
}
