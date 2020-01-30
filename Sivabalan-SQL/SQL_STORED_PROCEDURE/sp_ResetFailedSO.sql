Create Procedure sp_ResetFailedSO
AS
BEGIN
	Update Order_header set processed= 0 where month(order_date)=month(getdate()) and year(order_date)=year(getdate()) and day(order_date)=day(getdate())
				  And isnull(processed,0)=1 and ordernumber not in 
				  (select POreference from SOAbstract where month(SODate)=month(getdate()) and year(SODate)=year(getdate()) and day(SODate)=day(getdate()))
		
END
