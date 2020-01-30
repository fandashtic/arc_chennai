CREATE PROCEDURE spr_SDLwise_FOCQuantity ( @FROMDATE DATETIME, @TODATE DATETIME, @UOM nVarchar(255))        
AS        
Declare @parentid int    
Declare @productcode nvarchar(500)    
Declare @categoryid nvarchar(500)    
Declare @categoryname nvarchar(500)    
Declare @CatDesc nvarchar(500)    
Declare @parentcategory nvarchar(500)    
DECLARE @FirstLevel nVARCHAR(100)  
DECLARE @LastLevel nVARCHAR(100)  
DECLARE @Mysql nVARCHAR(4000)  

 SET @FirstLevel = dbo.GetHierarchyColumn('FIRST')
 SET @LastLevel= dbo.GetHierarchyColumn('LAST')
   
 if @UOM = 'Sales UOM'            
        Begin            
    
  SELECT INVOICEDETAIL.product_code,    
                "Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(items.categoryid),    
                "Product Hierarchy Last Level"= itemcategories.category_Name,    
      
  "Item Code" = INVOICEDETAIL.product_code,    
  "Item Name" = ITEMS.productname,      
                 "Sales UOM" = UOM.Description,    
                 "Quantity" = SUM(Case InvoiceAbstract.InvoiceType       
    when 4 then       
       0 - Invoicedetail.Quantity       
    else      
       Invoicedetail.Quantity       
          end )    
                 INTO #Temp1 FROM ITEMS,INVOICEABSTRACT,INVOICEDETAIL,itemcategories, UOM     
  WHERE ITEMS.PRODUCT_CODE = INVOICEDETAIL.PRODUCT_CODE      
  AND Items.UOM = UOM.UOM     
  AND itemcategories.categoryid = items.categoryid      
  AND INVOICEABSTRACT.INVOICEID = INVOICEDETAIL.INVOICEID       
  AND INVOICEABSTRACT.Invoicetype in (1,3,4) AND INVOICEDETAIL.Saleprice = 0       
  AND (status & 128) = 0       
  AND INVOICEABSTRACT.invoicedate BETWEEN @FROMDATE AND @TODATE      
  group by itemcategories.category_Name,INVOICEDETAIL.product_code,items.categoryid,UOM.Description,    
   ITEMS.PRODUCTNAME    

  SET @Mysql = 	'SELECT [Product_Code], [Product Hierarchy First Level] As "' + @FirstLevel + '", ' + 
  		'[Product Hierarchy Last Level] As "' + @LastLevel + '", [Item Code], [Item Name], ' +
		'[Sales UOM], [Quantity] FROM #Temp1'
EXEC(@MySql)
DROP TABLE #Temp1
       End        
    
         else if @UOM = 'Conversion Factor'    
 Begin            
  SELECT INVOICEDETAIL.product_code,    
                "Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(items.categoryid),    
                "Product Hierarchy Last Level"= itemcategories.category_Name,    
  "Item Code" = INVOICEDETAIL.product_code,    
  "Item Name" = ITEMS.productname,      
                 "Conversion Factor UOM" = ConversionTable.ConversionUnit,    
                 "Quantity" = SUM(Case InvoiceAbstract.InvoiceType       
    when 4 then       
       0 - Invoicedetail.Quantity       
    else      
       Invoicedetail.Quantity       
          end) * (SELECT CASE IsNull(Item.ConversionFactor,0) WHEN 0 THEN 1 else Item.ConversionFactor end FROM Items Item WHERE Item.Product_Code = InvoiceDetail.Product_Code)    
                 FROM ITEMS,INVOICEABSTRACT,INVOICEDETAIL,itemcategories, ConversionTable    
  WHERE ITEMS.PRODUCT_CODE = INVOICEDETAIL.PRODUCT_CODE      
  And ConversionTable.ConversionID = Items.ConversionUnit    
  AND itemcategories.categoryid = items.categoryid      
  AND INVOICEABSTRACT.INVOICEID = INVOICEDETAIL.INVOICEID       
  AND INVOICEABSTRACT.Invoicetype in (1,3,4) AND INVOICEDETAIL.Saleprice = 0       
  AND (status & 128) = 0       
  AND INVOICEABSTRACT.invoicedate BETWEEN @FROMDATE AND @TODATE      
  group by itemcategories.category_Name,INVOICEDETAIL.product_code,items.categoryid,ConversionTable.ConversionUnit,    
   ITEMS.PRODUCTNAME    
 end    
 else     
 Begin            
  SELECT INVOICEDETAIL.product_code,    
                "Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(items.categoryid),    
                "Product Hierarchy Last Level"= itemcategories.category_Name,    
      
  "Item Code" = INVOICEDETAIL.product_code,    
  "Item Name" = ITEMS.productname,      
                "Reporting UOM" = UOM.Description,     
                 "Quantity" = SUM(Case InvoiceAbstract.InvoiceType       
    when 4 then       
       0 - Invoicedetail.Quantity       
    else      
       Invoicedetail.Quantity       
          end) / (SELECT CASE IsNull(Item.ReportingUnit,0) WHEN 0 THEN 1 else Item.ReportingUnit end FROM Items Item WHERE Item.Product_Code = InvoiceDetail.Product_Code)    
                 FROM ITEMS,INVOICEABSTRACT,INVOICEDETAIL,itemcategories, UOM    
  WHERE ITEMS.PRODUCT_CODE = INVOICEDETAIL.PRODUCT_CODE      
  AND Items.ReportingUOM = UOM.UOM     
  AND itemcategories.categoryid = items.categoryid      
  AND INVOICEABSTRACT.INVOICEID = INVOICEDETAIL.INVOICEID       
  AND INVOICEABSTRACT.Invoicetype in (1,3,4) AND INVOICEDETAIL.Saleprice = 0       
  AND (status & 128) = 0       
  AND INVOICEABSTRACT.invoicedate BETWEEN @FROMDATE AND @TODATE      
  group by itemcategories.category_Name,INVOICEDETAIL.product_code,items.categoryid,UOM.Description,INVOICEDETAIL.product_code,    
   ITEMS.PRODUCTNAME    
 end    
             
    
    
    
  
  


