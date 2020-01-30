create proc sp_Dlete_IniFiles(@Files nvarchar(2000))  
as  
begin  
delete from tbl_merp_clientfileinfo where [Filename]=@Files  
end

