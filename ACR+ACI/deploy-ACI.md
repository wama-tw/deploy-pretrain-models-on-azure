# Deploy ACI in Azure Portal

1. Go to `container instances`
![](https://i.imgur.com/qTPhnec.png)

2. Start creation
![](https://i.imgur.com/JtvscuU.png)

3. Fill-in info
![](https://i.imgur.com/9D6l3YG.png)
![](https://i.imgur.com/SEPiAyX.png)
![](https://i.imgur.com/pGKbu5N.png)Environment variables
    - MODEL_BASE_PATH: /var/azureml-app/azureml-models/<MODEL_NAME>/<MODEL_VERSION> 
    - MODEL_NAME: <MODEL_NAME>
    (must match with the folder name, in this example, <MODEL_NAME>= half_plus_two)
    
4. Complete
![](https://i.imgur.com/fm7bf87.png)

## Test
```bash
curl --header "Content-Type: application/json" --request POST --data @$env:BASE_PATH/sample_request.json http://$env:PUBLIC_IP``:8501/v1/models/$env:MODEL_NAME`:predict
```