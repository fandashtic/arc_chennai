Create Procedure mERP_SP_Rpt_ListInvoices(@CustomerName nvarchar(150), @Product_Code nvarchar(2550),   
            @FromDate DateTime, @ToDate DateTime, @Top nvarchar(100), @UOMDesc nvarchar(100))
AS
BEGIN
	SET DATEFORMAT DMY

	Declare @CustomerID nvarchar(100)
	Declare @Delimeter as Char(1)
	Declare @INVPrefix as nvarchar(10)  
	Declare @SQL as nvarchar(Max)	
	
	Set @Delimeter=Char(15)    
	Set @FromDate = Convert(nvarchar(10),@FromDate,103)
	Set @ToDate = Convert(nvarchar(10),@ToDate,103)
	
	If ISNUMERIC(@Top) = 1
		Set @Top = Cast(@Top as nvarchar)
	Else
		Set @Top = '10'
		
	IF isnull(@UOMDesc,'%') = '%'
		Set @UOMDesc = 'UOM2'

	Select @CustomerID = CustomerID From Customer Where Company_Name = @CustomerName		
	
	Create Table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Create Table #InvoiceID(InvoiceID int, InvoiceDate Datetime, DocumentID int)

	IF @Product_Code='%'  
		--Insert Into #tmpProd Select Product_code From Items  
		Insert Into #tmpProd Select '0'  
	Else  
		Insert Into #tmpProd Select * From dbo.sp_SplitIn2Rows(@Product_Code,@Delimeter)  
	
	Set @SQL = N'Select Distinct Top ' + Cast(@Top as nvarchar) + ' IA.InvoiceID, dbo.striptimeFromDate(IA.InvoiceDate), IA.DocumentID From InvoiceAbstract IA '
	Set @SQL = @SQL + N'Inner Join InvoiceDetail ID ON IA.InvoiceID = ID.InvoiceID '
	Set @SQL = @SQL + N'Where '
	Set @SQL = @SQL + N'IA.InvoiceType in(1,3) '
	Set @SQL = @SQL + N'and (isnull(IA.Status,0) & 128) = 0 '
	Set @SQL = @SQL + N'and dbo.StripTimeFromDate(IA.InvoiceDate) Between ''' + Convert(nvarchar(10),@FROMDATE,103) + N''' and ''' + Convert(nvarchar(10),@ToDate,103) + N''''
	
	--Set @SQL = @SQL + N' and InvoiceDate Between @inFromDate and @inFromDate '
	Set @SQL = @SQL + N' and IA.CustomerID = ''' + Cast(@CustomerID as nvarchar) + N''''
	Set @SQL = @SQL + N' and ID.Product_Code in(Select Product_Code COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpProd) '
	Set @SQL = @SQL + N' Order By dbo.striptimeFromDate(IA.InvoiceDate) Desc, IA.DocumentID Desc '
	
	--Select @SQL
	--Print @SQL
	Insert Into #InvoiceID
	Exec(@SQL)

	--Insert Into #InvoiceID
	--EXEC SP_EXECUTESQL @SQL,'@inFromDate Datetime, @inTODATE Datetime',@inFromDate = @FROMDATE, @inTODATE = @TODate
	--Select * From #InvoiceID

	SELECT @INVPrefix = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE' 

	Select IA.InvoiceID, IA.CustomerID 'Outlet ID', C.Company_Name 'Outlet Name', ID.Product_Code 'SKU Code', 
		I.ProductName 'SKU Name', 
		Case When isnull(IA.GSTFlag,0) = 0 Then @INVPrefix + CAST(IA.DocumentID AS nVARCHAR) Else isnull(IA.GSTFullDocID,'') End 'Invoice No', IA.DocReference 'Doc Ref', IA.InvoiceDate 'Date', 
		--Sum(ID.Quantity), 
		Case When @UOMDesc = 'UOM1' then SUM(ID.Quantity)/Case When IsNull(Max(I.UOM1_Conversion), 0) = 0 Then 1 Else Max(I.UOM1_Conversion) End
			When @UOMdesc = 'UOM2' then SUM(ID.Quantity)/Case When IsNull(Max(I.UOM2_Conversion), 0) = 0 Then 1 Else Max(I.UOM2_Conversion) End
			Else SUM(ID.Quantity) End as Quantity,
		Case When @UOMDesc = 'UOM1' then (Select Top 1 UOM.Description From UOM Where UOM.UOM = I.UOM1)
			When @UOMdesc = 'UOM2' then (Select Top 1 UOM.Description From UOM Where UOM.UOM = I.UOM2)
			Else (Select Top 1 UOM.Description From UOM Where UOM.UOM = I.UOM) End as UOM,		
		--UOM.Description 'UOM', 
		Sum(ID.Amount) 'Total Value'
		--Sum(IA.NetValue) 'Total Value'
	From InvoiceAbstract IA 
	Inner Join InvoiceDetail ID ON IA.InvoiceID = ID.InvoiceID
	Inner Join Customer C ON IA.CustomerID = C.CustomerID
	Inner Join Items I ON ID.Product_Code = I.Product_Code
	--Inner Join  UOM ON ID.UOM = UOM.UOM
	Where
		IA.InvoiceID in(Select InvoiceID From #InvoiceID)
		and IA.InvoiceType in(1,3)
		and (isnull(IA.Status,0) & 128) = 0
		and dbo.StripTimeFromDate(InvoiceDate) Between dbo.StripTimeFromDate(@FromDate) and dbo.StripTimeFromDate(@ToDate)
		--and Convert(nvarchar(10),IA.InvoiceDate,103) Between Convert(nvarchar(10),@FROMDATE,103) and Convert(nvarchar(10),@ToDate,103)
		and IA.CustomerID = @CustomerID
		and ID.Product_Code in(Select Product_Code COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpProd)
	Group By IA.InvoiceID, IA.CustomerID, C.Company_Name, ID.Product_Code, I.ProductName, 
		IA.GSTFullDocID, IA.DocReference, IA.InvoiceDate,I.UOM,I.UOM1,I.UOM2, --UOM.Description, 
		isnull(IA.GSTFlag,0), IA.DocumentID
	Order By dbo.striptimeFromDate(IA.InvoiceDate) Desc, IA.DocumentID Desc

	Drop Table #tmpProd
	Drop Table #InvoiceID
END
