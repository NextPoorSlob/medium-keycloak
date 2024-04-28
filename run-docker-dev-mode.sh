docker run -p 8090:8080 \
-e KEYCLOAK_ADMIN=admin \
-e KEYCLOAK_ADMIN_PASSWORD=admin \
-v keycloak_data:/opt/keycloak/data \
quay.io/keycloak/keycloak:23.0.4 \
start-dev 2>&1 > /dev/null &
