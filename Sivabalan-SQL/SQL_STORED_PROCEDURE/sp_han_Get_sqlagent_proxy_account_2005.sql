Create Procedure sp_han_Get_sqlagent_proxy_account_2005  
as  
--EXEC master.dbo.xp_sqlagent_proxy_account N'GET'   
SELECT rtrim(ltrim(substring(s.credential_identity,0,charindex('\',s.credential_identity)))) as 'Domain',rtrim(ltrim(substring(s.credential_identity,charindex('\',s.credential_identity)+1,charindex('\',s.credential_identity))))as 'Username' FROM sys.credentials AS s WHERE (s.name=N'##xp_cmdshell_proxy_account##')  
