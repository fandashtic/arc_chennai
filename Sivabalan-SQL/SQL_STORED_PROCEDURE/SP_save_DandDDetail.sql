Create Procedure SP_save_DandDDetail @ID int,@Product_code nvarchar(15),@TotalQty Decimal(18,6),@UOM int,@UOMTotalQty Decimal(18,6),@FromMonth nVarchar(25), @ToMonth nVarchar(25), @OptSelection int = 1, @BatchNumber nvarchar(256)='',@RFAQty Decimal(18,6)=0,@UOMRFAQty Decimal(18,6)=0, @TaxID int=0,@TaxAmount decimal(18,6)=0,@TotalAmount Decimal(18,6)=0,
@SalvageQty decimal(18,6)=0,@SalvageRate decimal(18,6)=0,@SalvageValue decimal(18,6)=0,@SalvageUOM int=0,@SalvageUOMQty decimal(18,6)=0,@SalvageUOMRate decimal(18,6)=0,
@SalvageUOMValue decimal(18,6)=0,@RFAValue decimal(18,6)=0,@DandDMode int=0,@Tax Decimal(18,6)=0, @PTS decimal(18,6)=0,@UOMTaxAmount decimal(18,6)=0,@UOMTotalAmount decimal(18,6)=0,@UOMBatchTaxAmount decimal(18,6)=0,@UOMBatchTotalAmount decimal(18,6)=0,@UOMPTS decimal(18,6)=0, @BatchTaxID int = 0, @BatchTaxType int = 0
AS
BEGIN
Set dateformat dmy
Declare @Sale_UOM_Qty Decimal(18,6)
Declare @Last_Close_Date Datetime
Declare @RemainingQty Decimal(18,6)
DECLARE @UOM1 int
DECLARE @UOM2 int
DECLARE @UOMConv1 Decimal(18,6)
DECLARE @UOMConv2 Decimal(18,6)

Declare @CustomerID nvarchar(30)
Declare @TaxType int
Declare @DandDDate Datetime

Select Top 1 @CustomerID = CustomerID From Customer Where isnull(DnDFlag,0) = 1
Select @TaxType = dbo.FN_Get_GST_CustomerLocality (@CustomerID)

Create Table #UOMConv(Sale_UOM_Qty Decimal(18,6))
Create Table #BP(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS,Quantity decimal(18,6),Batch_code int,
Batch_Number nvarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,PTS decimal(18,6),TaxSuffered Decimal(18,6),TaxID int,TaxType int)

Insert Into #UOMConv(Sale_UOM_Qty) Exec SP_Get_Sales_Item_UOM @Product_code, 0

Select @Last_Close_Date = Convert(Nvarchar(10),DayCloseDate,103), @DandDDate = isnull(DandDDate,GetDate()) from DandDAbstract Where ID= @ID
Select @Sale_UOM_Qty = IsNull(Sale_UOM_Qty, 0) From  #UOMConv


If @optSelection = 2
Begin
Declare @FromDate Datetime
Declare @ToDate Datetime
Declare @OpeningDate as datetime
Declare @StockAdjID nvarchar(1000)
Declare @Delimiter Char(1)

Set @Delimiter = ','
Select Top 1 @OpeningDate=OpeningDate from Setup
Select @FromDate = Convert(nvarchar(10),dbo.mERP_fn_getFromDate(@FromMonth),103), @ToDate =  Convert(nvarchar(10),dbo.mERP_fn_getToDate(@ToMonth),103)

Create Table #tmpOutput(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS, Batch_Code int,
Batch_Number nvarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,
Quantity Decimal(18,6), DocDate Datetime, QuantityReceived Decimal(18,6), GRNID int, Serial int,
PFM Decimal(18,6), PTS Decimal(18,6), PFMType int, DandDPrice Decimal(18,6))

Create Table #tmpDelete(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS, Batch_Code int)

Insert into #tmpOutput(Product_Code,Batch_Code,Batch_Number,Quantity,DocDate,QuantityReceived,GRNID,Serial,PFM,PTS)
Select
Product_Code, Batch_Code, Batch_Number,isnull(Quantity,0) As Damage_Quantity, DocDate,isnull(QuantityReceived,0) As QuantityReceived,
GRN_ID,Serial,PFM,PTS
From
Batch_Products
Where
Convert(nvarchar(10),DocDate,103) Between @FromDate and @ToDate
And isnull(Damage,0)<>0
And Product_Code = @Product_code
And isnull(Free,0) = 0
And isnull(Quantity,0) > 0
--Group By Product_Code, Batch_Code, DocDate
--Having  Sum(isnull(Quantity,0))>0

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

