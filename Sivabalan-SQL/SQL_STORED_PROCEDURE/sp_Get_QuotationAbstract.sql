Create PROCEDURE sp_Get_QuotationAbstract(@QuotationID INT)        
AS
Begin        
DECLARE @CustomerCategory INT  
DECLARE @CustType INT  

SELECT  @CustomerCategory = CustomerCategory, @CustType = Locality FROM Customer  
WHERE Customer.CustomerID = (SELECT Top 1 CustomerID FROM QuotationCustomers WHERE QuotationID = @QuotationID)    
SELECT QuotationDate, ValidFromDate, ValidToDate, AllowInvoiceScheme, QuotationType, QuotationAbstract.Active,    
@CustomerCategory, @CustType,QuotationSubType,QuotationLevel,UOMConversion,SpecialTax,isnull(GSTFlag,0) as GSTFlag 
FROM QuotationAbstract WHERE QuotationAbstract.QuotationID = @QuotationID
End
