Create Procedure spr_HSNWiseSummary_Outward
(
@FROMDATE datetime,
@TODATE datetime
)
As
Begin

/*Kerala Calamity cess Validation */
Declare @StateCodeID INt
Select @StateCodeID = StateID from StateCode SC
Inner Join Setup S On Sc.StateID = S.BillingStateID
where ForumStateCode = '32'
/*Kerala Calamity cess Validation */

Create Table #TempSum
(
[S.No]         int Identity(1,1) NOT NULL,
[HSN]                         NVarchar(30),
[Description]         Nvarchar(100),
[UQC]                         Nvarchar(30),
[TotalQuantity]  Decimal(18,6),
[TotalValue]         Decimal(18,6),
[TaxableValue]   Decimal(18,6),
[IGSTAmount]         Decimal(18,6),
[CGSTAmount]         Decimal(18,6),
[SGSTAmount]         Decimal(18,6),
[CessAmount]         Decimal(18,6),
[CCESSAmount]        Decimal(18,6)
)

Set DateFormat DMY
Set @FROMDATE = dbo.StripTimeFromDate(@FROMDATE)
Set @TODATE = dbo.StripTimeFromDate(@TODATE)

Declare @UTGSTFlag int
Select @UTGSTFlag = Isnull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UTGST'

Create Table #TmpAbsInvID(InvoiceID int, SRInvoiceID int, InvoiceType int, Flag int)

Insert Into #TmpAbsInvID(InvoiceID, SRInvoiceID, InvoiceType)
Select InvoiceID, SRInvoiceID, InvoiceType
From InvoiceAbstract Iv(Nolock)
--Join Customer Tc ON (Iv.CustomerID = Tc.CustomerID)
Where dbo.StripTimeFromDate(Iv.InvoiceDate) BETWEEN @FROMDATE AND @TODATE
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

Select * Into #TmpInvoiceDetail From InvoiceDetail(Nolock) Where InvoiceId in(Select InvoiceID From #TempAbstract) and SalePrice > 0


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
CCESSPer= Max(Tmp.CCESSPer), CCESSAmt= Sum(Case When UOMQty>0 Then Tmp.CCESSAmt Else 0 End) ,
ID.TaxID, Tmp.TaxType
Into #TmpInvoiceDet
From #TmpInvoiceDetail ID  Join #TmpTaxDet Tmp ON ID.InvoiceID = Tmp.InvoiceID and ID.Product_Code = Tmp.Product_Code and ID.Serial = Tmp.SerialNo
Inner Join Tax T ON ID.TaxID = T.Tax_Code
Group By ID.InvoiceID,ID.Product_Code,ID.SalePrice,ID.MRPPerPack,ID.UOMPrice,ID.Serial,ID.HSNNumber,isnull(T.CS_TaxCode,0),ID.TaxID, Tmp.TaxType
Having Sum(ID.UOMQty) > 0


Select
ID.HSNNumber,
"Quantity" = (Case When InvoiceType = 4 Then -1 Else 1 End) * Sum(Quantity),
"InvoiceValue" = (Case When InvoiceType = 4 Then -1 Else 1 End) * ((Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))) + Sum(ID.STPayable + ID.CSTPayable)),
"TaxableValue" = (Case When InvoiceType = 4 Then -1 Else 1 End) * (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)- (((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100)))),
"IGSTAmount" = (Case When InvoiceType = 4 Then -1 Else 1 End) * Sum(isnull(ID.IGSTAmt,0)),
"CGSTAmount" = (Case When InvoiceType = 4 Then -1 Else 1 End) * Sum(isnull(ID.CGSTAmt,0)),
"SGSTAmount" = (Case When InvoiceType = 4 Then -1 Else 1 End) * Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
"CessAmount" = (Case When InvoiceType = 4 Then -1 Else 1 End) * (Sum(isnull(ID.CESSAmt,0)) + Sum(isnull(ID.ADDLCESSAmt,0))),
"CCESSAmt" = (Case When InvoiceType = 4 Then -1 Else 1 End) * (Sum(isnull(ID.CCESSAmt,0)))
Into #Temp
From #TempAbstract IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Group By
ID.HSNNumber, IA.AdditionalDiscount, InvoiceType

--	Insert Into #TempSum([HSN],[Description],[UQC],[TotalQuantity],[TotalValue],[TaxableValue],[IGSTAmount],[CGSTAmount],[SGSTAmount],[CessAmount])
--		Select HSNNumber,'','',Sum([Quantity]),Sum([InvoiceValue]),Sum([TaxableValue]),Sum([IGSTAmount]),Sum([CGSTAmount]),Sum([SGSTAmount]),
--		Sum([CessAmount])From #Temp Group By HSNNumber Order By HSNNumber

