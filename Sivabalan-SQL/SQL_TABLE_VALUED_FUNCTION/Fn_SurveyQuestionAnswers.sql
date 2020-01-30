CREATE FUNCTION [dbo].[Fn_SurveyQuestionAnswers]()
RETURNS @temptable TABLE (SurveyID nvarchar(50),QuestionID int,AnswerID int,AnswerDesc nvarchar(50),AnswerSequence int)       
AS       
BEGIN
	INSERT INTO @temptable
	SELECT SM.SurveyCode as SurveyID, QuestionID, AnswerID,AnswerDesc,AnswerSequence
	FROM tbl_merp_SurveyQuestionAnswerMapping SAM,tbl_merp_SurveyMaster SM
	WHERE SAM.SurveyID=SM.SurveyID and SM.Active=1 ORDER BY SAM.SurveyID,SAM.QuestionID,SAM.AnswerSequence
RETURN
END  
