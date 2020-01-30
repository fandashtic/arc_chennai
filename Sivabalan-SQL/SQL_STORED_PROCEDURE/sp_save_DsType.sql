Create Procedure sp_save_DsType(@SalesmanName as nVarchar(100),@DsTypeName1 nVarchar(50),@DsTypeValue1 nVarchar(50),@DSTypeName2 nVarchar(50),@DSTypeValue2 nvarchar(50))
As
Begin
   Declare @SalesmanID as Integer
   Declare @TypeID AS Integer
   Select @SalesmanID = SalesManID From Salesman Where Salesman_Name = @SalesmanName
   exec sp_InsOrUpDate_DSType @SalesmanID,@DsTypeName1,@DsTypeValue1,1
   exec sp_InsOrUpDate_DSType @SalesmanID,@DSTypeName2,@DSTypeValue2,2
End
