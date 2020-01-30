CREATE procedure sp_Update_RetailCustomer (      
@CustomerID nvarchar(50),
@Salutation Integer,
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
      
As      
      
Update Customer Set       
SalutationID = @Salutation,
RetailCategory = @Category,      
Occupation = @Occupation, BillingAddress = @Addr, ShippingAddress = @Addr1, CityID = @City,       
PinCode = @Pin, MobileNumber = @Mobile,       
Phone = @Phone, Fax = @Fax, Email = @Email, ContactPerson = @ContactPerson,       
DOB = @DOB, ReferredBy = @ReferredBy, Awareness = @Awareness, Discount = @Discount,       
ModifiedDate = @Date,TrackPoints=@TrackPoints,CollectedPoints = @CollectedPoints       
Where CustomerID = @CustomerID      
      
      
    
    
    
    
  




