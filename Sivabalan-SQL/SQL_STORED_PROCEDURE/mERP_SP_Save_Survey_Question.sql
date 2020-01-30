Create Procedure mERP_SP_Save_Survey_Question (@SurveyID int,@QuestionID int,@QuestionDesc nvarchar(50),@QuestionSequence int,@QuestionType nvarchar(10),@QuestionLength int)
AS 
BEGIN
	insert into tbl_merp_SurveyQuestionMapping ([SurveyID],[QuestionID],[QuestionDesc],[QuestionSequence],[QuestionType],[QuestionLength])
	values (@SurveyID,@QuestionID,@QuestionDesc,@QuestionSequence,@QuestionType,@QuestionLength)
END
