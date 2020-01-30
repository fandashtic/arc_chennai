CREATE FUNCTION [dbo].[Fn_SurveyDetailsProductList]()
RETURNS @temptable TABLE (SurveyID nvarchar(50),ProductID nvarchar(10),ProductName nvarchar(50),ProductSEQ int)       
AS       
BEGIN
	INSERT INTO @temptable
	SELECT SM.SurveyCode as SurveyID, SPM.ProductID, SPM.ProductName,SPM.ProductSequence as ProductSEQ
	FROM tbl_merp_SurveyProductMapping SPM,tbl_merp_SurveyMaster SM
	WHERE SPM.SurveyID=SM.SurveyID and SM.Active=1 ORDER BY SPM.SurveyID,SPM.ProductSequence
RETURN
END  
