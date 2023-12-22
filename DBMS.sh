#!/bin/bash

PS3="Enter a Choice: "

### Better echo message ###
function echo_adv {
	echo -e "\n"
	echo "-----------------------------------------------------------------------------------------------------------------"
	echo -e "\n$1\n"
	echo "-----------------------------------------------------------------------------------------------------------------"
	echo -e "\n"
}

### Log all errors in ./.DBMS_error.log file ###

function error_log {
	data="\n"
	data+="-----------------------------------------------------------------------------------------------------------------\n"
	data+=`date`
	data+="\nUser=$USER\n"
	data+="Error:\n"
	data+=`cat $1`
	data+="\n-----------------------------------------------------------------------------------------------------------------"
	data+="\n"
	echo -e $data >> ./.DBMS_error.log
}

echo -e "\nThis program was made by Belal Abo Ata and Yousef Alsayed\n"

echo_adv "Welcome To Simple DBMS"


# Make the directory 

echo "Making the DBMS directory at $PWD"


if mkdir ./DBMS 2> ./.error.log
then

	echo "The directory DBMS was made up successfully"
	echo -e "The Path is $PWD/DBMS \n"
else
	cat ./.error.log
	error_log ./.error.log
fi



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

	if mkdir ./DBMS/$DBname 2> ./.error.log
	then
		echo_adv "The database was made up succefully at $PWD/DBMS/$DBname"
	else
		cat ./.error.log
		error_log ./.error.log	
	fi

	DBmenu
}

function listDB {


	if ls ./DBMS 2> ./.error.log
	then
		echo -e "\n"
	else 
			cat ./.error.log
			error_log ./.error.log
	fi

	DBmenu

}

function connectDB {

	read -p "Enter the database name: " DBname
	if cd ./DBMS/$DBname 2> ./.error.log
	then
		echo_adv "The connect was made up successfully"
		pwd
		TBmenu
	else
		cat ./.error.log
		error_log ./.error.log	
		DBmenu
	fi

}

function dropDB {

	echo -e "\n"
	read -p "Enter the database name: " DBname

	if ls -d ./DBMS/$DBname 2> ./.error.log
	then
		echo -e "\n"
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
		cat ./.error.log
		error_log ./.error.log	
	fi

	DBmenu

}


function TBmenu {

	echo -e "\n"
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

	echo -e "\n"

	read -p "Enter the table name: " TBname

	if [[ -f ./$TBname ]] 
	then
		echo_adv "The table is already existed"
		TBmenu
	fi	

	echo -e "\n"
	read -p "Enter the number of columns: " TBcolnum

	counter=1
	sep="|"
	lsep="\n"
	pkey=""
	data_type="int"
	colnames=""
	metadata=""

	while [ $counter -le $TBcolnum ]
	do
		echo -e "\n"
		read -p "Enter the name of column $counter: " TBcolname
		echo "choose the data type for $TBcolname"
		echo "choose an option from 1 and 2"

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
		echo -e "choose an option from 1 and 2"

		select choice in "yes" "no"
		do
			case $REPLY in 
				1) pkey="PK"
					break
					;;
				2) pkey=""
					break
					;;
				*) echo -e "invalid option, please try again."
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

	echo_adv "The Table was be created successfully."
	TBmenu

}

function insertTB { 
	
	echo -e "\n"

	read -p "Enter the table name: " TBname

	if ! [[ -f ./$TBname ]] 
	then
		echo_adv "The table isn't existed"
		TBmenu
	fi	

	sep="|"
	data=""
	valid=0

	colnums=`cat ./.$TBname | wc -l`

	for (( i=1; i<=$colnums; i++ ))
	do
		colname=`awk 'BEGIN{FS="'$sep'"}{if (NR=='$i') print $1}' .$TBname`
		data_type=`awk 'BEGIN{FS="'$sep'"} {if (NR=='$i') print $2}' .$TBname`
		pkey=`awk 'BEGIN{FS="'$sep'"} {if (NR=='$i') print $3}' .$TBname`

		read -p "$i. $colname ($data_type): " value

		while [[ $valid == 0 ]]
		do
			if [[ $pkey == "PK" ]]
			then

				# validate the primary key isn't empty
				if [[ $value == "" ]]
				then
					echo -e "\n invalid data"
					echo "this field is a primary key and can't be empty"
					echo "enter new value"
					read -p "$i. $colname ($data_type): " value
					valid=0
					continue
				else
					valid=1
				fi

				# validate the primary key isn't repeated
				flag=`awk 'BEGIN{FS="'$sep'"} {print $'$i'}' ./$TBname | grep -Fx $value`

				if [[ $flag != "" ]]
				then
					echo -e "\n this data is already existed"
					echo "this field is a primary key and can't be repeated"
					echo "enter new value"
					read -p "$i. $colname ($data_type): " value
					flag=`awk 'BEGIN{FS="'$sep'"} {print '$i'}' $TBname | grep -Fx $value`
					valid=0
					continue
				else
					valid=1
				fi

			fi


			# validate the integer data type

			if [[ $value != "" ]]
			then
				if [[ $data_type == "int" &&  ! $value =~ ^[0-9]+$ ]]
				then
					echo -e "\n invalid data"
					echo "this field is an integer"
					echo "enter new value"
					read -p "$i. $colname ($data_type): " value
					valid=0
					continue
				else
					valid=1
				fi
			else
				valid=1
			fi
		done


	

		
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

	if ls . 2> ../.error.log
	then
		echo -e "\n"
	else 
		cat ./.error.log
		error_log ./.error.log

	fi

	TBmenu
}

