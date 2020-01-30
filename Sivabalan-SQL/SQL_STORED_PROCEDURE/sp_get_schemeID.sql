Create Procedure sp_get_schemeID                        
(@ItemCode as nvarchar (30),                        
 @Serverdate as DATETIME,                        
 @QUANTITY as Decimal(18,6),                      
 @CustomerId as nvarchar(30)=N'',                      
 @SchemeTypes as nvarchar(100)=N'',                  
 @Additional_No_of_Days as int = 0,              
 @Amount as Decimal(18,6)=0,      
 @PaymentMode as int=NULL,  
 @PayModeAP as int = 0 -- Payment Mode Not Applicable 0 and Applicable =1
)                          
AS                        
BEGIN         
 DECLARE @FirstDay Int        
 Declare @HappySchemeDate as DATETIME        
 SET @FirstDay = @@DATEFIRST          
 SET @HappySchemeDate = GetDate()        
 SET DATEFIRST 7        
 create table #Temp (SchemeID int)                               
 If @SchemeTypes <> N''                      
 Exec (N'Insert Into #Temp select SchemeID From schemes Where SchemeType IN (' + @SchemeTypes + ')')                          
                      
  IF (Select count(*) from ItemSchemes i,Schemes s               
  where Active=1 and @Serverdate between ValidFrom and Dateadd(d, @Additional_No_of_Days, ValidTo)               
  and i.Product_Code=@ItemCode and i.SchemeID=s.SchemeID                        
  and (s.schemeID In (Select SchemeID From #Temp) Or (Select Count(*) From #Temp) = 0)                      
  and (Isnull(s.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(@PaymentMode,s.SchemeID)=1 or  @PaymentMode=NULL Or @PayModeAP = 0)     
  and (Isnull(s.Customer,0) = 0 or @CustomerId = N'' or                       
  Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and s.schemeid = schemecustomers.schemeid) ,0) > 0)                
  and (((Select count(*) from schemeItems where SchemeItems.SchemeID = i.SchemeID and                        
  ((@Quantity between SchemeItems.StartValue and SchemeItems.EndValue and ISNULL(s.HasSlabs, 0) = 1) or (ISNULL(s.HasSlabs, 0) = 0 and @Quantity >= SchemeItems.StartValue))) > 0                 
  and s.SchemeType between 17 and 20)              
  or ((Select count(*) from schemeItems where SchemeItems.SchemeID = i.SchemeID and                        
  ((@Amount between SchemeItems.StartValue and SchemeItems.EndValue and ISNULL(s.HasSlabs, 0) = 1) or (ISNULL(s.HasSlabs, 0) = 0 and @Amount >= SchemeItems.StartValue))) > 0                 
  and s.SchemeType between 81 and 84))          
  and (Isnull(HappyScheme,0)=0 or (Isnull(HappyScheme,0)=1             
  and ((CONVERT(nvarchar,ToHour,108)= N'00:00:00' or CONVERT(nvarchar,@HappySchemeDate,108) between CONVERT(nvarchar,FromHour,108) and CONVERT(nvarchar,ToHour,108))            
  and (ToDayMonth = 0 or DAY(@HappySchemeDate) between FromDayMonth and ToDayMonth)            
  and (ToWeekDay = -1 or (((DATEPART(DW,@HappySchemeDate)-1) between         
  FromWeekDay and (Case when FromWeekDay > ToWeekDay then 6 else ToWeekDay end))         
  or ((DATEPART(DW,@HappySchemeDate)-1) between         
  (Case When FromWeekDay > ToWeekDay then 0 else FromWeekDay end) and ToWeekDay))))))) = 1                
  BEGIN                        
     SELECT 0                        
  END                        
 ELSE                        
  BEGIN                        
      SELECT 1                        
  END                        
  Select i.SchemeID,s.SchemeName,s.SchemeType,s.PromptOnly,s.Message                         
  from ItemSchemes i,Schemes s                         
  where Active=1 and @Serverdate between ValidFrom and Dateadd(d, @Additional_No_of_Days, ValidTo)               
  and i.Product_Code=@ItemCode and i.SchemeID=s.SchemeID                        
  and (s.schemeID In (Select SchemeID From #Temp) Or (Select Count(*) From #Temp) = 0)      
  and (Isnull(s.PaymentMode,N'')=N'' or  dbo.Fn_IsPaymentMode_In_Scheme(@PaymentMode,s.SchemeID)=1   OR  @PaymentMode=NULL Or @PayModeAP = 0)                   
  and (Isnull(s.Customer,0) = 0 or @CustomerId = N'' or                       
  Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and s.schemeid = schemecustomers.schemeid) ,0) > 0)                
  and (((Select count(*) from schemeItems where SchemeItems.SchemeID = i.SchemeID and                        
  ((@Quantity between SchemeItems.StartValue and SchemeItems.EndValue and ISNULL(s.HasSlabs, 0) = 1) or (ISNULL(s.HasSlabs, 0) = 0 and @Quantity >= SchemeItems.StartValue))) > 0                 
  and s.SchemeType between 17 and 20)              
  or ((Select count(*) from schemeItems where SchemeItems.SchemeID = i.SchemeID and                        
  ((@Amount between SchemeItems.StartValue and SchemeItems.EndValue and ISNULL(s.HasSlabs, 0) = 1) or (ISNULL(s.HasSlabs, 0) = 0 and @Amount >= SchemeItems.StartValue))) > 0                 
  and s.SchemeType between 81 and 84))                
  and (Isnull(HappyScheme,0)=0 or (Isnull(HappyScheme,0)=1             
  and ((CONVERT(nvarchar,ToHour,108)= N'00:00:00' or CONVERT(nvarchar,@HappySchemeDate,108) between CONVERT(nvarchar,FromHour,108) and CONVERT(nvarchar,ToHour,108))            
  and (ToDayMonth = 0 or DAY(@HappySchemeDate) between FromDayMonth and ToDayMonth)            
  and (ToWeekDay = -1 or (((DATEPART(DW,@HappySchemeDate)-1) between         
  FromWeekDay and (Case when FromWeekDay > ToWeekDay then 6 else ToWeekDay end))         
  or ((DATEPART(DW,@HappySchemeDate)-1) between         
  (Case When FromWeekDay > ToWeekDay then 0 else FromWeekDay end) and ToWeekDay))))))                         
  drop table #temp           
  SET DATEFIRST @FirstDay          
END    


