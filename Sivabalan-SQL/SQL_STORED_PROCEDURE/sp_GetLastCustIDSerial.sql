
CREATE Procedure sp_GetLastCustIDSerial( @Prefix nVarChar(50))  
As  

	Declare @Sql nVarchar(500)  

	Set @Sql = 'Select Max(Cast(SubString(CustomerID,Len(''' + @Prefix + ''')+1, Len(CustomerID )) as Int)) From Customer  
	Where CustomerID Like ''' +  @Prefix + '%''   
	And IsNumeric(SubString(CustomerID,Len(''' + @Prefix + ''')+1, Len(CustomerID ))) = 1'  
	Exec sp_ExecuteSql @Sql  



