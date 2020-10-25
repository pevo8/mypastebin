# MyPastebin: Frame: Collect pastes.
# Copyright (C) 2018 Petr Vojkovský <pevo@protonmail.com>

#package require Tk
package require ::mypastebin::paste 0.3
package require ::mypastebin::fraPaste 0.3

package provide ::mypastebin::fraCollect 0.3

namespace eval ::mypastebin::fraCollect {
    variable w .nb.fraCollect
	variable lbxPastes ""
	variable lIdPastes {}
}

# Na kartě Collect zobrazuji všechy pastes.
proc ::mypastebin::fraCollect::setIdPastes {} {
	variable lIdPastes
	set lIdPastes [::mypastebin::paste::getIdPastes]
}

proc ::mypastebin::fraCollect::gui {} {
	variable w
	variable lbxPastes
	variable lIdPastes

	[namespace current]::setIdPastes

	set fraCollect [ttk::frame $w]

	set fraBtns [frame $w.fraBtns]
	set btnNewPaste [button $fraBtns.btnNewPaste -text "New Paste" -command [namespace code btnNewPaste_onClick]]
	# Rozmístění ve fraBtns
	pack $btnNewPaste

	set fraPastes [frame $w.fraPastes]

	set fraLbls [frame $fraPastes.fraLbls]
	set lblNo [label $fraLbls.lblNo -justify left -text "#"]
	set lblTitle [label $fraLbls.lblDesc -justify left -text "Title"]
	# Rozmístění ve fraLbls
	grid $lblNo -row 0 -column 0 -sticky "we"
	grid $lblTitle -row 0 -column 1 -sticky "we"

	set lbxPastes [listbox $fraPastes.lbxPastes \
		-selectmode single -setgrid 1  -width 95\
		-font [dict get $::mypastebin::config::dConf LBXFONT] \
		-yscroll "$fraPastes.scbVert set"]
	set scbVert [scrollbar $fraPastes.scbVert -command "$lbxPastes yview"]
	#$lbxItems insert end "01 | První položka"
	[namespace current]::showPastes

	# Rozmístění ve fraPastes
	grid $fraLbls -row 0 -column 0 -columnspan 2 -sticky "nsew"
	grid $lbxPastes -row 1 -column 0 -sticky "nsew"
	grid $scbVert -row 1 -column 1 -sticky "nsew"
	# Tell the listbox widget to take all the extra room
	# (see: Example doc/tcl8.6.7/html/TkCmd/grid.htm)
	grid rowconfigure $fraPastes $lbxPastes -weight 1
	grid columnconfigure $fraPastes $lbxPastes -weight 1

	#	bind $lbxItems <ButtonRelease-1> \
		{puts [%W get [%W curselection]]}
	bind $lbxPastes <ButtonRelease-1> \
		{::mypastebin::fraCollect::lbxPastes_onSelect [%W curselection]}

	# Rozmístění v hlavním fraCollect
	pack $fraBtns
	pack $fraPastes -fill both -expand 1
	
	return $w
}

# Zobrazí items v Tk Listboxu.
proc ::mypastebin::fraCollect::showPastes {} {
	variable w
	variable lbxPastes
	variable lIdPastes
	set val ""
	$lbxPastes delete 0 end
	for {set i 0} {$i < [llength $lIdPastes]} {incr i} {
		array set hPaste [::mypastebin::paste::get [lindex $lIdPastes $i]]
		if {[string length $hPaste(TITLE)]} {
			set val "[clock format $hPaste(MODIFIED) -format "%Y-%m-%d"] $hPaste(TITLE)"
		}

		$lbxPastes insert end "[format "%02d" [expr $i+1]] | $val"
	}
}

# Načte lPastes z DB a zaktualizuje jejich zobrazení v Tk Listboxu.
proc ::mypastebin::fraCollect::refreshPastes {} {
	[namespace current]::setIdPastes
	[namespace current]::showPastes
}

proc ::mypastebin::fraCollect::btnNewPaste_onClick {} {
	#tk_messageBox -type ok -message "The button was pressed."
	::mypastebin::fraPaste::gui "insert" "null"
}

proc ::mypastebin::fraCollect::lbxPastes_onSelect {idx} {
	variable lIdPastes
	[namespace current]::refreshPastes
	if {[llength $lIdPastes]} {
		#DEBUG: tk_messageBox -type ok -message [lindex $lIdItems $idx]
		::mypastebin::fraPaste::gui "update" [lindex $lIdPastes $idx]
	};# fi
}

