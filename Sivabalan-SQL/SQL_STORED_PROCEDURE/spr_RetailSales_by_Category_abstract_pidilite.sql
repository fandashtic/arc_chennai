CREATE procedure [dbo].[spr_RetailSales_by_Category_abstract_pidilite](                
                    @Category nvarchar(2550),                  
                    @FromDate datetime,                  
                    @ToDate datetime)                    
                
AS    
    
Declare @Voucher as nvarchar(100)            
Select @Voucher = Prefix From VoucherPrefix Where TranID = 'INVOICE'                    
         
Create Table #tempCategory(CategoryID int, Status int)          
Exec GetSubCategories @Category       
         
Select Cast(InvoiceAbstract.InvoiceID as nvarchar) + ';' + @Category ,"Invoice ID" =  @Voucher + Cast(DocumentID as nvarchar), InvoiceDate, Doctor.Name as "Referred By",  
"Doc Reference" = DocReference,  
Customer.Company_Name       
From InvoiceAbstract, InvoiceDetail,Customer ,Items, ItemCategories, Doctor                
Where                 
InvoiceAbstract.CustomerID *= Customer.CustomerID                 
AND InvoiceAbstract.ReferredBy *= Doctor.ID                
AND InvoiceAbstract.InvoiceType in(2,5,6)    
AND invoicedetail.product_code = items.product_code                   
and invoicedetail.invoiceid=invoiceabstract.invoiceid                   
And (status & 128) = 0                   
and Items.CategoryID = ItemCategories.CategoryID              
and ItemCategories.CategoryID in (Select CategoryID from #tempCategory)          
And InvoiceAbstract.InvoiceDate BETWEEN @FromDate AND @ToDate                 
                
Union            
            
Select Cast(InvoiceAbstract.InvoiceID as nvarchar) + ';' + @Category ,"Invoice ID" =  @Voucher + Cast(DocumentID as nvarchar), InvoiceDate,NULL, 
"Doc Reference" = DocReference, Customer.Company_Name                 
From InvoiceAbstract, ItemCategories,Items, Customer, InvoiceDetail            
Where                 
InvoiceAbstract.CustomerID *= Customer.CustomerID             
AND InvoiceAbstract.InvoiceType in (1,3,4)            
And (status & 128) = 0                   
And InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID            
And InvoiceDetail.Product_Code = Items.Product_Code            
and Items.CategoryID = ItemCategories.CategoryID              
and ItemCategories.CategoryID in (Select CategoryID from #tempCategory)          
And InvoiceAbstract.InvoiceDate BETWEEN @FromDate AND @ToDate
