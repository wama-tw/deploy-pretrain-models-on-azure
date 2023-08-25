""
""
" ===== Set Environment Variables in Local ====="
$env:BASE_PATH='C:\Users\Username\filename'     # path in local host
$env:AML_MODEL_NAME='tfserving-mounted'         # model name in Azure ML
$env:MODEL_NAME='half_plus_two'
$env:MODEL_BASE_PATH="/var/azureml-app/azureml-models/$env:AML_MODEL_NAME" # path in docker & defualt path in AML
$env:CONTAINER_NAME="tfserving-test-half-plus-two"
$env:RESOURCE_GROUP='myresourcegroupname'   # Azure Resource Group name
$env:AML_WORKSPACE='myworkspacename'        # Azure ML Workspace name

az login

""
""
" ===== Downloading the Pre-trained TensorFlow Model ====="
mkdir -p $env:BASE_PATH\$env:MODEL_NAME
wget https://aka.ms/half_plus_two-model -O $env:BASE_PATH/$env:MODEL_NAME.tar.gz
tar -xvf $env:BASE_PATH/$env:MODEL_NAME.tar.gz -C $env:BASE_PATH
## The command tar -xvf .\filename\tar.gz -C . is used to extract a tar archive. The -xvf flag is actually a combination of three flags: -x, -v, and -f. The -x flag stands for extract, the -v flag stands for verbose (which means it will show the progress of the extraction), and the -f flag specifies the file to extract from.
wget https://raw.githubusercontent.com/Azure/azureml-examples/main/cli/endpoints/online/custom-container/tfserving/half-plus-two/sample_request.json -O $env:BASE_PATH/sample_request.json

""
""
" ===== Run in Docker to Test Locally ====="
docker run --rm -d --mount type=bind,source=$env:BASE_PATH,target=$env:MODEL_BASE_PATH -p 8501:8501 -e MODEL_BASE_PATH=$env:MODEL_BASE_PATH -e MODEL_NAME=$env:MODEL_NAME --name=$env:CONTAINER_NAME docker.io/tensorflow/serving:latest
## --rm flag: Automatically remove the container when it exits
## -d(--detach): Run container in background and print container ID
## -v(--volume): Bind mount a volume
## -p(--publish): Publish a container’s port(s) to the host
## -e(--env): Set environment variables
sleep 5
""
" ===== Testing for Response ====="
Remove-item alias:curl
curl -v http://localhost:8501/v1/models/$env:MODEL_NAME
curl --header "Content-Type: application/json" --request POST --data @$env:BASE_PATH/sample_request.json http://localhost:8501/v1/models/$env:MODEL_NAME`:predict
docker stop $env:CONTAINER_NAME

""
""
" ===== Deploy Online Endpoint to Azure ====="
az ml online-endpoint create --name tfserving-endpoint -f $env:BASE_PATH/../tfserving-endpoint.yml -g $env:RESOURCE_GROUP -w $env:AML_WORKSPACE
az ml online-deployment create --name tfserving-deployment -f $env:BASE_PATH/../tfserving-deployment.yml --all-traffic -g $env:RESOURCE_GROUP -w $env:AML_WORKSPACE

""
""
" ===== Test the Endpoint through Azure CLI ====="
az ml online-endpoint invoke -n tfserving-endpoint --request-file $env:BASE_PATH/sample_request.json -g $env:RESOURCE_GROUP -w $env:AML_WORKSPACE

""
" ===== Test the REST Endpoint ====="
$env:ACCESS_TOKEN=$(az ml online-endpoint get-credentials -n tfserving-endpoint -g $env:RESOURCE_GROUP -w $env:AML_WORKSPACE -o tsv --query accessToken)
$env:REST_ENDPOINT=$(az ml online-endpoint show -n tfserving-endpoint -g $env:RESOURCE_GROUP -w $env:AML_WORKSPACE --query "scoring_uri" -o tsv)
"Request:"
cat $env:BASE_PATH/sample_request.json
"Responce:"
curl --header "Content-Type: application/json" --header "Authorization: Bearer $env:ACCESS_TOKEN" --request POST --data @$env:BASE_PATH/sample_request.json $env:REST_ENDPOINT
""
""
"Request:"
cat $env:BASE_PATH/sample_request_single_input.json
"Responce:"
curl --header "Content-Type: application/json" --header "Authorization: Bearer $env:ACCESS_TOKEN" --request POST --data @$env:BASE_PATH/sample_request_single_input.json $env:REST_ENDPOINT

# ""
# ""
# " ===== Delete the Endpoint ====="
# az ml online-endpoint delete --name tfserving-endpoint -g $env:RESOURCE_GROUP -w $env:AML_WORKSPACE

# ""
# " ===== Archive the Model ====="
# az ml model archive -name $env:AML_MODEL_NAME -g $env:RESOURCE_GROUP -w $env:AML_WORKSPACE