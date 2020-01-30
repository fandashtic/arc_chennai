CREATE Procedure spr_list_TaxSummary_ITC @FROMDATE datetime,@TODATE datetime,@TaxCmpBrkUP nvarchar(10)='No'                            
AS         
Begin                             
create table #TaxSummary(Tax_code int,[Tax Description] nvarchar(255),                          
[Sales Amt.] decimal(18,6),Tax decimal(18,6),[Return Amt.] decimal(18,6),                          
[Return Tax] decimal(18,6),[Net Amt.] decimal(18,6),[Net Tax] decimal(18,6))                          

Declare @temp datetime
Set DATEFormat DMY                         
set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)

if(@FROMDATE > @temp )
begin
	select 0,'This report cannot be generated for GST period' as Reason
	goto GSTOut
end               
                 
if(@TODATE > @temp )
begin
	set @TODATE  = @temp 
	--goto GSTOut
end                 
        
if (@TaxCmpBrkUP='Yes')                          
Begin                          
declare @taxcompCnt as int                          
declare @tmpSql as nvarchar(4000),@tmpSql1 as nvarchar(4000)                           
declare @tmpcol1 as nvarchar(4000),@tmpcol2 as nvarchar(4000)                          

declare @countLT as int,@countCT as int,@INVType as int,@countRLT as int,@countRCT as int                          
declare @Coltxt as nvarchar(100)                          
declare @tax_code as int,@taxcomponent_code int,                          
@taxcomponent_desc nvarchar(255),@tax_percentage decimal(18,6),@tax_value decimal (18,6)                          
,@InvID as varchar(255)                          
 
--Create Temp table to insert Tax Components with Tax Code                          
create table #TaxComp(invid nvarchar(50),    
tax_code int,taxcomponent_code int,taxcomponent_desc nvarchar(255)                          
,tax_percentage decimal(18,6),tax_value decimal(18,6),Coltxt nvarchar(100),INVType int,Slno int,maxcol int,maxcolcst int)                          
                          
insert into #TaxComp                          
select distinct TCM.invoiceid,    
TCM.tax_code,TCM.taxcomponent_code,TCM.taxcomponent_desc,TCM.tax_percentage                           
,TAXVAL.tax_value                       
,case when TCM.LST_Flag=1                         
 then 'LT ' when TCM.LST_Flag=0 then 'CT '                         
 end Coltxt                          
,TCM.InvoiceType INVType,1 Slno                
,(select isnull(lst_flag,0) from taxcomponents where taxcomponent_code=TCM.taxcomponent_code and tax_code=TCM.tax_code)  maxcol                        
,(select count(taxcomponent_code) from taxcomponents where lst_flag=0   and tax_code=tcm.tax_code ) maxcolcst             
from (                          
select ivd.taxid tax_code,tcd.taxcomponent_code,tcd.taxcomponent_desc                          
,max(itaxc.tax_percentage) tax_percentage      
,IvD.InvoiceID                          
,case when ivd.stpayable<>0 then 1   
      when ivd.cstpayable<>0 then  0 else 2 end      
LST_Flag,                      
case when IvA.InvoiceType =1 or  IvA.InvoiceType =2 or IvA.InvoiceType =3 then 1 else 2 end InvoiceType                        
from 
InvoiceAbstract IvA, InvoiceDetail IvD--,Taxcomponents TC,                          
,Taxcomponentdetail TCD,invoicetaxcomponents ITaxC                             
where   IvA.Invoicetype in (1,2,3,4,5,6)                          
 and IvA.InvoiceID=IvD.InvoiceID                               
 and invoicedate between @FROMDATE AND @TODATE                            
 And IvA.Status&128=0                             
 And ITaxC.invoiceid=IvD.InvoiceID                 
 and ivd.taxid=itaxc.tax_code   
 and ivd.product_code=ITaxc.Product_code      
 And ITaxC.tax_component_code=TCD.taxcomponent_code                          
group by ivd.cstpayable,ivd.stpayable,ivd.taxid,tcd.taxcomponent_code,tcd.taxcomponent_desc,IvD.InvoiceID,IvA.InvoiceType                          
) TCM,(                          
select tax_code,sum(tax_value) tax_value,tax_component_code,invoiceid                             
from invoicetaxcomponents                            
where tax_value<>0     
group by tax_code,tax_component_code,invoiceid                  
) TAXVAL     
where                 
TCM.invoiceid=TAXVAL.invoiceid                          
And TCM.taxcomponent_code=TAXVAL.tax_component_code             
and TCM.tax_code=TAXVAL.tax_code                
group by TCM.tax_code,TCM.taxcomponent_code,TCM.taxcomponent_desc                         
,TCM.tax_percentage,TCM.LST_Flag,TCM.InvoiceType,TAXVAL.tax_value,TCM.invoiceid                            
order by Coltxt desc,TCM.InvoiceType,TCM.taxcomponent_code                          
               
                       
                   
                     
declare @tax_code1 as int, @slcnt as int,@invtype1 as int--,@coltxt as varchar(20)     
declare @maxcol as int                       
Declare CurTaxCompSLNO Cursor for                           
Select tax_code,invtype,isnull(maxcol,0)--,coltxt    
 from #taxcomp                        
