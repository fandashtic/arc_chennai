Create Procedure sp_ser_Update_FACollections(@DocID int, @BankID int)
as
Update Collections Set BankID = @BankID where DocumentID = @DocID

