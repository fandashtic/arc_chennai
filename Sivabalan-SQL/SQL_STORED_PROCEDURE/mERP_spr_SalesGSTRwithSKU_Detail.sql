Create Procedure mERP_spr_SalesGSTRwithSKU_Detail
(
@ID nVarchar(255),
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

Declare @InvoiceID int
Declare @TaxCode int
Declare @Pos1 int
Declare @Length int
Declare @UTGSTFlag int

Declare @DandD nVarchar(10)

Select @DandD = Left(@ID,5)

Select @UTGSTFlag = Isnull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UTGST'


If @DandD <> 'DAndD'
Begin
Set @Pos1 = CharIndex(N';', @ID, 1)
Set @InvoiceID = cast(SubString(@ID, 1, @Pos1 - 1) as int)
--Set @TaxCode = cast(SubString(@ID, 1, @Pos1 - 0) as int)
Set @TaxCode = Cast(SubString(@ID,@Pos1+1,Len(@ID)) as int)




--Invoice Abstract
Select * Into #TmpInvoiceAbs From InvoiceAbstract
Where InvoiceID = @InvoiceID

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
Join TaxComponentDetail TCD On TCD.TaxComponent_code = ITC.Tax_Component_Code
Where InvoiceID in(Select InvoiceID From #tmpInvoiceAbs) and ITC.Tax_Code = @TaxCode
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

--Select * From #TmpInvoiceDet

--Deleting TaxDetails which as zero tax
--Delete From #TmpInvoiceDet Where isnull(SGSTAmt,0) = 0 and isnull(CGSTAmt,0) = 0 and isnull(IGSTAmt,0) = 0
--	and isnull(CESSAmt,0) = 0 and isnull(ADDLCESSAmt,0) = 0

If Isnull(@StateCodeID,0) > 0
Begin
Select "InvID" = IA.InvoiceID, "Item Code" = ID.Product_Code, "Item Name" = Items.ProductName,
"MRP Per Pac" = Case When isnull(ID.MRPPerPack,0) = 0 Then Items.MRPPerPack Else ID.MRPPerPack End,
"Quantity" = Case When @UOMDesc = 'UOM1' Then SUM(ID.Quantity)/Case When IsNull(Max(Items.UOM1_Conversion), 0) = 0 Then 1 Else Max(Items.UOM1_Conversion) End
When @UOMdesc = 'UOM2' Then SUM(ID.Quantity)/Case When IsNull(Max(Items.UOM2_Conversion), 0) = 0 Then 1 Else Max(Items.UOM2_Conversion) End
Else SUM(ID.Quantity) End,
"UOM" = Case When @UOMDesc = 'UOM1' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = Items.UOM1)
When @UOMdesc = 'UOM2' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = Items.UOM2)
Else (Select Top 1 UOM.Description From UOM Where UOM.UOM = Items.UOM) End,

"Sales Price" = (Case When @UOMdesc = 'UOM1' Then (ID.SalePrice) * Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
When @UOMdesc = 'UOM2' then (ID.SalePrice) * Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
Else ID.SalePrice End),

"Goods Value" = Sum(ID.Quantity * ID.SalePrice),
"Discount%" = Max(ID.DiscountPercentage),
"Discount Amount" = Sum(ID.DiscountValue),
"Other Discount%" = IA.AdditionalDiscount,
"Other DiscAmount" = Sum((ID.Quantity * ID.SalePrice - ID.DiscountValue))*(IA.AdditionalDiscount/100),
"Gross Amount" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))),
"Total Tax Value" = Sum(STPayable + CSTPayable),
"Total Amount" = Sum(Amount),
"HSN Code" = isnull(Items.HSNNumber,''),
"Taxable Sales Value" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))),

