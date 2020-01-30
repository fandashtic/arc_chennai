CREATE procedure [dbo].[spr_list_Invoicewise_Collection_Detail_ARU_Chevron] (@InvoiceID int)    
As


Declare @CASH As NVarchar(50)
Declare @CHEQUE As NVarchar(50)
Declare @DD As NVarchar(50)
Declare @CREDITCARD As NVarchar(50)
Declare @COUPON As NVarchar(50)
Declare @CREDITNOTE As NVarchar(50)
Declare @GIFTVOUCHER As NVarchar(50)

Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)
Set @CREDITCARD = dbo.LookupDictionaryItem(N'Credit Card', Default)
Set @COUPON = dbo.LookupDictionaryItem(N'Coupon', Default)
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)
Set @GIFTVOUCHER = dbo.LookupDictionaryItem(N'Gift Voucher', Default)

Select Collections.DocumentID, "Collection ID" = Collections.FullDocID, "Document Ref" =   
DocReference, "Date" = Collections.DocumentDate, "Salesman" = Salesman.Salesman_Name,    
"Value" = CollectionDetail.AdjustedAmount, "Payment Mode" = Case PaymentMode   
   When 0 Then @CASH    
   When 1 Then @CHEQUE    
   When 2 Then @DD    
   When 3 Then @CREDITCARD    
   When 5 Then @COUPON     
   When 6 Then @CREDITNOTE
   When 7 Then @GIFTVOUCHER
   End    
From Collections, CollectionDetail, Salesman    
Where Collections.DocumentID = CollectionDetail.CollectionID And    
Collections.SalesmanID *= Salesman.SalesmanID And   
IsNull(Collections.Status, 0) & 128 = 0 And    
CollectionDetail.DocumentID = @InvoiceID And    
CollectionDetail.DocumentType In (1, 2, 4, 6, 7) And     
Collections.CustomerID Is Not Null
