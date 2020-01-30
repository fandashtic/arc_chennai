CREATE Procedure sp_Can_CancelGiftVoucher(@CollectionID Int)    
As
If Exists(Select SequenceNumber From GiftVoucherDetail,IssueGiftVoucher
Where IssueGiftVoucher.SerialNo=GiftVoucherDetail.SerialNo 
and CollectionID=@CollectionID 
and ((GiftVoucherDetail.Status & 1) = 1 or (GiftVoucherDetail.Status & 2) = 2))     

Begin     
 Select 1
End
Else
Begin
 Select 0
End

