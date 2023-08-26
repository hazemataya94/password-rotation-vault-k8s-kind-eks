import hvac
import random
import string
import json

class VaultConnector:
    def __init__(self, vault_url, vault_token="", role_id="", secret_id="", verify=True):
        if vault_token:
            self.client = hvac.Client(url=vault_url, token=vault_token, verify=verify)
        elif role_id and secret_id:
            self.client = hvac.Client(url=vault_url, verify=verify)
            self._authenticate_with_approle(role_id, secret_id)
        else:
            raise ValueError("Either 'token' or 'role_id' and 'secret_id' must be provided.")
        
        self.validate_authentication()
        
    def _authenticate_with_approle(self, role_id, secret_id):
        response = self.client.auth.approle.login(role_id=role_id, secret_id=secret_id)
        self.client.token = response['auth']['client_token']
    
    def _generate_random_password(self, length=32):
        characters = string.ascii_letters + string.digits
        return ''.join(random.choice(characters) for _ in range(length))

    def validate_authentication(self):
        if self.client.is_authenticated():
            print("Authentication with Vault successful.")
        else:
            raise Exception("Authentication with Vault failed.")

    def get_password(self, engine, secret_path, secret_key):
        response = self.client.secrets.kv.v2.read_secret_version(mount_point=engine, path=secret_path)
        data = response['data']['data']
        if secret_key in data:
            return data[secret_key]
        else:
            raise KeyError(f"Key '{secret_key}' not found in secret '{secret_path}'.")

    def rotate_password(self, engine, secret_path, secret_key):
        new_password = self._generate_random_password()
        self.client.secrets.kv.v2.create_or_update_secret(
            mount_point=engine,
            path=secret_path,
            secret={secret_key: new_password}
        )
        print(f"Password for key '{secret_key}' in secret '{secret_path}' rotated successfully.")

    def generate_policy(self, policy_name, rules):
        # Define the policy rules as a dictionary
        # policy_rules = {
        #     "path": {
        #         "secret/data/my-secret-path": {
        #             "capabilities": ["read", "update", "list"]
        #         }
        #     }
        # }
        self.client.sys.create_or_update_policy(name=policy_name, policy=rules)
        print(f"Policy '{policy_name}' created successfully.")
        
    def generate_app_role(self, role_name, policy_name):
        # print("Enable approle auth method")
        # self.client.sys.enable_auth_method(
        #     method_type='approle',
        # )
        # print("Creating app role")

        resp = self.client.auth.approle.read_role_id(
            role_name=role_name,
        )
        print(f'AppRole role ID for {role_name} role: {resp["data"]["role_id"]}')
        
        resp = self.client.auth.approle.generate_secret_id(
            role_name=role_name,
            cidr_list=['0.0.0.0/0'],
        )
        print(f'AppRole secret ID for {role_name} role: {resp["data"]["secret_id"]}')
      