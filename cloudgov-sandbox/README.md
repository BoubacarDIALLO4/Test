# Introduction 
This repository contains code to prepare sandbox resource group

# Manual deployment
1. Login with Az CLI
    ```bash
    $ az login
    ```

1. If necessary, switch to correct Azure subscription
    ```bash
    $ az account set --subscription 'Faurecia_DSF_Dev'
    ```

1. Deploy to resource group
    ```bash
    $ az deployment sub create --template-file 'azuredeploy.json' --parameters @azuredeploy.parameters.json -l westeurope --confirm-with-what-if
    ```

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)