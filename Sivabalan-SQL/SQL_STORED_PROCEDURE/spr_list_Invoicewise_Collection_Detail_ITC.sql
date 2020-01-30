
Create Procedure spr_list_Invoicewise_Collection_Detail_ITC (@InvoiceID int)      
As  
Begin
	Declare @CASH As NVarchar(50)  
	Declare @CHEQUE As NVarchar(50)  
	Declare @DD As NVarchar(50)  
	Declare @CREDITCARD As NVarchar(50)  
	Declare @BANKTRANSFER As NVarchar(50)
	Declare @COUPON As NVarchar(50)  
	Declare @CREDITNOTE As NVarchar(50)  
	Declare @GIFTVOUCHER As NVarchar(50)  
	Declare @OTHERS As NVarchar(50)  
	Declare @CREDITADJ AS nVarchar(50)
	  
	Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)  
	Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)  
	Set @DD = dbo.LookupDictionaryItem(N'DD', Default)  
	Set @CREDITCARD = dbo.LookupDictionaryItem(N'Credit Card', Default)  
	Set @BANKTRANSFER = dbo.LookupDictionaryItem(N'Bank Transfer', Default)  
	Set @COUPON = dbo.LookupDictionaryItem(N'Coupon', Default)  
	Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)  
	Set @GIFTVOUCHER = dbo.LookupDictionaryItem(N'Gift Voucher', Default)  
	Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)  
	set @CREDITADJ = dbo.LookupDictionaryItem(N'Credit Adjustment',Default)	  

	Select Collections.DocumentID, "Collection ID" = Collections.FullDocID, 
	"Document Ref" = DocReference, "Date" = Collections.DocumentDate,
	"Salesman" = Case IsNull(Salesman.Salesman_Name, N'') When N'' Then @OTHERS 
	Else IsNull(Salesman.Salesman_Name, N'') End,
	"Value" = IsNull(CollectionDetail.CollectedAmount,0),
	"Payment Mode" = Case PaymentMode     
		When 0 Then @CASH      
		When 1 Then @CHEQUE      
		When 2 Then @DD      
		When 3 Then @CREDITCARD      
		When 4 Then @BANKTRANSFER
		When 5 Then @COUPON       
		When 6 Then @CREDITNOTE  
		When 7 Then @GIFTVOUCHER  
	End,
	"Adjustment Value" = IsNull(CollectionDetail.DocAdjustAmount,0),
	"Adjustment Mode" = @CREDITADJ 
	From Collections
	Inner Join CollectionDetail On Collections.DocumentID = CollectionDetail.CollectionID
	Left Outer Join Salesman   On Collections.SalesmanID = Salesman.SalesmanID         
	Where 
	CollectionDetail.DocumentID = @InvoiceID And 
	IsNull(Collections.Status, 0) & 128 = 0 And      
	CollectionDetail.DocumentType = 4 And            
	Collections.CustomerID Is Not Null  
End