Open CurTaxCompSLNO                            
Fetch From CurTaxCompSLNO into @tax_code,@invtype1,@maxcol--,@coltxt                        
While @@Fetch_Status = 0                            
Begin                         
 set @slcnt=1                        
 Declare CurTaxCompSLNO1 Cursor for                           
 select distinct tax_code,taxcomponent_code,isnull(maxcol,0)--,coltxt     
from #taxcomp where tax_code=@tax_code and maxcol=@maxcol--coltxt=@coltxt                
 Open CurTaxCompSLNO1                            
 Fetch From CurTaxCompSLNO1 into @tax_code1,@taxcomponent_code,@maxcol--,@coltxt                
 While @@Fetch_Status = 0                            
 Begin                         
 update #taxcomp set slno=@slcnt where tax_code=@tax_code1                
   and taxcomponent_code=@taxcomponent_code                 
   and maxcol= @maxcol               
  set @slcnt=@slcnt+1                        
 Fetch Next From CurTaxCompSLNO1 Into @tax_code1,@taxcomponent_code,@maxcol--,@coltxt                
 End                                   
 Close CurTaxCompSLNO1                        
 deallocate CurTaxCompSLNO1                        
Fetch Next From CurTaxCompSLNO Into @tax_code,@invtype1,@coltxt                        
End                                   
Close CurTaxCompSLNO                        
deallocate CurTaxCompSLNO                        
    
           
Declare @MAXrowTLT as int ,@MAXrowTCT as int                        
Declare @MAXrowTRLT as int ,@MAXrowTRCT as int                        
                 
select @MAXrowTLT = max(slno) from #taxcomp where invtype=1 and coltxt='LT' --group by tax_code                 
select @MAXrowTCT = max(slno) from #taxcomp where invtype=1 and coltxt='CT' --group by tax_code                
select @MAXrowTRLT = max(slno) from #taxcomp where invtype<>1 and coltxt='LT' --group by tax_code                
select @MAXrowTRCT = max(slno) from #taxcomp where invtype<>1 and coltxt='CT' --group by tax_code                
                     
insert into #TaxSummary (Tax_code,[Tax Description],                          
[Sales Amt.],Tax,[Return Amt.],[Return Tax],[Net Amt.],[Net Tax])--,InvoiceID)                          
SELECT  T.Tax_code ,                            
"Tax Description" = T.Tax_Description ,                              
                            
"Sales Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ),                             
                              
"Tax" = SUM(case IvA.InvoiceType when  1 then IvD.STPayable + IvD.CSTPayable else 0 end)+                              
SUM(case IvA.InvoiceType when  2 then IvD.STPayable + IvD.CSTPayable else 0 end)+                              
SUM(case IvA.InvoiceType when  3 then IvD.STPayable + IvD.CSTPayable else 0 end),                              
     
"Return Amt." = sum(case when IvA.InvoiceType In (4,5,6) then IvD.Amount else 0 end ),                              
                            
