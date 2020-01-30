Create Procedure sp_get_Scheme_Customer_Detail_rec    
                (@SchemeID INT)    
as    
Select schemecustomers_rec.CustomerID,AllotedAmount,Customer.Company_Name from SchemeCustomers_Rec, Customer where     
schemecustomers_rec.schemeID=@SchemeID And schemecustomers_rec.CustomerID = Case When   
IsNull(Customer.AlternateCode,N'') = N'' Then Customer.CustomerId                  
Else Customer.AlternateCode End Order by SchemeCustomers_Rec.CustomerID

