first 
git clone https://github.com/spq/pkappa2

need to install docker !!!
```
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release -y

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

docker compose version

under /home/xxx
**/pkappa2**$ sudo docker compose up
```

final build and up (required high memory)
```
export NODE_OPTIONS="--max-old-space-size=1024"
sudo -E docker compose build
sudo docker compose up -d
```

run dumper 
set interval time 300 = 5 minutes 
```
~/pcap_uploader/tcpdump.sh
~/pcap_uploader/tcpdump_complete.sh

only run tcpdump.sh
```

access from 
http://38.180.243.176:8080/#/
ray ray

my pcap capture folder 
```
mkdir -p ~/pcap_uploader/pcaps
chmod 700 ~/pcap_uploader/pcaps
cd ~/pcap_uploader
```

the process 
1. every 5 min tcpdump will dump packet from service (5000, 8000)
2. then save under pcap_uploader/pcaps
3. then thru curl --data-binary @some-file.pcap http://localhost:8080/upload/some-file.pcap to upload file 
4. can see in dashboard xxx:8080
