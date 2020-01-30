Create Procedure mERP_Sp_CountDSTraining
AS
Select Count(*) from tbl_mERP_DSTraining where dbo.StriptimeFromDate(CreationDate) =  DATEADD(D, 0, DATEDIFF(D, 0, GETDATE()))
and DSTraining_Active = 1 
