# MyPastebin: Frame: Přiřazení tagů jednomu pastu.
# Copyright (C) 2018 Petr Vojkovský <pevo@protonmail.com>

#package require Tk
package require ::mypastebin::tag 0.3

package provide ::mypastebin::fraTagToPaste 0.3

namespace eval ::mypastebin::fraTagToPaste {
    variable w .fraTagToPaste
	variable lbxTags ""
	variable lItems {}
	variable lTags {}
	variable sPasteId
}

proc ::mypastebin::fraTagToPaste::init {} {
	variable lTags
	variable lItems

	set lTags [::mypastebin::tag::getTags]
	set lItems {}
	foreach dTag $lTags {
		lappend lItems [dict get $dTag LABEL]
	}
}

proc ::mypastebin::fraTagToPaste::gui {dPaste} {
	variable w
	variable lbxTags
	variable lTags
	variable lItems
	variable sPasteId [dict get $dPaste ID]

	[namespace current]::init

	set lTagsByPaste [::mypastebin::tag::get_tags_by_paste $sPasteId]
	#set fraTagToPaste [ttk::frame $w]
	toplevel $w
	wm title $w "MyPastebin: Tag to Paste"

	set fraBtns [frame $w.fraBtns]
	set btnSave [button $fraBtns.btnSave -text "Save" \
		-command [namespace code btnSave_onClick]]
	set btnCancel [button $fraBtns.btnCancel -text "Cancel" \
		-command [namespace code btnCancel_onClick]]
	# Rozmístění ve fraBtns
	pack $btnSave $btnCancel -side left -padx 10 -pady 10

	set fraPasteInfo [frame $w.fraPasteInfo]
	set lblPaste [label $fraPasteInfo.lblPaste -justify left \
		-text "Paste: [dict get $dPaste TITLE]" \
		-font [dict get $::mypastebin::config::dConf LBLFONT]]
	# Rozmístění ve fraPasteInfo
	grid $lblPaste -row 0 -column 0 -sticky "we"
	
	set fraTags [frame $w.fraTags]
	set lblSelectedTags [label $fraTags.lblSelectedTags -justify left \
		-text "Počet přiřazených tagů: n" \
		-font [dict get $::mypastebin::config::dConf LBLFONT]]

	set lbxTags [listbox $fraTags.lbxTags \
		-listvariable [namespace current]::lItems \
		-selectmode extended -setgrid 1  -width 60\
		-font [dict get $::mypastebin::config::dConf LBXFONT] \
		-yscroll "$fraTags.scbVert set"]
	# Výběr položek v listboxu.
	set lTagIds {}
	foreach dTag $lTags {
		lappend lTagIds [dict get $dTag ID]
	}
	#DEBUG: puts "lTagsByPaste: $lTagsByPaste"
	#DEBUG: puts "lTagIds: $lTagIds"
	# Najdi index každého prvku listu $lTagsByPaste v listu $lTagIds.
	# Potom vyber položku s tímto indexem v lisboxu $lbxTags.
	foreach id $lTagsByPaste {
		$lbxTags selection set [lsearch -exact $lTagIds $id]
	}
	set scbVert [scrollbar $fraTags.scbVert -command "$lbxTags yview"]
	
	# Rozmístění ve fraTags
	grid $lblSelectedTags -row 0 -column 0 -columnspan 2 -sticky "nsew"
	grid $lbxTags -row 1 -column 0 -sticky "nsew"
	grid $scbVert -row 1 -column 1 -sticky "nsew"
	# Tell the listbox widget to take all the extra room
	# (see: Example doc/tcl8.6.7/html/TkCmd/grid.htm)
	grid rowconfigure $fraTags $lbxTags -weight 1
	grid columnconfigure $fraTags $lbxTags -weight 1
	
	# Rozmístění v hlavním fraTagToPaste
	pack $fraPasteInfo
	pack $fraTags -fill both -expand 1
	pack $fraBtns

	#bind $lbxTags <<ListboxSelect>> \
		{puts [llength [%W curselection]]}
	#bind $lbxTags <ButtonRelease-1> \
		{::mypastebin::fraTagToPaste::lbxTags_onSelect [%W curselection]}
}

proc ::mypastebin::fraTagToPaste::btnSave_onClick {} {
	variable w
	variable lbxTags
	variable lTags
	variable sPasteId

	set lTagIds {}
	foreach idx [$lbxTags curselection] {
		lappend lTagIds [dict get [lindex $lTags $idx] ID]
	}
	set answer [tk_messageBox -type okcancel -icon info \
		-message "Pastu bude přiřazeno [llength $lTagIds] tagy" \
		-title "Přiřazení tagů pastu."]
	switch -- $answer {
		ok {
			::mypastebin::tag::delete_tags_by_paste $sPasteId
			#FIXME: Zkontroluj, zda byly všechny záznamy uloženy do DB.
			::mypastebin::tag::insert_tags_to_paste "$sPasteId" "$lTagIds"
			tk_messageBox -type ok -icon info \
				-message "Provedeno."
			grab release $w
			destroy $w
		}
		cancel {
			tk_messageBox -type ok -icon info \
				-message "Nic neprovádím."
			grab release $w
			destroy $w
		}
	}
}

proc ::mypastebin::fraTagToPaste::btnCancel_onClick {} {
	variable w

	grab release $w
	destroy $w
	#tk_messageBox -type ok -message "The button was pressed."
}

#proc mypastebin::fraTagToPaste::lbxTags_onSelect {idx} {
#	variable lTags
#	[namespace current]::refreshTags
#	if {[llength $lTags]} {
		#DEBUG: tk_messageBox -type ok -message [dict get [lindex $lTags $idx] LABEL]
#	};# fi
#}

