Create Procedure sp_get_SRRecd_NilStockItems_ITC (@StockRequestNo int)    
As    
Create Table #temp(ItemCode nvarchar(20) null,Quantity Decimal(18,6) null)    
  
Create Table #SRDetail(ItemCode nvarchar(20) null,Quantity Decimal(18,6) null)    
  
Declare @ConstInvalid as NVarchar(20)    
    
Set @ConstInvalid = dbo.LookupDictionaryItem(N'Invalid', Default)    
    
Insert into #temp    
Select Batch_Products.Product_Code, Sum(Batch_Products.Quantity)     
From Batch_Products    
Where Batch_Products.Product_Code in   
(Select Stock_Request_Detail_Received.Product_Code    
From Stock_Request_Detail_Received    
Where Stk_Req_Number = @StockRequestNo And  Pending > 0)    
Group By Batch_Products.Product_Code    
  
Insert into #SRDetail  Select SRDR.Product_Code, Sum(SRDR.Pending)  
From Stock_Request_Detail_Received SRDR, Items    
Where SRDR.Product_Code = Items.Product_Code  And  
SRDR.Stk_Req_Number = @StockRequestNo And SRDR.Pending > 0  
Group By SRDR.Product_Code    
  
Select "Item Code" = #SRDetail.ItemCode,     
"Pending Quantity" = Cast(#SRDetail.Quantity as nVarchar),  
"Available Quantity" = Cast(#Temp.Quantity as nVarchar)
From #Temp, #SRDetail    
Where #Temp.ItemCode = #SRDetail.ItemCode And    
#Temp.Quantity < #SRDetail.Quantity     
Union    
Select ForumCode, Sum(Pending), @ConstInvalid    
From Stock_Request_Detail_Received    
Where (IsNull(Product_Code, N'') = N'' Or Product_Code Not In (Select Distinct(Product_Code) From Batch_Products) or
Isnull(Product_Code,N'') NOT IN (SELECT PRODUCT_CODE FROM Items) or
Isnull(Product_Code,N'') in (select product_code from Items where active = 0)) And    
Stk_Req_Number = @StockRequestNo And  Pending > 0
Group By ForumCode    
Drop Table #temp    
