Create PROCEDURE spr_list_Inward_PurchaseReturnDetails
(
@FROMDATE datetime,
@TODATE datetime
)
AS
BEGIN
set dateformat DMY

Declare @UTGSTFlag int
Select @UTGSTFlag = Isnull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UTGST'

Create Table #TempInward
(
[GSTINOfTheSupplier] Nvarchar(30),
[InvoiceNo]	NVarchar(100),
[InvoiceDate]	Datetime,
[CreditNoteNo] Nvarchar(255),
[CreditNoteDate] Datetime,
[CreditNoteValue] Decimal(18,6),
[Rate] Decimal(18,6),
[TaxableValue] Decimal(18,6),
[IGSTAmount]	Decimal(18,6),
[CGSTAmount]	Decimal(18,6),
[SGSTAmount]	Decimal(18,6),
[CessAmount]	Decimal(18,6),
[PlaceofSupply] Nvarchar(100),
[TaxCode] int
)
--Declare @temp nvarchar(255)

Select * into #TempAdjustmentReturnAbstract
from AdjustmentReturnAbstract(Nolock)
where dbo.StripTimeFromDate(AdjustmentDate) >= dbo.StripTimeFromDate(@FROMDATE)
and dbo.StripTimeFromDate(AdjustmentDate) <= dbo.StripTimeFromDate(@TODATE )
--AND GSTFlag = 1
AND (Isnull(Status,0) & 128) = 0


Select  AdjustmentID , Product_Code, Tax_Code ,SerialNo,
--Ptc.Product_Code,Ptc.SerialNo,
SGSTPer = Cast(Max(Case When TCD.TaxComponent_desc = 'SGST' Then ptc.Tax_Percentage Else 0 End) as decimal(18,6)),
SGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ptc.Tax_Value Else 0 End) as decimal(18,6)),
UTGSTPer = Cast(Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ptc.Tax_Percentage Else 0 End) as decimal(18,6)),
UTGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ptc.Tax_Value Else 0 End) as decimal(18,6)),
CGSTPer = Cast(Max(Case When TCD.TaxComponent_desc = 'CGST' Then ptc.Tax_Percentage Else 0 End) as decimal(18,6)),
CGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ptc.Tax_Value Else 0 End) as decimal(18,6)),
IGSTPer = Cast(Max(Case When TCD.TaxComponent_desc = 'IGST' Then ptc.Tax_Percentage Else 0 End) as decimal(18,6)),
IGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ptc.Tax_Value Else 0 End) as decimal(18,6)),
CESSAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ptc.Tax_Value Else 0 End) as decimal(18,6)),
AddCessAmt =  Cast(Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ptc.Tax_Value Else 0 End) as decimal(18,6))
Into #TempTaxDet2
From (Select Distinct AdjustmentID,Product_Code,Tax_Code,SerialNo,Tax_Percentage,Tax_Value,TaxType,Tax_Component_Code From PRTaxComponents) PTC Join TaxComponentDetail TCD On TCD.TaxComponent_code = PTC.Tax_Component_Code
Group By AdjustmentID , Product_Code, Tax_Code ,SerialNo

Insert Into #TempInward
([GSTINOfTheSupplier],[InvoiceNo],[InvoiceDate],[CreditNoteNo],[CreditNoteDate],[CreditNoteValue],[Rate],[TaxableValue]
,[IGSTAmount],[CGSTAmount],	[SGSTAmount],[CessAmount],[PlaceofSupply])
Select
Isnull(BA.GSTIN,''), --- GSTIN
Isnull(BA.ODNumber,''), -- Invoice no
--BA.BillDate, -- invoicedate
IsNull((Select InvoiceDate From InvoiceAbstractReceived Where InvoiceID = (Select Top 1 RecdInvoiceID from GRNAbstract where BillID = BA.BillID )),BA.BillDate),
Isnull(adjab.GSTFullDocID,''),	-- creditno
adjab.AdjustmentDate,	--creditnotedate
--tmp1.Creditnotevalue,--creditnotevalue
--(adjdt.Rate * adjdt.Quantity) + (adjdt.TaxAmount ) ,
adjab.Total_Value ,--creditnotevalue
case When adjdt.GSTTaxType = 2 Then tmp2.IGSTPer Else ISNULL((Case when @UTGSTFlag = 1 Then tmp2.UTGSTPer Else tmp2.SGSTper End)+ tmp2.CGSTper,0) End, --rate
(adjdt.Rate * adjdt.Quantity) ,-- Taxable value
ISNULL(cast(Cast(tmp2.IGSTAmt as Decimal(18,6)) as nVarchar),0),--"IGSTAmount"
ISNULL(cast(Cast(tmp2.CGSTAmt as Decimal(18,6)) as nVarchar),0),--"CGSTAmount"
--ISNULL(cast(Cast(tmp2.SGSTAmt as Decimal(18,6)) as nVarchar),0),--"SGSTAmount"
Case when @UTGSTFlag = 1 Then tmp2.UTGSTAmt Else tmp2.SGSTAmt End,
ISNULL(CAST(CAST(tmp2.CESSAmt + AddCessAmt  as Decimal(18,6)) as nvarchar),0), --"CessAmount"
--Isnull((Select StateName from StateCode where StateID = adjab.ToStatecode),'')	 --placeofsupply
Isnull((Select StateName from StateCode where StateID = BA.FromStatecode ),'')	 --placeofsupply

