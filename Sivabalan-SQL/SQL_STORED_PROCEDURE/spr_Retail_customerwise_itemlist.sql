CREATE procedure spr_Retail_customerwise_itemlist(@Manufacturer nvarchar(128), 
		 @Product_Code nvarchar(15), @fromdate datetime, @todate datetime ) 
as
      
declare @AlterSql  nvarchar(4000)      
declare @ItemName  nvarchar(255) 
declare @ColName   nvarchar(255)      
declare @Quantity  nvarchar(255) 
declare @CustName  nvarchar(255)      
declare @UpdateSql nvarchar(4000)     

--Creating Table #Temp1
SELECT "CustomerName" = dbo.EncodeQuotes(cash_Customer.CustomerName),Items.Product_code,    
"Quantity" =   
sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
case  When (InvoiceAbstract.Status & 32) = 0  Then   
0 - InvoiceDetail.Quantity   
Else 0   
End    
Else InvoiceDetail.Quantity    
End) into #Temp1
FROM cash_Customer,Items,InvoiceDetail,InvoiceAbstract,ItemCategories,Manufacturer        
WHERE cash_Customer.CustomerID = InvoiceAbstract.CustomerID and         
ItemCategories.CategoryID = Items.CategoryID AND        
Items.Product_Code = InvoiceDetail.Product_Code and          
InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID and          
(InvoiceAbstract.Status & 128) = 0 AND InvoiceAbstract.InvoiceType = 2           
and InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate        
and items.manufacturerid = manufacturer.manufacturerid
and invoicedetail.product_code like @Product_Code
and Manufacturer.Manufacturer_Name like @Manufacturer    
GROUP BY Items.Product_code,Items.ProductName, dbo.EncodeQuotes(cash_Customer.CustomerName)   
 
--Creating Table #Temp2
select distinct CustomerName into #Temp2 
from invoiceabstract,cash_Customer,invoicedetail 
where invoiceabstract.customerid = cash_customer.customerid and invoicetype =2 
and invoiceabstract.invoiceid = invoicedetail.invoiceid 
and invoicedetail.product_code in (select Product_code from #Temp1 )

--Creating Cursor to insert ItemName as columns 
Declare getItemName cursor for select distinct Product_code from #Temp1      
Open getItemName      
Fetch from getItemName into @ItemName      
while @@fetch_status = 0      
Begin      
 Set @AlterSql = N'Alter Table #Temp2 Add [' + @ItemName +  N'] decimal (18,6) null'           
 Exec sp_executesql @AlterSql               
 Fetch Next From getItemName into @ItemName          
End             

--Updating the quantity in Temp table
Declare getQuantity cursor for select CustomerName,Product_code,Quantity from #Temp1      
Open getQuantity      
Fetch from getQuantity into @CustName,@ColName,@Quantity      
while @@fetch_status = 0      
Begin      
 SET @UpdateSQL = N'Update #Temp2 Set [' + @ColName + N'] = ' + cast (@Quantity as nvarchar) + N' Where CustomerName = N'''+ @CustName +''''
 exec sp_executesql @UpdateSQL               
 Fetch Next From getQuantity into @CustName,@ColName,@Quantity       
End             

--Updating the quantity in Temp table

close getQuantity      
Deallocate getQuantity      
close getItemName      
Deallocate getItemName      

Select * from #Temp2

drop table #temp1
drop table #temp2

