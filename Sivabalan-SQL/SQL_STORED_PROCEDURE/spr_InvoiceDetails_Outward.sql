Create Procedure spr_InvoiceDetails_Outward
(
@FROMDATE datetime,
@TODATE datetime,
@OutletType nvarchar(100)
)
As
Begin
Set dateformat DMY
Declare @UTGSTFlag int
Select @UTGSTFlag = Isnull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UTGST'

/*Kerala Calamity cess Validation */
Declare @StateCodeID INt
Select @StateCodeID = StateID from StateCode SC
Inner Join Setup S On Sc.StateID = S.BillingStateID
where ForumStateCode = '32'
/*Kerala Calamity cess Validation */

Select Iv.* Into #TempAbstract
From InvoiceAbstract Iv(Nolock)
--Join Customer Tc ON (Iv.CustomerID = Tc.CustomerID)
Where dbo.StripTimeFromDate (Iv.InvoiceDate) BETWEEN dbo.StripTimeFromDate (@FROMDATE) AND dbo.StripTimeFromDate (@TODATE)

--and ((@OutletType in ('Registered','Both') and isnull(Tc.IsRegistered,0) = 1)
--	or(@OutletType in ('Unregistered','Both') and isnull(Tc.IsRegistered,0) <>1))
And Case When @OutletType = 'Registered' Then 1 When @OutletType = 'Unregistered' Then 0 Else 2 End =
Case When @OutletType = 'Both' Then 2 When isnull(Iv.GSTIN,'') <> '' Then 1 When isnull(Iv.GSTIN,'') = '' Then 0 Else 2 End
and (Iv.InvoiceType in (1,3))
and Iv.GSTFlag = 1
and (Iv.Status & 128) = 0

select Distinct C.CustomerID As CustomerID,C.Company_Name As Company_Name  into #TempCustomer from Customer C,#TempAbstract T where C.CustomerID = T.CustomerID

Select G.* Into #TempGSTInvoiceTaxComponents From GSTInvoiceTaxComponents G,#TempAbstract T Where G.InvoiceID=T.InvoiceID

Select  ITC.InvoiceID, Product_Code, SerialNo, ITC.TaxType,
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
From #TempGSTInvoiceTaxComponents ITC(Nolock)
Inner Join TaxComponentDetail TCD ON TCD.TaxComponent_code = ITC.Tax_Component_Code
Inner join #TempAbstract T ON ITC.InvoiceID=T.InvoiceID
--Where ITC.InvoiceID=T.InvoiceID
Group By ITC.InvoiceID, Product_Code, SerialNo, ITC.Tax_Code, ITC.TaxType

Select ID.* Into #TmpInvoiceDetail From InvoiceDetail ID (Nolock),#TempAbstract TA Where ID.InvoiceId=TA.InvoiceID and SalePrice > 0
--in(Select InvoiceID From #TempAbstract) and SalePrice > 0


Select ID.InvoiceID,ID.Product_Code, ID.SalePrice, ID.MRPPerPack, Sum(ID.Quantity) Quantity, Sum(ID.UOMQty) UOMQty, ID.UOMPrice,
Sum(ID.STPayable) STPayable, Sum(ID.CSTPayable) CSTPayable, Sum(ID.DiscountPercentage) DiscountPercentage,
Sum(ID.DiscountValue) DiscountValue, Sum(ID.Amount)  Amount, ID.HSNNumber,
SGSTPer= Case When isnull(T.CS_TaxCode,0) = 0 Then Max(ID.TaxCode + ID.TaxCode2) Else Max(Tmp.SGSTPer) End,
SGSTAmt= Case When isnull(T.CS_TaxCode,0) = 0 Then Sum(STPayable + CSTPayable) Else Sum(Case When UOMQty>0 Then Tmp.SGSTAmt  Else 0 End) End,
CGSTPer= Max(Tmp.CGSTPer), CGSTAmt= Sum(Case When UOMQty>0 Then Tmp.CGSTAmt Else 0 End),
IGSTPer= Max(Tmp.IGSTPer), IGSTAmt= Sum(Case When UOMQty>0 Then Tmp.IGSTAmt Else 0 End) ,
UTGSTPer= Max(Tmp.UTGSTPer), UTGSTAmt= Sum(Case When UOMQty>0 Then Tmp.UTGSTAmt Else 0 End),
CESSPer= Max(Tmp.CESSPer), CESSAmt= Sum(Case When UOMQty>0 Then Tmp.CESSAmt Else 0 End) ,
ADDLCESSPer= Max(Tmp.ADDLCESSPer), ADDLCESSAmt= Sum(Case When UOMQty>0 Then Tmp.ADDLCESSAmt Else 0 End),
CCESSPer = Max(CCESSPer),CCESSAmt = Sum(Case When UOMQty>0 Then Tmp.CCESSAmt Else 0 End),
ID.TaxID, Tmp.TaxType
Into #TmpInvoiceDet
From #TmpInvoiceDetail ID Join #TmpTaxDet Tmp ON ID.InvoiceID = Tmp.InvoiceID and ID.Product_Code = Tmp.Product_Code and ID.Serial = Tmp.SerialNo
Inner Join Tax T ON ID.TaxID = T.Tax_Code
Group By ID.InvoiceID,ID.Product_Code,ID.SalePrice,ID.MRPPerPack,ID.UOMPrice,ID.Serial,ID.HSNNumber,isnull(T.CS_TaxCode,0),ID.TaxID, Tmp.TaxType
Having Sum(ID.UOMQty) > 0


Select "InvID" = IA.InvoiceID,
"GSTINoftheRecipient" = IA.GSTIN,
"CustomerName" = Tc.Company_Name,
"InvoiceNo" = IA.GSTFullDocID,
"InvoiceDate" = IA.InvoiceDate,

--"InvoiceValue" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))) + Sum(ID.STPayable + ID.CSTPayable),

