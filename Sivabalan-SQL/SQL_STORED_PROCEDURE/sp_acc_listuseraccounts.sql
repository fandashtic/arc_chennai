create procedure sp_acc_listuseraccounts(@UserName nvarchar(100),@PaymentType Int,
@KeyField nvarchar(30)=N'%',@Direction int = 0, 
@BookMark nvarchar(128) = N'')
as
IF @Direction = 1
Begin
	Select AccountID,AccountName,
	(Select GroupName from AccountGroup where 
	Groupid = AccountsMaster.GroupID) as [Account Group] 
    from AccountsMaster,PaymentMode
	where AccountsMaster.UserName = @UserName and PaymentType = @PaymentType
	and PaymentMode.Mode = AccountsMaster.RetailPaymentMode 
	and IsNull(AccountsMaster.Active,0) = 1 and AccountName like @KeyField 
	and AccountName > @BookMark  
	Order by AccountName
End
Else
Begin
	Select AccountID,AccountName,
	(Select GroupName from AccountGroup where 
	Groupid = AccountsMaster.GroupID) as [Account Group] 
	from AccountsMaster,PaymentMode
	where AccountsMaster.UserName = @UserName and PaymentType = @PaymentType
	and PaymentMode.Mode = AccountsMaster.RetailPaymentMode 
	and IsNull(AccountsMaster.Active,0) = 1 and AccountName like @KeyField 
	Order by AccountName
End







