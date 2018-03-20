# Alert definitions

Push the new alert via Ambari REST API. (modify the variable `{edit_user_name}` on [alerts.json]((/spaceQuota/alert-definition/alerts.json) first)

```sh
curl -u <AMBARI_USER>:<AMBARI_PASSWORD> -i -H 'X-Requested-By: ambari' -X POST -d @alerts.json http://<AMBARI_CLUSTER>:8080/api/v1/clusters/<CLUSTER_NAME>/alert_definitions
```
You will also need to copy the python script in /var/lib/ambari-server/resources/host_scripts 
you need to do this step (copy) only once, unless you want a different behaviour for a specific user:

```sh
cp -f spaceQuota.py   /var/lib/ambari-server/resources/host_scripts
```

then restart the ambari-server:

```sh
ambari-server restart
```

After restart the script will be pushed in /var/lib/ambari-agent/cache/host_scripts on the different hosts.

## Update Alert Definition

You can find the ID of your alerts by running
```sh
curl -u <AMBARI_USER>:<AMBARI_PASSWORD> -i -H 'X-Requested-By: ambari' -X GET http://<AMBARI_CLUSTER>:8080/api/v1/clusters/<CLUSTER_NAME>/alert_definitions
```

If we assume, that your alert is id 103. YOu can force the alert to run by
```sh
curl -u <AMBARI_USER>:<AMBARI_PASSWORD> -i -H 'X-Requested-By: ambari' -X PUT  http://<AMBARI_CLUSTER>:8080/api/v1/clusters/<CLUSTER_NAME>/alert_definitions/103?run_now=true
```


# Monitor folder for Space Quota

This alert will generate a warning if the space in your folder is above 70% of your quota and a critical if you are above 90%.

You need to modify the value of location.quota in the parameter section to match the folder that you would like to monitor.
```sh
              "name": "location.quota",
              "display_name": "Path to monitor",
              "value": "/application/digital",
```
Similarly if you want to change the threshold, modify the value for **quota.warning.threshold** and **quota.critical.threshold**.

## How to use space Quota in HDFS

The hdfs admin can create Quota. There is two types of quota: 
- space quota ( how much storage can be used )
- file quota ( how many files can be created )

This alert only check the space quota, it doesn't look into file quota.

Set a quota of 2GB on folder /application/digital - value are in bytes = 2*1024*1024*1024 = 2147483648
```sh
hdfs dfsadmin -setSpaceQuota 2147483648  /application/digital
```
NB: Quota works on raw storage

Check the quota ( can be run by any user w/ read permission on folder ) 
```sh
hdfs dfs -count -q /application/digital
       none             inf      2147483648      1832910848            1            1          104857600 /application/digital
                                    |               |
                                  Quota           Usage
```

Delete quota
```sh
hdfs dfsadmin -clrSpaceQuota /application/digital
```
