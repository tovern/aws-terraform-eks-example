#!/bin/bash
#####################################################################################
# new_app                                                                           #
# Creates the template for a new Kubernetes app managed by Flux                     #
#####################################################################################

PROGNAME="new_app"
VERSION=1.0
APP_TYPES=(
batch
web
)
# Helper functions #############################################################

function print_revision {
   # Print the revision number
   echo "$PROGNAME - $VERSION"
}

function print_usage {
   # Print a short usage statement
   echo "Usage: $PROGNAME -n <APP_NAME> -t <APP_TYPE> -e <ENVIRONMENTS>"
}

function print_help {
   # Print detailed help information
   print_revision
   print_usage

   /bin/cat <<__EOT

Options:
-h
   Print detailed help screen
-V
   Print version information
-n
   Name of the application
-t
   Type of application (batch/web)
-e
   Environments to create (comma separated list i.e prod,test,staging)
__EOT
   echo -e "\nCheck your parameters"
}

# Main stuff ####################################################################
#Get some input
while getopts "hVn:t:e:" OPTION
do
     case $OPTION in
         h)
             print_help
             exit $STATE_WARNING
             ;;
         V)
             print_revision
             exit $STATE_WARNING
             ;;
         n)
             APP_NAME=$OPTARG
             ;;
         t)
             APP_TYPE=$OPTARG
             ;;
         e)
             APP_ENVIRONMENTS=$OPTARG
             ;;             
     esac
done

# Check required inputs
if [[ -z $APP_NAME ]] || [[ -z $APP_TYPE ]]|| [[ -z $APP_ENVIRONMENTS ]]
then
        print_help
        exit $STATE_WARNING
fi

# Check app type is valid
if [[ ! " ${APP_TYPES[@]} " =~ " ${APP_TYPE} " ]]; then
    echo "APP TYPE ${APP_TYPE} is not valid. Aborting....."
    exit 1
fi

# Check if app exists
if [ -d "$APP_NAME" ]
then
    echo "App structure already exists. Aborting....."
    exit 0
fi

# Create template
mkdir -p ${APP_NAME}/base
cp -r templates/${APP_TYPE}/base/ ${APP_NAME}/base
find ${APP_NAME}/base -type f -exec sed -i '' "s/APP_NAME/${APP_NAME}/g" {} +

for ENV_NAME in ${APP_ENVIRONMENTS//,/ }
do
    mkdir ${APP_NAME}/${ENV_NAME}
    cp -r templates/${APP_TYPE}/patch/* ${APP_NAME}/${ENV_NAME}
    find ${APP_NAME}/${ENV_NAME} -type f -exec sed -i '' "s/APP_NAME/${APP_NAME}/g" {} +
    find ${APP_NAME}/${ENV_NAME} -type f -exec sed -i '' "s/ENV_NAME/${ENV_NAME}/g" {} +
done

find ${APP_NAME}/ -type f -name 'app.yaml' -execdir mv {} ${APP_NAME}.yaml ';'


echo "App structure for ${APP_NAME} created."