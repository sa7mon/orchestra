#####################################
#                                   #
#           CONFIGURATION           #
#                                   #
#####################################

YOUR_DOMAIN=""
REGION="us-east-1"


#####################################
#                                   #
#	   HERE BE DRAGONS	    #
#	   - DON'T TOUCH -	    #
#		                    #
#####################################

# Important things
BUCKET_NAME="${YOUR_DOMAIN}-cdn"
LOG_BUCKET_NAME="${BUCKET_NAME}-logs"

# Not so much
BASKET='\U1F5D1\UFE0F  '
CHECKMARK='\U2705  '
LOCK='\U1F512  '
WARNING='\U26A0\UFE0F  '
EARTH='\U1F30E  '
CLOCK='\U1F552  '


START=`date "+%Y-%m-%d %H:%M:%S"`

printf "${CLOCK}"
echo "Starting at: ${START}"
echo ""

## Create a new bucket

printf "${BASKET}"
echo "Creating new bucket..."

aws s3 mb s3://$BUCKET_NAME --region $REGION
# aws s3 mb s3://$LOG_BUCKET_NAME --region $REGION

printf "${CHECKMARK}"
echo "Done!"
echo ""


printf "${BASKET}"
echo "Configuring bucket..."

aws s3api put-bucket-website --bucket $BUCKET_NAME --website-configuration file://website.json

# Create bucket policy
echo "{
    \"Version\": \"2008-10-17\",
    \"Id\": \"PolicyForPublicWebsiteContent\",
    \"Statement\": [
        {
            \"Sid\": \"PublicReadGetObject\",
            \"Effect\": \"Allow\",
            \"Principal\": {
                \"AWS\": \"*\"
            },
            \"Action\": \"s3:GetObject\",
            \"Resource\": \"arn:aws:s3:::$BUCKET_NAME/*\"
        }
    ]
}" > bucketPolicy.json

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucketPolicy.json

printf "${CHECKMARK}"
echo "Done!"
echo ""

printf "${LOCK}"
echo "Requesting SSL certificate..."

TOKEN=`date +%s`
CERT_ARN=`aws acm request-certificate --domain-name $YOUR_DOMAIN --subject-alternative-names "www.$YOUR_DOMAIN" --validation-method DNS --idempotency-token "$TOKEN" --output text`

printf "${WARNING}"
echo "An SSL certificate was requested - you must now manually get the required DNS validation CNAME records from AWS Certificate Manager and create them."
printf "${WARNING}"
echo "This script will automatically continue after DNS validation has succeeded. You have 40 minutes until this script times out"

aws acm wait certificate-validated --certificate-arn $CERT_ARN

printf "${CHECKMARK}"
echo "Done!"
echo ""

printf "${EARTH}"
echo "Creating CDN (CloudFront) distribution..."

CALLER_REF="`date +%s`" # current second
echo "{
    \"Comment\": \"$BUCKET_NAME Static Hosting\",  
    \"Origins\": {
        \"Quantity\": 1,
        \"Items\": [
            {
                \"Id\":\"$BUCKET_NAME-origin\",
                \"OriginPath\": \"\", 
                \"CustomOriginConfig\": {
                    \"OriginProtocolPolicy\": \"http-only\", 
                    \"HTTPPort\": 80, 
                    \"OriginSslProtocols\": {
                        \"Quantity\": 3,
                        \"Items\": [
                            \"TLSv1\", 
                            \"TLSv1.1\", 
                            \"TLSv1.2\"
                        ]
                    }, 
                    \"HTTPSPort\": 443
                }, 
                \"DomainName\": \"$BUCKET_NAME.s3-website-$REGION.amazonaws.com\"
            }
        ]
    }, 
    \"DefaultRootObject\": \"index.html\", 
    \"PriceClass\": \"PriceClass_100\", 
    \"Enabled\": true, 
    \"CallerReference\": \"$CALLER_REF\",
    \"DefaultCacheBehavior\": {
        \"TargetOriginId\": \"$BUCKET_NAME-origin\",
        \"ViewerProtocolPolicy\": \"redirect-to-https\", 
        \"DefaultTTL\": 1800,
        \"AllowedMethods\": {
            \"Quantity\": 2,
            \"Items\": [
                \"HEAD\", 
                \"GET\"
            ], 
            \"CachedMethods\": {
                \"Quantity\": 2,
                \"Items\": [
                    \"HEAD\", 
                    \"GET\"
                ]
            }
        }, 
        \"MinTTL\": 0, 
        \"Compress\": true,
        \"ForwardedValues\": {
            \"Headers\": {
                \"Quantity\": 0
            }, 
            \"Cookies\": {
                \"Forward\": \"none\"
            }, 
            \"QueryString\": false
        },
        \"TrustedSigners\": {
            \"Enabled\": false, 
            \"Quantity\": 0
        }
    }, 
    \"ViewerCertificate\": {
        \"SSLSupportMethod\": \"sni-only\", 
        \"ACMCertificateArn\": \"$CERT_ARN\", 
        \"MinimumProtocolVersion\": \"TLSv1\", 
        \"Certificate\": \"$CERT_ARN\", 
        \"CertificateSource\": \"acm\"
    }, 
    \"CustomErrorResponses\": {
        \"Quantity\": 2,
        \"Items\": [
            {
                \"ErrorCode\": 403, 
                \"ResponsePagePath\": \"/404.html\", 
                \"ResponseCode\": \"404\",
                \"ErrorCachingMinTTL\": 300
            }, 
            {
                \"ErrorCode\": 404, 
                \"ResponsePagePath\": \"/404.html\", 
                \"ResponseCode\": \"404\",
                \"ErrorCachingMinTTL\": 300
            }
        ]
    }, 
    \"Aliases\": {
        \"Quantity\": 2,
        \"Items\": [
            \"$YOUR_DOMAIN\", 
            \"www.$YOUR_DOMAIN\"
        ]
    }
}" > distroConfig.json

aws cloudfront create-distribution --distribution-config file://distroConfig.json --query 'Distribution.ARN'

printf "${CHECKMARK}"
echo "Done!"
echo ""

END=`date "+%Y-%m-%d %H:%M:%S"`

printf "${CLOCK}"
echo "Ended at: ${END}"
echo ""
