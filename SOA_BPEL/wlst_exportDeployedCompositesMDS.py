# commande à lancer /.../oracle_common/common/bin/wlst.sh xxxx.py host username password
# e.g :  /.../oracle_common/common/bin/wlst.sh xxxx.py t3://bpel.XXXX.XXX:7101 weblogic Passw0rd1!


print 'INFO: Starting the script .... '

username = sys.argv[2]
password = sys.argv[3]
url= sys.argv[1]
connect(username,password,url)

domainRuntime()
deploy('ShareSoaInfraPartition','/tmp/ShareSoaInfraPartition.ear',upload='true')
exportMetadata(application='ShareSoaInfraPartition',server='SOA-admin-BPEL-LINKY',toLocation='/tmp/mds/',docs='/deployed-composites/deployed-composites.xml')


print 'ending the script ....'
disconnect()
exit()