"Tax1" = SUM(case when  IvA.InvoiceType In (4,5,6) then IvD.STPayable + IvD.CSTPayable else 0 end),                              
                              
"Net Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+                        
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ) -                              
sum(case when IvA.InvoiceType In (4,5,6) then IvD.Amount else 0 end ),                              
                              
"Net Tax" = SUM(case IvA.InvoiceType when  1 then IvD.STPayable + IvD.CSTPayable else 0 end)+                              
SUM(case IvA.InvoiceType when  2 then IvD.STPayable + IvD.CSTPayable else 0 end)+                              
SUM(case IvA.InvoiceType when  3 then IvD.STPayable + IvD.CSTPayable else 0 end) -                              
SUM(case when IvA.InvoiceType In (4,5,6) then IvD.STPayable + IvD.CSTPayable else 0 end)                              
                    
from Tax T , InvoiceAbstract IvA, InvoiceDetail IvD                           
where t.tax_code = IvD.TaxId and IvA.InvoiceID=IvD.InvoiceID                                 
and invoicedate between @FROMDATE AND @TODATE               
And IvA.Status&128=0                   
and taxamount<>0                              
group by t.tax_code, t.tax_description                         
                  
if exists (SELECT  ivd.taxamount            
from Tax T , InvoiceAbstract IvA, InvoiceDetail IvD                           
where t.tax_code = IvD.TaxId                   
and IvA.InvoiceID=IvD.InvoiceID                                 
and invoicedate between @FROMDATE AND @TODATE                              
And IvA.Status&128=0                    
And IvD.TaxAmount=0  
And Ivd.Amount<>0)           
insert into #TaxSummary ([Tax Description],[Sales Amt.],Tax,[Return Amt.],[Return Tax],[Net Amt.],[Net Tax])                  
(SELECT  'Exempt' exempt,                          
"Sales Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ),               
"Tax" =0,              
"Return Amt." = sum(case when IvA.InvoiceType In (4,5,6) then IvD.Amount else 0 end ),                              
"Tax1" =0,              
"Net Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ) -                              
sum(case when IvA.InvoiceType In (4,5,6) then IvD.Amount else 0 end )                              
,"Net Tax" =0              
from Tax T , InvoiceAbstract IvA, InvoiceDetail IvD                           
where t.tax_code = IvD.TaxId                   
and IvA.InvoiceID=IvD.InvoiceID                                 
and invoicedate between @FROMDATE AND @TODATE                              
And IvA.Status&128=0                    
And IvD.TaxAmount=0)               
              
set @countLT=0                          
set @countCT=0                          
set @countRLT=0                          
set @countRCT=0                          
     
Declare @CNT as int                        
Declare @tmpcolTLT as varchar(2000),@tmpcolTLTAMT as varchar(2000)                        
                        
set @CNT=0                        
set @tmpcolTLT=''                         
while @MAXrowTLT >0                        
Begin                        
 set @CNT=@CNT+1                        
 set @tmpcolTLT=@tmpcolTLT + '[LST Component '+ cast(@CNT as varchar) + ' Tax %],'                          
 set @tmpcolTLT=@tmpcolTLT + '[LST Component '+ cast(@CNT as varchar) + ' Tax Amount],'                          
 set @tmpSql='Alter Table #TaxSummary Add [LST Component '+ cast(@CNT as varchar) + ' Tax %] Decimal(18, 6) Default(0)'                                          
 set @tmpSql1='Alter Table #TaxSummary Add [LST Component '+ cast(@CNT as varchar) + ' Tax Amount] Decimal(18, 6) Default(0)'                                    
 Exec sp_executesql @tmpSql                         
 Exec sp_executesql @tmpSql1                        
 set @MAXrowTLT=@MAXrowTLT-1                      End                        
