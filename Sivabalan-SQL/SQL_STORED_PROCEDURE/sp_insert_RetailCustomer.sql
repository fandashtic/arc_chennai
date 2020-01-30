CREATE procedure sp_insert_RetailCustomer (@Salutation Integer,    
@FirstName nvarchar(200),    
@SecondName nvarchar(200),    
@Customer nvarchar(150),     
@MembershipCode nvarchar(30),    
@Category Integer,    
@Occupation Integer,    
@Addr nvarchar(250),    
@Addr1 nvarchar(250),    
@City Integer,    
@Pin nvarchar(50),    
@Mobile nvarchar(50),    
@Phone nvarchar(50),    
@Fax nvarchar(100),    
@Email nvarchar(50),    
@ContactPerson nvarchar(30),    
@DOB datetime,     
@ReferredBy Integer,    
@Awareness nvarchar(100),     
@Discount Decimal(18,6),    
@Date DateTime,
@TrackPoints int=0,
@CollectedPoints Decimal(18,6)=0)    
    
as    
insert into Customer(SalutationID, First_Name, Second_name, MembershipCode, CustomerCategory,    
Occupation, BillingAddress, ShippingAddress, CityID, PinCode, MobileNumber,     
Phone, Fax, Email, ContactPerson, DOB, ReferredBy, Awareness, Discount,     
CustomerID, Company_Name, CreationDate, Active, RetailCategory,TrackPoints,CollectedPoints)
values
(@Salutation, @FirstName, @SecondName, @MembershipCode, 4, @Occupation,    
@Addr, @Addr1, @City, @Pin, @Mobile, @Phone, @Fax, @Email, @ContactPerson, @DOB,     
@ReferredBy, @Awareness, @Discount, @MembershipCode, @Customer, @Date, 1, @Category,@TrackPoints,@CollectedPoints)
    
select @@IDENTITY    


