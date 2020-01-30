CREATE procedure sp_update_CashCustomer (@CustomerID int, 
					@Address nvarchar(250),
					@DOB datetime, 
					@ReferredBY int,
					@MembershipCode nvarchar(30) = N'',
					@Telephone nvarchar(30) = N'',
					@Fax nvarchar(30) = N'',
					@ContactPerson nvarchar(30) = N'',
					@Discount Decimal(18,6) = 0,
					@CategoryID int = 0) 
as
update Cash_Customer set Address = @Address, DOB = @DOB, ReferredBY = @ReferredBY,
MembershipCode = @MembershipCode, Telephone = @Telephone, Fax = @Fax, 
ContactPerson = @ContactPerson, Discount = @Discount, CategoryID = @CategoryID
where CustomerID = @CustomerID
