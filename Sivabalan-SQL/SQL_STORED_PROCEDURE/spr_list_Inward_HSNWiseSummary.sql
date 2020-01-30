CREATE PROCEDURE spr_list_Inward_HSNWiseSummary
(
@FROMDATE datetime,
@TODATE datetime
)
AS
BEGIN
set dateformat DMY

Declare @UTGSTFlag int
Select @UTGSTFlag = Isnull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UTGST'


Create Table #TempHSNWiseSum
(
[S.No]	 int Identity(1,1) NOT NULL,
[HSN]			 NVarchar(30),
[Description]	 Nvarchar(100),
[UQC]			 Nvarchar(30),
[TotalQuantity]  Decimal(18,6),
[TotalValue]	 Decimal(18,6),
[TaxableValue]   Decimal(18,6),
[IGSTAmount]	 Decimal(18,6),
[CGSTAmount]	 Decimal(18,6),
[SGSTAmount]	 Decimal(18,6),
[CessAmount]	 Decimal(18,6)
)

Create Table #TempHSNWise
(
[S.No]	 int Identity(1,1) NOT NULL,
[HSN]			 NVarchar(30),
[Description]	 Nvarchar(100),
[UQC]			 Nvarchar(30),
[TotalQuantity]  Decimal(18,6),
[TotalValue]	 Decimal(18,6),
[TaxableValue]   Decimal(18,6),
[IGSTAmount]	 Decimal(18,6),
[CGSTAmount]	 Decimal(18,6),
[SGSTAmount]	 Decimal(18,6),
[CessAmount]	 Decimal(18,6)
)
Create Table #TempBillAbstract
(
BillID int,
BillDate	Datetime,
VendorID	Nvarchar(100),
GSTIN Nvarchar(100),
ODNumber Nvarchar(100),
FromStatecode int,
ToStatecode int,
StateType int,
Status Int
)
	--Manual Invoice
	Insert Into #TempBillAbstract(BillID,BillDate,VendorID,GSTIN,ODNumber,FromStatecode,ToStatecode,StateType,Status)
	Select BA.BillID ,BA.BillDate ,BA.VendorID ,Isnull(BA.GSTIN,'') GSTIN,Isnull(BA.ODNumber,'') ODNumber,
	ISNULL(BA.FromStatecode,0) FromStatecode,ISNULL(BA.ToStatecode,0) ToStatecode  , Isnull(BA.StateType,0),Isnull(BA.Status,0)
	from BillAbstract BA(Nolock)
	where dbo.StripTimeFromDate(BillDate) >= dbo.StripTimeFromDate(@FROMDATE) 
    AND dbo.StripTimeFromDate(BillDate) <= dbo.StripTimeFromDate(@TODATE )
	AND (Isnull(BA.Status,0) & 128) = 0
	AND VendorID Not In (Select Distinct VendorID from InvoiceAbstractReceived) 
	--Online Invoices
	Insert Into #TempBillAbstract(BillID,BillDate,VendorID,GSTIN,ODNumber,FromStatecode,ToStatecode,StateType,Status)
	Select BA.BillID ,IAR.InvoiceDate ,BA.VendorID ,Isnull(BA.GSTIN,''),Isnull(BA.ODNumber,''),
	ISNULL(BA.FromStatecode,0),ISNULL(BA.ToStatecode,0),Isnull(BA.StateType,0),Isnull(BA.Status,0)
	from BillAbstract BA(Nolock) Inner Join InvoiceAbstractReceived IAR On IAR.DocumentID =BA.InvoiceReference 
	Where IAR.InvoiceID = (Select Top 1 RecdInvoiceID from GRNAbstract where BillID = BA.BillID )
	And dbo.StripTimeFromDate(IAR.InvoiceDate) >= dbo.StripTimeFromDate(@FROMDATE)
	AND dbo.StripTimeFromDate(IAR.InvoiceDate) <= dbo.StripTimeFromDate(@TODATE )
	AND (Isnull(BA.Status,0) & 128) = 0
	
	Select  BillID, Product_Code, Tax_Code ,SerialNo,  
	SGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'SGST' Then btc.Tax_Value Else 0 End) as decimal(18,6)), 
	UTGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then btc.Tax_Value Else 0 End) as decimal(18,6)), 
	CGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'CGST' Then btc.Tax_Value Else 0 End) as decimal(18,6)),  
	IGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'IGST' Then btc.Tax_Value Else 0 End) as decimal(18,6)), 	
	CESSAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'CESS' Then btc.Tax_Value Else 0 End) as decimal(18,6)),
	AddCessAmt =  Cast(Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then btc.Tax_Value Else 0 End) as decimal(18,6))
	Into #TempTaxDet
	From GSTBillTaxComponents btc(Nolock) Join TaxComponentDetail TCD (Nolock)
	On( TCD.TaxComponent_code = btc.Tax_Component_Code )
	Group By BillID, Product_Code, Tax_Code ,SerialNo

	Select  PRTC.AdjustmentID , Product_Code, Tax_Code ,SerialNo,  
	SGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'SGST' Then PRTC.Tax_Value Else 0 End) as decimal(18,6)), 
	UTGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then PRTC.Tax_Value Else 0 End) as decimal(18,6)), 
	CGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'CGST' Then PRTC.Tax_Value Else 0 End) as decimal(18,6)),  
	IGSTAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'IGST' Then PRTC.Tax_Value Else 0 End) as decimal(18,6)), 	
	CESSAmt = Cast(Sum(Case When TCD.TaxComponent_desc = 'CESS' Then PRTC.Tax_Value Else 0 End) as decimal(18,6)),
	AddCessAmt =  Cast(Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then PRTC.Tax_Value Else 0 End) as decimal(18,6))
	Into #TempPRTaxDet
	From PRTaxComponents PRTC(Nolock) 
	Join AdjustmentReturnAbstract AR(Nolock) On PRTC.AdjustmentID  = AR.AdjustmentID And IsNull(AR.Status,0) & 128 = 0
	AND dbo.StripTimeFromDate(AdjustmentDate ) >= dbo.StripTimeFromDate(@FROMDATE) 
    AND dbo.StripTimeFromDate(AdjustmentDate) <= dbo.StripTimeFromDate(@TODATE )
	Join TaxComponentDetail TCD (Nolock) On (TCD.TaxComponent_code = PRTC.Tax_Component_Code)
	Group By PRTC.AdjustmentID , Product_Code, Tax_Code ,SerialNo
	
	Insert Into #TempHSNWise
	([HSN],[Description],[UQC],[TotalQuantity],[TotalValue],
	[TaxableValue],[IGSTAmount],[CGSTAmount],[SGSTAmount],[CessAmount])
	Select 	 
	Isnull(bldt.HSNNumber,''),--HSN
	'',-- description
	'', -- uqc	 
    ISNULL(bldt.Quantity,0), --total quantity
	Isnull(bldt.Amount + bldt.TaxAmount,0),--total value
	(bldt.Amount),--TaxableValue
	(tmp2.IGSTAmt ),--"IGSTAmount"
	(tmp2.CGSTAmt ),--"CGSTAmount"
	Case When @UTGSTFlag = 1 Then tmp2.UTGSTAmt Else tmp2.SGSTAmt End,
	ISNULL(CAST(CAST(tmp2.CESSAmt + AddCessAmt  as Decimal(18,6)) as nvarchar),0) --"CessAmount"	
	From #TempBillAbstract  BA(Nolock) JOIN BillDetail bldt(Nolock) On(	BA.BillID = bldt.BillID )	
	LEFT OUTER JOIN  #TempTaxDet tmp2(Nolock) On( tmp2.BillID = bldt.BillID And tmp2.Product_Code =bldt.Product_Code 
    and tmp2.Tax_Code = bldt.TaxCode and tmp2.SerialNo = bldt.Serial)	
          
    Insert Into #TempHSNWise
	([HSN],[Description],[UQC],[TotalQuantity],[TotalValue],
	[TaxableValue],[IGSTAmount],[CGSTAmount],[SGSTAmount],[CessAmount])
	Select Isnull(ARD.HSNNumber,''),--HSN
	'',-- description
	'', -- uqc	 
    (ISNULL(ARD.Quantity,0) *-1), --total quantity
    (((ARD.Rate  * ARD .Quantity ) + ARD.TaxAmount) *-1 ),--total value
    (((ARD.Rate  * ARD .Quantity )) * -1) ,--TaxableValue
	((tmp2.IGSTAmt)*-1 ),--"IGSTAmount"
	((tmp2.CGSTAmt)*-1 ),--"CGSTAmount"
	Case When @UTGSTFlag = 1 Then (tmp2.UTGSTAmt)*-1 Else (tmp2.SGSTAmt)*-1 End,
	((tmp2.CESSAmt + AddCessAmt)*-1 ) --"CessAmount"	
	From  AdjustmentReturnAbstract AR(Nolock) JOIN AdjustmentReturnDetail ARD(Nolock) On(AR.AdjustmentID  = ARD.AdjustmentID )
	LEFT OUTER JOIN  #TempPRTaxDet tmp2(Nolock) On( tmp2.AdjustmentID  = ARD.AdjustmentID And tmp2.Product_Code =ARD.Product_Code 
    and tmp2.Tax_Code = ARD.Tax_Code and tmp2.SerialNo = ARD.SerialNo)		
	where IsNull(AR.Status,0) & 128 = 0
	AND dbo.StripTimeFromDate(AdjustmentDate ) >= dbo.StripTimeFromDate(@FROMDATE) 
    AND dbo.StripTimeFromDate(AdjustmentDate) <= dbo.StripTimeFromDate(@TODATE )
    	
  	Insert into #TempHSNWiseSum ([HSN],[Description],[UQC],[TotalQuantity],[TotalValue],
	[TaxableValue],[IGSTAmount],[CGSTAmount],[SGSTAmount],[CessAmount])
	Select [HSN],[Description],[UQC],Sum([TotalQuantity]),Sum([TotalValue]),
	Sum([TaxableValue]),Sum([IGSTAmount]),Sum([CGSTAmount]),Sum([SGSTAmount]),Sum([CessAmount])
	From #TempHSNWise(Nolock) Group By [HSN],[Description],[UQC]
	
	Select 0,[Sl.No]=[S.No],[HSN],[Description],[UQC],"Total Quantity"=[TotalQuantity],"Total Value"=[TotalValue],
	"Taxable Value"=[TaxableValue],"IGST Amount"=[IGSTAmount],"CGST Amount"=[CGSTAmount],"SGST Amount"=[SGSTAmount],"Cess Amount"=[CessAmount]
	From #TempHSNWiseSum

IF OBJECT_ID('tempdb..#TempBillAbstract') IS NOT NULL
	Drop Table #TempBillAbstract

IF OBJECT_ID('tempdb..#TempTaxDet') IS NOT NULL
	Drop Table #TempTaxDet

IF OBJECT_ID('tempdb..#TempPRTaxDet') IS NOT NULL
	Drop Table #TempPRTaxDet

IF OBJECT_ID('tempdb..#TempHSNWiseSum') IS NOT NULL
	Drop Table #TempHSNWiseSum

IF OBJECT_ID('tempdb..#TempHSNWise') IS NOT NULL
	Drop Table #TempHSNWise
	
End
