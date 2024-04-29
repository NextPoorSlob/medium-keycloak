#Dockerfile contents START

FROM quay.io/keycloak/keycloak:23.0.4

# Copy the contents from the "builder" stage to the current stage
COPY keycloak.crt /opt/keycloak/conf/keycloak.crt
COPY keycloak.pem /opt/keycloak/conf/keycloak.pem
COPY keycloak.keystore.p12 /opt/keycloak/conf/keycloak.keystore.p12

# Configure a database vendor
ENV KC_DB=postgres
ENV KC_DB_USERNAME=postgres
ENV KC_DB_PASSWORD=keycloak
ENV KC_DB_URL=jdbc:postgresql://kc_pg_cont:5432/postgres

ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin

ENV KC_HEALTH_ENABLED true
ENV http_port 8080
ENV https_port 8443

# Set the entry point for the container to "/opt/keycloak/bin/kc.sh"
# 10.xx.yy.zz is IP of machine which is running the container
ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start", \
"--https-port=${https_port}", \
"--http-port=${http_port}", \
"--https-key-store-file=/opt/keycloak/conf/keycloak.keystore.p12", \
"--https-key-store-password=keycloak", \
"--https-key-store-type=PKCS12", \
"--hostname=mykeycloak", \
"--hostname-admin=admin.mykeycloak"]

#Dockerfile contents END
