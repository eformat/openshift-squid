## openshift-squid

Squid proxy pod for OpenShift.

Generate an SSL cert for caching https:// - you will need to trust this as squid man-in-the-middles these calls e.g.
```bash
openssl req -new -newkey rsa:2048 -days 999 -nodes -x509 -keyout squidCA.pem -out squidCA.pem -subj "/C=AU/ST=QLD/L=Brisbane/O=ACME/OU=DEV/CN=DEV"
```

Quick deploy to OpenShift:
```bash
oc new-app quay.io/eformat/openshift-squid:latest --name=squid

cat <<'EOF' | oc apply -f-
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: squid-data
spec:
  resources:
    requests:
      storage: 1Gi
  storageClassName: gp2
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
EOF

oc set volume deployment/squid --add --overwrite -t persistentVolumeClaim --claim-name=squid-data --name=volume-1 --mount-path=/var/spool/squid
```

Test
```bash
export HTTP_PROXY=http://squid:3128
export HTTPS_PROXY=http://squid:3128
export http_proxy=http://squid:3128
export https_proxy=http://squid:3128

time curl -k -s -o aws-java-sdk-bundle-1.12.242.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.242/aws-java-sdk-bundle-1.12.242.jar -x "squid:3128"
```

Check the squid.conf for relevant options.