"CGST Tax Rate" = isnull(ID.CGSTPer,0), "CGST Tax Amount" = Sum(isnull(ID.CGSTAmt,0)),
"SGST Tax Rate" = Case When @UTGSTFlag = 1 Then isnull(ID.UTGSTPer,0) Else isnull(ID.SGSTPer,0) End,
"SGST Tax Amount" = Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
"IGST Tax Rate" = isnull(ID.IGSTPer,0), "IGST Tax Amount" = Sum(isnull(ID.IGSTAmt,0)),
"Cess Rate" = isnull(ID.CESSPer,0), "Cess Amount" = Sum(isnull(ID.CESSAmt,0)),
"AddlCess Rate" = isnull(ID.ADDLCESSPer,0), "AddlCess Amount"  = Sum(isnull(ID.ADDLCESSAmt,0)),
"KFC Rate" = isnull(ID.CCESSPer,0), "KFC Amount" = Sum(isnull(ID.CCESSAmt,0))
From #TmpInvoiceAbs IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Inner Join Items ON ID.Product_Code = Items.Product_Code
Where ID.TaxID = @TaxCode
Group By IA.InvoiceID, ID.Product_Code, Items.ProductName, ID.MRPPerPack, Items.UOM,Items.UOM1,Items.UOM2, ID.SalePrice,
ID.UTGSTPer, ID.SGSTPer, ID.CGSTPer, ID.IGSTPer, ID.CESSPer, ID.ADDLCESSPer, IA.AdditionalDiscount,
Items.UOM1_Conversion, Items.UOM2_Conversion, isnull(Items.HSNNumber,''), Items.MRPPerPack, ID.TaxID,isnull(ID.CCESSPer,0)
End
Else
Begin
Select "InvID" = IA.InvoiceID, "Item Code" = ID.Product_Code, "Item Name" = Items.ProductName,
"MRP Per Pac" = Case When isnull(ID.MRPPerPack,0) = 0 Then Items.MRPPerPack Else ID.MRPPerPack End,
"Quantity" = Case When @UOMDesc = 'UOM1' Then SUM(ID.Quantity)/Case When IsNull(Max(Items.UOM1_Conversion), 0) = 0 Then 1 Else Max(Items.UOM1_Conversion) End
When @UOMdesc = 'UOM2' Then SUM(ID.Quantity)/Case When IsNull(Max(Items.UOM2_Conversion), 0) = 0 Then 1 Else Max(Items.UOM2_Conversion) End
Else SUM(ID.Quantity) End,
"UOM" = Case When @UOMDesc = 'UOM1' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = Items.UOM1)
When @UOMdesc = 'UOM2' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = Items.UOM2)
Else (Select Top 1 UOM.Description From UOM Where UOM.UOM = Items.UOM) End,

"Sales Price" = (Case When @UOMdesc = 'UOM1' Then (ID.SalePrice) * Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
When @UOMdesc = 'UOM2' then (ID.SalePrice) * Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End
Else ID.SalePrice End),

"Goods Value" = Sum(ID.Quantity * ID.SalePrice),
"Discount%" = Max(ID.DiscountPercentage),
"Discount Amount" = Sum(ID.DiscountValue),
"Other Discount%" = IA.AdditionalDiscount,
"Other DiscAmount" = Sum((ID.Quantity * ID.SalePrice - ID.DiscountValue))*(IA.AdditionalDiscount/100),
"Gross Amount" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))),
"Total Tax Value" = Sum(STPayable + CSTPayable),
"Total Amount" = Sum(Amount),
"HSN Code" = isnull(Items.HSNNumber,''),
"Taxable Sales Value" = (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)))- (Sum(((ID.UOMQty * ID.UOMPrice) - ID.DiscountValue)*(IA.AdditionalDiscount/100))),

