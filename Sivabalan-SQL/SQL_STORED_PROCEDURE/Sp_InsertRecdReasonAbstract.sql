Create Procedure Sp_InsertRecdReasonAbstract(@DocumentID int, @ReceivedDate nVarchar(255), @FromCompanyID nVarchar(255))  
As  
Begin
--	Set DateFormat DMY
	INSERT INTO RecdReasonAbstract (Documentid,ReceiveDate,CompanyID,CreationDate,Status)
	Values (@DocumentID, @ReceivedDate, @FromCompanyID,Getdate(),0)  
	Select @@IDENTITY  
End
