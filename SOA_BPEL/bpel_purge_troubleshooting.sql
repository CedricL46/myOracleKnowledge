--TroubleShooting BPEL Purge
--Not purged instances
SELECT
	ci.ecid AS ecid,
	decode(ci.state,0, 'STATE_INITIATED(NOK)',1,'STATE_OPEN_RUNNING(OK)',2,'STATE_OPEN_SUSPENDED(OK)',3,'STATE_OPEN_FAULTED(OK)',4,'STATE_CLOSED_PENDING_CANCEL(OK)',5,'STATE_CLOSED_COMPLETED(NOK)',6,'STATE_CLOSED_FAULTED(NOK)', 7, 'STATE_CLOSED_CANCELLED(NOK)', 8, 'STATE_CLOSED_ABORTED(NOK)', 9, 'STATE_CLOSED_STALE(NOK)', 10, 'STATE_CLOSED_ROLLED_BACK(NOK)') AS state,
	ci.composite_name AS composite_name,
	ci.composite_revision AS composite_revision,
	TO_CHAR(ci.creation_date at TIME ZONE(tz_offset('Europe/Paris')), 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') AS creation_time,
	TO_CHAR(ci.modify_date at TIME ZONE(tz_offset('Europe/Paris')), 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') AS modify_date
FROM
	ps6_soainfra.cube_instance ci
where
	ci.modify_date <= (sysdate-72)
order by ci.modify_date desc;  

--not purged DLVMessage by types
SELECT
        dv.ecid AS ecid,
        dv.composite_name AS composite_name,
        dv.cikey,
        decode(dv.state,0,'STATE_UNRESOLVED',1,'STATE_RESOLVED',2,'STATE_HANDLED',3,'STATE_CANCELLED',4,'STATE_MAX_RECOVERED') AS dlv_state,
        decode(dv.dlv_type,1,'Invoke',2,'Callback') AS dlv_type
from
        ps6_soainfra.dlv_message dv
where dv.receive_date <= (sysdate-72)
group by dv.ecid, dv.composite_name, dv.cikey, dv.state, dv.dlv_type;

-- not purged DLVMessages 2 482 692
select
        count(dv.ecid)
from
        ps6_soainfra.dlv_message dv
where dv.receive_date <= (sysdate-72);
        
select count (task.ecid) from ps6_soainfra.wftask task where task.state IS NOT NULL AND
task.state NOT IN ('DELETED','ERRORED','EXPIRED','STALE','WITHDRAWN') and
task.ecid='744b95bf0760ff19:6970c490:154ca502300:-7ffe-00000000007e353f';

SELECT unique mi.ECID from ps6_soainfra.MEDIATOR_INSTANCE mi
where mi.ECID ='744b95bf0760ff19:6970c490:154ca502300:-7ffe-00000000007e353f'
and mi.component_state between 4 and 15;

SELECT dlv.ECID from ps6_soainfra.DLV_MESSAGE dlv
WHERE dlv.ECID = '744b95bf0760ff19:6970c490:154ca502300:-7ffe-00000000007e353f'
and dlv.dlv_type=1 and dlv.state in (0,1);

select unique ecid, state from ps6_soainfra.composite_instance
where (bitand(state,127)=1 or bitand(state,6)=2 or bitand(state,16)=16 or
bitand(state,64)=64 or bitand(state,127)=32)
and ecid='744b95bf0760ff19:6970c490:154ca502300:-7ffe-00000000007e353f';

--Recoverable message not purgeable (6)
select *
from ps6_soainfra.dlv_message dlv 
inner join ps6_soainfra.cube_instance ci on ci.ecid = dlv.ecid
where ci.state < 5 
and ci.creation_date <= (sysdate-72) 
and ci.ecid=dlv.ecid
and dlv.dlv_type=1 
AND dlv.STATE in (0,1);

--purgeable instance 394 059
select count(ci.ecid) from ps6_soainfra.cube_instance ci 
where ci.state >= 5 
and ci.MODIFY_DATE <= (sysdate-72);

-- Running cube instance records, NOT eligible for purging: 266 828
select count(ci.ecid) 
from ps6_soainfra.cube_instance ci 
where ci.state < 5 
and ci.MODIFY_DATE <= (sysdate-72);

--not purged DLVMessage by types
SELECT
        dv.composite_name AS composite_name,
        decode(dv.state,0,'STATE_UNRESOLVED',1,'STATE_RESOLVED',2,'STATE_HANDLED',3,'STATE_CANCELLED',4,'STATE_MAX_RECOVERED') AS dlv_state,
        decode(dv.dlv_type,1,'Invoke',2,'Callback') AS dlv_type
from
        ps6_soainfra.dlv_message dv
where dv.receive_date <= (sysdate-72)
group by dv.composite_name, dv.state, dv.dlv_type;

-- not purged DLVMessages Prod : 2 482 692 | Copie : 11 694 629 | Après purge std : 1 622 451 | après abort : 1 346 225
select
        count(dv.ecid)
from
        ps6_soainfra.dlv_message dv
where dv.receive_date <= (trunc(sysdate)-120);

--All Older instances | Après purge std : 518 665
select count(ci.ecid) from ps6_soainfra.cube_instance ci 
where ci.modify_date <= (trunc(sysdate)-118);

--purgeable instance | Après purge std : 321 002
select count(ci.ecid) from ps6_soainfra.cube_instance ci 
where ci.state >= 5 
and ci.MODIFY_DATE <= (trunc(sysdate)-118);

-- Running cube instance records, NOT eligible for purging:
select count(ci.ecid) 
from ps6_soainfra.cube_instance ci 
where ci.state < 5 
and ci.MODIFY_DATE <= (trunc(sysdate)-118);

--Force all old instance(>100) to a purgeable state
update ps6_soainfra.composite_instance set state=16 where created_time < trunc(sysdate)-100;
update ps6_soainfra.work_item set state = 10, modify_date = sysdate where  modify_date < trunc(sysdate)-100;
update ps6_soainfra.cube_instance ci set ci.state = 8 , 
ci.modify_date = sysdate - 70  where  ci.creation_date < trunc(sysdate)-100;
update ps6_soainfra.dlv_message set state = 3 where  receive_date < trunc(sysdate)-100;
update ps6_soainfra.dlv_subscription set state = -1 where subscription_date < trunc(sysdate)-100;
COMMIT;
--Delete unpurgeable element
delete from ps6_soainfra.xml_document xd where doc_partition_date < trunc(sysdate)-100;
delete from ps6_soainfra.instance_payload ip where created_time < trunc(sysdate)-100;
delete from ps6_soainfra.headers_properties hp where modify_date < trunc(sysdate)-100;
delete from ps6_soainfra.document_dlv_msg_ref ddmr where dlv_partition_date < trunc(sysdate)-100;
delete from ps6_soainfra.dlv_message dm where  receive_date < trunc(sysdate)-100;
COMMIT;
