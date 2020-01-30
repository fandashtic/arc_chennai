CREATE procedure [dbo].[spr_sales_by_ItemCategory_Report]
                (@ProHier nvarchar(255), @CATNAME nvarchar (4000),
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
As

DECLARE @UOMCOUNT int
DECLARE @UOM1COUNT int
DECLARE @UOM2COUNT int
Declare @UOMDESC nvarchar(50)
Declare @UOM1 nvarchar(50)
Declare @UOM2 nvarchar(50)

Create Table #tempCategory (CategoryID Int, Status Int)
Exec GetLeafCategories @ProHier, @CATNAME
Select Distinct CategoryID InTo #temp From #tempCategory

Select @UOMCOUNT = Count(Distinct Items.UOM)
From Items, InvoiceDetail, #temp, InvoiceAbstract
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
InvoiceDetail.Product_Code = Items.Product_Code AND
Items.CategoryID = #temp.CategoryID AND
InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND
InvoiceAbstract.Status & 192 = 0 AND
InvoiceAbstract.InvoiceType in (1, 2, 3, 4)

Select @UOM1COUNT = Count(Distinct Items.UOM1) 
From Items, #temp, InvoiceAbstract, InvoiceDetail
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
InvoiceDetail.Product_Code = Items.Product_Code AND
Items.CategoryID = #temp.CategoryID AND
InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND
InvoiceAbstract.Status & 192 = 0 AND
InvoiceAbstract.InvoiceType in (1, 2, 3, 4)

Select @UOM2COUNT = Count(Distinct Items.UOM2)
From Items, #temp, InvoiceAbstract, InvoiceDetail
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
InvoiceDetail.Product_Code = Items.Product_Code AND
Items.CategoryID = #temp.CategoryID AND
InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND
InvoiceAbstract.Status & 192 = 0 AND
InvoiceAbstract.InvoiceType in (1, 2, 3, 4)

If @UOMCOUNT <= 1 And @UOM1COUNT <= 1 And @UOM2COUNT <= 1
Begin
	Select Top 1 @UOMDESC = UOM.Description 
	From Items
	Inner Join #temp ON Items.CategoryID = #temp.CategoryID
	Inner Join InvoiceDetail ON Items.Product_Code = InvoiceDetail.Product_Code	
	Inner Join InvoiceAbstract ON InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
	Left Outer Join UOM ON Items.UOM = UOM.UOM
	WHERE	
	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND
	InvoiceAbstract.Status & 192 = 0 AND
	InvoiceAbstract.InvoiceType in (1, 2, 3, 4)	
	
	Select Top 1 @UOM1  = UOM.Description 
	From Items
	Inner Join #temp ON Items.CategoryID = #temp.CategoryID
	Inner Join InvoiceDetail ON Items.Product_Code = InvoiceDetail.Product_Code	
	Inner Join InvoiceAbstract ON InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
	Left Outer Join UOM ON Items.UOM1 = UOM.UOM
	WHERE	
	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND
	InvoiceAbstract.Status & 192 = 0 AND
	InvoiceAbstract.InvoiceType in (1, 2, 3, 4)	
	
	Select Top 1 @UOM2 = UOM.Description
	From Items
	Inner Join #temp ON Items.CategoryID = #temp.CategoryID
	Inner Join InvoiceDetail ON Items.Product_Code = InvoiceDetail.Product_Code	
	Inner Join InvoiceAbstract ON InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
	Left Outer Join UOM ON Items.UOM2 = UOM.UOM
	WHERE	
	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE AND
	InvoiceAbstract.Status & 192 = 0 AND
	InvoiceAbstract.InvoiceType in (1, 2, 3, 4)	

	Select Items.CategoryID, "Category Name" = ItemCategories.Category_Name, 
	"Net Quantity" = Cast(SUM(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 
          End * IsNull(Quantity, 0)) As nvarchar) + '  ' + @UOMDESC,
	"UOM1" = CAST(CAST(SUM((Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 
          End * ISNULL(Quantity, 0)) / (CASE Items.UOM1_Conversion WHEN 0 THEN 1 ELSE Items.UOM1_Conversion END)) AS Decimal(18, 6)) AS nvarchar)
	+ ' ' + @UOM1,
	"UOM2" = CAST(CAST(SUM((Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 
          End * ISNULL(Quantity, 0)) / (CASE Items.UOM2_Conversion WHEN 0 THEN 1 ELSE Items.UOM2_Conversion END)) AS Decimal(18, 6)) AS nvarchar)
	+ ' ' + @UOM2,
	"Net Value (%c)" = sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 
          End * IsNull(Amount, 0)) 
	from invoicedetail, InvoiceAbstract, ItemCategories, #temp, Items
	where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
	and invoicedate between @FROMDATE and @TODATE
	And InvoiceAbstract.Status & 192 = 0 
        and InvoiceAbstract.InvoiceType in (1, 2, 3, 4)
	and items.CategoryID = ItemCategories.CategoryID 
	And ItemCategories.CategoryID = #temp.CategoryID
	and items.product_Code = invoiceDetail.product_Code
	Group by Items.CategoryID,ItemCategories.Category_Name
End
Else
Begin
	Select Items.CategoryID,"Category Name" = ItemCategories.Category_Name, 
	"Net Quantity" = SUM(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 
          End * IsNull(Quantity, 0)),
	"UOM1" = Null,
	"UOM2" = Null,
	"Net Value (%c)" = sum(Case IsNull(InvoiceType, 0) When 4 Then -1 Else 1 
          End * IsNull(Amount, 0)) 
	From invoicedetail, InvoiceAbstract, ItemCategories, #temp, Items
	Where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
	And invoicedate between @FROMDATE and @TODATE
	And InvoiceAbstract.Status & 192 = 0 
	and InvoiceAbstract.InvoiceType in (1, 2, 3, 4)
        And Items.CategoryID = ItemCategories.CategoryID 
	And ItemCategories.CategoryID = #temp.CategoryID
	and items.product_Code = invoiceDetail.product_Code
	Group by Items.CategoryID, ItemCategories.Category_Name
End

Drop Table #tempCategory
Drop Table #temp

