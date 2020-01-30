Create Procedure Sp_InsertRecdMarketInfoAbstract(@DocumentID nVarchar(100), @ReceivedDate nVarchar(255), @FromCompanyID nVarchar(255))  
As  
Begin
--	Set DateFormat DMY
	INSERT INTO RecdMarketInfoAbstract (Documentid,ReceiveDate,CompanyID,CreationDate,Status)
	Values (@DocumentID, @ReceivedDate, @FromCompanyID,Getdate(),0)  
	Select @@IDENTITY  
End
