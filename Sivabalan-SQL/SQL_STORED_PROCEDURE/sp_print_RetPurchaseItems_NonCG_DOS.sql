Create Procedure [dbo].[sp_print_RetPurchaseItems_NonCG_DOS](@INVNO INT,@MODE INT=0)
AS

Begin

Declare @Cnt1 Int,@Cnt2 Int, @I Int,@I1 Int,@IDS1 Int,@FQty Decimal(18, 6)
Declare @IDS Int,@ItmC nVarChar(50),@Batch nVarChar(150),@UOM nVarChar(150)
Declare @srl int ,@utgst_flag int
Select @Cnt1 = 0, @Cnt2 = 0, @I = 0, @I1 = 0, @FQty = 0, @IDS = 0, @IDS1 = 0


/*GST_Changes starts here*/
Create Table #tmpSnoDup1(Sno_dup1 Int Identity(1,1),id_dup1	int)
Create Table #tmpDuplicate(Duplicate Int)
Insert into #tmpDuplicate Values (1)
Insert into #tmpDuplicate Values (2)

--Temp Tax Details
Select  AdjustmentID, Product_Code, SerialNo,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Value Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Value Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Value Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Value Else 0 End),
--CESSPer = Max(Case When TCD.TaxComponent_desc in ('CESS','Compensation CESS') Then ITC.Tax_Percentage Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
--CESSAmt = Sum(Case When TCD.TaxComponent_desc in ('CESS','Compensation CESS') Then ITC.NetTaxAmount Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End) Into #TempTaxDet
From PRTaxComponents ITC
Join TaxComponentDetail TCD
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Where AdjustmentID = @INVNo
Group By AdjustmentID, Product_Code, SerialNo

--UTGST flag Enable or not
select @utgst_flag = isnull(flag,0) from tbl_merp_configabstract(nolock) where screencode = 'UTGST'

--Temp Invoice Detail
Select *,
SGSTPer=Case GSTFlag
When 1 then (Select SGSTPer From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0)
When 0 then isnull(ID.Tax_Code,0)
End ,
SGSTAmt=Case GSTFlag
When 1 then (Select Sum(SGSTAmt) From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0)
When 0 then isnull(ID.TaxAmount,0)
End,
CGSTPer=(Select CGSTPer From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0) ,
CGSTAmt=(Select Sum(CGSTAmt) From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0) ,
IGSTPer=(Select IGSTPer From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0) ,
IGSTAmt=(Select Sum(IGSTAmt) From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0) ,
UTGSTPer=(Select UTGSTPer From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0) ,
UTGSTAmt=(Select Sum(UTGSTAmt) From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0) ,
CESSPer=(Select CESSPer From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0) ,
CESSAmt=(Select Sum(CESSAmt) From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0),
ADDLCESSPer=(Select ADDLCESSPer From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0) ,
ADDLCESSAmt=(Select Sum(ADDLCESSAmt) From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0)
into #TempInvDet2
from AdjustmentReturnDetail ID
Where AdjustmentID = @INVNo
And UOMQty > 0
/*GST_Changes ends here*/

Declare @BillingStateID Int, @VendorBillingStateID Int
Select @BillingStateID= BillingStateID from Setup
Select @VendorBillingStateID = BillingStateID from Vendors where VendorID in(
Select VendorID from AdjustmentReturnAbstract Where AdjustmentID = @INVNo)

SELECT Identity(Int, 1,1) as "id1",
"SNo" = cast('' as nvarchar(25)),
"Item Name" = Case When Duplicate = 1 then Items.Description Else cast(isnull(Items.HSNNumber,'') as nvarchar) End,
"UOM" = Isnull(Case When Duplicate=1 Then UOM.Description Else Cast(Cast(sum(AdjustmentReturnDetail.UOMQTY*AdjustmentReturnDetail.UOMPrice) as decimal(18,2))as nVarchar)
End,''),

"MRP" =isnull(Case when Duplicate = 1
then Cast(cast(Sum(AdjustmentReturnDetail.MRPPerPack) As Decimal(18,2))
as nvarchar)
Else Case When Isnull(@VendorBillingStateID,0) <> Isnull(@BillingStateID,0)  Then Cast(Cast(Sum(IGSTPer) as decimal(18,2))as nVarchar) Else '' End
End,''),

"Sale Price" = Isnull(Case When Duplicate=1
Then Cast(	Case Cast(AdjustmentReturnDetail.UOMPrice As Nvarchar(50))
When Cast(0 As nVarchar(10)) Then Cast(N'Free' As nVarchar(20))
Else Cast(Cast(AdjustmentReturnDetail.UOMPrice As Decimal(18,2))As NVarChar)
End As nVarChar)
Else  Cast(Case When Isnull(@VendorBillingStateID,0) <> Isnull(@BillingStateID,0)  Then Cast(Cast(Sum(IGSTAmt) as decimal(18,2))as nVarchar) Else '' End As Nvarchar(50))
End,''),
"Quantity" = Isnull(Case When Duplicate=1 Then Isnull(cast(Cast((Case When AdjustmentReturnDetail.UOMPrice <> 0  THEN Sum(1 * AdjustmentReturnDetail.UOMQty)  Else Sum(1 * AdjustmentReturnDetail.UOMQty) 	End) as decimal(18,2) )
as nVarchar),'')
Else Case When Isnull(@VendorBillingStateID,0) = Isnull(@BillingStateID,0) Then Cast(Cast(Max(SGSTPer) + Max(UTGSTPer) as decimal(18,2))as nVarchar) Else '' End
End,''),
"Gross Amount" =isnull(Case when Duplicate = 1
then cast(Case Cast(Sum(AdjustmentReturnDetail.Quantity) * AdjustmentReturnDetail.Rate  As Decimal(18,2))
When 0 then	0
Else	Cast(Sum(1 * AdjustmentReturnDetail.Quantity) * AdjustmentReturnDetail.Rate as Decimal(18,2))
End as nvarchar)
Else  Case When Isnull(@VendorBillingStateID,0) = Isnull(@BillingStateID,0) Then Cast(Cast(Sum(SGSTAmt) + Sum(UTGSTAmt) as decimal(18,2))as nVarchar) Else '' End
End,''),
"Tax Amount" =isnull(Case when Duplicate = 1
then Cast(cast(Sum(AdjustmentReturnDetail.TaxAmount) As Decimal(18,2))
as nvarchar)
Else Case When Isnull(@VendorBillingStateID,0) = Isnull(@BillingStateID,0) Then Cast(Cast(Sum(CGSTPer) as decimal(18,2))as nVarchar) Else '' End
End,''),

"CGST Amt" = isnull(Case when Duplicate = 1
then cast(''
as nvarchar)
Else Cast(Cast(Sum(CGSTAmt) as decimal(18,2))as nVarchar)
End,''),
"Cess%" = isnull(Case when Duplicate = 1
then Cast(cast(Sum(AdjustmentReturnDetail.CESSPer) As Decimal(18,2))
as nvarchar)
Else Cast(Cast(Sum(CESSAmt) as decimal(18,2))as nVarchar)
End,''),
"Addl. Cess Rate" = isnull(Case when Duplicate = 1
then Cast(Cast(Sum(AdjustmentReturnDetail.ADDLCESSPer) as decimal(18,2))as nVarchar)
Else cast(''
as nvarchar)
End,''),
"Addl. Cess Amt" = isnull(Case when Duplicate = 1
then Cast(Cast(Sum(AdjustmentReturnDetail.ADDLCESSAmt) as decimal(18,2))as nVarchar)
Else cast(''
as nvarchar)
End,''),
"Total Amount" = isnull(Case when Duplicate = 1
then Cast(Cast(Sum(AdjustmentReturnDetail.Total_value) as decimal(18,2))as nVarchar)
Else cast(''
as nvarchar)
End,''),
"Serial"= Min(AdjustmentReturnDetail.SerialNo),

Duplicate
Into
#TmpInvDet
FROM
AdjustmentReturnAbstract
Inner Join #TempInvDet2 as AdjustmentReturnDetail on AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID
Inner Join Items on AdjustmentReturnDetail.Product_Code = Items.Product_Code
Left Outer Join UOM on AdjustmentReturnDetail.UOM = UOM.UOM
Left Outer Join Batch_Products on AdjustmentReturnDetail.BatchCode = Batch_Products.Batch_Code
Left Outer Join Manufacturer on Items.ManufacturerID = Manufacturer.ManufacturerID
Inner Join ItemCategories on Items.CategoryID = ItemCategories.CategoryID
Inner Join Brand on Items.BrandID = Brand.BrandID
Left Outer Join UOM As RUOM on Items.ReportingUOM = RUOM.UOM
Left Outer Join ConversionTable on Items.ConversionUnit = ConversionTable.ConversionID
Inner Join #tmpDuplicate on 1 = 1
GROUP BY
AdjustmentReturnDetail.Product_code, Items.ProductName,
AdjustmentReturnDetail.Rate,
ItemCategories.Price_Option,
Manufacturer.ManufacturerCode, Items.Description, ItemCategories.Category_Name,
Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,
Brand.BrandName, RUOM.Description, ConversionTable.ConversionID,
ConversionTable.ConversionUnit, UOM.Description, AdjustmentReturnDetail.UOMPrice,
AdjustmentReturnAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Isnull(AdjustmentReturnDetail.MRPPerPack,0),Items.MRPPerPack,
AdjustmentReturnDetail.Tax_Code
,AdjustmentReturnDetail.UOM, Items.Soldas,Items.Soldas,
Batch_Products.PKD,Batch_Products.Expiry,duplicate,Items.HSNNumber,Batch_Products.Serial
,AdjustmentReturnDetail.MRPPerPack --,Isnull(AdjustmentReturnAbstract.FromStatecode,0) , Isnull(@BillingStateID,0)
Order By serial,Duplicate

Update #TmpInvDet Set [Sale Price] = Cast(0 As Decimal(18,6))
Where [Sale Price] = N'Free'

--GST_Changes starts here
insert into  #tmpSnoDup1(id_dup1) select id1 from #TmpInvDet Where Duplicate = 1
Update #TmpInvDet Set SNo = Sno_dup1 from #tmpSnoDup1,#TmpInvDet where id1 = id_dup1 and Duplicate = 1

--Update #TmpInvDet Set
--[SNo]='', Serial=0
--Where Duplicate = 2

--GST_Changes ends here

IF @MODE=0
select * from #tmpInvdet Order By Serial,Duplicate
else
select count(*) from #tmpInvdet where  Duplicate= 1
--*/
Drop Table #TmpInvDet
Drop Table #tmpSnoDup1
Drop Table #TmpDuplicate
Drop Table #TempTaxDet
Drop Table #TempInvDet2
End
