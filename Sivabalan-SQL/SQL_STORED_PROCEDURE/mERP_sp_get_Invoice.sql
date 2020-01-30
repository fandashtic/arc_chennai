Create PROCEDURE mERP_sp_get_Invoice (
				 @FromDate DATETIME,
				 @ToDate DATETIME,
			     @CustomerID NVARCHAR(15) = N'',
				 @Salesman nVarchar(500)= N'',      
				 @Beat nVarchar(500) = N'',
				 @MapSalesManID Int = 0,
				 @MapBeatID Int = 0
				) 
AS
Begin

	Create Table #tblSalesman(SalesManID Int)        
	Create Table #tblBeat(BeatID Int)
	Create Table #tmpCustomer(CustomerID nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS) 
	  

	If @SalesMan = N''        
	Begin  
		Insert Into #tblSalesman Values(0)  
		Insert InTo #tblSalesman Select SalesmanID From SalesMan Where Active = 1        
	End  
	Else        
		Insert InTo #tblSalesman Select * From sp_SplitIn2Rows(@SalesMan,N',') 

			    
	        
	If @Beat = N''         
	Begin  
		Insert Into #tblBeat Values(0)  
		Insert InTo #tblBeat Select BeatID From Beat Where Active = 1        
	End  
	Else    
		Insert InTo #tblBeat Select * From sp_SplitIn2Rows(@Beat,N',')  

		


	Insert Into #tmpCustomer
	Select Distinct CustomerID 
	From 
		Beat_Salesman 
	Where 
		SalesmanID = (Case @MapSalesManID When 0 Then SalesmanID Else @MapSalesManID End)
		And BeatID = (Case @MapBeatID When 0 Then BeatID Else @MapBeatID End)
		And isNull(CustomerID,'') <> ''

	

	SELECT 
		InvoiceAbstract.CustomerID AS "CustomerID", Company_Name, InvoiceAbstract.InvoiceID, InvoiceDate, 
		NetValue, InvoiceType, 
		"DocumentID" = Case IsNULL(GSTFlag ,0)
		When 0 then CAST(DocumentID as nvarchar)                        
		Else
			IsNULL(GSTFullDocID,'')
		End,
		ISNULL(Status, 0), Balance , invoicereference,
		DocReference,DocSerialType,
		(Select isNull(Salesman_Name,'') From Salesman Where SalesmanID = DSOS.MappedSalesmanID),
		(Select isNull(Description,'') From Beat Where BeatID = DSOS.MappedBeatID),
		 (Case isNull(InvoiceAbstract.GroupID,'') When '' Then '' Else dbo.mERP_fn_Get_GroupNames(InvoiceAbstract.GroupID) End),
		"GSTFlag" = IsNULL(GSTFlag ,0)   
		 
	FROM 
		InvoiceAbstract
		Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
		Left Outer Join tbl_mERP_DSOSTransfer DSOS On InvoiceAbstract.DocumentID = DSOS.InvoiceDocumentID
	WHERE 
		(InvoiceType = 1 OR InvoiceType = 3 OR InvoiceType = 4) 
		AND (InvoiceAbstract.Status & 128) = 0 
		AND InvoiceAbstract.CustomerID like @CustomerID
		AND InvoiceAbstract.CustomerID In(Select CustomerID From #tmpCustomer)
		AND Customer.Active = 1
		AND ISNULL(InvoiceAbstract.BeatID,0) In (Select  BeatId From #tblBeat)      
		AND ISNULL(InvoiceAbstract.SalesmanID,0) In (Select SalesmanID From #tblSalesman) 
		AND InvoiceDate BETWEEN @FromDate AND @ToDate 
		And ISNULL(Balance, 0) > 0
	ORDER BY 
		InvoiceAbstract.CustomerID

	Drop Table #tblSalesman  
	Drop Table #tblBeat  
	Drop Table #tmpCustomer

End
