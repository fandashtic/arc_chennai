CREATE procedure [dbo].[spr_SalesMan_Wise_Sales_detail_pidilite](@SALES_CUST NVARCHAR(100),         
@ProductHierarchy VarChar(100),       
@Category VarChar(4000),    
@Salesman Varchar(2550),      
@FROMDATE DATETIME ,         
@TODATE DATETIME,  
@UOM VarChar(100))        
AS        
DECLARE @SALE int  
DECLARE @CUST NVARCHAR(50)      
DECLARE @LENSTR INT      
SET @LENSTR = (CHARINDEX(',', @SALES_CUST) )       
SELECT @SALE = cast (SUBSTRING(@SALES_CUST,  1 , (@lENSTR - 1 ))   as int)  
SELECT @CUST = SUBSTRING(@SALES_CUST, (@lENSTR + 1) , LEN(@SALES_CUST) - @lENSTR )      
  
Create Table #tempCategory(CategoryID int, Status int)                
Exec GetSubCategories @Category              
  
SELECT  InvoiceDetail.Product_Code, "Category Name" = itemcategories.category_name,   
 "Item Name" = Items.ProductName,         
  "Quantity" = sum(case InvoiceAbstract.InvoiceType when 4 then   
 0 - (Case @UOM When 'Sales UOM' Then isnull(InvoiceDetail.Quantity, 0)  
      When 'UOM1' Then  isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom1_conversion, 1) when 0 then 1 Else isnull(items.uom1_conversion, 1) End)    
      When 'UOM2' Then isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom2_conversion, 1) when 0 then 1 Else isnull(items.uom2_conversion, 1) End) End) ELSE 
      (Case @UOM When 'Sales UOM' Then isnull(InvoiceDetail.Quantity, 0)    
      When 'UOM1' Then  isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom1_conversion, 1) when 0 then 1 Else isnull(items.uom1_conversion, 1) End)    
      When 'UOM2' Then isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom2_conversion, 1) when 0 then 1 Else isnull(items.uom2_conversion, 1) End) End) END),        
 "Reporting UOM" = Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity, 0) Else isnull(InvoiceDetail.Quantity, 0) End / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
 "Conversion Factor" = Sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity, 0) Else isnull(InvoiceDetail.Quantity, 0) End * IsNull(ConversionFactor, 0)),
 "Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Amount,0) ELSE isnull(InvoiceDetail.Amount,0) END)        
 FROM InvoiceAbstract, InvoiceDetail, Items, itemcategories, Salesman  , Customer      
 WHERE Items.Categoryid = itemcategories.Categoryid And   
 InvoiceDetail.Product_Code = Items.Product_Code        
 AND  InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid        
 AND  InvoiceAbstract.InvoiceDate between @FROMDATE and @TODATE        
 And  InvoiceAbstract.SalesmanID *= Salesman.SalesmanID        
 AND isnull(invoiceabstract.Salesmanid, 0)  =  @SALE      
 AND (InvoiceAbstract.Status & 128 ) = 0        
 AND  InvoiceAbstract.InvoiceType in (1,3,4)        
 and invoiceabstract.customerid = customer.customerid      
 and invoiceabstract.customerid like @CUST      
 And itemcategories.Categoryid In (Select CategoryID From #tempCategory)  
GROUP BY InvoiceDetail.Product_Code, Items.ProductName, itemcategories.Category_Name
