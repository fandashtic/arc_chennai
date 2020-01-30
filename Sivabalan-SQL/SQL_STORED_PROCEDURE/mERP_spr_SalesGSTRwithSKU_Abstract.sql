Create Procedure mERP_spr_SalesGSTRwithSKU_Abstract
(
@FROMDATE Datetime,
@TODATE Datetime,
@DocType nVarchar(100),
@UOMDesc nVarchar(30),
@TransactionType nVarchar(100)
)
As
Begin

/*Kerala Calamity cess Validation */
Declare @StateCodeID INt
Select @StateCodeID = StateID from StateCode SC
Inner Join Setup S On Sc.StateID = S.BillingStateID
where ForumStateCode = '32'
/*Kerala Calamity cess Validation */

If @TransactionType = '%'
Begin
Set @TransactionType = 'Without D & D'
End

Declare @SALESRETURNSALEABLE As NVarchar(50)
Declare @SALESRETURNDAMAGES As NVarchar(50)
Declare @RETAILINVOICE As NVarchar(50)
Declare @RETAILSALESRETURNSALEABLE As NVarchar(50)
Declare @RETAILSALESRETURNDAMAGES As NVarchar(50)
Declare @INVOICE As NVarchar(50)
Declare @CREDIT As NVarchar(50)
Declare @OTHERS As NVarchar(50)
Declare @CASH As NVarchar(50)
Declare @CHEQUE As NVarchar(50)
Declare @DD As NVarchar(50)
Declare @CREDITCARD As NVarchar(50)
Declare @COUPON As NVarchar(50)
Declare @UTGSTFlag int

Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Sales Return Saleable',Default)
Set @SALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'Sales Return Damages',Default)
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice',Default)
Set @RETAILSALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'RetailSales Return Saleable',Default)
Set @RETAILSALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'RetailSales Return Damages',Default)
set @INVOICE = dbo.LookupDictionaryItem(N'Invoice',Default)
set @CREDIT = dbo.LookupDictionaryItem(N'Credit',Default)
set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)
Set @CASH = dbo.LookupDictionaryItem(N'Cash',Default)
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque',Default)
Set @DD = dbo.LookupDictionaryItem(N'DD',Default)
Set @CREDITCARD = dbo.LookupDictionaryItem(N'Credit Card',Default)
Set @COUPON = dbo.LookupDictionaryItem(N'Coupon',Default)

Set DateFormat DMY
Set @FROMDATE = dbo.StripTimeFromDate(@FROMDATE)
Set @TODATE = dbo.StripTimeFromDate(@TODATE)

Select @UTGSTFlag = Isnull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UTGST'

--Select DocSerialType, * from InvoiceAbstract order by 1 desc
--Invoice Abstract
Select * Into #TmpInvoiceAbs From InvoiceAbstract
Where
isnull(Status,0) & 128 = 0
and dbo.StripTimeFromDate(InvoiceDate) BETWEEN @FROMDATE AND @TODATE
and DocSerialType Like @DocType and isnull(GSTFlag,0) = 1

