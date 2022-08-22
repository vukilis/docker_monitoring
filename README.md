# Docker Monitoring

> This is a script to monitor Docker resources

## Requirements

> Linux   
> Python 3.8+

## Usage

* With Python and Bash

```bash
pip install -r requirements.txt
touch .env
sudo ./monitoring.sh
```

* Only with Bash

```bash
touch .env
sudo ./monitoring_ob.sh
```

> Make and setup .env file: 
```
file_output=example.txt
message=example.out
user=linuxuser
gmail_from=example@gmail.com
gmail_app_password=your_google_secure_app_code
gmail_to=example@gmail.com
```

## What script do 
* Output resource     
* If CPU **90%** or **more** in usage then output file is sent to **email** 
* **Email** contain:          
**1. Top 5 processes which consuming high CPU**   
**2. Top 10 Processes which consuming high CPU using the ps command**         
**3. Attachment file with docker resources output**

## Add a cronjob
```bash
crontab -e
```
> */10 * * * * sudo bash /home/datadrill/Desktop/docker_monitor/monitoring.sh