update  BatchActivityAffiliation set bIsActivated = 0 where lActivityId = '1090000000'

update BatchDataTaskAffiliation set bIsActivated = 0 where lActivityId = '1090000000' and lDataTaskId in ('1090000010','1090000020','1090000030','1090000040')