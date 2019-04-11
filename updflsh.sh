#!/bin/sh
# run this, for example as cronjob, with "dialog" as argument for a popup dialog to install new updates
# (you need some form of external interaction when run as a cronjob, since cron has no tty)


#function declarations

doInstall() {
  # export vars
  set >~/.env.tmp

  if [ ! -z "$dialog" ]; then
    osascript -e '
      tell application "Terminal"
        activate
        do script "'"sudo bash $update_flash "'"
      end tell
      '
  else
    sudo bash $update_flash
  fi
}

doDialog() {
    foo=`osascript -e 'display dialog "'"$message"'" buttons {"No", "Yes"}'`
    if [ "$foo" == "button returned:Yes" ]; then
      doInstall
    fi
}


# var declarations

if [ "$1" = "dialog" ]; then
  dialog="yep"
fi

message="A new version of flash is available. Would you like to update now?"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
bname=`basename "$0"`
# make sure the worker script is postfixed "_worker.sh"
update_flash=$DIR/${bname%.*}_worker.sh

# if logfile doesnt exist, create it
logfile=$DIR/${bname%.*}.log
if [ ! -e $logfile ]; then
  touch $logfile 
fi

echo "-----⏰-----" >> $logfile
echo "`date`">> $logfile
echo "Checking available version..."| tee -a $logfile

# read current versions installed
current_npapi=`defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString 2>> /dev/null`
current_ppapi=`defaults read /Library/Internet\ Plug-Ins/PepperFlashPlayer/PepperFlashPlayer.plugin/Contents/Info.plist CFBundleShortVersionString 2>> /dev/null`

# fetch latest versions available
latest_ppapi=`curl -s https://get.adobe.com/flashplayer/about/|sed -n '/Safari/,/<\/tr/s/[^>]*>\([0-9].*\)<.*/\1/p'`
latest_npapi=`curl -s https://get.adobe.com/flashplayer/npapiosx/|grep 'Version'|egrep -o '([0-9]*)\.([0-9]*)\.([0-9]*)\.([0-9]*)'`
url_ppapi=https://fpdownload.adobe.com/get/flashplayer/pdc/"${latest_ppapi}"/install_flash_player_osx_ppapi.dmg
url_npapi=https://fpdownload.adobe.com/get/flashplayer/pdc/"${latest_npapi}"/install_flash_player_osx.dmg

if [ -z "$latest_ppapi" -o -z "$latest_npapi" ]; then
    echo "ERROR: Could not get data from adobe.com"
    exit -1
fi

# to install if not present, provide 'install npapi' or 'install ppapi'
if [ "$1" = "install" ]; then
  if [ "$2" = "ppapi" ]; then
    install_ppapi="install me"
    doInstall
  fi
  if [ "$2" = "npapi" ]; then
    install_npapi="install me instead"
    doInstall
  fi
fi


# compare versions. If newer version available install.
# (Only install new version if the plugin is already installed.) 
if [ ! -z "$current_npapi" -a "${current_npapi}" != "${latest_npapi}" ]; then
  new_npapi="install me"
  echo "New NPAPI version available!"|tee -a $logfile
 	echo "-> Installed version:    ${current_npapi}"|tee -a $logfile 
	echo "-> Newest version:   ${latest_npapi}"|tee -a $logfile 

fi
if [ ! -z "$current_ppapi" -a "${current_ppapi}" != "${latest_ppapi}" ]; then
  new_ppapi="install me too"
  echo "New PPAPI version available!"|tee -a $logfile
 	echo "-> Installed version:    ${current_ppapi}"|tee -a $logfile 
	echo "-> Newest version:   ${latest_ppapi}"|tee -a $logfile 
fi

if [ ! -z "$new_npapi" -o ! -z "$new_ppapi" ]; then
  if [ ! -z "$dialog" ]; then
    doDialog
  else
    doInstall 
  fi
else
  echo "No new updates found"|tee -a $logfile
  exit
fi
