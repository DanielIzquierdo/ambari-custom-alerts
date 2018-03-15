#!/bin/bash 

# dont forget to set the proper execution permission with: chmod +x cron_quota.sh

curl -X GET "http://192.168.5.133:50070/webhdfs/v1/user/daniel.izquierdo?op=GETCONTENTSUMMARY" | 
jq '.ContentSummary |  {consumed: .spaceConsumed, quota: .spaceQuota}' >> logUsers.txt