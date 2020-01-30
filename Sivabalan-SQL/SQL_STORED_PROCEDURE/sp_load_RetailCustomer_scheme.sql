CREATE procedure sp_load_RetailCustomer_scheme(                
 @Category nvarchar(250),  
 @SubCategory nvarchar(250),      
 @Active integer            
 )            
AS      
BEGIN      
If @Category = N'%'
	Begin
		SELECT CustomerID "CustomerCode", Company_Name "CustomerName", N'' "SalesMan"      
		, N'' "Beat", CustomerCategory.CategoryName "CustCategory"      
		FROM Customer INNER JOIN CustomerCategory ON CustomerCategory.CategoryID = Customer.CustomerCategory    
		LEFT JOIN RetailCustomerCategory ON Customer.RetailCategory=RetailCustomerCategory.CategoryID
		WHERE CustomerCategory.CategoryID In (4,5) AND (@SubCategory=N'%' or RetailCustomerCategory.CategoryName LIKE @SubCategory)
		AND (Customer.Active = 1 Or Customer.Active = @Active)      
	End
Else
	Begin
		SELECT CustomerID "CustomerCode", Company_Name "CustomerName", N'' "SalesMan"      
		, N'' "Beat", CustomerCategory.CategoryName "CustCategory"      
		FROM Customer INNER JOIN CustomerCategory ON CustomerCategory.CategoryID = Customer.CustomerCategory    
		LEFT JOIN RetailCustomerCategory ON Customer.RetailCategory=RetailCustomerCategory.CategoryID
		WHERE CustomerCategory.CategoryName LIKE @Category AND (@SubCategory=N'%' or RetailCustomerCategory.CategoryName LIKE @SubCategory)
		AND (Customer.Active = 1 Or Customer.Active = @Active)      
	End
END 



