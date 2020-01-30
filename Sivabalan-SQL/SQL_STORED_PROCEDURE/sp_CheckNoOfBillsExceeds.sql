

CREATE Procedure sp_CheckNoOfBillsExceeds(@CustID nvarchar(30), @Value int)  
As  
Begin  
	Declare @NoOfBillsCust as int  
	Declare @NoOfBillsGroup as int  
	
	Select @NoOfBillsCust =  IsNull(NoOfBillsOutstanding,0) From Customer Where CustomerID = @CustID  
	---If NoOfBills not defined for the customer then skip
	If @NoOfBillsCust = 0 
		Select 0
	Else
	Begin
		Select  @NoOfBillsGroup = Sum( NoOfBills) From CustomerCreditLimit Where CustomerID =  @CustID  
	
		Set @NoOfBillsGroup = @NoOfBillsGroup + @Value  
	
		If  @NoOfBillsGroup > @NoOfBillsCust   
			Select 1 --Exceeds  
		Else  
			Select 2
	End  
End  


