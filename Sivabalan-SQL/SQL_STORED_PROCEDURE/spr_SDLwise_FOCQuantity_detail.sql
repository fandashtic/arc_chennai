CREATE PROCEDURE spr_SDLwise_FOCQuantity_detail ( @PRODUCTCODE nvarchar(15), @FROMDATE DATETIME, @TODATE DATETIME , @UOM nvarchar(100))          
as     
Declare @Prefix nvarchar(10)
set @Prefix = N''
select @Prefix = prefix from voucherprefix where TranId=N'INVOICE'
    
if @UOM = N'Sales UOM'     
begin    
    
         
 SELECT  Invoiceabstract.InvoiceID,@Prefix + cast(Invoiceabstract.InvoiceID as nvarchar) as InvoiceID,Invoiceabstract.DocReference as "Doc.Reference", Invoiceabstract.InvoiceDate,        
  invoiceabstract.customerId as "Customer ID",      
  Customer.Company_Name as "Customer Name",      
  "Sales UOM" = UOM.Description,    
  "Quantity" = sum (case InvoiceAbstract.InvoiceType         
    when 4 then         
       0 - Invoicedetail.Quantity         
    else        
       Invoicedetail.Quantity         
        end  )      
  FROM Invoicedetail,Invoiceabstract,Customer, UOM, Items         
  WHERE Invoicedetail.InvoiceID = Invoiceabstract.InvoiceID         
  And Invoiceabstract.CustomerID = Customer.CustomerID         
  And Items.UOM = UOM.UOM    
  And Items.Product_Code = InvoiceDetail.Product_Code    
  And Invoicedetail.Saleprice = 0 And InvoiceType in (1,3,4)         
  And (status & 128) = 0 And INVOICEDETAIL.product_code = @PRODUCTCODE        
  And INVOICEABSTRACT.invoicedate BETWEEN @FROMDATE AND @TODATE        
 GROUP BY Invoiceabstract.InvoiceID,Invoiceabstract.DocReference , Invoiceabstract.InvoiceDate, UOM.Description,         
  invoiceabstract.customerId,     
  Customer.Company_Name     
END    
else if @UOM = N'Conversion Factor'    
 Begin            
  SELECT Invoiceabstract.InvoiceID,@Prefix + cast(Invoiceabstract.InvoiceID as nvarchar) as InvoiceID,Invoiceabstract.DocReference as "Doc.Reference", Invoiceabstract.InvoiceDate,        
         invoiceabstract.customerId as "Customer ID",      
   Customer.Company_Name as "Customer Name",         
  "Conversion Factor UOM" = ConversionTable.ConversionUnit,    
   "Quantity" = SUM(Case InvoiceAbstract.InvoiceType       
   when 4 then       
       0 - Invoicedetail.Quantity       
   else      
       Invoicedetail.Quantity       
         end) * (SELECT CASE IsNull(Item.ConversionFactor,0) WHEN 0 THEN 1 else Item.ConversionFactor end FROM Items Item WHERE Item.Product_Code = @productcode)    
                FROM INVOICEABSTRACT,INVOICEDETAIL,customer, ConversionTable, Items    
  WHERE ConversionTable.ConversionID = Items.ConversionUnit AND    
   INVOICEABSTRACT.INVOICEID = INVOICEDETAIL.INVOICEID   and    
                invoiceabstract.customerid = customer.customerid AND INVOICEABSTRACT.Invoicetype in (1,3,4) AND INVOICEDETAIL.Saleprice = 0       
  And Items.Product_Code = InvoiceDetail.Product_Code    
  AND (status & 128) = 0 and  INVOICEDETAIL.product_code = @PRODUCTCODE      
  AND INVOICEABSTRACT.invoicedate BETWEEN @FROMDATE AND @TODATE      
  group by Invoiceabstract.InvoiceID,Invoiceabstract.DocReference , Invoiceabstract.InvoiceDate, ConversionTable.ConversionUnit,        
             invoiceabstract.customerId, Customer.Company_Name     
 end    
else     
    
 Begin            
  SELECT Invoiceabstract.InvoiceID,@Prefix + cast(Invoiceabstract.InvoiceID as nvarchar) as InvoiceID,Invoiceabstract.DocReference as "Doc.Reference", Invoiceabstract.InvoiceDate,        
         invoiceabstract.customerId as "Customer ID",      
   Customer.Company_Name as "Customer Name",         
  "Reporting UOM" = UOM.Description,    
   "Quantity" = SUM(Case InvoiceAbstract.InvoiceType       
   when 4 then       
       0 - Invoicedetail.Quantity       
   else      
       Invoicedetail.Quantity       
         end) / (SELECT CASE IsNull(Item.ReportingUnit,0) WHEN 0 THEN 1 else Item.ReportingUnit end FROM Items Item WHERE Item.Product_Code = @productcode)    
                FROM INVOICEABSTRACT,INVOICEDETAIL,customer, UOM, Items    
  WHERE INVOICEABSTRACT.INVOICEID = INVOICEDETAIL.INVOICEID   and    
                invoiceabstract.customerid = customer.customerid AND INVOICEABSTRACT.Invoicetype in (1,3,4) AND INVOICEDETAIL.Saleprice = 0       
  And Items.Product_Code = InvoiceDetail.Product_Code    
  And Items.ReportingUOM = UOM.UOM     
  AND (status & 128) = 0 and  INVOICEDETAIL.product_code = @PRODUCTCODE      
  AND INVOICEABSTRACT.invoicedate BETWEEN @FROMDATE AND @TODATE      
  group by Invoiceabstract.InvoiceID,Invoiceabstract.DocReference , Invoiceabstract.InvoiceDate, UOM.Description,       
  invoiceabstract.customerId,     
  Customer.Company_Name     
 end    
    
    
  
  


