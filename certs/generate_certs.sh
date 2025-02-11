#!/bin/bash
set -e

# File names
VALIDITY=1825
CA_KEY="ca.key"
CA_CRT="ca.crt"
SERVER_KEY="tls.key"
SERVER_CSR="tls.csr"
SERVER_CRT="tls.crt"
CSR_CONFIG="csr.conf"

# Verify CSR config exists
if [ ! -f "$CSR_CONFIG" ]; then
  echo "Error: csr.conf file not found!"
  exit 1
fi

# Generate CA
echo "Generating Certificate Authority..."
openssl genrsa -out $CA_KEY 2048
openssl req -x509 -new -nodes -key $CA_KEY -sha256 -days $VALIDITY -out $CA_CRT -subj "/C=IN/ST=TEL/L=HYD/O=TechSayyRC/OU=IT/CN=elasticsearch-cluster"

# Generate server certificate
echo "Generating server certificate..."
openssl genrsa -out $SERVER_KEY 2048
openssl req -new -key $SERVER_KEY -out $SERVER_CSR -config $CSR_CONFIG
openssl x509 -req -in $SERVER_CSR -CA $CA_CRT -CAkey $CA_KEY -CAcreateserial -out $SERVER_CRT -days $VALIDITY -sha256 -extfile $CSR_CONFIG -extensions v3_req

# Base64 encoding with specified format
echo "Encoding certificates..."
base64 -w 0 -i $CA_CRT > ca.crt.base64
base64 -w 0 -i $SERVER_CRT > tls.crt.base64
base64 -w 0 -i $SERVER_KEY > tls.key.base64

# Cleanup
rm $SERVER_CSR

echo -e "\nCertificate generation complete. Base64 files created:"
echo "CA Certificate:     ca.crt.base64"
echo "Server Certificate: tls.crt.base64"
echo "Private Key:        tls.key.base64"
