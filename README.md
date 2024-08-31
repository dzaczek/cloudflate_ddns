![Header Image](https://github.com/dzaczek/cloudflate_ddns/blob/main/header.png?raw=true)

# Bash script for updating Cloudflare DNS records

This script is used to update DNS records on Cloudflare. It gets the current public IP of the server where it's running and updates the DNS records of the specified domains on Cloudflare.
(The best options when your provider doesn't give you a static IP, working like DynDNS for Cloudflare.)
## Prerequisites

The script requires the following tools to be installed on your system:

- `curl`: Used to send requests to the Cloudflare API.
- `awk`: Used to manipulate strings.
- `jq`: Used to parse JSON responses from the Cloudflare API.

Before running the script, ensure these tools are installed on your system.

## Configuration

You need to specify the following variables in the script:

- `CLOUDFLARE_EMAIL1`: Your Cloudflare account email.
- `CLOUDFLARE_API_KEY1`: Your Cloudflare API key.
- `ARRAY`: An array of domains you want to update the DNS records for. Each element should be in the format `domain:proxied`, where `domain` is your domain and `proxied` is either `true` or `false` depending on whether you want the domain to be proxied through Cloudflare.

Example:

```bash
ARRAY=("d1.example.com:false"
        "example.com:true"
        "nas.example.com:false" )
```
Usage
To run the script, simply execute it with bash:

```bash

bash cfddns.sh
```
The script will then do the following for each domain specified in the ARRAY:

Get the zone ID of the domain from Cloudflare.
Get the current DNS A record of the domain from Cloudflare.
Compare the current public IP of the server with the DNS A record. If they are not the same, it will update the DNS A record on Cloudflare with the current public IP of the server.
