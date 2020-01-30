Create Procedure Sp_Get_BeatSalesMan_Scheme_ITC  
(  
 @Customer NVarChar(300)
)  
As  
Select Distinct "Beat" = B.Description
,"SalesMan"=SM.SalesMan_Name
,"Category" = (Select CategoryName  From CustomerCategory Where CategoryID = (Select CustomerCategory from customer Where CustomerID = @Customer))
From Beat_SalesMan BS , Salesman SM , Beat B  
Where (CustomerID = @Customer) 
And BS.BeatID = (Select DefaultBeatID From Customer Where CustomerID = @Customer)  
And SM.SalesmanID  = BS.SalesmanID 
And B.BeatID = BS.BeatID 
And B.Active = 1 
And SM.Active = 1

