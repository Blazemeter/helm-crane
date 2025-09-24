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

Before installing the chart, you must provide your BlazeMeter `harbour_id`, `ship_id`, and `authtoken` in the `values.yaml` file. These values are required for the Crane deployment to register and authenticate with BlazeMeter.  
Refer to [2.0](#20-generating-harbour_id-ship_id-and_auth_token-in-blazemeter) for instructions on how to obtain these values.

**Example:**
```yaml
env:
  authtoken:  "YOUR_AUTH_TOKEN"
  harbour_id: "YOUR_HARBOUR_ID"
  ship_id:    "YOUR_SHIP_ID"
```

- Replace the example values above with your actual credentials.

#### Using Kubernetes Secrets or External Secret Managers

If you want to keep your credentials secure and **not** store them directly in `values.yaml`, you can use one of the following integrations:

- **SecretProviderClass** (CSI Driver)
- **ExternalSecrets Operator**

When either of these integrations is enabled (`secretProviderClass.enable: yes` or `externalSecretsOperator.enable: yes`), the `env.authtoken`, `env.harbour_id`, and `env.ship_id` values in `values.yaml` will be ignored, and the credentials will be sourced from your external secret store.

**Example:**
```yaml
secretProviderClass:
  enable: yes
  provider: aws
  # ...other configuration...
```
or
```yaml
externalSecretsOperator:
  enable: yes
  # ...other configuration...
```

**Notes:**  
>- If you use a secret manager, ensure your secret keys and environment variable mappings are correct in the relevant section.
>- See [4.14](#414-configure-secretproviderclass) and [4.15](#415-configure-externalsecrets-operator) for detailed configuration examples.


**Important:**  
- Only set credentials in one place. If both `env` and a secret integration are set, the secret integration takes precedence.
- Do **not** commit sensitive values to version control.

---

### [4.2] Configuring Deployment Options

The `.Values.deployment` section in `values.yaml` controls how the main Crane deployment is created, including service account, RBAC roles, and restart policy of the deployment (should it fails).

**Example:**
```yaml
deployment:
  role:                # (Optional) Name of an existing Role to use in the namespace. If not set, defaults to <releaseName>-role.
  clusterrole:         # (Optional) Name of an existing ClusterRole to use. If not set, defaults to <releaseName>-clusterrole.
  serviceAccount:
    create: false      # Set to true to create a new ServiceAccount, or false to use an existing one.
    name:              # (Optional) Name of the ServiceAccount to use. Leave empty to use the default.
    annotations:       # (Optional) Annotations to add to the ServiceAccount.
      eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/example-role
      custom.annotation/key: custom-value
  restartPolicy:       # (Optional) Pod restart policy. Defaults to "Always".
```

- `role`: Use an existing Kubernetes Role for RBAC. Leave empty to let the chart create one.
- `clusterrole`: Use an existing ClusterRole for cluster-wide permissions. Leave empty to let the chart create one.
- `serviceAccount.create`: If `true`, the chart creates a new ServiceAccount. If `false`, you must specify an existing ServiceAccount in `serviceAccount.name`. 
- `serviceAccount.name`: Name of the ServiceAccount to use. If empty, the default ServiceAccount is used.
- `serviceAccount.annotations`: Add custom annotations (e.g., for IAM roles or workload identity).
- `restartPolicy`: Pod restart policy (`Always`, `OnFailure`, or `Never`). Defaults to `Always`.

**Notes:**
- If your cluster uses IAM roles for service accounts (IRSA) or workload identity, add the required annotations under `serviceAccount.annotations`.
- If `create: false`, the chart will not create or modify the existing ServiceAccount, and the annotations in values.yaml will be ignored.
- If you want to use pre-existing RBAC roles, specify their names in `role` and `clusterrole`.
- For most installations, you can leave these fields at their defaults unless you have specific security or compliance requirements.

**Example for creating a new ServiceAccount with a custom IAM role:**
```yaml
deployment:
  serviceAccount:
    create: true
    name: my-existing-sa
    annotations:
      eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-crane-role
```


### [4.3] Configuring Image Overrides

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
>- If you do not need to override images, you can leave this section commented or empty, and the chart will use the default images provided by BlazeMeter.


### [4.4] Configure Proxy Settings

If your environment requires the use of a proxy, you can enable and configure proxy settings for the Crane deployment. Set `enable` to `yes` and provide the relevant proxy URLs in your `values.yaml` file.

Example configuration:
```yaml
proxy:
  enable: yes
  http_path: "http://your-http-proxy:port"
  https_path: "https://your-https-proxy:port"
  no_proxy: "kubernetes.default,127.0.0.1,localhost,myHostname.com"
```

- **enable**: Set to `yes` to activate proxy configuration.
- **http_path**: (Optional) HTTP proxy URL.
- **https_path**: (Optional) HTTPS proxy URL.
- **no_proxy**: (Optional) Comma-separated list of hosts or domains that should bypass the proxy.

**Note:**  
>- Only set the proxy values if your cluster requires outbound traffic to go through a proxy. The `no_proxy` field helps exclude internal or local addresses (defaults to "kubernetes.default,127.0.0.1,localhost")


### [4.5] Adding CA certificates (only configure if required, & for service virtualisation only)

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


### [4.6] Adding gridProxy configuration (only configure if required, & for GUI functional testing only)

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


### [4.7] Deploying Non_privilege container - NON_ROOT deployment. 
- If you plan to deploy the Blazemeter crane as a non_privileged installation, make changes to the following part of the `values` file. Change the `enable` to `yes` and this will automatically run the deployment and consecutive pods as Non_root/Non_privilege. You can amend the runAsGroup and runAsUser to any value of your choice. We can only have same user/groupId for both crane and child resources.

```yaml
non_privilege_container:
  enable: no
  runAsGroup: 1337
  runAsUser: 1337
```
**Note:**  
>- Non-root deployment requires an additional feature to be enabled at account level, please contact support for enabling this feature.*



### [4.8] Configure deployment to support Service Virtualisation (Mock Services)

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
>- Only one ingress type can be enabled at a time. Ensure the corresponding ingress controller (NGINX or Istio) is installed and configured in your cluster.  
>- For more details, see the [Blazemeter guide](https://help.blazemeter.com/docs/guide/private-locations-install-blazemeter-agent-for-kubernetes-for-mock-services.html).



### [4.9] Configuring Labels for Crane and Child Resources

You can add custom labels to the main Crane deployment, crane pod and its child resources (such as executor pods) using the following sections in your `values.yaml` file. This is useful for organizing, tracking, or applying policies to your resources.

There are three label sections:
- `labelsCrane`: Labels for the Crane Pod & deployment.
- `labelsExecutors`: Labels for child resources (executors/agents).

Each section has:
- `enable`: Set to `yes` to apply the labels.
- `syntax`: Provide your labels in JSON format.

**Example configuration:**
```yaml
labelsCrane:
  enable: yes
  syntax: {"purpose": "loadtest", "owner": "devops"}

labelsExecutors:
  enable: yes
  syntax: {"type": "executor", "region": "us-east-1"}
```

**Notes:**
>- Use these sections to ensure your Crane deployment and all related resources are labeled according to your organization’s standards
>- These labels are added in addition to any default labels set by the helm chart and Blazemeter.
>- If `enable` is set to `no`, labels will not be applied for that resource type.



### [4.10] Configure deployment to support for tolerations 

- The configuration is used to specify the tolerations for crane and child resources. Switch the `enable` to `yes` and add tolerations for crane and & child resources. Add tolerations in a Json format as per the example:
```yaml
tolerationCrane: 
  enable: no
  syntax: [{ "effect": "NoSchedule", "key": "lifecycle", "operator": "Equal", "value": "spot" }]
tolerationExecutors: 
  enable: no
  syntax: [{ "effect": "NoSchedule", "key": "lifecycle", "operator": "Equal", "value": "spot" }]
```

**Note:** 
>- `tolerationCrane` is for tolerations declared for crane and `tolerationExecutors` is for tolerations declared for child resources.*



### [4.11] Configure deployment to support node selector for crane & child resources
- The configuration is used to specify the node selector for crane and child resources. Switch the `enable` to `yes` and add node selectors for crane and child resources. Add node selectors in a Json format as per the example:
```yaml
nodeSelectorCrane:
  enable: no
  syntax:  {"label_1": "label_1_value", "label_2": "label_2_value"}
nodeSelectorExecutor:
  enable: no
  syntax:  {"label_1": "label_1_value", "label_2": "label_2_value"}
```

**Note:** 
>- `nodeSelectorCrane` is for node selectors declared for crane and `nodeSelectorExecutor` is for node selectors declared for child resources.*



### [4.12] Configure resource limits and requests for Crane & child resources

You can specify CPU, memory, and ephemeral storage resource requests and limits for both the Crane deployment and its child resources. Use the `resourcesCrane` section for the main Crane deployment, and `resourcesExecutors` for child resources (executors/agents).

Add or update the following in your `values.yaml` file:

```yaml
# Resource requests and limits for the Crane deployment.
resourcesCrane:  
  requests:     
    CPU: 250m
    MEM: 512Mi 
    storage: 100      # Ephemeral storage in MB (optional)
  limits:
    CPU: 1            # Example: 1 core
    MEM: 2Gi
    storage: 1024     # Ephemeral storage in MB (optional)

# Resource requests and limits for child resources (executors/agents).
resourcesExecutors: 
  requests:           
    CPU: 1000m        
    MEM: 4096         # This value should be an integer (Mi), unlike other values that support k8s standard notation.
    storage: 100      # Ephemeral storage in MB (optional)
  limits:
    CPU: 2
    MEM: 8Gi
    storage: 1024
```

**Notes:**
>- `resourcesCrane` applies to the main Crane deployment.
>- `resourcesExecutors` applies to child resources created by the agent.
>- For `resourcesExecutors`, the `MEM` value should be an integer (in Mi), not a string (e.g., `4096` not `4096Mi`).
>- The `storage` field is optional and represents ephemeral storage in MB.
>- If you do not need to set resource limits or requests, you can omit these sections or leave them


### [4.13] Configure the Pod Disruption Budget

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

**Note:**
>- If you do not require a PDB, leave `enable` as `no`.



### [4.14] Configure SecretProviderClass

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
>- You can specify as many as you need in the same map/slice fashion. The chart is designed to loop over these items. 
>- The `parameters` and `secretObjects` fields should be customized based on your secrets provider and use case.
>- If you do not require SecretProviderClass integration, leave `enable` as `no`.



### [4.15] Configure ExternalSecrets Operator

The [ExternalSecrets Operator](https://external-secrets.io/) allows you to synchronize secrets from external secret management systems (such as AWS Secrets Manager or Google Cloud Secret Manager) into Kubernetes secrets. This integration is useful if you want your Crane deployment to automatically fetch and manage secrets from your external provider.

You can enable and configure the ExternalSecrets Operator for the Crane deployment by updating the following section in your `values.yaml` file:

- **Enable ExternalSecrets Operator**: Set `enable` to `yes` to activate the integration.
- **volume**: (Optional) Configure the volume name, mount path, and readOnly flag for mounting secrets.
- **externalSecret**: Configure the ExternalSecret resource:
  - `name`: Name of the ExternalSecret resource.
  - `refreshInterval`: How often the operator should refresh the secret.
  - `target.name`: Name of the Kubernetes Secret to create.
  - `data`: List of secrets to fetch, mapping `secretKey` (Kubernetes key) to `remoteRef.key` (external secret name) and `envName` (environment variable to populate).
- **secretStore**: Configure the SecretStore resource:
  - `name`: Name of the SecretStore.
  - `provider`: Configure your secrets provider (e.g., AWS or GCP).
    - **AWS**: Set `enable` for `aws` to `true`, specify `service` and `region`.
      - **authSecretRef**: (Optional) Use this if you want to authenticate to AWS using static credentials (not recommended for production).  
        - `accessKeyID`: Reference to a Kubernetes Secret containing your AWS access key ID.
        - `secretAccessKey`: Reference to a Kubernetes Secret containing your AWS secret access key.
        - If `authSecretRef.enable` is `false`, the chart will use the service account associated with the deployment (recommended).
    - **GCP**: Set `enable` for `gcpsm` to `true`, specify `projectID`.
      - **secretRef**: (Optional) Use this if you want to authenticate to GCP using a static service account key.
        - `secretAccessKeySecretRef`: Reference to a Kubernetes Secret containing your GCP credentials.
        - If `secretRef.enable` is `false`, the chart will use Workload Identity with the service account (recommended).

**Example configuration:**
```yaml
externalSecretsOperator:
  enable: yes
  volume: 
    name: 
    readOnly: 
    path: 

  externalSecret: 
    name: blaze-external-secret
    refreshInterval: "15s"
    target:
      name: blazemeter-secrets-store
    data:
      - secretKey: ship-id
        remoteRef:
          key: ship-id
        envName: SHIP_ID
      - secretKey: harbour-id
        remoteRef:
          key: harbour-id
        envName: HARBOR_ID
      - secretKey: auth-token
        remoteRef:
          key: auth-token
        envName: AUTH_TOKEN
  
  secretStore:
    name: blaze-secret-store
    provider:
      aws:
        enable: true
        service: SecretsManager
        region: ap-southeast-2
        # Optionally configure authentication using static credentials:
        authSecretRef:
          enable: false
#  ---- <Rest of the config> ----
```

**Notes:**
- Only enable the provider you intend to use (`aws` or `gcpsm`). For other providers (such as Azure), please contact support.
- The chart will use the service account associated with the deployment for authentication unless `authSecretRef` (AWS) or `secretRef` (GCP) is enabled.
- `authSecretRef` and `secretRef` allow you to reference Kubernetes secrets for static credentials, but using IAM roles (AWS) or Workload Identity (GCP) is recommended for production.
- The `data` section allows you to map external secrets to Kubernetes secrets and environment variables.
- If you do not require ExternalSecrets Operator integration, leave `enable` as `no`.
- For more details, see the [ExternalSecrets Operator documentation](https://external-secrets.io/).

---


## [5.0] Verify if everything is setup correctly

- Once the values are updated, please verify if the values are correctly used in the helm chart:

```sh
helm lint <path-to-chart>
helm template <path-to-chart>
```

This will print the template Helm will use to install this chart. Check the values and if something is missing, please make amends.

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

If you continue to encounter issues, please contact your cloud or DevOps team for assistance.

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

- 1.4.1 - Added default values for secret wildcard credential for test-hook. Fixed minor condition handling for istio-based test-hook role configuration. No changes to main chart functionality.
- 1.4.0 - Added support for Pod Disruption Budgets (PDB) and SecretProviderClass integration. Introduced ExternalSecrets Operator support. Addition of testHook for faster/accurate validation of installation. Simplified the image override usage. Incorporation of ingress setup & usage in one single config. Other minor bug fixes and template enhancements. Extended documentations on chart usage. 
- 1.3.1 - Readiness and Liveness probes are now added. 
- 1.3.0 - Chart can support image-override configuration. gridProxy is in working configuration. Resource (CPU & MEM) limit/requests are now configurable for crane and child resources and also for ephemeral storage. Simplified nesting and values configuration. The chart can now work with non-default serviceAccount. Tolerations, nodeSelector and labels can be declared for Crane and child resources separately, with Major fixes & calibrations.
- **Anything below 1.3.0 - UNSUPPORTED**
