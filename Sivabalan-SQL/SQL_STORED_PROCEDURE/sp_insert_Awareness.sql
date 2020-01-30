Create Procedure sp_insert_Awareness (@Awareness as nvarchar(200))
As
Insert into Awareness ([Description]) Values (@Awareness)
Select @@identity