--		Insert Into #tmpDelete
--		Select BP.Product_Code, BP.Batch_Code From Batch_Products BP,StockAdjustmentAbstract SA,StockAdjustment SD Where
--		SA.AdjustmentID= SD.SerialNo And
--		SD.Batch_Code=BP.Batch_Code And IsNUll(BP.Damage,0)<>0
--		and SA.AdjustmentType = 4 and Convert(nvarchar(10),SA.AdjustmentDate,103) = @OpeningDate

Delete From #tmpOutput Where Convert(nvarchar(10),DocDate,103) = @OpeningDate and Batch_Code Not In(Select Distinct Batch_Code From #tmpDelete)
/* End: To get Batch for opening date Damage Sales Retun, Sales converison, Physical Reconcilation and delete opening damage stock */

If @DandDMode=0
BEGIN
--			Insert Into #BP(Product_Code,Quantity,Batch_code,Batch_Number,PTS,TaxSuffered,TaxID,TaxType)
--			Select BP.Product_Code,isnull(T.Quantity,0) as Quantity,BP.Batch_Code,BP.Batch_Number,
--				--BP.PTS
--				Case When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) = 0 Then BP.PTS
--					When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) <> 0
--						Then dbo.Fn_Get_DandDPrice(BP.GRN_ID,BP.Product_Code,BP.Serial,BP.PTS)	Else BP.PFM End DandDPrice,
--				Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End TaxPercentage,
--				TaxID = isnull(I.Sale_Tax,0), @TaxType
--
--			From Batch_Products BP
--			Join #tmpOutput T ON BP.Product_Code = T.Product_Code and BP.Batch_Code = T.Batch_Code
--			Join Items I ON T.Product_Code = I.Product_Code
--			Join Tax ON I.Sale_Tax = Tax.Tax_Code
--			Where
--				BP.Product_Code = @Product_Code
--				and isnull(T.quantity,0) > 0
--			Order By BP.Batch_Code

--			Update #tmpOutput Set PFMType = Case When isnull(PFM,0) > 0 Then 1
--					When isnull(PFM,0) = 0 and isnull(GRNID,0) <> 0 Then 2 Else 3 End
--			Update #tmpOutput Set DandDPrice = isnull(PFM,0) Where isnull(PFMType,0) = 1
--			Update #tmpOutput Set DandDPrice = Max(BD.PFM) From #tmpOutput T, GRNAbstract G , BillDetail BD
--			Where T.GRNID = G.GRNID And G.BillID = BD.Billid And T.Serial = BD.Serial And T.PRoduct_code = BD.Product_code
--				And isnull(PFMType,0) = 2
--
--			Update #tmpOutput Set DandDPrice = isnull(PTS,0) Where isnull(PFMType,0) in (2,3) And isnull(DandDPrice,0) = 0

Insert Into #BP(Product_Code,Quantity,Batch_code,Batch_Number,PTS,TaxSuffered,TaxID,TaxType)
Select BP.Product_Code, BP.Quantity, BP.Batch_code, BP.Batch_Number,
Case When isnull(BP.PFM,0) > 0 Then BP.PFM Else BP.PTS End,
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End TaxPercentage,
TaxID = isnull(Tax.Tax_Code,0), @TaxType
From #tmpOutput BP
--Join Items I ON BP.Product_Code = I.Product_Code

Join (Select Top 1 Product_Code, STaxCode as Sale_Tax From ItemsSTaxMap Where Product_Code = @Product_code and dbo.Striptimefromdate(@DandDDate)
Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))
) I ON BP.Product_Code = I.Product_Code

Join Tax ON I.Sale_Tax = Tax.Tax_Code
Order By BP.Batch_Code

