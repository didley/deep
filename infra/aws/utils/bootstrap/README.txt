bootstrap.zip

What is it?
    It's a minimal Lambda zip used for the initial creation of Lambdas by Terraform when it is only 
    handling the resource creation and not the deployment. Lambda requires an artifact for the resource creation.\


How is it created?
    echo 'exports.handler = async () => ({statusCode:200, body:"ok"});' > index.js
    zip bootstrap.zip index.js