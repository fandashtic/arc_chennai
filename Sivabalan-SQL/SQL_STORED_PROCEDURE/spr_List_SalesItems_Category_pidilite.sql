CREATE Procedure spr_List_SalesItems_Category_pidilite(
@PRODUCT_HIERARCHY nVarchar(4000),
@CATEGORY NVARCHAR(4000),
@CUSTOMER nvarchar(2550),
@ITEMCODE NVARCHAR(4000),
@UOM nVarChar(100),
@CusType nVarchar(50),
@FROMDATE DATETIME,
@TODATE DATETIME)  
AS
DECLARE @Delimeter as Char(1)
SET @Delimeter=Char(15)  
Create Table #ItemCode (ItemCode NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

If @ItemCode = '%' 
	Insert Into #ItemCode Select ProductName From Items
Else
	Insert Into #ItemCode Select * From DBO.sp_SplitIn2Rows(@ItemCode,@Delimeter)

Create Table #tempCategory(CategoryID int, Status int)        
Exec GetLeafCategories @PRODUCT_HIERARCHY, @CATEGORY 

Create table #tmpCustomer(Customer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @CUSTOMER=N'%'     
 Insert into #tmpCustomer select Company_Name from Customer    
Else    
 Insert into #tmpCustomer select * from dbo.sp_SplitIn2Rows(@CUSTOMER,@Delimeter)    

IF @CusType = 'Trade'
BEGIN  
Select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,   
"Item Name" = Items.ProductName, 
"Total Quantity" = 
(Case @UOM When 'Sales UOM' Then Sum(Case InvoiceAbstract.InvoiceType When 4 Then (Case When (InvoiceAbstract.Status & 32)=0  Then 0 - InvoiceDetail.Quantity Else 0 End) Else InvoiceDetail.Quantity End)
           When 'UOM1' Then dbo.sp_Get_ReportingQty(Sum(Case InvoiceAbstract.InvoiceType When 4 Then (Case When (InvoiceAbstract.Status & 32)=0  Then 0 - InvoiceDetail.Quantity Else 0 End) Else InvoiceDetail.Quantity End), Max(UOM1_Conversion))
           When 'UOM2' Then dbo.sp_Get_ReportingQty(Sum(Case InvoiceAbstract.InvoiceType When 4 Then (Case When (InvoiceAbstract.Status & 32)=0  Then 0 - InvoiceDetail.Quantity Else 0 End) Else InvoiceDetail.Quantity End), Max(UOM2_Conversion)) End),   
"Reporting UOM" = sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
case  When (InvoiceAbstract.Status & 32) = 0  Then   
0 - (InvoiceDetail.Quantity / Case IsNull(Items.ReportingUnit, 1) When 0 Then 1 Else IsNull(Items.ReportingUnit, 1) End)
Else 0   
End    
Else (InvoiceDetail.Quantity  / Case IsNull(Items.ReportingUnit, 1) When 0 Then 1 Else IsNull(Items.ReportingUnit, 1) End)
End),    

"Conversion Factor" = 
sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
case  When (InvoiceAbstract.Status & 32) = 0  Then   
0 - (InvoiceDetail.Quantity * Items.ConversionFactor)
Else 0   
End    
Else (InvoiceDetail.Quantity * Items.ConversionFactor)
End),  

"Total Value" = 
sum(Case InvoiceAbstract.InvoiceType 
When 4 Then 
case  When (InvoiceAbstract.Status & 32) = 0  Then 
0 - InvoiceDetail.Amount
Else 0 
End  
Else InvoiceDetail.Amount
End)   
From InvoiceDetail, items, ItemCategories, InvoiceAbstract   
where items.product_Code = InvoiceDetail.Product_Code   
and InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID         
and InvoiceDetail.InvoiceID IN   
(Select InvoiceAbstract.InvoiceID from InvoiceAbstract where   
InvoiceDate Between @FROMDATE AND @TODATE   
and (InvoiceAbstract.Status & 128) = 0  
and InvoiceAbstract.InvoiceType in (1, 3, 4))   
and Items.CategoryID = ItemCategories.CategoryID  
and ItemCategories.CategoryID in (Select CategoryID from #tempCategory)
and Items.ProductName In (Select ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS From #ItemCode)
and InvoiceAbstract.CustomerID IN (Select CustomerID From Customer Where Company_Name in 
(Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer))
group by InvoiceDetail.Product_Code,Items.ProductName 
END
ELSE
BEGIN
Select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,   
"Item Name" = Items.ProductName, 
"Total Quantity" = 
(Case @UOM When 'Sales UOM' Then Sum(InvoiceDetail.Quantity)
           When 'UOM1' Then dbo.sp_Get_ReportingQty(Sum(InvoiceDetail.Quantity), Max(UOM1_Conversion))
           When 'UOM2' Then dbo.sp_Get_ReportingQty(Sum(InvoiceDetail.Quantity), Max(UOM2_Conversion)) End),
"Reporting UOM" = sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
case  When (InvoiceAbstract.Status & 32) = 0  Then   
0 - (InvoiceDetail.Quantity / Case IsNull(Items.ReportingUnit, 1) When 0 Then 1 Else IsNull(Items.ReportingUnit, 1) End)
Else 0   
End    
Else (InvoiceDetail.Quantity  / Case IsNull(Items.ReportingUnit, 1) When 0 Then 1 Else IsNull(Items.ReportingUnit, 1) End)
End),
"Conversion Factor" = 
sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
case  When (InvoiceAbstract.Status & 32) = 0  Then   
0 - (InvoiceDetail.Quantity * Items.ConversionFactor)
Else 0   
End    
Else (InvoiceDetail.Quantity * Items.ConversionFactor)
End),
"Total Value" = Sum(InvoiceDetail.Amount)
From InvoiceDetail, items, ItemCategories, InvoiceAbstract   
where items.product_Code = InvoiceDetail.Product_Code   
and InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID         
and InvoiceDetail.InvoiceID IN   
(Select InvoiceAbstract.InvoiceID from InvoiceAbstract where   
InvoiceDate Between @FROMDATE AND @TODATE   
and (InvoiceAbstract.Status & 128) = 0  
and InvoiceAbstract.InvoiceType = 2)   
and Items.CategoryID = ItemCategories.CategoryID  
and ItemCategories.CategoryID in (Select CategoryID from #tempCategory)
and Items.ProductName In (Select ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS From #ItemCode)
and InvoiceAbstract.CustomerID IN (Select CustomerID From Customer Where Company_Name in 
(Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer))

group by InvoiceDetail.Product_Code,Items.ProductName 
END
Drop Table #ItemCode

