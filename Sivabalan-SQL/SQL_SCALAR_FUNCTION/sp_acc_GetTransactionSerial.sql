CREATE Function sp_acc_GetTransactionSerial(@TranType Int,@DocType nVarchar(255),@Cnt Int=-1)  
Returns nVarchar(200)  
as  
Begin  
Declare @TranSerialNo nVarchar(200)  
Declare @LastCnt int  
Declare @GenTranNo int  
Declare @CharacterPart nVarchar(100)  
Declare @NumberPart nVarchar(100)  
  
If (@Cnt=-1)  
 Begin  
  Select @CharacterPart = Case Isnumeric(DocumentNumber) when 1 then '' else left(DocumentNumber,len(DocumentNumber)-PATINDEX('%[^0-9]%',Reverse(DocumentNumber))+1) end,  
   @NumberPart = Case Isnumeric(DocumentNumber) when 1 then DocumentNumber else ISnull(REVERSE(left(reverse(DocumentNumber),PATINDEX('%[^0-9]%',Reverse(DocumentNumber))-1)),0) end,  
   @LastCnt=LastCount from TransactionDocNumber Where TransactionDocNumber.TransactionType = @TranType  
   And TransactionDocNumber.DocumentType = @DocType     
 End  
Else  
 Begin  
  Select @CharacterPart = Case IsNumeric(DocumentNumber) when 1 then '' else left(DocumentNumber,len(DocumentNumber)-PATINDEX('%[^0-9]%',Reverse(DocumentNumber))+1) end,  
   @NumberPart = Case IsNumeric(DocumentNumber) when 1 then DocumentNumber else ISnull(REVERSE(left(reverse(DocumentNumber),PATINDEX('%[^0-9]%',Reverse(DocumentNumber))-1)),0) end  
   from TransactionDocNumber Where TransactionDocNumber.TransactionType = @TranType  
   And TransactionDocNumber.DocumentType = @DocType      
   Select @LastCnt = @Cnt      
 End  
  
if (@NumberPart <> 0)  
 Select @GenTranNo = Cast(@NumberPart as int) + @LastCnt  
Else  
 Select @GenTranNo = @LastCnt + 1  
  
if Len(@GenTranNo) <= Len(@NumberPart)  
 begin  
  Select @TranSerialNo = @CharacterPart + Stuff(@NumberPart,Len(@NumberPart)-Len(@GenTranNo)+ 1,Len(@GenTranNo),@GenTranNo)  
 End  
Else  
 begin  
  Select @TranSerialNo = @CharacterPArt + CAST(@GenTranNo AS nVARCHAR)  
 End  
   
RETURN(@TranSerialNo)  
End 
