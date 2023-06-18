#!/bin/bash
##############################
# Cloudflare API key
CLOUDFLARE_EMAIL1="XXXXXXXXXXXX@gmail.com"

# Cloudflare Email
CLOUDFLARE_API_KEY1="XXXXXXXXXXXXXXX-XXXXXXX-XXXXXXXXXXXXXXXXXX"

#Comaptybility with bash 3

#Array doman:proxied true or false
ARRAY=("d1.example.com:false"
        "example.com:true"
        "nas.example.com:false" )
################################

CURRENT_IP=$(curl -s https://ipinfo.io/ip)

cloud_flare_fun() {
  DOMAIN=$1
  CLOUDFLARE_API_KEY=$2
  CLOUDFLARE_EMAIL=$3
  PROXIED=$4
  ZONE=$(echo ${DOMAIN} | awk -F. '{if (NF>2) {print $(NF-1)"."$NF} else {print}}')
  

  # Get the zone id for the domain
  ZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=${ZONE}" -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" -H "Authorization: Bearer ${CLOUDFLARE_API_KEY}" -H "Content-Type: application/json" | jq -r '.result[].id')

  # Get the current DNS IP record from Cloudflare
  DNS_RECORD=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${DOMAIN}" -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" -H "Authorization: Bearer ${CLOUDFLARE_API_KEY}" -H "Content-Type: application/json" | jq -r '.result[].content')

  # If the public IP is not the same as the DNS IP, update the DNS record
  if [ "$CURRENT_IP" != "$DNS_RECORD" ]; then
    #echo "changing $DNS_RECORD to $CURRENT_IP " |  systemd-cat -p info
    RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${DOMAIN}" -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" -H "Authorization: Bearer ${CLOUDFLARE_API_KEY}" -H "Content-Type: application/json" | jq -r '.result[].id')
    
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${RECORD_ID}" \
      -H "X-Auth-Email: ${CLOUDFLARE_EMAIL}" \
      -H "Authorization: Bearer ${CLOUDFLARE_API_KEY}" \
      -H "Content-Type: application/json" \
      --data '{"type":"A","name":"'${DOMAIN}'","content":"'${CURRENT_IP}'","ttl":120,"proxied":'${PROXIED}'}' | jq
 # else
  #echo "nothing to do" |  systemd-cat -p info 
  fi
}

# Array of commands to check
commands=("curl" "awk" "jq")

# Iterate over the commands and check if they are installed
for command in "${commands[@]}"; do
  if ! command -v $command &>/dev/null; then
    echo "$command could not be found, please install it."
    exit 1
  fi
done

echo "All required tools are installed."

for cloudy in "${ARRAY[@]}" ; do
    KEY="${cloudy%%:*}"
    VALUE="${cloudy##*:}"
    printf "%s proxies to %s.\n" "$KEY" "$VALUE"
    cloud_flare_fun ${KEY} ${CLOUDFLARE_API_KEY1} ${CLOUDFLARE_EMAIL1} ${VALUE}
   

done

 
