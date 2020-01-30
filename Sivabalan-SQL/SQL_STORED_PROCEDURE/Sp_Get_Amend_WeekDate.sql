CREATE procedure Sp_Get_Amend_WeekDate(@OldCode Bigint, @SalesmanId nvarchar(30) ,@WeekDate datetime)as          
if exists (select code from wcpabstract where salesmanid =@SalesmanId   
And dbo.StripDateFromTime(weekdate) =  dbo.StripDateFromTime(@weekdate)   
And isnull(status,0 & 128 )=0  
And Code <> @oldCode)  
select 1  
else  
select 0  
  


