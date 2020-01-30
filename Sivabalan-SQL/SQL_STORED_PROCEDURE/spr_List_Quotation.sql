CREATE PROCEDURE spr_List_Quotation(@CustomerID nvarchar(2550), @FromDate DateTime, @ToDate DateTime)    
AS    
Declare @Delimeter as Char(1)  
Declare @YES As NVarchar(50)  
Declare @NO As NVarchar(50)  
Declare @ITEMWISE As NVarchar(50)  
Declare @CATEGORYWISE As NVarchar(50)  
Declare @MANUFACTURERWISE As NVarchar(50)  
Declare @UNIVERSALDISCOUNT  As NVarchar(50)  
  
Set @YES = dbo.LookupDictionaryitem(N'Yes', Default)  
Set @NO = dbo.LookupDictionaryitem(N'No', Default)  
Set @ITEMWISE = dbo.LookupDictionaryitem(N'Itemwise', Default)  
Set @CATEGORYWISE = dbo.LookupDictionaryitem(N'Categorywise', Default)  
Set @MANUFACTURERWISE = dbo.LookupDictionaryitem(N'Manufacturerwise', Default)  
Set @UNIVERSALDISCOUNT = dbo.LookupDictionaryitem(N'Universal Discount', Default)  
  
  
Set @Delimeter=Char(15)      
Declare @tmpCustomer table(Customer_ID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @CustomerID='%'       
   Insert into @tmpCustomer select CustomerID from Customer      
Else      
   Insert into @tmpCustomer select * from dbo.sp_SplitIn2Rows(@CustomerID,@Delimeter)      
    
SELECT "Quotation ID" = QuotationAbstract.QuotationID, "Quotation Name" = QuotationName, "Quotation Date" = QuotationDate,     
"Valid From Date" = ValidFromDate, "Valid To Date" = ValidToDate,     
"Allow Invoice Scheme" = CASE AllowInvoiceScheme    
WHEN 1 THEN    
@YES  
ELSE    
@NO  
END,     
"Type" = Case QuotationLevel    
WHEN 1 THEN    
@ITEMWISE    
WHEN 2 THEN    
@CATEGORYWISE  
WHEN 3 THEN    
@MANUFACTURERWISE  
ELSE    
@UNIVERSALDISCOUNT  
END,     
"Customer Name" = dbo.fn_Get_CustomerName(QuotationAbstract.QuotationID), "Active" = Case Active WHEN 1 THEN @YES ELSE @NO END    
FROM QuotationAbstract    
WHERE QuotationAbstract.QuotationID IN (SELECT Distinct(QuotationID) FROM QuotationCustomers WHERE QuotationCustomers.CustomerID In (select Customer_ID COLLATE SQL_Latin1_General_CP1_CI_AS from @tmpCustomer))     
And QuotationDate BETWEEN @FromDate AND @ToDate     

