CREATE VIEW [dbo].[V_SurveyMaster] AS 
SELECT SurveyCode as SurveyID, SurveyDescription as Survey_Name, SurveyType as Survey_Type,CreationDate,Mandatory
 FROM dbo.tbl_merp_SurveyMaster WHERE datediff(dd,EffectiveFrom,getdate())>=0 and Active=1 
