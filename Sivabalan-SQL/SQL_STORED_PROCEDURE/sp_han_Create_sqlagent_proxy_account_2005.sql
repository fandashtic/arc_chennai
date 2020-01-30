CREATE Procedure sp_han_Create_sqlagent_proxy_account_2005(@domain nvarchar(100),@user nvarchar(100),@password nvarchar(100))  
as  
declare @WinUser nvarchar(200),@ret as int  
set @WinUser=@domain+'\'+@user  
--set @ret=1  
--EXEC master.dbo.sp_xp_cmdshell_proxy_account NULL  
begin try
exec @ret = master.dbo.sp_xp_cmdshell_proxy_account @WinUser,@password  
If @ret = 0 
Begin  
EXEC sp_configure 'show advanced options', 1  
-- To update the currently configured value for advanced options.  
RECONFIGURE  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1  
-- To update the currently configured value for this feature.  
RECONFIGURE  
-- To disallow advanced options to be changed.  
--EXEC sp_configure 'show advanced options', 0  
-- To update the currently configured value for advanced options.  
--RECONFIGURE  
end
select @ret
end try   
begin catch
select @@error
end catch
