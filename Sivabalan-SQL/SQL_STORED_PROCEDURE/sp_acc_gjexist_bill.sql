CREATE procedure sp_acc_gjexist_bill    
As    
DECLARE @BillID Int    
Declare @Status Int    
Declare @BillReference nVarchar(255)    
    
Declare @FiscalYearStart DateTime    
Set @FiscalYearStart=dbo.sp_acc_getfiscalyearstart()    
Declare @OpenAccID Int    
Declare @DocDate DateTime    
Declare @DocBalance Decimal(18,6)    
Declare @OutstandingBalance Decimal(18,6)    
     
Declare @MODULENAME as nVarchar(100)    
SET @MODULENAME = N'Bill'    
    
Declare @UpgradeStatus Int,@LastUpdatedDocID Int    
--Get upgrade status and last updated document id from FAUpgradeStatus table    
Select @UpgradeStatus=IsNull(Status,0),@LastUpdatedDocID=IsNull(DocumentID,0)     
from FAUpgradeStatus Where ModuleName=@MODULENAME    
    
If @UpgradeStatus=0    
Begin    
    
 DECLARE ScanBillTransaction CURSOR KEYSET FOR    
 Select BillID, status,BillReference from BillAbstract Where BillID > @LastUpdatedDocID    
     
 OPEN ScanBillTransaction    
 FETCH FROM ScanBillTransaction INTO @BillId, @Status, @BillReference    
 WHILE @@FETCH_STATUS = 0    
 BEGIN    
  Begin Tran     
  Select @DocDate =BillDate,@OpenAccID = dbo.sp_acc_getaccountidfrommaster(VendorID,2),     
  @DocBalance=IsNull(Balance,0) from BillAbstract Where BillID=@BillId    
    
  If dbo.Stripdatefromtime(@DocDate) < @FiscalYearStart    
  Begin    
   Select @OutstandingBalance=Sum(IsNull(AdjustedAmount,0)) from PaymentDetail Where     
   PaymentDetail.DocumentID=@BillId and PaymentDetail.PaymentID     
   not in (Select Payments.DocumentID from Payments Where (IsNull(Status,0) & 64) <> 0 or dbo.Stripdatefromtime(DocumentDate) < @FiscalYearStart)     
   and DocumentType=4 -- In PaymentDetail 4->Bill    
   Set @OutstandingBalance=IsNull(@OutstandingBalance,0) + IsNull(@DocBalance,0)    
   Set @OpenAccID = IsNull(@OpenAccID,0)    
   If IsNull(@OutstandingBalance,0) <> 0 and IsNull(@OpenAccID,0) <> 0    
   Begin    
    Set @OutstandingBalance=0-IsNull(@OutstandingBalance,0)    
    Insert Into TempOpeningDetails(AccountID,Amount,Type) Values(@OpenAccID,@OutstandingBalance,2)     
    Set @OutstandingBalance=0    
    Set @OpenAccID=0    
   End    
   If (@Status & 64)<>0 --Previous year pending bill cancelled in current year.    
   Begin    
    Execute sp_acc_gj_closebill @BillID --Close Bill    
   End    
  End    
  Else    
  Begin    
   If (@Status & 64)=0 --not cancelled    
   Begin    
    If isnull(dbo.gettrueval(@BillReference),N'')=N''    
    Begin    
     Execute sp_acc_gjexistbill_adjustments @BillID
     Execute sp_acc_gj_billgrn @BillID    
    End    
    Else    
    Begin    
     Execute sp_acc_gjexistbill_adjustments @BillID
     Execute sp_acc_gj_billamendment @BillID    
    End      
   End    
   Else    
   Begin    
    --Entries before cancel bill     
    If isnull(dbo.gettrueval(@BillReference),N'')=N''    
    Begin    
     Execute sp_acc_gjexistbill_adjustments @BillID
     Execute sp_acc_gj_billgrn @BillID    
    End    
    Else    
    Begin    
     Execute sp_acc_gjexistbill_adjustments @BillID
     Execute sp_acc_gj_billamendment @BillID    
    End      
       
    Execute sp_acc_gj_closebill @BillID --Close Bill    
   End    
  End    
  Update FAUpgradeStatus Set DocumentID=@BillID Where ModuleName = @MODULENAME    
  Commit Tran    
  FETCH NEXT FROM ScanBillTransaction INTO @BillId, @Status, @BillReference    
 END    
 CLOSE ScanBillTransaction    
 DEALLOCATE ScanBillTransaction    
 Update FAUpgradeStatus Set Status=1 Where ModuleName = @MODULENAME     
End 
