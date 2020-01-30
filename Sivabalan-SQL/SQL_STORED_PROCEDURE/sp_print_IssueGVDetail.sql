CREATE procedure sp_print_IssueGVDetail(@CollectionID as int)            
as  
Set dateformat dmy          
Select "Serial No" = SequenceNumber,"ExpiryDate" = ExpiryDate, "Amount" = Amount,    
"Value" = AmountReceived    
From giftvoucherdetail, IssueGiftVoucher    
Where IssueGiftVoucher.CollectionID = @CollectionID    
and giftvoucherdetail.SerialNo = IssueGiftVoucher.SerialNo  

