CREATE procedure sp_ser_view_FACollectionAbstract (@CollectionID int)
as
select isnull(Account_Number, '') 'Account_Number' from Collections, Bank 
where Collections.BankID = bank.Bankid  and Collections.DocumentID = @CollectionID 

