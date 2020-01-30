

CREATE procedure sp_Insert_Pre_Import_Items  
as  
 declare  @INS_ManufacturerCode int  
 declare  @INS_BrandID int  
 declare  @INS_UOM int  
  
if (select count(*) from Manufacturer where Manufacturer_Name = 'Default') < 1  
begin  
 insert into Manufacturer (Manufacturer_Name, Active, manufacturercode) values('Default', 1, 'Default')  
end  
select @INS_ManufacturerCode = Manufacturerid from Manufacturer where Manufacturer_Name = 'Default'   
if (select count(*) from Brand where BrandName = 'Default') < 1  
begin  
 insert into Brand (BrandName, ManufacturerID, Active) values('Default', @INS_ManufacturerCode, 1)  
end  
if (select count(*) from UOM where [Description] = 'Units') < 1  
begin  
 insert into UOM ([Description], Active) values('Units', 1)  
end  
if (select count(*) from Properties where Property_Name = 'Style') < 1  
begin  
 insert into properties (Property_Name) values('Style')  
end  
if (select count(*) from Properties where Property_Name = 'Colour') < 1  
begin  
 insert into properties (Property_Name) values('Colour')  
end  
if (select count(*) from Properties where Property_Name = 'Size') < 1  
begin  
 insert into properties (Property_Name) values('Size')  
end  
if (select count(*) from Properties where Property_Name = 'SupplierCode') < 1  
begin  
 insert into properties (Property_Name) values('SupplierCode')  
end  
  
select @INS_BrandID = BrandID from Brand where brandname = 'Default'   
select @INS_UOM = UOM from uom where [description] = 'Units'  
select cast(@INS_ManufacturerCode as nvarchar) + ',' + cast(@INS_BrandID as nvarchar) + ',' + cast(@INS_UOM as nvarchar)

