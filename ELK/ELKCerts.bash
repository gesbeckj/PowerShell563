cd /home/localadmin
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt

openssl genrsa -out server.key 2048
openssl req -sha512 -new -key server.key -out server.csr -config server.conf

echo "C2E9862A0DA8E970" > serial
openssl x509 -days 3650 -req -sha512 -in server.csr -CAserial serial -CA ca.crt -CAkey ca.key -out server.crt -extensions v3_req -extfile server.conf
mv server.key server.key.pem && openssl pkcs8 -in server.key.pem -topk8 -nocrypt -out server.key