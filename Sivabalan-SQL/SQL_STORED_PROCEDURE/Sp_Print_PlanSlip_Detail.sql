CREATE procedure Sp_Print_PlanSlip_Detail(@Customerid nvarchar(500)) as    
Set Nocount On    
declare @Order_tmp nvarchar(200)    
exec SPR_Split_Values_Plan @Customerid,4,@Order_tmp output    

Declare @Customerid_tmp NVarChar(200)                
exec SPR_Split_Values_Plan @Customerid,3,@Customerid_tmp output                

Declare @SVCount nVarChar(200)  
Exec SPR_Split_Values_Plan @Customerid,5,@SVCount OutPut  

Set DateFormat DMY

Create Table #TmpItem ([Item Code] nVarchar(15), [Item Name] nVarchar(250),  
[Default Sales Uom] nVarchar(250),[Price] Decimal(18,6),[OffTake] Decimal(18,6))  
if @Order_tmp <>'0'    
 Insert Into #TmpItem([Item Code],[Item Name],[Default Sales Uom],[Price],[OffTake])   
  select     
  i.Product_code ,    
  i.Productname ,    
  u.Description ,    
  i.Sale_Price,dbo.Fn_Get_OffTake(i.Product_Code,@SVCount,@Customerid_tmp)/ dbo.fn_GetUOMConversion(i.Product_code,1)
  from Items i, uom u ,orderdetail o    
  where i.uom = u.uom and    
  o.product_code = i.product_code and    
  o.docserial = @Order_tmp
else    
 Insert Into #TmpItem([Item Code],[Item Name],[Default Sales Uom],[Price],[OffTake])      
  Select     
  i.Product_code ,    
  i.Productname ,    
  u.Description ,    
  i.Sale_Price,dbo.Fn_Get_OffTake(i.Product_Code,@SVCount,@Customerid_tmp)/ dbo.fn_GetUOMConversion(i.Product_code,1)    
  From Items i, uom u   
  Where i.uom = u.uom 

Select "Item Code" = [item code],"Item Name" = [Item Name],"Default Sales Uom" = [Default Sales Uom],"Price" = [Price],"Off Take" = [OffTake] from #TmpItem  
Drop table #TmpItem  
set nocount off    
    

