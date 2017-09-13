#!/bin/bash



#当前脚本目录
CURRENT_DIR=$(cd `dirname $0`; pwd)

APP_RESOURCE_DIR="$CURRENT_DIR"/

INPUT_COMMAND=

##支持的功能
COMMAND_ARRAY=(
"read_app_config"
"create_bundleid"
"create_app"
"create_dev_cert"
"create_prod_cert"
"create_dev_push"
"create_prod_push"
"create_profile"
"quit"
)

COMMAND_DESC_ARRAY=(
"Reset Apple Id & Bundle ID"
"Create Bundle ID"
"Create ITC App"
"Create Develop Cert for App"
"Create Production Cert for App"
"Create Develop Push Notification Cert"
"Create Production Push Notification Cert"
"Create Production Profile for App"
"Deliver metadata to ituns Connect"
"Build Project by gym of fastlane"
"Svn update and revert project"
"Quit"
)

function readCommand()
{
	clear
	echo "==================================================="
	echo -e "\033[7m Input Operate Command: \033[m"
	echo
	echo
	declare -i iIndex=0
	iArrayLength=${#COMMAND_ARRAY[@]}
	while [[ $iIndex -lt  ${iArrayLength} ]] 
	do
		echo ${iIndex}: ${COMMAND_DESC_ARRAY[${iIndex}]}
		iIndex=`expr $iIndex + 1`

	done

	echo -ne "\a"
	echo 
	echo -e "Enter your commant index:\c" ; read INPUT_INDEX
	
	INPUT_COMMAND=${COMMAND_ARRAY[${INPUT_INDEX}]}
	
}


function read_account_id()
{

	while  [[ "$APPLE_ACOUNT_ID" == "" ]]
	do
		echo  -e "Input Apple ID:\c" ; APPLE_ACOUNT_ID= ; read APPLE_ACOUNT_ID
		sed -i "" "/.*export APPLE_ACOUNT_ID.*/d" ~/.profile
		echo "export APPLE_ACOUNT_ID=$APPLE_ACOUNT_ID" >> ~/.profile
		export APPLE_ACOUNT_ID=$APPLE_ACOUNT_ID
	done

	APP_RESOURCE_DIR="$CURRENT_DIR"/$APPLE_ACOUNT_ID

	if ! [[ -d "$APP_RESOURCE_DIR" ]]; then
	    mkdir "$APP_RESOURCE_DIR"
	fi
	
}

function read_bundle_id()
{

	while  [[ "$APP_IDENTIFIER" == "" ]]
	do
		echo  -e "Input BundleID ID:\c" ; APP_IDENTIFIER= ; read APP_IDENTIFIER
		sed -i "" "/.*export APP_IDENTIFIER.*/d" ~/.profile
		echo "export APP_IDENTIFIER=$APP_IDENTIFIER" >> ~/.profile
		export APP_IDENTIFIER=$APP_IDENTIFIER
	done

	TARGET_APP_RESOURCE_DIR="$APP_RESOURCE_DIR"/$APP_IDENTIFIER
	if ! [[ -d "$TARGET_APP_RESOURCE_DIR" ]]; then
	    mkdir "$TARGET_APP_RESOURCE_DIR"
	fi
	
}

function fun_read_app_config()
{

	while  [[ "$APPLE_ID_IS_RIGHT" == "" ]]
	do

		if [[ "$APPLE_ACOUNT_ID" != "" ]]; then
			echo "Apple ID:  $APPLE_ACOUNT_ID"
			echo  -e "Apple ID is right? \c" ; APPLE_ID_IS_RIGHT=Y; read APPLE_ID_IS_RIGHT
			case $APPLE_ID_IS_RIGHT in 
			[Yy])
				break
				;;
			[Nn])
				APPLE_ACOUNT_ID=
				;;
			esac
			read_account_id
			APPLE_ID_IS_RIGHT=Y
		else
			read_account_id
			APPLE_ID_IS_RIGHT=Y
		fi

	done

	while  [[ "$BUNDLE_ID_IS_RIGHT" == "" ]]
	do

		if [[ "$APP_IDENTIFIER" != "" ]]; then
			echo "Bundle ID:  $APP_IDENTIFIER"
			echo  -e "Bundle ID is right? \c" ; BUNDLE_ID_IS_RIGHT=Y; read BUNDLE_ID_IS_RIGHT
			case $BUNDLE_ID_IS_RIGHT in 
			[Yy])
				break
				;;
			[Nn])
				APP_IDENTIFIER=
				;;
			esac
			read_bundle_id
			BUNDLE_ID_IS_RIGHT=Y
		else
			read_bundle_id
			BUNDLE_ID_IS_RIGHT=Y
		fi
	done
}
function fun_create_bundleid()
{
	clear
	echo "==================================================="
	echo -e "\033[7m Create BundleID: \033[m"
	echo
	
	fun_read_app_config

	echo "Create new App: ${APP_IDENTIFIER} for account ${APPLE_ACOUNT_ID}."
	echo -ne "\a"
	echo  -e "Y/n?\c" ; IS_CREATE=N ; read IS_CREATE
	case $IS_CREATE in 
	[Yy])
		
		echo "Creating BundleID: ${APP_IDENTIFIER} for account ${APPLE_ACOUNT_ID}... "
		echo  
		fastlane produce create -u ${APPLE_ACOUNT_ID}  -a ${APP_IDENTIFIER} -q ${APP_IDENTIFIER} -i -z 1.0 -y ${APP_IDENTIFIER}.appsku -m English

		;;
	[Nn])
		echo "Cancel Create New App in ITC."
		;;
	esac		

}

