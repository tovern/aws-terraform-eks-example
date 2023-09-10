#!/bin/bash
#####################################################################################
# new_cluster                                                                       #
# Adds standard configurations to a Flux managed Kubernetes cluster                 # 
#####################################################################################

PROGNAME="new_cluster"
VERSION=1.0

# Helper functions #############################################################

function print_revision {
   # Print the revision number
   echo "$PROGNAME - $VERSION"
}

function print_usage {
   # Print a short usage statement
   echo "Usage: $PROGNAME -n <CLUSTER_NAME> -r <CLUSTER_REGION>"
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
   Name of the cluster
-r
   Region of the cluster
__EOT
   echo -e "\nCheck your parameters"
}

# Main stuff ####################################################################
#Get some input
while getopts "hVn:r:" OPTION
do
     case $OPTION in
         h)
             print_help
             exit $STATE_WARNING
             ;;
         V)
             print_revision
             exit 1
             ;;
         n)
             CLUSTER_NAME=$OPTARG
             ;;
         r)
             CLUSTER_REGION=$OPTARG
             ;;         
     esac
done

# Check required inputs
if [[ -z $CLUSTER_NAME ]] || [[ -z $CLUSTER_REGION ]]
then
        print_help
        exit $STATE_WARNING
fi

# Create template
cp -r templates/ops clusters/${CLUSTER_NAME}/
find clusters/${CLUSTER_NAME} -type f -exec sed -i '' "s/CLUSTER_NAME/${CLUSTER_NAME}/g" {} +
find clusters/${CLUSTER_NAME} -type f -exec sed -i '' "s/CLUSTER_REGION/${CLUSTER_REGION}/g" {} +
mkdir clusters/${CLUSTER_NAME}/namespaces
mkdir clusters/${CLUSTER_NAME}/ingress
mkdir clusters/${CLUSTER_NAME}/apps

echo "Cluster structure for ${CLUSTER_NAME} created."