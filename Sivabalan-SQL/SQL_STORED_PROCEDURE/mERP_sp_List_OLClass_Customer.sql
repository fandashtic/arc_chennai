Create Procedure mERP_sp_List_OLClass_Customer(@SalesManLst nVarchar(2000), @BeatLst nVarchar(2000), 
@FilterType Int,@Active int)   
As  
Begin  
  Declare @SqlQry Varchar(4000)
  Create table #TmpCustActive(Active int)   
  Create Table #TmpSalesManID(SalesmanID Int)  
  Create Table #TmpBeatID(BeatID Int)  
  Create Table #TempCustomer(CustomerID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,   
                             CustomerName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,   
                             CustomerType nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
                             Channel_Type_Code nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,   
                             Channel_Type_Desc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,   
                             Outlet_Type_Code nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,    
                             Outlet_Type_Desc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,   
                             SubOutlet_Type_Code nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,   
                             SubOutlet_Type_Desc nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  

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
      Insert into #TempCustomer
      Select CustomerID, Company_Name as 'CustomerName',CC.ChannelDesc,
      (select Channel_Type_Code from tbl_mERP_OLClassMapping OCMap, tbl_mERP_OLClass OCMas where OCMap.CustomerID=Customer.CustomerID  and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1), 
	  (select Channel_Type_Desc from tbl_mERP_OLClassMapping OCMap, tbl_mERP_OLClass OCMas where OCMap.CustomerID=Customer.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1), 
	  (select Outlet_Type_Code from tbl_mERP_OLClassMapping OCMap, tbl_mERP_OLClass OCMas where OCMap.CustomerID=Customer.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1),
      (select Outlet_Type_Desc from tbl_mERP_OLClassMapping OCMap ,tbl_mERP_OLClass OCMas where OCMap.CustomerID=Customer.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1), 
	  (select SubOutlet_Type_Code from tbl_mERP_OLClassMapping OCMap,tbl_mERP_OLClass OCMas where OCMap.CustomerID=Customer.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1),
      (select SubOutlet_Type_Desc from tbl_mERP_OLClassMapping OCMap ,tbl_mERP_OLClass OCMas where OCMap.CustomerID=Customer.CustomerID and OCMas.ID = OCMap.OLClassID  And OCMap.Active=1)
      From Customer 
	  Inner Join Customer_Channel CC On Customer.ChannelType=CC.ChannelType 
	  Left Outer Join Beat On Customer.DefaultBeatID = Beat.BeatID 
      Where Customer.Active in (select Active from #TmpCustActive)
      And CustomerCategory = 2
      And isnull(Customer.PreDefFlag,0) <> 1
      And isnull(Customer.DnDFlag,0) <> 1
      
      Order by Beat.Description, Company_Name
    End  
    Else If @FilterType = 1   /*Mapped Customer*/  
    Begin  
      Insert into #TempCustomer  
      Select CM.CustomerID, CM.Company_Name,CC.ChannelDesc,   
      OCMas.Channel_Type_Code, OCMas.Channel_Type_Desc,   
      OCMas.Outlet_Type_Code, OCMas.Outlet_Type_Desc,  
      OCMas.SubOutlet_Type_Code, OCMas.SubOutlet_Type_Desc
         
      From tbl_mERP_OLClassMapping OCMap
	  Inner Join Customer CM On CM.CustomerID = OCMap.CustomerID 
	  Inner Join  tbl_mERP_OLClass OCMas On OCMas.ID = OCMap.OLClassID
	  Left Outer Join Beat On CM.DefaultBeatID = Beat.BeatID
	  Inner Join Customer_Channel CC On CM.ChannelType=CC.ChannelType
      Where OCMap.Active = 1 And   
      CM.CustomerCategory = 2 And
      Isnull(CM.PreDefFlag,0) <> 1 And
      Isnull(CM.DnDFlag,0) <> 1 And
      CM.Active in (select Active from #TmpCustActive)
      
      Order by Beat.Description, CM.Company_Name
    End  
    Else if @FilterType = 2  /*UnMapped Customer*/  
    Begin  
      Insert into #TempCustomer(CustomerID, CustomerName,CustomerType)  
      Select CM.CustomerID, CM.Company_Name,CC.ChannelDesc    
      From Customer CM
	  Inner Join Customer_Channel CC On CM.ChannelType=CC.ChannelType 
	  Left Outer Join Beat On CM.DefaultBeatID = Beat.BeatID 
      Where CM.Active in (select Active from #TmpCustActive) And   
      CM.CustomerCategory = 2 And 
      Isnull(CM.PreDefFlag,0) <> 1 And
      Isnull(CM.DnDFlag,0) <> 1 And
      CM.CustomerID not in (select OCMap1.CustomerID From tbl_mERP_OLClassMapping OCMap1 where OCMap1.Active = 1 )
      Order by Beat.Description, CM.Company_Name
    End  
  End
   
--  Select SalesmanID from #TmpSalesManID  
--  Select BeatID from #TmpBeatID 

  if Len(@SalesManLst) > 0 or Len(@BeatLst) > 0
  Begin
     Select Distinct tmpCust.* From #TempCustomer tmpCust, Beat_Salesman BS   
	 Where tmpCust.CustomerID = BS.CustomerID   
	 And BS.SalesmanID in (Select SalesmanID from #TmpSalesManID)  
	 And BS.BeatID in (Select BeatID from #TmpBeatID)
	 order by  tmpCust.CustomerName
  End
  Else
  Begin  	
	  Select Distinct tmpCust.* From #TempCustomer tmpCust
	  Left Outer Join  Beat_Salesman BS  On tmpCust.CustomerID = BS.CustomerID   
	  Where  BS.SalesmanID in (Select SalesmanID from #TmpSalesManID)  
	  And BS.BeatID in (Select BeatID from #TmpBeatID)
	  order by  tmpCust.CustomerName
  End  
  
  Drop table #TempCustomer         
  Drop table #TmpSalesmanID  
  Drop table #TmpBeatID  
End