Declare @tmpcolTCT as varchar(2000),@tmpcolTCTAMT as varchar(2000)                        
set @CNT=0                        
set @tmpcolTCT=''                         
while @MAXrowTCT >0                        
Begin                        
 set @CNT=@CNT+1                        
 set @tmpcolTCT=@tmpcolTCT + '[CST Component '+ cast(@CNT as varchar) + ' Tax %],'                          
 set @tmpcolTCT=@tmpcolTCT + '[CST Component '+ cast(@CNT as varchar) + ' Tax Amount],'                          
 set @tmpSql='Alter Table #TaxSummary Add [CST Component '+ cast(@CNT as varchar) + ' Tax %] Decimal(18, 6) Default(0)'               
 set @tmpSql1='Alter Table #TaxSummary Add [CST Component '+ cast(@CNT as varchar) + ' Tax Amount] Decimal(18, 6) Default(0)'                                    
 Exec sp_executesql @tmpSql                         
 Exec sp_executesql @tmpSql1                        
 set @MAXrowTCT=@MAXrowTCT-1                        
End                        
                        
Declare @tmpcolTRLT as varchar(2000),@tmpcolTRLTAMT as varchar(2000)                        
set @CNT=0                        
set @tmpcolTRLT=''                         
while @MAXrowTRLT >0                        
Begin                        
 set @CNT=@CNT+1                        
 set @tmpcolTRLT=@tmpcolTRLT + '[SR_LST Component '+ cast(@CNT as varchar) + ' Tax %],'                          
 set @tmpcolTRLT=@tmpcolTRLT + '[SR_LST Component '+ cast(@CNT as varchar) + ' Tax Amount],'                          
 set @tmpSql='Alter Table #TaxSummary Add [SR_LST Component '+ cast(@CNT as varchar) + ' Tax %] Decimal(18, 6) Default(0)'                                          
 set @tmpSql1='Alter Table #TaxSummary Add [SR_LST Component '+ cast(@CNT as varchar) + ' Tax Amount] Decimal(18, 6) Default(0)'                                    
 Exec sp_executesql @tmpSql                         
 Exec sp_executesql @tmpSql1                        
 set @MAXrowTRLT=@MAXrowTRLT-1                        
End                        
Declare @tmpcolTRCT as varchar(2000),@tmpcolTRCTAMT as varchar(2000)                        
set @CNT=0                        
set @tmpcolTRCT=''                         
while @MAXrowTRCT >0                        
Begin                        
 set @CNT=@CNT+1                        
 set @tmpcolTRCT=@tmpcolTRCT + '[SR_CST Component '+ cast(@CNT as varchar) + ' Tax %],'                          
 set @tmpcolTRCT=@tmpcolTRCT + '[SR_CST Component '+ cast(@CNT as varchar) + ' Tax Amount],'                          
 set @tmpSql='Alter Table #TaxSummary Add [SR_CST Component '+ cast(@CNT as varchar) + ' Tax %] Decimal(18, 6) Default(0)'                                          
 set @tmpSql1='Alter Table #TaxSummary Add [SR_CST Component '+ cast(@CNT as varchar) + ' Tax Amount] Decimal(18, 6) Default(0)'                                    
 Exec sp_executesql @tmpSql                         
 Exec sp_executesql @tmpSql1                        
 set @MAXrowTRCT=@MAXrowTRCT-1                        
End                        
                        
Declare CurTaxComp Cursor for  
Select tax_code from #TaxSummary                        
 Open CurTaxComp                            
 Fetch From CurTaxComp into @tax_code                        
 While @@Fetch_Status = 0                            
 Begin                 
 set @CNT=0                        
 set @tax_value=0                        
 set @tax_percentage=0                        
                      
                       
select @MAXrowTLT = max(slno) from #taxcomp where invtype=1 and coltxt='LT' --group by tax_code                 
select @MAXrowTCT = max(slno) from #taxcomp where invtype=1 and coltxt='CT' --group by tax_code                
select @MAXrowTRLT = max(slno) from #taxcomp where invtype<>1 and coltxt='LT' --group by tax_code                
select @MAXrowTRCT = max(slno) from #taxcomp where invtype<>1 and coltxt='CT' --group by tax_code                
                
                
while @MAXrowTLT >0                        
Begin                        
 set @CNT=@CNT+1                        
 select @tax_value=sum(tax_value),@tax_percentage=max(tax_percentage) from #taxcomp where tax_code=@tax_code and invtype=1 and coltxt='LT' and slno=@CNT                        
 Set @tmpSql = 'Update #TaxSummary Set [LST Component '+ cast(@CNT as varchar) + ' Tax %] ='+cast(@tax_percentage as nvarchar)+ '                         
    ,[LST Component '+ cast(@CNT as varchar) + ' Tax Amount] ='+cast(@tax_value as nvarchar)+ '                        
          where tax_code ='''+cast(@tax_code as nvarchar)+''''                                      
 Exec sp_executesql @tmpSql                 
 set @MAXrowTLT=@MAXrowTLT-1                        
 set @tax_value=0                        
 set @tax_percentage=0                     