--Tax Details
Select  InvoiceID, Product_Code, SerialNo,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.NetTaxAmount Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.NetTaxAmount Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.NetTaxAmount Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.NetTaxAmount Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.NetTaxAmount Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.NetTaxAmount Else 0 End),
CCESSPer = Max(Case When TCD.TaxComponent_desc = 'Calamity CESS' Then ITC.Tax_Percentage Else 0 End),
CCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'Calamity CESS' Then ITC.NetTaxAmount Else 0 End),
ITC.Tax_Code
Into #TmpTaxDet
From GSTInvoiceTaxComponents ITC
Inner Join TaxComponentDetail TCD ON TCD.TaxComponent_code = ITC.Tax_Component_Code
Where InvoiceID in(Select InvoiceID From #tmpInvoiceAbs)
Group By InvoiceID, Product_Code, SerialNo, ITC.Tax_Code


Select * Into #TmpInvoiceDetail From InvoiceDetail Where InvoiceId in(Select InvoiceID From #tmpInvoiceAbs) and SalePrice > 0

----InvoiceDetails with Tax
----	Select InvoiceID,Product_Code, SalePrice, MRPPerPack, Sum(Quantity) Quantity, Sum(UOMQty) UOMQty, UOMPrice,
----			Sum(STPayable) STPayable, Sum(CSTPayable) CSTPayable,
----			Sum(DiscountPercentage) DiscountPercentage, Sum(DiscountValue) DiscountValue, Sum(Amount)  Amount, HSNNumber,
----		SGSTPer= Case When isnull(T.CS_TaxCode,0) = 0 Then Max(ID.TaxCode + ID.TaxCode2) Else (Select SGSTPer  From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0 ) End,
----		SGSTAmt= Case When isnull(T.CS_TaxCode,0) = 0 Then Sum(STPayable + CSTPayable) Else (Select Sum(SGSTAmt) From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0 ) End,
----		CGSTPer=(Select CGSTPer From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0 ) ,
----		CGSTAmt=(Select Sum(CGSTAmt) From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0 ) ,
----		IGSTPer=(Select IGSTPer From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0 ) ,
----		IGSTAmt=(Select Sum(IGSTAmt) From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0 ) ,
----		UTGSTPer=(Select UTGSTPer From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and	Sum(UOMQty) > 0 ) ,
----		UTGSTAmt=(Select Sum(UTGSTAmt) From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0 ) ,
----		CESSPer=(Select CESSPer From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0 ) ,
----		CESSAmt=(Select Sum(CESSAmt) From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0 ),
----		ADDLCESSPer=(Select ADDLCESSPer From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0) ,
----		ADDLCESSAmt=(Select Sum(ADDLCESSAmt) From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0),
----		--Tax_Code = (Select Tax_Code From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0),
----		--Case When isnull(ID.GSTCSTaxCode,0) = 0
----		ID.TaxID
----	Into #TmpInvoiceDet
----	From #TmpInvoiceDetail ID Inner Join Tax T ON ID.TaxID = T.Tax_Code
----	Group By InvoiceID,Product_Code, SalePrice, MRPPerPack, UOMPrice, Serial, HSNNumber,isnull(T.CS_TaxCode,0), ID.TaxID  --, UOMQty


Select ID.InvoiceID,ID.Product_Code, ID.SalePrice, ID.MRPPerPack, Sum(ID.Quantity) Quantity, Sum(ID.UOMQty) UOMQty, ID.UOMPrice,
Sum(ID.STPayable) STPayable, Sum(ID.CSTPayable) CSTPayable, Sum(ID.DiscountPercentage) DiscountPercentage,
Sum(ID.DiscountValue) DiscountValue, Sum(ID.Amount)  Amount, ID.HSNNumber,
SGSTPer= Case When isnull(T.CS_TaxCode,0) = 0 Then Max(ID.TaxCode + ID.TaxCode2) Else Max(Tmp.SGSTPer) End,
SGSTAmt= Case When isnull(T.CS_TaxCode,0) = 0 Then Sum(STPayable + CSTPayable) Else Sum(Case When UOMQty>0 Then Tmp.SGSTAmt  Else 0 End) End,
CGSTPer= Max(Tmp.CGSTPer), CGSTAmt= Sum(Case When UOMQty>0 Then Tmp.CGSTAmt Else 0 End),
IGSTPer= Max(Tmp.IGSTPer), IGSTAmt= Sum(Case When UOMQty>0 Then Tmp.IGSTAmt Else 0 End) ,
UTGSTPer= Max(Tmp.UTGSTPer), UTGSTAmt= Sum(Case When UOMQty>0 Then Tmp.UTGSTAmt Else 0 End),
CESSPer= Max(Tmp.CESSPer), CESSAmt= Sum(Case When UOMQty>0 Then Tmp.CESSAmt Else 0 End) ,
ADDLCESSPer= Max(Tmp.ADDLCESSPer), ADDLCESSAmt= Sum(Case When UOMQty>0 Then Tmp.ADDLCESSAmt Else 0 End) ,
CCESSPer= Max(Tmp.CCESSPer), CCESSAmt= Sum(Case When UOMQty>0 Then Tmp.CCESSAmt Else 0 End) ,
--Tax_Code = (Select Tax_Code From #TmpTaxDet Where InvoiceID = ID.InvoiceID And Product_Code = ID.Product_Code And SerialNo= ID.Serial and Sum(UOMQty) > 0),
ID.TaxID
Into #TmpInvoiceDet
From #TmpInvoiceDetail ID Left Join #TmpTaxDet Tmp ON ID.InvoiceID = Tmp.InvoiceID and ID.Product_Code = Tmp.Product_Code and ID.Serial = Tmp.SerialNo --and ID.UOMQty > 0
Inner Join Tax T ON ID.TaxID = T.Tax_Code
Group By ID.InvoiceID,ID.Product_Code,ID.SalePrice,ID.MRPPerPack,ID.UOMPrice,ID.Serial,ID.HSNNumber,isnull(T.CS_TaxCode,0),ID.TaxID
--, Tmp.SGSTPer, Tmp.CGSTPer, Tmp.IGSTPer, Tmp.UTGSTPer, Tmp.CESSPer, Tmp.ADDLCESSPer
Having Sum(ID.UOMQty) > 0


--Deleting TaxDetails which as zero tax
--Delete From #TmpInvoiceDet Where isnull(SGSTAmt,0) = 0 and isnull(CGSTAmt,0) = 0 and isnull(IGSTAmt,0) = 0
--	and isnull(CESSAmt,0) = 0 and isnull(ADDLCESSAmt,0) = 0

--Select InvoiceID, SGSTPer, Sum(SGSTAmt) SGSTAmt, CGSTPer, Sum(CGSTAmt) CGSTAmt, IGSTPer, Sum(IGSTAmt) IGSTAmt, CESSPer,
--	Sum(CESSAmt) CESSAmt, ADDLCESSPer, Sum(ADDLCESSAmt) ADDLCESSAmt,
--	Sum(((UOMQty * UOMPrice) - DiscountValue)) TaxableAmt
--Into #TmpTaxSplitDets From #TmpInvoiceDet Group By InvoiceID, SGSTPer, CGSTPer, IGSTPer, CESSPer, ADDLCESSPer

If Isnull(@TransactionType,'') = 'With D & D'
Begin
--To get DandD Invoice
Select IA.DandDInvID,IA.DandDInvDate,IA.CustomerID,IA.GSTDocID,IA.GSTFullDocID,IA.DandDID,IA.ClaimID,
IA.Status,IA.SubmissionDate,IA.SchemeType,IA.ActivityCode,IA.Description,IA.ActiveFrom,IA.ActiveTo,IA.PayoutFrom,
IA.PayoutTo,IA.DamageOption,IA.UserName,IA.GreenDandD,IA.TaxAmount,IA.ClaimAmount,IA.Balance,IA.GSTIN,IA.FromStateCode,IA.ToStateCode,IA.CreationDate,
DA.DocumentID
Into #TmpDandDInvAbs
From DandDInvAbstract IA
Inner Join DandDAbstract  DA on IA.DandDID = DA.ID
where dbo.StripTimeFromDate(DandDInvDate) Between dbo.StripTimeFromDate(@FromDate) and dbo.StripTimeFromDate(@ToDate)


--Select * from #TmpDandDInvAbs

Select IDENTITY  (int ,1, 1)  as RowID,DA.GSTFullDocID,DA.DocumentID,DandDInvDate,DA.CustomerID,DD.DandDInvID,DD.SystemSKU,DD.TaxCode ,DDE.UOMPTS , DDE.UOMRFAQty
,DD.CGSTRate,DD.CGSTAmount,dd.SGSTRate,dd.SGSTAmount,dd.IGSTRate,dd.IGSTAmount,DD.CessRate,DD.CessAmount,DD.AddlCessRate
,DD.AddlCessAmount,DD.TaxType,DD.TaxableValue,DDE.SalvageValue,DDE.Batch_code,DDE.BatchTaxableAmount
Into #TmpDandDInvDet
From #TmpDandDInvAbs DA
Join DandDInvDetail DD ON DA.DandDInvID = DD.DandDInvID
Join DandDDetail DDE On DA.DandDID = DDE.ID And DD.SystemSKU = DDE.Product_code
Where DDE.RFAQuantity > 0


Select Max(RowID) RowID,SystemSKU,Count(SystemSKU) As 'SKUCount'
Into #TempDuplicateSalvageValue
from #TmpDandDInvDet Where Isnull(SalvageValue,0) > 0
Group by SystemSKU
Having Count(SystemSKU) > 1


Update #TmpDandDInvDet Set SalvageValue = 0
From #TmpDandDInvDet TID
Inner Join #TempDuplicateSalvageValue TD on TID.SystemSKU = TD.SystemSKU
Where TID.RowID <> TD.RowID


--Select DD.* Into #TmpDandDInvDet From #TmpDandDInvAbs DA
--Join DandDInvDetail DD ON DA.DandDInvID = DD.DandDInvID
--Join DandDDetail DDE On DA.DandDID = DDE.ID

--select * from #TmpDandDInvDet

select Distinct C1.CustomerID As CustomerID,C1.Company_Name As Company_Name into #TempCustomer1 from Customer C1,#TmpDandDInvAbs T where C1.CustomerID = T.CustomerID

--			Select * from #TmpDandDInvDet

--Tax Details
Select  DandDID, Product_Code,Batch_Code,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Value Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Value Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Value Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Value Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End),
CCESSPer = Max(Case When TCD.TaxComponent_desc = 'Calamity CESS' Then ITC.Tax_Percentage Else 0 End),
CCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'Calamity CESS' Then ITC.Tax_Value Else 0 End),
ITC.Tax_Code
Into #TmpDandDInvDetTax
From DandDTaxComponents ITC
Inner Join TaxComponentDetail TCD ON TCD.TaxComponent_code = ITC.Tax_Component_Code
Where DandDID in(Select DandDID From #TmpDandDInvAbs)
Group By DandDID, Product_Code, ITC.Tax_Code,Batch_Code

--Select * from #TmpDandDInvDetTax


Select	DA.DandDInvID,
DA.DocumentID,
DA.GSTIN,
DA.CustomerID,
TC.Company_Name,
DA.GSTFullDocID,
DA.DandDInvDate,
"InvoiceValue" =  DA.ClaimAmount,
"Rate" = Case When DD.TaxType = 1 Then CAST(DD.SGSTRate + DD.CGSTRate as Decimal(18,6)) Else CAST(DD.IGSTRate as Decimal(18,6)) End,
"Goods Value" = UOMPTS * Sum(DD.UOMRFAQTY),
"Product Discount" = Isnull(DD.SalvageValue,0),
"Other Discount" = 0,
"Gross Value" =  Cast(((UOMPTS * Sum(DD.UOMRFAQTY)) -  (Isnull(DD.SalvageValue,0))) As Decimal(18,6)),
"Tax Value" = Cast(Sum(isnull(T.IGSTAmt,0)) + Sum(isnull(T.CGSTAmt,0)) + Sum(isnull(T.SGSTAmt,0))+Sum(isnull(T.CESSAmt,0))+Sum(isnull(T.ADDLCESSAmt,0)) As Decimal(18,6)),
"Net Value" = Cast(((UOMPTS * Sum(DD.UOMRFAQTY)) -  (Isnull(DD.SalvageValue,0))) + Sum(isnull(T.IGSTAmt,0)) + Sum(isnull(T.CGSTAmt,0)) + Sum(isnull(T.SGSTAmt,0))+Sum(isnull(T.CESSAmt,0))+Sum(isnull(T.ADDLCESSAmt,0)) As Decimal(18,6)),
"TaxableValue" = Sum(isnull(DD.BatchTaxableAmount,0)),
"IGSTRate" = max(isnull(T.IGSTPer,0)),
"IGSTAmount" = Sum(isnull(T.IGSTAmt,0)),
"CGSTRate" = Max(isnull(T.CGSTper,0)),
"CGSTAmount" = Sum(isnull(T.CGSTAmt,0)),
"SGSTRate" = Max(isnull(T.SGSTper,0)),
"SGSTAmount" = Sum(isnull(T.SGSTAmt,0)),
"CessRate" = Max(isnull(T.CESSper,0)) ,
"CessAmount" = Sum(isnull(T.CESSAmt,0)) ,
"AddlCessRate" = Max(isnull(T.ADDLCESSPer,0)),
"AddlCessAmount" = Sum(isnull(T.ADDLCESSAmt,0)),
"CCessRate" = Max(isnull(T.CCESSper,0)) ,
"CCessAmount" = Sum(isnull(T.CCESSAmt,0)) ,
"StateCode" = DA.ToStatecode,
"TaxCode" = DD.TaxCode,
"PlaceofSupply" = Isnull((Select Top 1 StateName From StateCode Where StateID = DA.ToStatecode),'')
Into #TmpDandD
From #TmpDandDInvAbs DA
Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
Inner Join #TempCustomer1 TC ON DA.CustomerID = TC.CustomerID
Inner Join #TmpDandDInvDetTax T on DA.DandDID = T.DandDID and DD.SystemSKU =  T.Product_Code and T.Batch_Code = DD.Batch_code
Group By DA.DandDInvID, DA.GSTIN, DA.GSTFullDocID, DA.DandDInvDate, DA.ToStatecode, DD.SGSTRate, DD.CGSTRate, DD.IGSTRate,
DD.TaxType,TC.Company_Name,DA.ClaimAmount,DA.CustomerID, DD.TaxCode,DA.DocumentID,UOMPTS,Isnull(DD.SalvageValue,0)
End

If Isnull(@TransactionType,'') = 'With D & D'
If Isnull(@StateCodeID,0) > 0
Begin
Select "InvID" = Cast(IA.InvoiceID as nVarchar) + ';' + Cast(ID.TaxID as nVarchar),
"InvoiceID" = IA.GSTFullDocID, "Doc Ref No." = IA.DocReference, "Date" = IA.InvoiceDate,

"Type" = Case InvoiceType WHEN 4 THEN Case isnull(Status,0) & 32 When 0 Then @SALESRETURNSALEABLE Else @SALESRETURNDAMAGES End
WHEN 2 THEN @RETAILINVOICE
WHEN 5 THEN @RETAILSALESRETURNSALEABLE
WHEN 6 THEN @RETAILSALESRETURNDAMAGES  ELSE @INVOICE END,

"Payment Mode" =  Case When Isnull(InvoiceType,0) = 2 Then Case IsNull(PaymentMode,0) When 0 Then @CREDIT When 1 Then @OTHERS End
When (Isnull(InvoiceType,0) = 1) OR (Isnull(InvoiceType,0) = 3) Then
Case IsNull(PaymentMode,0) When 0 Then @CREDIT  When 1 Then @CASH  When 2 Then @CHEQUE  When 3 Then @DD
When 4 Then @CREDITCARD  When 5 Then @COUPON Else @CREDIT End
When Isnull(InvoiceType,0) = 4 Then @CREDIT
When Isnull(InvoiceType,0) = 5 Then @CREDIT
When Isnull(InvoiceType,0) = 6 Then @CREDIT  End,
"Payment Date" = IA.PaymentDate, "CreditTerm" = CT.Description,
"CustomerID" = IA.CustomerID, "Customer" = C.Company_Name, "GSTIN of Outlet" = IA.GSTIN,
"Outlet StateCode" = (Select Top 1 ForumStateCode From StateCode Where StateID = IA.ToStateCode),
"Beat" = B.Description, "Salesman" = S.Salesman_Name,
"Goods Value" = Sum(ID.Quantity * SalePrice),    --IA.GoodsValue,
"Product Discount" = Sum(ID.DiscountValue), --IA.ProductDiscount,
"Other Discount" =(Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))),  --IA.AddlDiscountValue,
"Gross Value" =  (Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)))- (Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))), --GST_Changes ---IA.GrossValue,
"Tax Value" = Sum(ID.STPayable + ID.CSTPayable),  --IA.VatTaxAmount,
"Net Value" = Sum(ID.Amount),  --IA.NetValue,
"Taxable Sales Value" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))), --GST_Changes

