#!/bin/bash
set -euo pipefail

# Load values from .env variable
FILE=".env"
if [[ -f $FILE ]]; then
    export $(egrep . $FILE | xargs -n1)
else
	cat << EOF > .env
ResourceGroup=""
AppName=""
Location=""
ConnectionStrings__DefaultConnection=""
EOF
	echo "Enviroment file not detected.";
	echo "Please configure values for your environment in the created .env file";
	echo "and run the script again.";
	exit 1;
fi

# Change this if you are using your own github repository
gitSource="https://github.com/Azure-Samples/azure-sql-db-sync-api-change-tracking.git"

# Make sure connection string variable is set
if [[ -z "${ConnectionStrings__DefaultConnection:-}" ]]; then
	echo "Please make sure Azure SQL connection string is set in .env file";
    exit 1;
fi

echo "Creating Resource Group...";
az group create \
    -n $ResourceGroup \
    -l $Location

echo "Creating Application Service Plan...";
az appservice plan create \
    -g $ResourceGroup \
    -n "linux-plan" \
    --sku B1 \
    --is-linux

echo "Creating Web Application...";
az webapp create \
    -g $ResourceGroup \
    -n $AppName \
    --plan "linux-plan" \
    --runtime "DOTNETCORE|3.0" \
    --deployment-source-url $gitSource \
    --deployment-source-branch master

echo "Configuring Connection String...";
az webapp config connection-string set \
    -g $ResourceGroup \
    -n $AppName \
    --settings DefaultConnection=$ConnectionStrings__DefaultConnection \
    --connection-string-type=SQLAzure

echo "Done."