CREATE Procedure sp_acc_checkretailinvoicecancel (@INVOICEID INT)        
As        
Declare @UserName nVarchar(100)        
Declare @PaymentDetails nVarchar(510)        
Declare @AccountBalance Decimal(18,6), @ReturnValue INT        
Declare @RetailPaymentMode INT                 
Declare @FindPos INT        
Declare @RECSPLIT As nVarChar(15)          
Set @RECSPLIT = N','          
        
Declare @CASHTYPE Int,@CHEQUETYPE Int,@CREDITCARDTYPE Int,@COUPONTYPE Int,@OTHERSTYPE INT        
Set @CASHTYPE=1        
Set @CHEQUETYPE=2        
Set @CREDITCARDTYPE=3        
Set @COUPONTYPE=4        
Set @OTHERSTYPE=5        
                   
Select @UserName = UserName, @PaymentDetails = IsNULL(PaymentDetails,N''),         
@RetailPaymentMode = PaymentMode from InvoiceAbstract Where InvoiceID = @InvoiceID        
                       
If IsNULL(@RetailPaymentMode,0) <> 0 /*0 = Credit RetailInvoice*/        
 Begin            
  Set @FindPos = CharIndex(N':', @PaymentDetails, 1)          
  If @FindPos > 0 /*This is to Handle Old Implementation*/          
   Begin        
    Create Table #TempFirstSplit(FirstSplitRecords nVarchar(4000))        
    Create Table #TempSecondSplit(SecondSplitRecords nVarchar(4000))        
    Create Table #DynamicPaymentTable(PaymentMode nVarchar(150),AmtRecd Decimal(18,6),Detail nVarchar(255),AmtReturned Decimal(18,6))        
    Declare @FirstSplitRecords nVarchar(4000)        
    Declare @SecondSplitRecords nVarchar(4000)        
    Declare @Flag Int        
    Declare @Local as nVarchar(250)        
    Declare @ColumnCount Int        
            
    Set @Flag=0        
    Set @ColumnCount=1        
           
    Declare @FIRSTSPLIT nVarchar(15),@SECONDSPLIT nVarchar(15)        
    Set @FIRSTSPLIT = N';'        
    Set @SECONDSPLIT = N':'        
           
    Declare @SumAmtRecd Decimal(18,6),@SumAmtReturned Decimal(18,6),@AccountName nVarchar(255),@GroupID Int,@NewAccountID Int        
    Declare @AdjustedAmount Decimal(18,6),@ExtraAmount Decimal(18,6),@PaymentID Int,@PaymentType Int        
    Declare @PayMode nVarchar(150),@AmtRecd Decimal(18,6),@Detail nVarchar(255),@AmtReturned Decimal(18,6)        
           
    Insert #TempFirstSplit        
    Exec Sp_acc_SQLSplit @PaymentDetails,@FIRSTSPLIT        
    --Select * From #TempAssetRow        
    DECLARE scantempfirst CURSOR KEYSET FOR        
    select FirstSplitRecords from #TempFirstSplit         
            
    OPEN scantempfirst        
    FETCH FROM scantempfirst INTO @FirstSplitRecords        
            
    WHILE @@FETCH_STATUS =0        
    BEGIN        
     Insert #TempSecondSplit        
     Exec Sp_acc_SQLSplit @FirstSplitRecords,@SECONDSPLIT        
           
     DECLARE scantempsecond CURSOR KEYSET FOR        
     select SecondSplitRecords from #TempSecondSplit         
             
     OPEN scantempsecond        
     FETCH FROM scantempsecond INTO @SecondSplitRecords        
             
     WHILE @@FETCH_STATUS =0        
     BEGIN        
      If @Flag=0        
      Begin        
       Insert #DynamicPaymentTable Values(@SecondSplitRecords,0,0,0)        
       Set @Flag=1        
       Set @Local=@SecondSplitRecords        
       Set @ColumnCount=@ColumnCount+1        
      End        
      Else        
      Begin        
       If @ColumnCount=2        
        Update #DynamicPaymentTable Set AmtRecd=Cast(@SecondSplitRecords as Decimal(18,6)) where PaymentMode=@Local        
       Else If @ColumnCount=3        
        Update #DynamicPaymentTable Set Detail=@SecondSplitRecords where PaymentMode=@Local        
       Else If @ColumnCount=4        
        Update #DynamicPaymentTable Set AmtReturned=Cast(@SecondSplitRecords as Decimal(18,6)) where PaymentMode=@Local        
           
       Set @ColumnCount=@ColumnCount+1        
      End        
        FETCH NEXT FROM scantempsecond INTO @SecondSplitRecords        
     END        
     CLOSE scantempsecond        
     DEALLOCATE scantempsecond        
     Set @Flag=0        
     Set @local=Null        
     Delete #TempSecondSplit        
     Set @ColumnCount=1        
       FETCH NEXT FROM scantempfirst INTO @FirstSplitRecords        
    END        
    CLOSE scantempfirst        
    DEALLOCATE scantempfirst        
    ---------------------------------------------------        
    DECLARE scandynamictable CURSOR KEYSET FOR        
    Select PaymentMode,AmtRecd,Detail,AmtReturned from #DynamicPaymentTable        
          
    OPEN scandynamictable        
    FETCH FROM scandynamictable INTO @PayMode,@AmtRecd,@Detail,@AmtReturned        
            
    WHILE @@FETCH_STATUS =0        
    BEGIN        
     Select @PaymentID=Mode,@PaymentType=IsNULL(PaymentType,0) from PaymentMode where Value=@PayMode and IsNULL(@AmtRecd,0)<>0        
           
     Select @NewAccountID=AccountID from AccountsMaster where UserName=@Username and RetailPaymentMode=@PaymentID        
     Set @AccountBalance=dbo.sp_acc_getaccountbalance(@NewAccountID,dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate())))        
     If (IsNULL(@AccountBalance,0) - IsNULL(@AmtRecd,0) + IsNULL(@AmtReturned,0)) < 0        
     Begin        
      Set @ReturnValue= 0          
      Goto Stop         
     End        
     FETCH NEXT FROM scandynamictable INTO @PayMode,@AmtRecd,@Detail,@AmtReturned         
    END        
    Set @ReturnValue=1        
