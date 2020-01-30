CREATE Procedure sp_get_Salesman    
(@SalesmanID INT)    
as    
	Select SalesmanID,Salesman_name,Address,Active,ResidentialNumber,    
	MobileNumber,Commission,IsNull(SKillLevel, 0) As SkillLevel, SMSAlert From Salesman where SalesmanID=@SalesmanID    


