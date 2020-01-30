Create Procedure spr_TaxRate_Outward
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


Create Table #TmpAbsInvID(InvoiceID int, SRInvoiceID int, InvoiceType int, Flag int)

Insert Into #TmpAbsInvID(InvoiceID, SRInvoiceID, InvoiceType)
Select InvoiceID, SRInvoiceID, InvoiceType
From InvoiceAbstract Iv(Nolock)
--Join Customer Tc ON (Iv.CustomerID = Tc.CustomerID)
Where dbo.StripTimeFromDate(Iv.InvoiceDate) BETWEEN dbo.StripTimeFromDate(@FROMDATE) AND dbo.StripTimeFromDate(@TODATE)

--		and ((@OutletType in ('Registered','Both') and isnull(Tc.IsRegistered,0) = 1)
--			or(@OutletType in ('Unregistered','Both') and isnull(Tc.IsRegistered,0) <>1))
And Case When @OutletType = 'Registered' Then 1 When @OutletType = 'Unregistered' Then 0 Else 2 End =
Case When @OutletType = 'Both' Then 2 When isnull(Iv.GSTIN,'') <> '' Then 1 When isnull(Iv.GSTIN,'') = '' Then 0 Else 2 End
and (Iv.InvoiceType in (1,3,4)) and Iv.GSTFlag = 1 and (Iv.Status & 128) = 0

Update T Set T.Flag = 1 From InvoiceAbstract IA(Nolock)
Inner Join #TmpAbsInvID T ON IA.InvoiceID = T.SRInvoiceID and isnull(IA.GSTFlag,0) = 0
Where T.InvoiceType = 4

Delete From #TmpAbsInvID Where isnull(Flag,0) = 1

