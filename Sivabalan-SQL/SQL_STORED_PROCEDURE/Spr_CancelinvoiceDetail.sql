CREATE PROCEDURE Spr_CancelinvoiceDetail(@Details Nvarchar(500))
AS 
Begin           
	Declare @INVOICEID As Int
	Declare @UOM as Nvarchar(255)
	Set @INVOICEID =  (Select Top 1 ItemValue From dbo.sp_SplitIn2Rows_WithID(@Details,',') Where RowID = 1)
	Set @UOM = (Select Top 1 ItemValue From dbo.sp_SplitIn2Rows_WithID(@Details,',') Where RowID = 2)

	DECLARE @ADDNDIS AS Decimal(18,6)            
	DECLARE @TRADEDIS AS Decimal(18,6)            
           
	SELECT @ADDNDIS = isnull(AdditionalDiscount,0), @TRADEDIS = isnull(DiscountPercentage,0) FROM InvoiceAbstract            
	WHERE InvoiceID = @INVOICEID            

	CREATE TABLE #Temp(
		[Product_Code] Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Item Code] Nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Item Name] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Batch] Nvarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[MarketSKU] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Division] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Quantity] decimal(18, 6) NULL,
		[Volume] decimal(18, 6) NULL,
		[Sales Price] decimal(18, 6) NULL,
		[Invoice UOM] Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[Invoice Qty] decimal(18, 6) NULL,
		[Sale Tax] decimal(19, 6) NULL,
		[Tax Suffered] decimal(18, 6) NULL,
		[Discount] decimal(18, 6) NULL,
		[STCredit] decimal(18, 6) NULL,
		[Total] decimal(18, 6) NULL,
		[Forum Code] Nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		Serial Int)

	Insert Into #Temp
	SELECT  InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,             
	"Item Name" = Items.ProductName,             
	"Batch" = InvoiceDetail.Batch_Number,   
	"MarketSKU" = null,
	"Division" = Null,         
	"Quantity" =(
	Case When @UOM = 'UOM1' then SUM(InvoiceDetail.Quantity)/Case When IsNull(Items.UOM1_Conversion, 1) = 0 Then 1 Else Items.UOM1_Conversion End
	When @UOM = 'UOM2' then SUM(InvoiceDetail.Quantity)/Case When IsNull(Items.UOM2_Conversion, 1) = 0 Then 1 Else Items.UOM2_Conversion End
	Else SUM(InvoiceDetail.Quantity)
	End),        
	"Volume" = (      
	Case When @UOM = 'UOM1' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)          
	When @UOM = 'UOM2' then dbo.sp_Get_ReportingQty(SUM(InvoiceDetail.Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)          
	Else SUM(InvoiceDetail.Quantity)        
	End),          
	"Sales Price" = (    
	Case When @UOM = 'UOM1' then (InvoiceDetail.SalePrice) * Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
	When @UOM = 'UOM2' then (InvoiceDetail.SalePrice) * Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
	Else (InvoiceDetail.SalePrice)
	End),
	"Invoice UOM" = (Select Description From UOM Where UOM = InvoiceDetail.UOM),
	"Invoice Qty" = Sum(InvoiceDetail.UOMQty), 	
	"Sale Tax" = Round((Max(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2)), 2) ,            
	"Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0) ,            
	"Discount" = SUM(DiscountPercentage) ,            
	"STCredit" =             
	Round((SUM(InvoiceDetail.TaxCode) / 100.00) *            
	((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -             
	((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *            
	(@ADDNDIS / 100.00)) +            
	(((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) -             
	((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100.00))) *            
	(@TRADEDIS / 100.00))), 2),            
	"Total" = Round(SUM(Amount),2),            
	"Forum Code" = Items.Alias,           
	"Serial" = InvoiceDetail.Serial
	FROM InvoiceDetail, Items        
	WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND            
	InvoiceDetail.Product_Code = Items.Product_Code            
	GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number,   
	InvoiceDetail.SalePrice, Items.Alias, UOM1_Conversion,UOM2_Conversion,InvoiceDetail.UOM , InvoiceDetail.Serial  

	Update #temp Set MarketSKU = dbo.Fn_GetProductCategorys(Product_Code,4)
	Update #temp Set Division = dbo.Fn_GetProductCategorys(Product_Code,2)

	Select Product_Code,[Item Code],[Item Name],Batch,
	MarketSKU,Division,Quantity,Volume,[Sales Price],[Invoice UOM],
	[Invoice Qty],[Sale Tax],[Tax Suffered],Discount,STCredit,Total,[Forum Code]
	From #Temp
	Order By Serial Asc

	Drop Table #Temp
End    
