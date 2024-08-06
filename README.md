---
page_type: sample
languages:
- aspx-csharp
- tsql
- sql
- json
products:
- azure
- dotnet
- aspnet
- aspnet-core
- azure-app-service
- vs-code
- azure-sql-database
description: "Using Change Tracking API to sync data between Apps and the Cloud"
urlFragment: "azure-sql-db-dotnet-rest-api"
---

# Using Change Tracking API to sync data between Apps and the Cloud

![License](https://img.shields.io/badge/license-MIT-green.svg)

<!-- 
Guidelines on README format: https://review.docs.microsoft.com/help/onboard/admin/samples/concepts/readme-template?branch=master

Guidance on onboarding samples to docs.microsoft.com/samples: https://review.docs.microsoft.com/help/onboard/admin/samples/process/onboarding?branch=master

Taxonomies for products and languages: https://review.docs.microsoft.com/new-hope/information-architecture/metadata/taxonomies?branch=master
-->

If you are developing an application that must be able to work disconnected from the cloud, you'll surely need, at some point, to implement the ability to download the latest data from the cloud to refresh the data local to the app. Doing this efficiently could be tricky, as you would need to understand what are the changes that happened on the cloud since the last time the application synched with it, so that you can only send the differences.

With Azure SQL you can take advantage of [Change Tracking](https://docs.microsoft.com/en-us/sql/relational-databases/track-changes/about-change-tracking-sql-server) to detect which rows have been changed from the last time the application synced and generate a payload that only contains those changes. Something like that:

```json
{
  "Metadata": {
    "Sync": {
      "Version": 6,
      "Type": "Diff"
    }
  },
  "Data": [
    {
      "$operation": "U",
      "Id": 10,
      "RecordedOn": "2019-10-27T17:54:48-08:00",
      "Type": "Run",
      "Steps": 3450,
      "Distance": 4981
    },
    {
      "$operation": "I",
      "Id": 11,
      "RecordedOn": "2019-10-26T18:24:32-08:00",
      "Type": "Run",
      "Steps": 4866,
      "Distance": 4562
    }
  ]
}
```

Well, more precisely, not only you can detect the changes, but you can also generate the JSON directly from Azure SQL, so that you can take advantage of the amazing integration that Azure SQL provides across all its features and create a beautifully simple code.

More technical details are available here: [Sync Mobile Apps with Azure using Change Tracking API ](https://techcommunity.microsoft.com/t5/azure-sql-database/sync-mobile-apps-with-azure-using-change-tracking-api/ba-p/1213993)

I've also prepared a video to show in 10 minutes how much simpler can be your life using Change Tracking API.

![Azure SQL Change Tracking API in Action](https://img.youtube.com/vi/c1BmNruu6wc/0.jpg)](https://www.youtube.com/watch?v=c1BmNruu6wc)

## Create an empty database

Make sure you have an Azure SQL DB database to use. If you don't have an Azure account you, you can create one for free that will also include a free Azure SQL DB tier:

https://azure.microsoft.com/en-us/free/free-account-faq/

To create a new database, follow the instructions here:

[Create Azure SQL Database](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-single-database-get-started?tabs=azure-portal)

or, if you're already comfortable with [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli), you can just execute (using Bash, via [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10), a Linux environment or [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview))

```bash
az group create -n <my-resource-group> -l WestUS2
az sql server create -g <my-resource-group> -n <my-server-name> -u <my-user> -p <my-password>
az sql db create -g <my-resource-group> --server <my-server-name> -n CTSample --service-objective HS_Gen5_2
```

Once the database is created, you can connect to it using [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio). If you need help in setting up your first connection to Azure SQL with Azure Data Studio, this quick video will help you:

[How to connect to Azure SQL Database from Azure Data Studio](https://www.youtube.com/watch?v=Td_pYlRraQE)

## Add Database Objects

Once the database has been created, you need to enable change tracking and add a stored procedure that will called from .NET. The SQL code is available here:

- `./SQL/01-change-tracking-setup.sql`
- `./SQL/02-stored-procedure.sql`

Please execute the script on the created database in sequence.

If you need any help in executing the SQL script, you can find a Quickstart here: [Quickstart: Use Azure Data Studio to connect and query Azure SQL database](https://docs.microsoft.com/en-us/sql/azure-data-studio/quickstart-sql-database)

## Run sample locally

Make sure you have [.NET Core 3.0](https://dotnet.microsoft.com/download) SDK installed on your machine. Clone this repo in a directory on our computer and then configure the connection string in `appsettings.json`.

If you don't want to save the connection string in the `appsettings.json` file for security reasons, you can just set it using an environment variable:

Linux:

```bash
export ConnectionStrings__DefaultConnection="<your-connection-string>"
```

Windows:

```powershell
$Env:ConnectionStrings__DefaultConnection="<your-connection-string>"
```

Your connection string is something like:

```text
SERVER=<your-server-name>.database.windows.net;DATABASE=<your-database-name>;UID=DotNetWebApp;PWD=a987REALLY#$%TRONGpa44w0rd!
```

Just replace `<your-server-name>` and `<your-database-name>` with the correct values for your environment.

To run and test the REST API locally, just run

```bash
dotnet run
```

.NET will start the HTTP server and when everything is up and running you'll see something like

```text
Now listening on: https://localhost:5001
```

Using a REST Client (such as [Visual Studio](https://learn.microsoft.com/aspnet/core/test/http-files), [Insomnia](https://insomnia.rest/), [Curl](https://curl.se/docs/httpscripting.html) or PowerShell's [Invoke-RestMethod](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod))), you can now call your API, for example:

```bash
curl -s -k -H "fromVersion: 0" --url https://localhost:5001/trainingsession/sync
```

and you'll get something like the following:

```json
{
  "Metadata": {
    "Sync": {
      "Version": 6,
      "Type": "Full",
      "ReasonCode": 0
    }
  },
  "Data": [
    {
      "Id": 9,
      "RecordedOn": "2019-10-28T17:27:23-08:00",
      "Type": "Run",
      "Steps": 3784,
      "Distance": 5123
    },
    {
      "Id": 10,
      "RecordedOn": "2019-10-27T17:54:48-08:00",
      "Type": "Run",
      "Steps": 0,
      "Distance": 4981
    }
  ]
}
```

## Debug from Visual Studio Code

Debugging from Visual Studio Code is fully supported. If you have an `.env`, it will be used to get the connection string: this means, that at minimum the `.env` file needs to be like the following:

```
ConnectionStrings__DefaultConnection="<the-connection-string>"
```

The `.env` file is also used to read values needed to deploy the solution to Azure, as described in the next section.

## Deploy to Azure

Now that your REST API solution is ready, it's time to deploy it on Azure so that anyone can take advantage of it. A detailed article on how you can that that is here:

- [Create an ASP.NET Core app in App Service on Linux](https://docs.microsoft.com/en-us/azure/app-service/containers/quickstart-dotnetcore)

The only thing you have do in addition to what explained in the above articles is to add the connection string to the Azure Web App configuration. Using AZ CLI, for example:

```bash
AppName="azure-sql-db-dotnet-rest-api"
ResourceGroup="my-resource-group"

az webapp config connection-string set \
    -g $ResourceGroup \
    -n $AppName \
    --settings DefaultConnection=$ConnectionStrings__DefaultConnection \
    --connection-string-type=SQLAzure
```

Just make sure you correctly set `$AppName` and `$ResourceGroup` to match your environment and also that the variable `$ConnectionStrings__DefaultConnection` as also been set, as mentioned in section "Run sample locally". 

An example of a full script that deploy the REST API is available here: `azure-deploy.sh`. The script need and `.env` file to run. If there is none it will create an empty one for you. Make sure you to fill it with the correct values for your environment, and you'll be good to go. 

The `.env` file looks like the following:

```
ResourceGroup="<resource-group-name>"
AppName="<app-name>"
Location="WestUS2" 
ConnectionStrings__DefaultConnection="<the-connection-string>"
```

## Learn more

If you're new to .NET and want to learn more, there are a lot of tutorial available on the [Microsoft Learn](https://docs.microsoft.com/en-us/learn/browse/?products=dotnet) platform. You can start from here, for example:

- https://docs.microsoft.com/en-us/learn/modules/build-web-api-net-core/?view=aspnetcore-3.1

If you also want to learn more about Visual Studio Code, here's another resource:

[Using .NET Core in Visual Studio Code](https://code.visualstudio.com/docs/languages/dotnet)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