"CGST Tax Rate" = isnull(ID.CGSTPer,0), "CGST Tax Amount" = Sum(isnull(ID.CGSTAmt,0)),
"SGST Tax Rate" = Case When @UTGSTFlag = 1 Then isnull(ID.UTGSTPer,0) Else isnull(ID.SGSTPer,0) End ,
"SGST Tax Amount" = Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
"IGST Tax Rate" = isnull(ID.IGSTPer,0), "IGST Tax Amount" = Sum(isnull(ID.IGSTAmt,0)),
"Cess Rate" = isnull(ID.CESSPer,0), "Cess Amount" = Sum(isnull(ID.CESSAmt,0)),
"AddlCess Rate" = isnull(ID.ADDLCESSPer,0), "AddlCess Amount"  = Sum(isnull(ID.ADDLCESSAmt,0)),
"KFC Rate" = isnull(ID.CCESSPer,0), "KFC Amount" = Sum(isnull(ID.CCESSAmt,0))
From #TmpInvoiceAbs IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Inner Join Customer C ON IA.CustomerID = C.CustomerID
Inner Join Salesman S ON IA.SalesmanID = S.SalesmanID
Left Join Beat B ON IA.BeatID = B.BeatID
Left Join CreditTerm CT ON IA.CreditTerm = CT.CreditID
Group By
IA.InvoiceID, IA.GSTFullDocID, IA.DocReference, IA.InvoiceDate, IA.InvoiceType, IA.PaymentMode, IA.PaymentDate,
IA.CreditTerm,	IA.CustomerID, C.Company_Name, IA.GSTIN, IA.ToStateCode, B.Description, S.Salesman_Name,IA.GoodsValue,
IA.ProductDiscount, IA.GrossValue, IA.NetValue, IA.Status, CT.Description, IA.DiscountPercentage, IA.VatTaxAmount,
ID.UTGSTPer, ID.SGSTPer, ID.CGSTPer, ID.IGSTPer, ID.CESSPer, ID.ADDLCESSPer, IA.AdditionalDiscount, IA.AddlDiscountValue,
ID.TaxID,isnull(ID.CCESSPer,0)
Union All
Select Cast('DAndD' as nvarchar) + Cast(DandDInvID as nVarchar) + ';' + Cast(TaxCode as nVarchar) As Inv,
GSTFullDocID,
Cast(DocumentID as nVarchar(100)),
DandDInvDate,
'D & D Invoice',
'Credit',
DandDInvDate,
'N/A',
Customerid,
Company_Name,
GSTIN,
StateCode,
'','',
Cast(Sum([Goods Value]) As Decimal(18,6)),
Cast(Sum([Product Discount]) As Decimal(18,6)),
Cast(Sum([Other Discount]) As Decimal(18,6)),
Cast(Sum([Gross Value]) As Decimal(18,6)),
Cast(Sum([Tax Value]) As Decimal(18,6)),
Cast(Sum([Net Value]) As Decimal(18,6)),
Cast(Sum(TaxableValue) As Decimal(18,6)),
Max(CGSTRate),
Cast(sum(CGSTAmount) As Decimal(18,6)),
Max(SGSTRate),
Cast(Sum(SGSTAmount) As Decimal(18,6)),
Max(IGSTRate),
Cast(Sum(IGSTAmount) As Decimal(18,6)),
Max(CessRate),
Cast(Sum(CessAmount) As Decimal(18,6)),
Max(AddlCessRate),
Cast(Sum(AddlCessAmount) As Decimal(18,6)),
Max(CCessRate),
Cast(Sum(CCessAmount) As Decimal(18,6))
from #TmpDandD
Group by DandDInvID,GSTFullDocID,DocumentID,DandDInvDate,Customerid,Company_Name,GSTIN,StateCode,TaxCode
End
Else
Begin
Select "InvID" = Cast(IA.InvoiceID as nVarchar) + ';' + Cast(ID.TaxID as nVarchar),
"InvoiceID" = IA.GSTFullDocID, "Doc Ref No." = IA.DocReference, "Date" = IA.InvoiceDate,

