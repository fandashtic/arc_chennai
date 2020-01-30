Create Procedure mERP_sp_save_CSDisplay_OutletBudgetAlloc(
  @SchemeID INT , @CapPerOutletID INT, @PayoutPeriodID INT, 
  @OutletCode nVarChar(50), @AllocAmount Decimal(18,6))
As
Begin
  Insert into tbl_mERP_DispSchBudgetPayout(SchemeID,CapPerOutletID,PayoutPeriodID, OutletCode,AllocatedAmount,PendingAmount)
  values(@SchemeID, @CapPerOutletID, @PayoutPeriodID, @OutletCode, @AllocAmount, @AllocAmount)
  Select @@IDentity  
End
