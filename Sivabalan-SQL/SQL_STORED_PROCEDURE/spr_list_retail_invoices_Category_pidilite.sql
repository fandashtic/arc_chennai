CREATE procedure [dbo].[spr_list_retail_invoices_Category_pidilite] (@FROMDATE datetime,    
          @TODATE datetime,    
          @CATEGORY nvarchar(2550))    
AS    
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
  
create table #tmpCat(Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @CATEGORY=N'%'  
   insert into #tmpCat select Category_Name from ItemCategories  
else  
   insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@CATEGORY ,@Delimeter)  
  
SELECT  InvoiceAbstract.InvoiceID,     
 "InvoiceID" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),     
 "Date" = InvoiceDate, 
 "Doc Reference" = InvoiceAbstract.DocReference,
 "Customer" = Customer.Company_Name,    
 "Referred By" = Doctor.Name,    
 "Discount" = InvoiceAbstract.DiscountValue,     
 "Net Value" = Sum(InvoiceDetail.Amount),    
  "Status" = Case     
         WHEN Status & 192 = 192 Then      
         N'Cancelled'      
         WHEN Status & 192 = 128 Then      
         N'Amended'      
  WHEN Status = 0 then case WHEN NewInvoiceReference  <> N'' then N'Amendment' else N'' end          
         ELSE      
         N''      
         END,    
        "Invoice Reference" = NewInvoiceReference,    
 "Memo" = InvoiceAbstract.BillingAddress,    
 "Branch" = ClientInformation.Description,    

"Payment Mode" = dbo.fn_get_RetailPaymentModeDescription(InvoiceAbstract.InvoiceID),
"Cash" =(select sum(isnull(NetRecieved,0)) from RetailPaymentDetails,PaymentMode where
PaymentMode.mode = RetailPaymentDetails.Paymentmode and
PaymentMode.PaymentType = 1 and retailInvoiceID=InvoiceAbstract.InvoiceID),
"Cheque" =(select sum(isnull(NetRecieved,0)) from RetailPaymentDetails,PaymentMode where
PaymentMode.mode = RetailPaymentDetails.Paymentmode and
PaymentMode.PaymentType = 2 and retailInvoiceID=InvoiceAbstract.InvoiceID),
"CreditCard" =(select sum(isnull(NetRecieved,0)) from RetailPaymentDetails,PaymentMode where
PaymentMode.mode = RetailPaymentDetails.Paymentmode and
PaymentMode.PaymentType = 3 and retailInvoiceID=InvoiceAbstract.InvoiceID),
"Coupon" =(select sum(isnull(NetRecieved,0)) from RetailPaymentDetails,PaymentMode where
PaymentMode.mode = RetailPaymentDetails.Paymentmode and
PaymentMode.PaymentType = 4 and retailInvoiceID=InvoiceAbstract.InvoiceID),
"CreditNote" =(select sum(isnull(NetRecieved,0)) from RetailPaymentDetails,PaymentMode where
PaymentMode.mode = RetailPaymentDetails.Paymentmode and
PaymentMode.PaymentType = 6 and retailInvoiceID=InvoiceAbstract.InvoiceID),
"GiftVoucher" =(select sum(isnull(NetRecieved,0)) from RetailPaymentDetails,PaymentMode where
PaymentMode.mode = RetailPaymentDetails.Paymentmode and
PaymentMode.PaymentType = 7 and retailInvoiceID=InvoiceAbstract.InvoiceID),

"SalesStaff" = IsNull(Salesman.Salesman_Name, N'')
--IsNull(SalesStaff.Staff_Name, '')    
FROM InvoiceAbstract, Customer, VoucherPrefix, ClientInformation, 

 Doctor, InvoiceDetail, Items, ItemCategories, Salesman
--SalesStaff    
WHERE   InvoiceType = 2 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND    
 InvoiceAbstract.CustomerID *= Customer.CustomerID AND    
 VoucherPrefix.TranID = N'RETAIL INVOICE' AND     
 InvoiceAbstract.ClientID *= ClientInformation.ClientID AND
 InvoiceAbstract.ReferredBy *= Doctor.ID AND    
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 Items.CategoryID = ItemCategories.CategoryID AND    
 ItemCategories.Category_Name in(select Category_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCat) AND  
 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID  
GROUP BY InvoiceAbstract.InvoiceID, VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),    
  InvoiceDate, Customer.Company_Name,    
 Doctor.Name, InvoiceAbstract.DiscountValue, Status, NewInvoiceReference,     
 InvoiceAbstract.BillingAddress, ClientInformation.Description, PaymentMode, PaymentDetails,    
 Salesman.Salesman_Name, InvoiceAbstract.DocReference
-- SalesStaff.Staff_Name    

drop table #tmpCat
