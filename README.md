<p align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img width="946" alt="Ciberseguridad" src="https://user-images.githubusercontent.com/46871300/125079966-38ef8380-e092-11eb-9b5e-8bd0314d9274.PNG">
  </a>
 
   <h3 align="center">Implementacion de SOC con herramientas Open Source</h3>

  <p align="center">
    Proporcionamos los primeros pasos a los nuevos equipos de manejo de incidentes.
    <br />
    <a href="https://github.com/othneildrew/Best-README-Template"><strong>Explora la guia »</strong></a>
    <br />
    <br />
  </p>
</p>


# Install Guide & Build Instructions

This setup guide will show you how to create your **ElasticXDR** Platform.

I have listed some install steps below to help you re-create the same install build that I created. This will be a simple install out-of-box deployment.

## System Requirements

- **8GB - 12GB Memory**
- **2CPU Processors**
- **Ubuntu** 20.04.3 LTS Linux distribution.
- **Java** 8
- **Git repository**
- **Elastic repository** 
- **kibana repository**
- **David Walden repository**
- **Putty or SSH Terminal**

## Prerequisitis

- **An enterprise Cloudflare account (required to use the log API)
- **Your API email address and key (found on your Cloudflare profile page)

## Ubuntu 20.04.3 LTS Linux Distribution

 First we need to install ubuntu, this can be on a VMware or Oracle VirtualBox setup. Or if you have the physical hardware to spare that will work as well.

**Note:** Just make sure you have SSH access enabled once the server install is completed and know the IP address of the machine. Or that you can login through the GUI and open a Terminal.

