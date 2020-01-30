CREATE procedure SPRVanToInvoice_Weight_Detail(    
@VanNo nvarchar(100),     
@FromDate datetime,     
@ToDate datetime)    
as    

Select Items.ProductName,"Item " = Items.ProductName,
       "Category " = itemCategories.Category_Name ,
       "Weight " = sum(isnull(conversionfactor,0) * isnull(quantity,0)),
       "Amount" = sum(amount)
From InvoiceAbstract,InvoiceDetail,Items,itemCategories
where
InvoiceDetail.InvoiceID = InvoiceAbstract.Invoiceid
And InvoiceAbstract.Status &128 = 0
And InvoiceAbstract.Vannumber = @Vanno
And InvoiceDate between @FromDate And @Todate
And InvoiceDetail.Product_Code = Items.Product_Code
And Items.Categoryid = itemCategories.Categoryid

Group by Items.ProductName,itemCategories.Category_Name

