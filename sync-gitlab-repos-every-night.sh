#!/bin/bash
# Script to sync the repos across the new gitlab instance.
# One should sync the database just before the migration and sync repos every night.
NOW=$(date -u '+%F%H%M%Z')
echo "Started at $NOW" | tee -a /var/opt/gitlab/transfer-logs/success-$NOW.txt
DAYS="1" # How many last days data, you would like to sync. As of now nightly.
_SINCE=$(date -u -d "$DAYS days ago" +'%F %R %Z')
sudo gitlab-rake gitlab:list_repos SINCE="$_SINCE" > /var/opt/gitlab/transfer-logs/all-repos-$NOW.txt
cat /var/opt/gitlab/transfer-logs/all-repos-$NOW.txt | sort | uniq -u | parallel --will-cite -j 30 rsync -apvz --relative --delete-before --human-readable {} gitlab.prod.example.com:/ >> /var/opt/gitlab/transfer-logs/success-$NOW.txt
echo "Finished at $(date -u '+%F%R%Z')" | tee -a /var/opt/gitlab/transfer-logs/success-$NOW.txt
