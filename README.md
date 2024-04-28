# Keycloak production mode with Docker 
Based on a Medium article by Shailendra Jain
[Keycloak production mode with Docker](https://medium.com/@asynchronouscal/keycloak-production-mode-with-docker-step-by-step-guide-b284927e72c0)

## Steps
1. Install Docker
2. Run Keycloak in Dev Mode
3. Prepare the Hosts File
4. Prepare a Self-Signed Certificate
5. Create the Docker Network
6. Create The Database Container
7. Prepare Dockerfile for Keycloak
8. Generate Keycloak Image
9. Launch the Secure Keycloak

## Install Docker
System dependent.

## Run Keycloak in Dev Mode
This project uses version 23.0.4.

See
```shell
./run-docker-dev-mode.sh
```

## Prepare the Hosts File
Operating systems vary, but add the following values to the _hosts_ file.  On Windows, it is found at
C:\Windows\System32\drivers\etc\hosts.

```text
127.0.0.1	mykeycloak
::1		mykeycloak
127.0.0.1	admin.mykeycloak
::1		admin.mykeycloak
```

## Prepare a Self-Signed Certificate
Create a self-signed certificate to test the set-up.
```shell
openssl genrsa -out keycloak.key 2048

openssl req -new -x509 -sha256 -key keycloak.key -out keycloak.crt -days 2048

mv keycloak.key keycloak.pem

cat keycloak.crt >> keycloak.pem

sudo keytool -genkeypair -alias localhost \
-keyalg RSA \
-keysize 2048 \
-validity 2048 \
-keystore keycloak.keystore \
-dname "cn=Server Administrator,o=Angry Squirrel Software,c=US" \
-keypass keycloak \
-storepass keycloak
```

You can list the resulting  keystore with this line:
```shell
keytool -list -keystore keycloak.keystore -storepass keycloak -storetype PKCS12
```

This sets up the keystore and certificates for Keycloak.
```shell
-- https-certificate-file=keycloak.crt

-- https-certificate-key-file=keycloak.pem

-- https-trust-store-file=server.keystore
```

## Create the Docker Network
For added security and better customization, create a separate network.
```shell
docker network create kcnetwork
```


## Create The Database Container

Create a data volume for the database.
```shell
docker volume create pgdata
```

Using the volume, run the latest version of Postgres.
```shell
docker run -d --name kc_pg_cont \
--network kcnetwork \
-e POSTGRES_PASSWORD=keycloak \
-p 5432:5432 \
-v pgdata:/var/lib/postgresql/data \
postgres
```

You can test the database with the following command.  Note that the `-W` parameter will prompt the user for the
database password (_keycloak_).
```shell
docker run -it --rm --network kcnetwork postgres:latest psql -h kc_pg_cont -U postgres -p 5432 -W
```

## Prepare Dockerfile for Keycloak
This puts everything together to build an image to run Docker in.  See the `./Dockerfile`.

## Generate Keycloak Image
Run below command in the directory , which contains the Dockerfile , to build the docker image kcprod_v1
```shell
docker build -t kcprod_v1 .
```

## Launch the Secure Keycloak
Time to run Keycloak in production mode with postgres.
```shell
docker run --name kctest_container --network kcnetwork -p 8443:8443 -p 8080:8080 kcprod_v1
```
Use this link to open the admin site: https://mykeycloak:8443.

This link with show the health check:  https://mykeycloak:8443/health.

To run multiple containers on separate IP addresses, use this version of the command.
```shell
 docker run -d --name kctest_container1 --network kcnetwork -e "https_port=8443" -e "http_port=8080" -p 8443:8443 -p 8080:8080 kcprod_v1
 
 docker run -d --name kctest_container2 --network kcnetwork -e "https_port=8643" -e "http_port=8280" -p 8643:8643 -p 8280:8280 kcprod_v1
 
 docker run -d --name kctest_container3 --network kcnetwork -e "https_port=8843" -e "http_port=8480" -p 8843:8843 -p 8480:8480 kcprod_v1
```