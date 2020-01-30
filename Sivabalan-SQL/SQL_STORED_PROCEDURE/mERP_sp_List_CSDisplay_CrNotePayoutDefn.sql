Create Procedure mERP_sp_List_CSDisplay_CrNotePayoutDefn(@SchemeID Int, @PayoutPeriodID Int)
As
Begin
  Select Cus.CustomerID, Cus.Company_Name, 
   "Active" = Case Cus.Active When 1 Then 'Yes' Else 'No' End, 
   Bpay.CapPerOutletID, 
   "Alloc Amount" = Max(Bpay.AllocatedAmount), 
   "Paid Amount" = Max(Bpay.AllocatedAmount) - Sum(IsNull(Bpay.PendingAmount,0)),
   "Pending Amount" = Case Sum(IsNull(Bpay.PayoutAmount,0)) When 0 Then (Sum(IsNull(Bpay.PendingAmount,0)) - Sum(IsNull(Bpay.PayoutAmount,0))) Else Sum(IsNull(Bpay.PayoutAmount,0)) End,
   "CrNote" = Case Max(Bpay.AllocatedAmount) When 0 Then 'Yes' Else 'No' End, 
   "ValidityFlag" = Case When Sum(Bpay.PendingAmount+Bpay.PayoutAmount) = 0 And IsNull(Bpay.CrNoteRaised,0) = 1 Then 1 Else 0 End
  from tbl_mERP_DispSchBudgetPayout BPay, Customer Cus
  Where BPay.SchemeID = @SchemeID And 
   Bpay.PayoutPeriodID = @PayoutPeriodID And 
   Cus.CustomerID = Bpay.OutletCode
  Group By  Cus.CustomerID, Cus.Company_Name, Cus.Active, Bpay.CapPerOutletID, 
--   Case IsNull(Bpay.CrNoteRaised,0) When 1 Then 'Yes' Else 'No' End, 
   IsNull(Bpay.CrNoteRaised,0)
  Having Max(Bpay.AllocatedAmount) > 0 
  Order by Bpay.CapPerOutletID, Cus.Company_Name
End
