Create Procedure sp_insert_Occupation (@Occupation as nvarchar(200))
As
Insert into Occupation ([Occupation]) Values (@Occupation)
Select @@identity

