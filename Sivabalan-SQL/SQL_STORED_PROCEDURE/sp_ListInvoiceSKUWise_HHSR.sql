Create Procedure sp_ListInvoiceSKUWise_HHSR
(@FromDate Datetime,
@ToDate Datetime, 
@CUSTOMER nvarchar(15) = N'',
@ItemCode nvarchar(2000) = N'')   
As
Begin	  
	  
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
	Group By C.CustomerID, C.Company_Name, IA.InvoiceID, IA.InvoiceDate, IA.NetValue,
		IA.InvoiceType, IA.DocumentID, IA.DocReference, IA.DocSerialType, IA.GroupID, isnull(IA.GSTFullDocID, '')
	Order By
		C.Company_Name, IA.InvoiceID Desc		
		--isnull(IA.GSTFullDocID, '')		

	Drop Table #tmpProd
End

