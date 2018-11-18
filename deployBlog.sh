####################################
#				   #
#	      CONFIG		   #
#				   #
####################################

YOUR_DOMAIN=""


####################################
#				   #
#	   DONT TOUCH		   #
#				   #
####################################

BASKET='\U1F5D1\UFE0F  '
CHECKMARK='\U2705  '
PACKAGE='\U1F4E6  '
HAMMER='\U1F6E0\UFE0F  '


BUCKET_NAME="${YOUR_DOMAIN}-cdn"

printf "${PACKAGE}"
echo "Cloning packages locally..."

git clone https://github.com/sa7mon/academic-kickstart.git blog
cd blog/
git submodule update --init --recursive

printf "${CHECKMARK}"
echo "Done!"
echo ""

printf "${HAMMER}"
echo "Building static site..."

hugo

printf "${CHECKMARK}"
echo "Done!"
echo ""

printf "${BASKET}"
echo "Uploading public site files to S3 bucket..."
aws s3 sync --acl "public-read" public/ s3://${BUCKET_NAME} --exclude 'post' --only-show-errors

printf "${CHECKMARK}"
echo "Done!"
echo ""


# aws cloudfront list-distributions --output text --query "DistributionList.Items[].{DomainName: DomainName, Id: Id, OriginDomainName: Origins.Items[0].DomainName}[?contains(OriginDomainName, '${YOUR_DOMAIN}')] | [0].Id"