"Type" = Case InvoiceType WHEN 4 THEN Case isnull(Status,0) & 32 When 0 Then @SALESRETURNSALEABLE Else @SALESRETURNDAMAGES End
WHEN 2 THEN @RETAILINVOICE
WHEN 5 THEN @RETAILSALESRETURNSALEABLE
WHEN 6 THEN @RETAILSALESRETURNDAMAGES  ELSE @INVOICE END,

"Payment Mode" =  Case When Isnull(InvoiceType,0) = 2 Then Case IsNull(PaymentMode,0) When 0 Then @CREDIT When 1 Then @OTHERS End
When (Isnull(InvoiceType,0) = 1) OR (Isnull(InvoiceType,0) = 3) Then
Case IsNull(PaymentMode,0) When 0 Then @CREDIT  When 1 Then @CASH  When 2 Then @CHEQUE  When 3 Then @DD
When 4 Then @CREDITCARD  When 5 Then @COUPON Else @CREDIT End
When Isnull(InvoiceType,0) = 4 Then @CREDIT
When Isnull(InvoiceType,0) = 5 Then @CREDIT
When Isnull(InvoiceType,0) = 6 Then @CREDIT  End,
"Payment Date" = IA.PaymentDate, "CreditTerm" = CT.Description,
"CustomerID" = IA.CustomerID, "Customer" = C.Company_Name, "GSTIN of Outlet" = IA.GSTIN,
"Outlet StateCode" = (Select Top 1 ForumStateCode From StateCode Where StateID = IA.ToStateCode),
"Beat" = B.Description, "Salesman" = S.Salesman_Name,
"Goods Value" = Sum(ID.Quantity * SalePrice),    --IA.GoodsValue,
"Product Discount" = Sum(ID.DiscountValue), --IA.ProductDiscount,
"Other Discount" =(Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))),  --IA.AddlDiscountValue,
"Gross Value" =  (Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)))- (Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))), --GST_Changes ---IA.GrossValue,
"Tax Value" = Sum(ID.STPayable + ID.CSTPayable),  --IA.VatTaxAmount,
"Net Value" = Sum(ID.Amount),  --IA.NetValue,
"Taxable Sales Value" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))), --GST_Changes

