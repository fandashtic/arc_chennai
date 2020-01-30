Create Procedure [dbo].[Sp_Get_SpecialSKUValidation](@ItemDetails nVarchar(Max), @InvoiceDate DateTime)
As
Begin
Set dateformat dmy
SELECT @InvoiceDate=dbo.stripdatefromtime(@InvoiceDate)

Declare @Delimeter as Char(1)
Set @Delimeter=Char(15)

CREATE TABLE #SpecialSKUItems
(
[RowID]  INT IDENTITY(1,1),
[Data]  nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
)

CREATE TABLE #SpecialSKUItemDetails
(
[RowID]  INT,
[Data]   nVarchar(256)  COLLATE SQL_Latin1_General_CP1_CI_AS  Not Null,
[ID]  INT
)

CREATE TABLE #SpecialSKUItemList
(
[RowID]  INT IDENTITY(1,1),
[ProductCode]  nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS ,
[BaseQty]  Decimal(18,6),
[UOM] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
[UOM2_Conversion] Decimal(18,6),
[UOM2_QTY] Decimal(18,6),
FreeSKUFlag int not null default 0
)


Declare @FreeSKU nVarchar(15)
Declare @BilledSKU nVarchar(15)
Declare @DisPercentage Decimal(18,6)

Declare @TotalBaseQty_BUOM Decimal(18,6)
Declare @TotalFreeQty_BUOM Decimal(18,6)
Declare @CapQty_BUOM Decimal(18,6)
Declare @FreeUOM2Conversion Decimal(18,6)
Declare @FreeItemValidation Decimal(18,6)
Declare @BaseUOM2Conversion Decimal(18,6)
Declare @FreeUOM2Quantity_Floor Decimal(18,6)
Declare @FreeUOM2Quantity_View Decimal(18,6)
Declare @FreeProductName nVarchar(15)


Select	@FreeSKU = FreeSKU ,
@BilledSKU = BilledSKU,
@DisPercentage = DistributionPercentage
from SpecialSKUMaster
Where dbo.stripdatefromtime(@InvoiceDate) Between Fromdate and Todate And Active = 1

set @FreeSKU=isnull(@FreeSKU,'')
set @BilledSKU=isnull(@BilledSKU,'')
set @DisPercentage=isnull(@DisPercentage,0)
DECLARE @ID INT
SET @ID = 1

Declare @SchSubDetails nVarChar(max)

DECLARE ScanSpecialFreeSKUDetails CURSOR FOR
SELECT ItemValue FROM dbo.sp_splitin2Rows(@ItemDetails,@delimeter)
OPEN ScanSpecialFreeSKUDetails
FETCH FROM ScanSpecialFreeSKUDetails INTO @SchSubDetails
WHILE @@FETCH_STATUS = 0
BEGIN
INSERT INTO #SpecialSKUItems
Select ItemValue FROM dbo.sp_splitin2Rows(@SchSubDetails,'|')

INSERT INTO #SpecialSKUItemDetails([rowid],[data],ID)
Select [rowid],[data],@ID FROM #SpecialSKUItems

TRUNCATE TABLE #SpecialSKUItems

SET @ID = @ID + 1
FETCH NEXT FROM ScanSpecialFreeSKUDetails INTO @SchSubDetails
END
CLOSE ScanSpecialFreeSKUDetails
DEALLOCATE ScanSpecialFreeSKUDetails


Insert Into #SpecialSKUItemList(ProductCode,BaseQty,[UOM2_Conversion],UOM2_QTY,FreeSKUFlag)
SELECT ISH1.[DATA],ISH2.[DATA],(Select Uom2_Conversion From Items where Product_Code = ISH1.[DATA]),
ISH2.[DATA]/(Select Uom2_Conversion From Items where Product_Code = ISH1.[DATA]),
(Select isnull(FreeSKUFLag,0) From Items where Product_Code = ISH1.[DATA] )
FROM #SpecialSKUItemDetails ISH1
JOIN #SpecialSKUItemDetails ISH2 ON ISH2.ROWID = 2 AND ISH1.ID = ISH2.ID
--JOIN #SpecialSKUItemDetails ISH3 ON ISH3.ROWID = 3 AND ISH1.ID = ISH3.ID
WHERE ISH1.ROWID = 1

Delete from #SpecialSKUItemList Where BaseQty = 0

