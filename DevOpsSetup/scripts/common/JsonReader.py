import json
import sys
import os
import subprocess
import hashlib
 
class cloudObjects:
  def __init__(self):
    self.cloudObjectsList = []
    self.cloudCategories = []
    self.cloudElements = []

    data = open("objectList.txt", "r")
    for currentObject in data:
      self.cloudCategories.append(str(currentObject.strip()))
    data.close()

    data = open("elementList.txt", "r")
    for currentObject in data:
      self.cloudElements.append(str(currentObject.strip()))
    data.close()

    for clist in self.cloudCategories:
      tmp1 = clist.split(":")
      cloud = tmp1[0]
      cmd = tmp1[1]
      scmd = tmp1[2]
      category = tmp1[3]

      for elist in self.cloudElements:
        tmp2 = elist.split(":")
        element = ""

        if tmp1[0] == tmp2[0]:
          if tmp2[1] == "*":
            element = tmp2[2]
          else:
            if tmp2[1] == tmp1[3]:
              element = tmp2[2]
        
        if element != "":
          idx = cloud + ":" + cmd + ":" + scmd + ":" + category + ":" + element
          self.cloudObjectsList.append(idx)

  def printCloudObjects(self):
    for data in self.cloudObjectsList:
      print(data)

  def printResult(self):
    return(self.cloudObjectsList)

class readCloudObjects:
  def __init__(self, cloudList):
    self.dataMap = []
    tarr = []
    cmd = ""

    for clist in cloudList:
      tmp = clist.split(":")
      cmdTmp = tmp[1] + " " + tmp[3] + " " + tmp[2]

      if(cmd == ""):
        cmd = cmdTmp

      if cmd == cmdTmp:
        tarr.append(tmp[4])
      else:
        print("Working On " + tmp[0] + tmp[3])
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=None, shell=True)
        output = process.communicate()
        data = json.loads(output[0])

        for rec in data:
          dataRecord = str(rec)
          dataRecordHash = hashlib.md5(dataRecord.encode())
          print(str(dataRecordHash.hexdigest()))
          for ele in tarr:
            print("       " + ele + ": " + rec[ele])

        # json.dump(rec, sys.stdout, indent=4)
      
        cmd = cmdTmp
        for cnt in range(len(tarr), 0):
          tarr[(cnt-1)].pop()
        tarr.append(tmp[4])
        print()
        print()
    
if __name__ == '__main__':
  refList = cloudObjects()
  readCloudObjects(refList.printResult())

  print(refList.printResult())