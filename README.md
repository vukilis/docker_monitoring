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