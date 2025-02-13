# pollard-rb
scripts to categorize prunable user accounts via nyu identity api v2

## Setup
1. Make sure you have access to an NYU Identity API key. 
2. Clone this repository locally and cd into it
3. Next add the credentials to a `.secrets.json` file in the root of this project using the structure below and upade the values with your own.

> NOTE: You must save it to exactly this file name for the secret to be ignored by GitHub for security.

``` 
{
  "SERVICE_NET_ID": "CHANGE ME",
  "SERVICE_PW": "CHANGE ME",
  "CLIENT_ID": "CHANGE ME",
  "CLIENT_SECRET": "CHANGE ME",
  "BASE64_STRING": "CHANGE ME", 
  "API_ACCESS_ID": "CHANGE ME"
}
```

  | Variable | What it is / How to find it |
  |:---|:---|
  | `SERVICE_NET_ID`  | NetID for service user SSO registered w/ API key |
  | `SERVICE_PW`      | SSO Password for same service user |
  | `CLIENT_ID`       | For the registered "application" aka the deprovisioning script; you can find this by logging into https://portal.api.it.nyu.edu/ with the service user SSO (above) > "My applications" tab > "library_deprovisioning_request" |
  | `CLIENT_SECRET`   | Found in same area as `CLIENT_ID` ^ |
  | `BASE64_STRING`   | Go to https://www.base64encode.org/ and encode `CLIENT_ID:CLIENT_SECRET`; the result is your `BASE64_STRING`. You can redo this each time or save the result somewhere–it doesn't change unless the `CLIENT_ID` or `CLIENT_SECRET` do. |
  | `API_ACCESS_ID`   |  |

4. Next add your reference data to look up with the API. You should save it as a .csv in `data/in` (it will be ignored by GitHub for security.) The only real requirement it have a column "Email" that contains all users emails in netID format (e.g., `mn119@nyu.edu`)

## Install ruby dependencies

1. Install current Ruby version. If you have asdf (recommended), just run
    ```sh
    asdf install ruby
    ```
2. Install gems
    ``` sh
    bundle install
    ```
## Running the scripts
1. Generate a temporary access token for the API.
    ```sh
    bundle exec ruby lib/generate-token.rb 
    ```
2. Fetch identity fields corresponding to each netId in the reference list:
    ```sh
    bundle exec ruby lib/fetch-data.rb
    ```
    This will output multiple csvs in `/data/out` for users not checked, checked but not found, and found (respectively).
3. Run the analysis on the resulting data:
    ```sh
    bundle exec ruby lib/analyze-data.rb 
    ```
  This will spit out a csv in `/data/out` of accouts "to prune" given the eligibility requirements configured in the `analyze-data.rb` script.
