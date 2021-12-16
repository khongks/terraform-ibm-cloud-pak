https://www.ibm.com/docs/en/ibm-mq/9.2?topic=manager-example-configuring-tls


1. Create a self-signed private key and a public certificate in the current directory

openssl req -newkey rsa:2048 -nodes -keyout tls.key -subj "/CN=localhost" -x509 -days 3650 -out tls.crt

2. Add the server public key to a client key database

runmqakm -keydb -create -db clientkey.kdb -pw password -type cms -stash

runmqakm -cert -add -db clientkey.kdb -label mqservercert -file tls.crt -format ascii -stashed

