
Create Procedure sp_acc_import_updatevendoropeningbalance
As
Declare @VendorOpenBal Decimal(18,6),@AccountID Int

DECLARE scandebitcreditnote CURSOR KEYSET FOR
Select sum(balance),Vendors.AccountID from DebitNote,Vendors where DebitNote.VendorID=Vendors.VendorID Group By DebitNote.VendorID,Vendors.AccountID
UNION ALL
Select sum(balance),Vendors.AccountID from CreditNote,Vendors where CreditNote.VendorID=Vendors.VendorID Group By CreditNote.VendorID,Vendors.AccountID
OPEN scandebitcreditnote
FETCH FROM scandebitcreditnote INTO @VendorOpenBal,@AccountID
While @@FETCH_STATUS = 0
Begin
	Update AccountsMaster Set OpeningBalance= IsNull(OpeningBalance,0) + IsNull(@VendorOpenBal,0) where AccountID=@AccountID
	FETCH NEXT FROM scandebitcreditnote INTO @VendorOpenBal,@AccountID
End
CLOSE scandebitcreditnote
DEALLOCATE scandebitcreditnote





