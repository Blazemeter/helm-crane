# Helm for Blazemeter Private Location

Deploy Blazemeter private location engine to your Kubernetes cluster using HELM chart. Plus the chart allows to make additional configurations if required. 

![Helm-Blazemeter-crane](/Image.png)

## [1.0] Requirements
1. A [BlazeMeter account](https://www.blazemeter.com/)
2. A Kubernetes cluster
3. Latest [Helm installed](https://helm.sh/docs/helm/helm_version/)
4. The kubernetes cluster needs to fulfill [Blazemeter Private location requirements](https://guide.blazemeter.com/hc/en-us/articles/209186065-Private-Location-System-Requirements)


## [2.0] Usage
There are 2 methods for installing this Helm chart, or any Helm chart for that matter. In any case, the user will need Harbour_ID, Ship_ID & Auth_token from Blazemeter. 

### [2.1] Here is how to generate Harbour_ID, Ship_ID and Auth_token
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


### [2.2] Two common methods of installing HELM chart
1. Using `helm install` method - [read documentation](https://helm.sh/docs/helm/helm_install/)
2. Pulling the chart using `helm pull` and then install the chart using `helm install` along with additional configurations. [read documentations](https://helm.sh/docs/helm/helm_pull/)

### [2.3] We recommend adding the blazemeter-crane repo to your helm repo list

1. We will add `blazemeter` helm reporsitory to our cluster, [read documentations](https://helm.sh/docs/helm/helm_repo/)
```
helm repo add blazemeter https://helm-repo-bm.storage.googleapis.com/
```

2. Confirm the addition of this repository using the following:
```
helm repo list
```
Once the repository has been added, we can simply use the repository name (blazemeter in our case) to install the charts through chart name (instead of using the complete url all the time).


#### [2.3.1] Method 1

Install the chart directly
```
helm install crane blazemeter/blazemeter-crane --set env.harbour_id="Harbour_ID" env.ship_id="Ship_ID" env.authtoken="Auth_token" --create-namespace --namespace=bm
```
Here, `crane` is the name we want to set for this chart on our cluster, `blazemeter` is our repo name as added before [2.3], and `blazemeter-crane` is the chart name. 
`Harbour_ID`, `Ship_ID` and `authtoken` is the one we aquired before see[2.1]. 


#### [2.3.2] Method 2
1. Pull the chart
```
helm pull blazemeter/blazemeter-crane
```
Again, `blazemeter` is our repo name as added before [2.3], and `blazemeter-crane` is the chart name. 

2. Open `values` file to make ammendments as per requirements 
``` 
vi values.yaml
```

3. Add the Harbour_ID, Ship_ID and Auth_token in the `values.yaml` file.  `Harbour_ID`, `Ship_ID` and `authtoken` is the one we aquired before see[2.1]. 

```yaml
env:
  authtoken: "[auth-token]"
  harbour_id: "[harbour-id]"
  ship_id: "[ship-id]"
```

4. If the [proxy](https://guide.blazemeter.com/hc/en-us/articles/115005639765-Optional-Installation-Step-Configuring-Private-Location-s-Agents-To-Use-a-Corporate-Proxy-Optional-Installation-Step:-Configuring-Private-Location's-Agents-To-Use-a-Corporate-Proxy#h_4a05699b-fb2d-4d9b-933d-11b5e3befaca) needs to be configured, change the value for `use` to `yes` following the configuration for `http_proxy` or/and `https_proxy`. Make sure the values are set to `yes` before adding the proxy `path`, as shown below:

```yaml
proxy:
  use: yes
  http_proxy: yes
  http_path: "http://server:port" 
  https_proxy: yes
  https_path: "https://server:port"
```

5. Change `auto_update: false` if you do not want the cluster to be [auto-updated](https://guide.blazemeter.com/hc/en-us/articles/360009897078-How-to-Enable-Auto-Upgrade-for-Running-Containers) (Not recommended though).
```yaml
  auto_update: "'true'"
```

6. Lastly, you can name the namespace for this deployment, just add the name in `namespace`, this helm chart will be installed under that namespace.
```yaml
deployment:
  name: crane
  namespace: "bm"
```

7. Please avoid switching the `serviceAccount.create`  to `yes`, as serviceAccount other than `default` will cause issues with Blazemeter crane deployments. Though I have setup code which will successfully create a new serviceAccount and assign it to all resources in this Helm chart, this is something we need to avoid for now. 

8. Once the values are updated, please verify if the values are correctly used in the helm chart:

```
helm template .
```
This will print the template helm will use to install this chart. Check the values and if something is missing, please make ammends.

8. Install the helm chart
```
helm install crane blazemeter-crane --create-namespace --namespace=bm
```
Here, crane is the name we are setting for the chart on our system and blazemeter-crane is the actual name of the chart. 

### [2.4] Varify the chart installation

To varify the installation of our Helm chart run:
```
helm list
```

## [3.0] Recommendations

It is recommended to install this Helm chart onto the auto-scalable cluster for example - [EKS](https://aws.amazon.com/eks/), [GKE](https://cloud.google.com/kubernetes-engine) or [AKS](https://azure.microsoft.com/en-in/products/kubernetes-service/#:~:text=Azure%20Kubernetes%20Service%20(AKS)%20offers,edge%2C%20and%20multicloud%20Kubernetes%20clusters.). 

However, make sure you are scalling the nodes, as it is not recommended to go with EKS Fargate or GKE Autopilot, those types of autoscalling is not supported for Blazemeter crane deployments. 

Therefore, ***always go with Node autoscalling***


