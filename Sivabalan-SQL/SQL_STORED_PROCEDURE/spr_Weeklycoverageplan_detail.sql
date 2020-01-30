CREATE  procedure spr_Weeklycoverageplan_detail (@Salesmancode as nvarchar(15), @Fromdate datetime, @Unused1 as NVarchar(100), @Unused2 as NVarchar(100))        
as        
Declare @TemFromdate datetime        
Declare @alter nvarchar(250)        
declare @Assigndate nvarchar(25)        
declare @incrementdate int        
declare @insertstmt nvarchar(200)        
declare @customerid nvarchar(15)        
declare @insertcolumn nvarchar(25)        
Declare @nCount Int          
Declare @nTempCount Int  
Declare @companyName Nvarchar(255)        
create table #temp(SerialID int)        
 set @incrementdate = 0         
 while (@incrementdate < 7)        
 begin        
  set @TemFromdate = DateAdd(dd,@incrementdate,@Fromdate)        
  --to find length for month and date        
  Select @Assigndate = Cast(DatePart(dd, @TemFromdate) as nvarchar(2))-- + '/' + Cast(DatePart(mm, @Date1) as NVarchar(2)) + '/' + Cast(DatePart(yyyy, @Date1) as nvarchar(4))        
  if len(@Assigndate) <= 1        
   set @insertcolumn = '0'+ @Assigndate        
  else        
   set @insertcolumn = @Assigndate        
  Select @Assigndate = Cast(DatePart(mm, @TemFromdate) as NVarchar(2))        
  if len(@Assigndate) <= 1        
   set @insertcolumn = @insertcolumn + '/' + '0' + @Assigndate + '/' + Cast(DatePart(yyyy, @TemFromdate) as nvarchar(4))        
  else        
   set @insertcolumn = @insertcolumn + '/' +  @Assigndate + '/' + Cast(DatePart(yyyy, @TemFromdate) as nvarchar(4))        
        
  Set @Alter = 'Alter Table #Temp Add [' + @insertcolumn + '] nvarchar(255)'        
  Exec sp_executesql @Alter        
        
 DECLARE Salesman_Cursor CURSOR FOR select Distinct cr.customerid,cr.Company_name from WcpAbstract as Wt,WCPDetail as wd,customer as cr,salesman as sp where cr.customerid not in('0') and wt.code =wd.code        
 And sp.salesmancode = wt.salesmanid and cr.customerid = wd.customerid and wd.wcpdate =cast(@insertcolumn as datetime) and wt.salesmanid =@Salesmancode And (isnull(Wt.status,0)&128)=0       
 And (isnull(Wt.status,0)& 32)=0  	      
        
 Set @nCount = 1        
 Set @nTempCount = 1        
 OPEN Salesman_Cursor        
  FETCH NEXT FROM Salesman_Cursor INTO @customerid,@companyName        
  WHILE @@FETCH_STATUS = 0        
   BEGIN            
    If @incrementdate = 0        
    Begin        
     set @insertstmt ='insert into #temp([SerialID],['+ @insertcolumn +']) Values('+ Cast(@nCount as varchar) + ',' + '''' + @companyName + ''')'        
     Exec sp_executesql @insertstmt        
    End        
    Else        
    Begin             
    --set @insertstmt = 'Select @nTempCount = Count(*) From #Temp Where [' + @insertcolumn +'] = Null'             
     If Exists (Select * From #Temp Where SerialID = @nTempCount)        
      set @insertstmt ='Update #temp Set ['+ @insertcolumn +'] = ' + '''' + @companyName + ''' Where SerialID = ' + Cast(@nTempCount as varchar)              
     Else        
      set @insertstmt ='insert into #temp([SerialID],['+ @insertcolumn +']) Values('+ Cast(@nCount as varchar) + ',' + '''' + @companyName + ''')'         
     Exec sp_executesql @insertstmt        
    End        
    Set @nCount = @nCount + 1        
    Set @nTempCount = @nTempCount + 1        
    FETCH NEXT FROM Salesman_Cursor INTO @customerid,@companyName         
   END        
 CLOSE Salesman_Cursor        
 DEALLOCATE Salesman_Cursor        
 set @incrementdate = @incrementdate + 1        
 set @insertcolumn = ''        
end        
select * from #temp        
drop table #temp        
    
    
  
  