**Note:** To configure a static IP address on your Ubuntu 20.04 LTS server you need to modify a relevant netplan network configuration file within **/etc/netplan/** directory.



~~~
cd /etc/netplan/
~~~

- Now install Networking Tool:

~~~
sudo apt install net-tools -y
~~~


Once that is done, now we will need to look for our interface name. Remember to copy that Interface name, you will need it later.

- Display network info:

~~~
ifconfig -v
~~~


Look for your interface name mines was **enp1s0** and change your values to match your network card info.

- You should see a file like this one after you list the directory contents:

~~~
00-installer-config.yaml
~~~

- Now edit this file:

~~~
sudo nano 00-installer-config.yaml
~~~

Just copy and modify the contents with your data below, then paste it back in and save with CTRL + x.

- Configure a static IP address:

~~~
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
     dhcp4: no
     addresses: [192.168.0.25/24]
     gateway4: 192.168.0.1
     nameservers:
       addresses: [8.8.8.8,8.8.4.4]
~~~

- Once that is done restart services:

~~~
sudo netplan apply
~~~

***Note:*** This will disconnect you from the server!

- In case you run into some issues execute:

~~~
sudo netplan --debug apply
~~~

- Remember your new IP assignement!

## Installation of System Components

The Elastic Stack requires Java 8 to be installed.

- Before we install our ElasticXDR, we will need to update our Ubuntu Server first.
- Open a Terminal or SSH connection and login and type this commands.

~~~
sudo apt-get update && sudo apt-get upgrade -y
~~~ 

- Once that is done perform a Distro upgrade to finish last few upgrades.

~~~
sudo apt-get dist-upgrade -y
~~~

- Now lets reboot the system and finish our deployment:

~~~
sudo reboot
~~~

## Login and finish the **Setup Process.**

- Install java Version 8:

~~~
sudo apt-get install openjdk-8-jdk -y
~~~

- Setting JVM options

~~~
nano /etc/elasticsearch/jvm.options
~~~

-Xms2g
-Xmx2g

Now lets add the Elastic Repos into our system!

+ Add Elastic Repository:
~~~
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
~~~

The system should respond with OK.

- Next, install the apt-transport-https package:

~~~
sudo apt-get install apt-transport-https -y
~~~

- Now add the Elastic repository to your system’s repository list:
~~~
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
~~~

- Prior to installing Elasticsearch, update the repositories by entering:

~~~
sudo apt-get update -y
~~~

- Install Elasticsearch with the following command:

~~~
sudo apt-get install elasticsearch -y
~~~

- Do a systemctl daemon reload.
~~~
sudo systemctl daemon-reload
~~~

## Configure Elasticsearch

Elasticsearch uses a configuration file called **.yml** to control how it behaves. Open the configuration file in a text editor of your choice either nano or vi.
 **We will be using nano**:

~~~
sudo nano /etc/elasticsearch/elasticsearch.yml
~~~

- You should see a configuration file with several different entries and descriptions. Scroll down to find the following entries:

~~~
cluster.name: my-application
network.host: localhost
http.port: 9200
~~~

- Uncomment the lines by deleting the hash (#) sign at the beginning of both lines and replace **localhost** with you ip address and cluster name.

~~~
cluster.name: ElasticXDR
network.host: 192.168.0.25
http.port: 9200
~~~

- Just below, find the **"Discovery.Type"** section. We are adding one more line, as we are configuring a single node **ElasticXDR** then save with CTRL + x:

~~~
discovery.type: single-node
~~~

- Start the Elasticsearch service by running a systemctl command:


~~~
sudo systemctl start elasticsearch.service
~~~

- Now verify that the service is running:
~~~
sudo service elasticsearch status
~~~

This may take some time for the serivce to run and verify, but once it does we will need to check that it is installed.

- Type this command in your browser:
~~~
http://XDR_ip_address_here:9200
~~~

Once you hit enter you shoud see something like this:

```json
{
  "name" : "xdr",
  "cluster_name" : "ElasticXDR",
  "cluster_uuid" : "I2EDGxkoRD27wvVsGSFEyA",
  "version" : {
    "number" : "7.14.1",
    "build_flavor" : "default",
    "build_type" : "deb",
    "build_hash" : "66b55ebfa59c92c15db3f69a335d500018b3331e",
    "build_date" : "2021-08-26T09:01:05.390870785Z",
    "build_snapshot" : false,
    "lucene_version" : "8.9.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}

```

This means that the system in running Elasticsearch and it has been installed. Now lets enable it to run on boot.

- Enable Elasticsearch to start on boot:

~~~
sudo systemctl enable elasticsearch.service
~~~

- You can also test Elasticsearch by running this command:

~~~
curl –X GET "192.168.0.25:9200"
~~~

- Now that we have Elasticsearch install and running, lets install Kibana.

## Configure Kibana 

Kibana is a graphical user interface for parsing and interpreting collected log files.

- Lets run the following command to install Kibana:

~~~
sudo apt-get install kibana -y
~~~

- Now lets configure Kibana.

~~~
sudo nano /etc/kibana/kibana.yml
~~~

- Delete the (#) sign at the beginning of the following lines to enable them and replace the values with your information:

~~~
server.port: 5601
server.host: "192.168.0.25"
elasticsearch.hosts: ["http://192.168.0.25:9200"]
~~~



- Start Kibana service.

~~~
sudo systemctl start kibana
~~~

If there is no output, then the service was started correctly.

- Next, configure Kibana to launch at boot:

~~~
sudo systemctl enable kibana
~~~


- To access Kibana, open a web browser and browse to the following address:

~~~
http://192.168.0.25:5601
~~~

Note: If you receive a **"Kibana server not ready yet"** error, check if the Elasticsearch and Kibana services are active.

~~~
sudo systemctl status kibana
~~~

~~~
sudo systemctl status elasticsearch
~~~

- If the services are not running then you will need to restart or start the services with these commands:

~~~
sudo systemctl restart kibana
~~~

~~~
sudo systemctl restart elasticsearch
~~~


## Configure Filebeat

Filebeat is a lightweight plugin used to collect and ship log files.

- Install Filebeat by running the following command:

~~~
sudo apt-get install filebeat -y
~~~

- Configure Filebeat:

~~~
sudo nano /etc/filebeat/filebeat.yml
~~~

- Under the Elasticsearch output section, search for the commented outlines:

~~~
output.elasticsearch:
hosts: ["localhost:9200"]
~~~

- remove the (#) sign and edit the line with your system IP address.

- It should look like this:

~~~
output.elasticsearch
hosts: ["192.168.0.25:9200"]
~~~

Note: Remeber to change **IP** with you system IP addresss!
- Next, load the index template:

~~~
sudo filebeat setup --index-management -E output.logstash.enabled=false -E 'output.elasticsearch.hosts=["192.168.0.25:9200"]'
~~~

The system will do some work on setting it up.

- Start and enable the Filebeat service:

~~~
sudo systemctl start filebeat
~~~

~~~
sudo systemctl enable filebeat
~~~

- Verify Elasticsearch Reception of Data:

~~~
curl -XGET http://192.168.0.25:9200/_cat/indices?v
~~~

## Conclusion

Now you have a functional **ElasticXDR** basic install on your Ubuntu system. I recommend you continue building your **ElasticXDR** Security settings.

Security of the devices is not setup, we will setup that process in the next Guide Named: **Security-Module**
> https://github.com/watsoninfosec/ElasticXDR/blob/main/Deployment-Guide/Security-Module/Security-Module.md


# Troubleshotting Tips
- If you get an error messgae like this for **Kibana** , **Elasticsearch** or **Filebeat**:

~~~
● elasticsearch.service - Elasticsearch
   Loaded: loaded (/usr/lib/systemd/system/elasticsearch.service; enabled; vendor preset: ena   Active: failed (Result: timeout) since Tue 2020-12-15 00:44:16 UTC; 24min ago
     Docs: https://www.elastic.co
  Process: 1007 ExecStart=/usr/share/elasticsearch/bin/systemd-entrypoint -p ${PID_DIR}/elast Main PID: 1007 (code=killed, signal=TERM)
    Tasks: 0 (limit: 4631)
   CGroup: /system.slice/elasticsearch.service

Dec 15 00:45:11 test01 systemd[1]: Starting Elasticsearch...
Dec 15 00:44:16 test01 systemd[1]: elasticsearch.service: Start operation timed out. TerminatDec 15 00:44:16 test01 systemd[1]: elasticsearch.service: Failed with result 'timeout'.
Dec 15 00:44:16 test01 systemd[1]: Failed to start Elasticsearch.
~~~

~~~
*/5 * * * * /scripts/fetch-cf-logs.sh
0 0 * * * /scripts/clean-old-indices.sh
~~~

