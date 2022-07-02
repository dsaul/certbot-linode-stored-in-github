#!/usr/bin/env bash
set -o errexit
set -o nounset
#set -o xtrace
set -o pipefail

if [ -z ${CERTIFICATE_DOMAIN+x} ];
	then echo "CERTIFICATE_DOMAIN is not set" && exit 1;
	else echo "CERTIFICATE_DOMAIN = '$CERTIFICATE_DOMAIN'";
fi

if [ -z ${EMAIL_ADDR+x} ];
	then echo "EMAIL_ADDR is not set" && exit 1;
	else echo "EMAIL_ADDR = '$EMAIL_ADDR'";
fi

if [ -z ${LINODE_API_KEY+x} ];
	then echo "LINODE_API_KEY is not set" && exit 1;
	else echo "LINODE_API_KEY = '$LINODE_API_KEY'";
fi

if [ -z ${GIT_URL+x} ];
	then echo "GIT_URL is not set" && exit 1;
	else echo "GIT_URL = '$GIT_URL'";
fi

if [ -z ${ID_RSA_SECRET_FILE+x} ];
	then echo "ID_RSA_SECRET_FILE is not set" && exit 1;
	else echo "ID_RSA_SECRET_FILE = '$ID_RSA_SECRET_FILE'";
fi

if [ -z ${ID_RSA_PUB_SECRET_FILE+x} ];
	then echo "ID_RSA_PUB_SECRET_FILE is not set" && exit 1;
	else echo "ID_RSA_PUB_SECRET_FILE = '$ID_RSA_PUB_SECRET_FILE'";
fi


ssh-keyscan github.com >> ~/.ssh/known_hosts

# Make sure we have the secret files in position.
rm ~/.ssh/id_rsa ~/.ssh/id_rsa.pub || true
cp $ID_RSA_SECRET_FILE ~/.ssh/id_rsa
cp $ID_RSA_PUB_SECRET_FILE ~/.ssh/id_rsa.pub

# Correct ssh permissions
chmod go-w ~/ || true
chmod 700 ~/.ssh || true
chmod 600 ~/.ssh/id_rsa || true
chmod 600 /tmp/linode.ini || true

# Clear our the lets encrypt directory.
mkdir -p /etc/letsencrypt
rm -rfv /etc/letsencrypt/* || true
rm -rfv /etc/letsencrypt/.git || true

# Add git credentials.
git config --global user.email "servers@dispatchpulse.com"
git config --global user.name "Docker Container"

git clone --depth 1 $GIT_URL -b master /etc/letsencrypt




certbot \
	certonly --dns-linode \
	-d $CERTIFICATE_DOMAIN \
	-d *.$CERTIFICATE_DOMAIN \
	--agree-tos \
	--no-bootstrap \
	--manual-public-ip-logging-ok \
	--no-eff-email \
	--preferred-challenges dns-01 \
	--non-interactive \
	-m $EMAIL_ADDR \
	--server https://acme-v02.api.letsencrypt.org/directory \
	--dns-linode-credentials /tmp/linode.ini

cd /etc/letsencrypt
git add -v * || echo "git was unable to add"
git commit -v -m "Update Container Changes @ $(date -u +"%Y-%m-%dT%H:%M:%SZ") " || echo "git was unable to commit"
git push origin master || echo "git was unable to push"


