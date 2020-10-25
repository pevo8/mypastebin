# MyPastebin: Configuration 
# Copyright (C) 2018 Petr Vojkovský <pevo@protonmail.com>

package require Tcl 8.6
package provide ::mypastebin::config 0.3

namespace eval ::mypastebin::config {
	variable dConf [dict create DBF "../data/mypastebin.sdb" \
	LBLFONT "Helvetica 14" \
	ENTFONT "Helvetica 16" \
	LBXFONT "Helvetica 16" \
	TXTFONT "Helvetica 16"] 
}