~~~
nano /etc/enviroment
~~~

~~~
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
KIBANA_GID=993
REFRESHED_AT=2020-06-20
LOGSTASH_UID=992
HOSTNAME=d4d5ca597fb0
LANGUAGE=en_US:en
KIBANA_VERSION=7.15.2
ES_INDEX_RETENTION_DAYS=10
KIBANA_PACKAGE=kibana-7.15.2-linux-x86_64.tar.gz
KIBANA_UID=993
ES_PATH_CONF=/etc/elasticsearch
LOGSTASH_PATH_CONF=/etc/logstash
PWD=/
ES_PACKAGE=elasticsearch-7.15.2-linux-x86_64.tar.gz
ES_UID=991
HOME=/root
LANG=en_US.UTF-8
LOGSTASH_PACKAGE=logstash-7.15.2-linux-x86_64.tar.gz
CF_API_KEY=<API-KEY>
CF_FIELDS=CacheCacheStatus,ClientRequestHost,ClientRequestURI,CacheResponseStatus,EdgeResponseStatus,OriginResponseStatus,EdgeStartTimestamp,ClientIP,ClientRequestBytes,CacheResponseBytes,EdgeResponseBytes,ClientRequestMethod,ZoneID,ClientRequestProtocol,ClientRequestUserAgent
LOGSTASH_PATH_SETTINGS=/opt/logstash/config
ES_GID=991
KIBANA_HOME=/opt/kibana
ES_PATH_BACKUP=/var/backups
SHLVL=0
LOGSTASH_GID=992
ES_VERSION=7.15.2
LOGSTASH_VERSION=7.15.2
LC_ALL=en_US.UTF-8
ES_CLEAN_INDICES_SCHEDULE=0 0 * * *
CF_ZONES=<ZONE ID PARA AGREGAR MAS DE UNO DEBES DE SEPARARLO POR: ,>
CF_LOGS_FETCH_SCHEDULE=*/5 * * * *
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
LOGSTASH_HOME=/opt/logstash
CF_LOGS_FETCH_MIN=5
DEBIAN_FRONTEND=teletype
CF_EMAIL=<EMAIL>
ES_HOME=/opt/elasticsearch
_=/usr/bin/printenv
~~~

## Clone this project

git clone https://github.com/cookandy/cloudflare-elk.git

~~~
cd conf
mv logstash.conf /etc/logstash/conf.d
~~~

~~~
mv scripts /
~~~

~~~
mv GeoLite2-City.mmdb /
~~~


Try undoing the changes you have done by, **(#)** commenting you changes then save the file and restart the services. This will confirm if your recent last changes have made the file unstable!

This happens when an entry was not taken in the **.yml** file, the file may be damaged or corrupted.

Once that is done, everything should work after that!

-----
