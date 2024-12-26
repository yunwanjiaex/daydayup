#!/usr/bin/env python3
# 发送 smtp 邮件
# python3 ./outlook.py -s "This is mail subject." -b 'This is mail body.'
# 经测试可用于 qq 邮箱和 outlook 邮箱

import argparse, smtplib
from email.mime.text import MIMEText

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--subject", type=str, default="this_is_subject")
parser.add_argument("-b", "--body", type=str, default="this_is_body")
args = parser.parse_args()

sender = "18368322050@qq.com"
receiver = "yun.wanjia.ex@gmail.com"
smtp = smtplib.SMTP("smtp.qq.com", 587)
smtp.starttls()
smtp.login(user=sender, password="Cn2FgcG0kwQamrE4")
message = MIMEText(args.body, "plain", "utf-8")
message["From"] = sender
message["To"] = receiver + ","
message["Subject"] = args.subject

smtp.sendmail(from_addr=sender, to_addrs=[receiver], msg=message.as_string())
