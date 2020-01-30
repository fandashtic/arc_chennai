CREATE Procedure spr_list_GVIssuedRedeem(@FROMDATE datetime,              
       @TODATE datetime)          
As          
Declare @GVIssued nvarchar(50)          
Declare @GVRedeem nvarchar(50)          
          
Set @GVIssued = 'GV Issued'          
Set @GVRedeem = 'GV Redeem'          
          
Select @GVIssued, "Type" = @GVIssued,           
 "Total Value" = Sum((-1 * AmountRedeemed) + IsNull(AmountReceived,0)), 
  "Total No." = Count(Status)          
 From GiftVoucherDetail GVDetail Where IsNull(Status,0) In (1,2,3)      
 And GVDetail.IssueDate Between @FromDate and @ToDate          
Union          
Select @GVRedeem, "Type" = @GVRedeem, "Total Value" = IsNull(Sum(GVRedeemids.RedeemAmount),0) +           
 (Select IsNull(Sum(AmountRedeemed),0) from GiftVoucherOthers, Collections Where   
 (IsNull(GiftVoucherOthers.Status,0) & 192) = 0 And GiftVoucherOthers.RedeemId =   
 Collections.DocumentId And Collections.DocumentDate Between @FromDate and @ToDate),        
 "Total No." =  Count(GVDetail.Status) +           
 (Select Count(GiftVoucherOthers.Status) from GiftVoucherOthers, Collections Where   
 (IsNull(GiftVoucherOthers.Status,0) & 192) = 0 And GiftVoucherOthers.RedeemId =   
 Collections.DocumentId And Collections.DocumentDate Between @FromDate and @ToDate)          
 From GiftVoucherDetail GVDetail, Collections, GiftVoucherRedeemIds GVRedeemids        
 Where IsNull(GVDetail.Status,0) In (3,4) And (IsNull(Collections.Status,0) & 192) = 0  
 And GVDetail.SequenceNumber = GVRedeemIds.SequenceNo And GVRedeemIds.RedeemId =       
 Collections.DocumentId And Collections.DocumentDate Between @FromDate and @ToDate      
        



