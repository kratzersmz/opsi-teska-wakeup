#!/bin/python
# some functions grabbed from http://svn.opsi.org/opsi4.1/misc/time-driven-maintenance-tools/wake_clients_for_setup.py
from __future__ import print_function
from datetime import datetime
import os
import sys
import pprint
from OPSI.Logger import Logger, LOG_WARNING
from OPSI.Util.Ping import ping
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

def shutdownClient(backend,clientId):
  logger.info("Waking {}", clientId)
  backend.hostControlSafe_shutdown(clientId)
  time.sleep(0.5)

def shutdownGroup(backend, groupId):
  hostsInGroup = getClientIDsFromGroup(backend,groupId)
  try:
    checker = hostsInGroup[0]
  except IndexError:
    raise ValueError("No Hosts in Group with id '{0}'!".format(groupId))
  for hostInGroup in hostsInGroup:
    shutdownClient(backend,hostInGroup)

now = datetime.now()
# currentime in format hh-mm, e.g. 07-00, 12-30
currenttime = now.strftime("%H-%M")
# Return the day of the week as an integer, where Monday is 1 and Sunday is 7. For example, date(2002, 12, 4).isoweekday() == 3, a Wednesday. 
currentweekday = now.isoweekday()

shutdownsactive = backending.group_getObjects(id="shutdown",description="on")

# check if shutdown is active(True)
isactive = True
try:
  test = shutdownsactive[0]
except IndexError:
  isactive = False

if isactive:
  shutdowns = backending.group_getObjects(parentGroupId="shutdown")
  for shutdown in shutdowns:
    # check it time fits to shutdown-name, e.g. 07-00
    if (currenttime == shutdown.id):
      # check if shutdown weekday is empty. If so, assume 1..5.
      if len(shutdown.description) == 0 and int(currentweekday) in range(1,5):
        shutdownGroup(backending,shutdown.id)
      # if currentweekday is in string shutdowndays in description for shutdown, e.g. shutdown description 1,3,6 (Monday, Wednesday, Saturday) 
      elif str(currentweekday) in shutdown.description:
        shutdownGroup(backending,shutdown.id)
