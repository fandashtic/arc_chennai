CREATE FUNCTION [dbo].[Fn_SurveyDetailsGeneral]()
RETURNS @temptable TABLE (SurveyID nvarchar(50),QuestionID int,QuestionDesc nvarchar(50),QuestionSEQ int,AnswerType nvarchar(10),QuestionLen int)       
AS       
BEGIN
	INSERT INTO @temptable
	SELECT SM.SurveyCode as SurveyID, SQM.QuestionID, SQM.QuestionDesc,SQM.QuestionSequence as QuestionSEQ,SQM.QuestionType as AnswerType,
	-- case when SQM.QuestionType=0 then 'Yes-No' when SQM.QuestionType=1 then 'Multiple' when SQM.QuestionType=2 then 'Numeric Freeform' when SQM.QuestionType=3 then 'AlphaNumeric Freeform' End 
	SQM.QuestionLength as QuestionLen
	FROM dbo.tbl_merp_SurveyQuestionMapping SQM,tbl_merp_SurveyMaster SM
	WHERE SQM.SurveyID=SM.SurveyID and SM.SurveyType='Q' and SM.Active=1 ORDER BY SQM.SurveyID,SQM.QuestionSequence
RETURN
END  
