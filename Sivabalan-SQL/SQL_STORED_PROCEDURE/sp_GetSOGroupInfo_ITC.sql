CREATE Procedure [dbo].[sp_GetSOGroupInfo_ITC](@SONumber nVarChar(1000))
As
Begin
	Declare @szSql nvarchar(4000)
	
	Declare @GroupID as nVarchar(500)
	Declare @GroupNames as nVarchar(4000)

	Select @GroupID = isNull(GroupID,'-1') From SOAbstract Where SONumber = @SONumber

	if isNull(@GroupID,'-1' ) <> '-1' 
		Select  @GroupNames = dbo.mERP_fn_Get_GroupNames(@GroupID)


	
	Set @szSql = 'Select Top 1  Customer.Company_Name, Customer.CustomerID,'+ '''' + Cast(@GroupNames as nVarchar(4000)) + '''' + 'as GroupName, SOAbstract.GroupID,
					Salesman.Salesman_Name, Salesman.SalesmanID, Beat.Description, Beat.BeatID, CreditTerm.Description as CreditTerm, CreditTerm.CreditID ,DeliveryDate,
					IsNull(SupervisorID, 0) As SupervisorID 
					From SOAbstract
					Inner Join Customer On  Customer.CustomerID = SOAbstract.CustomerID
					Left Outer Join Salesman On SOAbstract.SalesmanID = Salesman.SalesmanID 
					Left Outer Join Beat On SOAbstract.BeatID = Beat.BeatID
					Left Outer Join CreditTerm On SOAbstract.CreditTerm =  CreditTerm.CreditID 
					Where IsNull(SOAbstract.Status,0) & 128 =0   
					And SOAbstract.SONumber In(' + @SONumber + ')'
	
	Exec sp_executesql @szSql
End

