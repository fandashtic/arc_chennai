
Create Procedure sp_Get_Damage_Stock_DandD_Month(@Claim_ID Int, @Cat_ID nvarchar(max), @FromMonth nVarchar(25), @ToMonth nVarchar(25))
As
Set dateformat dmy
Declare @Last_Close_Date Datetime
Declare @Delimiter Char(1)

Declare @FromDate	Datetime
Declare @ToDate		Datetime
Declare @StockAdjID nvarchar(1000)

Set Dateformat dmy

--Set @FromDate = Cast('01-' + Left(@FromMonth,3) + '-20' + Right(@FromMonth,2) as Datetime)
--Set @ToDate = Cast('01-' + Left(@ToMonth,3) + '-20' + Right(@ToMonth,2) as Datetime)
--
--Select @ToDate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@ToDate)+1,0))

/* For Damage Item Opening */
Declare @OpeningDate as datetime
Select Top 1 @OpeningDate=OpeningDate from Setup
Update Batch_Products Set DocDate=@OpeningDate Where Damage<>0 And isnull(DocDate,'')=''

Select @FromDate = Convert(nvarchar(10),dbo.mERP_fn_getFromDate(@FromMonth),103), @ToDate =  Convert(nvarchar(10),dbo.mERP_fn_getToDate(@ToMonth),103)

Create Table #TmpBrand(BrandID Int)
Create Table #tmpOutput(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS,ProductName nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
BrandID int,Quantity decimal(18,6),MultiBatch int, Batch_Code int, DocDate DateTime, QuantityReceived decimal(18,6))
Create Table #tmpDelete(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS, Batch_Code int)

--Create Table #DivItems(CategoryID int,Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS)
Create Table #DivItems(CategoryID int, Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
						Sub_Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
						Market_SKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
						Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS)

Set @Delimiter = ','

IF @Cat_ID = '0'	
	Insert Into #TmpBrand Select distinct CategoryID from ItemCategories where isnull(level,0)=2
Else
	Insert Into #TmpBrand Select * From dbo.sp_SplitIn2Rows(@Cat_ID, @Delimiter) 

	
Insert into #DivItems(CategoryID,Product_Code,Category,Sub_Category,Market_SKU)
select Distinct IC2.CategoryID,I.Product_code,IC2.Category_Name,IC3.Category_Name, IC4.Category_Name
from items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 where
IC4.categoryid = i.categoryid 
And IC4.Parentid = IC3.categoryid 
And IC3.Parentid = IC2.categoryid And IC2.CategoryId in (select BrandID from #TmpBrand)

Insert into #tmpOutput(Product_Code,ProductName,BrandID,Quantity, Batch_Code, DocDate, QuantityReceived)
Select 
	Items.Product_Code, Items.ProductName, D.CategoryID, Sum(isnull(BP.quantity,0)) As Damage_Quantity, BP.Batch_Code, BP.DocDate, Sum(isnull(BP.QuantityReceived,0))
From 
	batch_products BP, Items, UOM,#DivItems D, Tax
Where
	BP.Product_Code = Items.Product_Code
	And Items.UOM = UOM.UOM
    And Items.Product_code=D.Product_code
	And Convert(nvarchar(10),BP.DocDate,103) Between @FromDate and @ToDate	
	And isnull(BP.Damage,0)<>0
	And isnull(BP.Free,0) = 0
	And Items.Sale_Tax = Tax.Tax_Code and isnull(Tax.GSTFlag,0) = 1
Group By
	Items.Product_Code, Items.ProductName, UOM.Description, D.CategoryID, Batch_Code, BP.DocDate
Having  Sum(isnull(BP.quantity,0))>0
Order By Items.ProductName

/* Start: To get Batch for opening date Damage Sales Retun, Sales converison, Physical Reconcilation and delete opening damage stock */
Insert Into #tmpDelete
Select BP.Product_Code, BP.Batch_Code From Batch_Products BP,InvoiceAbstract IA,InvoiceDetail ID 
Where IA.InvoiceID=BP.DocID And IA.InvoiceID = ID.Invoiceid And
ID.Batch_Code=BP.Batch_Code And IsNUll(BP.Damage,0)<>0 and
BP.DocType=1 and Invoicetype=4 and
isnull(status,0)&32 <> 0 And isnull(status,0)&64 = 0
and Convert(nvarchar(10),IA.InvoiceDate,103) = @OpeningDate
And isnull(BP.Free,0) = 0

Insert Into #tmpDelete
Select BP.Product_Code, BP.Batch_Code From Batch_Products BP,StockAdjustmentAbstract SA,StockAdjustment SD Where
SA.AdjustmentID=BP.DocID And SA.AdjustmentID = SD.SerialNo And
SD.Batch_Code=BP.Batch_Code And IsNUll(BP.Damage,0)<>0
and BP.DocType=2 and SA.AdjustmentType = 0
and Convert(nvarchar(10),SA.AdjustmentDate,103) = @OpeningDate
And isnull(BP.Free,0) = 0

--Insert Into #tmpDelete
--Select BP.Product_Code, BP.Batch_Code From Batch_Products BP,StockAdjustmentAbstract SA,StockAdjustment SD Where
--SA.AdjustmentID= SD.SerialNo And
--SD.Batch_Code=BP.Batch_Code And IsNUll(BP.Damage,0)<>0 
--and SA.AdjustmentType = 4 and Convert(nvarchar(10),SA.AdjustmentDate,103) = @OpeningDate

Delete From #tmpOutput Where Convert(nvarchar(10),DocDate,103) = @OpeningDate and Batch_Code Not In(Select Distinct Batch_Code From #tmpDelete)
/* End: To get Batch for opening date Damage Sales Retun, Sales converison, Physical Reconcilation and delete opening damage stock */


Select a.Product_Code,ProductName,BrandID,Sum(isnull(quantity,0)) as Quantity,MultiBatch from #tmpOutput a, #DivItems b
Where a.Product_Code = b.Product_Code
Group By a.Product_Code,ProductName,BrandID,MultiBatch,Category,Sub_Category,Market_SKU
Having  Sum(isnull(quantity,0))>0
Order By Category,Sub_Category,Market_SKU,a.Product_Code	

Drop Table #TmpBrand
Drop Table #DivItems
Drop Table #tmpOutput
Drop Table #tmpDelete
