# My New Essentials
#
# Provide links to the mynews daily essentials.
#
# $Revision: 1.6 $

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
namespace eval mynews {     
  regexp -- {[0-9]+\.[0-9]+} {@(#)TiK My News package $Revision: 1.6 $} \
      ::mynews::VERSION
  regexp -- { .* } {:$Date: 2000/03/22 20:37:28 $} \
      ::mynews::VERSDATE
}

namespace eval mynews {

    # Must export at least: load, unload, goOnline, goOffline
    namespace export load unload goOnline goOffline

    # All packages must have a load routine.  This should do most
    # of the setup for the package.  Called only once.
    proc load {} {
        menu .myNewsMenu -tearoff 0
        .toolsMenu add cascade -label "Daily Essentials" -menu .myNewsMenu
        .myNewsMenu add command -label "Web Search" \
              -command {tik_show_url "DE" "http://www.aol.com/netfind/home.html"}
        .myNewsMenu add command -label "My News" \
              -command {tik_show_url "DE" "http://www.aol.com/mynews/home.adp"}
        .myNewsMenu add command -label "Stocks" \
              -command {tik_show_url "DE" "http://www.aol.com/mynews/business/home.adp"}
        .myNewsMenu add command -label "Weather" \
              -command {tik_show_url "DE" "http://www.aol.com/mynews/weather/home.adp"}
        .myNewsMenu add command -label "Scores" \
              -command {tik_show_url "DE" "http://realfans.aol.com/?MIval=rf_allscores.htm"}
        .myNewsMenu add command -label "Horoscopes" \
              -command {tik_show_url "DE" "http://www.aol.com/mynews/entertainment/horoscopes.adp"}
        .myNewsMenu add command -label "AOL Netmail" \
              -command {tik_show_url "DE" "http://www.aol.com/netmail"}
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
        .toolsMenu delete "Daily Essentials"
        destroy .myNewsMenu
    }
}
