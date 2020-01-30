CREATE Procedure sp_Save_schemes_rec (                              
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
     @ToDayMonth Integer=0,  
     @Applyon int =0,                       
     @PaymentMode nVarchar(255)=N'')                                           
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
	 ToDayMonth = @ToDayMonth,                
     Applyon = @Applyon,  
     PaymentMode=@PaymentMode                         
     where SchemeName = @SchemeName                               
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
     ToDayMonth,  
     Applyon,  
     PaymentMode )                               
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
     @ToDayMonth,  
     @ApplyOn,  
     @PaymentMode)                              
end                              
                  
-- to remove the existing entry in itemschemes and insert the new entries                        
delete itemschemes where schemeid = (select schemeid from schemes where schemename like @SchemeName)                        
insert into itemschemes select "ID" = (select schemes.schemeid from schemes where schemename like @SchemeName),                  
Items.Product_code from itemschemes_rec, Items where itemschemes_rec.schemeid = (select schemeid from schemes_rec where schemename like @SchemeName)                 
and Items.Alias = itemschemes_rec.Product_Code              
-- insert into itemschemes select "ID" = (select schemes.schemeid from schemes where schemename like @SchemeName),          
-- Product_code from itemschemes_rec where itemschemes_rec.schemeid = (select schemeid from schemes_rec where schemename like @SchemeName)         
        
              
-- to remove the existing entry in schemeitems and insert the new entries                        
delete schemeitems where schemeid = (select schemeid from schemes where schemename like @SchemeName)                        
insert into schemeitems(SchemeID,StartValue,EndValue,FreeValue,FreeItem,CreationDate,ModifiedDate,FromItem,ToItem)
select  "ID" = (select schemes.schemeid from schemes where schemename like @SchemeName),                  
startvalue,endvalue,freevalue,
"freeitem" = Case               
When Not Exists(Select Alias from Items Where Alias = schemeitems_rec.freeItem) Then              
N'' Else (Select Product_Code from Items Where Alias = schemeitems_rec.freeItem) End,  
schemeitems_rec.creationdate,schemeitems_rec.modifieddate,                
schemeitems_rec.FromItem, schemeitems_rec.ToItem                
from schemeitems_rec where schemeitems_rec.schemeid = (select schemeid from schemes_rec where schemename like @SchemeName)

-- insert into schemeitems select "ID" = (select schemes.schemeid from schemes where schemename like @SchemeName),                  
-- startvalue,endvalue,freevalue,freeItem,schemeitems_rec.creationdate,schemeitems_rec.modifieddate,                
-- schemeitems_rec.FromItem, schemeitems_rec.ToItem                
-- from schemeitems_rec where schemeitems_rec.schemeid = (select schemeid from schemes_rec where schemename like @SchemeName)                 
             
-- to remove the existing entry in schemecustomers and insert the new entries                        
delete schemecustomers where schemeid = (select schemeid from schemes where schemename like @SchemeName)                        
insert into schemecustomers (SchemeID, CustomerId, AllotedAmount) select "ID" = (select schemes.schemeid from schemes where schemename like @SchemeName),                  
Customer.CustomerID, AllotedAmount from schemecustomers_rec, Customer where schemecustomers_rec.schemeid = (select schemeid from schemes_rec where schemename like @SchemeName)                 
And schemecustomers_rec.CustomerID = Case When IsNull(Customer.AlternateCode,N'') = N'' Then Customer.CustomerId                
Else Customer.AlternateCode End    
  
-- If the Special Category Name already exists it wont be updated otherwise   
-- Special Category abstract & detail info would be inserted for the received scheme  
  
  
If Not exists (select special_category.Special_Cat_code from Special_category, Special_Category_Rec  
        where Special_Category.[Description] = Special_Category_Rec.[Description]  
               and Special_Category_Rec.schemeID =   
              (select schemes_rec.schemeid from schemes_rec where schemename like @SchemeName  
        and schemes_rec.Flag = 1))   
Begin  
-- Inserting Special Category abstract   
insert into Special_Category (SchemeID,CategoryType,[Description])    
select schemes.SchemeID, special_Category_Rec.CategoryType,special_Category_Rec.[Description]  
from special_Category_Rec,Schemes where Special_Category_Rec.schemeID =   
(select schemes_rec.schemeid from schemes_rec where schemename like @SchemeName  
and schemes_rec.Flag = 1)  
and Schemes.schemename like @SchemeName  
and Schemes.schemeType = @SchemeType    
  
-- Inserting Special Category detail for item based special Cat  
insert into Special_Cat_Product (Special_Cat_Code,Product_Code,CategoryID,HierarchyID)   
select special_Category.Special_Cat_code, Items.Product_code,  
Items.CategoryID,NULL   
from special_Cat_Product_Rec,  special_Category, Items, Special_Category_Rec, Schemes_Rec  
where special_Category_Rec.Special_Cat_Code = special_Cat_Product_Rec.Special_Cat_Code  
and Special_Category.[Description] = Special_Category_Rec.[Description]  
and special_Cat_Product_Rec.Product_Code = Items.Alias 
and Special_Category_Rec.SchemeID = Schemes_Rec.SchemeID  
and Schemes_Rec.schemename like @SchemeName   
and special_Category_Rec.CategoryType = 1 -- to get item based special cat  
and Schemes_Rec.Flag = 1  -- to check the scheme is unprocessed  
  
  
-- Inserting Special Category detail for item based special Cat  
insert into Special_Cat_Product (Special_Cat_Code,Product_Code,CategoryID,HierarchyID)    
select special_Category.Special_Cat_code,'',    
ItemCategories.CategoryID, ItemCategories.CategoryID   
from special_Category,Special_Category_Rec,Schemes_Rec,  
special_Cat_Product_Rec, ItemCategories,ItemHierarchy  
where special_Category_Rec.Special_Cat_Code = special_Cat_Product_Rec.Special_Cat_Code  
and Special_Category.[Description] = Special_Category_Rec.[Description]  
and special_Cat_Product_Rec.CategoryName = ItemCategories.Category_Name  
and special_Cat_Product_Rec.HierarchyName = Itemhierarchy.HierarchyName  
and Special_Category_Rec.SchemeID = Schemes_Rec.SchemeID  
and Schemes_Rec.schemename like @SchemeName  
and special_Category_Rec.CategoryType = 2  
and Schemes_Rec.Flag = 1  
End  
  
Else  
  
Begin  
 -- If the received special category exists and not mapped to a scheme then mapping to the received scheme  
  
 Create table #temp(SplCatCode int)  
  
 insert into #temp  
 select Special_category.Special_Cat_Code from Special_category, Special_Category_Rec  
        where Special_Category.[Description] = Special_Category_Rec.[Description]  
 and Special_Category.schemeID = 0  
        and Special_Category_Rec.schemeID =   
        (select schemes_rec.schemeid from schemes_rec where schemename like @SchemeName  
 and schemes_rec.Flag = 1)  
   
 Update Special_Category set Special_Category.SchemeID = (select schemes.schemeID from schemes where schemename  
        like @SchemeName)  
 where Special_cat_Code in (select #temp.SplCatCode from #temp)  
    Drop table #temp  
End  
            
update schemes_rec set flag = 0 where schemename = @SchemeName                            
                

