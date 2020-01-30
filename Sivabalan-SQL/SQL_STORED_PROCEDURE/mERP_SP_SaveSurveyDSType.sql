
Create Procedure mERP_SP_SaveSurveyDSType (@SurveyID int, @DSType nvarchar(100))
AS
BEGIN
	insert into [tbl_merp_SurveyDSMapping]([SurveyID],[DSType]) values (@SurveyID,@DSType)
END
