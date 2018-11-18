# Orchestra

## Requirements
* [awscli](https://aws.amazon.com/cli/)
* A domain name with access to it's DNS records


## Usage

0. Configure awscli with `aws configure`
1. In both `.sh` files, edit the `YOUR_DOMAIN` variable with your desired domain or subdomain
2. Run `./orchestra.sh`  (Create the DNS records stated in the output)
3. Run `./deployBlog.sh`
4. After DNS records and CDN files have propogated, visit `https://yourdomain.com`
