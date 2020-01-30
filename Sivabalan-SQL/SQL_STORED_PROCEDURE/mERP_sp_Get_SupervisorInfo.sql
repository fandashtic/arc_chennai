Create Procedure mERP_sp_Get_SupervisorInfo(@SupervisorID Int)
As
Begin
  Select SalesmanId, SalesmanName, IsNull(Address,''),IsNull(ResidenceNo,''),IsNull(MobileNo,''),TypeID, Active
  From Salesman2 Where SalesmanID = @SupervisorID
End 
