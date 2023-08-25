# Deploy Pre-trained Models on Azure

This porject contained full PowerShell script(`.ps1`) & config for deploying pre-trained models on Azure, with 3 solutions (deploy on Azure Kubernetes Services with Azure Container Register, Azure Container Instance with Azure Container Register, and Azure Machine Learning).

> Almost all script can be run as bash commands, just need a little change (e.g. `$env:VARIABLE_NAME` -> `$VARIABLE_NAME`)

![](https://i.imgur.com/2LT8nie.png)


## Prerequisites
- Make sure you have an [Azure](https://portal.azure.com/) account with an active subscription. (with according access)
- Have `Azure CLI` installed. (see [How to install](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli))
- Have `Docker` installed. (see [Docker](https://www.docker.com/))
- For AKS deployment: Have `kubectl` installed. (see [How to install](https://kubernetes.io/docs/tasks/tools/))

## Run and Deploy Demo Model

### Demo Model & Env Image
This example use the half-plus-two model.(input/2 + 2 = prediction)

Use the tensorflow/serving image as environment.

(see [TensorFlow Serving with Docker](https://www.tensorflow.org/tfx/serving/docker) for more details)

### Run
Clone the project
```bash
  git clone https://github.com/wama-tw/deploy-pretrain-models-on-azure.git
```

Go to the project directory
```bash
  cd deploy-pretrain-models-on-azure
```

- Option 1. Deploy model on AML
```bash
  cd AML
```

- Option 2. Deploy model on ACR+ACI
```bash
  cd ACR+ACI
```

- Option 3. Deploy model on ACR+AKS
```bash
  cd ACR+AKS
```

> Make sure to open the `commmands.ps1` file in editor to fill the Environment Variables for yourself. (all in `===== Set Environment Variables in Local =====` section)

Then, run the `ps1` commmands
```bash
./commmands.ps1
```

> If you choose ACR+ACI solution, please check `deploy-ACI.md`