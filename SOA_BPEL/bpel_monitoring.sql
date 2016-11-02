
--Key BPEL Indicator (usefull to build a monitoring system with EM or Kibana, etc)
--Indentify bpel errors in the last 10 minutes
select ci.title, ci.ecid, cui.composite_name, cui.composite_revision, ci.created_time,
(SELECT count(1) FROM soa_user.REFERENCE_INSTANCE ri WHERE  ri.ecid = ci.ecid  and error_message is not null) +
(select count(1) from soa_user.bpel_faults_vw bf where bf.ecid = ci.ecid) as nbfaults
from soa_user.composite_instance ci
inner join soa_user.cube_instance cui on cui.ecid = ci.ecid
where (select count(1) from soa_user.bpel_faults_vw bf where bf.ecid = ci.ecid) !=0
and ci.created_time >= sysdate - 10/(24*60);


-- Monitor business faults from the last 10 minutes
SELECT ri.ecid, ri.parent_id, ri.composite_instance_id, cui.composite_name, ri.reference_name, ri.operation_name, ri.error_message, ri.created_time
from soa_user.reference_instance ri
inner join soa_user.cube_instance cui on cui.ecid = ri.ecid
WHERE error_message is not null
and ri.created_time >= sysdate - 10/(24*60)
order by ri.created_time desc;


-- Monitor all bpel faults from the last 10 minutes
select x.ecid, x.composite_name,  x.wi_creation_date, (select bf2.fault_message from soa_user.BPEL_FAULTS_VW bf2 where bf2.cikey = x.cikey and rownum=1) as FaultMessage
from
(
select max(bf.id) as Id, bf.ecid, bf.composite_name,  bf.wi_creation_date, bf.cikey
from soa_user.BPEL_FAULTS_VW bf
where bf.wi_creation_date >= sysdate - 10/(24*60)
group by bf.ecid, bf.composite_name, bf.wi_creation_date, bf.cikey
) x
inner join soa_user.cube_instance ci on ci.cikey = x.cikey
order by x.wi_creation_date desc;


--BPEL Purge
--Identify not purged instance (older than the retention period - here 69)

select
count(ecid) cnt, decode(state,0, 'STATE_INITIATED(NOK)',1,'STATE_OPEN_RUNNING(OK)',2,'STATE_OPEN_SUSPENDED(OK)',3,'STATE_OPEN_FAULTED(OK)',4,'STATE_CLOSED_PENDING_CANCEL(OK)',5,'STATE_CLOSED_COMPLETED(NOK)',6,'STATE_CLOSED_FAULTED(NOK)', 7, 'STATE_CLOSED_CANCELLED(NOK)', 8, 'STATE_CLOSED_ABORTED(NOK)', 9, 'STATE_CLOSED_STALE(NOK)', 10, 'STATE_CLOSED_ROLLED_BACK(NOK)') state
from
soa_user.cube_instance
where creation_date <= (sysdate-69)
group by state; 

--Get instance state with composite name and composite revision (to identify if this is due to undeployed composite)
select
composite_name, composite_revision, decode(state,0, 'STATE_INITIATED(NOK)',1,'STATE_OPEN_RUNNING(OK)',2,'STATE_OPEN_SUSPENDED(OK)',3,'STATE_OPEN_FAULTED(OK)',4,'STATE_CLOSED_PENDING_CANCEL(OK)',5,'STATE_CLOSED_COMPLETED(NOK)',6,'STATE_CLOSED_FAULTED(NOK)', 7, 'STATE_CLOSED_CANCELLED(NOK)', 8, 'STATE_CLOSED_ABORTED(NOK)', 9, 'STATE_CLOSED_STALE(NOK)', 10, 'STATE_CLOSED_ROLLED_BACK(NOK)') state, count(state) from
soa_user.cube_instance
where creation_date <= (sysdate-69)
group by composite_name, composite_revision, state
order by composite_name, composite_revision;

--Key BPEL Database Indicator
--Monitor DB Size

-- segments size
select segment_name,bytes/1024/1024/1024 "GB",segment_type
from dba_segments
where owner='soa_user'
order by "GB" desc;


--Table size
select segment_name,bytes/1024/1024/1024 "GB"
from dba_segments
where owner='soa_user'
and segment_type='TABLE'
order by "GB" desc;


-- Index size
select segment_name,bytes/1024/1024/1024 "GB"
from dba_segments
where owner='soa_user'
and segment_type='INDEX'
order by "GB" desc;


-- lob size
select l.table_name,l.column_name,s.bytes/1024/1024/1024 "GB"
from dba_segments s, dba_lobs l
where s.owner='soa_user'
and s.segment_type='LOBSEGMENT'
and l.segment_name=s.segment_name
order by "GB" desc;

--composite list, Revision, date of the last ended instance
select ci.composite_name, ci.composite_revision, ci.modify_date last_Modified_Date
from  soa_user.cube_instance ci
where ci.state > 4
--and ci.modify_date < trunc(sysdate -69)
and ci.modify_date=(
      select MAX(cu.modify_date)
      from soa_user.cube_instance cu
      where cu.composite_name=ci.composite_name
      and cu.composite_revision=ci.composite_revision)
group by ci.composite_name, ci.composite_revision, ci.modify_date
order by 1,2;
