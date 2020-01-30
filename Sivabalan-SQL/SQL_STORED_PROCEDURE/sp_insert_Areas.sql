



CREATE procedure sp_insert_Areas(@AreaName nvarchar(255))
AS
insert into Areas(Area) values(@AreaName)
Select @@identity




