CREATE procedure sp_han_getdblocation
as
Select FileName 'Path' from SysFiles Where FileName like '%.mdf%'


