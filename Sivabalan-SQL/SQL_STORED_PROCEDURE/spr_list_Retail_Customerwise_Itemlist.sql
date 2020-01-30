CREATE Procedure [dbo].[spr_list_Retail_Customerwise_Itemlist]      
(       
@Manufacturer nvarchar(2550),       
@Product_Code nvarchar(2550),       
@FromDate DateTime,       
@ToDate DateTime      
 )      
AS      
      
Declare @Delimeter as Char(1)        
Declare @WALKINCUSTOMER As NVarchar(50)

Set @WALKINCUSTOMER = dbo.LookupDictionaryItem(N'Walkin Customer', Default)
Set @Delimeter=Char(15)        

Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create table #tmpItem(ProductCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
if @Manufacturer=N'%'         
   Insert into #tmpMfr select Manufacturer_Name from Manufacturer        
Else        
   Insert into #tmpMfr select * from dbo.sp_SplitIn2Rows(@Manufacturer,@Delimeter)        
        
if @Product_Code=N'%'        
   Insert into #tmpItem select product_code from Items        
Else        
   Insert into #tmpItem select * from dbo.sp_SplitIn2Rows(@Product_Code,@Delimeter)        
            
declare @AlterSql  nvarchar(4000)            
declare @ItemName  nvarchar(255)       
declare @ColName   nvarchar(255)            
declare @Quantity  nvarchar(255)       
declare @CustName  nvarchar(255)            
declare @UpdateSql nvarchar(4000)           
      
--Creating Table #Temp1      
SELECT "CustomerName" = case isnull(invoiceabstract.CustomerID,0)      
   When N'0' then      
	@WALKINCUSTOMER      
   else dbo.EncodeQuotes(Customer.Company_Name)      
   end,      
Items.Product_code,          
"Quantity" =         
sum(Case InvoiceAbstract.InvoiceType         
when 5 then    
0 - InvoiceDetail.Quantity    
when 6 then    
0 - InvoiceDetail.Quantity    
When 4 Then    
case  When (InvoiceAbstract.Status & 32) = 0  Then         
0 - InvoiceDetail.Quantity         
Else 0         
End          
Else InvoiceDetail.Quantity          
End) into #Temp1      
FROM Customer
Right Outer Join InvoiceAbstract on Customer.CustomerID = InvoiceAbstract.CustomerID 
Inner Join InvoiceDetail On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
Inner Join Items On Items.Product_Code = InvoiceDetail.Product_Code
Inner Join ItemCategories On ItemCategories.CategoryID = Items.CategoryID 
Inner Join Manufacturer On items.manufacturerid = manufacturer.manufacturerid      
WHERE Customer.CustomerCategory in(4,5) and      
(InvoiceAbstract.Status & 128) = 0 AND InvoiceAbstract.InvoiceType = 2                 
and InvoiceAbstract.InvoiceDate BETWEEN @fromdate AND @todate              
and invoicedetail.product_code In (Select ProductCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem)       
and Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpMfr)           
GROUP BY Items.Product_code,Items.ProductName, Customer.Company_Name,invoiceabstract.CustomerID         
      
--Creating Table #Temp2      
select distinct CustomerName into #Temp2 from #Temp1       
      
--Creating Cursor to insert ItemName as columns       
Declare getItemName cursor for select distinct Product_code from #Temp1            
Open getItemName            
Fetch from getItemName into @ItemName            
while @@fetch_status = 0            
Begin            
 Set @AlterSql = N'Alter Table #Temp2 Add [' + @ItemName +  '] Decimal(18,6) null' 
 Exec sp_executesql @AlterSql                     
 Fetch Next From getItemName into @ItemName                
End                   
      
--Updating the quantity in Temp table      
Declare getQuantity cursor for select CustomerName,Product_code,Quantity from #Temp1            
Open getQuantity            
Fetch from getQuantity into @CustName,@ColName,@Quantity            
while @@fetch_status = 0            
Begin            
 SET @UpdateSQL = N'Update #Temp2 Set [' + @ColName + '] = ' + cast (@Quantity as nvarchar) + ' Where CustomerName = N'''+ @CustName +''''      
 exec sp_executesql @UpdateSQL                     
 Fetch Next From getQuantity into @CustName,@ColName,@Quantity 
End             
      
--Updating the quantity in Temp table      
      
close getQuantity            
Deallocate getQuantity           
close getItemName            
Deallocate getItemName            
      
Select customername,* from #Temp2      
      
drop table #temp1      
drop table #temp2      
Drop table #tmpMfr      
Drop table #tmpItem      



