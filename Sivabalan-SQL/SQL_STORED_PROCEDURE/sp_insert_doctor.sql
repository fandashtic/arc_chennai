
CREATE procedure sp_insert_doctor(@NAME nvarchar(255))
as
insert into Doctor (Name) values (@NAME)
select @@IDENTITY

