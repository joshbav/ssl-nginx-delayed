# need to modify this with correct FQDN
#
for((i=1;i>0;++i)); do echo -n " # $i " && curl -A "bash loadtest" --silent --output /dev/null --show-error --fail ec2-54-187-52-242.us-west-2.compute.amazonaws.com; done;
