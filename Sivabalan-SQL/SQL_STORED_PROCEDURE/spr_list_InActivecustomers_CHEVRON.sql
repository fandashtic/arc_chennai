Create PROCEDURE [dbo].[spr_list_InActivecustomers_CHEVRON]    
AS    
SELECT CustomerID, "Customer Code" = CustomerID, "Company Name" = Company_Name,     
"Category" = CustomerCategory.CategoryName,  
"Trade Customer Category" = TradeCustomerCategory.Description    
FROM Customer
Left Outer Join CustomerCategory ON Customer.CustomerCategory = CustomerCategory.CategoryID
Left Outer Join TradeCustomerCategory ON Customer.TradeCategoryID = TradeCustomerCategory.TradeCategoryID  
WHERE Customer.CustomerCategory = CustomerCategory.CategoryID  
And Customer.TradeCategoryID = TradeCustomerCategory.TradeCategoryID  
And customer.active=0    
