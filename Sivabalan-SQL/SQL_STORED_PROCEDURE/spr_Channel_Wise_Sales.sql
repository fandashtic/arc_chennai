CREATE Procedure spr_Channel_Wise_Sales (@PRODUCT_HIERARCHY Varchar(255),      
@CATEGORY NVARCHAR(255),@PRODUCTCODE NVARCHAR(4000),      
@FROMDATE DATETIME,@TODATE DATETIME)   
As
--Declaration
Declare @ChannelType Int
Declare @ChannelDesc Nvarchar(255)    
Declare @StrPivotSql nVarChar(4000)
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)    
create table #tempProduct(ProdCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #tempCategory(CategoryID int, Status int)              
Exec GetLeafCategories @PRODUCT_HIERARCHY, @CATEGORY

Create Table #ChannelWiseItemSales
(
ChannelID Int,
ItemCode nvarChar(250)COLLATE SQL_Latin1_General_CP1_CI_AS,
Qty Decimal(18,6)
)

--Filter
if @productcode='%'       
 insert into #tempProduct select product_code from items    
Else      
 Insert into #tempProduct select * from dbo.sp_SplitIn2Rows(@productcode,@Delimeter)   

--Result Table
Insert Into #ChannelWiseItemSales (ChannelID,ItemCode,Qty)
select CM.ChannelType ,IT.Product_Code, Sum(Quantity)
From InvoiceAbstract IA, InvoiceDetail IDT,Items IT, Customer CM
Where 
IsNull(IA.Status,0) & 128 = 0
And IA.InvoiceType IN (1,3)
And IA.InvoiceDate Between @FromDate And @ToDate
And IDT.Product_Code IN (Select ProdCode From #tempProduct)
And IT.CategoryID IN (select categoryID From #tempCategory)
And IA.InvoiceID = IDT.InvoiceID
And IDT.Product_Code = IT.Product_Code
And IA.CustomerID = CM.CustomerID
Group By CM.ChannelType, IT.Product_Code

Set @StrPivotSql = 'Select 1, Max(IC.Category_Name) As "Category", X.ItemCode As "Item Code", 
Max(IT.ProductName) As "Item Name", Max(U.[Description]) As "UOM" '
DECLARE Channel_Cursor CURSOR FOR
SELECT  Distinct ChannelType,ChannelDesc FROM Customer_Channel Where IsNull(Active,0) = 1
OPEN Channel_Cursor
FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc
WHILE @@FETCH_STATUS = 0
BEGIN
	Set @StrPivotSql = @StrPivotSql + ', Sum(Case X.ChannelID When ' + Cast(@ChannelType As nVarChar) + ' Then X.Qty Else 0 End) As "' + @ChannelDesc + '"'
	FETCH NEXT FROM Channel_Cursor INTO @ChannelType,@ChannelDesc
END
CLOSE Channel_Cursor
DEALLOCATE Channel_Cursor
Set @StrPivotSql = @StrPivotSql + 
', Sum(X.Qty) As TotalQtySold 
From #ChannelWiseItemSales X, Itemcategories IC, Items IT, UOM U 
Where X.ItemCode = IT.Product_Code And IT.CategoryID = IC.CategoryID And IT.UOM = U.UOM 
Group By X.ItemCode'

Exec sp_executesql @StrPivotSql

Drop Table #ChannelWiseItemSales
Drop Table #tempProduct
Drop Table #tempCategory


