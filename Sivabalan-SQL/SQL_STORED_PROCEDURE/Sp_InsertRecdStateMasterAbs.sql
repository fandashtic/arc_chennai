Create Procedure Sp_InsertRecdStateMasterAbs(@DocumentID nVarchar(100), @ReceivedDate nVarchar(255), @FromCompanyID nVarchar(255))  
As  
Begin
--	Set DateFormat DMY
	INSERT INTO Recd_StateMasterAbs (Documentid,ReceiveDate,CompanyID,CreationDate,Status)
	Values (@DocumentID, @ReceivedDate, @FromCompanyID,Getdate(),0)  
	Select @@IDENTITY  
End
