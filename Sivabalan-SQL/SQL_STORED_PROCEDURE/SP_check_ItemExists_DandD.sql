Create Procedure SP_check_ItemExists_DandD @Division nvarchar(max), @FromMonth nvarchar(25), @ToMonth nvarchar(25), @OptSelection int = 1
AS
BEGIN
	Declare @Delimiter Char(1)
	Set @Delimiter = ','


Declare @Last_Close_Date as Datetime
Declare @OpeningDate as datetime
Declare @FromDate	Datetime
Declare @ToDate		Datetime
Declare @StockAdjID nvarchar(1000)

set dateformat dmy
Select @Last_Close_Date = Convert(Nvarchar(10),LastInventoryUpload,103) From Setup

--Set @FromDate = Cast('01-' + Left(@FromMonth,3) + '-20' + Right(@FromMonth,2) as Datetime)
--Set @ToDate = Cast('01-' + Left(@ToMonth,3) + '-20' + Right(@ToMonth,2) as Datetime)
--Select @ToDate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@ToDate)+1,0))

Select @FromDate = Convert(Nvarchar(10),dbo.mERP_fn_getFromDate(@FromMonth),103), @ToDate = Convert(Nvarchar(10),dbo.mERP_fn_getToDate(@ToMonth),103)

/* For Damage Item Opening */
Select Top 1 @OpeningDate=OpeningDate from Setup
Update Batch_Products Set DocDate=@OpeningDate Where Damage<>0 And isnull(DocDate,'')=''


Create Table #TmpBrand(BrandID Int)

Create Table #DivItems(CategoryID int,Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpOutput(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS)

Insert Into #TmpBrand Select * From dbo.sp_SplitIn2Rows(@Division, @Delimiter) 

Insert into #DivItems(CategoryID,Product_Code)
select Distinct IC2.CategoryID,I.Product_code 
from items I ,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2 where
IC4.categoryid = i.categoryid 
And IC4.Parentid = IC3.categoryid 
And IC3.Parentid = IC2.categoryid And IC2.CategoryId in (select BrandID from #TmpBrand)


IF @OptSelection = 2
Begin
	/* For month selection */
	Create Table #tmpBatch(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS,ProductName nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
							BrandID int,Quantity decimal(18,6),MultiBatch int, Batch_Code int, DocDate DateTime, QuantityReceived decimal(18,6))
	Create Table #tmpDelete(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS, Batch_Code int)

	Insert into #tmpBatch(Product_Code,ProductName,BrandID,Quantity, Batch_Code, DocDate, QuantityReceived)
	Select 
		Items.Product_Code, Items.ProductName, D.CategoryID, Sum(isnull(BP.quantity,0)) As Damage_Quantity, BP.Batch_Code, BP.DocDate
		,Sum(isnull(BP.QuantityReceived,0)) As QuantityReceived
	From 
		batch_products BP, Items, UOM,#DivItems D
	Where
		BP.Product_Code = Items.Product_Code
		And Items.UOM = UOM.UOM
		And Items.Product_code=D.Product_code
		And Convert(nvarchar(10),BP.DocDate,103) Between @FromDate and @ToDate	
		And isnull(BP.Damage,0)<>0
		And isnull(BP.Free,0) = 0
	Group By
		Items.Product_Code, Items.ProductName, UOM.Description, D.CategoryID, BP.Batch_Code, BP.DocDate
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

