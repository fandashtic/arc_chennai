CREATE Procedure sp_get_SchemeItemsDetail_MUOM(@SchemeID as INT, @ItemCode as nvarchar(30))      
As      
Declare @UOM1_CONV as Decimal(18,6)       
Declare @UOM2_CONV as Decimal(18,6)       
DECLARE @SEHEMETYPE as Int  
Select @SEHEMETYPE = SchemeType From Schemes Where SchemeID = @SchemeID  
Select @UOM1_CONV = UOM1_Conversion,  @UOM2_CONV = UOM2_Conversion From Items Where Product_code = @ItemCode      
IF @SEHEMETYPE = 17 OR  @SEHEMETYPE = 83
  Begin   
  Select SchemeID,         
  (Case IsNull(PrimaryUOM,0)         
  When 0 then StartValue         
  When 1 then StartValue * @UOM1_CONV      
  When 2 then StartValue * @UOM2_CONV End ) StartValue,         
  (Case IsNull(PrimaryUOM,0)         
  When 0 then EndValue         
  When 1 then EndValue * @UOM1_CONV        
  When 2 then EndValue * @UOM2_CONV End ) EndValue,         
  (Case IsNull(FreeUOM,0)         
  When 0 then FreeValue         
  When 1 then FreeValue * IsNull((Select IsNull(Uom1_conversion,1) From Items Where Product_code = @ItemCode),1)        
  When 2 then FreeValue * IsNull((Select IsNull(Uom2_conversion,1) From Items Where Product_code = @ItemCode),1) End ) FreeValue,         
  FreeItem, CreationDate, ModifiedDate, FromItem, ToItem, PrimaryUOM, FreeUOM From SchemeItems SI Where SchemeID = @SchemeID        
  End   
ELSE  
  Begin   
  Select SchemeID,         
  (Case IsNull(PrimaryUOM,0)         
  When 0 then StartValue         
  When 1 then StartValue * @UOM1_CONV      
  When 2 then StartValue * @UOM2_CONV End ) StartValue,         
  (Case IsNull(PrimaryUOM,0)         
  When 0 then EndValue         
  When 1 then EndValue * @UOM1_CONV        
  When 2 then EndValue * @UOM2_CONV End ) EndValue,         
  (Case IsNull(FreeUOM,0)         
  When 0 then FreeValue         
  When 1 then FreeValue * IsNull((Select IsNull(Uom1_conversion,1) From Items Where Product_code = IsNull(SI.FreeItem,'')),1)        
  When 2 then FreeValue * IsNull((Select IsNull(Uom2_conversion,1) From Items Where Product_code = IsNull(SI.FreeItem,'')),1) End ) FreeValue,         
  FreeItem, CreationDate, ModifiedDate, FromItem, ToItem, PrimaryUOM, FreeUOM From SchemeItems SI Where SchemeID = @SchemeID        
  End      


