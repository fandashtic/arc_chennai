CREATE procedure [dbo].[spr_list_InActivecustomers]
AS
SELECT CustomerID, "Customer Code" = CustomerID, "Company Name" = Company_Name, 
	"Category" = CustomerCategory.CategoryName
FROM Customer, CustomerCategory
WHERE Customer.CustomerCategory *= CustomerCategory.CategoryID and
customer.active=0
