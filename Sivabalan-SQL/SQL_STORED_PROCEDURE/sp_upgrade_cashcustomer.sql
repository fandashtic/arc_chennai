Create procedure sp_upgrade_cashcustomer
As
Begin
Declare @CustomerID nvarchar(255)
Declare @CustomerName nvarchar(50) 
Declare @Address nvarchar(255)
Declare @DOB DateTime
Declare @ReferredBy Integer
Declare @MembershipCode nvarchar(30)
Declare @Telephone nvarchar(30)
Declare @Fax nvarchar(30)
Declare @ContactPerson nvarchar(30)
Declare @CreationDate DateTime 
Declare @ModifiedDate DateTime 
Declare @OldRetailCustID nvarchar(50) 
Declare @CustFullID nvarchar(50) 
Declare @CustIDPart nvarchar(50) 
Declare @CustIDExists Integer
Declare @Discount Decimal(18,6)
Declare @CatID integer

Declare Retailer Cursor For
Select CustomerID, CustomerName, Address, DOB, ReferredBy, MembershipCode,
Telephone, Fax, ContactPerson, CreationDate, ModifiedDate,Discount,CategoryID
from Cash_Customer 

If exists (Select CustomerID From Customer WHere CustomerID like N'RC%' And Len(Case Isnumeric(CustomerID) when 1 then N'' else left(CustomerID,len(CustomerID)-PATINDEX(N'%[^0-9]%',Reverse(CustomerID))+1) end) = 2)
Begin	
       	Select @CustFullID = Max(Cast((case isnumeric(CustomerID) when 1 then CustomerID else ISnull(REVERSE(left(reverse(CustomerID),PATINDEX(N'%[^0-9]%',Reverse(CustomerID))-1)),0) End) as integer)) From Customer Where CustomerID like N'RC%'
	Select @CustIDPart = case isnumeric(@CustFullID) when 1 then @CustFullID else ISnull(REVERSE(left(reverse(@CustFullID),PATINDEX(N'%[^0-9]%',Reverse(@CustFullID))-1)),0) end
	Set @CustIDExists = 1
End
Else
	Set @CustIDExists = 0


Open Retailer 
Fetch From Retailer Into @OldRetailCustID, @CustomerName, @Address, @DOB, @ReferredBy, 
@MembershipCode,@Telephone, @Fax, @ContactPerson, @CreationDate, @ModifiedDate, @Discount,@CatID
WHILE @@FETCH_STATUS = 0              
BEGIN 

	If @CustIDExists = 1 
	Begin
		Set @CustIDPart = @CustIDPart + 1
		Set @CustomerID = N'RC' + @CustIDPart
	End
	Else
		Set @CustomerID = N'RC' + @OldRetailCustID

	If Exists (Select CustomerID From Customer Where Company_Name = @CustomerName) 
		Set @CustomerName = N'RC' + @CustomerName
	Else
		Set @CustomerName = @CustomerName

	If Isnull(@MembershipCode, N'') = N''
	Begin
		Select @MembershipCode = cast(Isnull(Max(Cast(MemberShipCode as Decimal(30,0))),0)+ 1 as nvarchar) 
		From Customer 
		Where PATINDEX(N'%[^0-9]%',MEMBERSHIPCODE)=0
	End				

	Insert into Customer 
	(CustomerID, Company_Name, First_Name, Second_Name, BillingAddress, DOB, Referredby, MembershipCode,
	Phone, Fax, ContactPerson, CustomerCategory, CreationDate, ModifiedDate, Discount,RetailCategory)
	Values(@CustomerID, @CustomerName + N' ', @CustomerName, N' ' , @Address, @DOB, Isnull(@ReferredBy,0), @MembershipCode,
	@Telephone, @Fax, @ContactPerson, 4, @CreationDate, @ModifiedDate,IsNull(@Discount,0),@CatID)

	Update InvoiceAbstract Set CustomerID = @CustomerID Where InvoiceType = 2 and CustomerID = @OldRetailCustID
--	Update Collections Set CustomerID = @CustomerID Where CustomerID = @OldRetailCustID

Fetch From Retailer Into @OldRetailCustID, @CustomerName, @Address, @DOB, @ReferredBy, 
@MembershipCode,@Telephone, @Fax, @ContactPerson, @CreationDate, @ModifiedDate, @Discount,@CatID
END 
Close Retailer
Deallocate Retailer
End



