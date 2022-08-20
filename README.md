# Docker Monitoring

> This is a script to monitor Docker resources

## Requirements

> Linux   
> Python 3.8+

## Usage

```bash
pip install -r requirements.txt
touch .env
sudo ./monitoring.sh
```

> Make and setup .env file: 
```
file_output=file_name_of_stats_output.txt
message=mail_file_output.*
user=your_linux_username
gmail_from=your_email
gmail_app_password=your_google_secure_app_code
gmail_to=send_to_email
```

## What script do 
* Output resource     
* If CPU **90%** or **more** in usage then output file is sent to **email** 
* **Email** contain:          
**1. Top 5 processes which consuming high CPU**   
**2. Top 10 Processes which consuming high CPU using the ps command**         
**3. Attachment file with docker resources output**