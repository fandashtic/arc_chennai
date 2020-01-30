
CREATE procedure sp_Insert_Batch_Products_ZWings  (                    
            @Product_code nvarchar(15),                
            @Quantity Decimal(18,6),            
            @PurchasePrice Decimal(18,6),            
            @SalePrice Decimal(18,6)        
 )            
as           
Declare @Ret int    

if @Quantity < 0          
begin          
 set  @Quantity  = 0          
end          
insert into batch_products(Product_code ,             
            Quantity ,            
            PurchasePrice ,            
            SalePrice )            
values(            
           @Product_code ,            
            @Quantity ,            
            @PurchasePrice ,            
            @SalePrice  )            
          
if @@rowcount <> 0               
begin     
 Set @Ret = 1  
end              
else              
begin              
 Set @Ret = 2    
end              
select @Ret    
  


