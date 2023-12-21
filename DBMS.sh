#!/bin/bash

# Make the directory 

echo "Make the DBMS directory at $PWD"
echo -e "\n"


if mkdir ./DBMS 2> ./.DBMS_error.log
then
	echo "The directory DBMS was made up successfully"
	echo -e "The Path is $PWD/DBMS \n"
else
	echo "There is an error while making the directory"
	echo -e "this could happen because of you don't have the permission or the directory is already existed \n"
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

	if mkdir ./DBMS/$DBname 2>> ./.DBMS_error.log
	then
		echo "The database was made up succefully at $PWD/DBMS/$DBname"
	else
		echo "There is an error while making the Database"
		echo -e "this could happen because of you don't have the permission or the Database is already existed \n"
	fi

	echo ""

	DBmenu
}

function listDB {


	if ls -lFh ./DBMS 2>> ./.DBMS_error.log
	then
		echo -e "\n\n"
	else 
		echo "There is an error while listing the databases"
		echo -e "this could happen because of you don't have the permission or the directory DBMS isn't existed \n"
	fi

	DBmenu

}

function connectDB {

	echo ""
	read -p "Enter the database name: " DBname
	if cd ./DBMS/$DBname 2>> ./.DBMS_error.log
	then
		echo "The connect was made up successfully"
		pwd
		TBmenu
	else
		echo "There is an error while connecting the database"
		echo -e "this could happen because of you don't have the permission or the database isn't existed \n"
	fi

}

function dropDB {

	echo ""
	read -p "Enter the database name: " DBname

	if ls -d ./DBMS/$DBname 2>> ./.DBMS_error.log

	then
		read -p "are you sure you want to remove $DBname database (y/n): " opt
		while true 
		do
			if [[ $opt = [Yy] ]]
			then
		 		rm -rf ./DBMS/$DBname 2>> ./.DBMS_error.log
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


function TBmenu {

	echo ""
	echo "Please choose an option from 1 to 9"
	select opt in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Back to Database menu" "exit"
	do
		case $REPLY in
			1) createTB
				;;
			2) listTB
				;;
			3) dropTB
				;;

			4) insertTB
				;;
			5) selectTB
				;;
			6) deleteTB
				;;
			7) updateTB
				;;
			8) DBmenu
				;;
			9) exit 
				;;

			*) 
				echo "invalid option please try again"
				;;
		esac
	done

}


function createTB {

	echo -e "\n\n"

	read -p "Enter the table name: " TBname

	if [[ -f ./$TBname ]] 
	then
		echo "The table is already existed\n\n"
		TBmenu
	fi	

	read -p "Enter the number of columns: " TBcolnum
	echo -e "\n"

	counter=1
	sep="|"
	lsep="\n"
	pkey=""
	data_type="int"
	colnames=""
	metadata=""

	while [ $counter -le $TBcolnum ]
	do
		read -p "Enter the name of column $counter: " TBcolname

		echo -e "\n choose the data type for $TBcolname"
		echo -e "\n choose an option from 1 and 2"

		select choice in "int" "string"
		do
			case $REPLY in 
				1) data_type="int"
					break
					;;
				2) data_type="string"
					break
					;;
				*) echo -e "\n invalid option, please try again."
					;;
			esac
		done


		echo -e "\n Do you want to make $TBcolname a primary key"
		echo -e "\n choose an option from 1 and 2"

		select choice in "yes" "no"
		do
			case $REPLY in 
				1) pkey="PK"
					break
					;;
				2) pkey=""
					break
					;;
				*) echo -e "\n invalid option, please try again."
					;;
			esac
		done

		if [[ $metadata == "" ]] 
		then
			metadata=$TBcolname$sep$data_type$sep$pkey
		else
			metadata=$metadata$lsep$TBcolname$sep$data_type$sep$pkey
		fi

		if [[ $colnames == "" ]]
		then
			colnames=$TBcolname
		else
			colnames=$colnames$sep$TBcolname
		fi

		let counter=$counter+1

	done

	echo -e $metadata > ./.$TBname
	echo -e $colnames > ./$TBname

	echo -e "\n\n The Table was be created successfully."
	TBmenu

}

