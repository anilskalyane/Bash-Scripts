#!/bin/bash
#Set the path
BACKUP_PATH='/backup/report-backup/';
FILENAME='MYSQLTABLE_report_'$(date +%d%b)'.csv';

#Set the Mysql details
MYSQL_DB='pim_app5';
MYSQL_QUERY='SELECT * FROM ReportView';

#Set the mail config
MAIL_SUBJECT='Report Dump - '$(date +%F);
MAIL_TO_IDS='*****@*****.com, *****@*****.com, *****@*****.com';

#Taking the backupo as csv using mysqldump
mysql $MYSQL_DB -e "set sql_mode='';$MYSQL_QUERY" -B | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" > $BACKUP_PATH$FILENAME

#Sending mail with the dump file
mutt -s $MAIL_SUBJECT -a $BACKUP_PATH$FILENAME -- $MAIL_TO_IDS
