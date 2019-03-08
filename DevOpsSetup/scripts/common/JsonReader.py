import json
import sys
import os
import subprocess
import hashlib
 
cmdPrefix = "az"
objectList = open("objectList.txt", "r")
for currentObject in objectList:
  cmdGroup = str(currentObject.strip())
  cmd = cmdPrefix + " " + cmdGroup + " list"       

  process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=None, shell=True)
  output = process.communicate()
  data = json.loads(output[0])

  print("Group: " + cmdGroup)
  for rec in data:
    dataRecord = str(rec)
    dataRecordHash = hashlib.md5(dataRecord.encode())
    print(str(dataRecordHash.hexdigest()) + " " + rec['id'])
    print
    #json.dump(rec, sys.stdout, indent=4)
  
  print()
  print()

objectList.close()
    