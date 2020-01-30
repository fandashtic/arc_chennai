
Create Procedure [dbo].[sp_print_PurchaseReturn_CG_Dos](@PRNO INT)
AS

Set dateformat DMY
Declare @ItemCount int
Declare @ItemListCount int
Declare @WDPhoneNumber As NVarchar(20)
Declare @WDName As nVarchar(255)
Declare @WDAddress As nVarchar(255)
Declare @CompanyGSTIN as Nvarchar(30)
Declare @CompanyPAN as Nvarchar(200)
Declare @CIN as Nvarchar(50)
Declare @CompanyState Nvarchar(200)
Declare @CompanySC	Nvarchar(50)
Declare @UTGST_flag  int
Declare @WDFSSAINO as Nvarchar(200)
Declare @TIN_Number nVarchar(50)

select @UTGST_flag = isnull(flag,0) from tbl_merp_configabstract(nolock) where screencode = 'UTGST'

Declare @ODNumber nVarchar(50)
Declare @RefInvoiceDate DateTime
Declare @ManualBillValidation nVarchar(30)


Select  @ManualBillValidation = B.VendorID from AdjustmentReturnDetail AR
Inner Join BillAbstract B on AR.BillOrgID = B.BillID
Where AdjustmentID = @PRNO
And AR.SerialNo = 1
--AND VendorID In (Select Distinct VendorID from InvoiceAbstractReceived)


If Isnull(@ManualBillValidation,'') = ''
Begin
Select @ODNumber = B.ODNumber from AdjustmentReturnDetail AR
Inner Join BillAbstract B on AR.BillOrgID = B.BillID
Where AdjustmentID = @PRNO
And AR.SerialNo = 1

Select @RefInvoiceDate = InvoiceDate from InvoiceAbstractReceived where ODNumber = Isnull(@ODNumber,'')

End
Else
Begin
Select @ODNumber = B.ODNumber, @RefInvoiceDate = B.BillDate  from AdjustmentReturnDetail AR
Inner Join BillAbstract B on AR.BillOrgID = B.BillID
Where AdjustmentID = @PRNO
And AR.SerialNo = 1
End

Select @WDName = OrganisationTitle,
@WDAddress = BillingAddress,
@CompanyGSTIN=GSTIN,
@WDPhoneNumber=Telephone,
@CompanyPAN =PANNumber,
@CIN=CIN,
@TIN_Number = TIN_Number
from Setup


Select TOP 1 @CompanyState=StateName,@CompanySC=ForumStateCode,@WDFSSAINO =   Case when Setup.STRegn = '' then '' else Setup.STRegn End
from StateCode
inner join Setup on Setup.ShippingStateID=StateCode.StateID

--Select @ItemCount = Max(SerialNo) from AdjustmentReturnDetail where AdjustmentID = @PRNO


Create Table #tempItemCount(ItemCount Int)
insert #tempItemCount(ItemCount)
exec sp_print_RetPurchaseItems_NonCG_DOS @PRNO,1

Select @ItemCount = ItemCount From #tempItemCount

Set @ItemListCount = @ItemCount
Set @ItemListCount = @ItemListCount*2

-------------------------Temp Tax Details
Select  AdjustmentID, Product_Code, Tax_Code ,SerialNo,
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
--CESSAmt = Sum(Case When TCD.TaxComponent_desc in ('CESS','Compensation CESS') Then ITC.Tax_Value Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End) Into #TempTaxDet
From PRTaxComponents ITC
Join TaxComponentDetail TCD
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Where AdjustmentID = @PRNO
Group By AdjustmentID, Product_Code, Tax_Code,SerialNo



