Create Procedure Sp_Get_GroupCreditTerm_ITC
(
 @GroupID nVarchar(1000),
 @Customer NVarChar(300)
)
As
Begin


	Declare @CustomerID As NVarChar(300)
	Declare @CreditTermDays As Int

	Create Table #tmpCrdtTrm(CrDtID Int,Description nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,Days Int)

	Select @CustomerID = CustomerID From Customer Where Company_Name = @Customer
	If IsNull(@CustomerID,'') = ''
	Set @CustomerID = @Customer


	Insert Into #tmpCrdtTrm
	Select Distinct
	isNull(CreditTermDays,-1),isNull(Description,''),CT.[Value]
	From
	CustomerCreditLimit CCL,CreditTerm CT
	Where
	CCL.CustomerID = @CustomerID
	And CCL.GroupID In(Select * From dbo.sp_splitIn2Rows(@GroupID,','))
	And isNull(CCL.CreditTermDays,-1) <> -1 
	And isNull(CCL.CreditTermDays,-1) = CT.CreditID 
	And CT.Active = 1

	If Not Exists(Select * From #tmpCrdtTrm)
		Select isNull(C.CreditTerm,-1),isNull(Description,'') From Customer C,CreditTerm CT
		Where CustomerID = @CustomerID And
		CT.CreditID = C.CreditTerm And
		isNull(C.CreditTerm,-1) <> -1
		And CT.Active = 1
	Else
		Select CrDtID,Description From #tmpCrdtTrm Order By Days

	Drop Table #tmpCrdtTrm

End
