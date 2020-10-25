# MyPastebin: Frame: Tag
# Copyright (C) 2018 Petr Vojkovský <pevo@protonmail.com>

#package require Tk
package require ::mypastebin::tag 0.3

package provide ::mypastebin::fraTag 0.3

namespace eval ::mypastebin::fraTag {
    variable w .fraTag
	variable BASE $w
	variable dTag [mypastebin::tag::new]
	variable valLabel ""
	variable valDescription ""
	variable mode "insert"
	variable tag_id "null"
}

# Inicializuje dTag a nastaví proměnné, které jsou používány Tk widgety.
proc ::mypastebin::fraTag::init {} {
	variable w
	variable dTag
	variable valLabel
	variable valDescription	

	set dTag [::mypastebin::tag::new]
	set valLabel [dict get $dTag LABEL]
	set valDescription [dict get $dTag DESCRIPTION]
}

# Nastaví dTag hodnotami z DB a aktualizuje proměnné, které používají widgety GUI.
proc ::mypastebin::fraTag::setup {tagid} {
	variable w
	variable dTag
	variable valLabel
	variable valDescription

	array set hPaste [::mypastebin::tag::get $tagid]
	
	dict set dTag ID $hPaste(ID)
	dict set dTag LABEL $hPaste(LABEL)
	dict set dTag DESCRIPTION $hPaste(DESCRIPTION)

	# Nastavení dat pro zobrazení v GUI.
	set valLabel [dict get $dTag LABEL]
	# Pomocí RE nahradím znakové sekvence \n konci řádků.
	regsub -all {\\n} [dict get $dTag DESCRIPTION] "\n" valDescription
}

proc ::mypastebin::fraTag::gui {mod tagid} {
	variable w
	variable BASE
	variable mode
	variable tag_id

	set mode $mod
	set tag_id $tagid

	if {$mode == "insert"} {
		#DEBUG: puts "Mode: insert"
		[namespace current]::init
		#DEBUG: puts "\$valLabel = $lightGtd::fraItem:::valLabel"
	}

	if {$mode == "update"} {
		#DEBUG: puts "Mode: update"
	#	[namespace code setup $item_id]
		[namespace current]::setup $tagid
	}

	set fraMain [toplevel $w]
	wm title $w "MyPastebin: Paste"
	if {$::tcl_platform(machine) == "armv7l"} {;# Pro můj tablet.
		wm geometry $w "[lindex [wm maxsize .] 0]x[lindex [wm maxsize .] 1]+0+0"
	};# fi
	set fraBtns [frame $w.fraBtns]
	set btnSave [button $fraBtns.btnSave -text "Save" -command [namespace code btnSave_onClick]]
	set btnDelete [button $fraBtns.btnDelete -text "Delete" -command [namespace code btnDelete_onClick]]
	set btnClose [button $fraBtns.btnClose -text "Close" -command [namespace code btnClose_onClick]]

	set lblTitle [label $w.lblTitle -justify left -text "Title"]
	set entTitle [entry $w.entTitle -textvariable [namespace current]::valLabel \
			-font [dict get $mypastebin::config::dConf ENTFONT]]
	set lblDescr [label $w.lblDescr -justify left -text "Content"]
	set scbVert [scrollbar $w.scbVert -command "$w.txtContent yview"]
	set txtContent [text $w.txtContent -height 10 -wrap word \
			-yscroll "$scbVert set" \
			-font [dict get $mypastebin::config::dConf TXTFONT]]
	#$txtDescr delete 1.0 end
	$txtContent insert end $mypastebin::fraTag::valDescription
	# Na pozici sekvencí \n vložím zalomení řádku.
	#foreach line [split $lightGtd::fraItem::valDescr "\\n"] { 
	#	$txtDescr insert end "$line\n"
	#}

	pack $btnSave $btnDelete $btnClose -side left -padx 10 -pady 10
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

proc ::mypastebin::fraTag::btnSave_onClick {} {
	variable w
	variable dTag
	variable valLabel
	variable mode
	variable tag_id

	# Hodnoty z GUI zapíšu do dTag.
	dict set dTag LABEL $valLabel
	# Nejdříve odstraním poslední '\n' z textu:
	regexp {(.*)\n} [$w.txtContent get 1.0 end] match desired
	# Pomocí RE nahradím konce řádků sekvencí \n.
	regsub -all \[\n] $desired "\\n" str
	dict set dTag DESCRIPTION $str 
	#dict set dItem DESCRIPTION [$w.txtDescr get 1.0 end]
#	set delka [string length [$w.txtDescr get 1.0 end]]
#	puts "delka: $delka"
#	puts "nova delka: [string length [string range [$w.txtDescr get 1.0 end] 0 [expr $delka - 1]]]"

#	[namespace code SaveToDb]
	#tk_messageBox -type ok -message "[$w.txtDescr get 1.0 end]\n$[namespace current]::hItem(LABEL)"
	#tk_messageBox -type ok -message "[dict get $dItem DESCRIPTION]"

	if {$mode == "insert"} {
		::mypastebin::tag::insert $dTag
		# FIXME: Když je to všdchno OK, tak:
		tk_messageBox -type ok -message "Zapsáno."
		# Aktualizace výpisu tags ve fraCollect.
		::mypastebin::fraTagManager::refreshTags
		# Zavři toto okno.
		grab release $w
		destroy $w
	};# fi
	if {$mode == "update"} {
		#tk_messageBox -type ok -message "The button was pressed."
		::mypastebin::tag::update $dTag
		# FIXME: Když je to všdchno OK, tak:
		tk_messageBox -type ok -message "Změny byly uloženy."
	};# fi
}

proc ::mypastebin::fraTag::btnDelete_onClick {} {
	variable dTag
	# tk_messageBox -type ok -message "Paste [dict get $dTag ID] bude smazán."
	set n [::mypastebin::tag::get_number_records_by_tag [dict get $dTag ID]]
	set answer [tk_messageBox -type yesno -icon question \
		-message "Opravdu chceš smazat tag\n[dict get $dTag LABEL]?\nTagem je označeno $n pastů." \
			-title "Smazání tagu"]
	switch -- $answer {
		yes {
			tk_messageBox -type ok -message "Tag [dict get $dTag LABEL] bude smazán."
			#Nejprve vymaž všechny záznamy s tímto tagem z tabulky patste_tag.
			# # mypastebin::tag::delete_tags_by_tag [dict get $dTag ID] 
			#FIXME: Zkontroluj, zda byly všechny záznamy uloženy do DB.
			# Potom:	
			#mypastebin::tag::delete [dict get $dTag ID]
			# Aktualizace výpisu tags ve fraCollect.
			#mypastebin::fraTagManager::refreshTags
			# Zavři toto okno.
			[namespace current]::btnClose_onClick
		}	
		no {
			tk_messageBox -type ok -icon info \
				-message "Nic neprovádím."
			# Zavři toto okno.
			[namespace current]::btnClose_onClick
		}
	}
}

proc ::mypastebin::fraTag::btnClose_onClick {} {
	variable w
	
	grab release $w
	destroy $w
	#tk_messageBox -type ok -message "The button was pressed."
}

