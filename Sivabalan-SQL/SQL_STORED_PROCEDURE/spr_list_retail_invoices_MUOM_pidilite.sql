CREATE procedure [dbo].[spr_list_retail_invoices_MUOM_pidilite](@FROMDATE datetime,    
       @TODATE datetime, @UOMDesc nVarchar(30))    
AS    
  
Create Table #TmpDocDetails(InvoiceID int null,DocumentID Int) 

Declare @InvID int  
Declare @DocID nvarchar(250)  
Declare @Delimeter char(1)  
  
Set @Delimeter = Char(44)      
  
Declare DocumentDetails Cursor For  
 select InvoiceID from InvoiceAbstract Where CHARINDEX(',',PaymentDetails) > 0   
  
Open DocumentDetails  
Fetch Next from DocumentDetails INTO @InvID  
  
If Not @@FETCH_STATUS <> 0   
Begin  
 While @@FETCH_STATUS = 0  
  Begin  
   Set @DocID = (Select PaymentDetails from InvoiceAbstract   
           where InvoiceAbstract.InvoiceID = @InvID)    
    Insert Into #TmpDocDetails   
   Select @InvID,Cast(ItemValue as Int) from dbo.sp_SplitIn2Rows(@DocID,',')  
      Fetch Next from DocumentDetails Into @InvID  
    End  
End   
  
Close DocumentDetails  
Deallocate DocumentDetails  
  
SELECT  InvoiceAbstract.InvoiceID,   
 "InvoiceID" = VoucherPrefix.Prefix + CAST(InvoiceAbstract.DocumentID AS NVARCHAR),   
 "Date" = InvoiceDate, 
  "Doc Reference" = DocReference,  
 "Customer" = Customer.Company_Name,  
 "Referred By" = Doctor.Name,  
 "Gross Value" = GrossValue, "Discount" = DiscountValue,   
 "Net Value" = NetValue, "Status" = case Status & 128  
 WHEN 0 THEN N''  
 ELSE N'Amended'  
 END,  
 "Invoice Reference" = NewInvoiceReference,  
 "Memo" = InvoiceAbstract.ShippingAddress, --Memo field for Retail Invoices  
 "Branch" = ClientInformation.Description,  

"Payment Mode" = Case PaymentMode When N'0' Then N'Credit' Else N'Others' End, 
"Payment Details" = Case When PaymentDetails = N'' Then N'' Else N'CL' + PaymentDetails  End,
"Amount Received" =   
Case When ( SubString(paymentdetails,1,1) not like N'%[0-9]' )  then   
dbo.GetAmountReceived(Case When IsNull(PaymentDetails,N'') = N'' Then N'Cash:' + cast(NetValue as nvarchar) + N'::0' Else PaymentDetails End)  
Else   
IsNull((Select sum(Value) From Collections Where Collections.DocumentID in (select #tmpDocDetails.documentID from #tmpDocDetails Where 
							#tmpDocDetails.InvoiceID = InvoiceAbstract.InvoiceID)), 0) End ,  

--  "Payment Mode" = Case When IsNull(PaymentDetails,'') = '' Then 'Cash' Else case Patindex('%;%',PaymentDetails)  
--   when '0' then left(PaymentDetails,Patindex('%:%',PaymentDetails)-1) else 'Multiple' end end,  
--  "Payment Details" = Case When IsNull(PaymentDetails,'') = '' Then 'Cash:' + cast(NetValue as nvarchar) + '::0' Else PaymentDetails End,  
--  "Amount Received" = dbo.GetAmountReceived(Case When IsNull(PaymentDetails,'') = '' Then 'Cash:' + cast(NetValue as nvarchar) + '::0' Else PaymentDetails End),  
 "SalesStaff" = Salesman.Salesman_Name
--SalesStaff.Staff_Name  
FROM InvoiceAbstract, Customer, VoucherPrefix, ClientInformation, Doctor, Salesman
--SalesStaff    
WHERE   InvoiceType = 2 AND InvoiceDate BETWEEN @FROMDATE AND @TODATE AND    
 (InvoiceAbstract.Status & 128) = 0 And    
 InvoiceAbstract.CustomerID *= Customer.CustomerID AND    
 VoucherPrefix.TranID = N'RETAIL INVOICE' AND     
 InvoiceAbstract.ClientID *= ClientInformation.ClientID AND    
 InvoiceAbstract.ReferredBy *= Doctor.ID AND    
 InvoiceAbstract.SalesmanID *= Salesman.SalesmanID
--SalesStaff.Staff_ID    

Drop Table #TmpDocDetails
