# Orchestra

## Description

Orchestra will create an example static site hosted on AWS using S3 and Cloudfront. The tool is split into 2 parts:
1. `orchestra.sh` will create an S3 bucket and CDN distribution to upload a static site to
2. `deployBlog.sh` will create and upload a static site generated using [Hugo](https://gohugo.io)

## Requirements
* [awscli](https://aws.amazon.com/cli/)
* [hugo](https://gohugo.io)
* A domain name with access to it's DNS records


## Usage

0. Configure awscli with `aws configure`
1. In both `.sh` files, edit the `YOUR_DOMAIN` variable at the top of the files with your desired domain or subdomain
2. Run `./orchestra.sh`  (Create the DNS records stated in the output)
3. Run `./deployBlog.sh`
4. After DNS records and CDN files have propogated, visit `https://yourdomain.com`

## Screenshots

### orchestra.sh
![orchestra](https://user-images.githubusercontent.com/3712226/48677330-e192f280-eb38-11e8-963f-2e5622e70ea5.png)

### deployBlog.sh
![deployblog](https://user-images.githubusercontent.com/3712226/48677329-e192f280-eb38-11e8-98bf-c377b6dd1631.png)

### Site
![site](https://user-images.githubusercontent.com/3712226/48677430-97127580-eb3a-11e8-875d-de1b0825bd0c.png)

## License
MIT

## Credits
The idea for this tool came from [this post](https://lustforge.com/2016/02/27/hosting-hugo-on-aws/) and much of the code is the same.
