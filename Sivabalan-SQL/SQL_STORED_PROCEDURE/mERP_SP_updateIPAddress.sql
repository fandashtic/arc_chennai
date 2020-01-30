Create Procedure mERP_SP_updateIPAddress(@Node nvarchar(255),@IPAddress nvarchar(255),@RamSize nVarChar(100))
AS
BEGIN
/*Check whether the IPAddress is alsready updated for the system. Update it only if it is mismatch*/
if(Select isnull(IPAddress,'') from tblclientmaster where Node=@Node)<>@IPAddress
BEGIN
update tblclientmaster set IPAddress=@IPAddress where Node=@Node
END
/*
On computers with more than 4 GB of memory,
the GlobalMemoryStatus function can return incorrect information,
reporting a value of �1 to indicate an overflow.
For this reason, applications should use the GlobalMemoryStatusEx function instead.
*/
If(Select isnull(PrimaryMemSize,'') from tblclientmaster where Node=@Node)<>@RamSize
BEGIN
update tblclientmaster set PrimaryMemSize=@RamSize where Node=@Node
END
END
