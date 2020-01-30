CREATE FUNCTION [dbo].[Fn_SurveyDetailsProductQuestion]()
RETURNS @temptable TABLE (SurveyID nvarchar(50),QuestionID int,QuestionDesc nvarchar(50),QuestionSeq int,AnswerType nvarchar(10),QuestionLen int)       
AS       
BEGIN
	INSERT INTO @temptable
	SELECT SM.SurveyCode as SurveyID, SQM.QuestionID, SQM.QuestionDesc,SQM.QuestionSequence as QuestionSEQ,SQM.QuestionType as AnswerType,SQM.QuestionLength as QuestionLen
	FROM dbo.tbl_merp_SurveyQuestionMapping SQM,tbl_merp_SurveyMaster SM
	WHERE SQM.SurveyID=SM.SurveyID and SM.SurveyType='P' and SM.Active=1 ORDER BY SQM.SurveyID,SQM.QuestionSequence
RETURN
END  
