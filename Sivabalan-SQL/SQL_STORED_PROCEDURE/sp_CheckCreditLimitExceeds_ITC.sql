Create Procedure sp_CheckCreditLimitExceeds_ITC  
(  
 @Frm int = 0,  
 @SalesmanID int = 0,   
 @BeatID int = 0,   
 @CustomerID nvarchar(30) = N'',   
 @GroupId nVarchar = N'',   
 @InvoiceAmt decimal(18,6) = 0,   
 @CustBalance decimal(18,6) = 0,  
 @CustCL decimal(18,6) = 0  
)  
As  
Begin  
 Declare @GroupOutStanding decimal(18,6)  
 Declare @GroupBalance decimal(18,6)  
 Declare @GroupCL decimal(18,6)  
 Declare @Flag int  

	If @CustCL = -1 
	Begin
		Set @Flag = 0
		GoTo Done
	End

 --CreditLimit exceeds for customer  
	If @CustBalance > @CustCL   
	Begin  
	Set @Flag = 1 --Exceeds  
	GoTo Done  
	End  
  
 --If no group is defined or if all categories set, then no need to check for group validation  
	If @GroupId = '0'  
	Begin  
	Set @Flag = 0
	GoTo Done  
	
	End  
	---If CreditLimit not defined for the group then dont do validation
	--Select @GroupCL = CreditLimit From CustomerCreditLimit Where CustomerID = @CustomerID And GroupID = @GroupId  
	If @GroupCL < 0 
 	Begin 
	Set @Flag = 0
	GoTo Done  		
	End	
	--3 -InvoiceAmendment, 4-Invoice (When @InvoiceAmt>0) 5- Invoice(When @InvoiceAmt=0)

	If @Frm = 3 or @Frm = 4
	Begin  
		--Select @GroupOutStanding = dbo.fn_get_Customer_OutStanding_Balance_ITC(@CustomerID, @GroupId )  
		Set @GroupOutStanding = 0 - @GroupOutStanding  
		
		--Select @GroupCL = CreditLimit From CustomerCreditLimit Where CustomerID = @CustomerID And GroupID = @GroupId  
		
		Set @GroupBalance = @GroupCL - @GroupOutStanding  
		
		If @InvoiceAmt > @GroupBalance  
		Set @Flag = 1 --Exceeds   
		Else  
		Set @Flag = 0
	End 

	If  @Frm = 5 --This is just to display Customer credit limit exceeds msg
	Begin

		--Select @GroupOutStanding = dbo.fn_get_Customer_OutStanding_Balance_ITC(@CustomerID, @GroupId )  
		Set @GroupBalance = @GroupOutStanding - @InvoiceAmt
		Set @GroupBalance = 0 - @GroupBalance
		
		If @InvoiceAmt = 0		
		Begin
			If @GroupBalance >= @GroupCL  
			Set @Flag = 1 --Exceeds   
			Else  
			Set @Flag = 0
		End
		Else
		Begin	
	  		If @GroupBalance > @GroupCL  
			Set @Flag = 1 --Exceeds   
			Else  
			Set @Flag = 0
		End

	End
  
Done:  
	Select @Flag  
End  

