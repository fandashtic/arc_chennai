
Create Procedure mERP_SP_Save_Survey_Product (@SurveyID int, @ProductID nvarchar(10),@ProductName nvarchar(50),@ProductSequence int, @IsCompanyProduct int)
AS
BEGIN
	insert into [tbl_merp_SurveyProductMapping]([SurveyID],[ProductID],[ProductName],[ProductSequence],[IsCompanyProduct]) 
    values (@SurveyID,@ProductID,@ProductName,@ProductSequence,@IsCompanyProduct)
END
