Create Procedure mERP_SP_GetQuotationCustomer_Detail(@QuotationID int)  
As  
Begin  
    select Customer.CustomerID,Customer.Company_Name,QuotationCustomers.SpecialTaxApplicable from   
    QuotationCustomers,Customer   
    where QuotationID=@QuotationID   
    and Customer.CustomerID=QuotationCustomers.CustomerID
	order by Customer.CustomerID   
End 
