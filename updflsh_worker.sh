#!/bin/sh 
# Don't run this directly


# import vars
. ~/.env.tmp
rm ~/.env.tmp


installNPAPI() {
  # mount dmg file
  sudo hdiutil attach $dl_path_npapi -nobrowse -quiet
  echo "Installing NPAPI..." 
  #pkg_path=`find /Volumes/Flash\ Player -name '*Adobe\ Flash\ Player.pkg'|sed 's/\ /\\\ /g'`
  pkg_path=`find /Volumes/Flash\ Player -name '*Adobe\ Flash\ Player.pkg'`
  sudo installer -pkg "$pkg_path" -target / 
  sleep 2
  echo "Unmounting installer disk image." 
  sudo hdiutil detach $(df | grep "Flash"|head -n1| awk '{print $1}') -quiet
  sleep 2

  # check for success
  instver_npapi=`defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString`
  if [ "$latest_npapi" = "$instver_npapi" ]; then
      echo "SUCCESS: NPAPI has been updated to version $instver_npapi"|tee -a $logfile 
      echo "Deleting disk image." 
      rm $dl_path_npapi
  else
    echo "FAILURE: Something went wrong while trying to install NPAPI version $latest_npapi"|tee -a $logfile
  fi
}

installPPAPI(){
  # mount dmg file
  sudo hdiutil attach $dl_path_ppapi -nobrowse -quiet
  echo "Installing PPAPI..." 
  #pkg_path=`find /Volumes/Flash\ Player -name '*Adobe\ Flash\ Player.pkg'|sed 's/\ /\\\ /g'`
  pkg_path=`find /Volumes/Flash\ Player -name '*Adobe\ Flash\ Player.pkg'`
  sudo installer -pkg "$pkg_path" -target / 
  sleep 2
  echo "Unmounting installer disk image." 
  sudo hdiutil detach $(df | grep "Flash"|head -n1| awk '{print $1}') -quiet
  sleep 2
  
  # check for success
  instver_ppapi=`defaults read /Library/Internet\ Plug-Ins/PepperFlashPlayer/PepperFlashPlayer.plugin/Contents/Info.plist CFBundleShortVersionString`
  if [ "$latest_ppapi" = "$instver_ppapi" ]; then
      echo "SUCCESS: PPAPI has been updated to version $instver_ppapi"|tee -a $logfile 
      echo "Deleting disk image." 
      rm $dl_path_ppapi
  else
    echo "FAILURE: Something went wrong while trying to install PPAPI version $latest_ppapi"|tee -a $logfile
  fi
}

startInstall(){
  # make sure to be root to install
  if [[ "$(sudo whoami)" != "root" ]]; then
    exit
  fi
  # if new npapi available, download and install
  if [ ! -z "$new_npapi" -o ! -z "$install_npapi" ]; then
    # create filename, download 
    dl_path_npapi=~/Downloads/flash_npapi_"${latest_npapi}".dmg
    echo "Downloading NPAPI version $latest_npapi"
    curl -o $dl_path_npapi $url_npapi
    installNPAPI
  fi

  # if new ppapi available, download and install
  if [ ! -z "$new_ppapi" -o ! -z "$install_ppapi" ]; then
    # create filename, download 
    dl_path_ppapi=~/Downloads/flash_npapi_"${latest_ppapi}".dmg
    echo "Downloading PPAPI version $latest_ppapi"
    curl -o $dl_path_ppapi $url_ppapi
    installPPAPI
  fi
}



if [ ! -z "$dialog" -o ! -z "$install_npapi" -o ! -z "$install_ppapi" ]; then
  startInstall
elif [ ! -z "$new_npapi" -o ! -z "$new_ppapi" ]; then
  echo $message "(yes/no)"
  read foo
  if [ "$foo" = "y" -o "$foo" = "yes" ];then
    startInstall
  else
    exit
  fi
fi
