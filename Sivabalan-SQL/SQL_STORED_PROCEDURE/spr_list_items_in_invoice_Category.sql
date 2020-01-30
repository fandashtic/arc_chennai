CREATE PROCEDURE spr_list_items_in_invoice_Category (@INVOICEID int,
						     @CATEGORY nvarchar(50))
AS
DECLARE @ADDNDIS AS Decimal(18,6)
DECLARE @TRADEDIS AS Decimal(18,6)

create table #tmpCat(Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @CATEGORY=N'%'  
   insert into #tmpCat select Category_Name from ItemCategories  
else 
Begin 
   Set @Category = Replace(@Category,Char(15),Char(44))
   insert into #tmpCat select Category_Name from ItemCategories where CategoryID in (select * from dbo.getItems(@Category))    
End

SELECT @ADDNDIS = AdditionalDiscount, @TRADEDIS = DiscountPercentage FROM InvoiceAbstract
WHERE InvoiceID = @INVOICEID

SELECT  InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code, 
	"Item Name" = Items.ProductName, 
	"Batch" = InvoiceDetail.Batch_Number,
	"Quantity" = SUM(InvoiceDetail.Quantity), 
	"Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0), 
	"Sale Tax" = CAST(Round(MAX(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2), 2) AS nvarchar) + '%',
	"Tax Suffered" = CAST(ISNULL(MAX(InvoiceDetail.TaxSuffered), 0) AS nvarchar) + '%',
	"Discount" = CAST(SUM(DiscountPercentage) AS nvarchar) + '%',
	"STCredit" = Round(IsNull(Sum(InvoiceDetail.STCredit),0),2),      
-- 	Round((SUM(InvoiceDetail.TaxCode) / 100) *
-- 	((((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) - 
-- 	((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100))) *
-- 	(@ADDNDIS / 100)) +
-- 	(((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) - 
-- 	((InvoiceDetail.SalePrice * SUM(InvoiceDetail.Quantity)) * (SUM(DiscountPercentage) / 100))) *
-- 	(@TRADEDIS / 100))), 2),
	"Total" = Round(SUM(Amount),2)
FROM InvoiceDetail, Items, ItemCategories
WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND
	InvoiceDetail.Product_Code = Items.Product_Code AND
	Items.CategoryID = ItemCategories.CategoryID AND
	ItemCategories.Category_Name in (select category_Name from #tmpCat)
GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number, 
	InvoiceDetail.SalePrice

Drop table #tmpCat


