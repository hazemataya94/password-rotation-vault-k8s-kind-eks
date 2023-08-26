from vault_connector import VaultConnector
# from dotenv import load_dotenv
# load_dotenv()  # Load variables from .env file if present (failed because of some error in pip, check it later)
# token = os.getenv("VAULT_TOKEN")

def get_key_value(line):
    line_parts = line.strip().split("=")
    return line_parts[1].strip('"')

def main():
    
    # Init values
    vault_url = role_id = role_secret_id = engine = secret_path = secret_key = ""
    
    env_file_path = ".env"
    with open(env_file_path, "r") as file:
        for line in file:
            if line.startswith("VAULT_URL="):
                vault_url = get_key_value(line)
            elif line.startswith("VAULT_ROLE_ID="):
                role_id = get_key_value(line)
            elif line.startswith("VAULT_ROLE_SECRET_ID="):
                role_secret_id = get_key_value(line)
            elif line.startswith("VAULT_ENGINE="):
                engine = get_key_value(line)
            elif line.startswith("VAULT_SECRET_PATH="):
                secret_path = get_key_value(line)
            elif line.startswith("VAULT_SECRET_KEY="):
                secret_key = get_key_value(line)
        
    try:
        if not all([vault_url, role_id, role_secret_id, engine, secret_path, secret_key]):
            raise ValueError("Missing required parameters in .env file.")
    
        vault = VaultConnector(vault_url, role_id=role_id, secret_id=role_secret_id)
        
        # ===================================================================
        print(f"Old value of {secret_key} is: ")
        value = vault.get_password(engine, secret_path, secret_key)
        print(value)

        # ===================================================================
        vault.rotate_password(engine, secret_path, secret_key)
        print(f"New value of {secret_key} is: ")
        value = vault.get_password(engine, secret_path, secret_key)
        print(value)
 
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
