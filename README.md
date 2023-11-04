# MS Graph query

Query MS Graph API via shell script

## Contents

- [Setup](#setup)
- [App registration](#app-registration)
- [Authentication](#authentication)
- [Usage](#usage)


## Setup

Go through the steps below to have the scripts running properly:

- [Create an App](#app-registration) within Azure portal
- Set `MSG_CLIENT_SECRET`, `MSG_APP_ID` and `MSG_TENANT_ID` environment variables wrt your app and domain.
- Install Python Poetry and Google Chrome driver and jq.
- Clone this repo and run `poetry install` to have all packages installed.
- Consent to permissions in the [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer) by clicking on your user avatar, then *Consent to permissions*. Follow this [tutorial](https://www.youtube.com/watch?v=f_3wc4UgqTI) for more information.
    - Be conservative and only consent to **read** permissions. Consent to other privileges at your own risk.
    - Once you decided which permissions to consent to, update `SCOPES` array in `auth.py` accordingly.


## App registration

In Azure Portal, access **App registrations**.
- Create one (e.g., `msgraph_access`) and redirect it to `localhost`
- Within Overview, assign Application (client) ID value to `MSG_APP_ID` env variable
- Within Certificates & Secrets, create a new client secret and assign the Value value to `MSG_CLIENT_SECRET` env variable
- Get the tenant id and assign it to `MSG_TENANT_ID` variable.
- Within API Permissions, click Microsoft Graph and add the scopes needed. Check `SCOPES` variables in `auth.py` 


## Authentication

Authentication takes place automatically by using Selenium to authenticate with Azure so an access token can be obtained to use the MS Graph API.

A folder named `SSO` will be created where cookies and all the session state will be stored so you keep logged in for future access. If there is no `SSO` folder by the time you use it, a new one will be created and a browser window will pop up for you to input your credentials. From this point on, authentication will take place automatically in the background.

- **WARNING 1**: Keep this folder (and hence the project folder) as protected as you can, because whoever has access to this folder can easily authenticate with your credentials
- **WARNING 2**: The access token obtained with authentication is stored in `/tmp/msgtoken` and the output of every call is stored in `/tmp/msgraph.json`. If you would rather have those in a different directory, make changes in `query.sh`.

If you want to manually reauthenticate, change user, or if the authentication stops working, delete the `SSO` folder and try again.


## Usage

Run `query.sh`:

```bash
$ ./query.sh MSGRAPH_URL JQ_QUERY
```

where:

- `MSGRAPH_URL` is the url to the MS Graph API. Use the Graph Explorer and play around with the possible example requests. Then, craft your final url and use it here.
- `JQ_QUERY` is the `jq` query to navigate the API output, since it outputs JSON.

It outputs an object in **javascript syntax, not JSON**. If you would rather have JSON, remove all the `sed` find-replace commands in `query.sh` and adapt it to your taste.

Check and run `example_cmd.sh` to see a working example.

As a convenience, you can also use preset variables like `TODAY_START`, `TODAY_PLUS_10` and others when crafting your API calls so you don't need extra preprocessing in your application. Refer to `query.sh` for the full list of preset variables and also to create your own.
