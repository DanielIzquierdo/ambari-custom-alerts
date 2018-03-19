<!---
Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements. See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
# Alert Dispatching

### Concepts

##### Groups
Alert definitions can be combined into groups. There is a default group for each service deployed in Ambari. These default groups contain each of the definitions that exist for that service. When a new definition is created for a given service, it is automatically added to the default group for that service.

To create custom groupings, any number of definitions from any service can be mixed together.

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

#### Groups

##### Create Request
A group can be created with just a name and then updated later with any of its valid properties. 

    POST api/v1/clusters/<cluster>/alert_groups
    
    {
      "AlertGroup": {
        "name": "Demo Group"
      }
    }

Or it can be created with all valid properties. In this example, a group is being associated with 2 existing targets and 3 existing definitions.

    POST api/v1/clusters/<cluster>/alert_groups

    {
      "AlertGroup": {
        "name": "Demo Group",
        "targets": [1, 2],
        "definitions": [7, 9, 14]
      }
    }


##### Update Request
    POST api/v1/clusters/<cluster>/alert_groups/<group-id>

    {
      "AlertGroup": {
        "name": "Demo Group",
        "targets": [1, 2, 3],
        "definitions": [7, 9, 14, 21, 28, 29, 30]
      }
    }
    
##### Delete Request
    DELETE api/v1/clusters/<cluster>/alert_groups/<group-id>
    
##### Query Request
    GET api/v1/clusters/<cluster>/alert_groups

##### Query Response
    {
      "href" : "http://<server>/api/v1/clusters/<cluster>/alert_groups",
      "items" : [
        {
          "href" : "http://<server>/api/v1/clusters/<cluster>/alert_groups/1",
          "AlertGroup" : {
            "cluster_name" : "<cluster>",
            "id" : 1,
            "name" : "TEZ"
          }
        },
        {
          "href" : "http://<server>/api/v1/clusters/<cluster>/alert_groups/2",
          "AlertGroup" : {
            "cluster_name" : "<cluster>",
            "id" : 2,
            "name" : "MAPREDUCE2"
          }
        },
        ...
      ]
    }

##### Query Request
    GET api/v1/clusters/<cluster>/alert_groups/<group-id>

##### Query Response
Each group contains information about the definitions and targets associated with it.

    {
      "href" : "http://<server>/api/v1/clusters/<cluster>/alert_groups/2?fields=*",
      "AlertGroup" : {
        "cluster_name" : "<cluster>",
        "default" : true,
        "definitions" : [
          {
            "name" : "mapreduce_history_server_webui",
            "label" : "History Server Web UI",
            "description" : "This host-level alert is triggered if the History Server Web UI is unreachable.",
            "enabled" : true,
            "service_name" : "MAPREDUCE2",
            "component_name" : "HISTORYSERVER",
            "id" : 1,
            "source_type" : "WEB"
          },
          ...
        ],
        "id" : 3,
        "name" : "MAPREDUCE2",
        "targets" : [
          {
            "name" : "Administrators",
            "id" : 1,
            "description" : "The Admins",
            "global" : false,
            "notification_type" : "EMAIL"
          }
        ]
      }
    }



## Reference
https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/alert-dispatching.md
