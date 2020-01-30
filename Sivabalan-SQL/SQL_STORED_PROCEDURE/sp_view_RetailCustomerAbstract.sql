CREATE PROCEDURE sp_view_RetailCustomerAbstract(@INVOICEID INT)          
AS          
	SELECT InvoiceDate, Customer.BillingAddress, Customer.DOB,          
		InvoiceAbstract.CustomerID,   
		dbo.LookUpDictionaryItem( Customer.Company_Name,default) as Company_Name,           
		InvoiceAbstract.GrossValue, InvoiceAbstract.DiscountPercentage,           
		InvoiceAbstract.DiscountValue, InvoiceAbstract.NetValue, DocumentID,          
		InvoiceAbstract.Status, InvoiceAbstract.InvoiceReference, InvoiceAbstract.ShippingAddress,          
		InvoiceAbstract.NewInvoiceReference, Doctor.Name, PaymentMode, PaymentDetails,          
		IsNull(MembershipCode,N''), IsNull(Customer.Phone,N''),       
		IsNull((Select CustomerCategory.CategoryName From CustomerCategory          
			Where CustomerCategory.CategoryID = Customer.CustomerCategory), N''),          
		InvoiceAbstract.SalesmanID, SalesMan.SalesMan_Name, InvoiceAbstract.RoundOffAmount,ServiceCharge as Service,      
		isNull(InvoiceAbstract.TaxOnMrp,0) as TaxOnMrp,      
		InvoiceAbstract.DocReference,InvoiceAbstract.DocSerialType,      
		SchemeID, SchemeDiscountPercentage, SchemeDiscountAmount, Status, 
		isnull(retailcustomercategory.CategoryName,N'') as CategoryName
		,isnull(InvoiceAbstract.GSTFullDocID,'') as GSTFullDocID   		      
	FROM InvoiceAbstract
	Inner Join Customer On InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS nvarchar)          
	Left Outer Join  Doctor On InvoiceAbstract.ReferredBy = Doctor.ID          
	Left Outer Join  SalesMan On InvoiceAbstract.SalesmanID = SalesMan.SalesManID         
	Left Outer Join retailcustomercategory On customer.retailcategory = retailcustomercategory.CategoryID          
	WHERE InvoiceAbstract.InvoiceID = @INVOICEID          
