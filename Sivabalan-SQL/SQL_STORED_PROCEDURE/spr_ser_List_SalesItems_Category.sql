CREATE Procedure spr_ser_List_SalesItems_Category  
		(@PRODUCT_HIERARCHY Varchar(4000),
	         @CATEGORY NVARCHAR(4000),  
		 @ITEMCODE NVARCHAR(4000),
		 @CusType nVarchar(50),
		 @FROMDATE DATETIME,  
         	 @TODATE DATETIME)  
AS  

DECLARE @Delimeter as Char(1)    
SET @Delimeter=Char(15)  
Create Table #ItemCode (ItemCode NVarChar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)

If @ItemCode = '%' 
	Insert Into #ItemCode Select Product_Code From Items
Else
	Insert Into #ItemCode Select * From DBO.sp_SplitIn2Rows(@ItemCode,@Delimeter)

Create Table #tempCategory(CategoryID int, Status int)
Exec GetLeafCategories @PRODUCT_HIERARCHY, @CATEGORY 

IF @CusType = 'Trade'
BEGIN  

Select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,   
"Item Name" = Items.ProductName, 
"Total Quantity" = 
sum(Case InvoiceAbstract.InvoiceType 
When 4 Then 
case  When (InvoiceAbstract.Status & 32) = 0  Then 
0 - InvoiceDetail.Quantity  
Else 0 
End  
Else InvoiceDetail.Quantity    
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
and Items.product_Code In (Select ItemCode From #ItemCode)
group by InvoiceDetail.Product_Code,Items.ProductName 


--Select "Code" = code, "Item Code" =  itemcode, "Item Name" = itemname, "Total Quantity" = sum(TotalQuantity),
--"Total Value"  = sum(TotalValue) from #ItemwiseTemp  group by code,itemcode,itemname
END
ELSE
BEGIN

Create Table #ItemwiseTemp(code nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
Itemcode nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,ItemName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[TotalQuantity] Decimal(18,6),
[TotalValue] Decimal(18,6))

Insert into #ItemwiseTemp 
Select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,   
"Item Name" = Items.ProductName, 
"Total Quantity" = sum(InvoiceDetail.Quantity),   
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
and Items.product_Code In (Select ItemCode From #ItemCode)
group by InvoiceDetail.Product_Code,Items.ProductName 


Insert into #ItemwiseTemp 

Select ServiceInvoiceDetail.SpareCode, "Item Code" = ServiceInvoiceDetail.SpareCode,   
"Item Name" = Items.ProductName, 
"Total Quantity" = sum(ServiceInvoiceDetail.Quantity),   
"Total Value" = Sum(ServiceInvoiceDetail.Netvalue)
From ServiceInvoiceDetail, items, ItemCategories, ServiceInvoiceAbstract
where items.product_Code = ServiceInvoiceDetail.SpareCode   
and ServiceInvoiceDetail.ServiceInvoiceID = ServiceInvoiceAbstract.ServiceInvoiceID         
And ISnull(Serviceinvoicedetail.sparecode,'') <> ''
and ServiceInvoiceDetail.ServiceInvoiceID IN   
(Select ServiceInvoiceAbstract.ServiceInvoiceID from ServiceInvoiceAbstract where   
ServiceInvoiceDate Between @FROMDATE AND @TODATE   
and Isnull(ServiceInvoiceAbstract.Status,0) & 192 = 0  
and ServiceInvoiceAbstract.ServiceInvoiceType = 1)   
and Items.CategoryID = ItemCategories.CategoryID  
and ItemCategories.CategoryID in (Select CategoryID from #tempCategory)
and Items.product_Code In (Select ItemCode From #ItemCode)
group by ServiceInvoiceDetail.SpareCode,Items.ProductName 


Select "Code" = code, "Item Code" =  itemcode, "Item Name" = itemname, "Total Quantity" = sum(TotalQuantity),
"Total Value"  = sum(TotalValue) from #ItemwiseTemp  group by code,itemcode,itemname
Drop Table #ItemwiseTemp
END
Drop Table #TempCategory
Drop Table #ItemCode

