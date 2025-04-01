This assumes that you have installed Terraform and configured your GCP credentials.

## Workspaces
1. Create the workspaces
    ```
    terraform workspace new Dev
    terraform workspace new Prd
    terraform workspace new Stg
    ```
1. List all workspaces
    ```
    terraform workspace list
    ```
    You should see 4 workspaces, the 3 newly created and the default workspace

1. Select the workspace that you would like to work with
    ```
    terraform workspace select Dev
    ```

## Deployment
1. Clone this repo.
1. if needed, update the code for the cloud function under:  `function_code/`
1. Create a zip file named `function_source.zip`, containing the content of the cloud fucntion.
    ```
    zip -r function_source.zip function_code/
    ```
1. Verify the workspace that you would like to deploy to.
    ```
    terraform workspace show
    ```
    * If workspace `Dev` is not selected, selected with the following command:
    ```
    terraform workspace select Dev
    ```

1. Initialize the Terraform Project:
    ```
    terraform init -upgrade
    ```
1. Review the Configuration Plan:
    ```
    terraform plan -var-file="tfvars/dev.tfvars"
    ```
1. Apply the Configuration:
    ```
    terraform apply -var-file="tfvars/dev.tfvars"
    ```
    Type `yes` when prompted to confirm the operation.

1. Verify the Resource on the Google Cloud Console or
    ```
    terraform show
    ```

## Destroy
1. Destroy resources when no longer neeeded.
    ```
    terraform destroy
    ```
