CREATE PROCEDURE spr_list_Inward_invoicesDetails
(
@FROMDATE datetime,
@TODATE datetime
)
AS
BEGIN
Set DateFormat DMY

Declare @UTGSTFlag int
Select @UTGSTFlag = Isnull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UTGST'

Create Table #TempInward
(
[GSTINOfTheSupplier] Nvarchar(30),
[InvoiceNo]	NVarchar(100),
[InvoiceDate]	Datetime,
[InvoiceValue]	Decimal(18,6),
[Rate] Decimal(18,6),
[TaxableValue] Decimal(18,6),
[IGSTAmount]	Decimal(18,6),
[CGSTAmount]	Decimal(18,6),
[SGSTAmount]	Decimal(18,6),
[CessAmount]	Decimal(18,6),
[PlaceofSupply] Nvarchar(100),
[TaxCode] int
)
Create Table #TempBillAbstract
(
BillID int,
BillDate	Datetime,
VendorID	Nvarchar(100),
Value decimal (18,6),
TaxAmount decimal (18,6),
GSTIN Nvarchar(100),
ODNumber Nvarchar(100),
FromStatecode int,
ToStatecode int,
StateType int,
Status Int
)
	--Manual Invoice
	Insert Into #TempBillAbstract(BillID,BillDate,VendorID,Value,TaxAmount,GSTIN,ODNumber,FromStatecode,ToStatecode,StateType,Status)
	Select BA.BillID ,BA.BillDate ,BA.VendorID ,Value,TaxAmount,Isnull(BA.GSTIN,'') GSTIN,Isnull(BA.ODNumber,'') ODNumber,
	ISNULL(BA.FromStatecode,0) FromStatecode,ISNULL(BA.ToStatecode,0) ToStatecode  , Isnull(BA.StateType,0),Isnull(BA.Status,0)
	from BillAbstract BA(Nolock)
	where dbo.StripTimeFromDate(BillDate) >= dbo.StripTimeFromDate(@FROMDATE) 
    AND dbo.StripTimeFromDate(BillDate) <= dbo.StripTimeFromDate(@TODATE )
	AND (Isnull(BA.Status,0) & 128) = 0
	AND VendorID Not In (Select Distinct VendorID from InvoiceAbstractReceived) 
	--Online Invoices
	Insert Into #TempBillAbstract(BillID,BillDate,VendorID,Value,TaxAmount,GSTIN,ODNumber,FromStatecode,ToStatecode,StateType,Status)
	Select BA.BillID ,IAR.InvoiceDate ,BA.VendorID ,Value,TaxAmount,Isnull(BA.GSTIN,''),Isnull(BA.ODNumber,''),
	ISNULL(BA.FromStatecode,0),ISNULL(BA.ToStatecode,0),Isnull(BA.StateType,0),Isnull(BA.Status,0)
	from BillAbstract BA(Nolock) Inner Join InvoiceAbstractReceived IAR On IAR.DocumentID =BA.InvoiceReference 
	Where IAR.InvoiceID = (Select Top 1 RecdInvoiceID from GRNAbstract where BillID = BA.BillID )
	And dbo.StripTimeFromDate(IAR.InvoiceDate) >= dbo.StripTimeFromDate(@FROMDATE)
	AND dbo.StripTimeFromDate(IAR.InvoiceDate) <= dbo.StripTimeFromDate(@TODATE )
	AND (Isnull(BA.Status,0) & 128) = 0
		
	Select  BillID, Product_Code, Tax_Code ,SerialNo,  
	SGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'SGST' Then btc.Tax_Value Else 0 End) as decimal(18,6)), 
	SGSTper = Cast(Max(Case When TCD.TaxComponent_desc = 'SGST' Then btc.Tax_Percentage Else 0 End) as decimal(18,6)), 
	CGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'CGST' Then btc.Tax_Value Else 0 End) as decimal(18,6)),  
	CGSTper = Cast(Max(Case When TCD.TaxComponent_desc = 'CGST' Then btc.Tax_Percentage Else 0 End) as decimal(18,6)),
	IGSTPer = Cast(Max(Case When TCD.TaxComponent_desc = 'IGST' Then btc.Tax_Percentage  Else 0 End) as decimal(18,6)), 
	IGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'IGST' Then btc.Tax_Value Else 0 End) as decimal(18,6)), 
	UTGSTPer = Cast(Max(Case When TCD.TaxComponent_desc = 'UTGST' Then btc.Tax_Percentage  Else 0 End) as decimal(18,6)), 
	UTGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then btc.Tax_Value Else 0 End) as decimal(18,6)),
	CESSAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'CESS' Then btc.Tax_Value Else 0 End) as decimal(18,6)),
	AddCessAmt =  Cast(Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then btc.Tax_Value Else 0 End) as decimal(18,6))
	Into #TempTaxDet
	From GSTBillTaxComponents btc(Nolock) Join TaxComponentDetail TCD (Nolock)
	On( TCD.TaxComponent_code = btc.Tax_Component_Code )
	Group By BillID, Product_Code, Tax_Code ,SerialNo  
	
	
	Insert Into #TempInward
	([GSTINOfTheSupplier],[InvoiceNo],[InvoiceDate],[InvoiceValue],[Rate],
	[TaxableValue],[IGSTAmount],[CGSTAmount],[SGSTAmount],[CessAmount],[PlaceofSupply])
	Select 
	ISNULL(BA.GSTIN,''),-- GSTIN of supplier
	ISNULL(BA.ODNumber,''),-- invoice no  
	BA.BillDate, -- invoice date	 
	--IsNull((Select InvoiceDate From InvoiceAbstractReceived Where InvoiceID = (Select Top 1 RecdInvoiceID from GRNAbstract where BillID = BA.BillID )),BA.BillDate),
	--bldt.Amount+bldt.TaxAmount,-- invoice value
	(BA.Value + BA.TaxAmount),  -- invoice value
	Case when BA.StateType = 2 Then tmp2.IGSTPer   Else Isnull(CAST((Case When @UTGSTFlag = 1 Then tmp2.UTGSTPer Else tmp2.SGSTper End) + tmp2.CGSTper as Decimal(18,2)),0) End, --Rate
	bldt.Amount,--TaxableValue
	ISNULL(cast(Cast(tmp2.IGSTAmt as Decimal(18,6)) as nVarchar),0),--"IGSTAmount"
	ISNULL(cast(Cast(tmp2.CGSTAmt as Decimal(18,6)) as nVarchar),0),--"CGSTAmount"
	--ISNULL(cast(Cast(tmp2.SGSTAmt as Decimal(18,2)) as nVarchar),0),--"SGSTAmount"
	Case When @UTGSTFlag = 1 Then tmp2.UTGSTAmt  Else tmp2.SGSTAmt End,
	ISNULL(CAST(CAST(tmp2.CESSAmt + AddCessAmt  as Decimal(18,6)) as nvarchar),0), --"CessAmount"
	Isnull((Select StateName from StateCode where StateID = BA.FromStatecode),'')--placeofsupply	
	From #TempBillAbstract  BA(Nolock) JOIN BillDetail bldt(Nolock) On(	BA.BillID = bldt.BillID)
	LEFT OUTER JOIN  #TempTaxDet tmp2(Nolock) On( tmp2.BillID = bldt.BillID And tmp2.Product_Code =bldt.Product_Code 
    and tmp2.Tax_Code = bldt.TaxCode and tmp2.SerialNo = bldt.Serial)
	

	Select 0,"GSTIN Of The Supplier"=[GSTINOfTheSupplier],"Invoice No"=[InvoiceNo],"Invoice Date"=[InvoiceDate],"Invoice Value"=[InvoiceValue]
	,"Rate"=[Rate],"Taxable Value"=Sum([TaxableValue]) ,"IGST Amount"=SUM([IGSTAmount])  ,"CGST Amount"=SUM([CGSTAmount]) ,
	"SGST Amount"=SUM([SGSTAmount]), "Cess Amount"=SUM([CessAmount]),"Place of Supply"=[PlaceofSupply]
	From #TempInward(Nolock)
	Group By #TempInward.GSTINOfTheSupplier,#TempInward.InvoiceNo,#TempInward.[InvoiceValue],#TempInward.InvoiceDate,
	#TempInward.Rate,PlaceofSupply


IF OBJECT_ID('tempdb..#TempBillAbstract') IS NOT NULL
	Drop Table #TempBillAbstract
                                                                                   
IF OBJECT_ID('tempdb..#TempTaxDet') IS NOT NULL
	Drop Table #TempTaxDet

IF OBJECT_ID('tempdb..#TempTaxableValue') IS NOT NULL
	Drop Table #TempTaxableValue

IF OBJECT_ID('tempdb..#TempInward') IS NOT NULL
	Drop Table #TempInward
	
End