END
ELSE
BEGIN
--			Insert Into #BP(Product_Code,Quantity,Batch_Code,Batch_Number,PTS,TaxSuffered,TaxID,TaxType)
--			Select BP.Product_Code,isnull(T.Quantity,0) as Quantity,BP.Batch_Code,BP.Batch_Number,
--				--BP.PTS,BP.TaxSuffered,isnull(BP.GRNTaxID,0),TaxType = Case When isnull(BP.TaxType,0) = 5 Then isnull(BP.GSTTaxType,0) Else isnull(BP.TaxType,0) End
--				Case When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) = 0 Then BP.PTS
--					When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) <> 0
--						Then dbo.Fn_Get_DandDPrice(BP.GRN_ID,BP.Product_Code,BP.Serial,BP.PTS)	Else BP.PFM End DandDPrice,
--				Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End TaxPercentage,
--				TaxID = isnull(I.Sale_Tax,0), @TaxType
--			From Batch_Products BP
--			Join #tmpOutput T ON BP.Product_Code = T.Product_Code and BP.Batch_Code = T.Batch_Code
--			Join Items I ON T.Product_Code = I.Product_Code
--			Join Tax ON I.Sale_Tax = Tax.Tax_Code
--			Where
--				BP.Product_Code = @Product_Code
--				and BP.Batch_Number=@BatchNumber
--				and (Case When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) = 0 Then BP.PTS
--						When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) <> 0
--						Then dbo.Fn_Get_DandDPrice(BP.GRN_ID,BP.Product_Code,BP.Serial,BP.PTS)	Else BP.PFM End) = @PTS
--				and isnull(T.quantity,0) > 0
--			Order By BP.Batch_Code



--			Update #tmpOutput Set PFMType = Case When isnull(PFM,0) > 0 Then 1
--					When isnull(PFM,0) = 0 and isnull(GRNID,0) <> 0 Then 2 Else 3 End
--			Update #tmpOutput Set DandDPrice = isnull(PFM,0) Where isnull(PFMType,0) = 1
--			Update #tmpOutput Set DandDPrice = Max(BD.PFM) From #tmpOutput T, GRNAbstract G , BillDetail BD
--			Where T.GRNID = G.GRNID And G.BillID = BD.Billid And T.Serial = BD.Serial And T.PRoduct_code = BD.Product_code
--				And isnull(PFMType,0) = 2
--
--			Update #tmpOutput Set DandDPrice = isnull(PTS,0) Where isnull(PFMType,0) in (2,3) And isnull(DandDPrice,0) = 0


Insert Into #BP(Product_Code,Quantity,Batch_code,Batch_Number,PTS,TaxSuffered,TaxID,TaxType)
Select BP.Product_Code, BP.Quantity, BP.Batch_code, BP.Batch_Number,
Case When isnull(BP.PFM,0) > 0 Then BP.PFM Else BP.PTS End,
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End TaxPercentage,
TaxID = isnull(Tax.Tax_Code,0), @TaxType
From #tmpOutput BP
--Join Items I ON BP.Product_Code = I.Product_Code

Join (Select Top 1 Product_Code, STaxCode as Sale_Tax From ItemsSTaxMap Where Product_Code = @Product_code and dbo.Striptimefromdate(@DandDDate)
Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))
) I ON BP.Product_Code = I.Product_Code

Join Tax ON I.Sale_Tax = Tax.Tax_Code
Where
BP.Batch_Number=@BatchNumber
and (Case When isnull(BP.PFM,0) > 0 Then BP.PFM Else BP.PTS End) = @PTS
Order By BP.Batch_Code

END

Drop Table #tmpOutput
Drop Table #tmpDelete
End
Else
Begin

Create Table #tmpOutput1(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS, Batch_Code int,
Batch_Number nvarchar(256) Collate SQL_Latin1_General_CP1_CI_AS,
Quantity Decimal(18,6), DocDate Datetime, QuantityReceived Decimal(18,6), GRNID int, Serial int,
PFM Decimal(18,6), PTS Decimal(18,6), PFMType int, DandDPrice Decimal(18,6))

Insert into #tmpOutput1(Product_Code,Batch_Code,Batch_Number,Quantity,DocDate,QuantityReceived,GRNID,Serial,PFM,PTS)
Select
Product_Code, Batch_Code, Batch_Number,isnull(Quantity,0) As Damage_Quantity, DocDate,isnull(QuantityReceived,0) As QuantityReceived,
GRN_ID,Serial,PFM,PTS
From
Batch_Products
Where
Convert(Nvarchar(10),DocDate,103) <= @Last_Close_Date
And isnull(Damage,0)<>0
And Product_Code = @Product_code
And isnull(Free,0) = 0
And isnull(Quantity,0) > 0


