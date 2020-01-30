CREATE procedure sp_list_Cheques(@BankID integer)
as
Declare @ChequeID Int,@LastIssued Int,@ChequeEnd Int
Declare @ChequeBookName nvarchar(255),@TotalLeaves Int
Declare @ChequeStart Int, @i Int
Declare @BankCode nvarchar(50)
Declare @Exists1 Int
Declare @Exists2 Int
Declare @Exists3 Int

Select @BankCode = BankCode 
From Bank Where BankID = @BankID

Create Table #TempCheques(ChequeID Int,LastIssued Int,ChequeEnd Int,
ChequeBookName nvarchar (255)) 

Declare scancheques Cursor Keyset For 
select ChequeID,case when LastIssued is null then Cheque_Start else
case when (Cheque_Start + Total_Leaves)-1 = LastIssued then LastIssued else  LastIssued + 1 end end,
Cheque_Start + Total_Leaves - 1,Cheque_Book_Name,Total_Leaves,Cheque_Start from cheques 
where BankID = @BankID and Active = 1

Open scancheques
Fetch From scancheques Into @ChequeID,@LastIssued,@ChequeEnd,@ChequeBookName,@TotalLeaves,@ChequeStart
While @@Fetch_Status = 0
Begin	
	Set @i = @ChequeStart	
	While @i <= (@ChequeStart + @TotalLeaves)- 1
	Begin		
		If Exists(Select Cheque_Number from Payments where IsNull(Cheque_Number,0) = @i
		and Isnull(Cheque_id,0)=@Chequeid
		and IsNull(BankCode,N'') = @BankCode and IsNull(PaymentMode,0)= 1
		and Isnull(Status,0) & 128 = 0 and ISnull(Status,0) & 64=0)
		Begin
			Set @Exists1 = 1 
		End
		Else
		Begin
			Set @Exists1 = 0
		End		
		
		If Exists(Select DDChequeNumber from Payments where IsNull(DDChequeNumber,0) = @i
		and Isnull(Cheque_id,0)=@Chequeid
		and IsNull(BankCode,N'') = @BankCode and IsNull(PaymentMode,0)= 2
		and IsNull(DDMode,0) = 1 and Isnull(Status,0) & 128 = 0 and ISnull(Status,0) & 64=0)
		Begin
			Set @Exists2 = 1 
		End
		Else
		Begin
			Set @Exists2 = 0
		End	
		/*For Non-Accounts Version deposits table shud not be checked*/
		if exists 
		(select * from dbo.sysobjects where id = object_id(N'[dbo].[Deposits]') 
		and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		Begin
			If Exists(Select ChequeNo from Deposits,Cheques where IsNull(ChequeNo,0) = @i
			and Isnull(Deposits.Chequeid,0)=@Chequeid
			and IsNull(Cheques.BankCode,N'') = @BankCode and IsNull(TransactionType,0) in ( 2,6)
			and IsNull(WithdrawlType,0) = 1 and IsNull(Status,0)<> 192 
			and Deposits.ChequeID = Cheques.ChequeID)
			Begin
				Set @Exists3 = 1 
			End
			Else
			Begin
				Set @Exists3 = 0
			End		
	
			If @Exists1 = 0 and @Exists2 = 0 and @Exists3 = 0 
			Begin
				Insert #TempCheques
				Select @ChequeID,@i,@ChequeEnd,@ChequeBookName
				Goto skip1
			End  
		End		
		Else
		Begin
			If @Exists1 = 0 and @Exists2 = 0 
			Begin
				Insert #TempCheques
				Select @ChequeID,@i,@ChequeEnd,@ChequeBookName
				Goto skip1
			End  
		End			
		Set @i = @i + 1
	End
	
Skip1:
	Fetch Next From scancheques Into @ChequeID,@LastIssued,@ChequeEnd,@ChequeBookName,@TotalLeaves,@ChequeStart
End
Select * from #TempCheques

Close scancheques
Deallocate scancheques
Drop Table #TempCheques