"CGST Tax Rate" = isnull(ID.CGSTPer,0), "CGST Tax Amount" = Sum(isnull(ID.CGSTAmt,0)),
"SGST Tax Rate" = Case When @UTGSTFlag = 1 Then isnull(ID.UTGSTPer,0) Else isnull(ID.SGSTPer,0) End ,
"SGST Tax Amount" = Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
"IGST Tax Rate" = isnull(ID.IGSTPer,0), "IGST Tax Amount" = Sum(isnull(ID.IGSTAmt,0)),
"Cess Rate" = isnull(ID.CESSPer,0), "Cess Amount" = Sum(isnull(ID.CESSAmt,0)),
"AddlCess Rate" = isnull(ID.ADDLCESSPer,0), "AddlCess Amount"  = Sum(isnull(ID.ADDLCESSAmt,0))
From #TmpInvoiceAbs IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Inner Join Customer C ON IA.CustomerID = C.CustomerID
Inner Join Salesman S ON IA.SalesmanID = S.SalesmanID
Left Join Beat B ON IA.BeatID = B.BeatID
Left Join CreditTerm CT ON IA.CreditTerm = CT.CreditID
Group By
IA.InvoiceID, IA.GSTFullDocID, IA.DocReference, IA.InvoiceDate, IA.InvoiceType, IA.PaymentMode, IA.PaymentDate,
IA.CreditTerm,	IA.CustomerID, C.Company_Name, IA.GSTIN, IA.ToStateCode, B.Description, S.Salesman_Name,IA.GoodsValue,
IA.ProductDiscount, IA.GrossValue, IA.NetValue, IA.Status, CT.Description, IA.DiscountPercentage, IA.VatTaxAmount,
ID.UTGSTPer, ID.SGSTPer, ID.CGSTPer, ID.IGSTPer, ID.CESSPer, ID.ADDLCESSPer, IA.AdditionalDiscount, IA.AddlDiscountValue,
ID.TaxID,isnull(ID.CCESSPer,0)
Union All
Select Cast('DAndD' as nvarchar) + Cast(DandDInvID as nVarchar) + ';' + Cast(TaxCode as nVarchar) As Inv,
GSTFullDocID,
Cast(DocumentID as nVarchar(100)),
DandDInvDate,
'D & D Invoice',
'Credit',
DandDInvDate,
'N/A',
Customerid,
Company_Name,
GSTIN,
StateCode,
'','',
Cast(Sum([Goods Value]) As Decimal(18,6)),
Cast(Sum([Product Discount]) As Decimal(18,6)),
Cast(Sum([Other Discount]) As Decimal(18,6)),
Cast(Sum([Gross Value]) As Decimal(18,6)),
Cast(Sum([Tax Value]) As Decimal(18,6)),
Cast(Sum([Net Value]) As Decimal(18,6)),
Cast(Sum(TaxableValue) As Decimal(18,6)),
Max(CGSTRate),
Cast(sum(CGSTAmount) As Decimal(18,6)),
Max(SGSTRate),
Cast(Sum(SGSTAmount) As Decimal(18,6)),
Max(IGSTRate),
Cast(Sum(IGSTAmount) As Decimal(18,6)),
Max(CessRate),
Cast(Sum(CessAmount) As Decimal(18,6)),
Max(AddlCessRate),
Cast(Sum(AddlCessAmount) As Decimal(18,6))
from #TmpDandD
Group by DandDInvID,GSTFullDocID,DocumentID,DandDInvDate,Customerid,Company_Name,GSTIN,StateCode,TaxCode
End
Else
If Isnull(@StateCodeID,0) > 0
Begin
Select "InvID" = Cast(IA.InvoiceID as nVarchar) + ';' + Cast(ID.TaxID as nVarchar),
"InvoiceID" = IA.GSTFullDocID, "Doc Ref No." = IA.DocReference, "Date" = IA.InvoiceDate,

