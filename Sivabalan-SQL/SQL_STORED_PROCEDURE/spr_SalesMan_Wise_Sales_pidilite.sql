CREATE procedure [dbo].[spr_SalesMan_Wise_Sales_pidilite]( @ProductHierarchy nVarChar(100),       
@Category nVarChar(4000), @SALESMAN nVARCHAR(2550),             
@FROMDATE DATETIME ,             
@TODATE DATETIME,  
@UOM nVarChar(100) )             
AS             
  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
Declare @MLOthers nVarchar(50)
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)
  
create table #tmpSale(Salesman_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @SALESMAN='%'  
   insert into #tmpSale select Salesman_Name from Salesman  
else  
   insert into #tmpSale select * from dbo.sp_SplitIn2Rows(@SALESMAN ,@Delimeter)  
  
Create Table #tempCategory(CategoryID int, Status int)                
Exec GetSubCategories @Category              
  
If @SALESMAN = '%'  
Begin  
select  cast (isnull(Salesman.Salesmanid, 0 ) as nvarchar) +  ',' + (isnull(InvoiceAbstract.CustomerID,0 )) ,         
"Salesman" = case isnull(Salesman.Salesman_Name, '' ) when '' then @MLOthers else Salesman.Salesman_Name end ,             
"Customer ID" = isnull(InvoiceAbstract.CustomerID, ''),       
"Company Name" = isnull(Customer.Company_Name, '') ,             
"Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Amount,0) ELSE isnull(InvoiceDetail.Amount,0) END),             
"Total Quantity" = sum(case InvoiceAbstract.InvoiceType when 4 then   
 0 - (Case @UOM When 'Sales UOM' Then isnull(InvoiceDetail.Quantity, 0)  
      When 'UOM1' Then  isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom1_conversion, 1) when 0 then 1 Else isnull(items.uom1_conversion, 1) End)    
      When 'UOM2' Then isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom2_conversion, 1) when 0 then 1 Else isnull(items.uom2_conversion, 1) End) End) ELSE 
      (Case @UOM When 'Sales UOM' Then isnull(InvoiceDetail.Quantity, 0)    
      When 'UOM1' Then  isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom1_conversion, 1) when 0 then 1 Else isnull(items.uom1_conversion, 1) End)    
      When 'UOM2' Then isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom2_conversion, 1) when 0 then 1 Else isnull(items.uom2_conversion, 1) End) End) END)

-- "Total Quantity" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END)          
  --"Total Invoice" = count(InvoiceAbstract.invoiceid)             
FROM Items, InvoiceAbstract, InvoiceDetail, Customer, Salesman             
WHERE  
Items.Product_Code = InvoiceDetail.Product_Code And  
InvoiceAbstract.Customerid *= Customer.Customerid             
AND InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid             
AND InvoiceAbstract.InvoiceDate between @FROMDATE and @TODATE             
And InvoiceAbstract.SalesmanID *= Salesman.SalesmanID             
AND Salesman.Salesman_Name in(select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale)       
And Items.CategoryID In (Select CategoryID From #tempCategory)  
AND (InvoiceAbstract.Status & 128 ) = 0             
AND InvoiceAbstract.InvoiceType in (1,3,4)             
GROUP BY  Salesman.Salesmanid , SALESMAN.SALESMAN_name,             
InvoiceAbstract.CustomerID, Customer.Company_Name             
order by SALESMAN.SALESMAN_name          
End  
Else  
Begin  
select  cast (isnull(Salesman.Salesmanid, 0 ) as nvarchar) +  ',' + (isnull(InvoiceAbstract.CustomerID,0 )) ,         
"Salesman" = isnull(Salesman.Salesman_Name, '' ),             
"Customer ID" = isnull(InvoiceAbstract.CustomerID, ''),       
"Company Name" = isnull(Customer.Company_Name, '') ,             
"Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Amount,0) ELSE isnull(InvoiceDetail.Amount,0) END),             
"Total Quantity" = sum(case InvoiceAbstract.InvoiceType when 4 then   
 0 - (Case @UOM When 'Sales UOM' Then isnull(InvoiceDetail.Quantity, 0)  
      When 'UOM1' Then  isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom1_conversion, 1) when 0 then 1 Else isnull(items.uom1_conversion, 1) End)    
      When 'UOM2' Then isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom2_conversion, 1) when 0 then 1 Else isnull(items.uom2_conversion, 1) End) End) ELSE 
      (Case @UOM When 'Sales UOM' Then isnull(InvoiceDetail.Quantity, 0)    
      When 'UOM1' Then  isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom1_conversion, 1) when 0 then 1 Else isnull(items.uom1_conversion, 1) End)    
      When 'UOM2' Then isnull(InvoiceDetail.Quantity, 0) / (Case isnull(items.uom2_conversion, 1) when 0 then 1 Else isnull(items.uom2_conversion, 1) End) End) END)

--"Total Quantity" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END)          
  --"Total Invoice" = count(InvoiceAbstract.invoiceid)             
FROM Items, InvoiceAbstract, InvoiceDetail, Customer, Salesman             
WHERE             
Items.Product_Code = InvoiceDetail.Product_Code And  
InvoiceAbstract.Customerid *= Customer.Customerid             
AND InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid             
AND InvoiceAbstract.InvoiceDate between @FROMDATE and @TODATE             
And InvoiceAbstract.SalesmanID = Salesman.SalesmanID             
AND Salesman.Salesman_Name in(select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale)           
And Items.CategoryID In (Select CategoryID From #tempCategory)  
AND (InvoiceAbstract.Status & 128 ) = 0             
AND InvoiceAbstract.InvoiceType in (1,3,4)             
GROUP BY  Salesman.Salesmanid , SALESMAN.SALESMAN_name,             
InvoiceAbstract.CustomerID, Customer.Company_Name             
order by SALESMAN.SALESMAN_name   
End
