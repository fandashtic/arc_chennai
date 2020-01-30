Create Procedure SP_Get_DandD_BatchInfo_New @Product_Code nvarchar(30), @ID int = 0, @DandDDate Datetime = Null
AS
Begin

Set DateFormat DMY
Declare @Last_Close_Date Datetime
Declare @FromDate Datetime
Declare @ToDate Datetime
Declare @StockAdjID nvarchar(1000)

Declare @FromMonth_DandD nVarchar(25)
Declare @ToMonth_DandD nVarchar(25)
Declare @OptSelection_DandD int
Declare @ClaimStatus int

Declare @CustomerID nvarchar(30)
Declare @TaxType int

Declare @OpeningDate as datetime
Select Top 1 @OpeningDate=OpeningDate from Setup

Declare @Delimiter Char(1)
Set @Delimiter = ','

IF @DandDDate is Null
Select @DandDDate = GetDate()

Create Table #tmpOutput(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS, Batch_Code int,
BatchNumber nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,	Quantity Decimal(18,6),
DocDate Datetime, QuantityReceived Decimal(18,6), GRNID int, PFM Decimal(18,6),
PTS Decimal(18,6), Serial int, DandDPrice Decimal(18,6), TaxType int, GSTTaxType int, TOQ int)

Create Table #tmpDelete(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS, Batch_Code int)

Select Top 1 @CustomerID = CustomerID From Customer Where isnull(DnDFlag,0) = 1
Select @TaxType = dbo.FN_Get_GST_CustomerLocality (@CustomerID)

Select @Last_Close_Date = Convert(Nvarchar(10),DayCloseDate,103), @FromMonth_DandD = FromMonth,
@ToMonth_DandD = ToMonth, @OptSelection_DandD = OptSelection, @ClaimStatus = ClaimStatus From DandDAbstract Where ID = @ID

Select @FromDate = Convert(Nvarchar(10),dbo.mERP_fn_getFromDate(@FromMonth_DandD),103), @ToDate = Convert(Nvarchar(10),dbo.mERP_fn_getToDate(@ToMonth_DandD),103)

IF @ClaimStatus = 1
Begin
IF @OptSelection_DandD = 2
Begin
/* Start - For month selection */

Insert into #tmpOutput(Product_Code,Batch_Code, BatchNumber, Quantity, DocDate,QuantityReceived, GRNID, PFM, PTS, Serial,
TaxType, GSTTaxType, TOQ)
Select
Product_Code, Batch_Code, Batch_Number, isnull(Quantity,0) As Damage_Quantity, DocDate,
isnull(QuantityReceived,0) As QuantityReceived, isnull(GRN_ID,0), isnull(PFM,0), isnull(PTS,0), Serial,
isnull(TaxType,0), isnull(GSTTaxType,0), isnull(TOQ,0)
From
Batch_Products
Where
Product_Code = @Product_code
and Convert(nvarchar(10),DocDate,103) Between @FromDate and @ToDate
and isnull(Quantity,0)>0
and isnull(Damage,0)<>0	and isnull(Free,0) = 0

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

--			Insert Into #tmpDelete
--			Select BP.Product_Code, BP.Batch_Code From Batch_Products BP,StockAdjustmentAbstract SA,StockAdjustment SD Where
--			SA.AdjustmentID= SD.SerialNo And
--			SD.Batch_Code=BP.Batch_Code And IsNUll(BP.Damage,0)<>0
--			and SA.AdjustmentType = 4 and Convert(nvarchar(10),SA.AdjustmentDate,103) = @OpeningDate

Delete From #tmpOutput Where Convert(nvarchar(10),DocDate,103) = @OpeningDate and Batch_Code Not In(Select Distinct Batch_Code From #tmpDelete)
/* End: To get Batch for opening date Damage Sales Retun, Sales converison, Physical Reconcilation and delete opening damage stock */


--			Update #tmpOutput Set DandDPrice = Case When isnull(PFM,0) = 0 and isnull(GRNID,0) = 0 Then PTS
--													When isnull(PFM,0) = 0 and isnull(GRNID,0) <> 0 Then dbo.Fn_Get_DandDPrice(GRNID,Product_Code,Serial,PTS)
--												Else PFM End

