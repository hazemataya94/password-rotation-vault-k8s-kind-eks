from vault_connector import VaultConnector
# from dotenv import load_dotenv
# load_dotenv()  # Load variables from .env file if present (failed because of some error in pip, check it later)
# token = os.getenv("VAULT_TOKEN")

def get_key_value(line):
    line_parts = line.strip().split("=")
    return line_parts[1].strip('"')

def get_policy(engine, secret_path):
    return {
            "path": {
                f"{engine}/data/{secret_path}": {
                    "capabilities": ["read", "update", "list"]
                }
            }
        }

def main():
    
    # Init values
    vault_url = vault_root_token = engine = secret_path = ""
    
    env_file_path = ".env"
    with open(env_file_path, "r") as file:
        for line in file:
            if line.startswith("VAULT_URL="):
                vault_url = get_key_value(line)
            elif line.startswith("VAULT_ROOT_TOKEN="):
                vault_root_token = get_key_value(line)
            elif line.startswith("VAULT_ENGINE="):
                engine = get_key_value(line)
            elif line.startswith("VAULT_SECRET_PATH="):
                secret_path = get_key_value(line)
            
    if not all([vault_url, vault_root_token, engine, secret_path]):
        raise ValueError("Missing required parameters in .env file.")
        
    try:
        vault = VaultConnector(vault_url, vault_root_token)
        policy_name = "service_token"
        role_name = "pass_rotation"
        # ===================================================================
        print(f"Creating a policy")
        vault.generate_policy(policy_name, get_policy(engine, secret_path))
        
        # ===================================================================
        print(f"Creating app role")
        vault.generate_app_role(role_name, policy_name)
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
