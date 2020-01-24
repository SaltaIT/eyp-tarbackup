#!/bin/bash

function initbck
{
	if [ -z "${DESTINATION}" ];
	then
		echo "no destination defined"
		BCKFAILED=1
	else
		mkdir -p $DESTINATION
		BACKUPTS=$(date +%Y%m%d%H%M)

		if [ -z "${LOGDIR}" ];
		then
			LOGDIR=${DESTINATION}
		fi

		CURRENTBACKUPLOG="$LOGDIR/$BACKUPTS.log"

		BCKFAILED=999

		exec >> $CURRENTBACKUPLOG 2>&1
	fi
}

function mailer
{
	MAILCMD=$(which mail 2>/dev/null)
	if [ -z "$MAILCMD" ];
	then
		echo "mail not found, skipping"
	else
		if [ -z "$MAILTO" ];
		then
			echo "mail skipped, no MAILTO defined"
			exit $BCKFAILED
		else
			if [ -z "$LOGDIR" ];
			then
				if [ "$BCKFAILED" -eq 0 ];
				then
					echo "OK" | $MAILCMD -s "$IDHOST-$BACKUPNAME-OK" $MAILTO
				else
					echo "ERROR - no log file configured" | $MAILCMD -s "$IDHOST-$BACKUPNAME-ERROR" $MAILTO
				fi
			else
				if [ "$BCKFAILED" -eq 0 ];
				then
					echo "OK - log: $CURRENTBACKUPLOG" | $MAILCMD -s "$IDHOST-$BACKUPNAME-OK" $MAILTO
				else
					echo "ERROR - check log: $CURRENTBACKUPLOG" | $MAILCMD -s "$IDHOST-$BACKUPNAME-ERROR" $MAILTO
				fi
			fi
		fi
	fi
}

function tarball
{
	LOCKFILE=${LOCKFILE-/tmp/${BASENAMEBCK%%.*}.lock}

	if [ -z "${INCLUDEDIR}" ];
	then
		echo "what do you want to backup today?"
		BCKFAILED=1
	else
		if [ ! -f "${LOCKFILE}" ];
		then
			touch $LOCKFILE

			if [ ! -z "${EXCLUDEDIR}" ];
			then
				EXCLUDEDIR_OPT=$(for i in ${EXCLUDEDIR}; do echo "$i" | sed 's/^/--exclude=/g'; done)
			fi

			DUMPDEST="$DESTINATION/$BACKUPTS"
			mkdir -p $DUMPDEST

			if [ ! -z "${PRESCRIPT}" ];
			then
				if [ -x "${PRESCRIPT}" ];
				then
					"${PRESCRIPT}"
					if [ $? -ne 0 ];
					then
						echo "error executing pre script: ${PRESCRIPT} (return code is non zero)"
						BCKFAILED=1
						return 1
					fi
				else
					echo "please check pre script: ${PRESCRIPT}"
					BCKFAILED=1
					return 1
				fi
			fi

			if [ ! -z "${GZIP}" ] && [ "${GZIP}" != "0" ];
			then
				BACKUP_EXTENSION="tar.gz"
			else
				BACKUP_EXTENSION="tar"
			fi

			if [ "$XDEV"="true" ];
			then
				DIR_TMP=$(mktemp -d /tmp/tmp.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX)
				touch ${DIR_TMP}/.placeholder
				cd $DIR_TMP
				tar cf "$DUMPDEST/${BASENAMEBCK%%.*}.tar" .placeholder
				find $INCLUDEDIR -xdev -print0 | xargs -0 -P 1 tar rvf "$DUMPDEST/${BASENAMEBCK%%.*}.tar" $EXCLUDEDIR_OPT --ignore-failed-read --no-recursion
				cd -
				rm -fr ${DIR_TMP}
				if [ ! -z "${GZIP}" ] && [ "${GZIP}" != "0" ];
				then
					gzip -9 "$DUMPDEST/${BASENAMEBCK%%.*}.tar"
				fi
			else
				tar czvf "$DUMPDEST/${BASENAMEBCK%%.*}.${BACKUP_EXTENSION}" $INCLUDEDIR $EXCLUDEDIR_OPT --ignore-failed-read
			fi

			tar tf "$DUMPDEST/${BASENAMEBCK%%.*}.${BACKUP_EXTENSION}"

			if [ "$?" -ne 0 ];
			then
				BCKFAILED=1
			else
				BCKFAILED=0
			fi

			if [ ! -z "${POSTSCRIPT}" ];
			then
				if [ -x "${POSTSCRIPT}" ];
				then
					"${POSTSCRIPT}"
					if [ $? -ne 0 ];
					then
						echo "error executing post script: ${POSTSCRIPT} (return code is non zero)"
						BCKFAILED=1
						return 1
					fi
				else
					echo "please check post script: ${POSTSCRIPT}"
					BCKFAILED=1
					return 1
				fi
			fi

			rm $LOCKFILE
		else
			echo LOCKED: ${LOCKFILE} BACKUP SKIPPED
			BCKFAILED=1
		fi
	fi
}

function cleanup
{
	if [ -z "$RETENTION" ];
	then
		echo "cleanup skipped, no RETENTION defined"
	else
		for i in $(find $DESTINATION -type f -mtime +$RETENTION);
		do
			rm -f $i
      if [ ! -z "${S3BUCKET}" ];
      then
        $AWSBIN s3 rm ${S3BUCKET}/$(basename $i)
      fi
		done
		find $DESTINATION -type d -empty -delete
	fi
}

PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

BASEDIRBCK=$(dirname $0)
BASENAMEBCK=$(basename $0)
IDHOST=${IDHOST-$(hostname -s)}

if [ ! -z "$1" ] && [ -f "$1" ];
then
	. $1 2>/dev/null
else
	if [[ -s "$BASEDIRBCK/${BASENAMEBCK%%.*}.config" ]];
	then
		. $BASEDIRBCK/${BASENAMEBCK%%.*}.config 2>/dev/null
	else
		echo "config file missing"
		BCKFAILED=1
	fi
fi

if [ ! -z "${S3BUCKET}" ];
then
  AWSBIN=${AWSBIN-$(which aws 2>/dev/null)}
  if [ -z "$AWSBIN" ];
  then
    echo "aws not found"
    BCKFAILED=1
  fi

fi

initbck

if [ "${BCKFAILED}" -ne 1 ];
then
	tarball
	if [ ! -z "${S3BUCKET}" ];
	then
		$AWSBIN s3 cp "$DUMPDEST/${BASENAMEBCK%%.*}.${BACKUP_EXTENSION}" "${S3BUCKET}/${BASENAMEBCK%%.*}.${BACKUP_EXTENSION}"

		if [ "$?" -ne 0 ];
		then
			echo "s3 upload failed"
			BCKFAILED=1
		fi
	fi
fi

mailer
cleanup
