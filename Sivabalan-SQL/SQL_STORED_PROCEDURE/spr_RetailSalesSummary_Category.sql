CREATE Procedure spr_RetailSalesSummary_Category  
(@PRODUCT_HIERARCHY nVarchar(4000),
@CATEGORY NVARCHAR(4000),  
@FROMDATE DATETIME,  
@TODATE DATETIME)  
AS  
SET NOCOUNT ON

DECLARE @Delimeter as Char(1)    
SET @Delimeter=Char(15)  

Create Table #tempCategory(CategoryID int, Status int)        
Declare @LevelID int
If @PRODUCT_HIERARCHY = '%'
	Begin
		SELECT @LevelID=0
	End
Else
	begin
		SELECT @LevelID=ItemHierarchy.HierarchyID
		From ItemCategories, ItemHierarchy  
		Where ItemCategories.Level =  ItemHierarchy.HierarchyID And  
		ItemHierarchy.HierarchyName like @PRODUCT_HIERARCHY  
	End

Exec GetLeafCategories @PRODUCT_HIERARCHY, @CATEGORY 

Create Table #SaleSummary (CategoryID int,SoldQty Decimal(18,6),GrossSalevalue Decimal(18,6),
SaleReturnQty Decimal(18,6),SaleReturnValue Decimal(18,6),Discount Decimal(18,6),SchemeSaleQty Decimal(18,6),
SchemeSaleValue Decimal(18,6),NetSoldQty Decimal(18,6),NetSaleValue Decimal(18,6))	

Insert Into #SaleSummary (CategoryID,SoldQty ,GrossSalevalue,SaleReturnQty,SaleReturnValue,Discount,SchemeSaleQty,SchemeSaleValue)
Select 

"CategoryID" =(Select CategoryId From Items Where Product_Code=Ind.Product_Code),

"Sold Qty"=Sum( Case 
	When IA.InvoiceType=2 then 
		Ind.Quantity
	Else 
		0
	End),

"Gross Sale Value"=Sum(Case
	When IA.InvoiceType=2 then 
		Ind.Amount
	Else 
		0
	End),
"Sales Return Qty"=Sum(Case
	When IA.InvoiceType=5 OR IA.InvoiceType=6 then 
		Ind.Quantity
	Else 
		0
	End),
"Sales Return Value"=Sum(Case
	When IA.InvoiceType=5 OR IA.InvoiceType=6 then 
		Ind.Amount
	Else 
		0
	End),
"Discount"=Sum(Case 
	When IA.InvoiceType=5 OR IA.InvoiceType=6 then 
		-((Ind.Quantity*Ind.SalePrice)*(IA.DiscountPercentage/100)) + Ind.DiscountValue
	When IA.InvoiceType=2 then
		((Ind.Quantity*Ind.SalePrice)*(IA.DiscountPercentage/100)) + Ind.DiscountValue
	Else
		0
	End),

"Scheme Sales Qty"=IsNull((Select Sum(Free) From SchemeSale Where Product_code=Ind.Product_Code And InvoiceID in (Select InvoiceID From InvoiceDetail Where InvoiceId=Ind.InvoiceID And SalePrice=0)),0),

"Scheme Sales value"=IsNull((Select Sum(Cost) From SchemeSale Where Product_code=Ind.Product_Code And InvoiceID in (Select InvoiceID From InvoiceDetail Where InvoiceId=Ind.InvoiceID And SalePrice=0)),0)

From InvoiceAbstract IA,InvoiceDetail Ind,Items,ItemCategories 
Where
		IA.InvoiceID=Ind.InvoiceID 
	And 	(IsNull(IA.Status,0) & 128) = 0
	And 	Ind.InvoiceID IN  (Select InvoiceID from InvoiceAbstract where InvoiceDate Between @FROMDATE AND @TODATE)   
	And	Items.product_Code = Ind.Product_Code   
	And 	Items.CategoryID = ItemCategories.CategoryID  
	And 	ItemCategories.CategoryID in (Select CategoryID from #tempCategory)
Group by Ind.InvoiceID,Ind.Product_Code

Update #SaleSummary Set 
NetSoldQty=SoldQty-SaleReturnQty-SchemeSaleQty,
NetSaleValue=GrossSalevalue-SaleReturnValue

Select 1, "Category"=dbo.fn_NLevelCategory(CategoryId,@LevelID), "Sold Qty" = Sum(SoldQty), "Gross Sale value" = Sum(GrossSalevalue),
"Sale Return Qty" = Sum(SaleReturnQty), "Sale Return Value" = Sum(SaleReturnValue), "Discount" = Sum(Discount),
"Scheme Sale Qty" = Sum(SchemeSaleQty), "Scheme Sale Value" = Sum(SchemeSaleValue), "Net Sold Qty" = Sum(NetSoldQty),
"Net Sale Value" = Sum(NetSaleValue) From #SaleSummary
Group by dbo.fn_NLevelCategory(CategoryId,@LevelID)

Drop Table #tempCategory
Drop Table #SaleSummary

SET NOCOUNT OFF



