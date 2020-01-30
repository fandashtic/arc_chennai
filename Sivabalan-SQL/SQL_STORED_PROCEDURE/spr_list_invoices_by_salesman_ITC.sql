CREATE PROCEDURE spr_list_invoices_by_salesman_ITC
(
	@SALESMANID INT,
	@BEAT_NAME nVarchar(2550),
	@Payment_Mode nVarchar(50),
	@DSType nVarchar(4000) = '',  
	@FROMDATE datetime,
	@TODATE datetime
)
AS
Begin
	DECLARE @InvID int
	DECLARE @InvoiceID nvarchar(50)
	DECLARE @DocReference nvarchar(50)
	DECLARE @Beat nvarchar(50)
	DECLARE @Date datetime
	DECLARE @CustomerID nvarchar(50)
	DECLARE @Customer nvarchar(128)
	DECLARE @TradeDis Decimal(18,6)
	DECLARE @Additional Decimal(18,6)
	DECLARE @NetValue Decimal(18,6)
	DECLARE @Balance Decimal(18,6)
	DECLARE @AdjRef nvarchar(255)
	Declare @Credit As NVarchar(50), @Cash As NVarchar(50), @Cheque As NVarchar(50)
	Declare @DD As NVarchar(50), @OTHERS As NVarchar(50), @Delimeter As Char(1)
	Set @Credit = dbo.LookupDictionaryItem(N'Credit', Default)
	Set @Cash = dbo.LookupDictionaryItem(N'Cash', Default)
	Set @Cheque = dbo.LookupDictionaryItem(N'Cheque', Default)
	Set @DD = dbo.LookupDictionaryItem(N'DD', Default)
	Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
	Set @Delimeter=Char(15)

	Create Table #tmpBeat(BeatID int)
	Create Table #tmpPayMode(PayMode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpPayMode2(PayMode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, pid int)
	
	Insert Into #tmpPayMode2 Values (N'Credit', 0)
	Insert Into #tmpPayMode2 Values (N'Cash', 1)
	Insert Into #tmpPayMode2 Values (N'Cheque', 2)
	Insert Into #tmpPayMode2 Values (N'DD', 3)

	If @BEAT_NAME='%'
	Begin
		Insert into #tmpBeat Select BeatID From Beat
		Insert into #tmpBeat Select 0
	End
	Else
		Insert into #tmpBeat Select BeatID From Beat Where Description in (select * from dbo.sp_SplitIn2Rows(@BEAT_NAME,@Delimeter))
	
	If @Payment_Mode = '%'
	   Insert into #tmpPaymode Select [values] From QueryParams where QueryParamID In (11, 26) And [Values] Not In ('Bank Transfer')
	else
	   Insert into #tmpPaymode Select * From dbo.sp_SplitIn2Rows(@Payment_Mode, @Delimeter)
	
	SELECT  inva.InvoiceID, "InvoiceID" =  case Isnull(inva.GSTFlag,0) when 0 then VoucherPrefix.Prefix + CAST(inva.DocumentID AS nvarchar) else ISNULL(inva.GSTFullDocID,'') end,
	"Doc Reference"=inva.DocReference,
	"Beat" = IsNull(Beat.Description, @OTHERS),
	"Date" = InvoiceDate,
	"Customer ID"=inva.CustomerID,
	"Customer" = Customer.Company_Name,
	"Payment Mode" = (Case IsNull(PaymentMode,0) When 0 Then @Credit When 1 Then @Cash When 2 Then @Cheque When 3 Then @DD Else @OTHERS End),
	"GoodsValue" = IsNull(Sum(Saleprice * Quantity),0),
	"Product Discount" = IsNull(ProductDiscount,0),
	"Trade Discount"=inva.DiscountValue,
	"Additional Discount"=inva.AddlDiscountValue,
	"Tax Amount (%c)" = IsNull(TotalTaxApplicable, 0),
	"Net Value" = NetValue - IsNull(Freight, 0),
	"Balance" = inva.Balance,
	"Adj Ref" = IsNull(Cast(dbo.GetAdjustments_ITC(Cast(inva.PaymentDetails As Int), inva.InvoiceID) as nvarchar(4000)),N''),
	"F11 Adj. Value" = IsNull(AdjustmentValue,0),
	"Credit Note Adj Value" = (Select IsNull(Sum(AdjustedAmount),0) From CollectionDetail Where CollectionID = inva.PaymentDetails And DocumentType = 2) - IsNull(Sum(ar.Amount),0)
	FROM InvoiceAbstract inva
	Inner Join  InvoiceDetail invd On inva.InvoiceID = invd.InvoiceID 
	Inner Join Customer On inva.CustomerID = Customer.CustomerID 
	Left Outer Join Beat On inva.BeatID = Beat.BeatID 
	Inner Join VoucherPrefix On VoucherPrefix.TranID = 'INVOICE'
	Left Outer Join AdjustmentReference ar On ar.InvoiceID = inva.InvoiceID And ar.DocumentType = 2
	WHERE (inva.Status & 128) = 0 AND 
	InvoiceType in (1, 3) AND
	inva.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND
	inva.SalesmanID = @SALESMANID AND
	inva.BeatID in (Select BeatID From #tmpBeat) And
	inva.PaymentMode in (Select pid From #tmpPayMode2 Where PayMode in (Select PayMode From #tmpPayMode)) 
	Group By inva.InvoiceID, VoucherPrefix.Prefix, inva.DocumentID, inva.DocReference, Beat.Description,
	InvoiceDate, inva.CustomerID, Customer.Company_Name, PaymentMode, ProductDiscount, inva.DiscountValue, inva.AddlDiscountValue,
	TotalTaxApplicable, NetValue, Freight, inva.Balance, AdjustmentValue, inva.PaymentDetails,inva.GSTFlag,inva.GSTFullDocID
	
	Drop Table #tmpBeat
	Drop Table #tmpPayMode
	Drop Table #tmpPayMode2
End
