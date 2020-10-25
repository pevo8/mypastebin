# MyPastebin
# Copyright (C) 2018 Petr Vojkovský <pevo@protonmail.com>

lappend auto_path [file join "."]
package require Tk
package require ::mypastebin::config
package require ::mypastebin::fraCollect
package require ::mypastebin::fraTagManager

if {![file exists [dict get $::mypastebin::config::dConf DBF]]} {
	tk_messageBox -type ok -icon warning -title "Info"\
		-message "Neexistuje DB."
	exit
} else {
	wm title . "MyPastebin"
	pack [ttk::notebook .nb] -fill both -expand 1
	.nb add [::mypastebin::fraCollect::gui] -text "Collect"
	.nb add [::mypastebin::fraTagManager::gui] -text "Tag Manager"

	tk_messageBox -type ok -message "MyPastebin v.0.3"
}
