
Create Procedure spr_VanLoading_Summary_Detail(@VBt nVarChar (250),
											   @Category nVarChar(250), 
											   @Beats nVarChar(250),
											   @Vans nVarChar(250),
											   @FromDate DateTime,
											   @ToDate DateTime)
As

Declare @Pos Int  
Declare @Beat nVarChar(100)  
Declare @Van  nVarChar(100)  
set @Pos = CharIndex(char(15), @VBt)  
Set @Van = SubString(@VBt, 1, @Pos - 1)
set @Beat = Convert(Int, Substring(@VBt, @Pos + 1, 251))

Create Table #tempCategory(CategoryID int, Status int)                  
Exec GetSubCategories @Category                

Select ic.Category_Name, "Category Name" = ic.Category_Name, 
"Item Code" = it.Product_Code, 
"Item Name" = it.ProductName, 
"Quantity" = sum(ids.Quantity), 
"Reporting UOM" = sum(ids.Quantity / Case IsNull(it.ReportingUnit, 1) When 0 Then 1 Else IsNull(it.ReportingUnit, 1) End), 
"Conversion Factor" = sum(ids.Quantity * it.ConversionFactor), 
"Value" = sum(ids.Amount) From
ItemCategories ic, Items it, InvoiceAbstract ia, InvoiceDetail ids, van v
Where It.Product_Code = ids.product_code And ia.invoiceid = ids.Invoiceid And
it.CategoryID = ic.CategoryID And ia.VanNumber = v.van And 
It.CategoryID In (Select CategoryID From #tempCategory) AND 
(ia.Status & 128) = 0 AND
ia.BeatID = @Beat And  v.van_number = @van And 
ia.InvoiceDate Between @FromDate And @ToDate
Group By ic.Category_Name, it.Product_Code, it.ProductName
Order By ic.Category_Name
