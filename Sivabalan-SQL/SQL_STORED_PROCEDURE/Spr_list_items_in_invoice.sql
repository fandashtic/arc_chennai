CREATE PROCEDURE Spr_list_items_in_invoice(@Details Nvarchar(500))
AS
Begin
	Set DateFormat DMY

	Declare @ADDNDIS AS Decimal(18,6)    
	Declare @TRADEDIS AS Decimal(18,6) 
	Declare @INVOICEID As Int
	Declare @UOM as Nvarchar(255)
	Declare @ORGInvoiceID Int

	Set @INVOICEID =  (Select Top 1 ItemValue From dbo.sp_SplitIn2Rows_WithID(@Details,',') Where RowID = 1)
	Set @UOM = (Select Top 1 ItemValue From dbo.sp_SplitIn2Rows_WithID(@Details,',') Where RowID = 2)

	SELECT @ADDNDIS = isnull(AdditionalDiscount,0), @TRADEDIS = isnull(DiscountPercentage,0) FROM InvoiceAbstract    
	WHERE InvoiceID = @INVOICEID    

	CREATE TABLE #temp(
		Product_Code Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Item Code] Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Item Name] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Batch Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		MarketSKU Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Division Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		UOM Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Original Inv - Qty] Decimal(18,6) NULL,
		Quantity Decimal(18,6) NULL,
		[Sale Price] Decimal(18, 6)  NULL,
		[Sale Tax] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Tax Suffered] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Discount Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		STCredit Decimal(18,6)  NULL,
		Total Decimal(18,6) NULL,
		[Forum Code] Nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Tax Suffered Value (%c)] Decimal(18,6) NULL,
		[Sales Tax Value (%c)] Decimal(18,6) NULL ,[HSN Number] nvarchar (15))
	Insert Into #temp
	SELECT  InvoiceDetail.Product_Code,
	"Item Code" = InvoiceDetail.Product_Code,     
	"Item Name" = Items.ProductName,     
	"Batch" = InvoiceDetail.Batch_Number, 
	"MarketSKU" = Null,
	"Division" = Null,
	"UOM" = Null,
	"Original Inv - Qty" = Null,
	"Quantity" = (Case 
		When @UOM = 'UOM2' Then Sum(cast((InvoiceDetail.Quantity / Isnull(Items.UOM2_Conversion,1)) as Decimal(18,6)))
		When @UOM = 'UOM1' Then Sum(cast((InvoiceDetail.Quantity / Isnull(Items.UOM1_Conversion,1)) as Decimal(18,6)))
		Else  SUM(InvoiceDetail.Quantity) End),     
	"Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0),     
	"Sale Tax" = CAST(Round(MAX(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2), 2) AS nvarchar) + '%',    
	"Tax Suffered" = CAST(ISNULL(MAX(InvoiceDetail.TaxSuffered), 0) AS nvarchar) + '%',    
	"Discount" = CAST(SUM(DiscountPercentage) AS nvarchar) + '%',    
	"STCredit" = Round(IsNull(Sum(InvoiceDetail.STCredit),0),2),    
	"Total" = SUM(Amount),    
	"Forum Code" = Items.Alias,   
	"Tax Suffered Value (%c)" = isnull(sum(TaxSuffAmount),0),
	"Sales Tax Value (%c)" = Isnull(Sum(STPayable + CSTPayable), 0) ,
	"HSN Number" = InvoiceDetail.HSNNumber
	
	FROM InvoiceDetail, Items    
	WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND    
	InvoiceDetail.Product_Code = Items.Product_Code    
	GROUP BY Invoicedetail.Serial,InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number,     
	InvoiceDetail.SalePrice, Items.Alias , InvoiceDetail.HSNNumber

	Update #temp Set MarketSKU = dbo.Fn_GetProductCategorys(Product_Code,4)
	Update #temp Set Division = dbo.Fn_GetProductCategorys(Product_Code,2)

	Set @ORGInvoiceID = (Select Top 1 InvoiceID from InvoiceAbstract Where cast(DocumentID as nvarchar(25))+cast(CustomerID as nvarchar(15)) = 
	(Select Top 1 cast(DocumentID as nvarchar(25))+cast(CustomerID as nvarchar(15)) from InvoiceAbstract Where InvoiceID = @INVOICEID)
	Order By InvoiceID Asc)
	
	Update T set T.[Original Inv - Qty] = O.Quantity From #temp T,
	(Select Invoicedetail.Product_Code,(Case 
		When @UOM = 'UOM2' Then Sum(cast((InvoiceDetail.Quantity / Isnull(Items.UOM2_Conversion,1)) as Decimal(18,6)))
		When @UOM = 'UOM1' Then Sum(cast((InvoiceDetail.Quantity / Isnull(Items.UOM1_Conversion,1)) as Decimal(18,6)))
		Else  SUM(InvoiceDetail.Quantity) End) Quantity 
	From Invoicedetail,Items 
	Where InvoiceID = @ORGInvoiceID
	And Items.Product_Code = Invoicedetail.Product_Code
	Group By Invoicedetail.Product_Code) O
	Where O.Product_Code = T.Product_Code

	Update T Set T.UOM = (Case When @UOM = 'UOM2' Then U.UOM2 When @UOM = 'UOM1' Then U.UOM1 Else U.UOM End) From #temp T,
	(Select Distinct I.Product_Code,U.Description UOM,U1.Description UOM1,U2.Description UOM2 From Items I,UOM U,UOM U1,UOM U2
	Where I.UOM = U.UOM
	And I.UOM1 = U1.UOM
	And I.UOM2 = U2.UOM) U
	Where T.Product_Code = U.Product_Code

	Select * From #temp

	Drop Table #temp
End