"Type" = Case InvoiceType WHEN 4 THEN Case isnull(Status,0) & 32 When 0 Then @SALESRETURNSALEABLE Else @SALESRETURNDAMAGES End
WHEN 2 THEN @RETAILINVOICE
WHEN 5 THEN @RETAILSALESRETURNSALEABLE
WHEN 6 THEN @RETAILSALESRETURNDAMAGES  ELSE @INVOICE END,

"Payment Mode" =  Case When Isnull(InvoiceType,0) = 2 Then Case IsNull(PaymentMode,0) When 0 Then @CREDIT When 1 Then @OTHERS End
When (Isnull(InvoiceType,0) = 1) OR (Isnull(InvoiceType,0) = 3) Then
Case IsNull(PaymentMode,0) When 0 Then @CREDIT  When 1 Then @CASH  When 2 Then @CHEQUE  When 3 Then @DD
When 4 Then @CREDITCARD  When 5 Then @COUPON Else @CREDIT End
When Isnull(InvoiceType,0) = 4 Then @CREDIT
When Isnull(InvoiceType,0) = 5 Then @CREDIT
When Isnull(InvoiceType,0) = 6 Then @CREDIT  End,
"Payment Date" = IA.PaymentDate, "CreditTerm" = CT.Description,
"CustomerID" = IA.CustomerID, "Customer" = C.Company_Name, "GSTIN of Outlet" = IA.GSTIN,
"Outlet StateCode" = (Select Top 1 ForumStateCode From StateCode Where StateID = IA.ToStateCode),
"Beat" = B.Description, "Salesman" = S.Salesman_Name,
"Goods Value" = Sum(ID.Quantity * SalePrice),    --IA.GoodsValue,
"Product Discount" = Sum(ID.DiscountValue), --IA.ProductDiscount,
"Other Discount" =(Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))),  --IA.AddlDiscountValue,
"Gross Value" =  (Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)))- (Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))), --GST_Changes ---IA.GrossValue,
"Tax Value" = Sum(ID.STPayable + ID.CSTPayable),  --IA.VatTaxAmount,
"Net Value" = Sum(ID.Amount),  --IA.NetValue,
"Taxable Sales Value" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))), --GST_Changes

