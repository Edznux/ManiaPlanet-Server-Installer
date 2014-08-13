#!/bin/bash
message_start()
{
	echo "This is an simple installation script for Maniaplanet servers"
	echo "If you find an issue in this script, please send an issue to edznux on maniaplanet forum"
	echo "Or on http://github.com/edznux"
	echo "Maniaplanet documentation : "
	echo "http://doc.maniaplanet.com/"
	echo ""
}
setup()
{
	echo "You need to provide some information created on your player page (http://player.maniaplanet.com) > dedicated server"
	read -p "What is your server login: " server_login
	read -p "What is your server password: " server_pass
	read -p "What is your validation key: " server_key
	read -p "Server name (seen by players): " server_name
	read -p "Server description (seen by players): " server_description
	echo "Spellchecking for game name :"
	echo ""
	echo "SMStorm TMCanyon TMStadium TMValley"
	echo ""	
	read -p "Server Game (CASE SENSITIVE): " server_game
	read -p "Confirm information ? (Y/n): " confirm

	if [[ "$confirm" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		cp ./UserData/Config/dedicated_cfg.default.txt ./UserData/Config/dedicated_cfg.txt
		#sed -i '/\<password\>\<\/password\>/c\<\password\>$server_pass\<\/password\>' ./UserData/Config/dedicated_cfg.default.txt
		xmlstarlet ed -S -P -L -u "/dedicated/masterserver_account/login" -v $server_login  ./UserData/Config/dedicated_cfg.txt
		xmlstarlet ed -S -P -L -u "/dedicated/masterserver_account/password" -v $server_pass  ./UserData/Config/dedicated_cfg.txt
		xmlstarlet ed -S -P -L -u "/dedicated/masterserver_account/validation_key" -v $server_key  ./UserData/Config/dedicated_cfg.txt
	        xmlstarlet ed -S -P -L -u "/dedicated/server_options/name" -v $server_name  ./UserData/Config/dedicated_cfg.txt
	        xmlstarlet ed -S -P -L -u "/dedicated/server_options/comment" -v $server_description  ./UserData/Config/dedicated_cfg.txt
		xmlstarlet ed -S -P -L -u  "/dedicated/server_options/title" -v $server_game ./UserData/Config/dedicated_cfg.txt

	else
		echo "Setup reset, please provide your right information"
		setup
	fi
}

adv_conf()
{
	read -p "Do you want to make some advanced configuration (set password for server, change superAdmin and admin password, change slot etc...) ? (Y/N)" adv
	if [[ "$adv" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
	#SuperAdmin password
                read -p "Change SuperAdmin password (Hightly recommended): " SuperAdmin_pass
                if [ "$SuperAdmin_pass" == "" ];then
                        echo "Password not modified"
                else
                        xmlstarlet ed -S -P -L -u  '/dedicated/authorization_levels/level/[name="SuperAdmin"]/password' -v $SuperAdmin__pass ./UserData/Config/dedicated_cfg.txt
                fi
	#Admin password
                read -p "Change Admin password (Hightly recommended): " Admin_pass
                if [ "$Admin_pass" == "" ];then
                        echo "Password not modified"
                else
                        ##TODO
 			xmlstarlet ed -S -P -L -u  '/dedicated/authorization_levels/level/[name="Admin"]/password' -v $Admin__pass ./UserData/Config/dedicated_cfg.txt
                        #xmlstarlet ed -L -u  "/dedicated/server_options" -v $join_pass ./UserData/Config/dedicated_cfg.txt
                fi

	#players password
		read -p "Set server password (leave empty for no modification, default : no password): " join_pass
		if [ "$join_pass" == "" ];then
			echo "Password not modified"
		else
			xmlstarlet ed -S -P -L -u  "/dedicated/server_options/password" -v $join_pass ./UserData/Config/dedicated_cfg.txt
		fi
	#players slots
                read -p "Set players max slost: " players_max_slot
                if [ "$players_max_slot" == "" ];then
                        echo "Players slots not modified"
                else
			##TODO
                        xmlstarlet ed -S -P -L -u  "/dedicated/server_options/max_players" -v $players_max_slot ./UserData/Config/dedicated_cfg.txt
		  fi
	#spectator slots
                read -p "Set spectator slots: " spec__max_slot
                if [ "$spec_max_slot" == "" ];then
                        echo "Spectator slots not modified"
                else
                        ##TODO
			xmlstarlet ed -S -P -L -u  "/dedicated/server_options/max_spectators" -v $spec_max_slot ./UserData/Config/dedicated_cfg.txt
                       	#xmlstarlet ed -L -u  "/dedicated/server_options" -v $join_pass ./UserData/Config/dedicated_cfg.txt
                fi
	fi
}
check_xmlstarlet()
{
if [ -x "xmlstarlet" ];then
	echo "xmlstarlet installed!"
else
	echo "Please install xmlstarlet (apt-get install xmlstarlet)"
	exit 0
fi
}
check_dir()
{
read -p "How do you want to name your server (directory name): " name
if [ -d "$name" ]; then
	read -p  "This directory is already used! Do you want to erase (delete) it? [Y/n]: " dir_exist
	if [[ "$dir_exist" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		rm -r $name
		mkdir $name
	else
		check_dir
	fi
else
	mkdir $name
fi
}

##Script start here

message_start

read -p "Do you want install maniaplanet Server ? (Y/n): " insta

if [[ "$insta" =~ ^([yY][eE][sS]|[yY])$ ]]
then
        check_dir
        echo "Downloading latest version. Please wait"
	echo "$name"
        rm -f ManiaPlanetBetaServer_latest.zip
        wget -O $name/ManiaPlanetBetaServer_latest.zip "http://files.maniaplanet.com/ManiaPlanet3Beta/ManiaPlanetBetaServer_latest.zip"
        #mv ManiaPlanetBetaServer_latest.zip $name/
        cd $name
	echo "Please wait, this operation can take 2 min or more on slow hardware (unzip whole server)"
        unzip -q "ManiaPlanetBetaServer_latest.zip"
	echo ""
        setup
        adv_conf

else

	echo "exiting"

fi

