
Create Procedure sp_getMACAddress
As
Begin
	Select distinct "MACAddress" = net_address From Master..sysprocesses Where hostname=host_name()
End
