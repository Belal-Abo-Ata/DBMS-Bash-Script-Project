#!/bin/bash

# Make the directory 

echo "Make the DBMS directory at $HOME"


if mkdir $HOME/DBMS 2>> $HOME/.DBMS_error.log
then
	echo "The directory DBMS was made up successfully"
	echo "The Path is $HOME/DBMS"
else
	echo "There is an error while making the directory"
	echo "this could happen because of you don't have the permission or the directory is already existed"
fi

echo ""

PS3="Enter a Choice: "

function DBmenu {

	echo "Please choose an option from 1 to 5"
	select opt in "Create Database" "List Databases" "Connect To Databases" "Drop Database" "exit"
	do
		case $REPLY in
			1) createDB
				;;
			2) listDB
				;;
			3) connectDB
				;;

			4) dropDB
				;;
			5) exit 
				;;
			*) 
				echo "invalid option please try again"
				;;
		esac
	done
}



function createDB {

	read -p "Enter the database name: " DBname

	if mkdir $HOME/DBMS/$DBname 2>> $HOME/.DBMS_error.log
	then
		echo "The database was made up succefully at $HOME/DBMS/$DBname"
	else
		echo "There is an error while making the Database"
		echo "this could happen because of you don't have the permission or the Database is already existed"
	fi

	echo ""

	DBmenu
}

function listDB {

	echo ""

	if ls -lFh $HOME/DBMS 2>> $HOME/.DBMS_error.log
	then
		echo ""
	else 
		echo "There is an error while listing the databases"
		echo "this could happen because of you don't have the permission or the directory DBMS isn't existed"
	fi

	DBmenu

}

function connectDB {

	echo ""
	read -p "Enter the database name: " DBname
	if cd $HOME/DBMS/$DBname 2>> $HOME/.DBMS_error.log
	then
		echo "The connect was made up successfully"
		pwd
	else
		echo "There is an error while connecting the database"
		echo "this could happen because of you don't have the permission or the database isn't existed"
	fi

	DBmenu

}

function dropDB {

	echo ""
	read -p "Enter the database name: " DBname

	if ls -d $HOME/DBMS/$DBname 2>> $HOME/.DBMS_error.log

	then
		read -p "are you sure you want to remove $DBname database (y/n): " opt
		while true 
		do
			if [[ $opt = [Yy] ]]
			then
		 		rm -rf $HOME/DBMS/$DBname 2>> $HOME/.DBMS_error.log
				echo ""
				echo "The $DBname database was remove successfully"
				break
			elif [[ $opt = [Nn] ]]
			then
				break
			else
				echo "invalid option please try again"
			fi
		done
	else
		echo "The database isn't existed"
	fi

	DBmenu

}


DBmenu
