CREATE procedure [dbo].[spr_list_invoices_by_salesman](@SALESMANID INT,  
        @FROMDATE datetime,   
        @TODATE datetime)  
AS  
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
Declare @OTHERS As NVarchar(50)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)

SELECT  InvoiceID, "InvoiceID" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),   
 "Doc Reference"=DocReference,  
 "Beat" = IsNull(Beat.Description, @OTHERS), "Date" = InvoiceDate,  
 "Customer ID"=invoiceabstract.CustomerID, 
 "Customer" = Customer.Company_Name,   
 "Trade Discount"=DiscountPercentage,
 "Additional Discount"=AdditionalDiscount,
 "Net Value" = NetValue - IsNull(Freight, 0),  
 "Balance" = Balance,
 "Adj Ref" = Cast(dbo.GetAdjustments(Cast(InvoiceAbstract.PaymentDetails As Int), InvoiceAbstract.InvoiceID) as nvarchar)
FROM InvoiceAbstract, Customer, Beat, VoucherPrefix  
WHERE   InvoiceType in (1, 3) AND  
 (InvoiceAbstract.Status & 128) = 0 AND  
 InvoiceAbstract.CustomerID = Customer.CustomerID AND  
 InvoiceAbstract.BeatID *= Beat.BeatID AND  
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
 InvoiceAbstract.SalesmanID = @SALESMANID AND  
 VoucherPrefix.TranID = 'INVOICE'
