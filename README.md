# Test 1 DevOps
* Create Terraform code to create a AWS S3 bucket with two files: test1.txt and test2.txt. The content of these files must be the timestamp when the code was executed.
* Using Kitchen Terraform, create the script to automate the testing for the Terraform code, validating that both files and the bucket are created successfully.

## Pre-requisites

* [Terraform](https://www.terraform.io/) in the versions interval of >= 0.11.4, < 0.13.0 
* [Kitchen-Terraform](https://github.com/newcontext-oss/kitchen-terraform)
* [Ruby](https://www.ruby-lang.org/en/) in the versions interval of >= 2.4, < 2.7
* [Bundler](https://bundler.io/index.html#getting-started) should be used to manage versions of Kitchen-Terraform on the system.
* You must have an [Amazon Web Services (AWS) account](http://aws.amazon.com/).

Note that this configuration was executed in a Linux Ubuntu machine, nonetheless, it can be easily ported to Windows.

## Installation

### Terraform
Kitchen-Terraform integrates with the
[Terraform command-line interface](https://www.terraform.io/docs/commands/index.html) to implement a Test
Kitchen workflow for Terraform modules.

Installation instructions can be found in the
[Install Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) article.

Kitchen-Terraform supports versions of Terraform in the interval of
`>= 0.11.4, < 0.13.0`.

[tfenv] can be used to manage versions of Terraform on the system.

### Ruby

Kitchen-Terraform is written in [Ruby](https://www.ruby-lang.org/en/) which requires an
interpreter to be installed on the system.

Installation instructions can be found in the
[Ruby: Installing Ruby](https://www.ruby-lang.org/en/documentation/installation/) article.

Kitchen-Terraform aims to support all versions of Ruby that are in
["normal" or "security" maintenance](https://www.ruby-lang.org/en/downloads/branches/), which is currently
the interval of `>= 2.4, < 2.7`.

#### Bundler
After Ruby is installed run
```$ gem install bundler```

### AWS
Configure your [AWS access keys](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) as
environment variables:
```
export AWS_ACCESS_KEY_ID=(your access key id)
export AWS_SECRET_ACCESS_KEY=(your secret access key)
```
## Quick Start

### Configure and Test

```
$ git clone https://github.com/cesaramaya-flugel/test1.git
$ cd test1
$ bundle install

# Run terraform testing module
$ bundle exec kitchen converge

# Run validation test
$ bundle exec kitchen verify

# Don't forget to destroy created resources
$ bundle exec kitchen destroy
```

### Deploy AWS Resources with Terraform 

#### S3 Bucket Name
If you want to change the default S3 backet name, edit the variables.tf file and set the default to the desired name.
```
variable "bucket_name" {
  default = "flugel-test1-bucket"
}
```

#### Execute Terraform
```
terraform init
terraform apply

```

When the `apply` command completes, you should see the name of the bucket created, for instance:

```
Outputs:

bucket_id = flugel-test1-bucket
```

Clean up when you're done:

```
terraform destroy
