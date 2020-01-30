CREATE PROCEDURE sp_define_alternateunits(@ITEMCODE nvarchar(15),    
       @UOM1 int,    
       @UOM2 int,    
       @UOMCONV1 Decimal(18,6),    
       @UOMCONV2 Decimal(18,6),    
       @DEFAULT int,
       @PriceAtUOMLevel int=0)    
AS    
Update  Items Set UOM1 = @UOM1, UOM2 = @UOM2, UOM1_Conversion = @UOMCONV1,     
 	UOM2_Conversion = @UOMCONV2, DefaultUOM = @DEFAULT,
 	PriceAtUOMLevel = @PriceAtUOMLevel   
Where Product_Code = @ITEMCODE    

