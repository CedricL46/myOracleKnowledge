# commande à lancer /.../oracle_common/common/bin/wlst.sh xxxx.py host username password
# e.g :  /.../oracle_common/common/bin/wlst.sh xxxxx.py t3://bpel.XXXX.XXX:7101 weblogic Passw0rd1!

print 'starting the script ....'
wlsSecureFolder = '/appli/projects/LINKY/security/'


username = sys.argv[2]
password = sys.argv[3]
url= sys.argv[1]
connect(username,password,url)

domainRuntime()

BPELConfigMBean = ObjectName('oracle.as.soainfra.config:Location=SOA-rin-a-1-BPEL-LINKY,name=bpel,type=BPELConfig,Application=soa-infra')
print BPELConfigMBean
expRetryDelay=Attribute('ExpirationRetryDelay',300)#default is 120
expMaxRetry=Attribute('ExpirationMaxRetry',10)#default is 5
mbs.setAttribute(BPELConfigMBean,expRetryDelay)
mbs.setAttribute(BPELConfigMBean,expMaxRetry)

print 'ending the script ....'
disconnect()
exit()