Stop:        
    CLOSE scandynamictable        
    DEALLOCATE scandynamictable        
    ----------------New implememtation of Retail Invoice---------------------        
    Drop Table #TempFirstSplit        
    Drop Table #TempSecondSplit        
    Drop Table #DynamicPaymentTable        
    -------------------------------------------------------------------------        
   End        
  Else /*New Implementation*/        
   Begin        
    Declare @CollectionID INT, @AccountID INT, @ColtnPayMode INT, @RetailUserWise INT            
    Declare @RetailPaymentModeID INT, @ColValue Decimal(18,6), @PayModeType INT        
            
    CREATE Table #TempCollections(CollectionID INT)           
    Insert Into #TempCollections          
    Exec Sp_acc_SQLSplit @PaymentDetails, @RECSPLIT          
            
    Declare ScanCollections Cursor KeySet FOR        
    Select CollectionID from #TempCollections        
    Open ScanCollections        
    Fetch From ScanCollections Into @CollectionID        
    WHILE @@FETCH_STATUS = 0        
     Begin        
      Select @RetailPaymentModeID = IsNULL(PaymentModeID,0), @ColValue = IsNULL(Value,0), @ColtnPayMode = PaymentMode,        
      @RetailUserWise = IsNULL(RetailUserWise,0) from Collections Where DocumentID = @CollectionID        
      Select @PayModeType = IsNULL(PaymentType,0) from PaymentMode Where Mode = @RetailPaymentModeID            
               
      If IsNULL(@ColValue,0) <> 0 And @ColtnPayMode <> 6 And @ColtnPayMode <> 7        
       Begin        
        If (IsNULL(@RetailUserWise,0) & 1) = 1        
         Begin  
          /*Check whether Cheque/CreditCard/Coupon is transfered to main account(using internal contra)*/  
          If @ColtnPayMode = 1 /*Cheque*/  
           Begin  
            If Exists (Select DocumentReference from ContraDetail,ContraAbstract Where DocumentType=2 And PaymentType=2 And (IsNULL(ContraAbstract.Status, 0) & 192)=0 And ContraAbstract.ContraID=ContraDetail.ContraID And DocumentReference=@CollectionID)  
             Begin  
              Set @ReturnValue = 0          
              Goto StopNew        
             End  
           End  
          Else If @ColtnPayMode = 3 /*Credit Card*/  
           Begin  
            If Exists (Select DocumentReference from ContraDetail,ContraAbstract Where DocumentType=2 And PaymentType=3 And (IsNULL(ContraAbstract.Status, 0) & 192)=0 And ContraAbstract.ContraID=ContraDetail.ContraID And DocumentReference=@CollectionID)  
             Begin  
              Set @ReturnValue = 0          
              Goto StopNew        
             End  
           End  
          Else If @ColtnPayMode = 5 /*Coupon*/  
           Begin  
            If Exists (Select SerialNo from ContraDetail,ContraAbstract,Coupon Where DocumentType=3 And PaymentType=4 And (IsNULL(ContraAbstract.Status, 0) & 192) = 0 And ContraAbstract.ContraID=ContraDetail.ContraID And Coupon.SerialNo=ContraDetail.DocumentReference And Coupon.CollectionID=@CollectionID)  
             Begin  
              Set @ReturnValue = 0          
              Goto StopNew        
             End  
           End  
          Select @AccountID = AccountID from AccountsMaster where UserName = @Username And RetailPaymentMode = @RetailPaymentModeID        
         End  
        Else        
         Begin        
          /*Check whether Cheque/CreditCard/Coupon is deposited*/  
          If @ColtnPayMode = 1 /*Cheque*/  
           Begin  
            If Not Exists (Select * from Collections Where DocumentID=@CollectionID And (ISNULL(DepositID, 0)=0 Or (IsNULL(DepositID,0)<>0 And IsNULL(Status,0)=2)))  
             Begin  
              Set @ReturnValue = 0          
              Goto StopNew        
             End  
           End  
          Else If @ColtnPayMode = 3 /*Credit Card*/  
           Begin  
            If Exists (Select * from Collections Where DocumentID=@CollectionID And IsNULL(OtherDepositID,0)<>0)  
             Begin  
              Set @ReturnValue = 0          
              Goto StopNew        
             End  
           End  
          Else If @ColtnPayMode = 5 /*Coupon*/  
           Begin  
            If Exists (Select * from Coupon Where CollectionID=@CollectionID And IsNUll(CouponDepositID,0)<>0)  
             Begin  
              Set @ReturnValue = 0          
              Goto StopNew        
             End  
           End  
          If @PayModeType = @CASHTYPE                       
           Set @AccountID = 3 -- Cash Account            
          Else If @PayModeType = @CHEQUETYPE                           
           Set @AccountID = 7 -- Cheque In Hand Account            
          Else If @PayModeType = @CREDITCARDTYPE                          
           Set @AccountID = 94 -- CreditCard Account            
          Else If @PayModeType = @COUPONTYPE                          
           Set @AccountID = 95 -- Coupon Account            
          Else If @PayModeType = @OTHERSTYPE                           
           Set @AccountID = 96 -- Others Account            
         End        
                  
        Set @AccountBalance=dbo.sp_acc_getaccountbalance(@AccountID, dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate())))        
        If (IsNULL(@AccountBalance, 0) - IsNULL(@ColValue, 0)) < 0        
         Begin        
          Set @ReturnValue = 0          
          Goto StopNew        
         End        
       End        
      Fetch Next From ScanCollections Into @CollectionID        
     End        
    Set @ReturnValue = 1          
StopNew:        
    CLOSE ScanCollections        
    DEALLOCATE ScanCollections        
   End        
 End        
Else        
 Begin        
  Set @ReturnValue = 1           
 End        
         
Select @ReturnValue 

