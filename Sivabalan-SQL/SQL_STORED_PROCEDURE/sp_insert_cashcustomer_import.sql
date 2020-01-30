CREATE Procedure sp_insert_cashcustomer_import  
(  
  @Name nvarchar(100),     
     @Address nvarchar(255),    
     @DOB datetime,     
     @ReferredBy nvarchar(128),    
     @MembershipCode nvarchar(30) = N'',    
     @Telephone nvarchar(30) = N'',    
     @Fax nvarchar(30) = N'',    
     @ContactPerson nvarchar(30) = N'',    
     @Discount Decimal(18,6) = 0,    
     @CategoryName nvarchar(50) = N''  
)     
as    
Declare @nRefBy int  
Declare @szMemCode nvarchar(30)  
Declare @nCatID int  
 --Referred by checking  
 if @ReferredBy <> N''  
 Begin  
 If Exists(Select [Name] From Doctor Where [Name] = @ReferredBy)  
  Select @nRefBy = [ID] From Doctor Where [Name] = @ReferredBy  
 Else  
  Begin  
   insert into Doctor (Name) values (@ReferredBy)    
   select @nRefBy = @@IDENTITY    
  End  
 End  
  
 --Category checking  
 If @CategoryName <> N''  
  If Exists(Select CategoryID from customercategory Where CategoryName = @CategoryName)  
   Select @nCatID = CategoryID from customercategory Where CategoryName = @CategoryName  
  Else  
   Begin  
		Select 0,N'Reject'  
	    GOTO SPOUT  
--    INSERT INTO [CustomerCategory]([CategoryName]) VALUES (@CategoryName)     
--    select @nCatID = @@identity    
   End  
 Else  
  Set @nCatID = 0  
  
 If Exists(Select CustomerName From Cash_Customer Where CustomerName = @Name and Membershipcode = @MembershipCode)  
 Begin   
  --Update Cash customer  
  Update Cash_Customer Set Address = @Address , DOB = @dob , ReferredBy = @nRefBy , Telephone = @Telephone   
  , Fax = @Fax , ContactPerson = @ContactPerson , Discount = @Discount , CategoryID = @nCatID  
  Where CustomerName = @Name and Membershipcode = @MembershipCode  
  Select CustomerID,N'Update' From Cash_Customer   
  Where CustomerName = @Name and Membershipcode = @MembershipCode  
 End  
 Else  
 Begin  
 --Membershipcode checking  
  If Exists(Select Membershipcode from cash_customer where Membershipcode = @MembershipCode)  
   Begin  
    Select 0,N'Reject'  
    GOTO SPOUT  
   End  
  Else If  @MembershipCode = N''  
   Begin  
    Select @szMemCode = cast(Isnull(Max(Cast(MemberShipCode as Decimal(30,0))),0)+ 1 as nvarchar)   
    From Cash_Customer   
    Where PATINDEX(N'%[^0-9]%',MEMBERSHIPCODE)=0  
   End  
  Else  
   Set @szMemCode = @MembershipCode  
  
  --Check Customer name alone exists  
  If Exists(Select CustomerName From Cash_Customer Where CustomerName = @Name)  
   Begin         
    --Update Cash customer  
    Update Cash_Customer Set Address = @Address , DOB = @dob , ReferredBy = @nRefBy , Telephone = @Telephone   
    , Fax = @Fax , ContactPerson = @ContactPerson , Discount = @Discount , CategoryID = @nCatID , Membershipcode = @szMemCode  
    Where CustomerName = @Name   
    Select CustomerID,N'Update' From Cash_Customer   
    Where CustomerName = @Name and Membershipcode = @szMemCode  
   End  
  Else  
   Begin  
    --Insert cash customer  
    insert into Cash_Customer(CustomerName, Address, DOB, ReferredBy, MembershipCode,     
        Telephone, Fax, ContactPerson, Discount, CategoryID)     
    values (@Name, @Address, @DOB, @nRefBy, @szMemCode, @Telephone,     
     @Fax, @ContactPerson, @Discount, @nCatID)    
    select @@IDENTITY  , N'Insert'  
   End  
 End  
SPOUT:  
  
  
  
  


