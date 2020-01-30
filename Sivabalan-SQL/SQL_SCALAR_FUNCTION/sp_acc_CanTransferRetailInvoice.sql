CREATE Function sp_acc_CanTransferRetailInvoice(@PaymentDetails VarChar(2000))  
Returns INT  
AS  
Begin  
 Declare @CHEQUE INT
 Declare @CREDITCARD INT                      
 Declare @COUPON INT                      
 Declare @PaymentMode INT  
 Declare @Count INT  
 Declare @CollectionID INT  
 Declare @PositionFound INT  
 DECLARE @ReturnValue INT  
 DECLARE @COLSEP AS VarChar(5)  

 Set @PositionFound = CharIndex(':',@PaymentDetails,1)  
 If @PositionFound > 0 GoTo StopFunction
  
 Set @CHEQUE = 2
 Set @CREDITCARD = 3                      
 Set @COUPON = 4                      
 SET @COLSEP = ','  
   
 DECLARE ScanTemp Cursor KeySet For  
 Select * from SqlSplit1(@PaymentDetails,@COLSEP)   
 Open ScanTemp   
 Fetch From ScanTemp Into @CollectionID  
 While @@FETCH_STATUS = 0  
 Begin  
  Select @PaymentMode=IsNULL(PaymentMode,0) from Collections Where IsNULL(RetailUserWise,0) = 1 And DocumentID = @CollectionID  
  If IsNULL(@PaymentMode,0) = 3  
   Begin  
    Select @Count=Count(*) from ContraDetail,ContraAbstract Where DocumentType = 2   
    And PaymentType = @CREDITCARD And (IsNULL(Status, 0) & 192) = 0   
    And ContraDetail.ContraID = ContraAbstract.ContraID And IsNULL(DocumentReference,0)=@CollectionID  
    If @Count = 0  
     Begin      
      Set @ReturnValue = 1  
      GoTo StopCursor  
     End  
   End  
  Else If IsNULL(@PaymentMode,0) = 5  
   Begin  
    Select @Count=Count(*) from Coupon Where CollectionID = @CollectionID And SerialNo Not IN  
    (Select DocumentReference from ContraDetail,ContraAbstract Where DocumentType = 3            
    And PaymentType = @COUPON And ContraAbstract.ContraID = ContraDetail.ContraID   
    And (IsNULL(ContraAbstract.Status, 0) & 192) = 0)  
    If @Count > 0  
     Begin      
      Set @ReturnValue = 1  
      GoTo StopCursor  
     End  
   End  
  Else If IsNULL(@PaymentMode,0) = 1
   Begin  
    Select @Count=Count(*) from ContraDetail,ContraAbstract Where DocumentType = 2   
    And PaymentType = @CHEQUE And (IsNULL(Status, 0) & 192) = 0   
    And ContraDetail.ContraID = ContraAbstract.ContraID And IsNULL(DocumentReference,0)=@CollectionID  
    If @Count = 0  
     Begin      
      Set @ReturnValue = 1  
      GoTo StopCursor  
     End  
   End  
  Fetch Next From ScanTemp Into @CollectionID  
 End  
StopCursor:  
 Close ScanTemp  
 DeAllocate ScanTemp  
StopFunction:  
 Return IsNULL(@ReturnValue,0)  
End  
