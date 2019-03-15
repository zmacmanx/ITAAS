import json
import sys
import os
import subprocess
import hashlib
 
class cloudObjects:
  def __init__(self):
    self.cloudObjectsList = []
    
    with open('cloudElements.json') as json_file:  
      data = json.load(json_file)
      json_file.close()

      for rec in data: 
        self.cloudObjectsList.append(rec)

  def printCloudObjects(self):
    for data in self.cloudObjectsList:
      print(data)

  def printResult(self):
    return(self.cloudObjectsList)

class readCloudObjects:
  def __init__(self, cloudList):
    self.dataMap = cloudList
    self.cloudElements = []

    for data in self.dataMap:
      for cnt in range(0, len(data['CloudObjects'])):
        cmd = data['Command'] + " " + data['CloudObjects'][cnt]['CloudEntity'] + " " + data['CloudObjects'][cnt]['Subcommand']
        print(cmd)

        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=None, shell=True)    
        output = process.communicate()
        cloudData = json.loads(output[0])

        for rec in cloudData:
          dataRecord = str(rec)
          dataRecordHash = hashlib.md5(dataRecord.encode())
          print(str(dataRecordHash.hexdigest()))

          for xx in range(0, len(data['CloudObjects'][cnt]['Attributes'])):
            attr = data['CloudObjects'][cnt]['Attributes'][xx]

            if(data['Command'] == 'az'):
              print("    " + attr + " " + rec[attr])
            else:
              # print(str(rec))
              print(cloudData['Reservations'][0]['Instances'][0]['InstanceId'])
        print()
        print()

  def printDataMap(self):
    for data in self.dataMap:
      print(data)  
    
if __name__ == '__main__':
  refList = cloudObjects()
  # refList.printCloudObjects()

  cloudMap = readCloudObjects(refList.printResult())
  # cloudMap.printDataMap()

  # print(refList.printResult())