CREATE procedure sp_insert_cashcustomer (@Name nvarchar(50), 
					@Address nvarchar(250),
					@DOB datetime, 
					@ReferredBy int,
					@MembershipCode nvarchar(30) = N'',
					@Telephone nvarchar(30) = N'',
					@Fax nvarchar(30) = N'',
					@ContactPerson nvarchar(30) = N'',
					@Discount Decimal(18,6) = 0,
					@CategoryID int = 0) 
as
insert into Cash_Customer(CustomerName, Address, DOB, ReferredBy, MembershipCode, 
			  Telephone, Fax, ContactPerson, Discount, CategoryID) 
values (@Name, @Address, @DOB, @ReferredBy, @MembershipCode, @Telephone, 
	@Fax, @ContactPerson, @Discount, @CategoryID)
select @@IDENTITY
