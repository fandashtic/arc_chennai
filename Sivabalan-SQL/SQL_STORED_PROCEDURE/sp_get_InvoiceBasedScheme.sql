CREATE Procedure sp_get_InvoiceBasedScheme                              
( @Serverdate as DATETIME,                              
 @VALUE as Decimal(18,6),                              
 @INVOICE_FROM_DISPATCH int,                              
 @CustomerID nvarchar(30) = N'',                              
 @Additional_No_of_Days as int = 0,                            
 @DirectInvoice as int = 0  ,          -- 2 for new scheme handled trade invoice
 @PaymentMode as int  =NULL,
 @PayModeAP as int = 0 -- Payment Mode Not Applicable 0 and Applicable =1    
)                              
AS               
BEGIN            
             
DECLARE @FirstDay Int             
Declare @HappySchemeDate as DATETIME              
SET @FirstDay = @@DATEFIRST                
SET @HappySchemeDate = GetDate()             
SET DATEFIRST 7                    
IF @INVOICE_FROM_DISPATCH = 1                              
BEGIN                               
 Select distinct Schemes.SchemeID,SchemeName,SchemeType,PromptOnly,Message from Schemes,SchemeItems where Active=1                              
 and (Isnull(Schemes.Customer,0) = 0 or @CustomerId = N''                               
 or Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and schemes.schemeid = schemecustomers.schemeid) ,0) > 0)                               
 and @Serverdate between ValidFrom and Dateadd(d, @Additional_No_of_Days, ValidTo) and schemeType in (1,2) and @VALUE between SchemeItems.StartValue and SchemeItems.EndValue and Schemes.SchemeID=SchemeItems.SchemeID                              
 and(Schemes.PaymentMode =N'' or dbo.Fn_IsPaymentMode_In_Scheme(@PaymentMode,Schemes.SchemeID) =1 OR @PaymentMode=NULL)          
END                              
ELSE                              
BEGIN                              
 If @DirectInvoice = 1             
  --New Schemes are not handled for direct invoice            
 Begin            
    Select distinct Schemes.SchemeID,SchemeName,SchemeType,PromptOnly,Message,isnull(SchemeItems.FreeValue,0),              
    FromItem, ToItem, isnull(Product_Code,N'') as ItemCode                        
    From Schemes  inner join SchemeItems on Schemes.SchemeID=SchemeItems.SchemeID  left join ItemSchemes on Schemes.SchemeID = ItemSchemes.SchemeID                     
    Where Active=1                              
    and (Isnull(Schemes.Customer,0) = 0 or @CustomerId = N''                               
    or Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and Schemes.schemeid = schemecustomers.schemeid) ,0) > 0)                               
    and(isnull(Schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(@PaymentMode,Schemes.SchemeID) =1 Or @PaymentMode=NULL Or @PayModeAP = 0)          
    and @Serverdate between ValidFrom and Dateadd(d, @Additional_No_of_Days, ValidTo)                         
	  and ((IsNull(HasSlabs,0) = 0 and @VALUE >=SchemeItems.StartValue) or (IsNull(HasSlabs,0) = 1 and @VALUE between SchemeItems.StartValue and SchemeItems.EndValue))
--    and @VALUE between SchemeItems.StartValue and SchemeItems.EndValue                             
    and schemeType in (1,2,3)             
    and (Isnull(HappyScheme,0)=0 or (Isnull(HappyScheme,0)=1                  
    and ((CONVERT(nvarchar,ToHour,108)= N'00:00:00' or CONVERT(nvarchar,@HappySchemeDate,108) between CONVERT(nvarchar,FromHour,108) and CONVERT(nvarchar,ToHour,108))                
    and (ToDayMonth = 0 or DAY(@HappySchemeDate) between FromDayMonth and ToDayMonth)                  
    and (ToWeekDay = -1 or ((DATEPART(DW,@HappySchemeDate)-1) between               
    FromWeekDay and (Case when FromWeekDay > ToWeekDay then 6 else ToWeekDay end))               
    or((DATEPART(DW,@HappySchemeDate)-1) between               
    (Case When FromWeekDay > ToWeekDay then 0 else FromWeekDay end) and ToWeekDay)))))                  
 End 
 Else if @DirectInvoice = 2   --new schemes are handled for trade invoice
  Begin
   Select distinct Schemes.SchemeID,SchemeName,SchemeType,PromptOnly,Message,isnull(SchemeItems.FreeValue,0),              
   FromItem, ToItem, isnull(Product_Code,N'') as ItemCode                        
   From Schemes inner join SchemeItems on Schemes.SchemeID=SchemeItems.SchemeID  left join ItemSchemes on Schemes.SchemeID = ItemSchemes.SchemeID                
   Where Active=1                              
   and (Isnull(Schemes.Customer,0) = 0 or @CustomerId = N''                               
   or Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and schemes.schemeid = schemecustomers.schemeid) ,0) > 0)                           
   and(Schemes.PaymentMode =N'' or dbo.Fn_IsPaymentMode_In_Scheme(@PaymentMode,Schemes.SchemeID) =1 OR @PaymentMode=NULL Or @PayModeAP = 0)          
   and @Serverdate between ValidFrom and Dateadd(d, @Additional_No_of_Days, ValidTo)                         
   and ((IsNull(HasSlabs,0) = 0 and @VALUE >=SchemeItems.StartValue) or (IsNull(HasSlabs,0) = 1 and @VALUE between SchemeItems.StartValue and SchemeItems.EndValue))
