# Using NYU Identity API via Library Deprovisioning Application Access Token
## See
- https://wp.nyu.edu/developers/connecting-to-apis-2/

## Prerequisite Info
| Variable | What it is / How to find it |
|:---|:---|
| `SERVICE_NET_ID`  | NetID for service user SSO; ask Marii |
| `SERVICE_PW`      | Password for service user SSO; same as `SERVICE_NET_ID`  ^ |
| `CLIENT_ID`       | For the registered "application" aka the deprovisioning script; you can find this by logging into https://portal.api.it.nyu.edu/ with the service user SSO (above) > "My applications" tab > "library_deprovisioning_request" |
| `CLIENT_SECRET`   | Same as `CLIENT_ID` ^ |
| `BASE64_STRING`   | Go to https://www.base64encode.org/ and encode `CLIENT_ID:CLIENT_SECRET`; the result is your `BASE64_STRING`. You can redo this each time or save the result somewhere–it doesn't change unless the `CLIENT_ID` or `CLIENT_SECRET` do. |
| `API_ACCESS_ID`   | *TBD* |

**NOTE:**


## Instructions

1. Generate a `TEMP_TOKEN` response by running the following cURL command (with your info added in); copy the whole result to a json file if needed, but note that it will expire in 1hr by default. The response will include values for `"access_token"`, `"refresh_token"`, `"scope"`, `"id_token"`, `"token_type"`, and `"expires_in"`.
    ```sh
    curl  -k -d "grant_type=password&username=SERVICE_NET_ID&password=SERVICE_PW&scope=openid" \
    -H "Authorization: Basic BASE64_STRING" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    "https://auth.nyu.edu/oauth2/token"
    ```
2. Test API lookup on `TEST_NET_ID` (can be yours or whomevers); use the `"access_token"` value from the `TEMP_TOKEN` response you got in step 1 as the `ACCESS_TOKEN` below.
    ``` sh
    curl -L 'https://api.nyu.edu/identity-v2-sys/identity/unique-id/TEST_NET_ID?api_access_id=API_ACCESS_ID' \
    -H 'Authorization: Bearer ACCESS_TOKEN'
    ```
3. If needed, renew the token; use the `"refresh_token"` value from the `TEMP_TOKEN` response you got in step 1 as the `REFRESH_TOKEN` below.
    ```sh
    curl -k -d "grant_type=refresh_token&refresh_token=REFRESH_TOKEN" \
    -H "Authorization: Basic BASE64_STRING" \
    -H "Content-Type: application/x-www-form-urlencoded" "https://auth.nyu.edu/oauth2/token"
    ```
