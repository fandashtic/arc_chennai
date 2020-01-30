CREATE Procedure spr_list_GVIssuedRedeemDetail(@Type nvarchar(50),         
 @FROMDATE datetime, @TODATE datetime)        
As        
        
If @Type = N'GV Issued'        
Begin        
 Select 1,"GVSerialNumber" = GVDetail.SequenceNumber, "GVDenomination" = GVDetail.Amount,         
  "CustomerName" = Company_Name, "Issued/Redeemed Date" = GVDetail.IssueDate,         
  "Issued/Redeemed Number" = IssueGV.CollectionID, "RedeemedAmount" = 0, "CollectionNo" = N''        
  From GiftVoucherDetail GVDetail, IssueGiftVoucher IssueGV, Customer Where         
  GVDetail.SerialNo = IssueGV.SerialNO And Customer.CustomerId = GVDetail.CustomerID And        
  IsNull(GVDetail.Status,0) In (1,2) And (IsNull(IssueGV.Status,0) & 192) = 0  And 
  GVDetail.IssueDate Between @FromDate and @ToDate        
  Union
  Select 1,"GVSerialNumber" = GVDetail.SequenceNumber, "GVDenomination" = GVDetail.Amount,         
   "CustomerName" = Company_Name,  "Issued/Redeemed Date" = DocumentDate,    
  "Issued/Redeemed Number" = GVRedeemIds.RedeemID, "RedeemedAmount" = GVRedeemIds.RedeemAmount,    
  "CollectionNo" = FullDocId     
 From GiftVoucherDetail GVDetail, Collections,       
  IssueGiftVoucher IssueGV, Customer, GiftVoucherRedeemIds GVRedeemIds Where         
  GVDetail.SerialNo = IssueGV.SerialNO And Customer.CustomerId = Collections.CustomerID And      
  IsNull(GVDetail.Status,0) In (3) And (IsNull(Collections.Status,0) & 192) = 0   
  And GVDetail.SequenceNumber = GVRedeemIds.SequenceNo And GVRedeemIds.RedeemId =     
 Collections.DocumentId And Collections.DocumentDate Between @FromDate and @ToDate           
End        
Else if @Type = N'GV Redeem'        
Begin        
 Select 1,"GVSerialNumber" = GVDetail.SequenceNumber, "GVDenomination" = GVDetail.Amount,         
   "CustomerName" = Company_Name,  "Issued/Redeemed Date" = DocumentDate,    
  "Issued/Redeemed Number" = GVRedeemIds.RedeemID, "RedeemedAmount" = GVRedeemIds.RedeemAmount,    
  "CollectionNo" = FullDocId     
 From GiftVoucherDetail GVDetail, Collections,       
  IssueGiftVoucher IssueGV, Customer, GiftVoucherRedeemIds GVRedeemIds Where         
  GVDetail.SerialNo = IssueGV.SerialNO And Customer.CustomerId = Collections.CustomerID And      
  IsNull(GVDetail.Status,0) In (3,4) And (IsNull(Collections.Status,0) & 192) = 0   
  And GVDetail.SequenceNumber = GVRedeemIds.SequenceNo And GVRedeemIds.RedeemId =     
 Collections.DocumentId And Collections.DocumentDate Between @FromDate and @ToDate           
 Union        
 Select 1,"GVSerialNumber" = GVOthers.SequenceNumber, "GVDenomination" = GVOthers.Amount,         
  "CustomerName" = Company_Name, "Issued/Redeemed Date" = DocumentDate,         
  "Issued/Redeemed Number" = GVOthers.RedeemID, "RedeemedAmount" = GVOthers.AmountRedeemed,      
  "CollectionNo" = FullDocId From GiftVoucherOthers GVOthers, Customer, Collections Where   
  Customer.CustomerId = Collections.Customerid and Collections.Documentid = GVOthers.RedeemID  
  And (IsNull(Collections.Status,0) & 192) = 0 And (IsNull(GVOthers.Status,0) & 192) = 0   
  And Collections.DocumentDate Between @FromDate and @ToDate       
End        
  



