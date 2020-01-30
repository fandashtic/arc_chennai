CREATE procedure [dbo].[sp_get_CashCustomer](@CustomerID int) as

select 	CustomerName, Address, DOB, IsNull(Doctor.Name, N''), IsNull(MembershipCode,N''),
	IsNull(TelePhone, N''), IsNull(Discount, 0), IsNull(Fax, N''), IsNull(ContactPerson, N''), 
	IsNull(CategoryName, N'')
from Cash_Customer
Left Outer Join Doctor on Cash_Customer.ReferredBY = Doctor.ID
Left Outer Join CustomerCategory on Cash_Customer.CategoryID = CustomerCategory.CategoryID
where CustomerID = @CustomerID 
--AND Cash_Customer.ReferredBY *= Doctor.ID And
--Cash_Customer.CategoryID *= CustomerCategory.CategoryID