--Temp Invoice Detail
Select Serial=ID.SerialNo , TaxID=ID.Tax_Code,
TaxableValue = Cast(Sum(ID.Quantity) * Sum(Rate) As Decimal(18,6)),
SGSTPer=(Select SGSTPer From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0)  ,
SGSTAmt=(Select Sum(SGSTAmt) From #TempTaxDet Where AdjustmentID = ID.AdjustmentID And Product_Code = ID.Product_Code And SerialNo= ID.SerialNo and	UOMQty > 0),

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
Inner Join AdjustmentReturnAbstract AR on ID.AdjustmentID = AR.AdjustmentID
Where AR.AdjustmentID = @PRNO
and ID.UOMQty > 0
Group by ID.Product_code,ID.serialNo,ID.Tax_Code,ID.AdjustmentID,ID.UOMQty

Select	TaxableValue=Cast(Sum(TaxableValue) as Decimal(18,2)),
SGSTPer=UTGSTPer+SGSTPer,
SGSTAmt =Cast(Sum(UTGSTAmt+SGSTAmt) as Decimal(18,2)),
CGSTPer=Max(CGSTPer),
CGSTAmt=Cast(SUM(CGSTAmt) as Decimal(18,2)),
IGSTPer=IGSTPer,
IGSTAmt=Cast(Sum(IGSTAmt) as Decimal(18,2)),
UTGSTPer=Max(UTGSTPer),
UTGSTAmt=Cast(Sum(UTGSTAmt) as Decimal(18,2)),
CESSPer=Max(CESSPer),
CESSAmt=Cast(Sum(CESSAmt) as Decimal(18,2)),
ADDLCESSPer=Max(ADDLCESSPer),
ADDLCESSAmt=Cast(Sum(ADDLCESSAmt) as Decimal(18,2)),
TotalInterTaxPer = Max(IGSTPer),
TotalIntraTaxPer = Max(CGSTPer)+Max(UTGSTPer+SGSTPer),
Total= Cast(SUM(UTGSTAmt+SGSTAmt+CGSTAmt+CESSAmt+ADDLCESSAmt) As Decimal(18,2)),
IGSTTotal= Cast(Sum(IGSTAmt+CESSAmt+ADDLCESSAmt) As Decimal(18,2))
Into #GSTaxSummary
From #TempInvDet2
Group By UTGSTPer,SGSTPer,IGSTPer,CESSPer,ADDLCESSPer

Declare @TotalTaxValue Decimal(18,6)
Select	@TotalTaxValue = SUM(Isnull(UTGSTAmt,0)+Isnull(SGSTAmt,0)+Isnull(CGSTAmt,0)+Isnull(CESSAmt,0)+Isnull(ADDLCESSAmt,0)+Isnull(IGSTAmt,0))
From #TempInvDet2


Declare @GSTTaxSumText nVarChar(25)
Declare @GSTTaxComp nVarChar(Max)
Declare @GSTTaxComp_DOS nVarChar(Max)
Declare @GSTTaxCompText nVarChar(200)
Declare @GSTTaxCompText_DOS nVarChar(200)

Declare @GSTTaxCompTextNC_DOS nVarChar(200)
Declare @GSTTaxCompNC_DOS nVarChar(Max)

Set @GSTTaxSumText = 'Tax Summary :'
Set @GSTTaxCompText = '    Tax Summary/GST  Component' + space(62) + 'TaxableVal' + Space(12) + 'CGST' + Space(8) + Case when @UTGST_flag = 1 then 'UTGST' Else  '  SGST' End + Space(12) + 'Cess' +  Space(4) + 'AddlCess'+ + Space(6) + 'Total Tax' --+ Char(13)
Set @GSTTaxCompText_DOS=  'Tax Summary/GST  Component' + space(33) + 'TaxableVal ' + Space(6) + 'CGST ' + Space(5) + Case when @UTGST_flag = 1 then 'UTGST' Else  ' SGST' End + Space(7) + 'Cess ' +  Space(2) + 'AddlCess '+ + Space(1) + 'Total Tax'
Set @GSTTaxComp = '  '+ Char(13) + Char(10)+'  |  Tax Summary/GST  Component' + space(62) + 'TaxableVal' + Space(12) + 'CGST' + Space(8) + Case when @UTGST_flag = 1 then 'UTGST' Else  '  SGST' End + Space(12) + 'Cess' +  Space(4) + 'AddlCess'+ + Space(6) + 'Total Tax' + Char(13) + Char(10)
Select @GSTTaxComp = @GSTTaxComp
+ '  |  CGST' + Replicate('  ',5-LEN(Cast(Cast(CGSTPer  As Decimal(5,2)) as nVarChar(5)))) +Cast(Cast(CGSTPer  As Decimal(5,2)) as nVarChar(5))
+ '% + '+ Case when @UTGST_flag = 1 then 'UTGST' Else  'SGST  ' End + Replicate('  ',5-LEN(CAST(Cast(SGSTPer  As Decimal(5,2))+Cast(UTGSTPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(SGSTPer As Decimal(5,2)) As nVarChar(5))
+ '% + Cess' + Replicate('  ',5-LEN(CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5))
+ '% + AddlCess ' +Replicate('  ',5-LEN(LTrim(CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5))))) + CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5)) +'/M' +SPACE(2)
+ ' ' + Replicate('  ',10-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate('  ',10-LEN(LTrim(Cast(Cast(CGSTAmt as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(CGSTAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate('  ',10-LEN(LTrim(cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate('  ',10-LEN(LTrim(cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate('  ',10-LEN(LTrim(Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate('  ',10-LEN(LTrim(Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(Total as Decimal(10,2)) As nVarChar(10)) + Char(13) + Char(10) -- + SPACE(1)
From #GSTaxSummary


Set @GSTTaxCompTextNC_DOS=  '       Rate ' + Space(6) +'TaxableValue ' + Space(6) + 'CGST ' + Space(6) + Case when @UTGST_flag = 1 then 'UTGST' Else  ' SGST' End + Space(3) + 'Total Tax'
--/*
Set @GSTTaxComp_DOS  = ''
Select @GSTTaxComp_DOS  = @GSTTaxComp_DOS
+ 'CGST' + Replicate(' ',5-LEN(Cast(Cast(CGSTPer  As Decimal(5,2)) as nVarChar(5)))) +Cast(Cast(CGSTPer  As Decimal(5,2)) as nVarChar(5))
+ '% + '+ Case when @UTGST_flag = 1 then 'UTGST' Else  'SGST ' End + Replicate(' ',5-LEN(CAST(Cast(SGSTPer  As Decimal(5,2)) + Cast(UTGSTPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(SGSTPer As Decimal(5,2)) As nVarChar(5))
+ '% + Cess' + Replicate(' ',5-LEN(CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5))
+ '% + AddlCess ' +Replicate(' ',5-LEN(LTrim(CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5))))) + CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5)) +'/M' +SPACE(2)
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(CGSTAmt as Decimal(10,2))  As nVarChar(10))))) + Cast(Cast(CGSTAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))  + SPACE(2)
From #GSTaxSummary
--*/

Set @GSTTaxCompNC_DOS  = ''
Select @GSTTaxCompNC_DOS  = @GSTTaxCompNC_DOS
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(TotalIntraTaxPer as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(TotalIntraTaxPer as Decimal(10,2)) As nVarChar(10))
+ '        ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
+ '  ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(CGSTAmt as Decimal(10,2))  As nVarChar(10))))) + Cast(Cast(CGSTAmt as Decimal(10,2)) As nVarChar(10))
+ '  ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(SGSTAmt as Decimal(10,2)) As nVarChar(10))
+ '  ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(Total as Decimal(10,2)) As nVarChar(10))  + SPACE(2)
From #GSTaxSummary


--IGST Changes
Declare @IGSTTaxCompCG nVarchar(Max)
Declare @IGSTTaxCompNonCG nVarchar(Max)
Declare @IGSTTaxCompTextNC nVarchar(Max)
Declare @IGSTTaxCompTextCG nVarchar(Max)

Set @IGSTTaxCompTextCG=  'Tax Summary/GST  Component' + space(20) + 'TaxableVal ' + Space(5) + 'IGST ' + Space(6) + 'Cess ' +  Space(2) + 'AddlCess '+ + Space(1) + 'Total Tax'
Set @IGSTTaxCompTextNC=  '       Rate ' + Space(7) +'TaxableValue ' + Space(7) + 'IGST ' + Space(7) + 'Total Tax'

Set @IGSTTaxCompCG  = ''
Select @IGSTTaxCompCG  = @IGSTTaxCompCG
+ 'IGST' + Replicate(' ',5-LEN(Cast(Cast(IGSTPer  As Decimal(5,2)) as nVarChar(5)))) +Cast(Cast(IGSTPer  As Decimal(5,2)) as nVarChar(5))
+ '% + Cess' + Replicate(' ',5-LEN(CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5)))) + CAST(Cast(CESSPer  As Decimal(5,2)) As nVarChar(5))
+ '% + AddlCess ' +Replicate(' ',5-LEN(LTrim(CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5))))) + CAST(Cast(ADDLCESSPer  As Decimal(4)) As nVarChar(5)) +'/M' +SPACE(2)
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(IGSTAmt as Decimal(10,2))  As nVarChar(10))))) + Cast(Cast(IGSTAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(CESSAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(ADDLCESSAmt as Decimal(10,2)) As nVarChar(10))
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(IGSTTotal as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(IGSTTotal as Decimal(10,2)) As nVarChar(10))  + SPACE(2)
From #GSTaxSummary

Set @IGSTTaxCompNonCG  = ''
Select @IGSTTaxCompNonCG  = @IGSTTaxCompNonCG
+ ' ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(IGSTPer as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(IGSTPer as Decimal(10,2)) As nVarChar(10)) + '% '+
+ '        ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))))) + Cast(Cast(TaxableValue as Decimal(10,2)) As nVarChar(10))
+ '  ' + Replicate(' ',10-LEN(LTrim(Cast(Cast(IGSTAmt as Decimal(10,2))  As nVarChar(10))))) + Cast(Cast(IGSTAmt as Decimal(10,2)) As nVarChar(10))
+ '  ' + Replicate(' ',15-LEN(LTrim(Cast(Cast(IGSTTotal as Decimal(15,2)) As nVarChar(15))))) + Cast(Cast(IGSTTotal as Decimal(15,2)) As nVarChar(15))  + SPACE(2)
From #GSTaxSummary

--Select * From #GSTaxSummary
--Select @IGSTTaxCompNonCG

SELECT
"Invoice Date" = convert(varchar(10),AdjustmentDate,103),
"Doc Ref" = AR.Reference ,
"VendorID" = V.VendorID,
"VendorName" = Vendor_Name,
"Serial No" = CASE Isnull(AR.GSTFlag,0) when 1 then isnull(GSTFullDocID,'') else VP.Prefix + CAST(DocumentID AS nvarchar) end,
"VendorAddress" = Isnull(V.Address,''),
"VendorGSTIN" = Isnull(V.GSTIN,''),
"VendorPAN" = Isnull(PANNumber,''),
"VendorStateCode" = (Select Isnull(ForumStateCode,'') From StateCode where StateCode.StateID = V.BillingStateID),
"VendorStateName" = (Select Isnull(StateName,'') From StateCode where StateCode.StateID = V.BillingStateID),
"VenodrTinNumber" = Isnull(TIN_Number,''),
"FSSAINO" = Case when V.TNGST  = '' then '' Else V.TNGST End,
"Total Taxable Value" = Isnull(AR.Value,0),
"Total Tax Amount" = @TotalTaxValue,
"Total Net Value" = Isnull(AR.Total_Value,0),
"WDName" = @WDName,
"WDGSTIN" = @CompanyGSTIN,
"WDStateName" = @CompanyState,
"WDStateCode" = @CompanySC,
"WDFSSAINO" = @WDFSSAINO,
"WDPhoneNumber" = @WDPhoneNumber,
"WDPANNO" = @CompanyPAN,
"WDTIN_Number" = @TIN_Number,
"Item Count" = @ItemListCount,
"Items Returned" = @ItemCount,
"Tax Summary Text" = @GSTTaxSumText  ,
"NonCG_GSTTax Summary Header" = @GSTTaxCompTextNC_DOS,
"NonCG_GSTTaxComp Details" = @GSTTaxCompNC_DOS,
"CG_GSTTax Summary Header" = @GSTTaxCompText_DOS,
"CG_GSTTaxComp Details" = @GSTTaxComp_DOS,
"CG_IGSTTax_Summary Header" = @IGSTTaxCompTextCG,
"CG_IGSTTaxComp Details" = @IGSTTaxCompCG,
"NonCG_IGST_Summary Header" = @IGSTTaxCompTextNC,
"NonCG_IGSTTaxComp Details" = @IGSTTaxCompNonCG,
"SGST/UTGST" = case @UTGST_flag when 1 then 'UTGST'  else 'SGST' end,
"RefInvoiceNo" = @ODNumber,
"RefInvoiceDate" = @RefInvoiceDate
From AdjustmentReturnAbstract AR
Inner Join Vendors V on AR.VendorID = V.Vendorid
Inner Join VoucherPrefix VP on VP.TranID = N'PURCHASE RETURN'
WHERE AR.AdjustmentID = @PRNO


Drop Table #TempInvDet2
Drop Table #TempTaxDet
Drop Table #GSTaxSummary
Drop Table #tempItemCount

