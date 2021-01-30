#!/bin/bash

echo -ne "\n---------Welcome to MariaDB setup---------"

echo -ne "\n\nChecking Permisions...\n"
sudo ls &> /dev/null
if [ $? -ne 0 ]
then
	echo "$USER not having the sudo privileges. This setup will need root user or sudo privileges. Try again later !"
	exit 1
fi
echo -ne "\nChecking Packages...\n"
sleep 1
required_packages="apache2 mariadb-server phpmyadmin php-mbstring php-zip php-gd php-json php-curl"
packages_to_be_installed=""
for package in $required_packages
do
	dpkg -l $package &> /dev/null
	if [ $? -ne 0 ]
	then
		packages_to_be_installed="$packages_to_be_installed $package"
	fi
done

if [ "$packages_to_be_installed" != '' ]
then
	echo -ne "\n\nFollowing packages are to be installed\n"
	for package in $packages_to_be_installed
	do
		echo $package
	done
	echo -ne "\n\n"
	read -p "Do you wish to install the packages to continue (Y/n) " user_input
	if [ "$user_input" != 'Y' ] && [ "$user_input" != 'y' ]
	then
		exit 1
	fi
	for package in $packages_to_be_installed
        do
                sudo apt-get install -y $package
		if [ $? -ne 0 ]
		then
			echo -ne "\n\n Package $package is not installed\n"
			exit 1
		fi
        done
	
fi
echo $packages_to_be_installed | grep mariadb &> /dev/null
if [ $? -eq 0 ]
then
	sudo mysql_secure_installation
fi
# Doing setup of the user and database
while true
do
	echo ""
	read -p "Database user : " db_user
	if [ ${#db_user} -ge 3 ]
	then
		read -p "Password : " -s db_pass
		echo ""
		read -p "Re-Enter Password : " -s db_pass1
		if [ ${#db_pass} -ge 6 ] && [ $db_pass == $db_pass1 ]
		then
			break
		fi
	else 
		echo -ne "\nUsername is too small. Please Try again"
		continue
	fi
	echo -ne "\nPassword didn't matched or either is too small. Please Try again\n"
done
echo ""
sudo mysql -e "DROP USER IF EXISTS $db_user@'%' ; CREATE USER $db_user@'%' IDENTIFIED BY '$db_pass'"
if [ $? -ne 0 ]
then
	echo -ne "\n\nFailed to create user\n\n"
fi
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO $db_user@'%'"
if [ $? -ne 0 ]
then
        echo -ne "\nFailed to grant privileges\n"
        exit 1
fi

ip_address=$(ip a | grep eth0 | grep inet | awk '{print $2}' | awk -F '/' '{print $1}')

echo -ne "\n\nLogin to phpMyAdmin\n"
echo -ne "\nURL : http://$ip_address/phpmyadmin\nUsername : $db_user\nPassword : $db_pass\n"
