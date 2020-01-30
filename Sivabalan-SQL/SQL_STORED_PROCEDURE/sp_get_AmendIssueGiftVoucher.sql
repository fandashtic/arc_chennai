CREATE procedure sp_get_AmendIssueGiftVoucher(@CollectionID Int)  
As  
Select SequenceNumber,ExpiryDate,Amount,Amountreceived,GiftVoucherDetail.SerialNo From GiftVoucherDetail,  
IssueGiftVoucher Where IssueGiftVoucher.SerialNo=GiftVoucherDetail.SerialNo and  
CollectionID=@CollectionID and ((GiftVoucherDetail.Status & 1) = 1  or (GiftVoucherDetail.Status & 2) = 2)  


