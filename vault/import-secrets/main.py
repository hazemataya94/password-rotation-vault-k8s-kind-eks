
import pandas
import hvac

# Press the green button in the gutter to run the script.
if __name__ == '__main__':

    CSV_FILE_PATH = "vault-passwords.csv"
    VAULT_ADDRESS = "http://link-to-vault:port-if-needed"
    VAULT_TOKEN = "root_token"
    OVERRIDE_EXISTING_VALUES = False

    csvFile = pandas.read_csv(CSV_FILE_PATH)

    finalData = []

    for index, row in csvFile.iterrows():

        dataDictionary = {}

        for i in range(0, csvFile.columns.size):

            if pandas.isnull(row[i]):
                continue

            dataDictionary[csvFile.columns[i].strip()] = str(row[i]).strip()

        if not 'engine' in dataDictionary or not 'path' in dataDictionary:
            continue

        finalData.append(dataDictionary)

    client = hvac.Client(
        url=VAULT_ADDRESS,
        token=VAULT_TOKEN
    )

    if not client.is_authenticated():
        print("Error connecting to vault")
        quit(1)

    for data in finalData:

        engine = data['engine']
        del data['engine']

        try:
            kv_configuration = client.secrets.kv.v2.read_configuration(
                mount_point=engine,
            )
        except Exception:
            print(f"Error in secret engine, secret engine '{engine}' doesn't exist")
            quit(1)

        if not OVERRIDE_EXISTING_VALUES:

            pathExists = True

            try:
                list_response = client.secrets.kv.v2.read_secret_version(
                    path=data['path'],
                    mount_point=engine
                )
            except Exception:
                pathExists = False

            if pathExists:
                print(f"Path {data['path']} already exists in '{engine}' engine, it'll be ignored, please update it manually")
                continue

        path = data['path']
        del data['path']

        if not data:
            continue

        client.secrets.kv.v2.create_or_update_secret(
            path=path,
            secret=data,
            mount_point=engine
        )

