
Create Function dbo.mERP_fn_getFromDate (@FromMonth nvarchar(100))  
Returns datetime  
AS  
BEGIN  
 Declare @fromdate datetime  
 set @fromdate = dbo.stripdatefromtime(convert(varchar, '01-'+ @FromMonth, 103))  
 return @fromdate  
END  
