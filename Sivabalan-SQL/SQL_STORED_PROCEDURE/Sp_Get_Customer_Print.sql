create procedure Sp_Get_Customer_Print (@salesmanid nvarchar(15), @WcpDate datetime) as
select customerid from wcpdetail where code in ( select code from wcpabstract where salesmanid =@salesmanid ) and wcpdate =@wcpdate


