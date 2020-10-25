# MyPastebin: Model: Tag
# Copyright (C) 2018 Petr Vojkovský <pevo@protonmail.com>

package provide ::mypastebin::tag 0.3

package require ::mypastebin::config 
package require sqlite3

namespace eval ::mypastebin::tag {
	variable dTag [dict create ID "" LABEL "" DESCRIPTION "" REMARK ""]	
	variable dbf [dict get $::mypastebin::config::dConf DBF]
}

proc ::mypastebin::tag::new {} {
	return [dict create ID "" LABEL "" DESCRIPTION "" REMARK ""]
}

# Načte data tagu daného ID z databáze.
proc ::mypastebin::tag::get {id} {
	variable dbf
	sqlite3 dbh $dbf

	set lRow {}
	set sQuery {select * from tags where ID = :id;}
	dbh eval $sQuery hRow {
		set lRow [array get hRow]
	}
	dbh close
	return $lRow
}

# Zapíše nový záznam do databáze.
proc ::mypastebin::tag::insert {dTag} {
	variable dbf

	sqlite3 dbh $dbf
	set sLabel [dict get $dTag LABEL]
	set sDescription [dict get $dTag DESCRIPTION]
	set sRemark [dict get $dTag REMARK]
	
	set sQuery {insert into tags (LABEL, DESCRIPTION) values (:sLabel, :sDescription);}
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
proc ::mypastebin::tag::update {dTag} {
	variable dbf

	sqlite3 dbh $dbf
	set sId [dict get $dTag ID]
	set sLabel [dict get $dTag LABEL]
	set sDescription [dict get $dTag DESCRIPTION]
	set sRemark [dict get $dTag REMARK]
	set sQuery {update tags set LABEL = :sLabel, DESCRIPTION = :sDescription where (ID = :sId);}

	#DEBUG: puts $sQuery
	dbh eval $sQuery
	dbh close
	return 0 
}

# Vymaže záznam s daným ID z tabulky tags
proc ::mypastebin::tag::delete {id} {
	variable dbf

	sqlite3 dbh $dbf
	set sQuery {delete from tags where ID = :id;}
#	tk_messageBox \
			-title "SQL query" \
			-icon info \
			-message "$sQuery"

	#DEBUG: puts $sQuery
	dbh eval $sQuery
	dbh close
	return 0 
}

# Načte seznam všech ID tagů z databáze.
proc ::mypastebin::tag::getIdTags {} {
	variable dbf
	set lIds {}

	sqlite3 dbh $dbf -readonly true
	set sQuery {select ID from tags order by LABEL;}

	dbh eval $sQuery hRow {
		lappend lIds $hRow(ID)
	}
	dbh close
	return $lIds
}

# Načte seznam všech tagů z databáze.
# Pouze ID a LABEL tagu. Je to pro použití v tk::listbox widgetu.
# Returns List of Dictionaries.
proc ::mypastebin::tag::getTags {} {
	variable dbf
	set lRows {}

	sqlite3 dbh $dbf -readonly true
	set sQuery {select ID, LABEL from tags order by LABEL;}

	dbh eval $sQuery hRow {
		lappend lRows [dict create ID $hRow(ID) LABEL $hRow(LABEL)]
	}
	dbh close
	return $lRows 
}

# Pro tabulku paste_tag.
#
# Z tabulky paste_tag získá počet záznamů pro daný paste.
proc ::mypastebin::tag::get_number_records_by_paste {paste_id} {
	variable dbf
	set sCount 0

	sqlite3 dbh $dbf
	set sQuery {select count(*) from paste_tag where PASTE = :paste_id;}
	#DEBUG: puts $sQuery
	set sCount [dbh onecolumn $sQuery]
	#DEBUG: puts $sItemId

	dbh close
	return $sCount 
}

# Z tabulky paste_tag získá počet záznamů pro daný tag.
proc ::mypastebin::tag::get_number_records_by_tag {tag_id} {
	variable dbf
	set sCount 0

	sqlite3 dbh $dbf
	set sQuery {select count(*) from paste_tag where TAG = :tag_id;}
	#DEBUG: puts $sQuery
	set sCount [dbh onecolumn $sQuery]
	#DEBUG: puts $sItemId

	dbh close
	return $sCount 
}



# Z tabulky paste_tag získá seznam (list) ID tagů pro daný paste.
proc ::mypastebin::tag::get_tags_by_paste {paste_id} {
	variable dbf

	set lRows {}
	sqlite3 dbh $dbf
	set sQuery {select TAG from paste_tag where PASTE = :paste_id;}
	#DEBUG: puts $sQuery
	dbh eval $sQuery hRow {
		lappend lRows $hRow(TAG)
	}
	dbh close
	return $lRows 
}

# Vymaže záznamy z tabulky paste_tag pro daný paste.
proc ::mypastebin::tag::delete_tags_by_paste {paste_id} {
	variable dbf

	sqlite3 dbh $dbf
	set sQuery {delete from paste_tag where PASTE = :paste_id;}
	#DEBUG: puts $sQuery
	dbh eval $sQuery
	dbh close
	return 0 
}

# Vymaže záznamy z tabulky paste_tag pro daný tag.
proc ::mypastebin::tag::delete_tags_by_tag {tag_id} {
	variable dbf

	sqlite3 dbh $dbf
	set sQuery {delete from paste_tag where TAG = :tag_id;}
	#DEBUG: puts $sQuery
	dbh eval $sQuery
	dbh close
	return 0 
}


# Zapíše nový záznam(y) do tabulky paste_tag.
proc ::mypastebin::tag::insert_tags_to_paste {paste_id lTagId} {
	variable dbf

	sqlite3 dbh $dbf
	#FIXME: Zpracuj to jako dávku (COMMIT).
	foreach tag_id $lTagId {
		set sQuery {insert into paste_tag (PASTE, TAG) values (:paste_id, :tag_id);}
		dbh eval $sQuery
	}
	dbh close
	return 0 
}

