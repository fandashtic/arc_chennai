Create Procedure sp_isAnyFailedSO
AS
BEGIN
	If exists (Select 'x' from Order_header where month(order_date)=month(getdate()) and year(order_date)=year(getdate()) and day(order_date)=day(getdate())
				  And isnull(processed,0)=1 and ordernumber not in 
				  (select POreference from SOAbstract where month(SODate)=month(getdate()) and year(SODate)=year(getdate()) and day(SODate)=day(getdate())))
		Select 1
	Else
		Select 0
END
