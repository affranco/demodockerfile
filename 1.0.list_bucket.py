import boto3

# Crear un cliente de S3
s3 = boto3.client('s3')

# Listar todos los buckets
listObjSummary = s3.list_buckets()

# Iterar sobre los buckets y imprimir el nombre y la fecha de creación de cada uno
for bucket in listObjSummary["Buckets"]:
    print(f'Bucket Name: {bucket["Name"]}, Creation Date: {bucket["CreationDate"]}')
