#!/bin/bash
#
# preinst script
mkdir -p /opt/teska-wakeup
cat <<EOF > /opt/teska-wakeup/wakeup.py
#!/bin/python
from __future__ import print_function
from datetime import datetime
import os
import sys
import pprint
from OPSI.Logger import Logger, LOG_WARNING
from OPSI.Util.Ping import ping

logger = Logger()
from OPSI.Backend.BackendManager import BackendManager
backending = BackendManager()


def getClientIDsFromGroup(backend, groupName):
  group = backend.group_getObjects(id=groupName, type="HostGroup")
  try:
    group = group[0]
  except IndexError:
    raise ValueError("No HostGroup with id '{0}' found!".format(groupName))
  return [mapping.objectId for mapping in backend.objectToGroup_getObjects(groupId=group.id)]


def wakeClient(backend,clientId):
  logger.info("Waking {}", clientId)
  backend.hostControlSafe_start(clientId)



#get current date
now = datetime.now()
currenttime = now.strftime("%H-%M")


wakeups = backending.group_getObjects(parentGroupId="wakeup")
try:
  test = wakeups[0]
except IndexError:
  raise ValueError("No Wakeup Parent Group found, seems something wrong with Installation, should be created automatically! Alternative, create by hand")

for wakeup in wakeups:
  #check if current time fits wakeup time
  if (currenttime == wakeup.id):
    #get hosts in group
    hosts = getClientIDsFromGroup(backending,wakeup.id)
    for host in hosts:
      wakeClient(backending,host)
      sleep(0.5)

EOF


echo "0,10,20,30,40,50 * * * 1-5 root    /usr/bin/python /opt/teska-wakeup/wakeup.py">/etc/cron.d/teska-wakeup
chown root:root -R /etc/cron.d/teska-wakeup
chmod 0644 /etc/cron.d/teska-wakeup
systemctl restart cron

opsi-admin -d method createGroup wakeup
