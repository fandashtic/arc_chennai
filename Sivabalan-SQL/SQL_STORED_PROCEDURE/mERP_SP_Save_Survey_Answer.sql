
Create Procedure mERP_SP_Save_Survey_Answer (
@SurveyID int,
@QuestionID int,
@AnswerID int,
@AnswerDesc nvarchar(50),
@AnswerSequence int,
@AnswerValue nvarchar(50) 
)
AS 
BEGIN
	insert into tbl_merp_SurveyQuestionAnswerMapping ([SurveyID],[QuestionID],[AnswerID],[AnswerDesc],[AnswerSequence],[AnswerValue])
	values (@SurveyID,@QuestionID,@AnswerID,@AnswerDesc,@AnswerSequence,@AnswerValue)
END