function insertTB { 
	
	echo -e "\n\n"

	read -p "Enter the table name: " TBname

	if ! [[ -f ./$TBname ]] 
	then
		echo -e "The table isn't existed\n\n"
		TBmenu
	fi	

	sep="|"
	data=""

	colnums=`cat ./.$TBname | wc -l`

	for (( i=1; i<=$colnums; i++ ))
	do
		colname=`awk 'BEGIN{FS="'$sep'"}{if (NR=='$i') print $1}' .$TBname`
		data_type=`awk 'BEGIN{FS="'$sep'"} {if (NR=='$i') print $2}' .$TBname`
		pkey=`awk 'BEGIN{FS="'$sep'"} {if (NR=='$i') print $3}' .$TBname`

		read -p "$i. $colname ($data_type): " value


		# validate the integer data type

		while [[ $data_type == "int" &&  ! $value =~ ^[0-9]+$ ]]
		do
			echo -e "\n invalid data"
			echo "this field is an integer"
			echo "enter new value"
			read -p "$i. $colname ($data_type): " value
		done

		# Primary key validation

		if [[ $pkey == "PK" ]]
		then
			# validate the primary key isn't empty

			while [[ $value == "" ]]
			do
				echo -e "\n invalid data"
				echo "this field is a primary key and can't be empty"
				echo "enter new value"
				read -p "$i. $colname ($data_type): " value
			done

			# validate the primary key isn't repeated

			flag=`awk 'BEGIN{FS="'$sep'"} {print $'$i'}' ./$TBname | grep -Fx $value`

			while [[ $flag != "" ]]
			do
				echo -e "\n this data is already existed"
				echo "this field is a primary key and can't be repeated"
				echo "enter new value"
				read -p "$i. $colname ($data_type): " value
				flag=`awk 'BEGIN{FS="'$sep'"} {print '$i'}' $TBname | grep -Fx $value`
			done

		fi

		
		if [[ $data == "" ]]
		then
			data=$value
		else
			data=$data$sep$value
		fi
		
	done

	echo -e $data >> $TBname

	echo "The data inserted successfully."

	TBmenu

}

function listTB {

	if ls -lFh . 2>> ../.DBMS_error.log
	then
		echo -e "\n\n"
	else 
		echo "There is an error while listing the tables"
		echo -e "this could happen because of you don't have the permission or \n"
	fi

}

DBmenu

function deleteFromTable {
	echo -e "Enter Table Name: \c"
	read Tname
	echo -e "Enter coulmn Name: \c"
	read colm
	fld=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<NF;i++){if($i=="'$colm'") print i}}}' $Tname)
	if [[$fld == ""]]
	then
		echo "Not FOUND"
		tableMenu
	else
	echo -e "Enter Data to delete: \c"
	read value
	val=$(awk 'BEGIN{FS="|"}{if($'$colm'=="'$value'") print $'$fld'}' $Tname 2>>./.error.log)
	if [[ $val == "" ]]
	then
		echo "The Data Not Found"
		tableMenu
	else
		del=$(awk 'BEGIN{FS="|"}{if($'$colm'=="'$value'") print del}' $Tname 2>>./.error.log)
		sed -i ''$del'd' $Tname 2>>./.error.log
		echo "Data Deleted Successfully"
		TableMenu
	fi
    fi
}  

function dropTable{
	echo -e "Enter Table Name: \c"
	read Tname
	rm $Tname .$Tname 2>>./.error.log

	tableMenu
}
function selectTabel{
	echo -e "Enter The Table You To Select From: \C"
	read Tname

	if [[ -f ${Tname}]];then
		cat ${Tname}
	else
		echo "error displaying table ${Tname}"
	fi
tableMenu
}