Select Iv.* Into #TempAbstract
From InvoiceAbstract Iv(Nolock)
Where Iv.InvoiceID in(Select InvoiceID From #TmpAbsInvID)

Select G.* Into #TempGSTInvoiceTaxComponents From GSTInvoiceTaxComponents G,#TempAbstract T Where G.InvoiceID=T.InvoiceID

Select  InvoiceID, Product_Code, SerialNo, ITC.TaxType,
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
Where InvoiceID in(Select InvoiceID From #TempAbstract)
Group By InvoiceID, Product_Code, SerialNo, ITC.Tax_Code, ITC.TaxType

Select ID.* Into #TmpInvoiceDetail From InvoiceDetail ID(Nolock)  join #TempAbstract TA  ON  ID.InvoiceID=Ta.InvoiceID and SalePrice > 0
--Where InvoiceId in(Select InvoiceID From #TempAbstract) and SalePrice > 0

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
CCESSPer = Max(CCESSPer),
CCESSAmt = Sum(CCESSAmt),
ID.TaxID, Tmp.TaxType
Into #TmpInvoiceDet
From #TmpInvoiceDetail ID  Join #TmpTaxDet Tmp ON ID.InvoiceID = Tmp.InvoiceID and ID.Product_Code = Tmp.Product_Code and ID.Serial = Tmp.SerialNo
Inner Join Tax T ON ID.TaxID = T.Tax_Code
Group By ID.InvoiceID,ID.Product_Code,ID.SalePrice,ID.MRPPerPack,ID.UOMPrice,ID.Serial,ID.HSNNumber,isnull(T.CS_TaxCode,0),ID.TaxID, Tmp.TaxType
Having Sum(ID.UOMQty) > 0

Select ID.TaxID,
"Rate" = Case When isnull(ID.TaxType,0) = 1 Then CAST(Case When @UTGSTFlag = 1 Then isnull(ID.UTGSTPer,0) Else isnull(ID.SGSTPer,0) End + isnull(ID.CGSTPer,0) as Decimal(18,6))
When isnull(ID.TaxType,0) = 2 Then CAST(isnull(ID.IGSTPer,0) as Decimal(18,6))
Else CAST(isnull(ID.SGSTPer,0)  as Decimal(18,6)) End,
"TaxableValue" = (Case When InvoiceType = 4 Then -1 Else 1 End) * (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)- (((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue))*(IA.AdditionalDiscount/100))),
"IGSTAmount" = Case When InvoiceType = 4 Then -1 Else 1 End * Sum(isnull(ID.IGSTAmt,0)),
"CGSTAmount" = Case When InvoiceType = 4 Then -1 Else 1 End * Sum(isnull(ID.CGSTAmt,0)),
"SGSTAmount" = Case When InvoiceType = 4 Then -1 Else 1 End * Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
--"CessAmount" = Case When InvoiceType = 4 Then -1 Else 1 End * Sum(isnull(ID.CESSAmt,0)) + Sum(isnull(ID.ADDLCESSAmt,0)),
"CessAmount" = (Case When InvoiceType = 4 Then -1 Else 1 End) * (Sum(isnull(ID.CESSAmt,0)) + Sum(isnull(ID.ADDLCESSAmt,0))),
"CCESSAmt" = (Case When InvoiceType = 4 Then -1 Else 1 End) * (Sum(isnull(ID.CCESSAmt,0))),
"TaxType" = Case When ID.TaxType = 1 Then 'Intra State' Else 'Inter State' End
Into #Temp
From #TempAbstract IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Group By
isnull(ID.SGSTPer,0), isnull(ID.CGSTPer,0), isnull(ID.IGSTPer,0), isnull(ID.UTGSTPer,0),
IA.AdditionalDiscount, ID.TaxID, ID.TaxType, IA.InvoiceType

--	Select 1, "Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
--		"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount), "Tax Type" = TaxType
--	From #Temp
--	Group By Rate, TaxType
--	Order By Rate


--To get DandD Invoice
Select * Into #TmpDandDInvAbs
From DandDInvAbstract
Where dbo.StripTimeFromDate(DandDInvDate) Between dbo.StripTimeFromDate(@FromDate) and dbo.StripTimeFromDate(@ToDate)
And Case When @OutletType = 'Registered' Then 1 When @OutletType = 'Unregistered' Then 0 Else 2 End =
Case When @OutletType = 'Both' Then 2 When isnull(GSTIN,'') <> '' Then 1 When isnull(GSTIN,'') = '' Then 0 Else 2 End

--Select * From #TmpDandDInvAbs

Select DD.* Into #TmpDandDInvDet From #TmpDandDInvAbs DA
Join DandDInvDetail DD ON DA.DandDInvID = DD.DandDInvID

--Select * from #TmpDandDInvDet

Select DA.DandDInvID, DA.GSTIN, DA.GSTFullDocID, DA.DandDInvDate, Sum(isnull(DD.RebateValue,0)) as InvoiceValue,
"Rate" = Case When DD.TaxType = 1 Then CAST(DD.SGSTRate + DD.CGSTRate as Decimal(18,6)) Else CAST(DD.IGSTRate as Decimal(18,6)) End,
"TaxableValue" = Sum(isnull(DD.TaxableValue,0)),
"IGSTAmount" = Sum(isnull(DD.IGSTAmount,0)),
"CGSTAmount" = Sum(isnull(DD.CGSTAmount,0)),
"SGSTAmount" = Sum(isnull(DD.SGSTAmount,0)),
"CessAmount" = Sum(isnull(DD.CESSAmount,0)) + Sum(isnull(DD.ADDLCESSAmount,0)),
"CCESSAmt" = Sum(isnull(DD.CCESSAmount,0)),
"PlaceofSupply" = Isnull((Select Top 1 StateName From StateCode Where StateID = DA.ToStatecode),''),
"TaxType" = Case When DD.TaxType = 1 Then 'Intra State' Else 'Inter State' End
Into #TmpDandD
From #TmpDandDInvAbs DA
Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
Group By DA.DandDInvID, DA.GSTIN, DA.GSTFullDocID, DA.DandDInvDate, DA.ToStatecode, DD.SGSTRate, DD.CGSTRate, DD.IGSTRate, DD.TaxCode, DD.TaxType

If Isnull(@StateCodeID,0) > 0
Begin
--Union All Invoice and DandD Invoice
Select 1, Rate, "Taxable Value" = Sum([Taxable Value]), "IGST Amount" = Sum([IGST Amount]), "CGST Amount" = Sum([CGST Amount]),
"SGST Amount" = Sum([SGST Amount]), "Cess Amount" = Sum([Cess Amount]),"KFC Amount" = Sum([KFC Amount]), "Tax Type" = [Tax Type]
From
(Select "Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount), "KFC Amount" = Sum(CCESSAmt), "Tax Type" = TaxType
From #Temp
Group By Rate, TaxType
--Order By Rate
Union ALL
Select "Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount),"KFC Amount" = Sum(CCESSAmt),  "Tax Type" = TaxType
From #TmpDandD
Group By Rate, TaxType) A
Group By Rate, [Tax Type]
Order By Rate
End
Else
Begin
Select 1, Rate, "Taxable Value" = Sum([Taxable Value]), "IGST Amount" = Sum([IGST Amount]), "CGST Amount" = Sum([CGST Amount]),
"SGST Amount" = Sum([SGST Amount]), "Cess Amount" = Sum([Cess Amount]), "Tax Type" = [Tax Type]
From
(Select "Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount), "Tax Type" = TaxType
From #Temp
Group By Rate, TaxType
--Order By Rate
Union ALL
Select "Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount), "Tax Type" = TaxType
From #TmpDandD
Group By Rate, TaxType) A
Group By Rate, [Tax Type]
Order By Rate
End

IF OBJECT_ID('tempdb..#TmpAbsInvID') IS NOT NULL
Drop Table #TmpAbsInvID

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
IF OBJECT_ID('tempdb..#TempGSTInvoiceTaxComponents') IS NOT NULL
Drop Table #TempGSTInvoiceTaxComponents
END
