
CREATE procedure sp_Insert_Customer_ZWings (        
 @MembershipCode nvarchar(30),         
 @CustomerName nvarchar(50),         
 @Address nvarchar(255),         
 @Phone nvarchar(30),         
 @Fax nvarchar(30),         
 @Discount Decimal(18,6),         
 @ContactPerson nvarchar(30),    
 @CategoryName nvarchar(50)    
     )        
as         
Declare @categoryid int    
if  @CategoryName <> N''    
begin    
 select @categoryid = categoryid from CustomerCategory where rtrim(ltrim(categoryname)) = rtrim(ltrim(@CategoryName))    
 if isnull(@Categoryid, 0) = 0     
 begin    
  insert into customercategory (categoryname, active, CreationDate) values (@CategoryName, 1, getdate())    
  select @Categoryid = @@identity    
 end    
end    
else    
begin    
 set @Categoryid = 0    
end    
DECLARE  @COU INT
SELECT @COU = COUNT(*) FROM cash_customer WHERE CustomerName = @CustomerName
IF @COU > 0 
BEGIN
SELECT -1
END
ELSE
BEGIN
insert into cash_customer (MembershipCode, CustomerName, Address, Telephone, Fax, Discount, ContactPerson, Categoryid)        
values        
(        
 @MembershipCode,         
 @CustomerName,         
 @Address,         
 @Phone,         
 @Fax,         
 @Discount,         
 @ContactPerson,    
 @Categoryid        
)        
SELECT @@IDENTITY  
END