End                        
                
                
set @CNT=0                   
while @MAXrowTCT >0                        
Begin                        
 set @CNT=@CNT+1                     
 select @tax_value=sum(tax_value),@tax_percentage=max(tax_percentage) from #taxcomp where tax_code=@tax_code and invtype=1 and coltxt='CT' and slno= @CNT                        
 Set @tmpSql = 'Update #TaxSummary Set [CST Component '+ cast(@CNT as varchar) + ' Tax %] ='+cast(@tax_percentage as nvarchar)+ '                         
        ,[CST Component '+ cast(@CNT as varchar) + ' Tax Amount] ='+cast(@tax_value as nvarchar)+ '                        
         where tax_code ='''+cast(@tax_code as nvarchar)+''''                                      
 Exec sp_executesql @tmpSql                
 set @MAXrowTCT=@MAXrowTCT-1                        
 set @tax_value=0                        
 set @tax_percentage=0                      
End                        
                        
set @CNT=0                        
while @MAXrowTRLT >0                        
Begin                        
 set @CNT=@CNT+1                        
 select @tax_value=sum(tax_value),@tax_percentage=max(tax_percentage) from #taxcomp where tax_code=@tax_code and invtype=2 and coltxt='LT' and slno=@CNT                        
 Set @tmpSql = 'Update #TaxSummary Set [SR_LST Component '+ cast(@CNT as varchar) + ' Tax %] ='+cast(@tax_percentage as nvarchar)+ '                         
        ,[SR_LST Component '+ cast(@CNT as varchar) + ' Tax Amount] ='+cast(@tax_value as nvarchar)+ '                        
         where tax_code ='''+cast(@tax_code as nvarchar)+''''                                      
 Exec sp_executesql @tmpSql                        
 set @MAXrowTRLT=@MAXrowTRLT-1                        
 set @tax_value=0                        
 set @tax_percentage=0                   
End                        
                
set @CNT=0                        
while @MAXrowTRCT >0                        
Begin                        
 set @CNT=@CNT+1                   
 select @tax_value=sum(tax_value),@tax_percentage=max(tax_percentage) from #taxcomp where tax_code=@tax_code and invtype=2 and coltxt='CT' and slno=@CNT                        
 Set @tmpSql = 'Update #TaxSummary Set [SR_CST Component '+ cast(@CNT as varchar) + ' Tax %] ='+cast(@tax_percentage as nvarchar)+ '                         
        ,[SR_CST Component '+ cast(@CNT as varchar) + ' Tax Amount] ='+cast(@tax_value as nvarchar)+ '                        
         where tax_code ='''+cast(@tax_code as nvarchar)+''''                                      
 Exec sp_executesql @tmpSql                        
 set @MAXrowTRCT=@MAXrowTRCT-1                        
 set @tax_value=0                        
 set @tax_percentage=0                        
End                        
                        
                        
Fetch Next From CurTaxComp Into @tax_code                        
End                                   
Close CurTaxComp                        
                  
set @tmpSql1 = 'select Tax_code,[Tax Description],[Sales Amt.]-Tax "Sales Amt.",Tax,'+ @tmpcolTLT + @tmpcolTCT +'                        
[Return Amt.]-[Return Tax] "Return Amt.",[Return Tax] "Return Tax",'+ @tmpcolTRLT + @tmpcolTRCT +'                        
[Net Amt.]-[Net Tax] "Net Amt.",[Net Tax] from #TaxSummary '--where [Sales Amt.]<>0'                         
              
Exec sp_executesql @tmpSql1                          
                        
