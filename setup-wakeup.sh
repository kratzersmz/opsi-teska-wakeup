# -- comes from pre.conf
#!/bin/bash
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

def wakeGroup(backend, groupId)
  hostsInGroup = getClientIDsFromGroup(backend,groupId)
  try:
    hostsInGroup = hostsInGroup[0]
  except: IndexError:
    raise ValueError("No Hosts in Group with id '{0}'!".format(groupId))
  for hostInGroup in hostsInGroup:
    wakeClient(backend,host)
    sleep(0.5)  

# get current date
now = datetime.now()
# currentime in format hh-mm, e.g. 07-00, 12-30
currenttime = now.strftime("%H-%M")
# Return the day of the week as an integer, where Monday is 1 and Sunday is 7. For example, date(2002, 12, 4).isoweekday() == 3, a Wednesday. 
currentweekday = now.isoweekday()
# GROUP = backend.host_getObjects(id = clientId)[0]
# client.getDescription()

wakeups = backending.group_getObjects(id="wakeup",description="on")
isactive = True

# check if wakeup is active
try:
  test = wakeups[0]
except IndexError:
  isactive = False

if isactive:
  for wakeup in wakeups:
    # check it time fits to wakeup-name, e.g. 07-00
    if (currenttime == wakeup.id):
      wakeupdays = backending.group_getObjecs(id=wakeup, type="Hostgroup")[0]
      # check if wakeups weekday is empty. If so, assume 1..5.
      wakeupDesc = wakeupdays.getDescription()
      if (wakeupdDesc = 0) and 1..5 in currentweekday:
        wakeGroup(backending,wakeup)
      # if currentweekday is in string wakeupdays in description for wakeup, e.g. wakeup description 1,3,6 (Monday, Wednesday, Saturday) 
      elif (wakeupDesc in currentweekday):
        wakeGroup(backending,wakeup)

EOF

echo "0,10,20,30,40,50 * * * * root    /usr/bin/python /opt/teska-wakeup/wakeup.py">/etc/cron.d/teska-wakeup
chown root:root -R /etc/cron.d/teska-wakeup
chmod 0644 /etc/cron.d/teska-wakeup
systemctl restart cron
opsi-admin -d method createGroup wakeup on on on
