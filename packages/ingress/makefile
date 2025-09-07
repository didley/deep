APP      ?= ingress_package
BUCKET   ?= ingress-package-lambda
REGION   ?= ap-southeast-2
FUNCTION_NAME ?= IngressPackage

ZIP_DIST := dist/zip
ZIP      := $(APP).zip

deploy: publish-s3
build:
	pnpm build
zip: build
	rm -rf $(ZIP_DIST) && mkdir -p $(ZIP_DIST) && cd dist/js && zip -r ../zip/$(ZIP) . && cd ../..
s3: zip
	aws s3 cp $(ZIP_DIST)/$(ZIP) s3://$(BUCKET)/$(ZIP) --region $(REGION)
publish-s3: s3
	aws lambda update-function-code \
	  --function-name $(FUNCTION_NAME) \
	  --s3-bucket $(BUCKET) \
	  --s3-key $(ZIP) \
	  --region $(REGION) \
	  --no-cli-pager 
