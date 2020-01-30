Create Procedure mERP_SP_SaveSurveyMaster (@SurveyID int,@SurveyCode nvarchar(50),@SurveyDescription nvarchar(50),@SurveyType char,@EffectiveFrom datetime,@Active int,@Mandatory int)
AS
BEGIN
	/* 
	We are maintaining status of Survey as per below logic
	Status = 0 (NEW) and active will be 1
	Status = 1 (Change Request) and active will be made as 1 for new record and existing SurveyCode active will be made to 0
	Status = 2 (DROP) and active will be received as Zero and will be updated in the table
    */
	--New Survey
	if((Select count (*) from tbl_merp_SurveyMaster where isnull([SurveyCode],'') = @SurveyCode)= 0)
	BEGIN
		insert into tbl_merp_SurveyMaster ([SurveyID],[SurveyCode],[SurveyDescription],[SurveyType],[EffectiveFrom],[Active],[Status],[CreationDate],[Mandatory])
		values (@SurveyID,@SurveyCode,@SurveyDescription,@SurveyType,@EffectiveFrom,@Active,
		(Case isnull(@Active,0) 
		when 0 then 2 --Make survey as inactive
		else 0 
		end) ,getdate(), isnull(@Mandatory,0))
	END
	Else
	--CR Survey
	BEGIN
		--Deactive existing surveys with same survey code
		update tbl_merp_SurveyMaster set active = 0 where isnull([SurveyCode],'') = @SurveyCode
		
		--Insert new survey details
		insert into tbl_merp_SurveyMaster ([SurveyID],[SurveyCode],[SurveyDescription],[SurveyType],[EffectiveFrom],[Active],[Status],[CreationDate],[Mandatory])
		values (@SurveyID,@SurveyCode,@SurveyDescription,@SurveyType,@EffectiveFrom,@Active,
		(Case isnull(@Active,0) 
		when 0 then 2 --Make survey as inactive
		else 1 
		end) ,getdate(), isnull(@Mandatory,0))
	END
END	
