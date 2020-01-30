
create PROCEDURE [sp_insert_Manufacturer]	(@Manufacturer_Name_2	nvarchar(50), @manufacturercode nvarchar(50))
AS 
INSERT INTO [Manufacturer] 	 ( 	 [Manufacturer_Name], manufacturercode) 
VALUES 	(@Manufacturer_Name_2 , @manufacturercode)
Select @@identity



