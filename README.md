# ambari-custom-alerts

In order to set an ambari Alert for HDFS quota for user you need to have:
* An [alert definition](/spaceQuota/alert-definitions)
* An [alert Target](/spaceQuota/alert-targets)
* An [alert Group](/spaceQuota/alert-groups)

In the alert group is where you indicate to what targets (people in your organization) want to issue a notification in accordance with the alert states in your alert targets. [OK, WARNING, CRITICAL, etc]

The alert definition + script are the only mandatory files you need to configure to set an alert in ambari UI, but if you want to dispatch a notification via Email you need to have an alert target and an alert group.