"CGST Tax Rate" = isnull(ID.CGSTPer,0), "CGST Tax Amount" = Sum(isnull(ID.CGSTAmt,0)),
"SGST Tax Rate" = Case When @UTGSTFlag = 1 Then isnull(ID.UTGSTPer,0) Else isnull(ID.SGSTPer,0) End ,
"SGST Tax Amount" = Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
"IGST Tax Rate" = isnull(ID.IGSTPer,0), "IGST Tax Amount" = Sum(isnull(ID.IGSTAmt,0)),
"Cess Rate" = isnull(ID.CESSPer,0), "Cess Amount" = Sum(isnull(ID.CESSAmt,0)),
"AddlCess Rate" = isnull(ID.ADDLCESSPer,0), "AddlCess Amount"  = Sum(isnull(ID.ADDLCESSAmt,0)),
"KFC Rate" = isnull(ID.CCESSPer,0), "KFC Amount" = Sum(isnull(ID.CCESSAmt,0))
From #TmpInvoiceAbs IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Inner Join Customer C ON IA.CustomerID = C.CustomerID
Inner Join Salesman S ON IA.SalesmanID = S.SalesmanID
Left Join Beat B ON IA.BeatID = B.BeatID
Left Join CreditTerm CT ON IA.CreditTerm = CT.CreditID
Group By
IA.InvoiceID, IA.GSTFullDocID, IA.DocReference, IA.InvoiceDate, IA.InvoiceType, IA.PaymentMode, IA.PaymentDate,
IA.CreditTerm,	IA.CustomerID, C.Company_Name, IA.GSTIN, IA.ToStateCode, B.Description, S.Salesman_Name,IA.GoodsValue,
IA.ProductDiscount, IA.GrossValue, IA.NetValue, IA.Status, CT.Description, IA.DiscountPercentage, IA.VatTaxAmount,
ID.UTGSTPer, ID.SGSTPer, ID.CGSTPer, ID.IGSTPer, ID.CESSPer, ID.ADDLCESSPer, IA.AdditionalDiscount, IA.AddlDiscountValue,ID.CCESSPer,
ID.TaxID
Order By IA.GSTFullDocID
End
Else
Begin
Select "InvID" = Cast(IA.InvoiceID as nVarchar) + ';' + Cast(ID.TaxID as nVarchar),
"InvoiceID" = IA.GSTFullDocID, "Doc Ref No." = IA.DocReference, "Date" = IA.InvoiceDate,

