CREATE Procedure [dbo].[spr_list_Invoice_Summary_Report_Detail] (@Temp Integer, @From_Date DateTime, @To_Date DateTime)    
As 
Begin
	   
	Declare @SALESRETURNSALEABLE As NVarchar(50)
	Declare @SALESRETURNDAMAGES As NVarchar(50)
	Declare @RETAILINVOICE As NVarchar(50)
	Declare @RETAILSALESRETURNSALEABLE As NVarchar(50)
	Declare @RETAILSALESRETURNDAMAGES As NVarchar(50)
	Declare @INVOICE As NVarchar(50)
	Declare @CREDIT As NVarchar(50)
	Declare @OTHERS As NVarchar(50)
	Declare @CASH As NVarchar(50)
	Declare @CHEQUE As NVarchar(50)
	Declare @DD As NVarchar(50)
	Declare @CREDITCARD As NVarchar(50)
	Declare @COUPON As NVarchar(50)

	Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Sales Return Saleable',Default)
	Set @SALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'Sales Return Damages',Default)
	Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice',Default)
	Set @RETAILSALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'RetailSales Return Saleable',Default)
	Set @RETAILSALESRETURNDAMAGES = dbo.LookupDictionaryItem(N'RetailSales Return Damages',Default)
	set @INVOICE = dbo.LookupDictionaryItem(N'Invoice',Default)
	set @CREDIT = dbo.LookupDictionaryItem(N'Credit',Default)
	set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)
	Set @CASH = dbo.LookupDictionaryItem(N'Cash',Default)
	Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque',Default)
	Set @DD = dbo.LookupDictionaryItem(N'DD',Default)
	Set @CREDITCARD = dbo.LookupDictionaryItem(N'Credit Card',Default)
	Set @COUPON = dbo.LookupDictionaryItem(N'Coupon',Default)

	DECLARE @INV AS NVARCHAR(50)
	SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'
	    
	If @Temp = N'1'     
	Begin    
	Select    
	InvoiceAbstract.InvoiceID,   
	"Document ID" = Case ISNULL(InvoiceAbstract.GSTFlag,0) When 0 Then @INV + Cast(DocumentID as nVarchar) Else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,   
	"Document Reference" = DocReference,     
	 "Type" = case InvoiceType      
	 WHEN 4 THEN       
	 Case Status & 32      
	 When 0 Then      
	 @SALESRETURNSALEABLE      
	 Else      
	 @SALESRETURNDAMAGES      
	 End      
	 WHEN 2 THEN @RETAILINVOICE      
	 WHEN 5 THEN @RETAILSALESRETURNSALEABLE
	 WHEN 6 THEN @RETAILSALESRETURNDAMAGES
	 ELSE @INVOICE      
	 END,     
	"Invoice Date" = InvoiceDate,  
	"Amount" = 
	Case InvoiceType	
	When 4 Then
	0 - Sum(Isnull(InvoiceDetail.Amount,0))
	When 5 then
	0 - Sum(Isnull(InvoiceDetail.Amount,0))
	when 6 then
	0 - Sum(Isnull(InvoiceDetail.Amount,0))
	Else
	Sum(Isnull(InvoiceDetail.Amount,0))   
	End,
	"Customer ID" =  Isnull(InvoiceAbstract.CustomerID,N''),
	"Customer Name" = Isnull(Customer.Company_Name,N''),
	"Forum Code" = Isnull(Customer.AlternateCode,N''),   
	"Payment Mode" = 
	Case 
	When Isnull(InvoiceType,0) = 2 Then  
		case IsNull(PaymentMode,0)
		When 0 Then @CREDIT
		When 1 Then @OTHERS
		End
	--     Case When IsNull(PaymentDetails,'') = '' Then 'Cash' Else case Patindex('%;%',PaymentDetails)
	--     when '0' then left(PaymentDetails,Patindex('%:%',PaymentDetails)-1) else dbo.GetPaymentModeDetails (PaymentDetails) end end
	When (Isnull(InvoiceType,0) = 1) OR (Isnull(InvoiceType,0) = 3) Then
		case IsNull(PaymentMode,0)
		When 0 Then @CREDIT
		When 1 Then @CASH
		When 2 Then @CHEQUE
		When 3 Then @DD
		when 4 Then @CREDITCARD
		when 5 Then @COUPON
		Else @CREDIT
		End
	When Isnull(InvoiceType,0) = 4 Then @CREDIT
	When Isnull(InvoiceType,0) = 5 Then @CREDIT
	When Isnull(InvoiceType,0) = 6 Then @CREDIT
	End,  
	"Payment Date" = PaymentDate,     
	"Credit Term" = CreditTerm.Description,    
	"Product Discount (%c.)" = (ProductDiscount),    
	"Trade Discount%" = CAST(Cast(InvoiceAbstract.DiscountPercentage as Decimal(18,6)) AS nvarchar) + N'%',     
	"Trade Discount(%c.)" = InvoiceAbstract.DiscountValue,
	"Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + N'%',    
	"Addl Discount(%c.)" = InvoiceAbstract.AddlDiscountValue, 
	"Freight" = (Freight),   
	"Net Value" = Isnull(NetValue,0),     
	"Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),    
	"Adjusted Amount" = (IsNull(InvoiceAbstract.AdjustedAmount, 0)),    
	"Balance" = Isnull(InvoiceAbstract.Balance,0),    
	"Collected Amount" = 
	Case InvoiceType  
	When 4 Then
	0
	when 5 then
	0
	when 6 then
	0
	Else
	(Isnull(NetValue,0) - IsNull(InvoiceAbstract.AdjustedAmount, 0) - IsNull(InvoiceAbstract.Balance, 0) + IsNull(RoundOffAmount, 0))
	End,    
	"Branch" = ClientInformation.Description,    
	"Beat" = Beat.Description,    
	"Salesman" = Salesman.Salesman_Name,
	"Rounded Net Value"  = NetValue + RoundOffAmount
	from InvoiceAbstract
	Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	Left Outer Join Customer On Customer.CustomerID = InvoiceAbstract.CustomerID 
	Left Outer Join CreditTerm On InvoiceAbstract.CreditTerm = CreditTerm.CreditID 
	Left Outer Join ClientInformation On InvoiceAbstract.ClientID = ClientInformation.ClientID    
	Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
	Left Outer Join Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID      
	--, Cash_Customer
	Where	 invoicedate between @From_Date and @To_Date    
	And InvoiceAbstract.Status & 128 = 0     
	and InvoiceAbstract.InvoiceType in (1,2,3,4,5,6)
	--Cast(Cash_Customer.CustomerID as nvarchar) =* InvoiceAbstract.CustomerID AND   
	Group By InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference, InvoiceAbstract.Status,
	InvoiceAbstract.InvoiceType, InvoiceAbstract.InvoiceDate, InvoiceAbstract.CustomerID,
	InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference, InvoiceAbstract.Status,
	InvoiceAbstract.InvoiceType, InvoiceAbstract.InvoiceDate, InvoiceAbstract.CustomerID,
	Customer.Company_Name, Customer.AlternateCode, InvoiceAbstract.PaymentDetails,
	InvoiceAbstract.PaymentMode, InvoiceAbstract.PaymentDate, CreditTerm.Description,
	InvoiceAbstract.DiscountPercentage, InvoiceAbstract.AdditionalDiscount, InvoiceAbstract.AdjRef,
	ClientInformation.Description, Beat.Description, Salesman.Salesman_Name, --Cash_Customer.CustomerName,
	InvoiceAbstract.ProductDiscount, InvoiceAbstract.Freight, InvoiceAbstract.NetValue, --Cash_Customer.CustomerID,
	InvoiceAbstract.AdjustedAmount, InvoiceAbstract.Balance, InvoiceAbstract.RoundOffAmount, InvoiceAbstract.GoodsValue,
	InvoiceAbstract.DiscountValue, InvoiceAbstract.AddlDiscountValue,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID
	End    
	Else If @Temp = N'2'    
	Begin    
	Select    
	InvoiceAbstract.InvoiceID,   
	"Document ID" = Case ISNULL(InvoiceAbstract.GSTFlag,0) When 0 Then @INV + Cast(DocumentID as nVarchar) Else ISNULL(InvoiceAbstract.GSTFullDocID,'') END, 
	--@INV + Cast(DocumentID as nVarchar),   
	"Document Reference" = DocReference,     
	 "Type" = case InvoiceType      
	 WHEN 4 THEN       
	 Case Status & 32      
	 When 0 Then      
	 @SALESRETURNSALEABLE
	 Else      
	 @SALESRETURNDAMAGES    
	 End      
	 WHEN 2 THEN @RETAILINVOICE         
	 WHEN 5 THEN @RETAILSALESRETURNSALEABLE
	 WHEN 6 THEN @RETAILSALESRETURNDAMAGES
	 ELSE @INVOICE
	 END,     
	"Invoice Date" = InvoiceDate,  
	"Amount" = 
	Case InvoiceType	
	When 4 Then
	0 - Sum(Isnull(InvoiceDetail.Amount,0))   
	When 5 Then
	0 - Sum(Isnull(InvoiceDetail.Amount,0))   
	When 6 Then
	0 - Sum(Isnull(InvoiceDetail.Amount,0))   
	Else
	Sum(Isnull(InvoiceDetail.Amount,0))   
	End,
	"Customer ID" =  Isnull(InvoiceAbstract.CustomerID,N''),
	"Customer Name" = Isnull(Customer.Company_Name,N''),   
	"Forum Code" = Isnull(Customer.AlternateCode,N''),  
	"Payment Mode" = 
	Case 
	When Isnull(InvoiceType,0) = 2 Then  
		case IsNull(PaymentMode,0)
		When 0 Then @CREDIT
		When 1 Then @OTHERS
		End
	-- 	Case When IsNull(PaymentDetails,'') = '' Then 'Cash' Else case Patindex('%;%',PaymentDetails)
	--         when '0' then left(PaymentDetails,Patindex('%:%',PaymentDetails)-1) else dbo.GetPaymentModeDetails (PaymentDetails) end end
	When (Isnull(InvoiceType,0) = 1) OR (Isnull(InvoiceType,0) = 3) Then
		case IsNull(PaymentMode,0)
		When 0 Then @CREDIT
		When 1 Then @CASH
		When 2 Then @CHEQUE
		When 3 Then @DD
		when 4 Then @CREDITCARD
		when 5 Then @COUPON
		Else @CREDIT
		End
	When Isnull(InvoiceType,0) = 4 Then @CREDIT
	When Isnull(InvoiceType,0) = 5 Then @CREDIT
	When Isnull(InvoiceType,0) = 6 Then @CREDIT
	End, 
	"Payment Date" = PaymentDate,     
	"Credit Term" = CreditTerm.Description,    
	"Product Discount (%c.)" = (ProductDiscount),    
	"Trade Discount%" = CAST(Cast(InvoiceAbstract.DiscountPercentage as Decimal(18,6)) AS nvarchar) + N'%',     
	"Trade Discount(%c.)" = InvoiceAbstract.DiscountValue,
	"Addl Discount" = CAST(AdditionalDiscount AS nvarchar) + N'%',    
	"Addl Discount(%c.)" = InvoiceAbstract.AddlDiscountValue, 
	"Freight" = (Freight),   
	"Net Value" = Isnull(NetValue,0),     
	"Adj Ref" = IsNull(InvoiceAbstract.AdjRef, N''),    
	"Adjusted Amount" = (IsNull(InvoiceAbstract.AdjustedAmount, 0)),    
	"Balance" = Isnull(InvoiceAbstract.Balance, 0),    
	"Collected Amount" = 0.00,
	"Branch" = ClientInformation.Description,    
	"Beat" = Beat.Description,    
	"Salesman" = Salesman.Salesman_Name,
	"Rounded Net Value"  = NetValue + RoundOffAmount
	from InvoiceAbstract
	Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
	Left Outer Join Customer On Customer.CustomerID = InvoiceAbstract.CustomerID 
	Left Outer Join CreditTerm On InvoiceAbstract.CreditTerm = CreditTerm.CreditID
	Left Outer Join ClientInformation On InvoiceAbstract.ClientID = ClientInformation.ClientID
	Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID 
	Left Outer Join Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID 
	--, Cash_Customer    
	Where (((CancelDate between @From_Date and @To_Date) and InvoiceAbstract.Status & 64 = 64)  or ((InvoiceDate between @From_Date and @To_Date) and InvoiceAbstract.Status & 128 = 128 And InvoiceAbstract.Status & 64 <> 64))       
	--and Canceldate between @From_Date and @To_Date   
	--(When cancel date is taken for date comparison amended invoices are getting filetered)
	and InvoiceAbstract.InvoiceType in (1,2,3,4,5,6) 
	--and (InvoiceAbstract.Status & 128) = 128
	--Cast(Cash_Customer.CustomerID as nvarchar) =* InvoiceAbstract.CustomerID AND    
	Group By InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference, InvoiceAbstract.Status,
	InvoiceAbstract.InvoiceType, InvoiceAbstract.InvoiceDate, InvoiceAbstract.CustomerID,
	InvoiceAbstract.DocumentID, InvoiceAbstract.DocReference, InvoiceAbstract.Status,
	InvoiceAbstract.InvoiceType, InvoiceAbstract.InvoiceDate, InvoiceAbstract.CustomerID,
	Customer.Company_Name, Customer.AlternateCode, InvoiceAbstract.PaymentDetails,
	InvoiceAbstract.PaymentMode, InvoiceAbstract.PaymentDate, CreditTerm.Description,
	InvoiceAbstract.DiscountPercentage, InvoiceAbstract.AdditionalDiscount, InvoiceAbstract.AdjRef,
	ClientInformation.Description, Beat.Description, Salesman.Salesman_Name, --Cash_Customer.CustomerName,
	InvoiceAbstract.ProductDiscount, InvoiceAbstract.Freight, InvoiceAbstract.NetValue, --Cash_Customer.CustomerID,
	InvoiceAbstract.AdjustedAmount, InvoiceAbstract.Balance, InvoiceAbstract.RoundOffAmount, InvoiceAbstract.GoodsValue,
	InvoiceAbstract.DiscountValue, InvoiceAbstract.AddlDiscountValue,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID
	End     

End    
