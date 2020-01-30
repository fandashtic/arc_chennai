
Create Function mERP_fn_Get_DSNameforSurvey (@SurveyName nvarchar(4000)) Returns @DSName Table (Name  nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
AS
BEGIN
	Declare @Delimeter as Char(1)      
	Set @Delimeter = Char(44)      
	if @SurveyName = '%%'
		insert into @DSName 
		Select Distinct Salesman_Name from Salesman order by 1
	Else
		insert into @DSName
		Select Distinct S.Salesman_Name from DSType_Master M,DSType_Details D,Salesman S,tbl_merp_SurveyDSMapping DSMap,tbl_merp_SurveyMaster SM where 
		S.SalesmanId=D.salesmanID
		And D.DSTypeID = M.DSTypeID
		And DSMap.DSType = M.DSTypeValue
		And SM.SurveyID = DSMAp.SurveyID
		And SM.SurveyDescription in (Select * from dbo.sp_SplitIn2Rows(@SurveyName,@Delimeter))
		order by 1
	RETURN
END