"CGST Tax Rate" = isnull(ID.CGSTPer,0), "CGST Tax Amount" = Sum(isnull(ID.CGSTAmt,0)),
"SGST Tax Rate" = Case When @UTGSTFlag = 1 Then isnull(ID.UTGSTPer,0) Else isnull(ID.SGSTPer,0) End,
"SGST Tax Amount" = Case When @UTGSTFlag = 1 Then Sum(isnull(ID.UTGSTAmt,0)) Else Sum(isnull(ID.SGSTAmt,0)) End,
"IGST Tax Rate" = isnull(ID.IGSTPer,0), "IGST Tax Amount" = Sum(isnull(ID.IGSTAmt,0)),
"Cess Rate" = isnull(ID.CESSPer,0), "Cess Amount" = Sum(isnull(ID.CESSAmt,0)),
"AddlCess Rate" = isnull(ID.ADDLCESSPer,0), "AddlCess Amount"  = Sum(isnull(ID.ADDLCESSAmt,0))
From #TmpInvoiceAbs IA
Inner Join #TmpInvoiceDet ID ON IA.InvoiceID = ID.InvoiceID
Inner Join Items ON ID.Product_Code = Items.Product_Code
Where ID.TaxID = @TaxCode
Group By IA.InvoiceID, ID.Product_Code, Items.ProductName, ID.MRPPerPack, Items.UOM,Items.UOM1,Items.UOM2, ID.SalePrice,
ID.UTGSTPer, ID.SGSTPer, ID.CGSTPer, ID.IGSTPer, ID.CESSPer, ID.ADDLCESSPer, IA.AdditionalDiscount,
Items.UOM1_Conversion, Items.UOM2_Conversion, isnull(Items.HSNNumber,''), Items.MRPPerPack, ID.TaxID,isnull(ID.CCESSPer,0)
End


End
Else
Begin
Select @ID = Right(@ID, len(@ID) - 5)
Set @Pos1 = CharIndex(N';', @ID, 1)
Set @InvoiceID = cast(SubString(@ID, 1, @Pos1 - 1) as int)
Set @TaxCode = Cast(SubString(@ID,@Pos1+1,Len(@ID)) as int)
--Select  @InvoiceID,@TaxCode


--To get DandD Invoice
Select * Into #TmpDandDInvAbs
From DandDInvAbstract
Where dbo.StripTimeFromDate(DandDInvDate) Between dbo.StripTimeFromDate(@FromDate) and dbo.StripTimeFromDate(@ToDate)

Select	DD.DandDInvID,
DD.Division,
DD.SubCategory,
DD.MarketSKU,
DD.SystemSKU,
DD.HSN,
DD.UOM,
DD.SaleQty,
DD.SaleValue,
DD.RebateValue,
DD.SalvageQty,
--DD.SalvageValue,
DD.TaxCode,
DD.TaxType,
DD.TaxableValue,
DD.TotalTaxAmount,
DD.CGSTRate,
DD.CGSTAmount,
DD.SGSTRate,
DD.SGSTAmount,
DD.IGSTRate,
DD.IGSTAmount,
DD.CessRate,
DD.CessAmount,
DD.AddlCessRate,
DD.AddlCessAmount,
DDE.Batch_code,
DDE.UOMPTS,
DDE.UOMRFAQty,
DDE.SalvageValue,
DDE.BatchSalvageValue,
DDE.TaxAmount,
DDE.TotalAmount,
DDE.BatchTaxableAmount,
DDE.RFAQuantity as RFAQty,
DDE.PTS as PTS
Into #TmpDandDInvDet
From #TmpDandDInvAbs DA
Join DandDInvDetail DD ON DA.DandDInvID = DD.DandDInvID
Join DandDDetail DDE On DA.DandDID = DDE.ID And DD.SystemSKU = DDE.Product_code
Where DDE.RFAQuantity > 0
And DD.TaxCode = @TaxCode
--And DD.SystemSKU = 'FA2133'



Alter Table #TmpDandDInvDet Add MRPPerPack Decimal(18,6)

Update TTD Set ttd.MRPPerPack = IsNull(BP.MRPPerPack,0) From #TmpDandDInvDet TTD Join Batch_Products BP On BP.Batch_Code = TTD.Batch_Code

