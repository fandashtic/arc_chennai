Create procedure FSU_SP_getNodeID @clientid int
AS
Begin
		Select top 1 node from tblclientmaster where clientid= @clientid
End 
