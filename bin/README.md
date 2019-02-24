deploy-aws       : deploy a local docker image to AWS ECR
deploy-az        : deploy a local docker image to Azure
aws-deploy-layer : deploy a previously job2lambda processed Talend zip file from an S3 bucket as an AWS Lambda Layer
job2docker       : convert a Talend Job zip file to a local docker image
job2lambda       : process a Talend Job zip file to a Lambda ready zip file
package          : use tcf-package::talend_packager to create a docker ready zip file
tcf-package.sh   : library of shell functions for packaging Talend jobs
tcf-env.sh       : initialize Talend Cloud factory environment
