
Create Procedure sp_CheckCreditLimitForCustomer_ITC(@SalesmanID int,@CustID nvarchar(30), @Mode int = 0 )  
As  
Begin  
	Declare @Status int, @GrpCount int, @NotDefined int, @CustType int, @PayMode int  
	
	If @Mode  = 0 
	Begin
		-- To get Customer Type   
		Select @PayMode=Payment_Mode From Customer Where CustomerID=@CustID  
		
		If @PayMode = 2   -- Credit  
		Set @CustType = 0  
		Else     -- Cash/Cheque/DD  
		Set @CustType = 1  
		
		-- To get status of defined/not defined category  
		Select @GrpCount = Count(*) From CustomerCreditLimit Where CustomerID = @CustID  
		Select @NotDefined = Count(*) From CustomerCreditLimit Where CustomerID = @CustID And NoOfBills < 0

		If (IsNull(@GrpCount,0) = IsNull(@NotDefined,0)) -- Nothing is defined  
		Set  @Status = 0  
		Else  
		Set @Status = 1  
		
		Select 'CustType'=@CustType, 'DFStatus'=@Status  
	End
	Else If @Mode = 1
	Begin
		Select @GrpCount = Count(*) From CustomerCreditLimit Where CustomerID = @CustID  
		Select @NotDefined = Count(*) From CustomerCreditLimit Where CustomerID = @CustID And CreditLimit < 0
	
		If (IsNull(@GrpCount,0) = IsNull(@NotDefined,0)) -- Nothing is defined  
		Set  @Status = 0  
		Else  
		Set @Status = 1  

		Select @Status
	End
End


