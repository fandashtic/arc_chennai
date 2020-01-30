CREATE procedure [dbo].[sp_get_RetailCustomer](@CustomerID nvarchar(50))         
as        
Select IsNull(SalutationID, N''), First_Name, Second_name, MembershipCode, isnull(RetailCategory, N''),         
IsNull(Occupation, N''), IsNull(BillingAddress, N''), IsNull(ShippingAddress, N''), IsNull(Customer.CityID, N''), Isnull(STDCode, N''), IsNull(PinCode, N''), IsNull(MobileNumber, N''),           
IsNull(Phone, N''), IsNull(Fax, N''), IsNull(Email, N''), IsNull(ContactPerson, N''), IsNull(DOB, N''), IsNull(ReferredBy, N''), IsNull(Awareness, N''),
isnull(TrackPoints,0) as TrackPoints,isnull(CollectedPoints,0) as CollectedPoints, IsNull(DISCOUNT,0) as DISCOUNT , CustomerID as CustomerID
From Customer
Left Outer Join City On Customer.CityID = City.CityID 
Where CustomerID = @CustomerID
--AND Customer.CityID *= City.CityID     
