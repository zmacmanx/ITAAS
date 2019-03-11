import json
import sys

class companyList:
  def __init__(self):
    with open('companyList.json') as json_file:  
      self.data = json.load(json_file)

  def listCompanies(self):
    for rec in self.data:
      json.dump(rec, sys.stdout, indent=4)
    print()

class companyObject:
  def __init__(self, companyId):
    self.companyId = companyId
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
    print("Company: " + self.companyId)
    print("Account: " + self.accountNumber)

if __name__ == '__main__':
  companyList = companyList()
  companyList.listCompanies()

  # Find company
  print("Id: " + companyList.data[1]["id"])
