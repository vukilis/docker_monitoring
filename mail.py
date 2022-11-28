import smtplib
from email.message import EmailMessage
import os
from pathlib import Path
from dotenv import load_dotenv

# path= "/home/datadrill/Desktop/docker_monitor"  # path to the script directory
# file = "Docker_Monitoring_Stats.txt"            # file name of stats output
# file_alert = "mail.log"                         # file name of mail attachemnt
# full_path = f"{path}{os.sep}{file}" 

load_dotenv('.env')
path = os.getcwd()
file = os.environ.get("file_output")
message = os.environ.get("message")
full_path = f"{path}{os.sep}{file}"

def alert():
    text = Path(f"{path}{os.sep}{message}").read_text()
    return send_mail(text)
    
def send_mail(text):
    gmail_user = os.environ.get("gmail_from")                        # your mail
    gmail_password = os.environ.get("gmail_app_password")            # your google secure app code
    msg = EmailMessage()
    msg.set_content(text)
    msg["Subject"] = "Report"
    msg["From"] = gmail_user
    msg["To"] = os.environ.get("gmail_to")                           # send to
    msg.add_attachment(open(full_path, "r").read(), filename=full_path)
    
    with smtplib.SMTP(host="smtp.gmail.com", port=587) as smtp:
        check = smtp.ehlo()
        if check[0] == 250:
            print("Successfully contacted mail server")
        else:
            print("Unable to contact server")

        smtp.starttls()
        
        try:
            smtp.login(gmail_user, gmail_password)
            print("Login successful")
        except smtplib.SMTPAuthenticationError as err:
            print("Login failed:", err)
        smtp.send_message(msg)
        smtp.quit()

if __name__ == "__main__":
    alert()