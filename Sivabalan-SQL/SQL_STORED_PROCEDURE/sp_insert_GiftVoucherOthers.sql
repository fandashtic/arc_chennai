CREATE PROCEDURE [sp_insert_GiftVoucherOthers]  
 (@SequenceNumber nvarchar(250),  
  @Amount decimal,  
  @IssueDate datetime,  
  @ExpiryDate datetime,  
  @AmountRedeemed decimal,  
  @RedeemID int,  
  @Status int)  
  
AS INSERT INTO [GiftVoucherOthers]   
  ([SequenceNumber],  
  [Amount],  
  [IssueDate],  
  [ExpiryDate],  
  [AmountRedeemed],  
  [RedeemID],  
  [Status])   
   
VALUES   
 (@SequenceNumber,  
  @Amount,  
  @IssueDate,  
  @ExpiryDate,  
  @AmountRedeemed,  
  @RedeemID,  
  @Status)


