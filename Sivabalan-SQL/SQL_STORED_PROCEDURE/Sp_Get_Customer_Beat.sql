CREATE procedure Sp_Get_Customer_Beat(@Beatid nvarchar(200))          
as          
Declare @Delimeter as Char(1)              
Set @Delimeter=Char(15)          
create table #tmpBeat (beat int)          
insert into  #tmpBeat select cast(ItemValue as int)ItemValue from dbo.sp_SplitIn2Rows(@beatid,@Delimeter)          
Create table #TmpCust (Customerid_tmp NVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
CompanyName_tmp NVarchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS )      

insert into #TmpCust      
Select cus.customerid, cus.company_name          
From customer cus, beat_salesman bet           
Where cus.customerid = bet.customerid   
 And Cus.Active=1             
 And bet.beatid in (select beat from #tmpBeat) order by bet.beatid   
      
IF (select COUNT(*) from #tmpBeat WHERE BEAT=0) > 0      
insert into #TmpCust      
Select cus.customerid, cus.company_name From customer cus Where cus.customerid NOT IN       
(SELECT DISTINCT CUSTOMERID FROM beat_salesman) And CustomerCategory <>4 And Customercategory <>5  And Active=1  
      
select * from #TmpCust      

drop table #tmpBeat       
drop table #TmpCust      


