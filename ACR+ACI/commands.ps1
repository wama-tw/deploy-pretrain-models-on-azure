""
""
" ===== Set Environment Variables in Local ====="
$env:BASE_PATH='C:\Users\Username\filename'     # path in local host
$env:MODEL_FILE_NAME='tfserving-mounted'         # model file name in docker
$env:MODEL_NAME='half_plus_two'
$env:MODEL_BASE_PATH="/var/azure-app/azure-models/$env:MODEL_FILE_NAME" # path in docker
$env:IMAGE_NAME='example-models-image:latest'
$env:CONTAINER_NAME='tfserving-test-half-plus-two'

$env:RESOURCE_GROUP='myresourcegroupname'   # Azure Resource Group name
$env:ACR_NAME='myacr'     # Azure Container Registry registry name, most be unique globally

az login

""
""
" ===== Downloading the Pre-trained TensorFlow Model ====="
mkdir -p $env:BASE_PATH
wget https://aka.ms/half_plus_two-model -O $env:BASE_PATH/$env:MODEL_NAME.tar.gz
tar -xvf $env:BASE_PATH/$env:MODEL_NAME.tar.gz -C $env:BASE_PATH
## The command tar -xvf .\filename\tar.gz -C . is used to extract a tar archive. The -xvf flag is actually a combination of three flags: -x, -v, and -f. The -x flag stands for extract, the -v flag stands for verbose (which means it will show the progress of the extraction), and the -f flag specifies the file to extract from.
wget https://raw.githubusercontent.com/Azure/azureml-examples/main/cli/endpoints/online/custom-container/tfserving/half-plus-two/sample_request.json -O $env:BASE_PATH/sample_request.json

""
""
" ===== Run in Docker to Test Locally ====="
$env:CONTAINER_ID=docker run --rm -d -p 8501:8501 -e MODEL_BASE_PATH=$env:MODEL_BASE_PATH -e MODEL_NAME=$env:MODEL_NAME --name=$env:CONTAINER_NAME docker.io/tensorflow/serving:latest
docker exec -it $env:CONTAINER_NAME mkdir -p $env:MODEL_BASE_PATH
docker cp $env:BASE_PATH/. $env:CONTAINER_ID`:$env:MODEL_BASE_PATH/  # copy the model into container
## --rm flag: Automatically remove the container when it exits
## -d(--detach): Run container in background and print container ID
## -v(--volume): Bind mount a volume
## -p(--publish): Publish a container’s port(s) to the host
## -e(--env): Set environment variables
$env:CONTAINER_ID
sleep 5
""
" ===== Testing for Response ====="
Remove-item alias:curl
curl -v http://localhost:8501/v1/models/$env:MODEL_NAME
curl --header "Content-Type: application/json" --request POST --data @$env:BASE_PATH/sample_request.json http://localhost:8501/v1/models/$env:MODEL_NAME`:predict

""
""
" ===== Create a Docker Image From the Running Container ====="
docker ps
docker commit $env:CONTAINER_ID $env:IMAGE_NAME
docker stop $env:CONTAINER_NAME

""
""
" ===== Create ACR ====="
az acr create --resource-group $env:RESOURCE_GROUP --name $env:ACR_NAME --sku Basic
az acr login --name $env:ACR_NAME   # Log in to an Azure Container Registry through the Docker CLI, use 'docker logout' to log out.
$env:ACR_LOGINSERVER=az acr list --resource-group $env:RESOURCE_GROUP --query "[].{acrLoginServer:loginServer}" --output tsv
$env:ACR_LOGINSERVER
docker tag $env:IMAGE_NAME $env:ACR_LOGINSERVER/$env:IMAGE_NAME
docker push $env:ACR_LOGINSERVER/$env:IMAGE_NAME  # push local tagged image to ACR
docker logout

# " ========================== Above This Line Same as ACR + AKS Solution ========================== "

# ""
# ""
# " ===== Enable Admin-User for ACI Deployment ====="
az acr update -n $env:ACR_NAME --admin-enabled true

# ""
# ""
# " ===== Deploy to ACI using Serveice Principal ====="
# ## Use Azure Portal (pls see the pngs & README)