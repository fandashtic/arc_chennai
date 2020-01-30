CREATE Procedure sp_Save_GRN_Combo_Components (           
@ComboID Integer,        
@GRNComboID integer,                
@GRNID nvarchar(50),              
@Combo_Item_Code nvarchar(50),              
@Component_Item_Code nvarchar(50),               
@ComboPackQty Decimal(18,6),
@Received_Quantity Decimal(18,6),          
@FreeQuantity Int,          
@PTS Decimal(18,6),          
@PTR Decimal(18,6),          
@ECP Decimal(18,6),          
@Spl_Price Decimal(18,6),          
@Date DateTime)     
          
As          
Declare @PurchasedAt int          
Declare @PurchasePrice Decimal(18,6)          
          
Set @PurchasedAt = (Select Purchased_At from Items Where product_code = @Combo_Item_Code)          
          
if @PurchasedAt = 1           
Begin          
Set @PurchasePrice = @PTS          
End          
Else          
Begin          
Set @PurchasePrice = @PTR          
End          
        
    
--Set @ComboID = (Select IsNull(Max(Combo_Components.ComboID),0) + 1 from Combo_Components)    
--Set @GRNComboID = (Select IsNull(Max(GRN_Combo_Components.ComboID),0) + 1 from GRN_Combo_Components)      
    
Insert into Combo_Components(ComboID, Combo_Item_Code, Component_Item_Code, Quantity, [Free],   
PTS, PTR, ECP, SpecialPrice, TaxSuffered, CreationDate, ModifiedDate) Values (@ComboID, @Combo_Item_Code, @Component_Item_Code,@Received_Quantity, @FreeQuantity,          
@PTS, @PTR, @ECP, @Spl_Price,0, @Date, @Date)          
          
Insert into GRN_Combo_Components(ComboID, GRNID, Combo_Item_Code, Component_Item_Code, Received_Quantity, PurchasePrice,  
PTS, PTR, ECP, SpecialPrice) Values (@GRNComboID, @GRNID, @Combo_Item_Code, @Component_Item_Code, @ComboPackQty * @Received_Quantity,         
@PurchasePrice, @PTS, @PTR, @ECP, @Spl_Price)      

