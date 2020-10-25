# MyPastebin: Frame: Paste
# Copyright (C) 2018 Petr Vojkovský <pevo@protonmail.com>

#package require Tk
package require ::mypastebin::paste
package require ::mypastebin::fraTagToPaste

package provide ::mypastebin::fraPaste 0.3

namespace eval ::mypastebin::fraPaste {
    variable w .fraPaste
	variable BASE $w
	variable dPaste [::mypastebin::paste::new]
	variable valTitle ""
	variable valContent ""
	variable mode "insert"
	variable paste_id "null"
}

# Inicializuje dPaste a nastaví proměnné, které jsou používány Tk widgety.
proc ::mypastebin::fraPaste::init {} {
	variable w
	variable dPaste
	variable valTitle
	variable valContent	

	set dPaste [::mypastebin::paste::new]
	set valTitle [dict get $dPaste TITLE]
	set valContent [dict get $dPaste CONTENT]
}

# Nastaví dPaste hodnotami z DB a aktualizuje proměnné, které používají widgety GUI.
proc ::mypastebin::fraPaste::setup {paid} {
	variable w
	variable dPaste
	variable valTitle
	variable valContent

	array set hPaste [::mypastebin::paste::get $paid]
	
	dict set dPaste ID $hPaste(ID)
	dict set dPaste TITLE $hPaste(TITLE)
	dict set dPaste CONTENT $hPaste(CONTENT)

	# Nastavení dat pro zobrazení v GUI.
	set valTitle [dict get $dPaste TITLE]
	# Pomocí RE nahradím znakové sekvence \n konci řádků.
	regsub -all {\\n} [dict get $dPaste CONTENT] "\n" valContent
}

proc ::mypastebin::fraPaste::gui {mod paid} {
	variable w
	variable BASE
	variable mode
	variable paste_id

	set mode $mod
	set paste_id $paid

	if {$mode == "insert"} {
		#DEBUG: puts "Mode: insert"
		[namespace current]::init
		#DEBUG: puts "\$valTitle = $lightGtd::fraItem:::valTitle"
	}

	if {$mode == "update"} {
		#DEBUG: puts "Mode: update"
	#	[namespace code setup $item_id]
		[namespace current]::setup $paid
	}

	set fraMain [toplevel $w]
	wm title $w "MyPastebin: Paste"
	if {$::tcl_platform(machine) == "armv7l"} {;# Pro můj tablet.
		wm geometry $w "[lindex [wm maxsize .] 0]x[lindex [wm maxsize .] 1]+0+0"
	};# fi
	set fraBtns [frame $w.fraBtns]
	set btnSave [button $fraBtns.btnSave -text "Save" -command [namespace code btnSave_onClick]]
	set btnDelete [button $fraBtns.btnDelete -text "Delete" -command [namespace code btnDelete_onClick]]
	set btnSetTag [button $fraBtns.btnSetTag -text "Přiřaď tagy" -command [namespace code btnSetTag_onClick]]
	set btnClose [button $fraBtns.btnClose -text "Close" -command [namespace code btnClose_onClick]]

	set lblTitle [label $w.lblTitle -justify left -text "Title"]
	set entTitle [entry $w.entTitle -textvariable [namespace current]::valTitle \
			-font [dict get $::mypastebin::config::dConf ENTFONT]]
	set lblDescr [label $w.lblDescr -justify left -text "Content"]
	set scbVert [scrollbar $w.scbVert -command "$w.txtContent yview"]
	set txtContent [text $w.txtContent -height 10 -wrap word \
			-yscroll "$scbVert set" \
			-font [dict get $::mypastebin::config::dConf TXTFONT]]
	#$txtDescr delete 1.0 end
	$txtContent insert end $::mypastebin::fraPaste::valContent
	# Na pozici sekvencí \n vložím zalomení řádku.
	#foreach line [split $lightGtd::fraItem::valDescr "\\n"] { 
	#	$txtDescr insert end "$line\n"
	#}

	pack $btnSave $btnDelete $btnSetTag $btnClose -side left -padx 10 -pady 10
	grid $lblTitle -row 1 -column 0 -columnspan 2 -sticky "nsew"
	grid $entTitle -row 2 -column 0 -columnspan 2 -sticky "nsew"
	#grid $lblContent -row 3 -column 0 -columnspan 2 -sticky "we"
	grid $txtContent -row 4 -column 0 -sticky "nsew"
	grid $scbVert -row 4 -column 1  -sticky "nsew"
	grid $fraBtns -row 5 -column 0 -columnspan 2 -sticky "nsew"
	# Tell the text widget to take all the extra room
	# (see: Example doc/tcl8.6.7/html/TkCmd/grid.htm)
	grid rowconfigure    $w $txtContent -weight 1
	grid columnconfigure $w $txtContent -weight 1
}

proc ::mypastebin::fraPaste::btnSave_onClick {} {
	variable w
	variable dPaste
	variable valTitle
	variable mode
	variable paste_id

	# Hodnoty z GUI zapíšu do dPaste.
	dict set dPaste TITLE $valTitle
	# Nejdříve odstraním poslední '\n' z textu:
	regexp {(.*)\n} [$w.txtContent get 1.0 end] match desired
	# Pomocí RE nahradím konce řádků sekvencí \n.
	regsub -all \[\n] $desired "\\n" str
	dict set dPaste CONTENT $str 
	#dict set dItem DESCRIPTION [$w.txtDescr get 1.0 end]
#	set delka [string length [$w.txtDescr get 1.0 end]]
#	puts "delka: $delka"
#	puts "nova delka: [string length [string range [$w.txtDescr get 1.0 end] 0 [expr $delka - 1]]]"

#	[namespace code SaveToDb]
	#tk_messageBox -type ok -message "[$w.txtDescr get 1.0 end]\n$[namespace current]::hItem(TITLE)"
	#tk_messageBox -type ok -message "[dict get $dItem DESCRIPTION]"

	if {$mode == "insert"} {
		::mypastebin::paste::insert $dPaste
		# FIXME: Když je to všdchno OK, tak:
		tk_messageBox -type ok -message "Zapsáno."
		# Aktualizace výpisu pastes ve fraCollect.
		::mypastebin::fraCollect::refreshPastes
		# Zavři toto okno.
		grab release $w
		destroy $w
	};# fi
	if {$mode == "update"} {
		#tk_messageBox -type ok -message "The button was pressed."
		::mypastebin::paste::update $dPaste
		# FIXME: Když je to všdchno OK, tak:
		tk_messageBox -type ok -message "Změny byly uloženy."
	};# fi
}

proc ::mypastebin::fraPaste::btnDelete_onClick {} {
	variable dPaste
	tk_messageBox -type ok -message "Paste [dict get $dPaste ID] bude smazán."
	::mypastebin::paste::delete [dict get $dPaste ID]
	# Aktualizace výpisu pastes ve fraCollect.
	::mypastebin::fraCollect::refreshPastes
	# Zavři toto okno.
	[namespace current]::btnClose_onClick
}

proc ::mypastebin::fraPaste::btnSetTag_onClick {} {
	variable w
	variable dPaste
	
	grab release $w
	#tk_messageBox -type ok -message "The button was pressed."
	::mypastebin::fraTagToPaste::gui $dPaste 
}

proc ::mypastebin::fraPaste::btnClose_onClick {} {
	variable w
	
	grab release $w
	destroy $w
	#tk_messageBox -type ok -message "The button was pressed."
}

