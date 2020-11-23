import requests

ip = requests.get("https://api.ipify.org").content.decode("utf-8")
requests.post("http://pihub.site/api/device-update", {"ip": ip})
