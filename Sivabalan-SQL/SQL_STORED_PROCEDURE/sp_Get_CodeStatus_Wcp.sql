CREATE Procedure sp_Get_CodeStatus_Wcp (@Code Bigint) as  
select Code from wcpabstract where code=@Code and isnull(status,0)&128=0  


