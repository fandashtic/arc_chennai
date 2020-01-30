Create Procedure mERP_Sp_CountMargin
AS
Select Count(*) from tbl_mERP_MarginDetail MDet Inner Join tbl_mERP_MarginAbstract MAbs
On MAbs.marginID = MDet.MarginID 
where dbo.StripTimefromDate(CreationDate) = DATEADD(D, 0, DATEDIFF(D, 0, GETDATE()))
and MAbs.ReceiveDocID <> 0
