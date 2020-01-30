Create Procedure mERP_sp_MarketInfo_GetBeatSalesman(@CustomerCode nVarchar(255))
as 
Begin 
  Select Top 1 B.Description, S.Salesman_Name 
  From Customer C, Beat B, Salesman S, Beat_Salesman BS
  Where B.Active = 1 and C.DefaultBeatID = B.BeatID 
  and B.BeatID = BS.BeatId
  and BS.SalesManID = S.SalesmanID
  and C.CustomerID = @CustomerCode
End
