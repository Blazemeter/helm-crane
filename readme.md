# Helm - Blazemeter crane - OPL

Deploy Blazemeter private location engine to your Kubernetes cluster using HELM chart. Plus the chart allows to make additional configurations if required. 

![Helm-Blazemeter-crane](/Image.png)

## Requirements
1. A [BlazeMeter account](https://www.blazemeter.com/)
2. A Kubernetes cluster
3. Latest [Helm installed](https://helm.sh/docs/helm/helm_version/)
4. The kubernetes cluster needs to fulfill [Blazemeter Private location requirements](https://guide.blazemeter.com/hc/en-us/articles/209186065-Private-Location-System-Requirements)

## Usage
There are 2 methods for installing this Helm Chart, or any Helm Chart for that matter. 

1. Using `helm install` method
2. Pulling the chart using `helm pull` and then install the chart `helm install` along with additional configurations.