If @DandDMode=0
BEGIN
--			Insert Into #BP(Product_Code,Quantity,Batch_Code,Batch_Number,PTS,TaxSuffered,TaxID,TaxType)
--			Select BP.Product_Code,isnull(BP.Quantity,0) as Quantity,Batch_Code,Batch_Number,
--			--PTS
--				Case When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) = 0 Then BP.PTS
--					When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) <> 0
--						Then dbo.Fn_Get_DandDPrice(BP.GRN_ID,BP.Product_Code,BP.Serial,BP.PTS)	Else BP.PFM End DandDPrice,
--				Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End TaxPercentage,
--				TaxID = isnull(I.Sale_Tax,0), @TaxType
--			From Batch_Products BP
--			Join Items I ON BP.Product_Code = I.Product_Code
--			Join Tax ON I.Sale_Tax = Tax.Tax_Code
--			Where
--				Convert(Nvarchar(10),BP.DocDate,103) <= @Last_Close_Date
--				And BP.Product_Code=@Product_Code
--				And isnull(BP.Quantity,0) > 0
--				And isnull(BP.Damage,0)<>0
--				And isnull(BP.Free,0) = 0
--			Order By BP.Batch_Code


Insert Into #BP(Product_Code,Quantity,Batch_code,Batch_Number,PTS,TaxSuffered,TaxID,TaxType)
Select BP.Product_Code, BP.Quantity, BP.Batch_code, BP.Batch_Number,
Case When isnull(BP.PFM,0) > 0 Then BP.PFM Else BP.PTS End,
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End TaxPercentage,
TaxID = isnull(Tax.Tax_Code,0), @TaxType
From #tmpOutput1 BP
--Join Items I ON BP.Product_Code = I.Product_Code

Join (Select Top 1 Product_Code, STaxCode as Sale_Tax From ItemsSTaxMap Where Product_Code = @Product_code and dbo.Striptimefromdate(@DandDDate)
Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))
) I ON BP.Product_Code = I.Product_Code

Join Tax ON I.Sale_Tax = Tax.Tax_Code
Order By BP.Batch_Code

END
ELSE
BEGIN
--			Insert Into #BP(Product_Code,Quantity,Batch_Code,Batch_Number,PTS,TaxSuffered,TaxID,TaxType)
--			Select BP.Product_code,isnull(BP.Quantity,0) as Quantity,Batch_Code,Batch_Number,
--				Case When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) = 0 Then BP.PTS
--					When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) <> 0
--						Then dbo.Fn_Get_DandDPrice(BP.GRN_ID,BP.Product_Code,BP.Serial,BP.PTS)	Else BP.PFM End DandDPrice,
--				Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End TaxPercentage,
--				TaxID = isnull(I.Sale_Tax,0), @TaxType
--
--				--PTS,TaxSuffered,isnull(GRNTaxID,0),
--				--TaxType = Case When isnull(BP.TaxType,0) = 5 Then isnull(BP.GSTTaxType,0) Else isnull(BP.TaxType,0) End
--			From Batch_Products BP
--			Join Items I ON BP.Product_Code = I.Product_Code
--			Join Tax ON I.Sale_Tax = Tax.Tax_Code
--			Where Convert(Nvarchar(10),BP.DocDate,103) <= @Last_Close_Date
--				And BP.Product_Code=@Product_Code
--				And isnull(Quantity,0) > 0
--				And isnull(Damage,0)<>0
--				And Batch_Number=@BatchNumber
--				And isnull(Free,0) = 0
--				and (Case When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) = 0 Then BP.PTS
--						When isnull(BP.PFM,0) = 0 and isnull(BP.GRN_ID,0) <> 0
--						Then dbo.Fn_Get_DandDPrice(BP.GRN_ID,BP.Product_Code,BP.Serial,BP.PTS)	Else BP.PFM End) = @PTS
--			Order By BP.Batch_Code


Insert Into #BP(Product_Code,Quantity,Batch_code,Batch_Number,PTS,TaxSuffered,TaxID,TaxType)
Select BP.Product_Code, BP.Quantity, BP.Batch_code, BP.Batch_Number,
Case When isnull(BP.PFM,0) > 0 Then BP.PFM Else BP.PTS End,
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End TaxPercentage,
TaxID = isnull(Tax.Tax_Code,0), @TaxType
From #tmpOutput1 BP
--Join Items I ON BP.Product_Code = I.Product_Code

Join (Select Top 1 Product_Code, STaxCode as Sale_Tax From ItemsSTaxMap Where Product_Code = @Product_code and dbo.Striptimefromdate(@DandDDate)
Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))
) I ON BP.Product_Code = I.Product_Code

