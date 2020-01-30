CREATE Procedure spr_Sales_Register_RP_Electronics_Details (@Inv Int)  
As
Declare @CASH nVarchar(50)  
Declare @CHEQUE nVarchar(50)  
Declare @DD nVarchar(50)  
Declare @CREDITCARD nVarchar(50)  
Declare @BANKTRANSFER nVarchar(50)  
Declare @COUPON nVarchar(50)  
Declare @CREDITNOTE nVarchar(50)  
Declare @GIFTVOUCHER nVarchar(50)  
SET @CASH = dbo.LookupDictionaryItem(N'Cash',default)
SET @CHEQUE = dbo.LookupDictionaryItem(N'Cheque',default)
SET @DD = dbo.LookupDictionaryItem(N'DD',default)
SET @CREDITCARD = dbo.LookupDictionaryItem(N'Credit Card',default)
SET @BANKTRANSFER = dbo.LookupDictionaryItem(N'Bank Transfer',default)
SET @COUPON = dbo.LookupDictionaryItem(N'Coupon',default)
SET @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note',default)
SET @GIFTVOUCHER = dbo.LookupDictionaryItem(N'Gift Voucher',default)

Select c.DocumentID, "Collection ID" = c.FullDocID, "Doc Ref" = c.DocReference,   
  "Date" = c.DocumentDate, "Amount" = Sum(cl.AdjustedAmount),  
  "Payment Mode" = Case c.PaymentMode When 0 Then @CASH   
                     When 1 Then @CHEQUE  
                     When 2 Then @DD
                     When 3 Then @CREDITCARD  
                     When 4 Then @BANKTRANSFER  
                     When 5 Then @COUPON    
                     When 6 Then @CREDITNOTE
                     When 7 Then @GIFTVOUCHER End,    
  "Details(Chq No/DD No)" = c.ChequeNumber From Collections c,   
  CollectionDetail cl Where c.DocumentID = cl.CollectionID And cl.DocumentID = @Inv  
  And IsNull(c.Status, 0) & 192 = 0
  Group By c.DocumentID, c.FullDocID, c.DocReference, c.DocumentDate,   
  c.PaymentMode, c.ChequeNumber  

