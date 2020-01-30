CREATE procedure sp_insert_ComboComponents (@Combo_Item_code nvarchar(15),            
@Component_item_code nvarchar(15),            
@Quantity Decimal(18,6),            
@Free Decimal(18,6),            
@PTS Decimal(18,6),            
@PTR Decimal(18,6),            
@SP_PRICE Decimal(18,6),            
@ECP Decimal(18,6),        
@ComboID int,        
@TaxSuffered Decimal(18,6)           
)            
as            
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
(@ComboID,@Combo_Item_code,@Component_item_code,@Quantity,@Free,@PTS,@PTR,@ECP,@SP_PRICE,@TaxSuffered,getdate(),getdate())            
      
Update Items set ComboId = @ComboId where Product_Code = @Combo_Item_code           
         