Join Tax ON I.Sale_Tax = Tax.Tax_Code
Where
Batch_Number=@BatchNumber
and (Case When isnull(BP.PFM,0) > 0 Then BP.PFM Else BP.PTS End) = @PTS
Order By BP.Batch_Code

END
Drop Table #tmpOutput1
End

Insert into DandDDetail(ID,Product_code,Totalquantity,UOM,Batch_code,UOMTotalQty,Batch_Number,PTS,TaxSuffered,UOMTaxAmount,UOMTotalAmount,UOMBatchTaxAmount,UOMBatchTotalAmount,UOMPTS,TaxID, TaxType)
Select @ID,@Product_code, Quantity, @UOM, Batch_code, Quantity/@Sale_UOM_Qty,Batch_Number,PTS,TaxSuffered,@UOMTaxAmount,@UOMTotalAmount,@UOMBatchTaxAmount,@UOMBatchTotalAmount,@UOMPTS,TaxID, TaxType From #BP

If @DandDMode <>0
BEGIN
/* RFA Qty Updation starts  */
Declare @BCode int
Declare @TotQty decimal(18,6)
Declare @RowID int
Declare @DPTS decimal(18,6)
Declare @DTax decimal(18,6)
Declare @DTaxID int
Declare @DTaxType int
Set @RemainingQty=@RFAQty
Declare UpdateStk Cursor For
Select Distinct RowID,Batch_code,Totalquantity,PTS,TaxSuffered,isnull(TaxID,0),isnull(TaxType,0) From DandDDetail
Where ID=@ID and Product_Code=@Product_Code and Batch_Number=@BatchNumber and PTS=@PTS
Order By Batch_Code
-- And TaxSuffered =@Tax and isnull(TaxID,0) = isnull(@BatchTaxID,0) and isnull(TaxType,0) = isnull(@BatchTaxType,0)

Open UpdateStk
Fetch From UpdateStk  into  @RowID,@BCode,@TotQty,@DPTS,@DTax,@DTaxID,@DTaxType
While @@fetch_status=0
BEGIN
--			If @TotQty>=@RFAQty
--			BEGIN
--				update DandDDetail set RFAQuantity=@RFAQty where Product_code=@Product_code and Batch_code=@BCode And ID=@ID and RowID=@RowID And PTS=@DPTS And TaxSuffered=@DTax
--				--update DandDDetail set RFAQuantity=0 where Product_code=@Product_code and Batch_Number =@BatchNumber And Batch_code<>@BCode And ID=@ID
--				--Goto ExitCursor
--			END
--			ELSE
--			BEGIN
If @RemainingQty <> 0
BEGIN
If @TotQty <= @RemainingQty
BEGIN
update DandDDetail set RFAQuantity=@TotQty where Product_code=@Product_code and Batch_code=@BCode And ID=@ID and RowID=@RowID
--And PTS=@DPTS And TaxSuffered=@DTax and isnull(TaxID,0) = @DTaxID	and isnull(TaxType,0) = @DTaxType
Set @RemainingQty=@RemainingQty-@TotQty
END
ELSE
BEGIN
update DandDDetail set RFAQuantity=@RemainingQty where Product_code=@Product_code and Batch_code=@BCode And ID=@ID and RowID=@RowID
--And PTS=@DPTS And TaxSuffered=@DTax	and isnull(TaxID,0) = @DTaxID and isnull(TaxType,0) = @DTaxType
Set @RemainingQty=@RemainingQty-@RemainingQty
END
If @RemainingQty=0
BEGIN
Goto ExitCursor
END
END
ELSE
BEGIN
Goto ExitCursor
END
--			END
Fetch Next From UpdateStk  into  @RowID,@BCode,@TotQty,@DPTS,@DTax,@DTaxID,@DTaxType
END
ExitCursor:
Close UpdateStk
Deallocate UpdateStk
END
/* RFA Qty Updation Ends  */
Select @UOM1 = IsNull(Items.UOM1,0),@UOMConv1=Items.UOM1_Conversion, @UOM2 = IsNull(Items.UOM2,0),@UOMConv2=Items.UOM2_Conversion From items where Product_code=@Product_code