--	Insert Into #tmpDelete
--	Select BP.Product_Code, BP.Batch_Code From Batch_Products BP,StockAdjustmentAbstract SA,StockAdjustment SD Where
--	SA.AdjustmentID= SD.SerialNo And
--	SD.Batch_Code=BP.Batch_Code And IsNUll(BP.Damage,0)<>0 
--	and SA.AdjustmentType = 4 and Convert(nvarchar(10),SA.AdjustmentDate,103) = @OpeningDate

	Delete From #tmpBatch Where Convert(nvarchar(10),DocDate,103) = @OpeningDate and Batch_Code Not In(Select Distinct Batch_Code From #tmpDelete)
	/* End: To get Batch for opening date Damage Sales Retun, Sales converison, Physical Reconcilation and delete opening damage stock */

	Insert Into #tmpOutput  	
	Select Product_Code From #tmpBatch 
	Group By Product_Code
	Having  Sum(isnull(Quantity,0))>0			

	Drop Table #tmpBatch
	Drop Table #tmpDelete

		/* To check whether current product is available in NON DESTROYED DandD other than current one*/

		IF exists(select 'x' from DandDDetail DD,DandDAbstract DA where DD.ID=DA.ID And (DA.ClaimStatus <> 3 And DA.ClaimStatus <> 192)
					And DD.Product_code in (select Product_code from #tmpOutput)
					And ((FromDate Between @FromDate and @ToDate or ToDate Between @FromDate and @ToDate)
					OR (@FromDate Between FromDate and ToDate or @ToDate Between FromDate and ToDate)))
					--And ((@ToDate Between FromDate and ToDate) or (ToDate <= @ToDate)) )				
		BEGIN
			Select Distinct 1,DD.Product_code from DandDDetail DD,DandDAbstract DA where 
			DD.ID=DA.ID And (DA.ClaimStatus <> 3 And DA.ClaimStatus <> 192) And 
			DD.Product_code in (select Product_code from #tmpOutput)
			And ((FromDate Between @FromDate and @ToDate or ToDate Between @FromDate and @ToDate)
			OR (@FromDate Between FromDate and ToDate or @ToDate Between FromDate and ToDate))
			--And ((@ToDate Between FromDate and ToDate) or (ToDate <= @ToDate))

			Select Distinct DocumentID,DA.ID,DA.ClaimDate from DandDDetail DD,DandDAbstract DA where 
			DD.ID=DA.ID And (DA.ClaimStatus <> 3 And DA.ClaimStatus <> 192) And 
			DD.Product_code in (select Product_code from #tmpOutput)
			And ((FromDate Between @FromDate and @ToDate or ToDate Between @FromDate and @ToDate)
			OR (@FromDate Between FromDate and ToDate or @ToDate Between FromDate and ToDate))
			--And ((@ToDate Between FromDate and ToDate) or (ToDate <= @ToDate))
		
		END
		ELSE
			Select 0
End
Else
Begin		
	Insert into #tmpOutput 
		Select distinct Items.Product_Code 
		From 
			batch_products BP, Items, UOM,#DivItems D
		Where
			BP.Product_Code = Items.Product_Code
			And Items.UOM = UOM.UOM
			And Items.Product_code=D.Product_code
			And Convert(Nvarchar(10),BP.DocDate,103) <= @Last_Close_Date
			And isnull(BP.Damage,0)<>0
			And isnull(BP.Free,0) = 0
		Group By
		Items.Product_Code, Items.ProductName, UOM.Description, D.CategoryID
		Having  Sum(isnull(BP.quantity,0))>0
			

		/* To check whether current product is available in NON DESTROYED DandD other than current one*/

		IF exists(select 'x' from DandDDetail DD,DandDAbstract DA where DD.ID=DA.ID And (DA.ClaimStatus <> 3 And DA.ClaimStatus <> 192)
					And DD.Product_code in (select Product_code from #tmpOutput))
		BEGIN
			Select Distinct 1,DD.Product_code from DandDDetail DD,DandDAbstract DA where 
			DD.ID=DA.ID And (DA.ClaimStatus <> 3 And DA.ClaimStatus <> 192) And DD.Product_code in (select Product_code from #tmpOutput)
			Select Distinct DocumentID,DA.ID,DA.ClaimDate from DandDDetail DD,DandDAbstract DA where 
			DD.ID=DA.ID And (DA.ClaimStatus <> 3 And DA.ClaimStatus <> 192) And DD.Product_code in (select Product_code from #tmpOutput)
		END
		ELSE
			Select 0
End	

Drop Table #TmpBrand
Drop Table #tmpOutput
Drop Table #DivItems
END