--	Select [S.No], "Sl.No." = [S.No],"HSN" = [HSN], "Description" = [Description],"UQC" = [UQC],
--		"Total Quantity" = [TotalQuantity], "Total Value" = [TotalValue], "Taxable Value" = [TaxableValue],
--		"IGST Amount" = [IGSTAmount], "CGST Amount" = [CGSTAmount], "SGST Amount" = [SGSTAmount], "Cess Amount" = [CessAmount]
--	From #TempSum


--To get DandD Invoice
Select * Into #TmpDandDInvAbs
From DandDInvAbstract
Where dbo.StripTimeFromDate(DandDInvDate) Between dbo.StripTimeFromDate(@FromDate) and dbo.StripTimeFromDate(@ToDate)

--Select * From #TmpDandDInvAbs

Select DD.* Into #TmpDandDInvDet From #TmpDandDInvAbs DA
Join DandDInvDetail DD ON DA.DandDInvID = DD.DandDInvID

--Select * from #TmpDandDInvDet

Select Sum(isnull(DD.RebateValue,0)) as InvoiceValue, Sum(SaleQty) as Quantity,
"TaxableValue" = Sum(isnull(DD.TaxableValue,0)),
"IGSTAmount" = Sum(isnull(DD.IGSTAmount,0)),
"CGSTAmount" = Sum(isnull(DD.CGSTAmount,0)),
"SGSTAmount" = Sum(isnull(DD.SGSTAmount,0)),
"CessAmount" = Sum(isnull(DD.CESSAmount,0)) + Sum(isnull(DD.ADDLCESSAmount,0)),
"CCESSAmt" = Sum(isnull(DD.CCESSAmount,0)),
"HSNNumber" = DD.HSN
Into #TmpDandD
From #TmpDandDInvAbs DA
Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
Group By DD.HSN

--Union All Invoice and DandD Invoice
Insert Into #TempSum([HSN],[Description],[UQC],[TotalQuantity],[TotalValue],[TaxableValue],[IGSTAmount],[CGSTAmount],[SGSTAmount],[CessAmount],CCESSAmount)
Select HSNNumber, '', '', Sum(TotalQuantity), Sum(TotalValue), Sum(TaxableValue), Sum(IGSTAmount), Sum(CGSTAmount),
Sum(SGSTAmount), Sum(CessAmount),Sum(CCESSAmt)
From
(Select HSNNumber,Sum([Quantity]) TotalQuantity,Sum([InvoiceValue]) TotalValue,Sum([TaxableValue]) TaxableValue,
Sum([IGSTAmount]) IGSTAmount,Sum([CGSTAmount]) CGSTAmount,Sum([SGSTAmount]) SGSTAmount,Sum([CessAmount]) CessAmount ,Sum(CCESSAmt) CCESSAmt
From #Temp Group By HSNNumber
Union ALL
Select HSNNumber,Sum([Quantity]) TotalQuantity,Sum([InvoiceValue]) TotalValue,Sum([TaxableValue]) TaxableValue,
Sum([IGSTAmount]) IGSTAmount,Sum([CGSTAmount]) CGSTAmount,Sum([SGSTAmount]) SGSTAmount,Sum([CessAmount]) CessAmount,Sum(CCESSAmt) CCESSAmt
From #TmpDandD Group By HSNNumber) A
Group By HSNNumber
Order By HSNNumber

If Isnull(@StateCodeID,0) > 0
Begin
Select [S.No], "Sl.No." = [S.No],"HSN" = [HSN], "Description" = [Description],"UQC" = [UQC],
"Total Quantity" = [TotalQuantity], "Total Value" = [TotalValue], "Taxable Value" = [TaxableValue],
"IGST Amount" = [IGSTAmount], "CGST Amount" = [CGSTAmount], "SGST Amount" = [SGSTAmount], "Cess Amount" = [CessAmount],"KFC Amount" = [CCESSAmount]
From #TempSum
End
Else
Begin
Select [S.No], "Sl.No." = [S.No],"HSN" = [HSN], "Description" = [Description],"UQC" = [UQC],
"Total Quantity" = [TotalQuantity], "Total Value" = [TotalValue], "Taxable Value" = [TaxableValue],
"IGST Amount" = [IGSTAmount], "CGST Amount" = [CGSTAmount], "SGST Amount" = [SGSTAmount], "Cess Amount" = [CessAmount]
From #TempSum
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

IF OBJECT_ID('tempdb..#TempSum') IS NOT NULL
Drop Table #TempSum

IF OBJECT_ID('tempdb..#TmpDandDInvAbs') IS NOT NULL
Drop Table #TmpDandDInvAbs

IF OBJECT_ID('tempdb..#TmpDandDInvDet') IS NOT NULL
Drop Table #TmpDandDInvDet

IF OBJECT_ID('tempdb..#TmpDandD') IS NOT NULL
Drop Table #TmpDandD
IF OBJECT_ID('tempdb..#TempGSTInvoiceTaxComponents') IS NOT NULL
Drop Table #TempGSTInvoiceTaxComponents
END
