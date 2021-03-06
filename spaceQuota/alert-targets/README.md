##### Targets
Targets are used to notify an interested party that an alert instance has changed state. There are currently two supported target types:

* Email (SMTP)
* Simple Network Management Protocol (SNMP)
    * SNMPv1
    * SNMPv2c
    * SNMPv3
    
Any number of targets can be associated with an alert group (a grouping of definitions). When a definition in the group changes state, all associated targets will be notified. 

There is also a `global` alert target which can be used as a way to produce notifications for any alert defined in Ambari. These `global` targets are never associated with any groups; they apply to all groups and all definitions.

##### Notices
Once an alert has changed state, Ambari will determine if there are any targets that should receive a notification of the state change. These notifications, or notices, are created with an initial status of `PENDING` and will transition either to `DELIVERED` or `FAILED` once the proper dispatcher has attemped to process the notice. Dispatchers can attempt to aggregate any `PENDING` notices into a single outbound notification.

### API Summary

#### Targets
Each target type has its own set of properties that are used to configure the backend dispatcher. These properties are typically not shared between targets except for the following global properties:

* ambari.dispatch.credential.username - an optional property for specifying the username needed for the dispatcher in order to relay the notification.
* ambari.dispatch.credential.password - an optional property for specifying the password needed for the dispatcher in order to relay the notification.
* ambari.dispatch.recipients - an array of strings representing each recipient to receive an alert notification. This is a free-form string that the backend dispatcher can understand. For example, with an `EMAIL` target, this would be a list of email addresses.

The following is a list of target types and the valid properties that they accept:

* Email - any JavaMail property
* SNMP
    * ambari.dispatch.snmp.oids.body
    * ambari.dispatch.snmp.oids.subject
    * ambari.dispatch.snmp.oids.trap
    * ambari.dispatch.snmp.port
    * ambari.dispatch.snmp.version
    * ambari.dispatch.snmp.community
    * ambari.dispatch.snmp.security.username
    * ambari.dispatch.snmp.security.auth.passphrase
    * ambari.dispatch.snmp.security.priv.passphrase
    * ambari.dispatch.snmp.security.level


##### Create Request
In this example, several JavaMail properties are specified in order for this target to connect and authenticate with the SMTP relay. If the target was not global, any existing groups could be included as well when creating the target.

```sh
curl -u <AMBARI_USER>:<AMBARI_PASSWORD> -i -H 'X-Requested-By: ambari' -X POST -d @alert-targets.json http://<AMBARI_CLUSTER>:8080/api/v1/alert_targets
```
###### example
    POST api/v1/alert_targets
    
    {
      "AlertTarget": {
        "name": "Administrators",
        "description": "The Admins",
        "notification_type": "EMAIL",
        "global": true,
        "alert_states": ["WARNING","CRITICAL"],
        "properties":{
          "ambari.dispatch.credential.username":"domain_admin_user",
          "ambari.dispatch.credential.password":"domain_admin_password",
          "ambari.dispatch.recipients":["user1@domain.com","user2@domain.com"],
          "mail.smtp.host":"host.domain.com",
          "mail.smtp.port":"25",
          "mail.smtp.auth":"true",
          "mail.smtp.starttls.enable":"false",
          "mail.smtp.from":"ambari_alert_email@domain.com"
        }
      }
    }


##### Update Request
Alert targets can be updated with a partial body. Properties which are not specified are assumed to not change. 


```sh
curl -u <AMBARI_USER>:<AMBARI_PASSWORD> -i -H 'X-Requested-By: ambari' -X PUT -d @alert-targets.json http://<AMBARI_CLUSTER>:8080/api/v1/alert_targets/<ALERT_TARGET_ID>
```
###### example
    PUT api/v1/alert_targets/<target-id>
    
    {
      "AlertTarget": {
        "alert_states": ["OK", "WARNING"]
      }
    }

##### Delete Request
```sh
curl -u <AMBARI_USER>:<AMBARI_PASSWORD> -i -H 'X-Requested-By: ambari' -X DELETE http://<AMBARI_CLUSTER>:8080/api/v1/alert_targets/<ALERT_TARGET_ID>
```
###### example
    DELETE api/v1/alert_targets/<target-id>
        
##### Query Request
Targets are not associated with any aspect of a cluster. Therefore their endpoint is defined without any cluster scoping. This allows the same target to be reused for other clusters managed by Ambari.

