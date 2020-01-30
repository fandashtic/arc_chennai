
CREATE procedure sp_update_CashCustomer_rec (@CustomerID int,       
     @Address nvarchar(250),      
     @DOB datetime,       
     @ReferredBY int,      
     @MembershipCode nvarchar(30) = N'',      
     @Telephone nvarchar(30) = N'',      
     @Fax nvarchar(30) = N'',      
     @ContactPerson nvarchar(30) = N'',      
     @Discount Decimal(18,6) = 0,      
     @Category nvarchar(100))       
as      
Declare @Catid int    
select @Catid from customercategory where CategoryName like @Category    
if isnull(@Catid, 0) > 0      
begin    
 update Cash_Customer_rec set Address = @Address, DOB = @DOB, ReferredBY = @ReferredBY,      
 MembershipCode = @MembershipCode, Telephone = @Telephone, Fax = @Fax,       
 ContactPerson = @ContactPerson, Discount = @Discount, CategoryID = @Catid , flag = 1,      
 ModifiedDate = GetDate()    
 where CustomerID = @CustomerID      
end    
else    
begin    
-- customercategory     
 insert into customercategory (CategoryName, Active, CreationDate)     
 values(@Category, 1, getdate())    
 select @Catid = @@IDENTITY        
-- Cash_customer    
 update Cash_Customer_rec set Address = @Address, DOB = @DOB, ReferredBY = @ReferredBY,      
 MembershipCode = @MembershipCode, Telephone = @Telephone, Fax = @Fax,       
 ContactPerson = @ContactPerson, Discount = @Discount, CategoryID = @Catid,flag = 1,            
 ModifiedDate = GetDate()    
 where CustomerID = @CustomerID      
end    
    
  