deallocate CurTaxComp                           
drop table #TaxComp                          
End                   
Else                          
                  
Begin                          
 insert into #TaxSummary (Tax_code,[Tax Description],                          
 [Sales Amt.],Tax,[Return Amt.],[Return Tax],[Net Amt.],[Net Tax])                         
SELECT  T.Tax_code ,                            
"Tax Description" = T.Tax_Description ,                              
                            
"Sales Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ),                             
                              
"Tax" = SUM(case IvA.InvoiceType when  1 then IvD.STPayable + IvD.CSTPayable else 0 end)+                              
SUM(case IvA.InvoiceType when  2 then IvD.STPayable + IvD.CSTPayable else 0 end)+                              
SUM(case IvA.InvoiceType when  3 then IvD.STPayable + IvD.CSTPayable else 0 end),                              
                            
"Return Amt." = sum(case when IvA.InvoiceType In (4,5,6) then IvD.Amount else 0 end ),                              
                            
"Tax1" = SUM(case when  IvA.InvoiceType In (4,5,6) then IvD.STPayable + IvD.CSTPayable else 0 end),                              
                              
"Net Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ) -                              
sum(case when IvA.InvoiceType In (4,5,6) then IvD.Amount else 0 end ),                              
                              
"Net Tax" = SUM(case IvA.InvoiceType when  1 then IvD.STPayable + IvD.CSTPayable else 0 end)+                              
SUM(case IvA.InvoiceType when  2 then IvD.STPayable + IvD.CSTPayable else 0 end)+                              
SUM(case IvA.InvoiceType when  3 then IvD.STPayable + IvD.CSTPayable else 0 end) -                              
SUM(case when IvA.InvoiceType In (4,5,6) then IvD.STPayable + IvD.CSTPayable else 0 end)                              
                              
from Tax T , InvoiceAbstract IvA, InvoiceDetail IvD                           
where t.tax_code = IvD.TaxId and IvA.InvoiceID=IvD.InvoiceID                                 
and invoicedate between @FROMDATE AND @TODATE   
And IvA.Status&128=0         
and taxamount<>0                              
group by t.tax_code, t.tax_description                            
        
if exists (SELECT  ivd.taxamount            
from Tax T , InvoiceAbstract IvA, InvoiceDetail IvD                           
where t.tax_code = IvD.TaxId                   
and IvA.InvoiceID=IvD.InvoiceID                                 
and invoicedate between @FROMDATE AND @TODATE                              
And IvA.Status&128=0                    
And IvD.TaxAmount=0  
And Ivd.Amount<>0)        
insert into #TaxSummary ([Tax Description],[Sales Amt.],Tax,[Return Amt.],[Return Tax],[Net Amt.],[Net Tax])                  
(SELECT  'Exempt' exempt,                          
"Sales Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ),               
"Tax" =0,              
"Return Amt." = sum(case when IvA.InvoiceType In (4,5,6) then IvD.Amount else 0 end ),                              
"Tax1" =0,              
"Net Amt." = sum(case IvA.InvoiceType when  1 then IvD.Amount else 0 end )+                              
sum(case IvA.InvoiceType when  2 then IvD.Amount else 0 end )+                         
sum(case IvA.InvoiceType when  3 then IvD.Amount else 0 end ) -                              
sum(case when IvA.InvoiceType In (4,5,6) then IvD.Amount else 0 end )                              
,"Net Tax" =0              
from Tax T , InvoiceAbstract IvA, InvoiceDetail IvD                           
where t.tax_code = IvD.TaxId                   
and IvA.InvoiceID=IvD.InvoiceID                                 
and invoicedate between @FROMDATE AND @TODATE                              
And IvA.Status&128=0                    
And IvD.TaxAmount=0)            
        
select Tax_code,[Tax Description],                          
 [Sales Amt.]-Tax "Sales Amt.",Tax,[Return Amt.]-[Return Tax] "Return Amt.",[Return Tax] "Return Tax",[Net Amt.]-[Net Tax] "Net Amt.",[Net Tax] from #TaxSummary        
End        
drop table #TaxSummary                                     
GSTOut:
End              


