# Create only one file for distribution/release.
cat src/config.tcl > app_mypastebin.tcl
cat src/paste.tcl >> app_mypastebin.tcl
cat src/tag.tcl >> app_mypastebin.tcl
cat src/fraTagToPaste.tcl >> app_mypastebin.tcl
cat src/fraPaste.tcl >> app_mypastebin.tcl
cat src/fraCollect.tcl >> app_mypastebin.tcl
cat src/fraTag.tcl >> app_mypastebin.tcl
cat src/fraTagManager.tcl >> app_mypastebin.tcl
cat src/mypastebin.tcl >> app_mypastebin.tcl

