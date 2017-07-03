# commande à lancer /.../oracle_common/common/bin/wlst.sh getAllAuditLevel.py host username password
# e.g :  /.../oracle_common/common/bin/wlst.sh getAllAuditLevel.py t3://bpel.XXXX.XXX:7101 weblogic Passw0rd1!


print 'INFO: Starting the script .... Connect to a MANAGED Server (port specified is managed server port) : '

username = sys.argv[2]
password = sys.argv[3]
url= sys.argv[1]
connect(username,password,url)

# Navigate to custom tree
print 'INFO: Browsing SOA config data... Please wait... : '
custom()

cd('oracle.soa.config')
redirect('/dev/null','false')
list = ls(returnMap='true')
redirect('/dev/null','true')

#Retrieving SOA Composite Audit Levels using WLST
print 'INFO: Listing SOA component audit Levels that are not in inherit : '
for composite in list:
	   compositeObject = ObjectName(composite)
	   compositeName = compositeObject.getKeyProperty('SCAComposite')
	   componentName = compositeObject.getKeyProperty('name')
	   # Retrieving Audit Level only for objects with j2eeType SCAComposite
	   if compositeObject.getKeyProperty('j2eeType') == 'SCAComposite':
			  # Properties of compositeObject
			  compositeProperties  = mbs.getAttribute(compositeObject, 'Properties')
			  for element in compositeProperties:
				  if element.containsValue('auditLevel'):
					  componentAuditLevelValue = element.get('value')
					  print("compositeName =", componentName, " compositeAuditLevelValue =", componentAuditLevelValue)
	   if compositeObject.getKeyProperty('j2eeType') == 'SCAComposite.SCAComponent':
			  # Properties of compositeObject
			  componentProperties = mbs.getAttribute(compositeObject, 'Properties')
			  # Looping through elements in Properties
			  for element in componentProperties:
					   if element.containsValue('bpel.config.auditLevel'):
					       componentAuditLevelValue = element.get('value')
					       print("compositeName =", compositeName, " componentName =", componentName, " componentAuditLevelValue =", componentAuditLevelValue)
					   
print 'INFO: ending the script ....'
disconnect()
exit()
