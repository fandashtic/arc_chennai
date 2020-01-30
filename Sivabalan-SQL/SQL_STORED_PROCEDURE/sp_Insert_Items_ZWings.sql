
CREATE procedure sp_Insert_Items_ZWings (                    
            @Product_code nvarchar(15),                
            @ProductName nvarchar(255),                
            @CategoryName nvarchar(255),                
            @CategoryColour nvarchar(255),                  
            @CategorySize nvarchar(255),                 
            @Purchase_Price Decimal(18,6),                  
            @Sale_Price Decimal(18,6),                
            @MRP Decimal(18,6),          
            @SupplierCode nvarchar(50))                
as                
 Declare @Ret int      
 Declare @Colourid int                 
 Declare @Sizeid int                
 Declare @Styleid int                
 Declare @Supplierid int                
 Declare @Categoryid int                
 Declare @ManufacturerID int                
 Declare @BrandID int                
 Declare @UOM int                
 Declare @ReportingUOM int                
 Declare @PropValue nvarchar(50)         
    
set @Product_code  =  ltrim(rtrim(@Product_code))            
set @ProductName  = ltrim(rtrim(@ProductName ))            
set @CategoryName  = ltrim(rtrim(@CategoryName ))            
set @CategoryColour  = ltrim(rtrim(@CategoryColour))             
set @CategorySize = ltrim(rtrim(@CategorySize ))            
set @SupplierCode = ltrim(rTrim(@SupplierCode))          
Select @Colourid = propertyid from properties where property_Name = 'Colour'                
Select @Sizeid =  propertyid from properties where property_Name = 'Size'                
Select @Styleid = propertyid from properties where property_Name = 'Style'                
Select @Supplierid = propertyid from properties where property_Name = 'SupplierCode'                
          
select @ManufacturerID = ManufacturerID from manufacturer where Manufacturer_Name = 'Default'                
select @BrandID = brandid from brand where brandname = 'Default'                
select @UOM = uom from uom where [description] = 'Units'                
select @ReportingUOM = uom from uom where [description] = 'Units'                
          
--to insert category and get id                 
if (select count(*) from ItemCategories where Category_Name = @CategoryName) < 1                
begin                
 insert into itemcategories (Category_Name, [Description], Track_Inventory, Price_Option, Active)                
 values(@CategoryName, @CategoryName ,1, 0, 1)                
 select @Categoryid = @@identity                
end                
else -- if already there get the id                 
begin                
 select @Categoryid = Categoryid from itemcategories where category_name = @CategoryName                
end                
--after getting the cat id insert into category_properties table if there is no such entry                
if (select count(*) from category_properties where Categoryid = @Categoryid and propertyid = @Colourid) < 1                 
begin                
 insert into category_properties values(@Categoryid, @Colourid)                
end                
if (select count(*) from category_properties where Categoryid = @Categoryid and propertyid = @Sizeid) < 1                 
begin                
 insert into category_properties values(@Categoryid, @Sizeid)                
end                
if (select count(*) from category_properties where Categoryid = @Categoryid and propertyid = @Styleid) < 1                 
begin                
 insert into category_properties values(@Categoryid, @Styleid)                
end                
if (select count(*) from category_properties where Categoryid = @Categoryid and propertyid = @Supplierid) < 1                 
begin                
 insert into category_properties values(@Categoryid, @Supplierid)                
end                
--customise the item name and chk for duplicates                
set @PropValue = @productname
set @Productname = cast(@Productname as nvarchar) + ' ' + cast(@CategoryColour as nvarchar) + ' ' + cast(@CategorySize as nvarchar)           

--after  inserting category_properties table insert into item_properties table if there is no such entry                
if (select count(*) from ITEMS where Product_code = @Product_code or ProductName = @ProductName) < 1                 
BEGIN                
 insert into item_properties (Product_code, PropertyId, [Value]) values(@Product_code, @Colourid, @CategoryColour)           
 insert into item_properties (Product_code, PropertyId, [Value]) values(@Product_code, @Sizeid, @CategorySize)                
 insert into item_properties (Product_code, PropertyId, [Value]) values(@Product_code, @Styleid, @PropValue )                
 insert into item_properties (Product_code, PropertyId, [Value]) values(@Product_code, @Supplierid, @SupplierCode)                
END                
-- to check for any item duplicates      
if (select count(*) from items where Product_code = @Product_code or productname = @Productname) < 1                 
 begin                
  --atlast insert into items table                
  insert into items (Product_code, Productname, Categoryid, Purchase_Price, Sale_Price, MRP, ManufacturerId, BrandId, UOM, ReportingUOM,                
   Track_Batches, TrackPKD, Virtual_Track_Batches, StockNorm, MinOrderQty, Saleid, Sale_Tax, opening_stock, opening_stock_value, Schemeid, TaxSuffered, Alias)                
  values (@Product_code, @Productname, @Categoryid, @Purchase_Price, @Sale_Price, @MRP, @ManufacturerId, @BrandId, @UOM, @ReportingUOM,                
   0, 0, 0, 100, 0, 2, 0, 0, 0, 0, 0, @Product_code)              
  if @@rowcount <> 0               
  set @Ret = 1      
 end                
 else      
 begin      
  set @Ret = 2      
 end      
      
select @Ret        


