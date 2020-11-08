# -- comes from pre.conf
#!/bin/bash
mkdir -p /opt/teska-wakeup
cat <<EOF > /opt/teska-wakeup/wakeup.py
#!/bin/python
# some functions grabbed from http://svn.opsi.org/opsi4.1/misc/time-driven-maintenance-tools/wake_clients_for_setup.py
from __future__ import print_function
from datetime import datetime
import os
import sys
import pprint
from OPSI.Logger import Logger, LOG_WARNING
from OPSI.Util.Ping import ping
import json
import time

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
  time.sleep(0.5)

def wakeGroup(backend, groupId):
  hostsInGroup = getClientIDsFromGroup(backend,groupId)
  try:
    checker = hostsInGroup[0]
  except IndexError:
    raise ValueError("No Hosts in Group with id '{0}'!".format(groupId))
  for hostInGroup in hostsInGroup:
    wakeClient(backend,hostInGroup)

now = datetime.now()
# currentime in format hh-mm, e.g. 07-00, 12-30
currenttime = now.strftime("%H-%M")
# Return the day of the week as an integer, where Monday is 1 and Sunday is 7. For example, date(2002, 12, 4).isoweekday() == 3, a Wednesday. 
currentweekday = now.isoweekday()

wakeupsactive = backending.group_getObjects(id="wakeup",description="on")

# check if wakeup is active(True)
isactive = True
try:
  test = wakeupsactive[0]
except IndexError:
  isactive = False

if isactive:
  wakeups = backending.group_getObjects(parentGroupId="wakeup")
  for wakeup in wakeups:
    # check it time fits to wakeup-name, e.g. 07-00
    if (currenttime == wakeup.id):
      # check if wakeups weekday is empty. If so, assume 1..5.
      if len(wakeup.description) == 0 and int(currentweekday) in range(1,5):
        wakeGroup(backending,wakeup.id)
      # if currentweekday is in string wakeupdays in description for wakeup, e.g. wakeup description 1,3,6 (Monday, Wednesday, Saturday) 
      elif str(currentweekday) in wakeup.description:
        wakeGroup(backending,wakeup.id)

EOF

echo "0,10,20,30,40,50 * * * * root    /usr/bin/python /opt/teska-wakeup/wakeup.py">/etc/cron.d/teska-wakeup
chown root:root -R /etc/cron.d/teska-wakeup
chmod 0644 /etc/cron.d/teska-wakeup
systemctl restart cron
opsi-admin -d method createGroup wakeup "" on
opsi-admin -d method createGroup 07-00  ""  "" wakeup
opsi-admin -d method createGroup 06-50  ""  "" wakeup
