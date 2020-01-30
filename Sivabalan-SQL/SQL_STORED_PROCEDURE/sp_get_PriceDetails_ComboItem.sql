CREATE procedure [dbo].[sp_get_PriceDetails_ComboItem](@ProductCode nvarchar(15))           
AS          
DECLARE @combopack int        
set @combopack = 0        
SELECT @combopack = Itemcombo FROM items WHERE product_code = @productcode          
IF isnull(@combopack,0) = 0         
 BEGIN        
  SELECT  ProductName, Sale_Price, "Percentage" = b.Percentage, Price_Option, Track_Batches, Sale_Tax, Track_Inventory, ECP, PTS, PTR, Company_Price,          
  CAST(ISNULL(b.Percentage, 0) as nvarchar) + '+' + CAST(ISNULL(b.CST_Percentage, 0) as nvarchar),          
  CAST(ISNULL(a.Percentage, 0) as nvarchar) + '+' + CAST(ISNULL(a.CST_Percentage, 0) as nvarchar)          
  FROM Items, ItemCategories, Tax b, Tax a          
  WHERE Items.Product_code = @productcode and           
  Items.CategoryID *= ItemCategories.CategoryID and           
  Items.Sale_Tax *= b.Tax_Code and          
  Items.TaxSuffered *= a.Tax_Code          
 END          
ELSE       
BEGIN           
DECLARE @prname as nvarchar(510)          
DECLARE @price_option as int          
DECLARE @Track_Batches as int          
DECLARE @salestax as decimal(18,6)        
DECLARE @Track_Inventory as int          
DECLARE @pts as decimal(18,6)           
DECLARE @ptr as decimal(18,6)          
DECLARE @ecp as decimal(18,6)          
DECLARE @comp_price as decimal(18,6)          
DECLARE @prodcode as nvarchar(20)            
DECLARE @sale_price as decimal(18,6)            
DECLARE @sale_tax as decimal(18,6)            
DECLARE @taxsuffered as decimal(18,6)            
DECLARE @quantity as decimal(18,6)            
DECLARE @salepercen as decimal(18,6)            
DECLARE @salepercen1 as decimal(18,6)            
DECLARE @sufpercen as decimal(18,6)            
DECLARE @sufpercen1 as decimal(18,6)            
DECLARE @salper as decimal(18,6)            
DECLARE @salper1 as decimal(18,6)          
DECLARE @sufper as decimal(18,6)            
DECLARE @sufper1 as decimal(18,6)              
DECLARE @total as decimal(18,6)            
DECLARE @total1 as decimal(18,6)            
DECLARE @totsalper as decimal(18,6)            
DECLARE @totsalper1 as decimal(18,6)            
DECLARE @totsufper as decimal(18,6)            
DECLARE @totsufper1 as decimal(18,6)            
set @salper = 0        
set @salper1 = 0        
set @sufper = 0        
set @sufper1 = 0        
set @total = 0        
set @total1 = 0        
 --product name          
select @prname = productname from items where product_code = @productcode          
 -- price option , track battch to comp price          
select @price_option = price_option, @Track_Batches = Track_Batches, @salestax = Sale_Tax, @Track_Inventory = Track_Inventory, @ecp = ECP, @pts = PTS, @ptr = PTR, @comp_price = Company_Price          
from items it, itemcategories ic           
where it.categoryid = ic.categoryid and it.product_code = @productcode           
--tax suffered percentage        
  
DECLARE combo_components CURSOR KEYSET FOR                    
select it.product_code, it.sale_price, it.sale_tax, cc.quantity ,it.taxsuffered           
from items it, combo_components cc, Items ComboItem            
where it.product_code = cc.component_item_code and    
      cc.free = 0 and cc.combo_item_code = @productcode and  
   ComboItem.ComboId = cc.ComboId and
   ComboItem.Product_Code = cc.combo_item_code
  
OPEN combo_components             
FETCH FROM combo_components INTO @prodcode,@sale_price,@sale_tax,@quantity,@taxsuffered            
WHILE @@FETCH_STATUS = 0                    
BEGIN                     
 select @salepercen = percentage,@salepercen1 = cst_percentage from tax where tax_code = @sale_tax            
 select @sufpercen = percentage,@sufpercen1 = cst_percentage from tax where tax_code = @taxsuffered            
  set @salper = @salper + ((@quantity * @sale_price) * @salepercen)            
  set @salper1 = @salper1 + ((@quantity * @sale_price) * @salepercen1)         
  set @total =  @total + (@quantity * @sale_price)              
  set @sufper = @sufper + ((@quantity * @sale_price) * @sufpercen)            
  set @sufper1 = @sufper1 + ((@quantity * @sale_price) * @sufpercen1)            
  set @total1 =  @total1 + (@quantity * @sale_price)                
 FETCH FROM combo_components INTO @prodcode,@sale_price,@sale_tax,@quantity,@taxsuffered        
END            
 set @totsalper = @salper/@total        
 set @totsalper1 = @salper1/@total        
 set @totsufper = @sufper/@total        
 set @totsufper1 = @sufper1/@total        
 select 'ProductName'=@prname, 'Sale_Price'= @total ,'Percentage'=@totsalper ,'Price_Option'=@price_option ,'Track_Batches'=@Track_Batches ,'Sale_tax'=@salestax ,'Track_Inventory'=@Track_Inventory ,'ECP'=@ecp,'PTS'=@pts ,'PTR'=@ptr  ,'Company_Price'=    
   
   
 @comp_price ,CAST(ISNULL(@totsalper, 0) as nvarchar) + '+' + CAST(ISNULL(@totsalper1, 0) as nvarchar),        
 CAST(ISNULL(@totsufper, 0) as nvarchar) + '+' + CAST(ISNULL(@totsufper1, 0) as nvarchar)        
 CLOSE combo_components            
 DEALLOCATE combo_components                 
END
