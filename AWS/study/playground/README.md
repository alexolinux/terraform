# AWS Playground

---

## About this lab

playground is a continuous lab. The idea is growing gradually according to the creation of resources (step-by-step).

It is being used for studying.

### Current project

- vpc

#### Terraform - UP and Running

##### AWS Profile

- [Configure your AWS Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

  - Configure AWS Profile

  ```shell
  aws configure --profile playground
  ```

  Example of Output:

  ```txt
  AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
  AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
  Default region name [None]: us-east-1
  Default output format [None]: json
  ```

  > *Use the same region name of terraform region variable.*

  - Using named profile

  ```shell
  export AWS_PROFILE=playground
  ```

  - Testing

  ```shell
  aws sts get-caller-identity
  ```

  Example of Output:

  ```json
  {
    "UserId": "AKIAIOSFODNN7EXAMPLE",
    "Account": "12345670987653210",
    "Arn": "arn:aws:iam::12345670987653210:user/aws_someuser"
  }
  ```
  
##### Using Terraform

- Go to the project resources folder and execute the following commands:

```shell
  terraform init
  terraform validate
  terraform plan
  terraform apply
```

  - init: Start Terraform Provider
  - validate: terraform validation code
  - plan: simulate a provision
  - apply: provision target resources

##### Ok, but... How to delete at ALL?


- No worries. Run the following command:

```shell
  terraform destroy -auto-approve
```

> For more details: Access this **[link](https://developer.hashicorp.com/terraform/cli/run)**

---

To Be continued