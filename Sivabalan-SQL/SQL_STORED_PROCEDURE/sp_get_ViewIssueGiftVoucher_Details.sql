CREATE procedure sp_get_ViewIssueGiftVoucher_Details(@CollectionID Int)    
As    
Select SequenceNumber,ExpiryDate,Amount,Amountreceived,GiftVoucherDetail.SerialNo From GiftVoucherDetail,    
IssueGiftVoucher Where IssueGiftVoucher.SerialNo=GiftVoucherDetail.SerialNo and    
CollectionID=@CollectionID and GiftVoucherDetail.Status in (1,2,3,4)    


  


