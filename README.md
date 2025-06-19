# Helm for Blazemeter Private Location

[Download the latest Chart](https://github.com/Blazemeter/helm-crane/releases)

Deploy Blazemeter private location to your Kubernetes cluster using HELM chart. The chart allows to make advanced/custom configurations to your Blazemeter private location deployment. 

![Helm-crane](/logo.png)

## [1.0] Requirements
1. A [BlazeMeter account](https://a.blazemeter.com/)
2. A Kubernetes cluster
3. Latest [Helm installed](https://helm.sh/docs/helm/helm_version/)
4. The kubernetes cluster needs to fulfill [Blazemeter Private location requirements](https://help.blazemeter.com/docs/guide/private-locations-system-requirements.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____1)
---


## [2.0] Generating Harbour_ID, Ship_ID and Auth_token in Blazemeter

>To start with, you will need Harbour_ID, Ship_ID & Auth_token from Blazemeter. You can either generate these from Blazemeter GUI or through API as described below.

1. Get the Harbour_ID, Ship_ID and Auth_token through BlazeMeter GUI
    - Login to Blazemeter & create a [Private Location](https://help.blazemeter.com/docs/guide/private-locations-create.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____2)
    - Copy the [Harbour_ID](https://help.blazemeter.com/docs/guide/private-locations-where-to-find-harbor-id-and-ship-id.html?tocpath=Private%20Locations%7CPrivate%20Locations%20Knowledge%20Base%7C_____1) once the private location has been created in BlazeMeter.
    - Create an [Agent](https://help.blazemeter.com/docs/guide/private-locations-install-agent.html)
    - Copy the Ship_ID & Auth_token, you can copy Harbour_ID, when you click on the add agent button. 

2. Get the Harbour_ID, Ship_ID and Auth_token through BlazeMeter API
    - You should have the Blazemeter API key and secret
    - Create a Private location [using API](https://help.blazemeter.com/apidocs/performance/private_locations_create_a_private_location.htm?tocpath=Performance%7CPrivate%20Locations%7C_____3)
    - Copy the Harbour ID
    - Create an Agent [using API](https://help.blazemeter.com/apidocs/performance/private_locations_create_an_agent.htm?tocpath=Performance%7CPrivate%20Locations%7C_____4)
    - Copy the Ship_ID
    - Generate the docker command [using API](https://help.blazemeter.com/apidocs/performance/private_locations_docker_command.htm?tocpath=Performance%7CPrivate%20Locations%7C_____5)
    - Copy Auth_token, harbour_id and ship_id from the docker command

---

## [3.0] Downloading the chart

- Pull/Download the chart - tar file from the GitHub repository [Download the latest Chart](https://github.com/Blazemeter/helm-crane/releases)

- Untar the chart
```bash
tar -xvf helm-crane(version).tgz
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
## [4.0] Configuring the Chart values before installing

- Open the `values` file to apply configurations as per your deployment requirements. 

### [4.1] Adding the basic/required configurations
- Add the Harbour_ID, Ship_ID and Auth_token in the `values.yaml` file.  `harbour_id`, `ship_id` and `authtoken` are the one we aquired earlier see: [2.0](#20-generating-harbour_id-ship_id-and-auth_token-in-blazemeter)

```yaml
env: 
  # if you plan to pass the AUTH_TOKEN through secret in the crane ENV variables set secret to yes and add secret name and key
  secret_authtoken:
    enable: no
    secretName: "your-secretName"
    secretKey: "authtoken"
  authtoken:  "MY_SAMPLE_TOKEN-shfowh243owijoidh243o2nosIOIJONo2414"
  harbour_id: "MY_SAMPLE_HARBOURID"
  ship_id: "MY_SAMPLE_SHIPID"
```

- If you require the AUTH_TOKEN for any crane installation to be secret/secure, the ENV values for AUTH_TOKEN can be inherited from the k8s secret. You will need to make changes to `secret_authtoken` part of the `values` file. In that case, the `authtoken` value will be ignored. Make sure the cluster/namespace has the secret applied in the following format:

```YAML
apiVersion: v1
kind: Secret
metadata:
  name: <your-secretName>
  namespace: <namespace name>
type: Opaque
data:
  authtoken: ZjIzZjU0ZTIwODk5ZWYwYzgzYmJkMzZmYzU3ODlhNzc3ODJjYTY1YjJjODIzZTMyMjY3NDcxM2QzZTc3Mzg2Yw==
```

- Additionally, you can now configure the deployment settings, like non-default serviceAccount, role & clusterrole name and restart policy in the below section of the `values` file.
```yaml
deployment:
  # This is the name of roles and clusterroles created by the chart.
  role: "roleCrane"
  clusterrole: "cluster-roleCrane"
  serviceAccount:
  # Specifies whether a ServiceAccount should be created. 
    create: false
  # The name of the ServiceAccount to use, keep empty to use default ServiceAccount.
    name:
  restartPolicy: "Always"
```

### [4.2] Configuring the default image settings

- You can configure the settings for image pull-policy, auto-update, etc. in the `image` values. If the `auto-update` is not a desired option, it can be set to `false`, which will disable the auto-update for crane and its components. Similarly, the `pull` policy can be changed to `Always` or `IfNotPresent` as per the requirement. If the cluster cache is configured to preserve the images for longer duration, changing the pull policy is desirable. 

```yaml
image:   
  docker_registry: "gcr.io/verdant-bulwark-278"  #default registry for Blazemeter crane (DO NOT CHANGE)
  image: "gcr.io/verdant-bulwark-278/blazemeter/crane"  #default image for Blazemeter crane (DO NOT CHANGE)
  tag: "latest-master"
  auto_update: true                             
  auto_update_running_containers: false   #Controls auto update of components, default false. Also, either AUTO_UPDATE or AUTO_KUBERNETES_UPDATE must be true for this option to work, depending on the platform Crane is running on.
  pullPolicy: "Always"
```

*Note: Do not change the default Blazemeter registry, image or tag values here, use the `imageOverride` section to override the default settings.*


### [4.2] Configuring Image Overrides

The chart supports overriding the default images used for Crane and its components through the `imageOverride` section in your `values.yaml` file. This allows you to specify custom registries, images, tags, and pull policies for all relevant containers.

Example configuration:
```yaml
imageOverride:
  docker_registry: "gcr.io/<custom-registry>"
  craneImage: "gcr.io/<custom-registry>/blazemeter/crane"
  tag: "latest-master"
  auto_update: true
  auto_update_running_containers: false
  executorImages:
    taurus-cloud:latest: "pathToYourRepo/taurus-cloud:version"
    torero:latest: "pathToYourRepo/torero:version"
    blazemeter/service-mock:latest: "pathToYourRepo/service-mock:version"
    blazemeter/mock-pc-service:latest: "pathToYourRepo/mock-pc-service:version"
    blazemeter/sv-bridge:latest: "pathToYourRepo/sv-bridge:version"
    blazemeter/doduo:latest: "pathToYourRepo/doduo:version"
  pullPolicy: "Always"
  testImage: "gcr.io/verdant-bulwark-278/cranehook"
  testTag: "latest"
```

- **docker_registry**: Custom Docker registry for all images.
- **craneImage**: Path to the Crane image.
- **tag**: Image tag to use.
- **auto_update**: Enable or disable automatic updates.
- **auto_update_running_containers**: Control auto-update for running containers.
- **executorImages**: Map of executor/component images to override.
- **pullPolicy**: Image pull policy (`Always`, `IfNotPresent`, etc.).
- **testImage** and **testTag**: Image and tag for the test hook.

**Note:**  
> If you do not need to override images, you can leave this section commented or empty, and the chart will use the default images provided by BlazeMeter.


### [4.4] Adding Proxy config details
- If the [proxy](https://help.blazemeter.com/docs/guide/private-locations-optional-installation-step-configure-agents-to-use-corporate-proxy.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____10#h_4a05699b-fb2d-4d9b-933d-11b5e3befaca) needs to be configured, change the value for `enable` to `yes`. Add the configuration for `http_proxy` or/and `https_proxy`. Make sure the values are set to `yes` before adding the proxy `path`, as shown below:

```yaml
proxy:
  enable: yes
  http_proxy: yes
  http_path: "http://server:port" 
  https_proxy: yes
  no_proxy: "kubernetes.default,127.0.0.1,localhost,myHostname.com"
```


### [4.5] Adding CA certificates

- If you plan to configure the Kubernetes installation to use [CA certificates](https://help.blazemeter.com/docs/guide/private-locations-optional-installation-step-configure-kubernetes-agent-to-use-ca-bundle.html?tocpath=Private%20Locations%7CInstallation%20of%20Private%20Locations%7C_____12), make changes to the following section of the values.yaml file:
  -  Change the `enable` to `yes`
  -  Provide the path to the certificate file respectively for both (ca_subpath & aws_subpath). You will need to copy/move these cert files in the same directory as this chart and just provide the name of the certs instead of the complete path. '

```yaml
ca_bundle:
  enable: no
  request_ca_bundle: "certificate.crt"
  aws_ca_bundle: "certificate2.crt"
  volume:
    volume_name: "volume-cm"
    mount_path: "/var/cm"
    readOnly: true
```


### [4.6] Adding gridProxy configuration

- If you plan to configure your crane installation to use [gridProxy](https://help.blazemeter.com/docs/guide/functional-run-gridproxy-over-https.htm?Highlight=grid%20proxy), make changes to the following section of the `values.yaml` file. Grid Proxy enables you to run Selenium functional tests in BlazeMeter without using a local server. You can run Grid Proxy over the HTTPS protocol using the following methods:

```yaml
gridProxy:
  enable: yes
  a_environment: 'https://your.environment.net'
  tlsKeyGrid: "certificate.key"          # The private key for the domain used to run the BlazeMeter Grid proxy over HTTPS. Value in string format. 
  tlsCertGrid: "certificate.crt"         # The public certificate for the domain used to run the BlazeMeter Grid proxy over HTTPS. Value in string format.
  mount_path: "/etc/ssl/certs/doduo"
  doduoPort:  9070                       # The user-defined port where to run Doduo (BlazeMeter Grid Proxy). By default, Doduo listens on port 8000. 
  volume:
    volume_name: "tls-files"
    mount_path: "/etc/ssl/certs/doduo"
    readOnly: true
```


### [4.5] Deploying Non_priviledge container - NON_ROOT deployment. 
- If you plan to deploy the Blazemeter crane as a non_Priviledged installation, make changes to the following part of the `values` file. Change the `enable` to `yes` and this will automatically run the deployment and consecutive pods as Non_root/Non_priviledge. You can ammend the runAsGroup and runAsUser to any value of your choice. We can only have same user/groupId for both crane and child resources.

```YAML
non_privilege_container:
  enable: no
  runAsGroup: 1337
  runAsUser: 1337
```

*Non-root deployment requires an additional feature to be enabled at account level, please contact support for enabling this feature.*



### [4.6] Enabling Service Virtualisation (Mock Services)

If your Private Location will run service-virtualisation (mock services), enable the `service_virtualization` section in your `values.yaml` file. This allows you to expose mock services using either Istio or NGINX ingress controllers.

```yaml
service_virtualization: 
  enable: yes
  ingressType: nginx         # or istio, depending on your cluster setup
  credentialName: "wildcard-credential"
  web_expose_subdomain: "mydomain.local"
```

- **enable**: Set to `yes` to activate service virtualisation.
- **ingressType**: Choose `nginx` or `istio` based on your ingress controller.
- **credentialName**: Name of the credential (e.g., wildcard certificate) to use.
- **web_expose_subdomain**: Subdomain to expose mock services.

 **Note:**  
> Only one ingress type can be enabled at a time. Ensure the corresponding ingress controller (NGINX or Istio) is installed and configured in your cluster.  
> For more details, see the [Blazemeter guide](https://help.blazemeter.com/docs/guide/private-locations-install-blazemeter-agent-for-kubernetes-for-mock-services.html).



### [4.7] Configure deployment to support child pods to inherit labels from the crane

- If you require a certain set of labels as part of the deployment of crane and it's child resources, we can use these `labels` values. These labels can be set for crane as well as the child pods. Add labels in a JSON format as per the example. 
```yaml
labelsCrane:
  enable: no
  syntax: {"label_1": "label_1_value", "label_2": "label_2_value"}
labelsExecutors:
  enable: no 
  syntax: {"label_1": "label_1_value", "label_2": "label_2_value"}
```
*Note: `labelsCrane` is for labels declared for crane and `labelsExecutors` is for labels declared for child pods.*



### [4.8] Configure deployment to support for tolerations 

- The configuration is used to specify the tolerations for crane and child pods. Switch the `enable` to `yes` and add tolerations for crane and & child resources. Add tolerations in a Json format as per the example:
```yaml
tolerationCrane: 
  enable: no
  syntax: [{ "effect": "NoSchedule", "key": "lifecycle", "operator": "Equal", "value": "spot" }]
tolerationExecutors: 
  enable: no
  syntax: [{ "effect": "NoSchedule", "key": "lifecycle", "operator": "Equal", "value": "spot" }]
```
*Note: `tolerationCrane` is for tolerations declared for crane and `tolerationExecutors` is for tolerations declared for child pods.*



### [4.9] Configure deployment to support node selector for crane & child resources
- The configuration is used to specify the node selector for crane and child pods. Switch the `enable` to `yes` and add node selectors for crane and child resources. Add node selectors in a Json format as per the example:
```yaml
nodeSelectorCrane:
  enable: no
  syntax:  {"label_1": "label_1_value", "label_2": "label_2_value"}
nodeSelectorExecutor:
  enable: no
  syntax:  {"label_1": "label_1_value", "label_2": "label_2_value"}
```
*Note: `nodeSelectorCrane` is for node selectors declared for crane and `nodeSelectorExecutor` is for node selectors declared for child pods.*



### [4.10] Configure resources limits and requests for the crane & child resources.

- If you require a CPU, MEM or EphemeralStorage limits/requests to be applied to crane and its child resources, we can use this `resourcesCrane` or `resourcesExecutors` value. The values in `resourcesCrane` values will be applied to crane deployment, while the values in `resourcesExecutors` will be applied to the child resources. You can either use one of them or both. Add required values in the below value section in the values.yaml file.

```yaml
# CPU & Memory limits & requests for resources for crane deployment. You can also specify ephemeral storage requests for the crane.
resourcesCrane:  
  requests:     
    CPU: 250m
    MEM: 512Mi 
    storage: #100
  limits:
    CPU: #1 
    MEM: #2Gi
    storage: #1024    # This is in MB

# CPU & Memory limits & requests for resources created by agent. You can also specify ephemeral storage limits for the child resources.
resourcesExecutors: 
  requests:           
    CPU: 1000m        
    MEM: 4096         # This value should be an integer unlike other values that supports k8s standard for declaring resource limits/requests.
    storage: #100     # This is in MB
  limits:
    CPU: #2
    MEM: #8Gi
    storage: #1024

```


### [4.11] Configure the Pod Disruption Budget

A [Pod Disruption Budget (PDB)](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) ensures that a minimum number of pods remain available during voluntary disruptions (such as node drains or cluster upgrades). You can configure a PDB for the Crane deployment by enabling the following settings in your `values.yaml` file.

- **Enable PDB**: Set `enable` to `yes` to activate the PDB.
- **minAvailable / maxUnavailable**: Specify either `minAvailable` (minimum pods that must be available) or `maxUnavailable` (maximum pods that can be unavailable). If both are set, `minAvailable` takes precedence.
- **matchLabels**: You can then specify the labels to match pods for the PDB.

Example configuration:
```yaml
podDisruptionBudget:
  enable: yes
  # Only one of minAvailable or maxUnavailable should be set.
  minAvailable: 1
  # maxUnavailable: 1
  matchLabels: {"app": "crane"}
```

**Notes:**
- If you do not require a PDB, leave `enable` as `no`.



### [4.12] Configure SecretProviderClass

The [SecretProviderClass](https://secrets-store-csi-driver.sigs.k8s.io/topics/introduction.html) resource is used with the [Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/) to mount secrets, keys, or certificates from external secret management systems (such as Azure Key Vault, AWS Secrets Manager, or HashiCorp Vault) into Kubernetes pods as files or Kubernetes secrets.

You can enable and configure SecretProviderClass for the Crane deployment by updating the following section in your `values.yaml` file:

- **Enable SecretProviderClass**: Set `enable` to `yes` to activate the integration.
- **provider**: Specify the external secrets provider (e.g., `azure`, `aws`, `vault`).
- **objects**: Add a list of provider-specific objects (such as secrets, alias or keys, etc.)
- **secretObjects**: (Optional) Define Kubernetes secrets to be created from the mounted content.
- **envName**: This is not a standard parameter in secretProviderClass, however, you are required to put in the env variable the specific secret is going to replace/populate. 

Example configuration:
```yaml
secretProviderClass:
  enable: yes
  provider: aws
  # This is in JSON, to allow users configure different spec, like: secretPath, secretKey, objectAlias, etc. 
  objects: [{ "objectName": "arn:aws:secretsmanager:ap-southeast-2:{{AWS ACCOUNT}}:secret:harbour-id-{{dummy}}","objectType": "secretsmanager","objectAlias": "harbour-id-opl"},{"objectName": "arn:aws:secretsmanager:ap-southeast-2:{{AWS ACCOUNT}}:secret:ship-id-{{dummy}}","objectType": "secretsmanager","objectAlias": "ship-id-opl"}]
  secretObjects:  
  # Comment out the below section if you do not plan to create secrets in the namespace. 
    - secretName: auth-token
      type: Opaque
      data:
        - key: auth-token-key
          objectName: auth-token-opl
      envName: AUTH_TOKEN
    - secretName: harbour-id
      type: Opaque
      data:
        - key: harbour-id-key
          objectName: harbour-id-opl
      envName: HARBOR_ID
    - secretName: ship-id
      type: Opaque
      data:
        - key: ship-id-key
          objectName: ship-id-opl
      envName: SHIP_ID
```

**Notes:**
- You can specify as many as you need in the same map/slice fashion. The chart is designed to loop over these items. 
- The `parameters` and `secretObjects` fields should be customized based on your secrets provider and use case.
- If you do not require SecretProviderClass integration, leave `enable` as `no`.



### [4.13] Configure ExternalSecrets Operator

The [ExternalSecrets Operator](https://external-secrets.io/) allows you to synchronize secrets from external secret management systems (such as AWS Secrets Manager or Google Cloud Secret Manager) into Kubernetes secrets. This integration is useful if you want your Crane deployment to automatically fetch and manage secrets from your external provider.

You can enable and configure the ExternalSecrets Operator for the Crane deployment by updating the following section in your `values.yaml` file:

- **Enable ExternalSecrets Operator**: Set `enable` to `yes` to activate the integration.
- **useExistingSecretStore**: (Optional) Reference an existing SecretStore by name.
- **volume**: (Optional) Configure the volume name, mount path, and readOnly flag for mounting secrets.
- **externalSecret**: Configure the ExternalSecret resource:
  - `name`: Name of the ExternalSecret resource.
  - `refreshInterval`: How often the operator should refresh the secret.
  - `target.name`: Name of the Kubernetes Secret to create.
  - `data`: List of secrets to fetch, mapping `secretKey` (Kubernetes key) to `remoteRef.key` (external secret name) and `envName` (environment variable to populate).
- **secretStore**: Configure the SecretStore resource:
  - `name`: Name of the SecretStore.
  - `provider`: Configure your secrets provider (e.g., AWS or GCP).
    - **AWS**: Set `enable` for `aws` to `true`, specify `service` and `region`, and optionally configure `role` or `authSecretRef` for authentication.
    - **GCP**: Set `enable` for `gcpcm` to `true`, specify `projectID`, and optionally configure `secretRef` for authentication.

For example, we are using: 
```yaml
externalSecretsOperator:
  enable: no
  volume: 
    name:       # (Optional) If not provided, will be linked with release name - see helm template
    readOnly:   # Default: true 
    path:       # Default: /mnt/secrets  

  externalSecret: 
    name: blaze-external-secret
    refreshInterval: "15s"
    target:
      name: blazemeter-secrets-store     # Name of Kubernetes Secret to make
    data:
      - secretKey: ship-id     # New key to make
        remoteRef:
          key: ship-id         # Name of the Secret in Secrets Manager
        envName: SHIP_ID       
      - secretKey: harbour-id  # New key to make
        remoteRef:
          key: harbour-id      # Name of the Secret in Secrets Manager
        envName: HARBOR_ID     
      - secretKey: auth-token  # New key to make
        remoteRef:
          key: auth-token      # Name of the Secret in Secrets Manager
        envName: AUTH_TOKEN      
  
  secretStore:
    name: blaze-secret-store
    provider:
      aws:
        enable: true
        service: SecretsManager
        region: ap-southeast-2
```

**Notes:**
- Only enable the provider you intend to use (`aws` or `gcpsm`), please raise a support ticket if you'd like to use `azure` of some other vault. As currently the chart is only designed to work with aws or gcp.
- The chart will use the service account associated with the deployment for authentication unless `authSecretRef` (AWS) or `secretRef` (GCP) is enabled.
- The `data` section allows you to map external secrets to Kubernetes secrets and environment variables.
- If you do not require ExternalSecrets Operator integration, leave `enable` as `no`.
---


## [5.0] Verify if everything is setup correctly

- Once the values are updated, please verify if the values are correctly used in the helm chart:

```sh
helm lint <path-to-chart>
helm template <path-to-chart>
```

This will print the template Helm will use to install this chart. Check the values and if something is missing, please make ammends.

---


## [6.0] Installing the chart

- Install the helm chart
```sh
helm install crane /path/to/chart --namespace <namespace name>
```
**Here, crane is the name we are setting for the chart release**

---



## [7.0] Testing the chart & k8s infrastructure

After installing the chart, you can verify both the deployment and the underlying Kubernetes infrastructure using Helm’s built-in test hooks. This chart includes a test pod that checks for essential connectivity and configuration, ensuring your environment is ready for BlazeMeter workloads.

### [7.1] Run the Helm test

To execute the test:

```sh
helm test <release-name> -n <namespace>
```

- Replace `<release-name>` with the name you used for your Helm release (e.g., `crane`).
- Replace `<namespace>` with the namespace where you installed the chart.

### [7.2] What does the test do?

The test pod will:
- Validate that the Cluster resources are suitable to run Crane & child deployment
- Check for required roles and mappings.
- Verify network connectivity and DNS resolution from within the cluster.
- Validate if the required k8s resources are deployed to support crane and its functionalities


### [7.3] Interpreting results

- **Success:**  
  If the test passes, you’ll see output similar to:
  ```sh
  NAME: crane
  LAST DEPLOYED: Tue Jun  3 20:24:12 2025
  NAMESPACE: default
  STATUS: deployed
  REVISION: 5
  TEST SUITE:     cranetesthook
  Last Started:   Tue Jun  3 20:24:24 2025
  Last Completed: Tue Jun  3 20:24:30 2025
  Phase:          Succeeded
  ```
  This means your chart and infrastructure are ready.

- **Failure:**  
  If the test fails, review the logs for details. The `--logs` flag would point to the issue that is causing the failure.
  Common issues include missing secrets, network restrictions, or misconfigured values/specs. Address any reported issues and re-run the test.

### [7.4] Additional tips

- You can add the `--logs` flag to `helm test` to automatically print the test pod logs:
  ```sh
  helm test <release-name> --logs
  ```
- If the test pod is stuck or fails to start, check for k8s scheduler error (possible with third-party admission controllers), image pull errors, or missing configuration.

If you continue to encounter issues, please contact your cloud or DevOps team for assistance. If this continues to ba an issue, please open a support ticket with Blazemeter support.

---


## [8.0] Upgrading the existing chart

To upgrade your existing Helm release to a new version of the chart, use the `helm upgrade` command. This allows you to apply new chart versions or updated configuration values without uninstalling and reinstalling.

### [8.1] Basic upgrade command

```sh
helm upgrade <release-name> /path/to/newchart -n <namespace>
```
- Replace `<release-name>` with the name of your Helm release (e.g., `crane`).
- Replace `/path/to/newchart` with the path to the new or updated chart directory or `.tgz` file.
- Replace `<namespace>` with the namespace where your release is installed.

### [8.2] Upgrading with custom values

If you have a custom `values.yaml` file, specify it with the `-f` flag:

```sh
helm upgrade <release-name> /path/to/newchart -n <namespace> -f /path/to/values.yaml
```

You can specify multiple `-f` flags to merge several values files.

### [8.3] Additional tips

- Before upgrading, you can preview the changes with:
  ```sh
  helm diff upgrade <release-name> /path/to/newchart -n <namespace> -f /path/to/values.yaml
  ```
  (Requires the [helm-diff plugin](https://github.com/databus23/helm-diff).)
- If you want to force resource updates (for example, if only config or secrets changed), add `--force`:
  ```sh
  helm upgrade <release-name> /path/to/newchart -n <namespace> --force
  ```
- After upgrading, verify the deployment and run the Helm test as described in the previous section.

If you encounter issues during upgrade, review the output for errors and consult the [Helm upgrade documentation](https://helm.sh/docs/helm/helm_upgrade/).

---


## [9.0] Uninstalling the chart

- To uninstall the Helm chart run:
```sh
helm uninstall <release-name> -n <namespace name>
```
---



## [10.0] Changelog:

- 1.4.0 - Added support for Pod Disruption Budgets (PDB) and SecretProviderClass integration. Introduced ExternalSecrets Operator support. Addition of testHook for faster/accurate validation of installation. Minor bug fixes and template enhancements.
- 1.3.1 - Readiness and Liveness probes are now added. 
- 1.3.0 - Chart can support image-override configuration. gridProxy is in working configuration. Resource (CPU & MEM) limit/requests are now configurable for crane and child resources and also for ephemeral storage. Simplified nesting and values configuration. The chart can now work with non-default serviceAccount. Tolerations, nodeSelector and labels can be declared for Crane and child resources separately, with Major fixes & calibrations.
- 1.2.3 - Chart can work with resource requests & limits, similarly the ephemeral storage requests & limits can be configured.
- 1.2.2 - Chart now supports gridProxy deployment configurations
- 1.2.1 - Chart now supports node selectors and tolerations
- 1.2.0 - Chart now supports service virtualisation deployment using nginx-ingress
- 1.1.0 - Chart now supports inheriting labels and resourcelimits to child pods from crane environment
- 1.0.1 - The AUTH_TOKEN can now be inherited from a secret
- 1.0.0 - Now supports service virtualisation deployment using istio-ingress
- 0.1.3 - Supports configuration for non_proviledge container deployment, also added a license
- 0.1.2 - Supports Proxy, CA_certs as an additional configuration of Blazemeter crane deployment
- 0.1.1 - Support proxy as an additional configurable aspect of Blazemeter crane deployment 
- 0.1.0 - Supports standard - vanilla Blazemeter crane deployment (no proxy or CA_Bundle configurable)