"InvoiceValue" = Max(IA.NetValue) ,--+ Max(IA.RoundOffAmount),
"Rate" = Case When ID.TaxType = 1 Then CAST( Case When @UTGSTFlag = 1 Then ID.UTGSTPer Else ID.SGSTPer End + ID.CGSTPer as Decimal(18,6))
Else CAST(ID.IGSTPer as Decimal(18,6)) End,
"TaxableValue" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)- (((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100)))),
"IGSTAmount" = Sum(isnull(ID.IGSTAmt,0)),
"CGSTAmount" = Sum(isnull(ID.CGSTAmt,0)),
"SGSTAmount" = Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
"CessAmount" = Sum(isnull(ID.CESSAmt,0)) + Sum(isnull(ID.ADDLCESSAmt,0)),
"PlaceofSupply" = Isnull((Select Top 1 StateName From StateCode Where StateID = IA.ToStatecode),''),
"CCESSAmt" = Sum(isnull(ID.CCESSAmt,0))
Into #Temp
From #TempAbstract IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Inner Join #TempCustomer Tc on IA.CustomerID = Tc.CustomerID
Group By
IA.InvoiceID, IA.GSTFullDocID, IA.InvoiceDate, IA.GSTIN, IA.ToStateCode,
IA.DiscountPercentage, ID.SGSTPer, ID.CGSTPer, ID.IGSTPer, ID.UTGSTPer,
IA.AdditionalDiscount, IA.AddlDiscountValue, ID.TaxID, ID.TaxType,Tc.Company_Name


--	Select InvID, "GSTIN of the Recipient" = GSTINoftheRecipient, "Invoice No." = InvoiceNo, "Invoice Date" = InvoiceDate,
--		"Invoice Value" = Sum(InvoiceValue), "Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
--		"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount), "Place of Supply" = PlaceofSupply
--	From #Temp
--	Group By InvID, GSTINoftheRecipient, InvoiceNo, InvoiceDate, Rate, PlaceofSupply



--To get DandD Invoice
Select * Into #TmpDandDInvAbs
From DandDInvAbstract
Where dbo.StripTimeFromDate(DandDInvDate) Between dbo.StripTimeFromDate(@FromDate) and dbo.StripTimeFromDate(@ToDate)
And Case When @OutletType = 'Registered' Then 1 When @OutletType = 'Unregistered' Then 0 Else 2 End =
Case When @OutletType = 'Both' Then 2 When isnull(GSTIN,'') <> '' Then 1 When isnull(GSTIN,'') = '' Then 0 Else 2 End

--Select * From #TmpDandDInvAbs

Select DD.* Into #TmpDandDInvDet From #TmpDandDInvAbs DA
Join DandDInvDetail DD ON DA.DandDInvID = DD.DandDInvID

select Distinct C1.CustomerID As CustomerID,C1.Company_Name As Company_Name into #TempCustomer1 from Customer C1,#TmpDandDInvAbs T where C1.CustomerID = T.CustomerID

--Select * from DandDInvDetail

