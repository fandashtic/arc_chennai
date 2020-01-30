CREATE PROCEDURE spr_list_invoices_by_salesman_abstract2_ITC
(
	@SALESMAN_NAME nvarchar(2550),
	@BEAT_NAME nvarchar(2550),
	@PAYMENT_MODE nvarchar(50),
	@FROMDATE DATETIME,  
	@TODATE DATETIME
)  
AS  

Declare @Delimeter as Char(1), @Pay as nVarchar(50)    
Declare @Credit As NVarchar(50), @Cash As NVarchar(50), @Cheque As NVarchar(50)
Declare @DD As NVarchar(50), @OTHERS As NVarchar(50)
Set @Credit = dbo.LookupDictionaryItem(N'Credit', Default)
Set @Cash = dbo.LookupDictionaryItem(N'Cash', Default)
Set @Cheque = dbo.LookupDictionaryItem(N'Cheque', Default)
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
Set @Delimeter=Char(15)    

Create Table #tmpSalesMan(SalesmanID int)
Create Table #tmpBeat(BeatID int)
Create Table #tmpPayMode(PayMode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #tmpPayMode2(PayMode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, pid int)  
  
Insert Into #tmpPayMode2 Values (N'Credit', 0)  
Insert Into #tmpPayMode2 Values (N'Cash', 1)  
Insert Into #tmpPayMode2 Values (N'Cheque', 2)  
Insert Into #tmpPayMode2 Values (N'DD', 3)  

Create Table #tmpResult(SalesmanID int, Salesman nVarchar(100), GoodsValue Decimal(18,6), Discount Decimal(18,6),
TaxAmount Decimal(18,6), NetValue Decimal(18,6), PendingBills int, CashInvoices Decimal(18,6),
CreditInvoices Decimal(18,6), SalesReturnCash Decimal(18,6), SalesReturnCredit Decimal(18,6))

If @SALESMAN_NAME='%'     
Begin
	Insert into #tmpSalesMan Select SalesmanID From Salesman    
	Insert into #tmpSalesMan Select 0
End
Else    
	Insert into #tmpSalesMan Select SalesmanID From Salesman Where Salesman_Name in (select * from dbo.sp_SplitIn2Rows(@SALESMAN_NAME,@Delimeter))    

If @BEAT_NAME='%'     
Begin
	Insert into #tmpBeat Select BeatID From Beat    
	Insert into #tmpBeat Select 0
End
Else    
	Insert into #tmpBeat Select BeatID From Beat Where Description in (select * from dbo.sp_SplitIn2Rows(@BEAT_NAME,@Delimeter))    

If @Payment_Mode = '%'              
   Insert into #tmpPaymode select [values] from QueryParams where QueryParamID In (11, 26) And [Values] Not In ('Bank Transfer')  
else              
   Insert into #tmpPaymode select * from dbo.sp_SplitIn2Rows(@Payment_Mode, @Delimeter)              

Insert Into #tmpResult 
SELECT  isnull(inva.SalesmanID, 0 ), 
 (case isnull(inva.SalesmanID, 0 ) when 0 then @OTHERS else Salesman.Salesman_Name end),   
 Sum(SalePrice * Quantity - (SalePrice * Quantity * invd.DiscountPercentage / 100)),
 Sum(SalePrice * Quantity * (AdditionalDiscount+inva.DiscountPercentage) / 100),
 inva.TotalTaxApplicable, 
 Sum(Amount),
 dbo.GetPendingBillsForSalesman(IsNull(inva.SalesmanID, 0), @FROMDATE, @TODATE),
 Sum(Case When IsNull(PaymentMode,0) > 0 And IsNull(PaymentMode,0) < 4 Then Amount Else 0 End), 
 Sum(Case IsNull(PaymentMode,0) When 0 Then Amount Else 0 End), 
 (Case When isnull(Paymentmode,0) > 0 And IsNull(PaymentMode,0) < 4 Then (Select IsNull(Sum(AdjustedAmount),0) From CollectionDetail Where CollectionID = IsNull(inva.PaymentDetails,0) And DocumentType in (1)) Else 0 End),
 (Case When isnull(Paymentmode,0) = 0 Then (Select IsNull(Sum(AdjustedAmount),0) From CollectionDetail Where CollectionID = IsNull(inva.PaymentDetails,0) And DocumentType in (1)) Else 0 End) 
FROM InvoiceAbstract inva, Salesman, InvoiceDetail invd 
WHERE   InvoiceType in (1, 3) AND  
 (inva.Status & 128) = 0 AND  
 inva.SalesmanID = Salesman.SalesmanID AND  
 inva.InvoiceDate BETWEEN @FROMDATE AND @TODATE And
 inva.InvoiceID = invd.InvoiceID And
 inva.SalesmanID In (Select SalesmanID From #tmpSalesMan) And 
 inva.BeatID in (Select BeatID From #tmpBeat) And 
 inva.PaymentMode in (Select pid From #tmpPayMode2 Where PayMode in (Select PayMode From #tmpPayMode)) 
GROUP BY inva.SalesmanID, Salesman.Salesman_Name, inva.PaymentDetails, inva.PaymentMode, inva.TotalTaxApplicable  

Select SalesmanID, Salesman, "Goods Value (%c)" = Sum(GoodsValue), "Discount (%c)" = Sum(Discount), 
"Tax Amount (%c)" = Sum(TaxAmount), "Net Value (%c)" = Sum(NetValue), "Pending Bills" = PendingBills, 
"Cash Invoices (%c)" = Sum(CashInvoices), "Credit Invoices (%c)" = Sum(CreditInvoices), 
"Sales Return (Cash)" = Sum(SalesReturnCash), "Sales Return (Credit)" = Sum(SalesReturnCredit) 
From #tmpResult Group By SalesmanID, Salesman, PendingBills

Drop Table #tmpSalesMan
Drop Table #tmpBeat
Drop Table #tmpPayMode
Drop Table #tmpPayMode2
Drop Table #tmpResult
