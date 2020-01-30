Create Procedure mERP_sp_Insert_SupervisorInfo(
  @SupervisorName nVarchar(500), 
  @Address nVarchar(510) = Null, 
  @ResidenceNo nVarchar(30)= Null, 
  @MobileNo nVarchar(30)= Null, 
  @TypeID Int)
As
Begin
Insert into Salesman2 (SalesmanName, Address, ResidenceNo, MobileNo, TypeID) Values
(@SupervisorName, @Address, @ResidenceNo, @MobileNo, @TypeID)
Select @@Identity
End
