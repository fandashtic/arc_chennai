CREATE procedure [dbo].[Spr_EFF_ProdReport]    
(@sname nvarchar(2550),@fromdate datetime,@todate datetime)    
AS    
    
         DECLARE @SDATE DATETIME    
         DECLARE @Smanname nvarchar(100)    
         DECLARE @Smanno integer    
         DECLARE @Smanamt decimal(10,3)    
         DECLARE @SQl1 nvarchar(4000)    
         DECLARE @SumColumn nvarchar(4000)    
  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
  
Create table #tmpSal(Salesman_Name nvarchar(255))    

Declare @OTHERS NVarchar(50)
Set @OTHERS=dbo.LookupDictionaryItem(N'Others', Default)
  
if @sname=N'%'     
   Insert into #tmpSal select Salesman_Name from Salesman    
Else    
   Insert into #tmpSal select * from dbo.sp_SplitIn2Rows(@sname, @Delimeter)    
  
    
         Create Table #Stemp    
  (    
          Sdate datetime,    
          SMName nvarchar(100),    
          Countno integer,    
          Total_Value decimal(10,3),            
  )    
  set @sql1=N'Select "SDate"=Sdate'    
  SET @SumColumn = N''    
    
SET DATEFORMAT DMY    
SET QUOTED_IDENTIFIER off    
    
    
if (@sname<>N'%')    
   BEGIN       
        Insert into #Stemp    
 SELECT "Sdate"= dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),     
 "SMName"=Case when Salesman.SalesMan_Name is null then @OTHERS     
                      else Salesman.SalesMan_Name     
                 end,     
        "Countno" = Count(dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)),     
        "Total Value" = Sum(Case when Invoiceabstract.INvoicetype <> 4 then  netValue    
                    else 0-netvalue end) FROM InvoiceAbstract, Salesman     
         Where InvoiceAbstract.SalesManID = Salesman.SalesManID AND    
         InvoiceAbstract.InvoiceDate Between @fromdate And @todate    
         and Invoiceabstract.InvoiceType <> 2 and Salesman.SalesMan_name In (Select Salesman_Name From #tmpsal)    
         and (Invoiceabstract.Status & 128)=0    
         GROUP BY dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), Salesman.SalesMan_Name    
    END    
else    
    BEGIN     
        Insert into #Stemp    
 SELECT "Sdate"= dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate),     
 "SMName"=Case when Salesman.SalesMan_Name is null then @OTHERS     
                      else Salesman.SalesMan_Name     
                 end,     
        "Countno" = Count(dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate)),     
        "Total Value" = Sum(Case when Invoiceabstract.INvoicetype<>4 then  netValue    
                    else 0-netvalue end) FROM InvoiceAbstract, Salesman     
         Where InvoiceAbstract.SalesManID *= Salesman.SalesManID AND    
         InvoiceAbstract.InvoiceDate Between @fromdate And @todate    
         and Invoiceabstract.InvoiceType <> 2             
         and (Invoiceabstract.Status & 128)=0    
         GROUP BY dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate), Salesman.SalesMan_Name    
     END    
    
    
    
DECLARE DYNTABCUR CURSOR FOR    
  SELECT [SMName] FROM #Stemp GROUP BY [SMName]    
open DYNTABCUR    
   fetch NEXT FROM DYNTABCUR into @smanname    
    
  WHILE @@FETCH_STATUS =0    
  BEGIN    
    select @sql1= @Sql1 + N',"'+ @smanname + N' (No of bills)"=NULL, "'+ @smanname + N' (Bill Value)"=#stemp.Total_Value'    
    SELECT @SumColumn = @SumColumn + N',"' + @smanname + N' (No of bills)"=' + N' Sum(isnull([' + @smanname + N' (No of bills)],0)),"' + @smanname + N' (Bill Value)"=' + N' Sum(isnull([' + @smanname + N' (Bill Value)],0.00)) '    
    fetch NEXT FROM DYNTABCUR into @smanname    
  END    
    
CLOSE DYNTABCUR    
DEALLOCATE DYNTABCUR    
    
SELECT @SQL1 = @SQL1 + N' INTO #temp1 FROM #Stemp WHERE 1 < 0'    
    
    
DECLARE LOADVALCUR CURSOR FOR    
  SELECT [sdate],[SMName],Sum([countno]),Sum([Total_value]) FROM #STEMP GROUP BY [SMName], [sDate]    
    
  open LOADVALCUR    
  fetch NEXT FROM LOADVALCUR into @sdate,@smanname,@smanno,@smanamt    
    
  WHILE @@FETCH_STATUS =0    
  BEGIN       
    SELECT @sql1= @sql1 + N';INSERT INTO #temp1([SDate],[' + @smanname + N' (No of bills)], [' + @smanname + N' (Bill Value)]) Values("' + Cast(@sdate As nvarchar) + N'",' + Cast(@smanno As nVarchar) + N',' + Cast(@smanamt As nVarchar) + N')'        
    EXEC(@sql1)        
    fetch NEXT FROM LOADVALCUR into @sdate,@smanname,@smanno,@smanamt    
  END    
    
CLOSE LOADVALCUR    
DEALLOCATE LOADVALCUR    
    
SELECT @SQL1 = N'Set dateformat mdy;' + @SQL1 + N';SELECT SDate,"Date"=Convert(nvarchar(20),Cast(SDate as datetime),103)' + @SumColumn + N' FROM #temp1 GROUP BY SDate;DROP TABLE #temp1;Set dateformat mdy'    
exec(@SQL1)    
DROP TABLE #STEMP    
    
Drop table #tmpSal
