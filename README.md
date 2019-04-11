# Update flash player for macOS
Script for handling flash player NPAPI &amp; PPAPI install and updates in the shell.

Running the script without arguments checks for updates to installed plugins.

To install NPAPI or PPAPI using the script, run
`./updflsh.sh install npapi`
or
`./updflsh.sh install ppapi`
respectively.

Run `./updflsh.sh dialog`, for example as cronjob, for a popup dialog to install new updates.
