## Introduction
Welcome to the simple go web app!
Theres a couple of things you will need to do before you can deploy this application.

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
