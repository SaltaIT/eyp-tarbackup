#!/bin/bash

AWSBIN=${AWSBIN-$(which aws 2>/dev/null)}
if [ -z "$AWSBIN" ];
then
  echo "aws not found"
fi

KEEP_FILES=0

while getopts 'kb:' OPT; do
  case $OPT in
    k)  KEEP_FILES=1;;
    b)  S3BUCKET=$OPTARG;;
    h)  JELP="yes";;
    *)  JELP="yes";;
  esac
done

# usage
HELP="
    usage: $0 [-k] -b <S3BUCKET> <FILES>...
    syntax:
            -b : S3 bucket
            -k : keep local file - do not delete it after pushing it to S3
            -h : print this help screen
"

if [ "$JELP" = "yes" ]; then
  echo "$HELP"
  exit 1
fi

shift $(($OPTIND - 1))

ERROR="0"

for FILE in $@;
do
  if [ -e $FILE ];
  then
    $AWSBIN s3 cp $FILE "${S3BUCKET}/$(basename $FILE)"

    if [ "$?" -eq 0 ] && [ "${KEEP_FILES}" -eq 0 ];
    then
      rm -f "${FILE}"
    fi
  else
    echo "$FILE does not exists, skipping"
    let ERROR=$ERROR+1
  fi
done

exit $ERROR
