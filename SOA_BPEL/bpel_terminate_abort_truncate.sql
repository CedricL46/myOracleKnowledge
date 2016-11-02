
--Performance/Development Action
--Script to mass abort all running instances. (Usefull during perf testing to keep volumetry between runs)
update ps6_soainfra.composite_instance set state=16 where state=32;
update ps6_soainfra.work_item set state = 10, modify_date = sysdate where state<5;
update ps6_soainfra.cube_instance ci set ci.state = 8 , 
ci.scope_revision = (select cit.scope_revision+1 from ps6_soainfra.cube_instance cit where cit.ecid = ci.ecid) , 
ci.modify_date = sysdate  where  ci.state < 4;
update ps6_soainfra.dlv_message set state = 3 where state in (0, 2);
update ps6_soainfra.dlv_subscription set state = -1 where state=0;
COMMIT;

-- Delete all data (Only in Dev/VBox env)
truncate table soa_user.edn_clusters;
truncate table soa_user.edn_retry_count;
truncate table soa_user.edn_log_messages;
truncate table soa_user.EDN_EVENT_ERROR_STORE;
truncate table soa_user.audit_details;
truncate table soa_user.audit_trail;
truncate table soa_user.brdecisionunitofwork;
truncate table soa_user.composite_instance;
truncate table soa_user.cube_instance;
truncate table soa_user.cube_scope;
truncate table soa_user.document_dlv_msg_ref;
truncate table soa_user.dlv_message;
truncate table soa_user.dlv_subscription;
truncate table soa_user.document_ci_ref;
truncate table soa_user.instance_payload;
truncate table soa_user.headers_properties;
truncate table soa_user.reference_instance;
truncate table soa_user.composite_sensor_value;
truncate table soa_user.wi_fault;
truncate table soa_user.mediator_case_detail;
truncate table soa_user.mediator_case_instance;
truncate table soa_user.mediator_instance;
truncate table soa_user.mediator_case_detail;
truncate table soa_user.MEDIATOR_CASE_INSTANCE;
truncate table soa_user.mediator_instance;
truncate table soa_user.EDN_LOG_MESSAGES;
alter table soa_user..B2B_DATA_STORAGE disable constraint B2B_DS_DOC_ID_FK ;
truncate table soa_user..XML_DOCUMENT;
alter table soa_user..B2B_DATA_STORAGE enable constraint B2B_DS_DOC_ID_FK ;
--commit;
truncate table soa_user.wfassignee;
truncate table soa_user.wfcomments;
truncate table soa_user.wfmessageattribute;
truncate table soa_user.wfroutingslip;
truncate table soa_user.wfheaderprops;
truncate table soa_user.WFTASKASSIGNMENTSTATISTIC;
truncate table soa_user.wftaskhistory;
truncate table soa_user.work_item;
truncate table soa_user.wftaskhistory_tl;
COMMIT;
