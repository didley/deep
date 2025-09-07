REGION   ?= ap-southeast-2

APP := ingress_lambda
ZIP_DIST := dist/zip

deploy: publish-lambda
build:
	pnpm build
zip: build
	rm -rf $(ZIP_DIST) && mkdir -p $(ZIP_DIST) && cd dist/js && zip -r ../zip/$(APP).zip . && cd ../..
publish-lambda: zip
	aws lambda update-function-code \
	  --function-name $(APP) \
	  --zip-file fileb://dist/zip/$(APP).zip \
	  --region $(REGION) \
	  --no-cli-pager 