Select T.BatchNumber, Tot_Qty = Sum(IsNull(T.Quantity, 0)),
--Rate = T.DandDPrice,
Rate = Case When isnull(T.PFM,0) > 0 Then T.PFM Else T.PTS End,
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End Tax,
TOQ = Max(Isnull(T.TOQ,0)), TaxID = isnull(Tax.Tax_Code,0), TaxType = @TaxType
--TaxType = Case When isnull(T.TaxType,0) = 5 Then isnull(T.GSTTaxType,0) Else isnull(T.TaxType,0) End
From #tmpOutput T
--Join Items I ON T.Product_Code = I.Product_Code
Join (Select Top 1 Product_Code, STaxCode as Sale_Tax From ItemsSTaxMap Where Product_Code = @Product_code and dbo.Striptimefromdate(@DandDDate)
Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))
) I ON T.Product_Code = I.Product_Code
Join Tax ON I.Sale_Tax = Tax.Tax_Code
Where
T.Product_Code = @Product_code
Group By
T.BatchNumber, Case When isnull(T.PFM,0) > 0 Then T.PFM Else T.PTS End,
Tax.Percentage, isnull(Tax.Tax_Code,0),
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End
Order By Min(T.Batch_Code)
End
/* End - For month selection */
Else

Begin
Insert into #tmpOutput(Product_Code, Batch_Code, BatchNumber, Quantity, DocDate,QuantityReceived, GRNID, PFM, PTS, Serial,
TaxType, GSTTaxType, TOQ)
Select
Product_Code, Batch_Code, Batch_Number, isnull(Quantity,0) As Damage_Quantity, DocDate,
isnull(QuantityReceived,0) As QuantityReceived, isnull(GRN_ID,0), isnull(PFM,0), isnull(PTS,0), Serial,
isnull(TaxType,0), isnull(GSTTaxType,0), isnull(TOQ,0)
From
Batch_Products
Where
Product_Code = @Product_code
and Convert(Nvarchar(10),DocDate,103) <= @Last_Close_Date
and isnull(Quantity,0) > 0
and Isnull(Damage,0) <> 0 And isnull(Free,0) = 0


--			Update #tmpOutput Set DandDPrice = Case When isnull(PFM,0) = 0 and isnull(GRNID,0) = 0 Then PTS
--													When isnull(PFM,0) = 0 and isnull(GRNID,0) <> 0 Then dbo.Fn_Get_DandDPrice(GRNID,Product_Code,Serial,PTS)
--												Else PFM End

Select T.BatchNumber, Tot_Qty = Sum(IsNull(T.Quantity, 0)),
--Rate = T.DandDPrice,
Rate = Case When isnull(T.PFM,0) > 0 Then T.PFM Else T.PTS End,
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End Tax,
TOQ = Max(Isnull(T.TOQ,0)), TaxID = isnull(Tax.Tax_Code,0), TaxType = @TaxType
--TaxType = Case When isnull(T.TaxType,0) = 5 Then isnull(T.GSTTaxType,0) Else isnull(T.TaxType,0) End
From #tmpOutput T
--Join Items I ON T.Product_Code = I.Product_Code
Join (Select Top 1 Product_Code, STaxCode as Sale_Tax From ItemsSTaxMap Where Product_Code = @Product_code and dbo.Striptimefromdate(@DandDDate)
Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))
) I ON T.Product_Code = I.Product_Code
Join Tax ON I.Sale_Tax = Tax.Tax_Code
Where
T.Product_Code = @Product_code
Group By
T.BatchNumber,
Case When isnull(T.PFM,0) > 0 Then T.PFM Else T.PTS End,
Tax.Percentage, isnull(Tax.Tax_Code,0),
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End
Order By Min(T.Batch_Code)
End
End
Else
Begin
Select T.Batch_Number, Tot_Qty = Sum(IsNull(T.TotalQuantity, 0)), Rate = T.PTS,
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End Tax,
TOQ = Max(Isnull(BP.TOQ,0)) , TaxID = isnull(Tax.Tax_Code,0), TaxType = @TaxType
--TaxType = Case When isnull(T.TaxType,0) = 5 Then isnull(T.GSTTaxType,0) Else isnull(T.TaxType,0) End
From DandDDetail T
Join Batch_Products BP ON T.Product_Code = T.Product_Code and T.Batch_Code = BP.Batch_Code
--Join Items I ON T.Product_Code = I.Product_Code
Join (Select Top 1 Product_Code, STaxCode as Sale_Tax From ItemsSTaxMap Where Product_Code = @Product_code and dbo.Striptimefromdate(@DandDDate)
Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))
) I ON T.Product_Code = I.Product_Code
Join Tax ON I.Sale_Tax = Tax.Tax_Code
Where
T.Product_Code = @Product_code and ID = @ID
Group By
T.Batch_Number, T.PTS, Tax.Percentage, isnull(Tax.Tax_Code,0),
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End
Order By Min(T.Batch_Code)
End

Drop Table #tmpDelete
Drop Table #tmpOutput
End
