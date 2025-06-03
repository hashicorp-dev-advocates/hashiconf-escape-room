import os
import hvac
import requests


from faker import Faker

NUMBER_OF_RECORDS = 10

client = hvac.Client(
    url=os.environ["VAULT_ADDR"],
    token=os.environ["VAULT_TOKEN"],
    namespace=os.getenv("VAULT_NAMESPACE"),
)

OPEN_WEBUI_URL=os.environ['OPEN_WEBUI_URL']
OPEN_WEBUI_TOKEN=os.environ['OPEN_WEBUI_TOKEN']

fake = Faker()


def encode_address(address):
    encode_response = client.secrets.transform.encode(
        mount_point="payments/transform",
        role_name="payments",
        value=address,
        transformation="address",
    )
    return encode_response["data"]["encoded_value"]


def encode_credit_card_number(ccn):
    encode_response = client.secrets.transform.encode(
        mount_point="payments/transform",
        role_name="payments",
        value=ccn,
        transformation="ccn",
    )
    return encode_response["data"]["encoded_value"]


def generate_data(number_of_records):
    payments = {}
    for _ in range(0, number_of_records):
        name = fake.name()
        ccn = encode_credit_card_number(fake.credit_card_number())
        ccntype = fake.credit_card_provider()
        address = encode_address(fake.street_address())
        zipcode = fake.postcode()

        form = f"""# Credit Card Form

Full Name: {name}

Credit Card Type: {ccntype}

Credit Card Number: {ccn}

Billing Street Address: {address}

Billing Zip Code: {zipcode}
"""
        payments[name] = form
    return payments


def create_knowledge_base(name, description):
    url = f'{OPEN_WEBUI_URL}/api/v1/knowledge/create'
    headers = {
        'Authorization': f'Bearer {OPEN_WEBUI_TOKEN}',
        'Content-Type': 'application/json'
    }
    data = {'name': name, 'description': description}
    response = requests.post(url, headers=headers, json=data)
    print(response.json())
    return response.json()


def upload_file(file_contents):
    url = f'{OPEN_WEBUI_URL}/api/v1/files/'
    headers = {
        'Authorization': f'Bearer {OPEN_WEBUI_TOKEN}',
        'Accept': 'application/json'
    }
    files = {'file': file_contents.encode()}
    response = requests.post(url, headers=headers, files=files)
    return response.json()


def add_file_to_knowledge(knowledge_id, file_id):
    url = f'{OPEN_WEBUI_URL}/api/v1/knowledge/{knowledge_id}/file/add'
    headers = {
        'Authorization': f'Bearer {OPEN_WEBUI_TOKEN}',
        'Content-Type': 'application/json'
    }
    data = {'file_id': file_id}
    response = requests.post(url, headers=headers, json=data)
    return response.json()


def main():
    kb = create_knowledge_base('Credit Card Forms', 'Credit card forms for payment processing')
    payments = generate_data(NUMBER_OF_RECORDS)
    for name in payments:
        response = upload_file(payments[name])
        add_file_to_knowledge(kb['id'], response['id'])


if __name__ == "__main__":
    main()
