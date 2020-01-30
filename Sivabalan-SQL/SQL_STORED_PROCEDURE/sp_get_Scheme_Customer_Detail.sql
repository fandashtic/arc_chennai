Create Procedure sp_get_Scheme_Customer_Detail  
                (@SchemeID INT)  
as  
Select SC.CustomerID,SC.AllotedAmount,C.Company_Name
from SchemeCustomers SC, Customer C
where SC.CustomerID = C.CustomerID
And schemeID=@SchemeID   
order by SC.CustomerID

