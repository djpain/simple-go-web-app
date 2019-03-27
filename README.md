## Introduction
Welcome to the simple go web app!
Theres a couple of things you will need to do before you can deploy this application. Inspiration for this came from https://github.com/grisha/hello-go-ecs-terraform 

## prerequisites

firstly you will need to make sure you have your awscli application installed and configured for ap-southeast-2 and authenticated your docker to ECR. [Check this url for a how to.](https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_AWSCLI.html#AWSCLI_get-login)

Once you are ready lets create the container repository
```
aws ecr create-repository --repository-name $appname
```
This command will create the docker repository for you. You will need to change "$appname" to what ever you will like to call you application.

Now we build the container. So go into the root directory for this project and run the following command
```
docker build -t simple-go-web-app:latest .
```
This will build the docker image and set the "simple-go-web-app:latest" tag to the container.

Next we will need to set the ECR tag to the image where "your-ecr-url" should be outputed in the create repository command part.
```
docker tag simple-go-web-app:latest <your-ecr-url>/simple-go-web-app:latest
```

Once done you will then need to push your image to ECR
```
docker push <your-ecr-url>/simple-go-web-app:latest  
```

## terraform deploy

make sure you are in the tf directory and have run `terraform init` to import the required modules.

Once ready we can run a TF plan to see whats created
```
terraform plan -var key_name=$keyname -var dockerimg=<ecr-registry>/simple-go-web-app:latest -input=false -out=plan
```
once completed you will see that your app is up and running

##TODO
- verify that app runs correctly on ecs
- setup code build and code deploy to build the docker container and deploy TF
- use docker-compose.yml as a starting base to add DB support to the app. Use something like https://github.com/jinzhu/gorm to log User-Agent	header
