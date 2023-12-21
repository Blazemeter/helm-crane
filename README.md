# Helm for Blazemeter Private Location

[Download the latest Chart](https://github.com/ImMnan/Helm-crane-blazemeter/releases/download/1.0.0/blazemeter-crane-1.0.0.tgz)

Deploy Blazemeter private location engine to your Kubernetes cluster using HELM chart. Plus the chart allows to make advanced configurations if required. 

![Helm-Blazemeter-crane](/Image.png)

### [1.0] Requirements
1. A [BlazeMeter account](https://www.blazemeter.com/)
2. A Kubernetes cluster
3. Latest [Helm installed](https://helm.sh/docs/helm/helm_version/)
4. The kubernetes cluster needs to fulfill [Blazemeter Private location requirements](https://guide.blazemeter.com/hc/en-us/articles/209186065-Private-Location-System-Requirements)


### [2.0] Generating Harbour_ID, Ship_ID and Auth_token in Blazemeter
To start with, Blazemeter user will need Harbour_ID, Ship_ID & Auth_token from Blazemeter. 

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

---

### [3.0] Downloading the chart

- Pull/Download the chart - tar file from the github repository 

  [Download the latest Chart](https://github.com/ImMnan/Helm-crane-blazemeter/releases/download/1.0.0/blazemeter-crane-1.0.0.tgz)

- Untar the chart
```bash
tar -xvf blazemeter-crane-(version).tgz
```

<!To start with, I recommend adding the blazemeter-crane repo to your helm repo list
<!
<!1. We will add `blazemeter` helm reporsitory to our cluster, [read documentations](https://helm.sh/docs/helm/helm_repo/)
<!```
<!helm repo add blazemeter https://helm-repo-bm.storage.googleapis.com/charts
<!```
<!2. Confirm the addition of this repository using the following:
<!```
<!helm repo list
<!```
<!Once the repository has been added, we can simply use the repository name (blazemeter in our case) to install the charts through chart name (instead of using the complete url all the time).
<!
<!3. Pull the chart
<!```
<!helm pull blazemeter/blazemeter-crane --untar=true
<!```
<!So, `blazemeter` is our repo name as added before [2.3], and `blazemeter-crane` is the chart name. 
<!This above command will by-default pull the latest version of the chart, i.e. 0.1.2 which allows configuring CA_bundle. However, if you are interested in other version please use the flag `--version=` in the pull command. >

---
### [4.0] Configuring the Chart values before installing

- Open `values` file to make ammendments as per requirements 
``` 
vi values.yaml
```

#### [4.1] Adding the basic/required configurations
- Add the Harbour_ID, Ship_ID and Auth_token in the `values.yaml` file.  `Harbour_ID`, `Ship_ID` and `authtoken` is the one we aquired before see[2.1]. 

```yaml
env:
  authtoken: "[auth-token]"
  harbour_id: "[harbour-id]"
  ship_id: "[ship-id]"
```

#### [4.2] Adding Proxy config details
- If the [proxy](https://guide.blazemeter.com/hc/en-us/articles/115005639765-Optional-Installation-Step-Configuring-Private-Location-s-Agents-To-Use-a-Corporate-Proxy-Optional-Installation-Step:-Configuring-Private-Location's-Agents-To-Use-a-Corporate-Proxy#h_4a05699b-fb2d-4d9b-933d-11b5e3befaca) needs to be configured, change the value for `use` to `yes`. Now, add the configuration for `http_proxy` or/and `https_proxy`. Make sure the values are set to `yes` before adding the proxy `path`, as shown below:

```yaml
proxy:
  use: yes
  http_proxy: yes
  http_path: "http://server:port" 
  https_proxy: yes
  no_proxy: "kubernetes.default,127.0.0.1,localhost,myHostname.com"
```

#### [4.3] Adding CA certificates
- Now, if you want to configure your Kubernetes installation to use CA certificates, make changes to this section of the values.yaml file:
  -  Change the `use` to `yes`
  -  Provide the path to certificate file respectively for both (ca_subpath & aws_subpath). The best thing is to just copy/move these cert files in the same directory as this chart and just provide the name of the certs instead of complete path.

```yaml
ca_bundle:
  use: no
  ca_subpath: "certificate.crt"
  aws_subpath: "certificate.crt"
volume:
  volume_name: "volume-cm"
  mount_path: "/var/cm"
```

#### [4.4] Additional basic configurations
- Please avoid switching the `serviceAccount.create`  to `yes`, as serviceAccount other than `default` will cause issues with Blazemeter crane deployments. Though I have setup code which will successfully create a new serviceAccount and assign it to all resources in this Helm chart, this is something we need to avoid for now. 

- Change `auto_update: false` if you do not want the cluster to be [auto-updated](https://guide.blazemeter.com/hc/en-us/articles/360009897078-How-to-Enable-Auto-Upgrade-for-Running-Containers) (Not recommended though).
```yaml
  auto_update: "'true'"
```

- Lastly, you can name the namespace for this deployment, just add the name in `namespace`, and this helm chart will be installed under that namespace.
```yaml
deployment:
  name: crane
  namespace: "bm"
```
#### [4.5] Deplouying Non_provoledge container - NON_ROOT deployment. 
- If you plan to deploy the Blazemeter crane as a non_Priviledged installation, make changes to this part of the `values` file.
```YAML
non_privilege_container:
  use: no
  runAsGroup: 1337
  runAsUser: 1337
```
Change the `use` to `yes` and this will automatically run the deployment and consecutive pods as Non_root/Non_priviledge.

#### [4.6] Verify if everything is setup correctly
- Once the values are updated, please verify if the values are correctly used in the helm chart:

```
helm template .
```
This will print the template helm will use to install this chart. Check the values and if something is missing, please make ammends.

### [5.0] Installing the chart

- Install the helm chart
```
helm install crane blazemeter-crane --create-namespace --namespace=bm
```
Here, crane is the name we are setting for the chart on our system and blazemeter-crane is the actual name of the chart. Make sure the namespace declared here is the same as the one we declared in the values file (see 2.3.2.6 section).


### [6.0] Varify the chart installation

- To varify the installation of our Helm chart run:
```
helm list -A
```

## [7.0] Recommendations

It is recommended to install this Helm chart onto the auto-scalable cluster for example - [EKS](https://aws.amazon.com/eks/), [GKE](https://cloud.google.com/kubernetes-engine) or [AKS](https://azure.microsoft.com/en-in/products/kubernetes-service/#:~:text=Azure%20Kubernetes%20Service%20(AKS)%20offers,edge%2C%20and%20multicloud%20Kubernetes%20clusters.). 

However, make sure you are scalling the nodes, as it is not recommended to go with EKS Fargate or GKE Autopilot, those types of autoscalling is not supported for Blazemeter crane deployments. 

Therefore, ***always go with Node autoscalling***

## [8.0] Changelog:

- 0.1.3 - Supports configuration for non_proviledge container deployment, also added a license 
- 0.1.2 - Supports Proxy, CA_certs as an additional configuration of Blazemeter crane deployment
- 0.1.1 - Support proxy as an additional configurable aspect of Blazemeter crane deployment
- 0.1.0 - Supports standard - vanila Blazemeter crane deployment (no proxy or CA_Bundle configurable)
