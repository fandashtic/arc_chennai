CREATE PROCEDURE [dbo].[mERPFYCP_get_CountRecCCD_GSK] ( @yearenddate datetime )
As
SELECT count(*) FROM RecCustClassification WHERE Status = 0 and docrecdate <= @yearenddate
