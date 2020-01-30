CREATE procedure sp_acc_validatechequenumber(@ChequeNumber Int,@BankCode nVarchar(100),@CkName nvarchar(50))  
as  
Declare @Exists1 Int  
Declare @Exists2 Int  
Declare @Exists3 Int  
Declare @CkID int

select @ckid = ChequeID from cheques where Cheque_Book_Name = @CkName
  
If Exists(Select Cheque_Number from Payments where IsNull(Cheque_Number,0) = @ChequeNumber   
 and IsNull(BankCode,N'') = @BankCode and IsNull(PaymentMode,0)= 1  
 and IsNull(Status,0)<> 192 and IsNull(Status,0)<> 128  
 and ((IsNull(Status,0) & 64) = 0) and ((IsNull(Status,0) & 128) = 0)
 and Cheque_ID = @ckid)  
Begin  
 Set @Exists1 = 1   
End  
Else  
Begin  
 Set @Exists1 = 0  
End  
  
--Select @Exists1  
  
  
If Exists(Select DDChequeNumber from Payments where IsNull(DDChequeNumber,0) = @ChequeNumber  
 and IsNull(BankCode,N'') = @BankCode and IsNull(PaymentMode,0)= 2  
 and IsNull(DDMode,0) = 1 and IsNull(Status,0)<> 192 and IsNull(Status,0)<> 128  
 and ((IsNull(Status,0) & 64) = 0) and ((IsNull(Status,0) & 128) = 0)
 and  Cheque_ID = @ckid)  
Begin  
 Set @Exists2 = 1   
End  
Else  
Begin  
 Set @Exists2 = 0  
End  
  
--Select @Exists2  
  
If Exists(Select ChequeNo from Deposits,Cheques where IsNull(ChequeNo,0) = @ChequeNumber  
 and Isnull(Deposits.Chequeid,0)=@ckid
 and IsNull(Cheques.BankCode,N'') = @BankCode and IsNull(TransactionType,0) in (2,6)  
 and IsNull(WithdrawlType,0) = 1 and IsNull(Status,0)<> 192   
 and Deposits.ChequeID = Cheques.ChequeID)  
   
Begin  
 Set @Exists3 = 1   
End  
Else  
Begin  
 Set @Exists3 = 0  
End  
  
--Select @Exists3  
  
If @Exists1 = 0 and @Exists2 = 0 and @Exists3 = 0    
Begin  
 Select 1   
End    
Else  
Begin  
 Select 0  
End  

