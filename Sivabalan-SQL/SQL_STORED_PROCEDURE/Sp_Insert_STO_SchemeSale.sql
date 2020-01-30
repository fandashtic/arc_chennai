CREATE procedure Sp_Insert_STO_SchemeSale (@prod_code as nvarchar(20) , @freeQty Decimal(18,6) ,     
@value decimal(18,6) , @cost decimal(18,6) , @Type int , @stoID int , @Pending Decimal(18,6) ,    
@Serial Int)    
as    
--Primary Qty = 0    
--Flags = 1    
--Special Category = 0 - Regular Scheme    
--SaleType = 1 STO    
--@Cost = Purchase Price * Quantity
Set @Cost = (Select Purchase_Price From Items Where Product_Code = @prod_code) * @freeQty
Insert Into SchemeSale(Product_Code, Quantity , Free , Value , Cost , Type ,    
InvoiceID , Pending , Flags , SpecialCategory , Serial , SaleType)    
Values(@prod_code , 0 , @freeQty , @value , @cost , @Type ,     
@stoID , @freeQty , 1 , 0 , @Serial , 1)    
    
  
  


