CREATE Procedure spr_list_CFormDForm_Exception  
As  
Declare @YES As NVarchar(50)  
Declare @NO As NVarchar(50)  
Set @YES = dbo.LookupDictionaryItem(N'Yes',Default)  
Set @NO = dbo.LookupDictionaryItem(N'No',Default)  
  
Select InvoiceID, "Invoice ID" = case Isnull(GSTFlag,0)when 0 then VoucherPrefix.Prefix + Cast(DocumentID As nvarchar) else ISNULL(GSTFullDocID,'')end,  
"Invoice Date" = InvoiceDate, "CustomerID" = Customer.CustomerID,   
"Customer" = Customer.Company_Name, "Net Value (%c)" = NetValue,   
"Balance (%c)" = Balance, "CForm" = Case When ((Flags & 4) <> 0) Then @YES Else @NO End,  
"CForm No" = Isnull(CFormNo,N''),  
"DForm" = Case When ((Flags & 8) <> 0) Then @YES Else @NO End,  
"DFormNo" = Isnull(DFormNo, N'')  
From InvoiceAbstract, Customer, VoucherPrefix  
Where InvoiceAbstract.CustomerID = Customer.CustomerID   
And InvoiceAbstract.InvoiceType in (1, 3, 4)  
And (InvoiceAbstract.Status & 128) = 0  
And (InvoiceAbstract.Flags & 128) = 0  
And (InvoiceAbstract.Flags & 12) <> 0  
And VoucherPrefix.TranID = N'INVOICE'  
