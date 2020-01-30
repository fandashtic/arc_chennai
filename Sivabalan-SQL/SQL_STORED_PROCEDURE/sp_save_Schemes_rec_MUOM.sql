CREATE Procedure sp_save_Schemes_rec_MUOM (                                
     @SchemeName nvarchar(250),                                            
     @SchemeType int,                                             
     @ValidFrom datetime,                                            
     @ValidTo datetime,                                            
     @PromptOnly int  ,                              
     @Message nvarchar(100),                                
     @SchemeDescription nvarchar(255) ,                                            
     @SecondaryScheme int,                                            
     @HasSlabs int,                  
     @Active int = 0,    
     @BudgetedAmount Decimal(18,6)=0,                  
     @Customer Int=0,                  
     @HappyScheme Integer=0,                  
     @FromHour DateTime=NULL,                  
     @ToHour DateTime=NULL,                  
     @FromWeekDay Integer=0,                  
     @ToWeekDay Integer=0,                  
     @FromDayMonth Integer=0,                  
     @ToDayMonth Integer=0  
     )                                             
as                                            
                          
if (select count(*) from schemes where SchemeName = @SchemeName) > 0                                 
begin                                
     update schemes  set                                      
     SchemeType = @SchemeType,                                
     ValidFrom = @ValidFrom,                                
     ValidTo = @ValidTo,                                
     PromptOnly = @PromptOnly,                              
     Message = @Message,                                
     SchemeDescription = @SchemeDescription,                                
     SecondaryScheme = @SecondaryScheme,                                
     HasSlabs = @HasSlabs,                                 
     ModifiedDate = getdate(),       
     Active = @Active,                 
     BudgetedAmount = @BudgetedAmount,                  
     Customer = @Customer,                  
     HappyScheme = @HappyScheme,                  
     FromHour = @FromHour,                  
     ToHour = @ToHour,                  
     FromWeekDay = @FromWeekDay,                  
     ToWeekDay = @ToWeekDay,                  
     FromDayMonth = @FromDayMonth,                  
     ToDayMonth = @ToDayMonth  
     where      SchemeName = @SchemeName                                 
end                                
else                                
begin                                
insert into schemes (                                
     SchemeName ,                                
     SchemeType ,                                
     ValidFrom ,                                
     ValidTo ,                                
     PromptOnly,                               
     Message ,                                
     SchemeDescription ,                                
     SecondaryScheme ,                                
     HasSlabs,        
     Active,              
     BudgetedAmount,                  
     Customer,                  
     HappyScheme,                  
     FromHour,                  
     ToHour,                  
     FromWeekDay,                  
     ToWeekDay,                  
     FromDayMonth,                  
     ToDayMonth )                                 
values(                                
     @SchemeName ,                                
     @SchemeType ,                                
     @ValidFrom ,                                
     @ValidTo ,                                
     @PromptOnly,                              
     @Message ,                                
     @SchemeDescription ,                                
     @SecondaryScheme ,                                
     @HasSlabs,                  
     @Active,    
     @BudgetedAmount,                  
     @Customer,                  
     @HappyScheme,                  
     @FromHour,                       
     @ToHour,                  
     @FromWeekDay,                  
     @ToWeekDay,                  
     @FromDayMonth,                  
     @ToDayMonth )                                
end                                
-- to remove the existing entry in itemschemes and insert the new entries                          
Delete itemschemes where schemeid = (select schemeid from schemes where schemename like @SchemeName)                          
Insert into itemschemes select "ID" = (select schemes.schemeid from schemes where schemename like @SchemeName),                    
Items.Product_code from itemschemes_rec, Items where itemschemes_rec.schemeid = (select schemeid from schemes_rec where schemename like @SchemeName)                   
and Items.Alias = itemschemes_rec.Product_Code                
-- insert into itemschemes select "ID" = (select schemes.schemeid from schemes where schemename like @SchemeName),            
-- Product_code from itemschemes_rec where itemschemes_rec.schemeid = (select schemeid from schemes_rec where schemename like @SchemeName)           
          
                
-- to remove the existing entry in schemeitems and insert the new entries                          
Delete schemeitems where schemeid = (select schemeid from schemes where schemename like @SchemeName)                          
Insert into schemeitems select "ID" = (select schemes.schemeid from schemes where schemename like @SchemeName),                    
startvalue,endvalue,freevalue,"freeitem" = Case                 
When Not Exists(Select Alias from Items Where Alias = schemeitems_rec.freeItem) Then                
N'' Else (Select Product_Code from Items Where Alias = schemeitems_rec.freeItem) End,    
schemeitems_rec.creationdate,schemeitems_rec.modifieddate,                  
schemeitems_rec.FromItem, schemeitems_rec.ToItem,  
schemeitems_rec.PrimaryUOM, schemeitems_rec.FreeUOM  
from schemeitems_rec where schemeitems_rec.schemeid = (select schemeid from schemes_rec where schemename like @SchemeName)                   
-- insert into schemeitems select "ID" = (select schemes.schemeid from schemes where schemename like @SchemeName),                    
-- startvalue,endvalue,freevalue,freeItem,schemeitems_rec.creationdate,schemeitems_rec.modifieddate,                  
-- schemeitems_rec.FromItem, schemeitems_rec.ToItem                  
-- from schemeitems_rec where schemeitems_rec.schemeid = (select schemeid from schemes_rec where schemename like @SchemeName)                   
                  
-- to remove the existing entry in schemecustomers and insert the new entries                          
Delete schemecustomers where schemeid = (select schemeid from schemes where schemename like @SchemeName)                          
Insert into schemecustomers (SchemeID, CustomerId, AllotedAmount) select "ID" = (select schemes.schemeid from schemes where schemename like @SchemeName),                    
Customer.CustomerID, AllotedAmount from schemecustomers_rec, Customer where schemecustomers_rec.schemeid = (select schemeid from schemes_rec where schemename like @SchemeName)                   
And schemecustomers_rec.CustomerID = Case When IsNull(Customer.AlternateCode,N'') = N'' Then Customer.CustomerId                  
Else Customer.AlternateCode End                  
                  
Update schemes_rec set flag = 0 where schemename = @SchemeName                              
                   
    
    
  


