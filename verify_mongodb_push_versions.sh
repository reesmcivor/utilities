#!/bin/bash -e
#
# Given a version of the MongoDB Server, verify push artifacts to 
# determine how many of the total files that need to wind up pushed have
# been pushed.

trap "echo ; echo ERROR!" err

version="$1"
if [ ! "$version" ] 
then
  echo "Usage: $0 <version>"
  exit 1
fi

if [ ! "$AWS_SECRET_ACCESS_KEY" -o ! "$AWS_ACCESS_KEY_ID" ]
then
  . ~/amazon-nocadmin.sh
fi

all_files="
s3://downloads.10gen.com/linux/mongodb-linux-x86_64-enterprise-amzn64-%s.tgz
s3://downloads.10gen.com/linux/mongodb-linux-x86_64-enterprise-rhel57-%s.tgz
s3://downloads.10gen.com/linux/mongodb-linux-x86_64-enterprise-rhel62-%s.tgz
s3://downloads.10gen.com/linux/mongodb-linux-x86_64-enterprise-suse11-%s.tgz
s3://downloads.10gen.com/linux/mongodb-linux-x86_64-enterprise-ubuntu1204-%s.tgz
s3://downloads.10gen.com/win32/mongodb-win32-x86_64-enterprise-windows-64-2.5.5.msi
s3://downloads.mongodb.org/linux/mongodb-linux-i686-%s.tgz
s3://downloads.mongodb.org/linux/mongodb-linux-i686-debugsymbols-%s.tgz
s3://downloads.mongodb.org/linux/mongodb-linux-i686-rhel57-%s.tgz
s3://downloads.mongodb.org/linux/mongodb-linux-i686-static-%s.tgz
s3://downloads.mongodb.org/linux/mongodb-linux-x86_64-%s.tgz
s3://downloads.mongodb.org/linux/mongodb-linux-x86_64-debugsymbols-%s.tgz
s3://downloads.mongodb.org/linux/mongodb-linux-x86_64-legacy-%s.tgz
s3://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel57-%s.tgz
s3://downloads.mongodb.org/win32/mongodb-win32-i386-%s.zip
s3://downloads.mongodb.org/win32/mongodb-win32-x86_64-%s.zip
s3://downloads.mongodb.org/win32/mongodb-win32-x86_64-2008plus-%s.zip
s3://downloads.mongodb.org/osx/mongodb-osx-x86_64-%s.tgz
s3://downloads.mongodb.org/sunos5/mongodb-sunos5-x86_64-%s.tgz
"

tried=0
found=0

for push_file_pattern in $all_files
do
  tried=`expr $tried + 1`
  push_file=`printf $push_file_pattern $version`
  #echo push_file: $push_file
  echo -n .
  if ! aws s3 ls $push_file | grep `basename $push_file`$ >/dev/null 
  then
    echo
    echo "ERROR: missing file: $push_file"
  else
    found=`expr $found + 1`
  fi
done
echo
echo "Found $found/$tried"
