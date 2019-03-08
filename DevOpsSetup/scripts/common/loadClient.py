import json
import sys

class companyList:
  def __init__(self):
    with open('companyList.json') as json_file:  
      self.data = json.load(json_file)

  def listCompanies(self):
    for rec in self.data:
      json.dump(rec, sys.stdout, indent=4)

class companyObject:
  def __init__(self, companyName):
    self.companyName = companyName
    self.accountNumber = ""

  def loadCompanyInfo(self):
    with open('companyList.json') as json_file:  
      data = json.load(json_file)

      for rec in data:
        print(rec['id'])
        # json.dump(rec, sys.stdout, indent=4)
        # print

    self.accountNumber = "xxxxxxxx"

  def printCompanyInfo(self):
    print("Company: " + self.companyName)
    print("Account: " + self.accountNumber)


if __name__ == '__main__':
  companyList = companyList()
  companyList.listCompanies()