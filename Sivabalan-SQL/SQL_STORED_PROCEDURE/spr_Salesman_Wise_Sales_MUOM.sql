CREATE PROCedure [dbo].[spr_Salesman_Wise_Sales_MUOM]( @SALESMAN nvarchar(2550),                 
@FROMDATE DATETIME ,                 
@TODATE DATETIME,      
@UOMDesc nvarchar(30) )                 
AS                 
      
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
Declare @MLOthers NVarchar(50)
Set @MLOthers=dbo.LookupDictionaryItem(N'Others', Default)
      
create table #tmpSale(Salesman_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @SALESMAN=N'%'      
   insert into #tmpSale select Salesman_Name from Salesman      
else      
   insert into #tmpSale select * from dbo.sp_SplitIn2Rows(@SALESMAN ,@Delimeter)      
      
If @SALESMAN = N'%'      
Begin      
select  cast (isnull(Salesman.Salesmanid, 0 ) as nvarchar) +  N',' + (isnull(InvoiceAbstract.CustomerID,0 )) ,             
"Salesman" = case isnull(Salesman.Salesman_Name, N'' ) when N'' then @MLOthers else Salesman.Salesman_Name end ,                 
"Customer ID" = isnull(InvoiceAbstract.CustomerID, N''),           
"Company Name" = isnull(Customer.Company_Name, N'') ,                 
"Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Amount,0) ELSE isnull(InvoiceDetail.Amount,0) END),                 
"Total Quantity" = sum(
					(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END) /
					(Case When @UOMdesc = N'UOM1' then Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
		    		When @UOMdesc = N'UOM2' then Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End  
					Else 1  
		   			End))              		
  --"Total Invoice" = count(InvoiceAbstract.invoiceid)                 
FROM InvoiceAbstract
Left Outer Join Customer on InvoiceAbstract.Customerid = Customer.Customerid
Inner Join InvoiceDetail on InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid
Left Outer Join Salesman on InvoiceAbstract.SalesmanID = Salesman.SalesmanID 
Inner Join Items on InvoiceDetail.Product_Code = Items.Product_Code
WHERE                 
--InvoiceAbstract.Customerid *= Customer.Customerid                 
--AND InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid AND 
InvoiceAbstract.InvoiceDate between @FROMDATE and @TODATE                 
--And InvoiceAbstract.SalesmanID *= Salesman.SalesmanID                 
AND Salesman.Salesman_Name in(select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale)           
AND (InvoiceAbstract.Status & 128 ) = 0                 
AND InvoiceAbstract.InvoiceType in (1,3,4)                 
--And InvoiceDetail.Product_Code = Items.Product_Code
GROUP BY  Salesman.Salesmanid , SALESMAN.SALESMAN_name,                 
InvoiceAbstract.CustomerID, Customer.Company_Name                 
order by SALESMAN.SALESMAN_name              
End      
Else      
Begin      
select  cast (isnull(Salesman.Salesmanid, 0 ) as nvarchar) +  N',' + (isnull(InvoiceAbstract.CustomerID,0 )) ,             
"Salesman" = isnull(Salesman.Salesman_Name, N'' ),                 
"Customer ID" = isnull(InvoiceAbstract.CustomerID, N''),           
"Company Name" = isnull(Customer.Company_Name, N'') ,                 
"Net Value (%c)" = sum(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Amount,0) ELSE isnull(InvoiceDetail.Amount,0) END),                 
"Total Quantity" = sum(
					(case InvoiceAbstract.InvoiceType when 4 then 0 - isnull(InvoiceDetail.Quantity,0) ELSE isnull(InvoiceDetail.Quantity,0) END)/
					(Case When @UOMdesc = N'UOM1' then Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End
		    		When @UOMdesc = N'UOM2' then Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End  
					Else 1  
		   			End))              
  --"Total Invoice" = count(InvoiceAbstract.invoiceid)   
--FROM InvoiceAbstract, InvoiceDetail, Customer, Salesman, Items
FROM InvoiceAbstract
Left Outer Join Customer on InvoiceAbstract.Customerid = Customer.Customerid
Inner Join InvoiceDetail on InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid
Left Outer Join Salesman on InvoiceAbstract.SalesmanID = Salesman.SalesmanID 
Inner Join Items on InvoiceDetail.Product_Code = Items.Product_Code

WHERE                 
--InvoiceAbstract.Customerid *= Customer.Customerid                 
--AND InvoiceAbstract.Invoiceid = InvoiceDetail.Invoiceid AND 
InvoiceAbstract.InvoiceDate between @FROMDATE and @TODATE                 
--And InvoiceAbstract.SalesmanID = Salesman.SalesmanID                 
AND Salesman.Salesman_Name in(select Salesman_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSale)               
AND (InvoiceAbstract.Status & 128 ) = 0                 
AND InvoiceAbstract.InvoiceType in (1,3,4)                 
--And InvoiceDetail.Product_Code = Items.Product_Code
GROUP BY  Salesman.Salesmanid , SALESMAN.SALESMAN_name,                 
InvoiceAbstract.CustomerID, Customer.Company_Name                 
order by SALESMAN.SALESMAN_name       
End      
