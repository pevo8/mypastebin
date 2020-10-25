# MyPastebin: Model: Paste.
# Copyright (C) 2018 Petr Vojkovský <pevo@protonmail.com>

package provide ::mypastebin::paste 0.3

package require ::mypastebin::config 
package require sqlite3

namespace eval ::mypastebin::paste {
	variable dPaste [dict create ID "" TITLE "" CONTENT "" \
		CREATED "" MODIFIED "" IS_DELETED ""]	
	variable dbf [dict get $::mypastebin::config::dConf DBF]
}

proc ::mypastebin::paste::new {} {
	return [dict create ID "" TITLE "" CONTENT "" \
		CREATED "" MODIFIED "" IS_DELETED "0"]	
}

# Načte data paste daného ID z databáze.
proc ::mypastebin::paste::get {id} {
	variable dbf
	sqlite3 dbh $dbf

	set lRow {}
	set sQuery "select * from pastes where ID = :id;"
	# set sQuery {select ID, TITLE, CONTENT, strftime("%Y-%m-%d %H:%M:%S", MODIFIED, 'unixepoch', 'localtime') as MODIFIED from pastes where ID = $id;}
	dbh eval $sQuery hRow {
		set lRow [array get hRow]
	}
	dbh close
	return $lRow
}

# Zapíše nový záznam do databáze.
proc ::mypastebin::paste::insert {dPaste} {
	variable dbf

	sqlite3 dbh $dbf
	set sTitle [dict get $dPaste TITLE]
	set sContent [dict get $dPaste CONTENT]
	#set sQuery "insert into pastes (TITLE, CONTENT) values ('[dict get $dPaste TITLE]', '[dict get $dPaste CONTENT]');"
	set sQuery "insert into pastes (TITLE, CONTENT) values (:sTitle, :sContent);"
#	tk_messageBox \
			-title "SQL query" \
			-icon info \
			-message "$sQuery"

	#DEBUG: puts $sQuery
	dbh eval $sQuery
	dbh close
	return 0 
}

# Updatuje záznam.
proc ::mypastebin::paste::update {dPaste} {
	variable dbf

	set sId [dict get $dPaste ID]
	set sTitle [dict get $dPaste TITLE]
	set sContent [dict get $dPaste CONTENT]

	sqlite3 dbh $dbf
	set sQuery "update pastes set TITLE = :sTitle, CONTENT = :sContent, MODIFIED = strftime('%s','now') where (ID = :sId);"

	#DEBUG: puts $sQuery
	dbh eval $sQuery
	dbh close
	return 0 
}

# Vymaže záznam s daným ID z tabulky pastes
proc ::mypastebin::paste::delete {id} {
	variable dbf

	sqlite3 dbh $dbf
	set sQuery "delete from pastes where ID = :id;"
#	tk_messageBox \
			-title "SQL query" \
			-icon info \
			-message "$sQuery"

	#DEBUG: puts $sQuery
	dbh eval $sQuery
	dbh close
	return 0 
}

# Načte seznam všech ID pastes z databáze.
proc ::mypastebin::paste::getIdPastes {} {
	variable dbf
	set lIds {}

	sqlite3 dbh $dbf
	set sQuery "select ID from pastes order by MODIFIED desc;"

	dbh eval $sQuery hRow {
		lappend lIds $hRow(ID)
	}
	dbh close
	return $lIds
}

# Načte seznam všech pastes z databáze.
proc ::mypastebin::paste::getPastes {} {
	variable dbf
	set lRows {}

	sqlite3 dbh $dbf
	set sQuery "select ID, TITLE, CONTENT from pastes;"

	dbh eval $sQuery hRow {
		lappend lRows [array get hRow]
	}
	dbh close
	return $lRows 
}

