CREATE Procedure sp_GetCompanyName (@ForumCode nvarchar(100))  
as  
  
declare @CompanyName nvarchar(255)  
  
Select @CompanyName = Company_Name from Customer where AlternateCode = @ForumCode  
if Isnull(@CompanyName, N'') = N''   
 Select @CompanyName = Vendor_Name from Vendors where AlternateCode = @ForumCode 
if Isnull(@CompanyName, N'') = N''   
 Select @CompanyName = WareHouse_Name from WareHouse where ForumID = @ForumCode  
    
Select @CompanyName  


