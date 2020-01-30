Create Procedure mERP_sp_List_Customer_MarketInfo(@SalesManLst nVarchar(Max), @BeatLst nVarchar(Max), 
@FilterType Int,@Active int)   
As  
Begin  
  Declare @SqlQry Varchar(4000)
  Create table #TmpCustActive(Active int)   
  Create Table #TmpSalesManID(SalesmanID Int)  
  Create Table #TmpBeatID(BeatID Int)  
  Create Table #TempCustomer(CustomerID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,   
                             CustomerName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
                             BeatName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
                             DSName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, 
                             District nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,   
                             Sub_District nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,   
                             MarketID int,
                             MarketName nVarchar(240) COLLATE SQL_Latin1_General_CP1_CI_AS,    
                             Pop_Group nVarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS,   
                             MarketMapID int)  

  if @Active=0	
  Begin 
     Insert into #TmpCustActive values(1)
	 Insert into #TmpCustActive values(0)
  End
  Else if @Active=2
	 Insert into #TmpCustActive values(0)	
  Else
     Insert into #TmpCustActive values(@Active)	

  If Len(@SalesManLst) > 0     
    Insert into #TmpSalesManID  
    Select * from dbo.sp_SplitIn2Rows(@SalesManLst,',')  
  Else   
	Insert into #TmpSalesManID  
    Select SalesmanId From Salesman Where Active = 1   
  
  If LEN(@BeatLst) > 0   
    Insert into #TmpBeatID  
    Select * from dbo.sp_SplitIn2Rows(@BeatLst,',')  
  Else
    Insert into #TmpBeatID 
    Select BeatID From Beat Where Active = 1   
  
  Begin  
    If @FilterType = 0   
    Begin  
      Insert into #TempCustomer(CustomerID,CustomerName,BeatName, District,Sub_District,MarketID,MarketName,Pop_Group,MarketMapID)
      Select Customer.CustomerID, Company_Name as 'CustomerName', Description, 
      (select District from CustomerMarketInfo Map, MarketInfo Mas where Map.CustomerCode=Customer.CustomerID  and Mas.MMID = Map.MMID and Map.Active = 1), 
	  (select Sub_District from CustomerMarketInfo Map, MarketInfo Mas where Map.CustomerCode=Customer.CustomerID  and Mas.MMID = Map.MMID and Map.Active = 1), 
	  (select MarketID from CustomerMarketInfo Map, MarketInfo Mas where Map.CustomerCode=Customer.CustomerID  and Mas.MMID = Map.MMID and Map.Active = 1), 
      (select MarketName from CustomerMarketInfo Map, MarketInfo Mas where Map.CustomerCode=Customer.CustomerID  and Mas.MMID = Map.MMID and Map.Active = 1), 
	  (select Pop_Group from CustomerMarketInfo Map, MarketInfo Mas where Map.CustomerCode=Customer.CustomerID  and Mas.MMID = Map.MMID and Map.Active = 1), 
      (select Map.MMID from CustomerMarketInfo Map, MarketInfo Mas where Map.CustomerCode=Customer.CustomerID  and Mas.MMID = Map.MMID and Map.Active = 1) 
      From Customer
	  Left Outer Join Beat On  Customer.DefaultBeatID = Beat.BeatID--, SalesMan, Beat_Salesman
      Where Customer.Active in (select Active from #TmpCustActive)
      And CustomerCategory = 2 And Beat.Active = 1 
      Order by Beat.Description, Company_Name
--      And Beat.BeatID = Beat_Salesman.BeatID
--      And Beat_Salesman.SalesmanID = Salesman.SalesmanID
    End  
    Else If @FilterType = 1   /*Mapped Customer*/  
    Begin  
      Insert into #TempCustomer(CustomerID,CustomerName,BeatName,  District,Sub_District,MarketID,MarketName,Pop_Group,MarketMapID)  
      Select CM.CustomerID, CM.Company_Name, Beat.Description, Mas.District, Mas.Sub_District, Mas.MarketID, Mas.MarketName,  
      Mas.Pop_Group, Mas.MMID
      From Customer CM
	  Left Outer Join  Beat On CM.DefaultBeatID = Beat.BeatID
	  Inner Join CustomerMarketInfo Map On  CM.CustomerID = Map.CustomerCode
	  Inner Join MarketInfo Mas On  Mas.MMID = Map.MMID
      Where CM.CustomerCategory = 2 And CM.Active in (select Active from #TmpCustActive) And Map.Active = 1 And Beat.Active = 1 
	  Order by Beat.Description, CM.Company_Name
--	   Beat.BeatID = Beat_Salesman.BeatID And 
--    And   Beat_Salesman.SalesmanID = Salesman.SalesmanID
      
    End  
    Else if @FilterType = 2  /*UnMapped Customer*/  
    Begin  
      Insert into #TempCustomer(CustomerID, CustomerName,BeatName)  
      Select CM.CustomerID, CM.Company_name, Beat.Description
      From Customer CM
	  Left Outer Join Beat On CM.DefaultBeatID = Beat.BeatID 
      Where CM.Active in (select Active from #TmpCustActive) And   
      CM.CustomerCategory = 2 And 
      CM.CustomerID not in (select CustomerCode From CustomerMarketInfo where Active = 1 ) And Beat.Active = 1  
	  Order by Beat.Description, CM.Company_Name
--    And  Beat.BeatID = Beat_Salesman.BeatID And 
--      Beat_Salesman.SalesmanID = Salesman.SalesmanID
    End  
  End

	Update T set T.DSName = S.SalesMan_Name From #TempCustomer T , SalesMan S, Beat_Salesman BS, Beat B
	Where S.SalesManID = BS.SalesManID
	And T.BeatName = B.Description
	ANd B.BeatID = BS.BeatID
--  Select SalesmanID from #TmpSalesManID  
--  Select BeatID from #TmpBeatID 
	
	update #TempCustomer set Sub_District = 'To be defined' where Sub_District is null
	update #TempCustomer set Pop_Group = 'To be defined' where Pop_Group is null


  if Len(@SalesManLst) > 0 or Len(@BeatLst) > 0
  Begin
     Select Distinct tmpCust.* From #TempCustomer tmpCust, Beat_Salesman BS, #TmpSalesManID tmpSM, #TmpBeatID tmpBt   
	 Where tmpCust.CustomerID = BS.CustomerID   
	 And BS.SalesmanID =  tmpSM.SalesmanID 
	 And BS.BeatID = tmpBt.BeatID
	 order by  tmpCust.CustomerName
  End
  Else
  Begin  
	  /* To Display customers for whom Salesman is not defined*/	
	  Select * from
	  (
	  Select Distinct tmpCust.* From #TempCustomer tmpCust
	  Left Outer Join  Beat_Salesman BS On tmpCust.CustomerID = BS.CustomerID
	  Inner Join  #TmpSalesManID tmpSM On BS.SalesmanID = tmpSM.SalesmanID
	  Inner Join  #TmpBeatID tmpBt  On  BS.BeatID = tmpBT.BeatID    
	  union
	  Select Distinct tmpCust.* From #TempCustomer tmpCust,Beat_Salesman BS
	  Where isnull(salesmanId,0)=0
	  ) T 
	  order by  T.CustomerName
  End  
  
  Drop table #TempCustomer         
  Drop table #TmpSalesmanID  
  Drop table #TmpBeatID  
End