select Distinct C1.CustomerID As CustomerID,C1.Company_Name As Company_Name into #TempCustomer1 from Customer C1,#TmpDandDInvAbs T where C1.CustomerID = T.CustomerID

--Select * from #TmpDandDInvDet

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
And Tax_code = @TaxCode
Group By DandDID, Product_Code, ITC.Tax_Code,Batch_Code

--Select * from #TmpDandDInvDetTax where Product_Code = 'FA2133'

If Isnull(@StateCodeID,0) > 0
Begin
Select DA.DandDInvID,
"Item Code" = DD.SystemSKU,
"Item Name" = TC.ProductName,
"MRP Per Pac" = Case When isnull(DD.MRPPerPack,0) = 0 Then TC.MRPPerPack Else DD.MRPPerPack End,
--	"Quantity" = Sum(DD.UOMRFAQty),
"Quantity" = Cast(Case When @UOMDesc = 'UOM1' Then SUM(DD.RFAQty)/Case When IsNull(Max(TC.UOM1_Conversion), 0) = 0 Then 1 Else Max(TC.UOM1_Conversion) End
When @UOMdesc = 'UOM2' Then SUM(DD.RFAQty)/Case When IsNull(Max(TC.UOM2_Conversion), 0) = 0 Then 1 Else Max(TC.UOM2_Conversion) End
Else SUM(DD.RFAQty) End As Decimal(18,6)),
--	"UOM" = DD.UOM,
--	"Sales Price" = DD.UOMPTS,
"UOM" = Case When @UOMDesc = 'UOM1' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = TC.UOM1)
When @UOMdesc = 'UOM2' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = TC.UOM2)
Else (Select Top 1 UOM.Description From UOM Where UOM.UOM = TC.UOM) End,
"Sales Price" = Cast((Case When @UOMdesc = 'UOM1' Then (DD.PTS) * Case When IsNull(TC.UOM1_Conversion, 0) = 0 Then 1 Else TC.UOM1_Conversion End
When @UOMdesc = 'UOM2' then (DD.PTS) * Case When IsNull(TC.UOM2_Conversion, 0) = 0 Then 1 Else TC.UOM2_Conversion End
Else DD.PTS End) As Decimal(18,6)),
"Goods Value"  = isnull(cast(Cast(Case Sum(DD.UOMRFAQty)  * DD.UOMPTS
When 0 then	NULL
Else	cast(Cast(Sum(DD.UOMRFAQty)  * DD.UOMPTS  As decimal(18,6)) as nvarchar)
End As Decimal(18,6) )as decimal(18,6)),0),

