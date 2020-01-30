CREATE procedure sp_update_ComboComponents (@Combo_Item_code nvarchar(15),            
@Component_item_code nvarchar(15),            
@Quantity Decimal(18,6),            
@Free Decimal(18,6),            
@PTS Decimal(18,6),            
@PTR Decimal(18,6),            
@SP_PRICE Decimal(18,6),            
@ECP Decimal(18,6),        
@ComboID int,        
@TaxSuffered Decimal(18,6),  
@CreationDate datetime                
)            
as            
-- Declare @CreationDate datetime          
-- select @CreationDate = CreationDate from Combo_Components where Combo_Item_code = @Combo_Item_code          
-- Delete from Combo_Components where Combo_Item_code = @Combo_Item_code and ComboId = @ComboID        
          
Insert into Combo_Components (ComboID,        
Combo_Item_code ,            
Component_item_code,            
Quantity ,            
[Free],            
PTS ,            
PTR ,            
ECP ,            
SpecialPrice ,         
TaxSuffered,        
CreationDate,            
ModifiedDate)            
Values            
(@ComboID,@Combo_Item_code,@Component_item_code,@Quantity,@Free,@PTS,@PTR,@ECP,@SP_PRICE,@TaxSuffered,@CreationDate,getdate())                  