function updateTB {

  sep="|"
  echo -e "Enter Table Name: \c"
  read Tname
  if [[ -f $Tname ]]
  then
	  echo -e "Enter Column name: \c"
	  read colm
	  fld=$(awk 'BEGIN{FS="'$sep'"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$colm'") print i}}}' $Tname)

	  if [[ $fld == "" ]]
	  then
		  echo "Not Found"
	  else
		  colname=`awk 'BEGIN{FS="'$sep'"}{if (NR=='$fld') print $1}' .$Tname`
		  data_type=`awk 'BEGIN{FS="'$sep'"} {if (NR=='$fld') print $2}' .$Tname`
		  pkey=`awk 'BEGIN{FS="'$sep'"} {if (NR=='$fld') print $3}' .$Tname`
		  sep="|"


		  echo -e "Enter Value in $colname ($data_type:$pkey): \c"
		  read val
		  res=$(awk 'BEGIN{FS="|"}{if ($'$fld'=="'$val'") print $'$fld'}' $Tname)
		  if [[ $res == "" ]]
		  then
			  echo "Value Not Found"
		  else
				  echo -e "Enter new Value to set in $colname ($data_type:$pkey): \c"
				  read newvalue
				  valid=0

				  while [[ $valid == 0 ]]
				  do
					  if [[ $pkey == "PK" ]]
					  then

						  # validate the primary key isn't empty
						  if [[ $newvalue == "" ]]
						  then
							  echo -e "\n invalid data"
							  echo "this field is a primary key and can't be empty"
							  echo "enter new newvalue"
							  read -p "$colname ($data_type): " newvalue
							  valid=0
							  continue
						  else
							  valid=1
						  fi

						  # validate the primary key isn't repeated
						  flag=`awk 'BEGIN{FS="'$sep'"} {print $'$fld'}' ./$Tname | grep -Fx $newvalue`

						  if [[ $flag != "" ]]
						  then
							  echo -e "\n this data is already existed"
							  echo "this field is a primary key and can't be repeated"
							  echo "enter new newvalue"
							  read -p "$colname ($data_type): " newvalue
							  flag=`awk 'BEGIN{FS="'$sep'"} {print '$i'}' $Tname | grep -Fx $newvalue`
							  valid=0
							  continue
						  else
							  valid=1
						  fi

					  fi


					  # validate the integer data type

					  if [[ $newvalue != "" ]]
					  then
						  if [[ $data_type == "int" &&  ! $newvalue =~ ^[0-9]+$ ]]
						  then
							  echo -e "\n invalid data"
							  echo "this field is an integer"
							  echo "enter new newvalue"
							  read -p "$colname ($data_type): " newvalue
					valid=0
					continue
				else
					valid=1
				fi
			else
				valid=1
			fi
		done


				  
				  NR=$(awk 'BEGIN{FS="|"}{if ($'$fld' == "'$val'") print NR}' $Tname)
				  oldvalue=$(awk 'BEGIN{FS="|"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$fld') print $i}}}' $Tname)
				  sed -i ''$NR's/'$oldvalue'/'$newvalue'/g' $Tname
				  echo_adv "Row Updated Successfully"
			  fi
		  fi
	  else
		  echo_adv "Table isn't exist"
	  fi

	  TBmenu
  }

function deleteTB { 
	echo -e "Enter Table Name: \c"
	read Tname
	if [[ -f $Tname ]]
	then
		echo -e "Enter coulmn Name: \c"
		read colm
		fld=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<NF;i++){if($i=="'$colm'") print i}}}' $Tname)
		if [[ $fld == "" ]]
		then
			echo "Not FOUND"
			TBmenu
		else
			echo -e "Enter Data to delete: \c"
			read value
			val=$(awk -v col=$fld -v val="$value" 'BEGIN{FS="|"}{if($col==val) print $col }' $Tname)
			if [[ $val == "" ]]
			then
				echo "The Data Not Found"
			else
				awk -v col=$fld -v val="$value" 'BEGIN{FS="|"}{if($col!= val) print $0}' $Tname > temp_file       
				mv temp_file $Tname                    
				echo_adv "Data Deleted Successfully"
			fi
		fi

	else
		echo_adv "The Table isn't exist"
	fi

    TBmenu
}  

function dropTB {
	echo -e "Enter Table Name: \c"
	read Tname
	if rm $Tname .$Tname 2> ../.error.log
	then
		echo_adv "The Table was dropped successfully"
	else
		cat ../.error.log
		error_log ../.error.log
	fi

	TBmenu
}

function selectTB {

	echo -e "Enter the table name: \c"
	read Tname
	if [ -e "$Tname" ];then 
		rowsnum=`cat ./$Tname | wc -l`
		let rowsnum=$rowsnum-1
		echo "Number of Rows in This Table is $rowsnum"
		if [[ $rowsnum > 0 ]]
		then
			echo -e "if you don't write any number the whole table will be shown"
			echo -e "Enter raw you want select from 1 to $rowsnum: \c"
			read row
			if [[ $row != "" ]]
			then
				let row=$row+1
				awk 'BEGIN { FS = "|" } { if (NR=='$row') print $0 }' $Tname
			else 
				echo_adv "`cat $Tname`"
			fi
		else 
			echo_adv "There isn't data in this table"
		fi
   	else
	   echo_adv "Table $Tname not found"
   	fi	

	TBmenu
}
DBmenu
