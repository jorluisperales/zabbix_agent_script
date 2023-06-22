import csv
import requests
import json
from getpass import getpass

# Zabbix server information
zabbix_url = "http://192.168.101.130/zabbix"

# Prompt for Zabbix username and password
zabbix_username = input("Enter Zabbix username: ")
zabbix_password = getpass("Enter Zabbix password: ")

# Prompt for path of users.csv file
csv_file_path = input("Enter the path of the users.csv file: ")

# Zabbix API endpoint URLs
login_url = zabbix_url + "/api_jsonrpc.php"
user_create_url = zabbix_url + "/api_jsonrpc.php"

# Authenticate with Zabbix API
session = requests.Session()
session.timeout = None  # Disable auto-logout
login_data = {
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": zabbix_username,
        "password": zabbix_password
    },
    "id": 1,
    "auth": None
}
response = session.post(login_url, json=login_data)
auth_token = response.json()["result"]
session.headers.update({"Content-Type": "application/json-rpc"})

# Read CSV file and create users in Zabbix
with open(csv_file_path, "r") as file:
    reader = csv.DictReader(file)
    for row in reader:
        firstname = row["firstname"]
        lastname = row["lastname"]
        username = row["username"]
        password = row["password"]
        usergroup_list = row["usergroup"].split(",")  # Split the usergroup field by comma

        # Create user with read-only permissions
        user_create_data = {
            "jsonrpc": "2.0",
            "method": "user.create",
            "params": {
                "alias": username,
                "name": firstname,
                "surname": lastname,
                "usrgrps": [{"usrgrpid": usergroup} for usergroup in usergroup_list],  # Assign multiple user groups
                "roleid": "1",  # Assign the default role
                "autologin": "1"  # Enable auto-login
            },
            "auth": auth_token,
            "id": 1
        }

        if password:
            user_create_data["params"]["passwd"] = password

        response = session.post(user_create_url, json=user_create_data)
        response_json = response.json()

        if "result" in response_json:
            print(f"User '{username}' created successfully.")
        else:
            error_message = response_json.get("error", {}).get("data", "Unknown error")
            print(f"Failed to create user '{username}'. Error: {error_message}")

        print("Response:", json.dumps(response_json, indent=4))  # Print the response for debugging
