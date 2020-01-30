CREATE Procedure Sp_Get_BeatSalesMan_ITC
(
 @Customer NVarChar(300),
 @nCust Integer
)
As
Select Distinct "Description" = dbo.GetBeatDescriptionFromID(BS.BeatID),BS.BeatID,"DefaultBeatID"=BS.BeatID,"SalesMan_Name"=dbo.GetSalesManNameFromID(BS.SalesManID),BS.SalesManID   
From Beat_SalesMan BS,Salesman SM,Beat B  Where   
(CustomerID = @Customer Or CustomerID = (Select CustomerID From Customer Where Company_Name=@Customer)) And  
BS.BeatID = (Select DefaultBeatID From Customer Where  
CustomerID = @Customer Or CustomerID = (Select CustomerID From Customer Where Company_Name=@Customer))  And
SM.SalesmanID  = BS.SalesmanID And
B.BeatID = BS.BeatID And
B.Active = 1 And
SM.Active = 1
