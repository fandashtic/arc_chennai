CREATE Procedure sp_GetDispatchGroupInfo_ITC(@DispatchID  int)
As
Begin
	Declare @GroupID as nVarchar(500)
	Declare @GroupNames as nVarchar(1000)

	Select @GroupID = isNull(GroupID,'-1') From DispatchAbstract Where DispatchID = @DispatchID

	if isNull(@GroupID,'-1' ) <> '-1' 
		Select  @GroupNames = dbo.mERP_fn_Get_GroupNames(@GroupID)


	Select Top 1 Customer.Company_Name, DispatchAbstract.CustomerID , Customer.CreditTerm, 
	@GroupNames As 'GroupName', DispatchAbstract.GroupID,
	Salesman.Salesman_Name, Salesman.SalesmanID, Beat.Description, Beat.BeatID
	From DispatchAbstract
	Inner Join Customer On DispatchAbstract.CustomerID = Customer.CustomerID 
	Left Outer Join   Salesman On DispatchAbstract.SalesmanID = Salesman.SalesmanID
	Left Outer Join Beat On DispatchAbstract.BeatID = Beat.BeatID 
	Where IsNull(DispatchAbstract.Status,0) & 128 =0   
	And DispatchAbstract.DispatchID = @DispatchID
End
