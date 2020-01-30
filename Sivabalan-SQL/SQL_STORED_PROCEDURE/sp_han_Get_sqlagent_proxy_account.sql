CREATE Procedure sp_han_Get_sqlagent_proxy_account (@Type nvarchar(100))    
as    
EXEC master.dbo.xp_sqlagent_proxy_account @Type     
SET QUOTED_IDENTIFIER OFF
