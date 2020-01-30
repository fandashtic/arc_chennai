Create Procedure [dbo].[sp_print_RetInvItems_RespectiveUOM_FMCG_IGST_ITC_GST](@INVNO INT,@MODE INT=0)
AS
Begin

Declare @Cnt1 Int,@Cnt2 Int, @I Int,@I1 Int,@IDS1 Int,@FQty Decimal(18, 6)
Declare @IDS Int,@ItmC nVarChar(50),@Batch nVarChar(150),@UOM nVarChar(150)
Declare @srl int,@utgst_flag int
Select @Cnt1 = 0, @Cnt2 = 0, @I = 0, @I1 = 0, @FQty = 0, @IDS = 0, @IDS1 = 0

/*GST_Changes starts here*/
Create Table #tmpSnoDup1(Sno_dup1 Int Identity(1,1),id_dup1	int)
Create Table #tmpDuplicate(Duplicate Int)
Insert into #tmpDuplicate Values (1)
Insert into #tmpDuplicate Values (2)

--Temp Tax Components
Select MAX(ITC.Tax_Percentage) as TaxRate,SUM(ITC.Tax_Value)as TaxAmt,ITC.InvoiceID,ITC.Product_Code,TCD.TaxComponent_code,TCD.TaxComponent_desc
INTO #tmpTaxComponents
From TaxComponentDetail TCD
inner join  InvoiceTaxComponents ITC on ITC.Tax_Component_Code=TCD.TaxComponent_code
where ITC.InvoiceID=@INVNO
Group by ITC.InvoiceID,ITC.Product_Code,TCD.TaxComponent_code,TCD.TaxComponent_desc

