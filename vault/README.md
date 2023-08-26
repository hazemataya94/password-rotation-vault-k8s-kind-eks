# HashiCorp Vault

## Vault Admin Manual
https://innoscripta.atlassian.net/wiki/spaces/DEV/pages/212172801/HashiCorp+Vault+-+Admin+Manual

## Vault Deployment Diagram
<p align="center">
  <img src="./deployment-diagram.jpg" width="600" alt="Vault Deployment">
</p>

## Helm Chart
https://github.com/hashicorp/vault-helm<br />
The vault helm chart is set as a dependency subchart in Chart.yaml.<br />
Run `helm dependency build` or `helm dependecy update` to install the dependency chart before deploying the helm chart. All default vaules are set in https://github.com/hashicorp/vault-helm/blob/main/values.yaml.<br />

The chart is deployed in EKS, **inno-dev cluster**, **vault namespace**, **ng-vault node group**. Node group configuration can be found here: https://git.innoscripta.com/devops/iac/aws-eks/-/blob/main/inno-dev/inno-dev-cluster.yaml.<br />

Node selector **environment: vault** is provided in hc-vault/values.yaml to deploy the pods on ng-vault node group in inno-dev cluster, which is created only for the vault.<br />

AWS User is provided to access AWS KMS (autounseal), the user tokens are provided in **vault secret** in vault namespace. Check hc-vault/values.yaml, vault.server.ha.config value to see how it's configured.<br />

For the audit logs, a persistent volume claim created in vault namespace. hc-vault/pvc.yaml contains the claim, and the mound can be found in hc-vault/values.yaml  vault.server.volumes and vault.server.volumeMounts.<br />

## Storage (Database)
MySQL is used as a backend storage for Vault, and only audit logs are written on a volume. Check hc-vault/values.yaml, vault.server.ha.config for the configuration.<br />

## Vault Setup Secrets
All the secrets used to setup the Vault can be found in AWS Secret Manager, region eu-central-1 (Frankfurt), with the name vault_keys_and_database https://eu-central-1.console.aws.amazon.com/secretsmanager/home?region=eu-central-1#!/listSecrets/.<br>

To show the values, go to secret details, then in "Secret value" section click on "Retrieve secret value". The secret contains the unseal keys, vault root token, vault AWS user, and mysql instance root user.<br />

## Backup
Vault MySQL RDS is configured to have daily backups, and additional backup script is also created to backup the data and upload it to S3 bucket: inno-vault-backup. The S3 backups are created using the hc-vault/templates/cronjob.yaml, configured in hc-vault/vaules.yaml cronjob. The docker image is in backup/Dockerfile, and pushed to ECR in 9xxxxxxx.dkr.ecr.eu-central-1.amazonaws/vault:backup.<br />

The cronjob runs a pod which uses vault secret to access the mysql backend and S3 bucket, and the pod has the audit log volume mounted in it. The cronjob runs the script in backup/backup.sh, which exports the database and uploads it to s3://inno-vault-backup/database, and compresses the logs and upload them to s3://inno-vault-backup/auditlog, then empties the audit logs (as a kind of log rotation).<br />

## Enable Audit Log
After the helm chart is deployed, access one of the vault pods and execute:<br />
```
vault login VAULT_ROOT_TOKEN && vault audit enable file file_path=/vault/audit/vault_audit.log
```

## Disaster Recovery
In case of any incident, e.g. secrets are deleted, or overwritten by mistake, or the helm chart stopped working, then:<br />
- Go to the S3 bucket, and download the latest backup of vault database.
- Import the latest backup to a MySQL database using one of the following methods:
  - Use the existing Vault RDS:
    - Login as root user, use vault database, drop all tables, then import the SQL file in vault database.
  - Use a new Vault RDS:
    -  Go to the existing Vault RDS in AWS Console, go to "Maintenance & backups" tab, choose a backup and restore it in a new RDS instance. Then go to hc-vault/values vault.server.ha.config and make sure to change the MySQL host.
    - Create a new MySQL RDS, login as root user, create vault database, create vault user and give full access to vault database. Then Import the SQL file into the vault database. Then go to hc-vault/values vault.server.ha.config and make sure to change the MySQL configurations.
- After the database is restored, restart the helm chart, or redeploy it, or deploy a new helm chart. As long as the same database is used, the deployment won't make much difference.

## Import Secrets
To import bulks of secrets into the vault, which was the case when the deployment is created, a Python script was created to read the secrets from a CSV file and upload them to Vault using hvac library. The script can be found in import-secrets directory.<br />

The CSV file defines the secret, and the template is in import-secrets/vault-passwords.csv, the first two columns are essential. The first column "engine" is the name of the key/value secret engine created in vault, the engine must exist and must be created before the script runs. the second column "path" defines the path of the inside the secrets engine. The rest of the columns are the data included inside the secret, where the name of the column will be the key, and the data in the cell will be the value. The names can be changed, but make sure that the used format can be imported in valut as the script doesn't modify the names.<br />

Any empty row in the CSV file will be ignored. And for any empty cell the script will ignore the respective column (key). The provided template in import-secrets/vault-passwords.csv shows how it was used to import the credentials the first time.<br />

The script is tested on MacOS, Python 3.9.9.<br />

To run the script, make sure to prepare the CSV file, then pip install the import-secrets/requirements.txt, then go to import-secrets/main.py to configure the script. The configuration parameters are defined in the beginning of the main function:<br />
- CSV_FILE_PATH: relative or absolute path to the CSV file which contains the secrets to import.
- VAULT_ADDRESS: the http link to vault.
- VAULT_TOKEN: vault user token, can use root token for full access.
- OVERRIDE_EXISTING_VALUES: if the value is False, then the script will ignore the paths (secrets) that already exist, and will print a message with these paths (secrets). Otherwise if the vlaue is True, then the script will update the secret in case the "path" already exist in the "engine". This can lead to some errors in case it wasn't used carefully, so make sure the paths and values are correct before using this power. And in both cases the new secrets will be created.<br />

Once the CSV file is ready and main.py is modified, run main.py to import the secrets.<br />