--"Goods Value" =TaxableValue,
"Discount%" = 0,
"Discount Amount" = Sum(Isnull(dd.BatchSalvageValue,0)),
"Other Discount%" = 0,
"Other DiscAmount" = 0.000000,
"Gross Amount" = isnull(cast(Cast(Case Sum(DD.UOMRFAQty)  * DD.UOMPTS
When 0 then	NULL
Else	cast(Cast(Sum(DD.UOMRFAQty)  * DD.UOMPTS  As decimal(18,6)) as Decimal(18,6))
End As Decimal(18,6) )as Decimal(18,6)),0) - Sum(Isnull(dd.BatchSalvageValue,0)),
"Total Tax Value" = Sum(DD.TaxAmount),
"Total Amount" =Sum(DD.TotalAmount) - Sum(Isnull(dd.BatchSalvageValue,0)),
"HSN Code" = HSN,
"Taxable Sales Value" = Sum(Isnull(BatchTaxableAmount,0)),
"CGST Tax Rate" = Max(isnull(T.CGSTPer,0)),
"CGST Tax Amount" = Sum(isnull(T.CGSTAmt,0)),
"SGST Tax Rate" = Max(isnull(T.SGSTPer,0)),
"SGST Tax Amount" = Sum(isnull(T.SGSTAmt,0)),
"IGST Tax Rate" = Max(isnull(T.IGSTPer,0)),
"IGST Tax Amount" = Sum(isnull(T.IGSTAmt,0)),
"Cess Rate" = Max(isnull(T.CESSPer,0)),
"Cess Amount" = Sum(isnull(T.CESSAmt,0)),
"AddlCess Rate" = Max(isnull(T.ADDLCESSPer,0)),
"AddlCess Amount" = Sum(isnull(T.ADDLCESSAmt,0)),
"KFC Rate" = Max(isnull(T.CCESSPer,0)),
"KFC Amount" = Sum(isnull(T.CCESSAmt,0))
Into #TmpDandD
From #TmpDandDInvAbs DA
Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
Inner Join Items TC ON DD.SystemSKU = TC.Product_Code
Inner Join #TmpDandDInvDetTax T on DA.DandDID = T.DandDID and DD.SystemSKU =  T.Product_Code and T.Batch_Code = DD.Batch_code
Where DA.DandDInvID = 	@InvoiceID
And DD.TaxCode = @TaxCode
Group By DA.DandDInvID,DD.SystemSKU,TC.ProductName, DD.UOM,HSN,DD.MRPPerPack,TC.UOM1,TC.UOM2,TC.UOM,TC.UOM1_Conversion, TC.UOM2_Conversion
--,DD.TaxableValue,DD.TotalTaxAmount,DD.RebateValue,
--,T.CGSTPer,T.CGSTAmt,T.SGSTAmt,T.SGSTPer,T.IGSTAmt,T.IGSTPer,T.CESSPer,T.CESSAmt,T.ADDLCESSAmt,t.ADDLCESSPer, DD.UOMPTS
--,T.CGSTPer,T.SGSTPer,T.IGSTPer,T.CESSPer,t.ADDLCESSPer
, DD.PTS,TC.MRPPerPack,DD.UOMPTS
End
Else
Begin
Select DA.DandDInvID,
"Item Code" = DD.SystemSKU,
"Item Name" = TC.ProductName,
"MRP Per Pac" = Case When isnull(DD.MRPPerPack,0) = 0 Then TC.MRPPerPack Else DD.MRPPerPack End,
--	"Quantity" = Sum(DD.UOMRFAQty),
"Quantity" = Cast(Case When @UOMDesc = 'UOM1' Then SUM(DD.RFAQty)/Case When IsNull(Max(TC.UOM1_Conversion), 0) = 0 Then 1 Else Max(TC.UOM1_Conversion) End
When @UOMdesc = 'UOM2' Then SUM(DD.RFAQty)/Case When IsNull(Max(TC.UOM2_Conversion), 0) = 0 Then 1 Else Max(TC.UOM2_Conversion) End
Else SUM(DD.RFAQty) End As Decimal(18,6)),
--	"UOM" = DD.UOM,
--	"Sales Price" = DD.UOMPTS,
"UOM" = Case When @UOMDesc = 'UOM1' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = TC.UOM1)
When @UOMdesc = 'UOM2' Then (Select Top 1 UOM.Description From UOM Where UOM.UOM = TC.UOM2)
Else (Select Top 1 UOM.Description From UOM Where UOM.UOM = TC.UOM) End,
"Sales Price" = Cast((Case When @UOMdesc = 'UOM1' Then (DD.PTS) * Case When IsNull(TC.UOM1_Conversion, 0) = 0 Then 1 Else TC.UOM1_Conversion End
When @UOMdesc = 'UOM2' then (DD.PTS) * Case When IsNull(TC.UOM2_Conversion, 0) = 0 Then 1 Else TC.UOM2_Conversion End
Else DD.PTS End) As Decimal(18,6)),
"Goods Value"  = isnull(cast(Cast(Case Sum(DD.UOMRFAQty)  * DD.UOMPTS
When 0 then	NULL
Else	cast(Cast(Sum(DD.UOMRFAQty)  * DD.UOMPTS  As decimal(18,6)) as nvarchar)
End As Decimal(18,6) )as decimal(18,6)),0),

