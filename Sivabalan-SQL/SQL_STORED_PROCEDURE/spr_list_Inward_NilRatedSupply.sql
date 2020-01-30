CREATE PROCEDURE spr_list_Inward_NilRatedSupply
(
@FROMDATE datetime,
@TODATE datetime
)
AS
BEGIN
set dateformat DMY

Create Table #TempNilRatedSupply
(
[Description]		Nvarchar(100),
[NilRatedSupplies]	Nvarchar(100),
[Exempted]			Decimal(18,6),
[NON-GSTSupplies]	Nvarchar(100)
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

Declare @fromstatecode int
Declare @Tostatecode int
Declare @prefix Nvarchar(100)
Declare @prefix2 Nvarchar(100)
Declare @temp nvarchar(100)
Declare @temp2 nvarchar(100)
Declare @re int
Set @prefix = 'Inter-State Supplies'
Set @prefix2 = 'Intra-State Supplies'

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

	Insert Into #TempNilRatedSupply
	([Description],[NilRatedSupplies],[Exempted],[NON-GSTSupplies])
	Select @prefix,'',0,''
	union 
	Select @prefix2,'',0,''
	
	Insert Into #TempNilRatedSupply
	([Description],[NilRatedSupplies],[Exempted],[NON-GSTSupplies])
	Select case When BA.FromStatecode = BA.ToStatecode Then @prefix2 else @prefix End , --Description, 
	'', -- NilRatedSupplies
	Sum(Isnull(bldt.Amount ,0)), -- Exempted
    ''--NoNGSTSupplies	
	From #TempBillAbstract  BA(Nolock)
	JOIN BillDetail bldt(Nolock)
	On(	BA.BillID = bldt.BillID )	
	where bldt.TaxAmount=0 and TaxCode > 0
	Group by BA.FromStatecode,BA.ToStatecode
	
	--Purchase Return
	Insert Into #TempNilRatedSupply
	([Description],[NilRatedSupplies],[Exempted],[NON-GSTSupplies])
	Select case When AR.FromStatecode = (select FromStateCode from BillAbstract BA where BA.billid=ARD.BillOrgID)Then @prefix2 else @prefix End , --Description, 
	'', -- NilRatedSupplies
	((Sum(ARD.Rate  * ARD .Quantity )) * -1) , -- Exempted
    ''--NoNGSTSupplies	
	From AdjustmentReturnAbstract AR(Nolock) JOIN AdjustmentReturnDetail ARD(Nolock)
	On(	AR.AdjustmentID  = ARD.AdjustmentID )	
	where IsNull(AR.Status,0) & 128 = 0
	AND dbo.StripTimeFromDate(AdjustmentDate ) >= dbo.StripTimeFromDate(@FROMDATE) 
    AND dbo.StripTimeFromDate(AdjustmentDate) <= dbo.StripTimeFromDate(@TODATE )
	And ARD.TaxAmount = 0 and Isnull(ARD.Tax_Code,0) > 0
	Group by AR.FromStatecode,ARD.BillOrgID

	Select 0,[Description],"Nil Rated Supplies"=[NilRatedSupplies],Exempted=sum([Exempted]),"NON-GST Supplies"=[NON-GSTSupplies]
	From #TempNilRatedSupply(Nolock)
	Group by [Description],[NilRatedSupplies],[NON-GSTSupplies]


IF OBJECT_ID('tempdb..#TempBillAbstract') IS NOT NULL
	Drop Table #TempBillAbstract

IF OBJECT_ID('tempdb..#TempTaxDet') IS NOT NULL
	Drop Table #TempTaxDet

IF OBJECT_ID('tempdb..#TempTaxableValue') IS NOT NULL
	Drop Table #TempTaxableValue

IF OBJECT_ID('tempdb..#TempNilRatedSupply') IS NOT NULL
	Drop Table #TempNilRatedSupply
	
End
