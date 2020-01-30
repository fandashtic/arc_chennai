CREATE Procedure sp_han_Create_sqlagent_proxy_account(@domain nvarchar(100),@user nvarchar(100),@password nvarchar(100))  
as  
EXECUTE master.dbo.xp_sqlagent_proxy_account N'SET', @domain, @user, @password  
EXECUTE msdb.dbo.sp_set_sqlagent_properties @sysadmin_only = 0  
