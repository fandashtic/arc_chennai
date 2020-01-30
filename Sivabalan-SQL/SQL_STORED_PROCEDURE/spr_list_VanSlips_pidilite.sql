CREATE procedure [dbo].[spr_list_VanSlips_pidilite](@BeatName nVarchar(2550), @fromdate datetime, @todate datetime)  
as  

Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
  
Create table #tmpBeat(BeatID Int )  
if @BeatName = N'%'  
   insert into #tmpBeat select BeatID from Beat  Union Select 0
else  
   insert into #tmpBeat Select BeatID From Beat Where Description In 
   (select * from dbo.sp_SplitIn2Rows(@BeatName ,@Delimeter))

select DocSerial,  
 "Van Statment No" =  VoucherPrefix.Prefix + cast (VanStatementAbstract.DocumentID as nvarchar),
 "Date" = VanStatementAbstract.DocumentDate,
 "Beat" = IsNull(Beat.Description, N'Others'),   
 "Salesman" = Salesman.Salesman_Name,   
 "Van Id" = VanStatementAbstract.VanID,   
 "Van Number" = Van.Van_Number,  
 "Van Loading Date" = VanStatementAbstract.LoadingDate,
 "Amount" = VanStatementAbstract.DocumentValue,
 "Status" = CASE Status
	WHEN 0 THEN N'Opened'	
	WHEN 128 THEN N'Closed'
        WHEN 192 THEN N'Closed'
	END  
From VanStatementAbstract, Van, Salesman, Beat, VoucherPrefix  
Where  VanStatementAbstract.VanID = Van.Van and  
 VanStatementAbstract.BeatID *= Beat.BeatID and
 VoucherPrefix.tranid = N'VAN LOADING STATEMENT' and   
 VanStatementAbstract.SalesmanID = Salesman.SalesmanID and  
 VanStatementAbstract.BeatID In (Select BeatId from #tmpBeat) And
 VanStatementAbstract.DocumentDate between @fromdate and @todate   
 And IsNull(Status, 0) & 192 = 0
order by VanStatementAbstract.DocumentDate