Select DA.DandDInvID, DA.GSTIN,TC.Company_Name, DA.GSTFullDocID, DA.DandDInvDate, "InvoiceValue" =  DA.ClaimAmount,
"Rate" = Case When DD.TaxType = 1 Then CAST(DD.SGSTRate + DD.CGSTRate as Decimal(18,6)) Else CAST(DD.IGSTRate as Decimal(18,6)) End,
"TaxableValue" = Sum(isnull(DD.TaxableValue,0)),
"IGSTAmount" = Sum(isnull(DD.IGSTAmount,0)),
"CGSTAmount" = Sum(isnull(DD.CGSTAmount,0)),
"SGSTAmount" = Sum(isnull(DD.SGSTAmount,0)),
"CessAmount" = Sum(isnull(DD.CESSAmount,0)) + Sum(isnull(DD.ADDLCESSAmount,0)),
"CCESSAmt" = Sum(isnull(DD.CCESSAmount,0)),
"PlaceofSupply" = Isnull((Select Top 1 StateName From StateCode Where StateID = DA.ToStatecode),'')
Into #TmpDandD
From #TmpDandDInvAbs DA
Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
Inner Join #TempCustomer1 TC ON DA.CustomerID = TC.CustomerID
Group By DA.DandDInvID, DA.GSTIN, DA.GSTFullDocID, DA.DandDInvDate, DA.ToStatecode, DD.SGSTRate, DD.CGSTRate, DD.IGSTRate, DD.TaxType,TC.Company_Name,DA.ClaimAmount

If Isnull(@StateCodeID,0) > 0
Begin
--Union All Invoice and DandD Invoice
Select InvID, "GSTIN of the Recipient" = GSTINoftheRecipient,"Customer Name" = CustomerName, "Invoice No." = InvoiceNo, "Invoice Date" = InvoiceDate,
"Invoice Value" = Max(InvoiceValue), "Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount),"KFC Amount" = Sum(CCESSAmt),"Place of Supply" = PlaceofSupply
From #Temp
Group By InvID, GSTINoftheRecipient, InvoiceNo, InvoiceDate, Rate, PlaceofSupply,CustomerName
Union ALL
Select "InvID" = DandDInvID, "GSTIN of the Recipient" = GSTIN, "Customer Name" = Company_Name, "Invoice No." = GSTFullDocID, "Invoice Date" = DandDInvDate,
"Invoice Value" = Sum(InvoiceValue), "Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount),"KFC Amount" = Sum(CCESSAmt),  "Place of Supply" = PlaceofSupply
From #TmpDandD
Group By DandDInvID, GSTIN, GSTFullDocID, DandDInvDate, Rate, PlaceofSupply,Company_Name
End
Else
Begin
--Union All Invoice and DandD Invoice
Select InvID, "GSTIN of the Recipient" = GSTINoftheRecipient,"Customer Name" = CustomerName, "Invoice No." = InvoiceNo, "Invoice Date" = InvoiceDate,
"Invoice Value" = Max(InvoiceValue), "Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount),"Place of Supply" = PlaceofSupply
From #Temp
Group By InvID, GSTINoftheRecipient, InvoiceNo, InvoiceDate, Rate, PlaceofSupply,CustomerName
Union ALL
Select "InvID" = DandDInvID, "GSTIN of the Recipient" = GSTIN, "Customer Name" = Company_Name, "Invoice No." = GSTFullDocID, "Invoice Date" = DandDInvDate,
"Invoice Value" = Sum(InvoiceValue), "Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount), "Place of Supply" = PlaceofSupply
From #TmpDandD
Group By DandDInvID, GSTIN, GSTFullDocID, DandDInvDate, Rate, PlaceofSupply,Company_Name
End


IF OBJECT_ID('tempdb..#TmpTaxDet') IS NOT NULL
Drop Table #TmpTaxDet

IF OBJECT_ID('tempdb..#TempAbstract') IS NOT NULL
Drop Table #TempAbstract

IF OBJECT_ID('tempdb..#TmpInvoiceDetail') IS NOT NULL
Drop Table #TmpInvoiceDetail

IF OBJECT_ID('tempdb..#TmpInvoiceDet') IS NOT NULL
Drop Table #TmpInvoiceDet

IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
Drop Table #Temp

IF OBJECT_ID('tempdb..#TmpDandDInvAbs') IS NOT NULL
Drop Table #TmpDandDInvAbs

IF OBJECT_ID('tempdb..#TmpDandDInvDet') IS NOT NULL
Drop Table #TmpDandDInvDet

IF OBJECT_ID('tempdb..#TmpDandD') IS NOT NULL
Drop Table #TmpDandD

IF OBJECT_ID('tempdb..#TempCustomer') IS NOT NULL
Drop Table #TempCustomer

IF OBJECT_ID('tempdb..#TempCustomer1') IS NOT NULL
Drop Table #TempCustomer1


END
