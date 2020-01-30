Create Procedure sp_ListInvoiceSR_SKUWise
(@FromDate Datetime,
@ToDate Datetime, 
@CUSTOMER nvarchar(15) = N'',
@SalesMan nVarchar(500) = N'', 
@Beat nVarchar(500) = N'',  
@Channel Int = 0,  
@SubChannel Int = 0,
@ItemCode nvarchar(2000) = N'')   
As
Begin
	Create Table #tblSalesman(SalesManID Int)      
	Create Table #tblBeat(BeatID Int)      
	Create Table #tblChannel(ChannelID Int)  
	Create Table #tblSubChannel(SubChannelID Int)
	      
	IF @SalesMan = N''      
		Insert Into #tblSalesman Select SalesmanID From SalesMan Where Active = 1      
	Else      
		Insert Into #tblSalesman Select * From sp_SplitIn2Rows(@SalesMan,N',')       
	      
	IF @Beat = N''       
		Insert Into #tblBeat Select BeatID From Beat Where Active = 1      
	Else  
		Insert Into #tblBeat Select * From sp_SplitIn2Rows(@Beat,N',')      
	 
	IF @Channel = 0 
		Begin 
			Insert Into #tblChannel Values(0)
			Insert Into #tblChannel Select ChannelType From Customer_Channel Where Active = 1    
		End
	Else  
		Insert Into #tblChannel Values(@Channel)  
	 
	IF @SubChannel = 0  
		Begin
			Insert Into #tblSubChannel Values(0)
			Insert Into #tblSubChannel Select  SubChannelID From SubChannel Where Active =1    
		End
	Else  
		Insert Into #tblSubChannel Values(@SubChannel)  
	  
	  
	Create Table #tmpProd(RowID int, Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	IF @ItemCode='%'  
	   Insert Into #tmpProd Select 1, Product_Code From Items  
	Else  
	   Insert Into #tmpProd Select * From dbo.sp_SplitIn2Rows_WithID(@ItemCode,N',')  
	  
	Select
		C.CustomerID, C.Company_Name, IA.InvoiceID, IA.InvoiceDate, IA.NetValue,
		IA.InvoiceType, IA.DocumentID, IA.DocReference, IA.DocSerialType,
		"CatGrp" = Case When IsNull(IA.GroupID,'0') = '0' Then 'All Category' Else dbo.mERP_fn_Get_GroupNames(IA.GroupID) End,
		isnull(IA.GSTFullDocID, '') as GSTFullDocID, dbo.Fn_Get_SR_SKUWiseSerial(IA.InvoiceID,@ItemCode) as Serial	
	From InvoiceAbstract IA
		Inner Join InvoiceDetail ID ON IA.InvoiceID = ID.InvoiceID
		Inner Join Customer C ON IA.CustomerID = C.CustomerID
		Inner Join #tmpProd T ON ID.Product_Code = T.Product_Code
	Where
		IA.InvoiceDate Between @FromDate and @ToDate
		and IA.InvoiceType <> 4 and IA.InvoiceType <> 2
		and	IA.CustomerID = @CUSTOMER
		and IA.Status & 128 = 0
		--and ID.Product_Code In (Select Product_Code From #tmpProd)
		and isnull(ID.PendingQty,0) > 0 and ID.Flagword = 0 and ID.UOMQty > 0
		and Isnull(IA.BeatID,0) In (Select BeatID From #tblBeat)
		and Isnull(IA.SalesmanID,0) In (Select SalesmanID From #tblSalesman)
		and IsNull(C.ChannelType,0) In (Select ChannelID From #tblChannel)
		and IsNull(C.SubChannelID,0) In (Select SubChannelID From #tblSubChannel)
	Group By C.CustomerID, C.Company_Name, IA.InvoiceID, IA.InvoiceDate, IA.NetValue,
		IA.InvoiceType, IA.DocumentID, IA.DocReference, IA.DocSerialType, IA.GroupID, isnull(IA.GSTFullDocID, '')
	Order By
		C.Company_Name, IA.InvoiceID Desc
		--isnull(IA.GSTFullDocID, '')

	Drop Table #tblSalesman
	Drop Table #tblBeat
	Drop Table #tblChannel
	Drop Table #tblSubChannel
	Drop Table #tmpProd
End

