# Update flash player for macOS
Script for handling flash player NPAPI &amp; PPAPI install and updates in the shell.

Running the script without arguments checks for updates to installed plugins.
To install NPAPI or PPAPI using the script, run
`./updtflsh.sh install npapi`
or
`./updtflsh.sh install ppapi`
respectively.

Run `./updtflsh.sh dialog`, for example as cronjob, for a popup dialog to install new updates.
(You need some form of external interaction when run as a cronjob, since cron has no tty)
