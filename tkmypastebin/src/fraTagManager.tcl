# MyPastebin: Frame: Tag management.
# Copyright (C) 2018 Petr Vojkovský <pevo@protonmail.com>

#package require Tk
package require ::mypastebin::tag 0.3
package require ::mypastebin::fraPaste 0.3

package provide ::mypastebin::fraTagManager 0.3

namespace eval ::mypastebin::fraTagManager {
    variable w .nb.fraTagManager
	variable lbxTags ""
	variable lIdTags {}
}

# Na kartě Collect zobrazuji všechy pastes.
proc ::mypastebin::fraTagManager::setIdTags {} {
	variable lIdTags
	set lIdTags [::mypastebin::tag::getIdTags]
}

proc ::mypastebin::fraTagManager::gui {} {
	variable w
	variable lbxTags
	variable lIdTags

	[namespace current]::setIdTags

	set fraTagManager [ttk::frame $w]

	set fraBtns [frame $w.fraBtns]
	set btnNewTag [button $fraBtns.btnNewPaste -text "New Tag" -command [namespace code btnNewTag_onClick]]
	
	set fraTags [frame $w.fraTags]

	set fraLbls [frame $fraTags.fraLbls]
	set lblNo [label $fraLbls.lblNo -justify left -text "#"]
	set lblTitle [label $fraLbls.lblDesc -justify left -text "Title"]
	# Rozmístění ve fraLbls
	grid $lblNo -row 0 -column 0 -sticky "we"
	grid $lblTitle -row 0 -column 1 -sticky "we"

	set lbxTags [listbox $fraTags.lbxTags \
		-selectmode single -setgrid 1  -width 95\
		-font [dict get $::mypastebin::config::dConf LBXFONT] \
		-yscroll "$fraTags.scbVert set"]
	set scbVert [scrollbar $fraTags.scbVert -command "$lbxTags yview"]
	#$lbxItems insert end "01 | První položka"
	[namespace current]::showTags

	# Rozmístění ve fraTags
	grid $fraLbls -row 0 -column 0 -columnspan 2 -sticky "nsew"
	grid $lbxTags -row 1 -column 0 -sticky "nsew"
	grid $scbVert -row 1 -column 1 -sticky "nsew"
	# Tell the listbox widget to take all the extra room
	# (see: Example doc/tcl8.6.7/html/TkCmd/grid.htm)
	grid rowconfigure $fraTags $lbxTags -weight 1
	grid columnconfigure $fraTags $lbxTags -weight 1

	#	bind $lbxItems <ButtonRelease-1> \
		{puts [%W get [%W curselection]]}
	bind $lbxTags <ButtonRelease-1> \
		{::mypastebin::fraTagManager::lbxTags_onSelect [%W curselection]}

	# Rozmístění v hlavním fraTagManager
	pack $btnNewTag
	pack $fraBtns
	pack $fraTags -fill both -expand 1
	
	return $w
}

# Zobrazí items v Tk Listboxu.
proc ::mypastebin::fraTagManager::showTags {} {
	variable w
	variable lbxTags
	variable lIdTags
	set val ""
	$lbxTags delete 0 end
	for {set i 0} {$i < [llength $lIdTags]} {incr i} {
		array set hTag [::mypastebin::tag::get [lindex $lIdTags $i]]
		$lbxTags insert end $hTag(LABEL) 
	}
}

# Načte lTags z DB a zaktualizuje jejich zobrazení v Tk Listboxu.
proc ::mypastebin::fraTagManager::refreshTags {} {
	[namespace current]::setIdTags
	[namespace current]::showTags
}

proc ::mypastebin::fraTagManager::btnNewTag_onClick {} {
	#tk_messageBox -type ok -message "The button was pressed."
	::mypastebin::fraTag::gui "insert" "null"
}

proc mypastebin::fraTagManager::lbxTags_onSelect {idx} {
	variable lIdTags
	[namespace current]::refreshTags
	if {[llength $lIdTags]} {
		#DEBUG: tk_messageBox -type ok -message [lindex $lIdItems $idx]
		::mypastebin::fraTag::gui "update" [lindex $lIdTags $idx]
	};# fi
}

