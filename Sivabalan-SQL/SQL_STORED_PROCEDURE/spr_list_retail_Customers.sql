CREATE PROCEDURE [dbo].[spr_list_retail_Customers]    
AS  
SELECT CustomerID, CustomerID, "Customer Name" = Company_Name, "Membership Code" = MembershipCode,  
"Category" = CategoryName, "Phone Number" = Phone, "Fax" = Fax, "Contact Person" = ContactPerson,  
"Referred By" = Doctor.Name, --"Discount Offered" = Discount, 
BillingAddress, DOB,
"Collected Points" = Customer.CollectedPoints 
FROM Customer
Left Outer Join CustomerCategory ON Customer.CustomerCategory = CustomerCategory.CategoryID
Left Outer Join Doctor ON Customer.ReferredBy = DOCTOR.ID
WHERE Customer.CustomerCategory = CustomerCategory.CategoryID And  
CustomerCategory = 4
And Customer.ReferredBy = Doctor.ID
