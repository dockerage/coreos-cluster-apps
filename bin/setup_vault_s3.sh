#!/bin/bash
# 
# sfeng@stanford.edu 2016
#
# Modified https://github.com/hashicorp/best-practices/blob/master/packer/config/vault/scripts/setup_vault.sh
# to use S3 backend.
set -e

# Pass -i for interactive run. Otherwise, automatically init and unseal.
interactive=${1:-'false'}

# Assuming Vault is installed in /opt/bin.
export PATH=/opt/bin:$PATH

if [ "X$interactive" = 'X-i' ]; then
    read -p $'Running this script will initialize & unseal Vault, \nthen put your unseal keys and root token into S3. \n\nIf you are sure you want to continue, type \'yes\': \n' ANSWER
  if [ "$ANSWER" != "yes" ]; then
     echo
     echo "Exiting without intializing & unsealing Vault, no keys or tokens were stored."
     echo
     exit 1
   fi
fi

# Variables
#TMPDIR=$(mktemp -d /tmp/root-token.XXXXX)
TMPDIR=/tmp/root-token
BUCKET=$(grep bucket /opt/etc/vault/vault.hcl | grep -v ^# | awk '{print $NF}' | sed 's/"//g')

## Functions
abort() { echo "$1"; exit 1; }
s3ls() { 
 docker run --rm xueshanf/awscli aws s3 ls s3://$BUCKET/$1 > /dev/null 2>&1
}
s3get() {
 docker run --rm -v $TMPDIR:/tmp xueshanf/awscli aws s3 cp s3://$BUCKET/$1 /tmp > /dev/null 2>&1
}
s3set() {
 rm -rf $TMPDIR/key
 echo $1 > $TMPDIR/key
 docker run --rm -v $TMPDIR/key:/tmp/key xueshanf/awscli aws s3 cp /tmp/key s3://$BUCKET/$2
}

if [ -z "$BUCKET" ]; then
  abort "S3 Bucket is not defined in conf."
fi

if  ! s3ls core ; then
  abort "S3 Bucket is doesn't exist."
fi
if ! s3ls root-token ; then
  echo "Initialize Vault"
  #vault init | tee $TMPDIR/vault.init > /dev/null

  # Store master keys in S3 for operator to retrieve and remove
  COUNTER=1
  cat /tmp/vault.init | grep '\(hex\)' | awk '{print $6}' | for key in $(cat -); do
    s3set $key root-token/unseal-key-$COUNTER
    COUNTER=$((COUNTER + 1))
  done

  export ROOT_TOKEN=$(cat $TMPDIR/vault.init | grep '^Initial' | awk '{print $4}')
  s3set $ROOT_TOKEN root-token/root-token

  echo "Remove master keys from disk"
  #shred -u $TMPDIR/*key*
else
  echo "Vault has already been initialized, skipping."
fi

if vault status | grep Sealed | grep true ; then
  echo "Downloading keys"
  s3get root-token/unseal-key-1
  s3get root-token/unseal-key-2
  s3get root-token/unseal-key-3

  echo "Unsealing Vault"
  vault unseal $(cat $TMPDIR/unseal-key-1)
  vault unseal $(cat $TMPDIR/unseal-key-2)
  vault unseal $(cat $TMPDIR/unseal-key-3)
  echo "Vault setup complete."
else
 echo "Vault is already unsealed."
fi

instructions() {
  cat <<EOF
We use an instance of HashiCorp Vault for secrets management.
It has been automatically initialized and unsealed once. Future unsealing must
be done manually.
The unseal keys and root token have been temporarily stored in S3.
  $BUCKET/root-token $BUCKET/root-token/unseal-key-{1..5}
Please securely distribute and record these secrets and remove them from Etcd.
EOF

  exit 1
}

instructions
