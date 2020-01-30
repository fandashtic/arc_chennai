Create procedure dbo.spr_list_saleswiseproc(@SName nvarchar(2550),@rtype nvarchar(20),@From datetime,@To datetime)        
As        
Declare @saltype as int    
Declare @status as int    
Declare @OTHERS As NVarchar(50)

Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

Create table #tmpSalesMan(SalesManName nvarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)  

if @SName='%'   
	Insert into #tmpSalesMan select salesman_name from SalesMan  
Else  
	Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@SName,@Delimeter)  

If @rtype = 'Damages'    
Begin    
	Set @saltype = 32    
	Set @status = 32    
End    
Else If @rtype = 'Saleable'    
Begin    
	Set @status = 0    
	set @saltype = 32    
End    
Else    
Begin    
	Set @status = 0    
	Set @saltype = 0    
End    

if @SName = '%'     
Begin    
	select Cast(IsNull(t2.Salesman_name,@OTHERS) As nvarchar(255)) + ';' + @rtype, IsNull(Salesman_name, @OTHERS) as Salesman,sum(netvalue)-sum(IsNull(freight,0)) as TotalValue         
	from invoiceabstract t1
	Left Outer Join salesman t2  On t1.salesmanid = t2.salesmanid         
	where invoicetype=4 and         
	status & @saltype = @status and         
	t2.salesman_name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And    
	Status & 128 = 0 And     
	(invoicedate between @from and @To)         
	group by salesman_name, t2.SalesmanID        
End    
Else    
Begin    
	select Cast(Isnull(t2.Salesman_name,@OTHERS) As nvarchar(255)) + ';' + @rtype, IsNull(Salesman_name, @OTHERS) as Salesman,sum(netvalue)-sum(isnull(freight,0)) as TotalValue         
	from invoiceabstract t1,salesman t2         
	where invoicetype=4 and         
	Status & 128 = 0 And     
	status & @saltype = @status and         
	t2.salesman_name In (Select SalesManName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpSalesMan) And    
	(t1.salesmanid = t2.salesmanid) and         
	(invoicedate between @from and @To)         
	group by salesman_name, t2.SalesmanID        
End 
Drop table #tmpSalesMan
