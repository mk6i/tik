# Routines for proxy stuff
#######################################################
proc tik_noneproxy_config {} {
    set w .proxyconfig
    destroy $w

    toplevel $w -class Tik
    wm title $w [tik_str PROXY_TITLE]
    wm iconname $w [tik_str PROXY_ICON]
    if {$::TIK(options,windowgroup)} {wm group $w .login}
    label $w.label -text [tik_str PROXY_MSG]

    frame $w.tochostF
    label $w.tochostF.l -text [tik_str PROXY_TOCH]
    entry $w.tochostF.e -textvariable ::TOC($::SELECTEDTOC,host) \
        -exportselection 0
    pack $w.tochostF.l $w.tochostF.e -side left

    frame $w.tocportF
    label $w.tocportF.l -text [tik_str PROXY_TOCP]
    entry $w.tocportF.e -textvariable ::TOC($::SELECTEDTOC,port) \
        -exportselection 0
    pack $w.tocportF.l $w.tocportF.e -side left

    button $w.ok -text [tik_str B_OK] -command "destroy $w"
    pack $w.label $w.tochostF $w.tocportF $w.ok -side top
}

set ::TIK(proxies,names) [list None] 

proc tik_register_proxy {name connFunc configFunc} {
    set ::TIK(proxies,$name,connFunc) $connFunc
    set ::TIK(proxies,$name,configFunc) $configFunc
    lappend ::TIK(proxies,names) $name

    .login.prF.more.proxies.menu add radiobutton -label $name -variable ::USEPROXY
}

proc tik_unregister_proxy {name} {
    .login.prF.more.proxies.menu delete $name
}
