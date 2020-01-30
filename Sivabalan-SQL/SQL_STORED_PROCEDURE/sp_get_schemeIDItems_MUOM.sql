CREATE Procedure sp_get_schemeIDItems_MUOM            
    (@ItemCode as nvarchar (30),            
    @Serverdate as DATETIME,            
    @QUANTItY as Decimal(18,6),            
    @AMTTYPE as INT,            
    @PERTYPE as INT,            
    @CustomerId as nvarchar(30) = N'',            
    @Additional_No_of_Days as int = 0,        
    @Amount as Decimal(18,6) =0)        
AS            
DECLARE @UOM1_CONVERSION as Decimal(18,6)             
DECLARE @UOM2_CONVERSION as Decimal(18,6)            
SELECT @UOM1_CONVERSION = IsNull(UOM1_Conversion,1), @UOM2_CONVERSION = IsNull(UOM2_Conversion,1) From Items Where Product_code = @ItemCode            
IF (Select count(*) from ItemSchemes i,Schemes s             
    where Active=1 and               
    @Serverdate between ValidFrom and Dateadd(d, @Additional_No_of_Days, ValidTo) and               
    (Isnull(s.Customer,0) = 0 or @CustomerId = N'' or               
    Isnull((Select Count(*) from SchemeCustomers             
			Where CustomerId = @CustomerID and s.schemeid = schemecustomers.schemeid) ,0) > 0) and               
    (SchemeType = @AMTTYPE or schemeType= @PERTYPE or (schemeType between  81 and 82)) and               
    i.Product_Code=@ItemCode and i.SchemeID=s.SchemeID and               
	(        
		(                
			(        
			Select count(*) from schemeItems             
			where SchemeItems.SchemeID = i.SchemeID and              
            ((@Quantity between             
				(Case IsNull(SchemeItems.PrimaryUOM,0)             
				When 0 then SchemeItems.StartValue             
				When 1 then SchemeItems.StartValue * @UOM1_CONVERSION            
				When 2 then SchemeItems.StartValue * @UOM2_CONVERSION End) 
				and             
				(Case IsNull(SchemeItems.PrimaryUOM,0)             
				When 0 then SchemeItems.EndValue             
				When 1 then SchemeItems.EndValue * @UOM1_CONVERSION            
				When 2 then SchemeItems.EndValue * @UOM2_CONVERSION End)             
				and ISNULL(s.HasSlabs, 0) = 1            
             )             
             Or            
             (ISNULL(s.HasSlabs, 0) = 0 and 
			 @Quantity >= 
				(Case IsNull(SchemeItems.PrimaryUOM,0)             
				When 0 Then SchemeItems.StartValue             
				When 1 Then SchemeItems.StartValue * @UOM1_CONVERSION            
				When 2 Then SchemeItems.StartValue * @UOM2_CONVERSION End)            
             )            
            )            
            )> 0              
        and s.SchemeType between 17 and 20        
        )        
        Or         
        (        
		 (        
         Select count(*) from schemeItems         
         where SchemeItems.SchemeID = i.SchemeID and         
            (
			(@Amount between SchemeItems.StartValue and SchemeItems.EndValue and ISNULL(s.HasSlabs, 0) = 1)           
            Or (ISNULL(s.HasSlabs, 0) = 0 and @Amount >= SchemeItems.StartValue)        
            )        
         ) > 0                       
        and s.SchemeType between 81 and 84        
        )          
	)        
	) = 1              
	BEGIN              
		SELECT 0              
	END              
ELSE              
	BEGIN              
		SELECT 1              
	END              
Select i.SchemeID,s.SchemeName,s.SchemeType,s.PromptOnly,s.Message             
from ItemSchemes i,Schemes s             
where Active=1 and               
	(Isnull(s.Customer,0) = 0 or @CustomerId = N'' or               
    Isnull((Select Count(*) from SchemeCustomers             
           Where CustomerId = @CustomerID and s.schemeid = schemecustomers.schemeid) ,0) > 0) and               
	@Serverdate between ValidFrom and Dateadd(d, @Additional_No_of_Days, ValidTo) and               
	(SchemeType = @AMTTYPE or schemeType= @PERTYPE or (schemeType between  81 and 82)) and               
	i.Product_Code=@ItemCode and i.SchemeID=s.SchemeID and 
	(        
		(                
			(        
			Select count(*) from schemeItems             
			where SchemeItems.SchemeID = i.SchemeID and             
            ((@Quantity between             
				(Case IsNull(SchemeItems.PrimaryUOM,0)             
				When 0 then SchemeItems.StartValue             
				When 1 then SchemeItems.StartValue * @UOM1_CONVERSION            
				When 2 then SchemeItems.StartValue * @UOM2_CONVERSION End) 
				and             
				(Case IsNull(SchemeItems.PrimaryUOM,0)             
				When 0 then SchemeItems.EndValue             
				When 1 then SchemeItems.EndValue * @UOM1_CONVERSION            
				When 2 then SchemeItems.EndValue * @UOM2_CONVERSION End)             
			 and ISNULL(s.HasSlabs, 0) = 1            
             )             
             Or            
             (ISNULL(s.HasSlabs, 0) = 0 and            
               @Quantity >= 
				(Case IsNull(SchemeItems.PrimaryUOM,0)             
				When 0 Then SchemeItems.StartValue             
				When 1 Then SchemeItems.StartValue * @UOM1_CONVERSION            
				When 2 Then SchemeItems.StartValue * @UOM2_CONVERSION End)            
			 )            
            )            
            )> 0              
        and s.SchemeType between 17 and 20        
		)        
		Or         
		(        
			(        
            Select count(*) from schemeItems         
            where SchemeItems.SchemeID = i.SchemeID and         
				(       
				(@Amount between SchemeItems.StartValue and SchemeItems.EndValue and ISNULL(s.HasSlabs, 0) = 1)           
                or 
				(ISNULL(s.HasSlabs, 0) = 0 and @Amount >= SchemeItems.StartValue)        
                )        
			) > 0                       
        and s.SchemeType between 81 and 84        
		)          
	)        

