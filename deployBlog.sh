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

BUCKET_NAME="${YOUR_DOMAIN}-cdn"

git clone https://github.com/sa7mon/academic-kickstart.git blog
cd blog/
git submodule update --init --recursive
hugo

aws s3 sync --acl "public-read" blog/public/ s3://${BUCKET_NAME} --exclude 'post'

# aws cloudfront list-distributions --output text --query "DistributionList.Items[].{DomainName: DomainName, Id: Id, OriginDomainName: Origins.Items[0].DomainName}[?contains(OriginDomainName, '${YOUR_DOMAIN}')] | [0].Id"