function fun_create_app()
{

	clear
	echo "==================================================="
	echo -e "\033[7m Create App in Apple Dev Center and iTunes Connect \033[m"
	echo

	fun_read_app_config

	echo "Create new App: ${APP_IDENTIFIER} for account ${APPLE_ACOUNT_ID} in iTunes Connect."
	echo -ne "\a"
	echo  -e "Y/n?\c" ; IS_CREATE=N ; read IS_CREATE
	case $IS_CREATE in 
	[Yy])
		
		echo "Creating new App: ${APP_IDENTIFIER} for account ${APPLE_ACOUNT_ID}... "
		echo  
		fastlane produce create -u ${APPLE_ACOUNT_ID}  -a ${APP_IDENTIFIER} -q ${APP_IDENTIFIER} -i -z 1.0 -y ${APP_IDENTIFIER}.appsku -m English 

		sleep 5 

		fastlane produce create -u ${APPLE_ACOUNT_ID}  -a ${APP_IDENTIFIER} -q ${APP_IDENTIFIER} -d -z 1.0 -y ${APP_IDENTIFIER}.appsku -m English

		;;

	[Nn])

		echo "Cancel Create New App in ITC."
		;;
	esac		

}

function fun_create_dev_cert()
{
	clear
	echo "==================================================="
	echo -e "\033[7m Create App Development Cert \033[m"
	echo

	fun_read_app_config

	echo -ne "\a"
	echo "Create new development cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
	echo  -e "Y/n?\c" ; IS_CREATE=N ; read IS_CREATE
	
	case $IS_CREATE in 
	[Yy])

		echo "Creating new development cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}..."
		CERT_DIR="$APP_RESOURCE_DIR"/cert
		CERT_OUTPUT_DIR="$APP_RESOURCE_DIR"/cert_temp

		if ! [[ -d "$CERT_DIR" ]]; then
		    mkdir "$CERT_DIR"		
		fi

		rm -rdf "$CERT_OUTPUT_DIR"
		mkdir "$CERT_OUTPUT_DIR"

		CERT_NAME_TMEP=${APP_IDENTIFIER#*.}
		CERT_NAME_TMEP1=${CERT_NAME_TMEP%.*}

		APP_CERT_DEV_NAKE=itune_${CERT_NAME_TMEP1}_dev

		cert create -u ${APPLE_ACOUNT_ID} -development \
		-o "$CERT_OUTPUT_DIR" --verbose

		mv -f "$CERT_OUTPUT_DIR"/*.cer "$CERT_DIR"/${APP_CERT_DEV_NAKE}.cer
		mv -f "$CERT_OUTPUT_DIR"/*.certSigningRequest "$CERT_DIR"/${APP_CERT_DEV_NAKE}.certSigningRequest
		mv -f "$CERT_OUTPUT_DIR"/*.p12 "$CERT_DIR"/${APP_CERT_DEV_NAKE}.p12

		if [[ -f "$CERT_DIR"/${APP_CERT_DEV_NAKE}.cer ]]; then
			echo Done !!!
		else
			echo -e "\033[41;37m Error: \033[0m  Failed to create cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
		fi

		rm -rdf "$CERT_OUTPUT_DIR"
		;;

	[Nn])
		echo "Cancel create cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
		;;
	esac

}

function fun_create_prod_cert()
{
	clear
	echo "==================================================="
	echo -e "\033[7m Create App Push Notification Cert \033[m"
	echo	

	fun_read_app_config

	echo -ne "\a"
	echo "Create new cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
	echo  -e "Y/n?\c" ; IS_CREATE=N ; read IS_CREATE
	
	case $IS_CREATE in 
	[Yy])

		echo "Creating new cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}..."


		CERT_DIR="$APP_RESOURCE_DIR"/cert
		CERT_OUTPUT_DIR="$APP_RESOURCE_DIR"/cert_temp

		if ! [[ -d "$CERT_DIR" ]]; then
		    mkdir "$CERT_DIR"		
		fi

		rm -rdf "$CERT_OUTPUT_DIR"
		mkdir "$CERT_OUTPUT_DIR"

		CERT_NAME_TMEP=${APP_IDENTIFIER#*.}
		CERT_NAME_TMEP1=${CERT_NAME_TMEP%.*}

		APP_CERT_PROD_NAKE=itune_${CERT_NAME_TMEP1}_prod

		cert create -u ${APPLE_ACOUNT_ID} \
		-o "$CERT_OUTPUT_DIR" --verbose

		mv -f "$CERT_OUTPUT_DIR"/*.cer "$CERT_DIR"/${APP_CERT_PROD_NAKE}.cer
		mv -f "$CERT_OUTPUT_DIR"/*.certSigningRequest "$CERT_DIR"/${APP_CERT_PROD_NAKE}.certSigningRequest
		mv -f "$CERT_OUTPUT_DIR"/*.p12 "$CERT_DIR"/${APP_CERT_PROD_NAKE}.p12

		if [[ -f "$CERT_DIR"/${APP_CERT_PROD_NAKE}.cer ]]; then
			echo Done !!!
		else
			echo -e "\033[41;37m Error: \033[0m  Failed to create cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
		fi

		rm -rdf "$CERT_OUTPUT_DIR"
		;;
	[Nn])
		echo "Cancel create cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
		;;
	esac

}

function fun_create_dev_push()
{
	fun_read_app_config

	echo -ne  "\a"
	echo "Create new development push notification cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
	echo  -e "Y/n?\c" ; IS_CREATE=N ; read IS_CREATE
	
	case $IS_CREATE in 
	[Yy])
		echo "Creating new push notification cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}..."

		if ! [[ -d "$TARGET_APP_RESOURCE_DIR" ]]; then
		    mkdir "$TARGET_APP_RESOURCE_DIR"
		fi

		APP_PUSH_CERT_DIR="$TARGET_APP_RESOURCE_DIR"/cert_push
		if ! [[ -d $APP_PUSH_CERT_DIR ]]; then
		    mkdir $APP_PUSH_CERT_DIR
		fi

		PUSH_NAME_TMEP=${APP_IDENTIFIER#*.}
		PUSH_NAME_TMEP1=${PUSH_NAME_TMEP%.*}
		PUSH_NAME_TMEP2=${PUSH_NAME_TMEP##*.}

		APP_PUSH_DEV_NAME=${PUSH_NAME_TMEP1}_${PUSH_NAME_TMEP2}_push_dev

		fastlane pem renew -u ${APPLE_ACOUNT_ID} -a ${APP_IDENTIFIER} --p12_password pinssible#1 --generate_p12 --development\
		-o $APP_PUSH_DEV_NAME -e $APP_PUSH_CERT_DIR --verbose

		if [[ -f $APP_PUSH_CERT_DIR/${APP_PUSH_DEV_NAME}.p12 ]]; then
		    echo $APP_PUSH_CERT_DIR
		    echo $APP_PUSH_PROD_NAME
		else
			echo -e "\033[41;37m Error: \033[0m  Failed to create push notification cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
		fi
		
		;;

	[Nn])
		echo "Cancel create push notification cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
		;;
	esac	
}

function fun_create_prod_push()
{
	fun_read_app_config

	echo -ne  "\a"
	echo "Create new production push notification cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
	echo  -e "Y/n?\c" ; IS_CREATE=N ; read IS_CREATE
	
	case $IS_CREATE in 
	[Yy])
		echo "Creating new production push notification cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}..."

		if ! [[ -d "$TARGET_APP_RESOURCE_DIR" ]]; then
		    mkdir "$TARGET_APP_RESOURCE_DIR"
		fi

		APP_PUSH_CERT_DIR="$TARGET_APP_RESOURCE_DIR"/cert_push
		if ! [[ -d $APP_PUSH_CERT_DIR ]]; then
		    mkdir $APP_PUSH_CERT_DIR
		fi

		PUSH_NAME_TMEP=${APP_IDENTIFIER#*.}
		PUSH_NAME_TMEP1=${PUSH_NAME_TMEP%.*}
		PUSH_NAME_TMEP2=${PUSH_NAME_TMEP##*.}
		APP_PUSH_PROD_NAME=${PUSH_NAME_TMEP1}_${PUSH_NAME_TMEP2}_push_prod
		
		fastlane pem renew -u ${APPLE_ACOUNT_ID} -a ${APP_IDENTIFIER} --p12_password pinssible#1 --generate_p12 \
		-o $APP_PUSH_PROD_NAME -e $APP_PUSH_CERT_DIR --verbose

		if [[ -f $APP_PUSH_CERT_DIR/${APP_PUSH_PROD_NAME}.p12 ]]; then
		    echo $APP_PUSH_CERT_DIR
		    echo $APP_PUSH_PROD_NAME
		else
			echo -e "\033[41;37m Error: \033[0m  Failed to create push notification cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
		fi
		;;
	[Nn])
		echo "Cancel create push notification cert for App ${APP_IDENTIFIER} in ${APPLE_ACOUNT_ID}."
		;;
	esac	
}

function fun_create_profile()
{
	echo "coming soon !"
}

function run()
{

	while  true

	do
		INPUT_COMMAND="error"
	   	readCommand
		case $INPUT_COMMAND in 
			
		"read_app_config")
			APPLE_ID_IS_RIGHT=
			APP_IDENTIFIER=
			BUNDLE_ID_IS_RIGHT=
			APPLE_ACOUNT_ID=
			fun_read_app_config
			;;
		"create_bundleid")
			fun_create_bundleid
			;;
		"create_app")
			fun_create_app
			;;
		"create_dev_cert")
			fun_create_dev_cert
			;;
		"create_prod_cert")		
			fun_create_prod_cert
			;;
		"create_dev_push")		
			fun_create_dev_push
			;;
		"create_prod_push")		
			fun_create_prod_push
			;;
		"create_profile")
			fun_create_profile
			;;
		"quit")
			echo "Quit !!"
			break
			;;
		[Qq])
			echo "Quit !!"
			break
		esac

		echo
		echo -ne "\a"
		read -rsp $'Press enter to continue...\n'
	done 
}

run



