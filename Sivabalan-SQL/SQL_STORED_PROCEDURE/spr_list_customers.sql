CREATE procedure [dbo].[spr_list_customers]
AS
SELECT CustomerID, "Customer Code" = CustomerID, "Company Name" = Company_Name, 
	"Category" = CustomerCategory.CategoryName
FROM Customer, CustomerCategory
WHERE Customer.CustomerCategory *= CustomerCategory.CategoryID
And Customer.CustomerCategory Not In (4,5)
