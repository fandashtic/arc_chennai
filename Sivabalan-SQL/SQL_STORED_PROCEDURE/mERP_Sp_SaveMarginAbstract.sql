Create Procedure mERP_Sp_SaveMarginAbstract(@DocumentDate datetime,@UserID nvarchar(100))
As
Begin
   Insert into MarginAbstract(DocumentDate,CreationDate,UserID) Values(@DocumentDate,getdate(),@UserID)
   select @@Identity		
End
