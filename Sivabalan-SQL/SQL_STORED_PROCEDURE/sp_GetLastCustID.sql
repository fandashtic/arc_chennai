
CREATE Procedure sp_GetLastCustID      
As      
	Declare @Prefix nVarchar(25)      
	Declare @Serial int      

	Select @Prefix = IsNull(CustIDPrefix,''), @Serial = CustSerial From SetUp      
	Select @Prefix, @Serial From SetUp


