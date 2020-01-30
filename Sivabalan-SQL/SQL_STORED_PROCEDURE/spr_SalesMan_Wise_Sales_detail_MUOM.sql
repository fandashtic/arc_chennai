Create PROCEDURE [dbo].[spr_SalesMan_Wise_Sales_detail_MUOM](@SALES_CUST nvarchar(100),         
      @FROMDATE DATETIME ,         
      @TODATE DATETIME, @UOMDesc nvarchar(30) )        
AS        
DECLARE @SALE int  
DECLARE @CUST nvarchar(50)      
DECLARE @LENSTR INT      
SET @LENSTR = (CHARINDEX(',', @SALES_CUST) )       
SELECT @SALE = cast (SUBSTRING(@SALES_CUST,  1 , (@lENSTR - 1 ))   as int)  
SELECT @CUST = SUBSTRING(@SALES_CUST, (@lENSTR + 1) , LEN(@SALES_CUST) - @lENSTR )      
SELECT  InvoiceDetail.Product_Code,   
 "Item Name" = Items.ProductName,         
  --"Quantity" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END),        
"Quantity" = Cast((    
   Case When @UOMdesc = 'UOM1' then dbo.sp_Get_ReportingQty(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.
UOM1_Conversion End)      
       When @UOMdesc = 'UOM2' then dbo.sp_Get_ReportingQty(sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.
UOM2_Conversion End)      
     Else sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END)      
   End) as nvarchar)  
  + ' ' + Cast((    
   Case When @UOMdesc = 'UOM1' then (SELECT Description FROM UOM WHERE UOM = Items.UOM1)      
       When @UOMdesc = 'UOM2' then (SELECT Description FROM UOM WHERE UOM = Items.UOM2)      
     Else (SELECT Description FROM UOM WHERE UOM = Items.UOM)      
   End) as nvarchar),  
 "Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Amount,0) ELSE isnull(InvoiceDetail.Amount,0) END)        
 FROM InvoiceAbstract
 Inner Join InvoiceDetail ON InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid
 Inner Join Items ON InvoiceDetail.Product_Code = Items.Product_Code
 Left Outer Join Salesman ON InvoiceAbstract.SalesmanID = Salesman.SalesmanID
 Inner Join Customer ON invoiceabstract.customerid = customer.customerid      
 WHERE  
 InvoiceAbstract.InvoiceDate between @FROMDATE and @TODATE 
 AND isnull(invoiceabstract.Salesmanid, 0)  =  @SALE      
 AND (InvoiceAbstract.Status & 128 ) = 0        
 AND  InvoiceAbstract.InvoiceType in (1,3,4)        
 and invoiceabstract.customerid like @CUST      
GROUP BY InvoiceDetail.Product_Code, Items.ProductName,   
Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM

