# opsi-teska-wakeup

## Install wakeup script via:
bash setup-wakeup.sh

Please refresh opsi-configed. New group should be visible named "wakeup".

In this group pls add subgroups with wished WOL-Time in format:
HH-MM, e.g.  05-00 or 06-30 or 13-10. Only 10 steps are allowed. E.g. 03-12 is not allowed

Place your clients in the new groups.

If school is in holidays, you can switch the wakeups off by setting group description for "wakeup" to "off". Default its set to "on"

Info:
In this setup wakeup is defaulted to Mo - Fr.

### Advanced Version
You can define for each or your wakeup an wakeupday or a range. E.g.

If wakeup 07-00 should only start on Monday, Tuesday, Friday and Sunday just rightclick 07-00, go to edit and enter in the description field 1,2,5,7

If description field is empty, script assumes wakeup from Mo - Fr.

## Install shutdown script via:
bash setup-shutdown.sh

Same as wakeup, but shutdowns computers in a group to a specific time. You can use the guide for wakeup, just replace wakeup with shutdown in your mind......