From #TempAdjustmentReturnAbstract  adjab(Nolock)
JOIN (Select GSTTaxType,AdjustmentID,Rate,Sum(Quantity) As Quantity,BillOrgID,Tax_Code,SerialNo,Product_Code from AdjustmentReturnDetail (Nolock)
Group by SerialNo,GSTTaxType,AdjustmentID,Rate,BillOrgID,Tax_Code,Product_Code) adjdt
On(	adjdt.AdjustmentID	= adjab.AdjustmentID)
JOIN Billabstract BA (Nolock) ON(adjdt.BillOrgID = BA.BillID)
--LEFT OUTER JOIN  #TempCreditValue tmp1(Nolock)
--On( tmp1.AdjustmentID = adjab.AdjustmentID
--And	tmp1.Tax_Code = adjdt.Tax_Code)
LEFT OUTER JOIN  #TempTaxDet2 tmp2(Nolock) On( tmp2.AdjustmentID = adjdt.AdjustmentID and tmp2.Product_Code =adjdt.Product_Code
and tmp2.Tax_Code = adjdt.Tax_Code and tmp2.SerialNo = adjdt.SerialNo)
Join Vendors V on V.VendorID = adjab.VendorID and isnull(v.GSTIN,'') <> ''
--Where --Isnull(adjab.GSTIN,'') <> ''
Order by adjab.Reference


Select 0,"GSTIN Of The Supplier"=[GSTINOfTheSupplier],"Invoice No"=[InvoiceNo],"Invoice Date"=[InvoiceDate],"CreditNote No"=[CreditNoteNo],"CreditNote Date"=[CreditNoteDate],
"CreditNote Value"=[CreditNoteValue],Rate=([Rate]),"Taxable Value"=Sum([TaxableValue]),"IGST Amount"=Sum([IGSTAmount]),"CGST Amount"=Sum([CGSTAmount]),
"SGST Amount"=Sum([SGSTAmount]),"Cess Amount"=Sum([CessAmount])  ,"Place of Supply"=[PlaceofSupply]
From #TempInward(Nolock)
Group By #TempInward.TaxCode,#TempInward.GSTINOfTheSupplier,#TempInward.InvoiceNo,#TempInward.InvoiceDate,
#TempInward.CreditNoteNo,#TempInward.CreditNoteDate,#TempInward.[CreditNoteValue],PlaceofSupply,Rate

IF OBJECT_ID('tempdb..#TempBillAbstract') IS NOT NULL
Drop Table #TempBillAbstract

IF OBJECT_ID('tempdb..#TempTaxDet') IS NOT NULL
Drop Table #TempTaxDet

IF OBJECT_ID('tempdb..#TempTaxableValue') IS NOT NULL
Drop Table #TempTaxableValue

IF OBJECT_ID('tempdb..#TempInward') IS NOT NULL
Drop Table #TempInward

IF OBJECT_ID('tempdb..#TempAdjustmentReturnAbstract') IS NOT NULL
Drop table #TempAdjustmentReturnAbstract

IF OBJECT_ID('tempdb..#TempTaxDet2') IS NOT NULL
Drop table  #TempTaxDet2

End
