Create Procedure mERP_sp_Get_OLClassExport_CustInfo(@CustomerID nVarchar(50))  
As  
Begin  
  Select Top 1 CustChn.ChannelDesc, Case CustMas.Active When 0 Then 'No' Else 'Yes' End 'Active', CustMas.BillingAddress,  Beat.Description,  BS.Salesman_name 
  From Customer CustMas
  Inner Join  Customer_Channel CustChn On CustMas.ChannelType = CustChn.ChannelType
  Left Outer Join Beat On CustMas.DefaultBeatId = Beat.BeatID
  Left Outer Join (Select S.Salesman_Name, BS.BeatID From 
          Beat_Salesman BS, Salesman S Where BS.SalesmanID = S.SalesmanID 
          Group By S.Salesman_Name, BS.BeatID) BS On CustMas.DefaultBeatId = BS.BeatID 
  Where CustMas.CustomerID = @CustomerID And Beat.BeatID = BS.BeatID 
End
