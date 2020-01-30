
Create Function dbo.mERP_fn_getToDate (@ToMonth nvarchar(100))  
Returns datetime  
AS  
BEGIN  
 Declare @Todate datetime  
 set @Todate = dbo.stripdatefromtime(convert(varchar, '01-'+ @ToMonth, 103))  
 -- Increment one month  
 set @Todate= dateadd(m,1,@Todate)  
 -- Decrease one day from the next month  
 set @Todate= dateadd(d,-1,@Todate)  
 return @Todate  
END  
