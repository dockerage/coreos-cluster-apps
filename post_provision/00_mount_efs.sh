# Mount EFS: assuming one EFS for the AWS account. Adjust accordingly if you have more than one.
function mount_efs() {
  if ! mount |grep '/efs ' > /dev/null 2>&1;
  then
    sudo mkdir -p /efs
    filesystemId=$(docker run --rm -v /root/.aws:/root/.aws suet/awscli aws efs describe-file-systems | jq -r '.FileSystems[].FileSystemId')
    if [[ $filesystemId =~ "fs-" ]]
    then
      sudo mount -t nfs4 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).$filesystemId.efs.us-west-2.amazonaws.com:/ /efs
    fi
  fi
}