```sh
curl -u <AMBARI_USER>:<AMBARI_PASSWORD> -i -H 'X-Requested-By: ambari' -X GET 
http://<AMBARI_CLUSTER>:8080/api/v1/alert_targets/<ALERT_TARGET_ID>
```


##### Query Response
The target from the query has the following attributes:

* It is associated with the HDFS alert group
* It will trigger for any of the alert states
<!-- --> 
###### example
    GET api/v1/alert_targets
    
    {
      "href" : "http://<server>/api/v1/alert_targets?fields=*",
      "items" : [
        {
          "href" : "http://<server>/api/v1/alert_targets/1",
          "AlertTarget" : {
            "alert_states" : [
              "OK",
              "CRITICAL",
              "UNKNOWN",
              "WARNING"
            ],
            "description" : "The Admins",
            "global" : false,
            "groups" : [
              {
                "name" : "HDFS",
                "id" : 3,
                "default" : true,
                "cluster_id" : 2
              }
            ],
            "id" : 1,
            "name" : "Administrators",
            "notification_type" : "EMAIL",
            "properties" : {
              "mail.smtp.from" : "ambari@relay.ambari.apache.org",
              "ambari.dispatch.credential.username" : "ambari",
              "mail.smtp.host" : "relay.ambari.apache.org",
              "mail.smtp.port" : "25",
              "mail.smtp.auth" : "true",
              "ambari.dispatch.credential.password" : "password",
              "ambari.dispatch.recipients" : [
                "ambari@relay.ambari.apache.org"
              ],
              "mail.smtp.starttls.enable" : "false"
            }
          }
        }
      ]
    }
    
#### Validation
Before a target is created, it is possible to have Ambari validate whether the properties being specified are correct. Ambari will attempt to execise the target and return a response with the validation information.

###### Request
Use the `validate_config` directive to have Ambari connect to the backend dispatcher in order to verify the the target's properties are valid.
Depending on your version of ambari, the following can be succesfull or not.

```sh
curl -u <AMBARI_USER>:<AMBARI_PASSWORD> -i -H 'X-Requested-By: ambari' -X POST
 http://<AMBARI_CLUSTER>:8080/api/v1/alert_targets?validate_config=true
```
###### example
    POST api/v1/alert_targets?validate_config=true
    
    {
      "AlertTarget": {
        "name": "Administrators",
        "description": "The Admins",
        "notification_type": "EMAIL",
        "global": true,
        "properties":{
          "ambari.dispatch.credential.username":"ambari",
          "ambari.dispatch.credential.password":"password",
          "ambari.dispatch.recipients":["ambari@invalid.ambari.apache.org"],
          "mail.smtp.host":"invalid.ambari.apache.org",
          "mail.smtp.port":"25",
          "mail.smtp.auth":"true",
          "mail.smtp.starttls.enable":"false",
          "mail.smtp.from":"ambari@invalid.ambari.apache.org"
        }
      }
    }    
    
###### Response
    HTTP 400 Bad Request
    
    {
      "status" : 400,
      "message" : "Invalid config: Couldn't connect to host, port: invalid.ambari.apache.org, 25; timeout -1"
    }    

#### Notices
Notices are read-only and are produced by Ambari in response to alerting events. They are used to maintain an audit trail of the outbound notifications and whether they were successfully delivered to the backend dispatcher.

##### Request
```sh
curl -u <AMBARI_USER>:<AMBARI_PASSWORD> -i -H 'X-Requested-By: ambari' -X GET
http://<AMBARI_CLUSTER>:8080/api/v1/clusters/<cluster>/alert_notices
```
###### example
    GET api/v1/clusters/<cluster>/alert_notices
    
##### Response
    {
      "href" : "http://<server>/api/v1/clusters/<server>/alert_notices?fields=*",
      "items" : [
        {
          "href" : "http://<server>/api/v1/clusters/<cluster>/alert_notices/1",
          "AlertNotice" : {
            "cluster_name" : "<cluster>",
            "history_id" : 227,
            "id" : 1,
            "notification_state" : "DELIVERED",
            "service_name" : "ZOOKEEPER",
            "target_id" : 3,
            "target_name" : "Administrators",
            "uuid" : "fef28294-bb3a-4186-b62c-1a060fa75927"
          }
        }
      ]
    }


## Reference
https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/alert-dispatching.md