"Type" = Case InvoiceType WHEN 4 THEN Case isnull(Status,0) & 32 When 0 Then @SALESRETURNSALEABLE Else @SALESRETURNDAMAGES End
WHEN 2 THEN @RETAILINVOICE
WHEN 5 THEN @RETAILSALESRETURNSALEABLE
WHEN 6 THEN @RETAILSALESRETURNDAMAGES  ELSE @INVOICE END,

"Payment Mode" =  Case When Isnull(InvoiceType,0) = 2 Then Case IsNull(PaymentMode,0) When 0 Then @CREDIT When 1 Then @OTHERS End
When (Isnull(InvoiceType,0) = 1) OR (Isnull(InvoiceType,0) = 3) Then
Case IsNull(PaymentMode,0) When 0 Then @CREDIT  When 1 Then @CASH  When 2 Then @CHEQUE  When 3 Then @DD
When 4 Then @CREDITCARD  When 5 Then @COUPON Else @CREDIT End
When Isnull(InvoiceType,0) = 4 Then @CREDIT
When Isnull(InvoiceType,0) = 5 Then @CREDIT
When Isnull(InvoiceType,0) = 6 Then @CREDIT  End,
"Payment Date" = IA.PaymentDate, "CreditTerm" = CT.Description,
"CustomerID" = IA.CustomerID, "Customer" = C.Company_Name, "GSTIN of Outlet" = IA.GSTIN,
"Outlet StateCode" = (Select Top 1 ForumStateCode From StateCode Where StateID = IA.ToStateCode),
"Beat" = B.Description, "Salesman" = S.Salesman_Name,
"Goods Value" = Sum(ID.Quantity * SalePrice),    --IA.GoodsValue,
"Product Discount" = Sum(ID.DiscountValue), --IA.ProductDiscount,
"Other Discount" =(Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))),  --IA.AddlDiscountValue,
"Gross Value" =  (Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)))- (Sum(((ID.Quantity * ID.SalePrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))), --GST_Changes ---IA.GrossValue,
"Tax Value" = Sum(ID.STPayable + ID.CSTPayable),  --IA.VatTaxAmount,
"Net Value" = Sum(ID.Amount),  --IA.NetValue,
"Taxable Sales Value" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))), --GST_Changes

"CGST Tax Rate" = isnull(ID.CGSTPer,0), "CGST Tax Amount" = Sum(isnull(ID.CGSTAmt,0)),
"SGST Tax Rate" = Case When @UTGSTFlag = 1 Then isnull(ID.UTGSTPer,0) Else isnull(ID.SGSTPer,0) End ,
"SGST Tax Amount" = Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
"IGST Tax Rate" = isnull(ID.IGSTPer,0), "IGST Tax Amount" = Sum(isnull(ID.IGSTAmt,0)),
"Cess Rate" = isnull(ID.CESSPer,0), "Cess Amount" = Sum(isnull(ID.CESSAmt,0)),
"AddlCess Rate" = isnull(ID.ADDLCESSPer,0), "AddlCess Amount"  = Sum(isnull(ID.ADDLCESSAmt,0))
From #TmpInvoiceAbs IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Inner Join Customer C ON IA.CustomerID = C.CustomerID
Inner Join Salesman S ON IA.SalesmanID = S.SalesmanID
Left Join Beat B ON IA.BeatID = B.BeatID
Left Join CreditTerm CT ON IA.CreditTerm = CT.CreditID
Group By
IA.InvoiceID, IA.GSTFullDocID, IA.DocReference, IA.InvoiceDate, IA.InvoiceType, IA.PaymentMode, IA.PaymentDate,
IA.CreditTerm,	IA.CustomerID, C.Company_Name, IA.GSTIN, IA.ToStateCode, B.Description, S.Salesman_Name,IA.GoodsValue,
IA.ProductDiscount, IA.GrossValue, IA.NetValue, IA.Status, CT.Description, IA.DiscountPercentage, IA.VatTaxAmount,
ID.UTGSTPer, ID.SGSTPer, ID.CGSTPer, ID.IGSTPer, ID.CESSPer, ID.ADDLCESSPer, IA.AdditionalDiscount, IA.AddlDiscountValue,ID.CCESSPer,
ID.TaxID
Order By IA.GSTFullDocID
End

If Isnull(@TransactionType,'') = 'With D & D'
Begin
Drop Table #TmpInvoiceAbs
Drop Table #TmpInvoiceDet
Drop Table #TmpTaxDet
Drop Table #TmpInvoiceDetail
Drop Table #TmpDandDInvDetTax

Drop Table #TmpDandD
Drop Table #TmpDandDInvAbs
Drop Table #TmpDandDInvDet
Drop Table #TempCustomer1
Drop Table #TempDuplicateSalvageValue
End
Else
Begin
Drop Table #TmpInvoiceAbs
Drop Table #TmpInvoiceDet
Drop Table #TmpTaxDet
Drop Table #TmpInvoiceDetail
End
End
