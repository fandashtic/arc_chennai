Create Procedure mERP_sp_Update_SupervisorInfo(
  @SupervisorID nVarchar(500), 
  @Address nVarchar(510) = Null, 
  @ResidenceNo nVarchar(30)= Null, 
  @MobileNo nVarchar(30)= Null, 
  @TypeID Int, @Active Int)
As
Begin
  Update Salesman2 Set Address = @Address, ResidenceNo = @ResidenceNo, MobileNo = @MobileNo, TypeID = @TypeID, Active = @Active
  Where SalesmanID = @SupervisorID
  Select @@RowCount
End
