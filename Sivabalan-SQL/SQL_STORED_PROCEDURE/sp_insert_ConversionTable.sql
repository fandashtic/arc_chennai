
CREATE proc sp_insert_ConversionTable (@Conversion nvarchar(50))
as
insert into ConversionTable 
(ConversionUnit) values (@Conversion)
select @@identity