--"Goods Value" =TaxableValue,
"Discount%" = 0,
"Discount Amount" = Sum(Isnull(dd.BatchSalvageValue,0)),
"Other Discount%" = 0,
"Other DiscAmount" = 0.000000,
"Gross Amount" = isnull(cast(Cast(Case Sum(DD.UOMRFAQty)  * DD.UOMPTS
When 0 then	NULL
Else	cast(Cast(Sum(DD.UOMRFAQty)  * DD.UOMPTS  As decimal(18,6)) as Decimal(18,6))
End As Decimal(18,6) )as Decimal(18,6)),0) - Sum(Isnull(dd.BatchSalvageValue,0)),
"Total Tax Value" = Sum(DD.TaxAmount),
"Total Amount" =Sum(DD.TotalAmount) - Sum(Isnull(dd.BatchSalvageValue,0)),
"HSN Code" = HSN,
"Taxable Sales Value" = Sum(Isnull(BatchTaxableAmount,0)),
"CGST Tax Rate" = Max(isnull(T.CGSTPer,0)),
"CGST Tax Amount" = Sum(isnull(T.CGSTAmt,0)),
"SGST Tax Rate" = Max(isnull(T.SGSTPer,0)),
"SGST Tax Amount" = Sum(isnull(T.SGSTAmt,0)),
"IGST Tax Rate" = Max(isnull(T.IGSTPer,0)),
"IGST Tax Amount" = Sum(isnull(T.IGSTAmt,0)),
"Cess Rate" = Max(isnull(T.CESSPer,0)),
"Cess Amount" = Sum(isnull(T.CESSAmt,0)),
"AddlCess Rate" = Max(isnull(T.ADDLCESSPer,0)),
"AddlCess Amount" = Sum(isnull(T.ADDLCESSAmt,0))
Into #TmpDandD1
From #TmpDandDInvAbs DA
Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
Inner Join Items TC ON DD.SystemSKU = TC.Product_Code
Inner Join #TmpDandDInvDetTax T on DA.DandDID = T.DandDID and DD.SystemSKU =  T.Product_Code and T.Batch_Code = DD.Batch_code
Where DA.DandDInvID = 	@InvoiceID
And DD.TaxCode = @TaxCode
Group By DA.DandDInvID,DD.SystemSKU,TC.ProductName, DD.UOM,HSN,DD.MRPPerPack,TC.UOM1,TC.UOM2,TC.UOM,TC.UOM1_Conversion, TC.UOM2_Conversion
--,DD.TaxableValue,DD.TotalTaxAmount,DD.RebateValue,
--,T.CGSTPer,T.CGSTAmt,T.SGSTAmt,T.SGSTPer,T.IGSTAmt,T.IGSTPer,T.CESSPer,T.CESSAmt,T.ADDLCESSAmt,t.ADDLCESSPer, DD.UOMPTS
--,T.CGSTPer,T.SGSTPer,T.IGSTPer,T.CESSPer,t.ADDLCESSPer
, DD.PTS,TC.MRPPerPack,DD.UOMPTS
End

If Isnull(@StateCodeID,0) > 0
Begin
select * from #TmpDandD
End
Else
Begin
Select * from #TmpDandD1
End


End
If @DandD <> 'DAndD'
Begin
Drop Table #TmpInvoiceAbs
Drop Table #TmpInvoiceDet
Drop Table #TmpTaxDet
Drop Table #TmpInvoiceDetail
End
Else
Begin
Drop Table #TmpDandD
Drop Table #TmpDandDInvAbs
Drop Table #TmpDandDInvDet
Drop Table #TempCustomer1
Drop Table #TmpDandDInvDetTax
End

End
