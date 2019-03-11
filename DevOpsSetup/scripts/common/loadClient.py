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

  def selectCompanyById(self, CompanyId):
    #
    # Find company
    #
    for cnt in range(0, len(self.data)):
      # print("Id: " + self.data[cnt]["CompanyId"])
      if self.data[cnt]["CompanyId"] == CompanyId:
        return(self.data[cnt])
      
    return(None)

  def selectCompanyByName(self, CompanyName):
    #
    # Find company
    #
    for cnt in range(0, len(self.data)):
      # print("Id: " + self.data[cnt]["id"])
      if self.data[cnt]["CompanyName"] == CompanyName:
        return(self.data[cnt])
      
    return(None)  

class company:
  def __init__(self, CompanyId):
    self.CompanyId = CompanyId
    self.accountNumber = ""
    self.clouds = []

    with open('companyCloudList.json') as json_file:  
      data = json.load(json_file)

      for rec in data: 
        if rec["CompanyId"] == self.CompanyId:
          self.clouds.append(rec) 
          
  def printCompanyInfo(self):
    print("Company: " + self.CompanyId)
    print("Account: " + self.accountNumber)
    for cloud in self.clouds:
      print(cloud)

if __name__ == '__main__':
  companyList = companyList()
  # companyList.listCompanies()
  # selectedCompany = companyList.selectCompany("3")

  currentCompany = company("2")
  currentCompany.printCompanyInfo()