Update DandDDetail set RFAQuantity=0 where RFAQuantity is null and ID=@ID
Update DandDDetail set UOMRFAQty= isnull(RFAQuantity,0)/
(Select case @UOM when @UOM1 then @UOMConv1 when @UOM2 then @UOMConv2 else 1 end) where Product_code=@Product_code and ID=@ID
Update DandDDetail set UOMTotalQty= isnull(TotalQuantity,0)/
(Select case @UOM when @UOM1 then @UOMConv1 when @UOM2 then @UOMConv2 else 1 end) where Product_code=@Product_code and ID=@ID

Update D set SalvageQuantity=@SalvageQty from DandDDetail D where Product_code=@Product_code and ID=@ID
Update D set SalvageRate=@SalvageRate from DandDDetail D where Product_code=@Product_code and ID=@ID
Update D set SalvageValue=isnull(@SalvageQty,0) * isnull(@SalvageRate,0) from DandDDetail D where Product_code=@Product_code and ID=@ID
Update D set SalvageUOM=@SalvageUOM from DandDDetail D where Product_code=@Product_code and ID=@ID
Update D set SalvageUOMQuantity=@SalvageUOMQty from DandDDetail D where Product_code=@Product_code and ID=@ID
Update D set SalvageUOMRate=@SalvageUOMRate from DandDDetail D where Product_code=@Product_code and ID=@ID
Update D set SalvageUOMValue=@SalvageUOMValue from DandDDetail D where Product_code=@Product_code and ID=@ID
Update D set RFAValue=@RFAValue from DandDDetail D where Product_code=@Product_code and ID=@ID

Update DandDDetail Set BatchAmount = isnull(PTS,0) * isnull(RFAQuantity,0) Where Product_Code=@Product_Code and ID=@ID

Update DandDDetail Set BatchTotalAmount = (Select Sum(BatchAmount) From DandDDetail Where Product_Code=@Product_Code and ID=@ID) Where Product_Code=@Product_Code and ID=@ID

--To update Batch Salvage
IF (Select Sum(SalvageValue) From DandDDetail Where Product_Code=@Product_Code and ID=@ID) > 0 and (Select Sum(BatchTotalAmount) From DandDDetail Where Product_Code=@Product_Code and ID=@ID) > 0
Begin
Update DandDDetail Set BatchSalvageValue = (BatchAmount * SalvageValue) / BatchTotalAmount
--(Select Sum(BatchAmount) From DandDDetail Where Product_Code=@Product_Code and ID=@ID)
Where Product_Code=@Product_Code and ID=@ID
End

Update DandDDetail Set BatchTaxableAmount = BatchAmount - isnull(BatchSalvageValue,0) Where Product_Code=@Product_Code and ID=@ID


----	if exists (Select Product_Code From Items Where Product_code=@Product_code And Isnull(TOQ_Purchase,0) = 1)
----	Begin
--		Update D set TaxAmount=(RFAQuantity * isnull(BP.TaxSuffered,0)) from DandDDetail D,Batch_products BP where BP.Batch_Code= D.Batch_Code
--		and D.Product_code=@Product_code and ID=@ID And Isnull(BP.TOQ,0) = 1
--
--		Update D set TotalAmount=(RFAQuantity * BP.PTS) + (RFAQuantity * isnull(BP.TaxSuffered,0)) from DandDDetail D,Batch_products BP where BP.Batch_Code= D.Batch_Code
--		and D.Product_code=@Product_code and ID=@ID	And Isnull(BP.TOQ,0) = 1
----	End
----	Else
----	Begin
--		Update D set TaxAmount=(RFAQuantity * BP.PTS) * ((isnull(BP.TaxSuffered,0)/100.)) from DandDDetail D,Batch_products BP where BP.Batch_Code= D.Batch_Code
--		and D.Product_code=@Product_code and ID=@ID And Isnull(BP.TOQ,0) = 0
--
--		Update D set TotalAmount=(RFAQuantity * BP.PTS) + ((RFAQuantity * BP.PTS) * (isnull(BP.TaxSuffered,0)/100.)) from DandDDetail D,Batch_products BP where BP.Batch_Code= D.Batch_Code
--		and D.Product_code=@Product_code and ID=@ID And Isnull(BP.TOQ,0) = 0
----	End

--If @DandDMode <>0
-- To calculate Tax splitup
--Exec sp_DandDTaxComponents @ID, @Product_Code, @BatchNumber, @PTS

--Update DandDDetail Set BatchRFAValue = (BatchAmount + isnull(TaxAmount,0)) - isnull(BatchSalvageValue,0) Where Product_Code=@Product_Code and ID=@ID

Drop Table #BP
Drop Table #UOMConv
END
