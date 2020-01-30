CREATE procedure sp_save_settlement (@ClaimsID int,
				     @SettlementType int,
				     @SettlementDate datetime,
				     @SettlementValue Decimal(18,6),	
				     @GSK_Flag Integer = 0,	
				     @CreditNoteNo nvarchar(100)= 0)
as
If @GSK_Flag = 1 
Update ClaimsNote Set SettlementType = @SettlementType, SettlementDate = @SettlementDate,
SettlementValue = @SettlementValue, Status = IsNull(Status, 0) | 128, CompanyCreditNoteNo = @CreditNoteNo 
Where ClaimID = @ClaimsID
Else
Update ClaimsNote Set SettlementType = @SettlementType, SettlementDate = @SettlementDate,
SettlementValue = @SettlementValue, Status = IsNull(Status, 0) | 128
Where ClaimID = @ClaimsID

