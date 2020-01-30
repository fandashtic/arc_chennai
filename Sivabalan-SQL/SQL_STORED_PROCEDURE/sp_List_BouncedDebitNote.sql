Create Procedure sp_List_BouncedDebitNote (@DebitID int)
As
Select DebitID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar), DocumentDate, Memo
From DebitNote, VoucherPrefix Where DebitID = @DebitID And 
VoucherPrefix.TranID = 'DEBIT NOTE'

SET QUOTED_IDENTIFIER OFF 
