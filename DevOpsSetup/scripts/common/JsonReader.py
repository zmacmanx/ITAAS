import json
import sys
import os
import subprocess

cmdPrefix = "az"
objectList = open("objectList.txt", "r")
for currentObject in objectList:
  cmd = cmdPrefix + " " + currentObject + " list"       

  process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=None, shell=True)
  output = process.communicate()
  data = json.loads(output[0])

  for rec in data:
    print(rec['id'])
    #json.dump(rec, sys.stdout, indent=4)
    print

objectList.close()
exit(0)

# with open('data.txt') as json_file:  
  # data = json.load(json_file)

  # for rec in data:
    # print(rec['id'])
    # json.dump(rec, sys.stdout, indent=4)
    # print
    