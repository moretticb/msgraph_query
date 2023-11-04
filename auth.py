import os
import webbrowser
from msal import ConfidentialClientApplication

from seleniumwire import webdriver
from selenium import webdriver as viswebdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from pathlib import Path


USER_DATA_FOLDER = "SSO"

client_secret = os.getenv("MSG_CLIENT_SECRET")
app_id = os.getenv("MSG_APP_ID")
tenant_id = os.getenv("MSG_TENANT_ID")

SCOPES = [
    'User.Read',
    'Mail.Read',
    'Mail.ReadBasic',
    'Mail.Read.Shared',
    'Calendars.Read',
    'Calendars.ReadBasic',
    'Calendars.Read.Shared'
]


client = ConfidentialClientApplication(
    client_id=app_id,
    client_credential=client_secret,
    authority=f"https://login.microsoftonline.com/{tenant_id}"
)
auth_url = client.get_authorization_request_url(SCOPES)


delay = 15
if Path(USER_DATA_FOLDER).is_dir():
    options = webdriver.ChromeOptions()
    options.add_argument(f"--user-data-dir={USER_DATA_FOLDER}")
    options.add_argument("--headless=new")

    driver = webdriver.Chrome(options=options)
else:
    options = viswebdriver.ChromeOptions()
    options.add_argument(f"--user-data-dir={USER_DATA_FOLDER}")

    driver = viswebdriver.Chrome(options=options)
    delay = 120


driver.get(auth_url)
try:
    WebDriverWait(driver, delay).until(EC.url_matches("code="))
except:
    raise Exception(f"Unable to authenticate. Remove {USER_DATA_FOLDER} folder and try again.")
    

url = driver.current_url

code = url.split("code=")[1].split("&")[0]
access_token = client.acquire_token_by_authorization_code(code=code, scopes=SCOPES)
print(access_token['access_token'])

