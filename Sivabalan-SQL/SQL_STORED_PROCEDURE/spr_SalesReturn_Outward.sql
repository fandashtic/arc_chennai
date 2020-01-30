Create Procedure spr_SalesReturn_Outward
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

Create Table #TmpAbsInvID(InvoiceID int, SRInvoiceID int, Flag int)

Insert Into #TmpAbsInvID(InvoiceID, SRInvoiceID)
Select InvoiceID, SRInvoiceID
From InvoiceAbstract Iv(Nolock)
--Join Customer Tc on (Iv.CustomerID = Tc.CustomerID)
Where dbo.striptimefromdate(Iv.InvoiceDate) BETWEEN dbo.striptimefromdate(@FROMDATE) AND dbo.striptimefromdate(@TODATE)
--and ((@OutletType in ('Registered','Both') and isnull(Tc.IsRegistered,0) = 1)
--	or(@OutletType in ('Unregistered','Both') and isnull(Tc.IsRegistered,0) <>1))

And Case When @OutletType = 'Registered' Then 1 When @OutletType = 'Unregistered' Then 0 Else 2 End =
Case When @OutletType = 'Both' Then 2 When isnull(Iv.GSTIN,'') <> '' Then 1 When isnull(Iv.GSTIN,'') = '' Then 0 Else 2 End
and Iv.GSTFlag = 1 and Iv.InvoiceType = 4 and (Iv.Status & 128) = 0

--	Select T.SRInvoiceID From InvoiceAbstract IA(Nolock)
--	Inner Join #TmpAbsInvID T ON IA.InvoiceID = T.SRInvoiceID Where isnull(IA.GSTFlag,0) = 0

Update T Set T.Flag = 1 From InvoiceAbstract IA(Nolock)
Inner Join #TmpAbsInvID T ON IA.InvoiceID = T.SRInvoiceID and isnull(IA.GSTFlag,0) = 0

Delete From #TmpAbsInvID Where isnull(Flag,0) = 1

Select Iv.* Into #TempAbstract
From InvoiceAbstract Iv(Nolock)
Where Iv.InvoiceID in(Select InvoiceID From #TmpAbsInvID)

select Distinct C.CustomerID As CustomerID,C.Company_Name As Company_Name into #TempCustomer from Customer C,#TempAbstract T where C.CustomerID = T.CustomerID

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
From GSTInvoiceTaxComponents ITC(Nolock)
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
From #TmpInvoiceDetail ID Left Join #TmpTaxDet Tmp ON ID.InvoiceID = Tmp.InvoiceID and ID.Product_Code = Tmp.Product_Code and ID.Serial = Tmp.SerialNo
Inner Join Tax T ON ID.TaxID = T.Tax_Code
Group By ID.InvoiceID,ID.Product_Code,ID.SalePrice,ID.MRPPerPack,ID.UOMPrice,ID.Serial,ID.HSNNumber,isnull(T.CS_TaxCode,0),ID.TaxID, Tmp.TaxType
Having Sum(ID.UOMQty) > 0


Select "InvID" = IA.InvoiceID,
"GSTINoftheRecipient" = IA.GSTIN,
"CustomerName" = Tc.Company_Name,
"InvoiceNo" = (Select Case When isnull(GSTFullDocID,'') = '' Then DocReference Else GSTFullDocID End From InvoiceAbstract(NoLock) Where IA.SRInvoiceID = InvoiceID),
"InvoiceDate" = (Select InvoiceDate From InvoiceAbstract(NoLock) Where IA.SRInvoiceID = InvoiceID),
"CreditNoteNo" = IA.GSTFullDocID,
"CreditNoteDate" = IA.InvoiceDate,

--"CreditNoteValue" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))) + Sum(ID.STPayable + ID.CSTPayable),

"CreditNoteValue" = Max(IA.NetValue) , --+ Max(IA.RoundOffAmount),
"Rate" = Case When isnull(ID.TaxType,0) = 1 Then CAST(Case When @UTGSTFlag = 1 Then isnull(ID.UTGSTPer,0) Else isnull(ID.SGSTPer,0) End + isnull(ID.CGSTPer,0) as Decimal(18,6))
When isnull(ID.TaxType,0) = 2 Then CAST(isnull(ID.IGSTPer,0) as Decimal(18,6))
Else CAST(isnull(ID.SGSTPer,0)  as Decimal(18,6)) End,
"TaxableValue" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)- (((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100)))),
"IGSTAmount" = Sum(isnull(ID.IGSTAmt,0)),
"CGSTAmount" = Sum(isnull(ID.CGSTAmt,0)),
"SGSTAmount" = Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
"CessAmount" = Sum(isnull(ID.CESSAmt,0)) + Sum(isnull(ID.ADDLCESSAmt,0)),
"CCESSAmt" = Sum(isnull(ID.CCESSAmt,0)),
"PlaceofSupply" = Isnull((Select Top 1 StateName From StateCode Where StateID = IA.ToStatecode),'')
Into #Temp
From #TempAbstract IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Inner Join #TempCustomer Tc on IA.CustomerID = Tc.CustomerID
Group By
IA.InvoiceID, IA.GSTFullDocID, IA.InvoiceDate, IA.GSTIN, IA.ToStateCode,
IA.DiscountPercentage, isnull(ID.SGSTPer,0), isnull(ID.CGSTPer,0), isnull(ID.IGSTPer,0), isnull(ID.UTGSTPer,0),
IA.AdditionalDiscount, IA.AddlDiscountValue, ID.TaxID, ID.TaxType, IA.SRInvoiceID,Tc.Company_Name

If Isnull(@StateCodeID,0) > 0
Begin
Select InvID, "GSTIN of the Recipient" = GSTINoftheRecipient, "Customer Name" = CustomerName, "Invoice No." = InvoiceNo, "Invoice Date" = InvoiceDate,
"CreditNote No." = CreditNoteNo, "CreditNote Date" = CreditNoteDate, "CreditNote Value" = Max(CreditNoteValue),
"Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount),"KFC Amount" = Sum(CCESSAmt),  "Place of Supply" = PlaceofSupply
From #Temp
Group By InvID, GSTINoftheRecipient, InvoiceNo, InvoiceDate, CreditNoteNo, CreditNoteDate, Rate, PlaceofSupply,CustomerName
End
Else
Begin
Select InvID, "GSTIN of the Recipient" = GSTINoftheRecipient, "Customer Name" = CustomerName, "Invoice No." = InvoiceNo, "Invoice Date" = InvoiceDate,
"CreditNote No." = CreditNoteNo, "CreditNote Date" = CreditNoteDate, "CreditNote Value" = Max(CreditNoteValue),
"Rate" = Rate, "Taxable Value" = Sum(TaxableValue), "IGST Amount" = Sum(IGSTAmount),
"CGST Amount" = Sum(CGSTAmount), "SGST Amount" = Sum(SGSTAmount), "Cess Amount" = Sum(CessAmount),  "Place of Supply" = PlaceofSupply
From #Temp
Group By InvID, GSTINoftheRecipient, InvoiceNo, InvoiceDate, CreditNoteNo, CreditNoteDate, Rate, PlaceofSupply,CustomerName
End

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

IF OBJECT_ID('tempdb..#TempCustomer') IS NOT NULL
Drop Table #TempCustomer


END