--   and @VALUE between SchemeItems.StartValue and SchemeItems.EndValue                             
   and (schemeType in (1,2,3,4) or (schemeType in (97,98,99,100) and Schemes.SchemeID = ItemSchemes.SchemeID))                        
   and (Isnull(HappyScheme,0)=0 or (Isnull(HappyScheme,0)=1                  
   and ((CONVERT(nvarchar,ToHour,108)= N'00:00:00' or CONVERT(nvarchar,@HappySchemeDate,108) between CONVERT(nvarchar,FromHour,108) and CONVERT(nvarchar,ToHour,108))                
   and (ToDayMonth = 0 or DAY(@HappySchemeDate) between FromDayMonth and ToDayMonth)                  
   and (ToWeekDay = -1 or ((DATEPART(DW,@HappySchemeDate)-1) between               
   FromWeekDay and (Case when FromWeekDay > ToWeekDay then 6 else ToWeekDay end))               
   or((DATEPART(DW,@HappySchemeDate)-1) between               
   (Case When FromWeekDay > ToWeekDay then 0 else FromWeekDay end) and ToWeekDay)))))                  
  End
 Else
 Begin            
   Select distinct Schemes.SchemeID,SchemeName,SchemeType,PromptOnly,Message,isnull(SchemeItems.FreeValue,0),              
   FromItem, ToItem, isnull(Product_Code,N'') as ItemCode                        
   From Schemes inner join SchemeItems on Schemes.SchemeID=SchemeItems.SchemeID  left join ItemSchemes on Schemes.SchemeID = ItemSchemes.SchemeID                
   Where Active=1                              
   and (Isnull(Schemes.Customer,0) = 0 or @CustomerId = N''                               
   or Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and schemes.schemeid = schemecustomers.schemeid) ,0) > 0)                           
   and(Schemes.PaymentMode =N'' or dbo.Fn_IsPaymentMode_In_Scheme(@PaymentMode,Schemes.SchemeID) =1 OR @PaymentMode=NULL Or @PayModeAP = 0)          
   and @Serverdate between ValidFrom and Dateadd(d, @Additional_No_of_Days, ValidTo)                         
   and ((IsNull(HasSlabs,0) = 0 and @VALUE >=SchemeItems.StartValue) or (IsNull(HasSlabs,0) = 1 and @VALUE between SchemeItems.StartValue and SchemeItems.EndValue))
--   and @VALUE between SchemeItems.StartValue and SchemeItems.EndValue                             
   and (schemeType in (1,2,3,4) or (schemeType in (97,98,99,100) and Schemes.SchemeID = ItemSchemes.SchemeID))                        
   and (Isnull(HappyScheme,0)=0 or (Isnull(HappyScheme,0)=1                  
   and ((CONVERT(nvarchar,ToHour,108)= N'00:00:00' or CONVERT(nvarchar,@HappySchemeDate,108) between CONVERT(nvarchar,FromHour,108) and CONVERT(nvarchar,ToHour,108))                
   and (ToDayMonth = 0 or DAY(@HappySchemeDate) between FromDayMonth and ToDayMonth)                  
   and (ToWeekDay = -1 or ((DATEPART(DW,@HappySchemeDate)-1) between               
   FromWeekDay and (Case when FromWeekDay > ToWeekDay then 6 else ToWeekDay end))               
   or((DATEPART(DW,@HappySchemeDate)-1) between               
   (Case When FromWeekDay > ToWeekDay then 0 else FromWeekDay end) and ToWeekDay)))))                  
 End            
END                   
 SET DATEFIRST @FirstDay            
END
