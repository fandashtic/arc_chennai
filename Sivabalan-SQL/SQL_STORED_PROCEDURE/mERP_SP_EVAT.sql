create Procedure mERP_SP_EVAT(@FromDate datetime,@ToDate datetime,@OutputType nVarchar(50),@Format nvarchar(100))
As
Begin
    --@Format paramter always Kerala EVAT , For future use only we added as a paramter	
   If @OutputType=N'Purchase' or @OutputType=N''
   Begin
       select 
       "Invoice No" = case when Invoicereference='' then cast(DocumentID as Nvarchar) else Invoicereference end,
       "Invoice Date" = case (Select IsNull(RecdInvoiceID,'') From GRNAbstract Where GRNID = BA.GRNID) when '' then BillDate else (select InvoiceDate From InvoiceAbstractReceived Where DocumentID = BA.Invoicereference) end,
       "Seller Registration No" = V.Tin_Number,
	   "Seller Dealer Name" = V.Vendor_name,
       "Seller Dealer Address" =IsNull(REPLACE(REPLACE(REPLACE(Replace(Replace(Replace(Replace(Replace(Replace(V.Address,char(44),''),char(34),''),Char(39),''),char(62),''),char(60),''),char(38),''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),''),
       "Value of Goods" = (Select Sum(Amount) From BillDetail
	   Where BillDetail.BillID = BA.BillID),
       "Vat Amount Paid" = BA.TaxAmount,
       "Total Invoice Amount" = BA.Value + BA.TaxAmount + AdjustmentAmount   
       from BillAbstract BA,Vendors V
       where isnull(BA.Status,0) & 192 = 0 
       and BA.BillDate BETWEEN @FromDate AND @ToDate
       and V.VendorID=BA.VendorID
   End
   Else If @OutputType=N'Sales'
   Begin
       Select "Invoice No" = CAST(DocReference as nVarchar(50)),
	   "Invoice Date" = InvoiceDate,
	   "Buyer Registration No" = C.Tin_Number,
	   "Buyer Dealer Name" = C.Company_Name,
       "Buyer Dealer Address" = IsNull(REPLACE(REPLACE(REPLACE(Replace(Replace(Replace(Replace(Replace(Replace(C.BillingAddress,char(44),''),char(34),''),Char(39),''),char(62),''),char(60),''),char(38),''), CHAR(10), ''), CHAR(13), ''), CHAR(9), ''),''),
       "Value of Goods" = GoodsValue,
       "Vat Amount Paid" = TotalTaxApplicable,
       "Total Invoice Amount" = Netvalue
       FROM InvoiceAbstract, Customer C
       WHERE  InvoiceType in (1,3) AND InvoiceDate BETWEEN @FROMDATE AND @TODATE 
       and InvoiceAbstract.CustomerID = C.CustomerID    
       and isnull(InvoiceAbstract.Status,0) & 192 = 0
   End  
End