--Temp Tax Details
Select  InvoiceID, Product_Code, SerialNo,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.NetTaxAmount Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.NetTaxAmount Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.NetTaxAmount Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.NetTaxAmount Else 0 End),
--CESSPer = Max(Case When TCD.TaxComponent_desc in ('CESS','Compensation CESS') Then ITC.Tax_Percentage Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
--CESSAmt = Sum(Case When TCD.TaxComponent_desc in ('CESS','Compensation CESS') Then ITC.NetTaxAmount Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.NetTaxAmount Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.NetTaxAmount Else 0 End) Into #TempTaxDet
From GSTInvoiceTaxComponents ITC
Join TaxComponentDetail TCD
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Where InvoiceId = @INVNo
Group By InvoiceID, Product_Code, SerialNo

--UTGST flag Enable or not
select @utgst_flag = isnull(flag,0) from tbl_merp_configabstract(nolock) where screencode = 'UTGST'

--Temp Invoice Detail
Select *,
SGSTPer=Case GSTFlag
When 1 then (Select SGSTPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0)
When 0 then isnull(ID.TaxCode,0) + isnull(ID.TaxCode2,0)
End ,
SGSTAmt=Case GSTFlag
When 1 then (Select Sum(SGSTAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0)
When 0 then isnull(ID.stpayable,0)+ isnull(ID.cstpayable,0)
End,
CGSTPer=(Select CGSTPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
CGSTAmt=(Select Sum(CGSTAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
IGSTPer=(Select IGSTPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
IGSTAmt=(Select Sum(IGSTAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
UTGSTPer=(Select UTGSTPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
UTGSTAmt=(Select Sum(UTGSTAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
CESSPer=(Select CESSPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
CESSAmt=(Select Sum(CESSAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0),
ADDLCESSPer=(Select ADDLCESSPer From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0) ,
ADDLCESSAmt=(Select Sum(ADDLCESSAmt) From #TempTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	UOMQty > 0),
BaseUOMDescription = (Select U.Description from UOM U Inner Join Items I on U.UOM = I.UOM Where I.Product_Code = ID.Product_Code)
into #TempInvDet2
from InvoiceDetail ID
Where InvoiceId = @INVNo
/*GST_Changes ends here*/

Create Table #Temp1 (InvID int identity(1,1), invno int,SRQty Decimal(18,6))
Select @srl = max(serial) from invoicedetail where invoiceid = @invno-- sales Item first then salesreturn Items
Insert into #Temp1(Invno,SRQty) Values (@invno,1)
If
(
SELECT Count(CollectionDetail.DocumentID) FROM CollectionDetail,InvoiceAbstract
Where InvoiceAbstract.InvoiceId = @invno and
ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID
And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)
) > 0
Begin
INsert into #Temp1(Invno,SRQty)
SELECT CollectionDetail.DocumentID,-1 FROM CollectionDetail,InvoiceAbstract
Where InvoiceAbstract.InvoiceId = @invno and
ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID
And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)
End

SELECT Identity(Int, 1,1) as "id1",
--GST_Changes starts here
"SNo" = cast('' as nvarchar(25)),
"Quantity" =Isnull(cast(Case When Duplicate=1
then Cast((Case When InvoiceDetail.UOMPrice <> 0
THEN Sum(#Temp1.SRQty * InvoiceDetail.UOMQty)
Else 0
End) as decimal(18,2) )
--Else Cast(sum(IGSTAmt) as decimal(18,2))
End as nVarchar),''),
--GST_Changes ends here
"Free" = Isnull(cast(Cast((Case When InvoiceDetail.UOMPrice = 0 THEN Sum(#Temp1.SRQty * InvoiceDetail.UOMQty) Else 0 End) as decimal(18,2)) as nvarchar),''),
"UOM" = UOM.Description,
--GST_Changes starts here
"Sale Price" = Isnull(Case When Duplicate=1
Then Cast(	Case InvoiceDetail.UOMPrice
When 0 Then N'Free'
Else Cast(Cast(InvoiceDetail.UOMPrice As Decimal(18,2))As NVarChar)
End As nVarChar)
--Else  Cast(Cast(Max(IGSTPer) as decimal(18,2))as nVarchar)
End,''),
--GST_Changes ends here
"TaxDetails" = cast(dbo.GetTaxCompInfo(Max(InvoiceDetail.InvoiceID),InvoiceDetail.Product_Code,Max(InvoiceDetail.TaxID), Sum(InvoiceDetail.STPayable)) as nvarchar),
"TaxDetailsWithBreakup" = cast(dbo.GetTaxCompInfoWithBreakup(Max(InvoiceDetail.InvoiceID),InvoiceDetail.Product_Code,Max(InvoiceDetail.TaxID), Sum(InvoiceDetail.STPayable)) as nvarchar),
"Discount%" = Isnull(cast(Case When Duplicate=1
then cast(Max(InvoiceDetail.DiscountPercentage) as nvarchar)
Else  Cast(Cast(Max(IGSTPer) as decimal(18,2))as nVarchar)
End as nVarchar),''),
"Discount Value" =  Isnull(Case When Duplicate=1
Then  cast(Sum(#Temp1.SRQty * InvoiceDetail.DiscountValue) as nvarchar)
Else   Cast(Cast(sum(IGSTAmt) as decimal(18,2)) as nVarchar)
End,''),
"Other Disc" = Cast(sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice-InvoiceDetail.DiscountValue))*(InvoiceAbstract.AdditionalDiscount/100) as nvarchar),
"Amount"=Cast(
case IsNull(InvoiceAbstract.TaxOnMRP,0)
when 1 then
case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)
WHEN 0 THEN
Case (Round((SUM(InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option
WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)) +
(SUM(InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option
WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)
* dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6))
When 0 then
NULL
Else
Cast(Round((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option
WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)) +
(SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option
WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)
* dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6) As nvarchar)
End
ELSE
Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -
(Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *
Max(InvoiceDetail.DiscountPercentage) / 100))
When 0 then
NULL
Else
Cast((Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -
(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *
Max(InvoiceDetail.DiscountPercentage) / 100) as nvarchar)
End
END
else
case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)
WHEN 0 THEN
Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -
(Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *
Max(InvoiceDetail.DiscountPercentage) / 100) +
((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice
- (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *
Max(InvoiceDetail.DiscountPercentage) / 100))
* Max(InvoiceDetail.TaxCode) / 100))
When 0 then
NULL
Else
Cast((Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -
(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *
Max(InvoiceDetail.DiscountPercentage) / 100) +
((Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice
- (Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *
Max(InvoiceDetail.DiscountPercentage) / 100))
* Max(InvoiceDetail.TaxCode) / 100) as nvarchar)
End
ELSE
Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -
(Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *
Max(InvoiceDetail.DiscountPercentage) / 100))
When 0 then
NULL
Else
Cast((Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -
(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *
Max(InvoiceDetail.DiscountPercentage) / 100) as nvarchar)
End
END
end As nVArChar),
"Description" = Case When Duplicate = 1 then Items.Description Else
Cast((case when len(Items.HSNNumber)=4 then cast(isnull(Items.HSNNumber,'') as nvarchar(10))+ SPACE(6) else cast(isnull(Items.HSNNumber,'') as nvarchar(10)) end)
+' | '+ Cast(Cast(Sum(InvoiceDetail.Quantity) As decimal(20,5)) As nvarchar(25)) + +' '+ Cast(InvoiceDetail.BaseUOMDescription  As nvarchar(5)) As nVarchar(50))
End,--GST_Changes
"Item Gross Value" =isnull(cast(Case Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice
When 0 then	NULL
Else	Cast(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice as nvarchar)
End as nvarchar),''),
"Net Value" = cast(Sum(#Temp1.SRQty * ((InvoiceDetail.uomqty * InvoiceDetail.uomprice)
+ InvoiceDetail.stpayable + InvoiceDetail.cstpayable + InvoiceDetail.STCredit - InvoiceDetail.DiscountValue))as nvarchar),
"TaxableValue" = Cast((Sum(#Temp1.SRQty * ((InvoiceDetail.uomqty * InvoiceDetail.uomprice) - InvoiceDetail.DiscountValue)))- (Sum(#Temp1.SRQty * ((InvoiceDetail.uomqty * InvoiceDetail.uomprice) - InvoiceDetail.DiscountValue)*(InvoiceAbstract.AdditionalDiscount/100)))	As nVarChar), --GST_Changes
"Net Amount" = cast(Sum(#Temp1.SRQty * Amount) as nvarchar),
--Sum(#Temp1.SRQty * ((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) + InvoiceDetail.TaxAmount - InvoiceDetail.DiscountValue)),
--"Item MRP" = isnull(Items.MRP,0),
--"Item MRP" = case isnull(max(Batch_Products.MRPPerpack),0) when 0 then isnull(Items.MRPPerPack,0) else isnull(max(Batch_Products.MRPPerpack),0) end ,
"Item MRP" =  cast(case isnull(InvoiceDetail.MRPPerpack,0) when 0 then isnull(Items.MRPPerPack,0) else isnull(InvoiceDetail.MRPPerpack,0) end as nvarchar),
"Batch No." =cast(isnull(InvoiceDetail.Batch_Number,'') as nvarchar),
"Mfr. Dt." =cast(dbo.fn_dateMY(Batch_Products.PKD) as nvarchar),
"Expiry" =cast(dbo.fn_dateMY(Batch_Products.Expiry) as nvarchar),
"Total Tax" = cast(sum(isnull(InvoiceDetail.stpayable,0) + isnull(InvoiceDetail.cstpayable,0)) as nVarchar) ,
--"Serial"= case invoicetype when 4 then @srl + 1 else Min(InvoiceDetail.Serial) end
"Serial"= Min(InvoiceDetail.Serial)
,Duplicate --GST_Changes
Into
#TmpInvDet
FROM
InvoiceAbstract
Inner Join #Temp1 on InvoiceAbstract.InvoiceID = #Temp1.invno
Inner Join #TempInvDet2 as InvoiceDetail on InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
Inner Join Items on InvoiceDetail.Product_Code = Items.Product_Code
Left Outer Join UOM on InvoiceDetail.UOM = UOM.UOM
Left Outer Join Batch_Products on InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
Left Outer Join Manufacturer on Items.ManufacturerID = Manufacturer.ManufacturerID
Inner Join ItemCategories on Items.CategoryID = ItemCategories.CategoryID
Inner Join Brand on Items.BrandID = Brand.BrandID
Left Outer Join UOM As RUOM on Items.ReportingUOM = RUOM.UOM
Left Outer Join ConversionTable on Items.ConversionUnit = ConversionTable.ConversionID
Inner Join #tmpDuplicate on 1 = 1

--FROM
--InvoiceAbstract,#TempInvDet2 as InvoiceDetail,UOM,Items,Batch_Products,Manufacturer, --GST_Changes
--ItemCategories,Brand,UOM As RUOM,ConversionTable,#Temp1,#tmpDuplicate --GST_Changes
--WHERE
--InvoiceAbstract.InvoiceID = #Temp1.invno
--AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
--AND InvoiceDetail.Product_Code = Items.Product_Code
---- AND InvoiceDetail.UOMQty > 0
--AND InvoiceDetail.UOM *= UOM.UOM
--AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code
--AND Items.ManufacturerID *= Manufacturer.ManufacturerID
--AND Items.CategoryID = ItemCategories.CategoryID
--And Items.BrandID = Brand.BrandID
--And Items.ReportingUOM *= RUOM.UOM
--And Items.ConversionUnit *= ConversionTable.ConversionID
GROUP BY
#Temp1.InvID,InvoiceDetail.Product_code, Items.ProductName,
InvoiceDetail.Batch_Number,InvoiceDetail.SalePrice,
InvoiceDetail.SaleID, ItemCategories.Price_Option,
Manufacturer.ManufacturerCode, Items.Description, ItemCategories.Category_Name,
Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,
Brand.BrandName, RUOM.Description, ConversionTable.ConversionID,
ConversionTable.ConversionUnit, UOM.Description, InvoiceDetail.UOMPrice,
--InvoiceAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Items.MRP,
--InvoiceAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Items.MRPPerPack,
InvoiceAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Isnull(InvoiceDetail.MRPPerPack,0),Items.MRPPerPack,
InvoiceDetail.TaxID,#Temp1.Invno,
InvoiceDetail.UOM, Items.Soldas,InvoiceAbstract.InvoiceType, Items.Soldas,InvoiceAbstract.AdditionalDiscount,
Batch_Products.PKD,Batch_Products.Expiry,duplicate,Items.HSNNumber,InvoiceDetail.BaseUOMDescription--GST_Changes
Order By serial,Duplicate

Update #TmpInvDet Set [Sale Price] = Cast(0 As Decimal(18,6)), [Amount] = Cast(0 As Decimal(18,6)) , [Item Gross Value] = Cast(0 As Decimal(18,6))
Where [Sale Price] = N'Free'

--GST_Changes starts here
insert into  #tmpSnoDup1(id_dup1) select id1 from #TmpInvDet Where Duplicate = 1
Update #TmpInvDet Set SNo = Sno_dup1 from #tmpSnoDup1,#TmpInvDet where id1 = id_dup1 and Duplicate = 1

Update #TmpInvDet Set
UOM=Cast(TaxableValue as decimal(18,2)),Amount='',[Net Value]='',[Net Amount]='',Serial=0,[SNo]='',
[Item MRP]='',TaxDetailsWithBreakup = '',[Item Gross Value]='',Free='',
--[Discount Value]='',[Discount%]='',
[Quantity]='', [Sale Price]='',TaxDetails='',[Batch No.]='' ,[Total Tax] = '' ,[Other Disc] = ''
Where Duplicate = 2
--GST_Changes ends here

IF @MODE=0
select * from #tmpInvdet Order By id1--Serial
else
select count(*) from #tmpInvdet where Duplicate = 1

Drop Table #TmpInvDet
Drop Table #Temp1
--GST_Changes starts here
Drop Table #tmpSnoDup1
Drop Table #TmpDuplicate
Drop Table #tmpTaxComponents
Drop Table #TempTaxDet
Drop Table #TempInvDet2
--GST_Changes ends here
End
