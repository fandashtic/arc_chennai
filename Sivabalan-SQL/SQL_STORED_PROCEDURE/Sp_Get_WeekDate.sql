CREATE procedure Sp_Get_WeekDate( @SalesmanId nvarchar(30) ,@WeekDate datetime)as          
select weekdate from wcpabstract           
where salesmanid=@salesmanId and dbo.StripDateFromTime(weekdate) =  dbo.StripDateFromTime(@weekdate)   
And status & 128=0  And status & 32 =0  


