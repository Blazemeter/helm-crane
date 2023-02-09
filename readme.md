# Helm for Blazemeter Private Location

Deploy Blazemeter private location engine to your Kubernetes cluster using HELM chart. Plus the chart allows to make additional configurations if required. 

![Helm-Blazemeter-crane](/Image.png)

## Requirements
1. A [BlazeMeter account](https://www.blazemeter.com/)
2. A Kubernetes cluster
3. Latest [Helm installed](https://helm.sh/docs/helm/helm_version/)
4. The kubernetes cluster needs to fulfill [Blazemeter Private location requirements](https://guide.blazemeter.com/hc/en-us/articles/209186065-Private-Location-System-Requirements)


## Usage
There are 2 methods for installing this Helm chart, or any Helm chart for that matter. In any case, the user will need Harbour_ID, Ship_ID & Auth_token from Blazemeter. 

### Here is how to generate Harbour_ID, Ship_ID and Auth_token
1. Get the Harbour_ID, Ship_ID and Auth_token through BlazeMeter GUI
    - Login to Blazemeter & create a [Private Location](https://guide.blazemeter.com/hc/en-us/articles/207421655-Creating-a-Private-Location-Creating-a-Private-Location)
    - Copy the [Harbour_ID](https://guide.blazemeter.com/hc/en-us/articles/360000270577-Where-can-I-find-the-Harbor-ID-and-Ship-ID-) once the private location has been created in BlazeMeter.
    - Create an [Agent](https://guide.blazemeter.com/hc/en-us/articles/360017746838)
    - Copy the Ship_ID & Auth_token, you can copy Harbour_ID if you missed it earlier.

2. Get the Harbour_ID, Ship_ID and Auth_token through BlazeMeter API
    - You should have Blazemeter API key and secret
    - Create a Private location [using API](https://api.blazemeter.com/performance/#create-a-private-location)
    - Copy the Harbour ID
    - Create an Agent [using API](https://api.blazemeter.com/performance/#create-an-agent)
    - Copy the Ship_ID
    - Generate the docker command [using API](https://api.blazemeter.com/performance/#generate-docker-command)
    - Copy Auth_token. 


### Two common methods of installing HELM chart
1. Using `helm install` method
2. Pulling the chart using `helm pull` and then install the chart using `helm install` along with additional configurations.

> Method 1
```
helm install crane https://github.com/ImMnan/Helm-crane-blazemeter.git --set env.harbour_id="Harbour_ID" env.ship_id="Ship_ID" env.authtoken="Auth_token" 
```




