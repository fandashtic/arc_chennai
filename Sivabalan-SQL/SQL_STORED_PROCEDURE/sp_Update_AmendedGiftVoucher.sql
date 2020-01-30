CREATE Procedure sp_Update_AmendedGiftVoucher(@CollectionID Int,@Status Int = 128)      
As      
 Update IssueGiftVoucher Set Status = Status | @Status Where CollectionID = @CollectionID      
 if @status = 192     
	 update GiftVoucherDetail set IssueDate=Null,AmountReceived=Null,CustomerID=Null,Status=0  
	 where status not in(3,4) and  GiftVoucherDetail.SerialNo in (Select SerialNo From IssueGiftVoucher      
	 where CollectionID=@CollectionID)      
 else
	 update GiftVoucherDetail set IssueDate=Null,AmountReceived=Null,CustomerID=Null,Status=0  
	 where GiftVoucherDetail.SerialNo in (Select SerialNo From IssueGiftVoucher      
	 where CollectionID=@CollectionID)      


