CREATE Procedure sp_get_VanSchemeID
                 (@ItemCode as nvarchar (15),
                  @Serverdate as DATETIME,
                  @QUANTItY as Decimal(18,6),
	  	  @Value as Decimal(18,6) = 0)
AS

DECLARE @UOM1_CONVERSION as Decimal(18,6)   
DECLARE @UOM2_CONVERSION as Decimal(18,6)  
SELECT @UOM1_CONVERSION = IsNull(UOM1_Conversion,1), @UOM2_CONVERSION = IsNull(UOM2_Conversion,1) From Items Where Product_code = @ItemCode

IF (Select count(*) from ItemSchemes i,Schemes s where Active=1 and 
    @Serverdate between ValidFrom and ValidTo and 
    (SchemeType in (17,18,83,84)) and 
    i.Product_Code=@ItemCode and i.SchemeID=s.SchemeID and 
    (
    (
    (Select count(*) from schemeItems where SchemeItems.SchemeID = i.SchemeID and
      (  
       (@Quantity between   
       (Case IsNull(SchemeItems.PrimaryUOM,0)   
       When 0 then SchemeItems.StartValue   
       When 1 then SchemeItems.StartValue * @UOM1_CONVERSION  
       When 2 then SchemeItems.StartValue * @UOM2_CONVERSION End) and   
       (Case IsNull(SchemeItems.PrimaryUOM,0)   
       When 0 then SchemeItems.EndValue   
       When 1 then SchemeItems.EndValue * @UOM1_CONVERSION  
       When 2 then SchemeItems.EndValue * @UOM2_CONVERSION End)    
     and ISNULL(s.HasSlabs, 0) = 1  
       )  
          Or   
    (ISNULL(s.HasSlabs, 0) = 0 and   
   @Quantity >= (Case IsNull(SchemeItems.PrimaryUOM,0)   
    When 0 Then SchemeItems.StartValue   
    When 1 Then SchemeItems.StartValue * @UOM1_CONVERSION  
    When 2 Then SchemeItems.StartValue * @UOM2_CONVERSION End)        
       )   
      )  
      ) > 0               
	and s.SchemeType between 17 and 18) 
	or  
	((Select count(*) from schemeItems where SchemeItems.SchemeID = i.SchemeID and                      
           ((@Value between SchemeItems.StartValue and SchemeItems.EndValue and ISNULL(s.HasSlabs, 0) = 1)   
           or (ISNULL(s.HasSlabs, 0) = 0 and @Value >= SchemeItems.StartValue))) > 0               
           and s.SchemeType between 83 and 84)
	)
	) = 1
BEGIN
    SELECT 0
END
ELSE
BEGIN
    SELECT 1
END
Select i.SchemeID,s.SchemeName,s.SchemeType,s.PromptOnly,s.Message from 
ItemSchemes i,Schemes s where Active=1 and 
@Serverdate between ValidFrom and ValidTo and 
(SchemeType in (17,18,83,84)) and 
i.Product_Code=@ItemCode and i.SchemeID=s.SchemeID and 
(((Select count(*) from schemeItems where SchemeItems.SchemeID = i.SchemeID and 
      (  
       (@Quantity between   
       (Case IsNull(SchemeItems.PrimaryUOM,0)   
       When 0 then SchemeItems.StartValue   
       When 1 then SchemeItems.StartValue * @UOM1_CONVERSION  
       When 2 then SchemeItems.StartValue * @UOM2_CONVERSION End) and   
       (Case IsNull(SchemeItems.PrimaryUOM,0)   
       When 0 then SchemeItems.EndValue   
       When 1 then SchemeItems.EndValue * @UOM1_CONVERSION  
       When 2 then SchemeItems.EndValue * @UOM2_CONVERSION End)    
     and ISNULL(s.HasSlabs, 0) = 1  
       )  
          Or   
    (ISNULL(s.HasSlabs, 0) = 0 and   
   @Quantity >= (Case IsNull(SchemeItems.PrimaryUOM,0)   
    When 0 Then SchemeItems.StartValue   
    When 1 Then SchemeItems.StartValue * @UOM1_CONVERSION  
    When 2 Then SchemeItems.StartValue * @UOM2_CONVERSION End)        
       )   
      )  
      ) > 0               
and s.SchemeType between 17 and 18)
	or  
	((Select count(*) from schemeItems where SchemeItems.SchemeID = i.SchemeID and                      
           ((@Value between SchemeItems.StartValue and SchemeItems.EndValue and ISNULL(s.HasSlabs, 0) = 1)   
           or (ISNULL(s.HasSlabs, 0) = 0 and @Value >= SchemeItems.StartValue))) > 0               
           and s.SchemeType between 83 and 84))
