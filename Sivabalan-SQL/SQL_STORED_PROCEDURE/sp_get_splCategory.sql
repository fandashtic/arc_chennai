CREATE Procedure sp_get_splCategory            
( @SERVERDATE as DATETIME, @CustomerID nvarchar(30) = N'',            
  @Additional_No_of_Days as int = 0  , @ParentForm int = 1, -- 3 for new scheme handled for trade invoice
  @PaymentMode as int=NULL,
  @PayModeAP as int = 0 -- Payment Mode Not Applicable 0 and Applicable =1        
)            
As        
--While handling new schemes for dir inv pls remove this version.        
BEGIN            
 DECLARE @FirstDay Int        
 SET @FirstDay = @@DATEFIRST          
 SET DATEFIRST 7        
 If @ParentForm = 1        
  Begin
    Select Special_Cat_Code,CategoryType,Description,Special_Category.SchemeID,Schemes.SchemeName,Schemes.SchemeType,Schemes.Promptonly,Schemes.message           
    From Special_Category,Schemes           
    Where Special_Category.Active=1            
    and Schemes.Active=1 and Special_Category.schemeID<>0 and Schemes.SchemeID=Special_Category.SchemeID             
    and (Isnull(Schemes.Customer,0) = 0 or @CustomerId = N''             
    or Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and schemes.schemeid = schemecustomers.schemeid) ,0) > 0)        
    and (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(@PaymentMode,schemes.SchemeID)=1 OR @PaymentMode=NULL Or @PayModeAP=0)            
    and @SERVERDATE between Schemes.ValidFrom and Dateadd(d, @Additional_No_of_Days, Schemes.ValidTo)                
    and (Isnull(HappyScheme,0)=0 or (Isnull(HappyScheme,0)=1             
    and ( CONVERT(nvarchar,ToHour,108)=N'00:00:00' or CONVERT(nvarchar,@Serverdate,108) between CONVERT(nvarchar,FromHour,108) and CONVERT(nvarchar,ToHour,108))            
    and (ToDayMonth=0 or DAY(@Serverdate) between FromDayMonth and ToDayMonth)            
    and (ToWeekDay =-1 or (DATEPART(DW,@Serverdate)-1) between FromWeekDay and ToWeekDay)))              
   End
  Else if @ParentForm = 3    --New schemes are handled for Trade Invoice
   Begin
    Select Special_Cat_Code,CategoryType,Description,Special_Category.SchemeID,Schemes.SchemeName,Schemes.SchemeType,Schemes.Promptonly,Schemes.message           
    From Special_Category,Schemes           
    Where Special_Category.Active=1            
    and Schemes.Active=1 and Special_Category.schemeID<>0 and Schemes.SchemeID=Special_Category.SchemeID             
    and (Isnull(Schemes.Customer,0) = 0 or @CustomerId = N''             
    or Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and schemes.schemeid = schemecustomers.schemeid) ,0) > 0)        
    and (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(@PaymentMode,schemes.SchemeID)=1 OR @PaymentMode=NULL Or @PayModeAP=0)            
    and @SERVERDATE between Schemes.ValidFrom and Dateadd(d, @Additional_No_of_Days, Schemes.ValidTo)                
    and (Isnull(HappyScheme,0)=0 or (Isnull(HappyScheme,0)=1             
    and ( CONVERT(nvarchar,ToHour,108)=N'00:00:00' or CONVERT(nvarchar,@Serverdate,108) between CONVERT(nvarchar,FromHour,108) and CONVERT(nvarchar,ToHour,108))            
    and (ToDayMonth=0 or DAY(@Serverdate) between FromDayMonth and ToDayMonth)            
    and (ToWeekDay =-1 or (DATEPART(DW,@Serverdate)-1) between FromWeekDay and ToWeekDay)))              
   End
  Else        
   Begin
    Select Special_Cat_Code,CategoryType,Description,Special_Category.SchemeID,Schemes.SchemeName,Schemes.SchemeType,Schemes.Promptonly,Schemes.message           
    From Special_Category,Schemes           
    Where Special_Category.Active=1            
    and schemes.schemetype not in (21,22,81,82,83,84,97,98,99,100)        
    and Schemes.Active=1 and Special_Category.schemeID<>0 and Schemes.SchemeID=Special_Category.SchemeID             
    and (Isnull(Schemes.Customer,0) = 0 or @CustomerId = N''             
    or Isnull((Select Count(*) from SchemeCustomers Where CustomerId = @CustomerID and schemes.schemeid = schemecustomers.schemeid) ,0) > 0)             
    and (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(@PaymentMode,schemes.SchemeID)=1 OR @PaymentMode=NULL Or @PayModeAP=0)               
    and @SERVERDATE between Schemes.ValidFrom and Dateadd(d, @Additional_No_of_Days, Schemes.ValidTo)                
    and (Isnull(HappyScheme,0)=0 or (Isnull(HappyScheme,0)=1             
    and ( CONVERT(nvarchar,ToHour,108)=N'00:00:00' or CONVERT(nvarchar,@Serverdate,108) between CONVERT(nvarchar,FromHour,108) and CONVERT(nvarchar,ToHour,108))            
    and (ToDayMonth=0 or DAY(@Serverdate) between FromDayMonth and ToDayMonth)            
    and (ToWeekDay =-1 or (DATEPART(DW,@Serverdate)-1) between FromWeekDay and ToWeekDay)))              
    SET DATEFIRST @FirstDay        
   End
END