if (select Sum(BaseQty) from #SpecialSKUItemList Where ProductCode = Isnull(@BilledSKU,0)) = 0 And
(Select Sum(BaseQty) from #SpecialSKUItemList Where ProductCode = Isnull(@FreeSKU,0)) > 0
BEGIN
Select 2,Cast('Billed SKU ('+ @BilledSKU+') has zero quantity' As nvarchar(2000))
Goto Skip
END



if (select isnull(Sum(BaseQty),0) from #SpecialSKUItemList Where ProductCode = Isnull(@BilledSKU,0)) > 0 And
(Select isnull(Sum(BaseQty),0) from #SpecialSKUItemList Where ProductCode = Isnull(@FreeSKU,0)) > 0
BEGIN
if  (Select max(product_code) from items where Product_Code in (select ProductCode from #SpecialSKUItemList where FreeSKUFlag=1) and isnull(FreeSKUFlag,0)=1) <> isnull(@FreeSKU,'')
BEGIN
Select @FreeProductName = max(product_code) from items where Product_Code in (select ProductCode from #SpecialSKUItemList where FreeSKUFlag=1 )
Select 1 ,Cast('DDS mapping is not available for the item code '+ Isnull(@FreeProductName,'')  As nVarchar(2000))
GOTO SKIP
END


if  exists (Select product_code from items where isnull(FreeSKUFlag,0)=0 And Product_Code  in (select ProductCode from #SpecialSKUItemList  where productcode =isnull(@FreeSKU,'')))
BEGIN
Select 1 ,Cast('DDS mapping is not available in the item master for the Item Code (' + Isnull(@FreeSKU,'') +')'  As nVarchar(2000))
GOTO SKIP
END


if  exists (Select product_code from items where isnull(FreeSKUFlag,0)=1 And Product_Code  in (select ProductCode from #SpecialSKUItemList) and product_code <> isnull(@FreeSKU,'') )
BEGIN

Select 1 ,Cast('Selected DDS mapping is not available in current month' As nVarchar(2000))
GOTO SKIP
END

If (Select Count(*) from #SpecialSKUItemList where ProductCode = Isnull(@FreeSKU,'')) = 0
Begin
Select 0 --Invoice FreeSKU not available.
GOTO SKIP
End


If (Select Count(*) from SpecialSKUMaster Where @InvoiceDate Between Fromdate and Todate And Active = 1 And FreeSKU = Isnull(@FreeSKU,'')) > 0
Begin
If (Select Count(*) from #SpecialSKUItemList Where ProductCode = Isnull(@BilledSKU,'')) = 0
Begin
Select 1 ,Cast('DDS (' + Isnull(@FreeSKU,'') +') cannot be sold without Billed SKU (' + Cast(Isnull(@BilledSKU,'') as nVarchar(30)) +')'    As nVarchar(2000))
GOTO SKIP
End
Else
Begin
Select @TotalBaseQty_BUOM = Sum(BaseQty) from #SpecialSKUItemList Where ProductCode = Isnull(@BilledSKU,0)
Select @TotalFreeQty_BUOM = Sum(BaseQty) from #SpecialSKUItemList Where ProductCode = Isnull(@FreeSKU,0)
select @FreeUOM2Quantity_Floor = FLOOR(UOM2_QTY) from #SpecialSKUItemList Where ProductCode = Isnull(@FreeSKU,0) --PAC Quantity
select @FreeUOM2Conversion = [UOM2_Conversion] from #SpecialSKUItemList Where ProductCode = Isnull(@FreeSKU,0) --PAC Quantity
select @FreeUOM2Quantity_View = Sum(Isnull(UOM2_QTY,0)) from #SpecialSKUItemList Where ProductCode = Isnull(@FreeSKU,0) --PAC Quantity
Select @BaseUOM2Conversion =[UOM2_Conversion] from #SpecialSKUItemList Where ProductCode = Isnull(@BilledSKU,0)
--select @TotalBaseQty_BUOM,@TotalFreeQty_BUOM
Select @CapQty_BUOM = (Isnull(@TotalBaseQty_BUOM,0)*Isnull(@DisPercentage,0))/100
if isnull(@TotalFreeQty_BUOM,0) > 0 And isnull(@TotalBaseQty_BUOM,0) = 0
BEGIN
Select 2,Cast('Billed SKU ('+ @BilledSKU+') has zero quantity' As nvarchar(2000))
GOTO SKIP
END
ELSE
BEGIN
-- Only CG items has  UOM2 Conversion less than 1 and this enhancement is done only for CG items
If isnull(@FreeUOM2Conversion,0) < 1
BEGIN
If round((@TotalFreeQty_BUOM/@FreeUOM2Conversion),0) <> (@TotalFreeQty_BUOM/@FreeUOM2Conversion)
BEGIN
--Select Isnull(@FreeUOM2Quantity_View,0),Isnull(@BaseUOM2Conversion,0),@FreeSKU
Select 3,Cast('DDS Quantity (' + Cast(Isnull(Cast(Isnull(@FreeUOM2Quantity_View,0) As Decimal(18,3)),0) As nVarchar(30)) + ' ) has decimal in PAC.' As nVarchar(2000))
GOTO SKIP
END
ELSE
BEGIN
If Isnull(@TotalFreeQty_BUOM,0) > Isnull(@CapQty_BUOM,0)
BEGIN
Select 2,Cast('DDS Quantity('+ Cast(Isnull(Cast(Isnull(@TotalFreeQty_BUOM,0)/Isnull(@FreeUOM2Conversion,0) As Decimal(18,3)),0) As nVarchar(30)) + ' PAC) is greater than Cap Quantity('+ Cast(Isnull(Cast(Isnull(@CapQty_BUOM,0)/Isnull(@BaseUOM2Conversion,0) As Decimal(18,3)),0) As nVarchar(30))+' PAC).' As nvarchar(2000))
GOTO SKIP
END
ELSE
BEGIN
--Select 5,'DDS selected in this invoice, please ensure you have created and adjusted the credit note in this invoice with the DDS total value.' -- Pack Quantity Validation satisfaction
Select 5,Isnull(@FreeSKU,'')
GOTO SKIP
END
END
END
ELSE
BEGIN
--Select 5,'DDS selected in this invoice, please ensure you have created and adjusted the credit note in this invoice with the DDS total value.' -- Pack Quantity Validation satisfaction
Select 5,Isnull(@FreeSKU,'')
GOTO SKIP
END
END
End

End
Else
Begin
If (Select Count(*) from #SpecialSKUItemList where ProductCode in (Select Product_Code from Items where Product_Code = Isnull(@FreeSKU,'') and FreeSKUFlag = 1)) > 0
Begin
--Set @FreeProductName = ''
Select @FreeProductName = ProductCode from #SpecialSKUItemList where ProductCode in (Select Product_Code from Items where Product_Code = Isnull(@FreeSKU,'') and FreeSKUFlag = 1)

Select 4,Cast('DDS' + Isnull(@FreeSKU,'') + 'cannot be sold without billed SKU (' + Isnull(@FreeProductName,'') + '.' As nVarchar(2000)) --Item master free flag validation checking
GOTO SKIP
End
Else
Begin
Select 0
GOTO SKIP
End
End
END
ELSE
BEGIN

if  exists (Select product_code from items where isnull(FreeSKUFlag,0)=1 And Product_Code  in (select ProductCode from #SpecialSKUItemList) and product_code <> isnull(@FreeSKU,'') )
BEGIN

Select 1 ,Cast('Selected DDS mapping is not available in current month' As nVarchar(2000))
GOTO SKIP
END
Else
BEGIN
if  exists (Select product_code from items where isnull(FreeSKUFlag,0)=1 And Product_Code  in (select ProductCode from #SpecialSKUItemList) and product_code = isnull(@FreeSKU,'') )
BEGIN
--Select 2,Cast('Billed SKU ('+ @BilledSKU+') has zero quantity' As nvarchar(2000))
Select 1 ,Cast('DDS (' + Isnull(@FreeSKU,'') +') cannot be sold without Billed SKU (' + Cast(Isnull(@BilledSKU,'') as nVarchar(30)) +')'    As nVarchar(2000))
GOTO SKIP
END
Else
Begin
if  exists (Select product_code from items where isnull(FreeSKUFlag,0)=0 And Product_Code  in (select ProductCode from #SpecialSKUItemList) and product_code = isnull(@FreeSKU,'') )
BEGIN
Select 1 ,Cast('DDS mapping is not available in the item master for the Item Code (' + Isnull(@FreeSKU,'') +')'  As nVarchar(2000))
GOTO SKIP

END
ELse
Begin
Select 0
GOTO SKIP
End
End
END

END

SKIP:
IF OBJECT_ID('tempdb..#SpecialSKUItems') IS NOT NULL
Drop Table #SpecialSKUItems
IF OBJECT_ID('tempdb..#SpecialSKUItemDetails') IS NOT NULL
Drop Table #SpecialSKUItemDetails
IF OBJECT_ID('tempdb..#SpecialSKUItemList') IS NOT NULL
Drop Table #SpecialSKUItemList
End
