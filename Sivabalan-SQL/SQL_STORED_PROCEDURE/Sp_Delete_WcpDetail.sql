create procedure Sp_Delete_WcpDetail(@Code int,@WcpDate datetime) as
delete from WcpDetail where code=@Code and WcpDate=@WcpDate

