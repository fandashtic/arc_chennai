Create Function mERP_fn_Get_GVCustomerSalesman(@SalesMan nvarchar(2000))
Returns @Customer table(CustomerID nvarchar(50)) 
As
Begin
  Declare @tmpSman table(Salesman Int)
  if @SalesMan = 'All DS' or @SalesMan = '' or @SalesMan = '%%'
     Begin
     Insert into @tmpSman Select 0
     Insert into @tmpSman
     select Distinct SalesmanID from CreditNote Where IsNull(Flag,0) in (1,2) and IsNull(status,0) not in (64,128)
	 End 
  else
     Insert into @tmpSman
     select salesmanID from salesman Where salesman_name in(select * from dbo.sp_SplitIn2Rows(@SalesMan,','))

  Insert into @Customer
  Select CN.CustomerID
  From CreditNote CN
  Left Outer Join  Salesman SM On CN.SalesmanID = SM.SalesmanID 
  Where IsNull(CN.Flag,0) in(1,2) and IsNull(CN.status,0) not in (64,128) 
  and SM.SalesmanID in(Select * from @tmpSman)

  Return
End
