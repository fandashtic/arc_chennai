
CREATE procedure sp_Save_cashcustomer_rec (@Name nvarchar(50),                 
     @Address nvarchar(250),                
     @DOB datetime,                 
     @ReferredBy nvarchar(100),                
     @MembershipCode nvarchar(30) = N'',                
     @Telephone nvarchar(30) = N'',                
     @Fax nvarchar(30) = N'',                
     @ContactPerson nvarchar(30) = N'',                
     @Discount Decimal(18,6) = 0,                
     @Category  nvarchar(100))                 
as                
Declare @Catid int            
Declare @Refid int          -- to get doctor id  
Declare @Dup int      
Declare @DupName nvarchar(100)      
   -- get the catid if its new      
if @Category <> N'0' and @Category <> N''
begin
   select @Catid= CategoryID from customercategory where CategoryName like @Category            
   if isnull(@Catid, 0) = 0               
   begin            
    -- customercategory             
    insert into customercategory (CategoryName, Active, CreationDate)             
    values(@Category, 1, getdate())            
    select @Catid = @@IDENTITY                
   end          
end
else begin set @Catid = 0 end
-- for doctor  
if @ReferredBy <> N'' --and @Category <> ''
begin
   select @Refid= [ID] from doctor where [Name] like @ReferredBy  
   if isnull(@Refid, N'') = 0  
   begin  
    insert into doctor (Name)   
    values(@ReferredBy)  
    select @Refid = @@IDENTITY                
   end  
end
else begin set @Refid = 0 
end
-- to chk for same forum code      
select @Dup = count(*) from Cash_Customer where membershipcode = @MembershipCode      
if @Dup > 0 -- if yes      
begin      
 -- to chk for same code and same name      
 select @DupName = CustomerName from Cash_Customer where membershipcode = @MembershipCode       
      
 if @dupname = @Name -- mem = mem, name = name      
 begin      
  update Cash_Customer set Address = @Address, DOB = @DOB, ReferredBY = @Refid,            
  MembershipCode = @MembershipCode, Telephone = @Telephone, Fax = @Fax,             
  ContactPerson = @ContactPerson, Discount = @Discount, CategoryID = @Catid,    
  ModifiedDate = GetDate()          
  where membershipcode = @MembershipCode          
 end      
 ELSE      
 BEGIN -- mem = mem, name <> name      
  update Cash_Customer set Address = @Address, DOB = @DOB, ReferredBY = @Refid,            
  MembershipCode = @MembershipCode, Telephone = @Telephone, Fax = @Fax,             
  ContactPerson = @ContactPerson, Discount = @Discount, CategoryID = @Catid,    
  ModifiedDate = GetDate()          
  where membershipcode = @MembershipCode          
 END      
end      
ELSE      
BEGIN      
 select @DupName = CustomerName from Cash_Customer where CustomerName = @Name      
 if @dupname = @Name      
 begin -- mem <> mem, name = name      
 -- select @MembershipCode + @Name      
  insert into Cash_Customer (CustomerName, Address, DOB, ReferredBy, MembershipCode,                 
  Telephone, Fax, ContactPerson, Discount, CategoryID,  Creationdate, ModifiedDate)                 
  values ((@Name + N' ' + @MembershipCode), @Address, @DOB, @Refid, @MembershipCode, @Telephone,                 
  @Fax, @ContactPerson, @Discount, @CatID,  GetDate(), GetDate())                
 end      
 else       
 begin -- mem <> mem, name <> name      
  insert into Cash_Customer (CustomerName, Address, DOB, ReferredBy, MembershipCode,                 
  Telephone, Fax, ContactPerson, Discount, CategoryID,  Creationdate, ModifiedDate)                 
  values (@Name, @Address, @DOB, @Refid, @MembershipCode, @Telephone,                 
  @Fax, @ContactPerson, @Discount, @CatID,  GetDate(), GetDate())                
 end      
END      
update cash_customer_Rec set flag = 0 where customername = @Name and membershipcode = @MembershipCode    

