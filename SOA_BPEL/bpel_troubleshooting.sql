--Audit Trail
-- SQL Query to provide detail audit trail via SQL (useful when a flowtrace can't be open)

-- SQL to get bpel ECID from ID Demande : 
select ECID, ID, composite_dn 
from soa_user.composite_instance 
where title ='&BUSINESS_DEFINED_ID' 
order by created_time desc;

 --SQL to get detailed status of a bpel instance and his ECID Replace Flowtrace
select 
 ri.created_time,
  decode(ci.state,0,'STATE_INITIATED',1,'STATE_OPEN_RUNNING',2,'STATE_OPEN_SUSPENDED',3,'STATE_OPEN_FAULTED',4,'STATE_CLOSED_PENDING_CANCEL',5,'STATE_CLOSED_COMPLETED',6,'STATE_CLOSED_FAULTED', 7, 'STATE_CLOSED_CANCELLED', 8, 'STATE_CLOSED_ABORTED', 9, 'STATE_CLOSED_STALE', 10, 'STATE_CLOSED_ROLLED_BACK') state,
  decode(dm.state,0,'STATE_UNRESOLVED',1 , 'STATE_RESOLVED',2, 'STATE_HANDLED',3,'STATE_CANCELLED',4,'STATE_MAX_RECOVERED') dlvstate,
  ci.status, 
  ri.operation_name,
  ri.reference_name,  
  fault.message Error_Message,
  ci.parent_id, 
  ci.composite_name, 
  ci.component_name, 
  co.title,
  co.ecid
from 
  soa_user.composite_instance co 
inner join 
  soa_user.cube_instance ci on co.ecid=ci.ecid
inner join 
  soa_user.dlv_message dm on ci.ecid=dm.ecid
inner join 
  soa_user.reference_instance ri on co.ecid = ri.ecid
left join 
  soa_user.WI_FAULT fault on fault.cikey = CI.CIKEY
where 
  co.ecid='&ecidFromPrecedentSQL'
order by ri.created_time desc;

-- SQL Query to identify an audit trail being set at a wrong level in production

-- SQL to identify audit trail level issue
select count(au.cikey) NbRowAuditTrail, ci.ecid, ci.composite_name
from soa_user.audit_trail au
right join soa_user.cube_instance ci on ci.cikey=au.cikey
group by ci.ecid, ci.composite_name
order by nbrowaudittrail desc;

--e.g : SQL to identify last week audit trail level issue on a specific composite
select count(au.cikey) NbRowAuditTrail, ci.ecid, ci.composite_name
from soa_user.audit_trail au
right join soa_user.cube_instance ci on ci.cikey=au.cikey
where ci.creation_date < trunc(sysdate)-7 AND ci.composite_name='&compositeName'
group by ci.ecid, ci.composite_name
order by nbrowaudittrail desc;

--Timer
--Identify bpel timer not declenched for the last 7 days

select cmp.composite_dn, wi.exp_date, wi.label, cmp.title, cmp.id, ci.cikey, ci.status, cmp.state, wi.state
from soa_user.work_item wi,
soa_user.cube_instance ci,
soa_user.composite_instance cmp
where ci.cikey = wi.cikey
and cmp.id = ci.cmpst_id
and nvl(exp_date,sysdate+1) < sysdate
and wi.state <= 3
and ci.state <= 3
and wi.exp_date > sysdate - 7
order by wi.exp_date desc

--List the number of currently running composite per revision and state (check if a revision still have running instances)
select  ci.composite_name, ci.component_name, ci.composite_revision, count(*)
from  soa_user.cube_instance ci
where ci.state <= 3
group by ci.composite_name, ci.component_name, ci.composite_revision, ci.state
order by 1,2,3

--composite list / Revision / last ended instance date  :
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

