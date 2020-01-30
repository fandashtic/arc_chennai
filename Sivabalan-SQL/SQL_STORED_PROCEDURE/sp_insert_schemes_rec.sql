CREATE procedure sp_insert_schemes_rec (                            
     @SchemeName nvarchar(250),                                        
     @SchemeType int,                                         
     @ValidFrom datetime,                                        
     @ValidTo datetime,                                        
     @PromptOnly int,                          
     @Message nvarchar(100),                            
     @SchemeDescription nvarchar(255) ,                                        
     @SecondaryScheme int,                                        
     @HasSlabs int,                   
     @Creationdate datetime,                    
     @modifieddate datetime,                 
     @ForumCode nvarchar(250),        
     @Active Int = 0,            
     @BudgetedAmount Decimal(18,6)=0,              
     @Customer Int=0,              
     @HappyScheme Integer=0,              
     @FromHour DateTime=NULL,              
     @ToHour DateTime=NULL,              
     @FromWeekDay Integer=0,              
     @ToWeekDay Integer=0,              
     @FromDayMonth Integer=0,              
     @ToDayMonth Integer=0,  
     @Applyon Int = 0,             
     @PaymentMode nVarchar(255)=N'')                                         
as                                        
                  
Declare @CompanyID nvarchar(100)                  
Declare @Flag int                
set @Flag = 1                  
Select @CompanyID = CustomerID from Customer where AlternateCode = @ForumCode                  
if Isnull(@CompanyID, N'') = N''                   
 Select @CompanyID = VendorID from Vendors where AlternateCode = @ForumCode                  
if Isnull(@CompanyID, N'') = N''                   
 Select @CompanyID = WareHouseID from WareHouse where ForumId = @ForumCode                  
                  
if (select count(*) from schemes_rec where SchemeName = @SchemeName And ForumCode = @ForumCode) > 0                             
begin                            
     update schemes_rec set                                  
     SchemeType = @SchemeType,                            
     ValidFrom = @ValidFrom,                            
     ValidTo = @ValidTo,                            
     PromptOnly = @PromptOnly,                          
     Message = @Message,                            
     SchemeDescription = @SchemeDescription,                            
     SecondaryScheme = @SecondaryScheme,                            
     HasSlabs = @HasSlabs ,              
     Flag = @Flag,                      
     ForumCode = @ForumCode ,                    
     CompanyID = @CompanyID,               
     Creationdate = @Creationdate ,                    
     modifieddate = @modifieddate,              
  	 Active = @Active,      
  	 BudgetedAmount = @BudgetedAmount,              
  	 Customer = @Customer,              
  	 HappyScheme = @HappyScheme,              
  	 FromHour = @FromHour,              
  	 ToHour = @ToHour,              
  	 FromWeekDay = @FromWeekDay,              
  	 ToWeekDay = @ToWeekDay,              
  	 FromDayMonth = @FromDayMonth,              
  	 ToDayMonth = @ToDayMonth,  
  	 Applyon = @Applyon,  
  	 PaymentMode=@paymentMode                             
     where  SchemeName = @SchemeName                             
select schemeid from schemes_rec where schemename = @SchemeName                      
end                            
else                            
begin                            
insert into schemes_rec (                            
     SchemeName ,                            
     SchemeType ,                            
     ValidFrom ,                            
     ValidTo ,                            
     PromptOnly ,                           
     Message ,                            
     SchemeDescription ,                            
     SecondaryScheme ,                            
     HasSlabs ,             
     Creationdate ,              
     modifieddate ,              
     CompanyID ,                    
     ForumCode,        
  	 Active,       
  	 BudgetedAmount,              
  	 Customer,              
  	 HappyScheme,              
  	 FromHour,              
   	 ToHour,              
  	 FromWeekDay,              
  	 ToWeekDay,              
  	 FromDayMonth,              
  	 ToDayMonth,  
  	 Applyon,  
     PaymentMode              
)                             
values(                            
     @SchemeName ,                            
     @SchemeType ,                            
     @ValidFrom ,                            
     @ValidTo ,             
     @PromptOnly ,                           
     @Message ,                            
     @SchemeDescription ,                            
     @SecondaryScheme ,                            
     @HasSlabs ,             
     @Creationdate ,              
     @modifieddate ,              
     @CompanyID,                   
     @ForumCode,               
  	 @Active,      
  	 @BudgetedAmount,              
  	 @Customer,              
  	 @HappyScheme,              
  	 @FromHour,              
  	 @ToHour,              
  	 @FromWeekDay,              
  	 @ToWeekDay,              
  	 @FromDayMonth,              
  	 @ToDayMonth,  
  	 @Applyon,     
  	 @PaymentMode            
)                            
select @@identity                      
end                            
  


