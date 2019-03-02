# Update flash player for macOS
Script for handling flash player NPAPI &amp; PPAPI install and updates in the shell.

Running the script without arguments checks for updates to installed plugins.
To install NPAPI or PPAPI using the script, run
`./update_flash.sh install npapi`
or
`./update_flash.sh install ppapi`
respectively.

Run
`./update_flash.sh cronjob`
to get a popup dialog if a new update is available. Useful when run as a cronjob.
