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
#THIS COMES in future releases, so each wakeup can have different weekdays
#weekday = now.weekday()
#GROUP = backend.host_getObjects(id = clientId)[0]
#client.getDescription()

wakeups = backending.group_getObjects(id="wakeup",description="on")
isactive = True

try:
  test = wakeups[0]
except IndexError:
  isactive = False

print(isactive)
if isactive:
  for wakeup in wakeups:
    #check if current time fits wakeup time
    if (currenttime == wakeup.id):
      #get hosts in group
      hosts = getClientIDsFromGroup(backending,wakeup.id)
      for host in hosts:
        print(host)
        wakeClient(backending,host)
        sleep(0.5)
