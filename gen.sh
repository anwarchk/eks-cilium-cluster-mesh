rm -rf ./dist/*

#gen ca cert
openssl genrsa -out ./dist/ca.key 2048

openssl req -new -key ./dist/ca.key -out ./dist/ca.csr -subj \
"/C=CA/ST=BC/L=Vancouver/O=Lululemon Athletica/OU=Enterprise Shared Services/CN=clustermesh-apiserver-ca.cilium.io"\

openssl x509 -req -in ./dist/ca.csr -signkey ./dist/ca.key -out ./dist/ca.crt -days 3650

#gen server cert
openssl genrsa -out ./dist/server.key 2048

openssl req -new -sha256 -key ./dist/server.key -out ./dist/server.csr -subj \
"/C=CA/ST=BC/L=Vancouver/O=Lululemon Athletica/OU=Enterprise Shared Services/CN=clustermesh-apiserver-ca.cilium.io/"

openssl x509 -req -days 3650 -sha256 -extensions v3_req -CA ./dist/ca.crt -CAkey ./dist/ca.key -CAcreateserial -in ./dist/server.csr -out ./dist/server.crt  -extfile ./alt.config


#gen server cert
openssl genrsa -out ./dist/admin.key 2048

openssl req -new -sha256 -key ./dist/admin.key -out ./dist/admin.csr -subj \
"/C=US/ST=WA/L=Sammamish/O=AR3SYSTEMS INC/OU=Enterprise Shared Services/CN=root/"

openssl x509 -req -days 3650 -sha256 -extensions v3_req -CA ./dist/ca.crt -CAkey ./dist/ca.key -CAcreateserial -in ./dist/admin.csr -out ./dist/admin.crt  -extfile ./alt.config

#gen remote cert
openssl genrsa -out ./dist/remote.key 2048

openssl req -new -sha256 -key ./dist/remote.key  -out ./dist/remote.csr -subj \
"/C=CA/ST=BC/L=Vancouver/O=Lululemon Athletica/OU=Enterprise Shared Services/CN=remote"

openssl x509 -req -days 3650 -sha256 -extensions v3_req -CA ./dist/ca.crt -CAkey ./dist/ca.key -CAcreateserial -in ./dist/remote.csr -out ./dist/remote.crt 

#gen config.yaml
CA_CRT=$(cat ./dist/ca.crt|base64 | tr -d '\n')
CA_KEY=$(cat ./dist/ca.key|base64 | tr -d '\n')
SERVER_CRT=$(cat ./dist/server.crt|base64 | tr -d '\n')
SERVER__KEY=$(cat ./dist/server.key|base64 | tr -d '\n')
REMOTE_CRT=$(cat ./dist/remote.crt|base64 | tr -d '\n')
REMOTE_KEY=$(cat ./dist/remote.key|base64 | tr -d '\n')
ADMIN_CRT=$(cat ./dist/admin.crt|base64 | tr -d '\n')
ADMIN_KEY=$(cat ./dist/admin.key|base64 | tr -d '\n')
echo "
ca:
  cert: $CA_CRT
  key: $CA_KEY
server:
  cert: $SERVER_CRT
  key: $SERVER__KEY
remote:
  cert: $REMOTE_CRT
  key: $REMOTE_KEY
admin:
  cert: $ADMIN_CRT
  key: $ADMIN_KEY
"> ./dist/config.yaml


