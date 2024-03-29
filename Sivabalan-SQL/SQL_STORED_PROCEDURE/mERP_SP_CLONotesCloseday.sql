create procedure mERP_SP_CLONotesCloseday @ActivityCode nvarchar(max)
AS
BEGIN
	set dateformat dmy
--	Declare @MaxInvDate datetime
	Create table #CLOActivitycode(ID Int Identity(1,1), ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Create Table #CRNote(CreditID int,CLODate datetime,ActivityCode nVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #TMPOut(ActivityCode nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Create Table #tmpI(adjref nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,invdate datetime,CreditID int)

	Insert Into #CLOActivitycode  
	Select * from dbo.sp_SplitIn2Rows(@ActivityCode, ',') 
	
	Insert into #CRNote(CreditID,CLODate,ActivityCode)
	Select CLO.CreditID,CLO.Clodate,CLO.ActivityCode from clocrnote CLO,CreditNote where CLO.CreditID =CreditNote.CreditID 
	and CLO.ActivityCode in (select ActivityCode from #CLOActivitycode) 
	And CLO.active= 1 
	and isnull(CLO.IsGenerated,0)=1
	And Balance=0
	
	Declare @Lastinventoryupload datetime   
	Select top 1 @Lastinventoryupload  = dbo.stripdatefromtime(isnull(Lastinventoryupload,getdate())) from Setup  

	/* Checking for Inventory configuration*/  
	if (Select isnull(Flag,0) from tbl_merp_configdetail where screencode='CLSDAY01' and controlname='InventoryLock') = 1   
	BEGIN 
		Declare @t nvarchar(255)
		Declare @dt datetime
		Declare Allinv cursor for select AdjRef,invoicedate from invoiceabstract Where   
		isnull(status,0)& 192 = 0
		and isnull(adjref,'') <> ''
		and Convert(Nvarchar(10),Invoicedate,103)>=(Select min(CLODate) from #CRNote)
		open Allinv
		fetch from Allinv into @t,@dt
		while @@fetch_status=0
		begin
			insert into #tmpI(adjref)	
			(Select * From dbo.sp_splitin2Rows(@t,','))
			update #tmpI set invdate=@dt where invdate is null
			fetch next from Allinv into @t,@dt
		end
		close Allinv
		deallocate Allinv
		update #tmpI set adjref= ltrim(rtrim(adjref)) 
		update #tmpI set invdate=Convert(Nvarchar(10),invdate,103)
		update T Set CreditID = CN.CreditID From #tmpI T,CreditNote CN,#CRNote CLO where CN.DocumentReference=T.adjref And CLO.CreditID=CN.CreditID
		/*Invoice abstract*/  
		insert into #TMPOut(ActivityCode)
		Select distinct ActivityCode from #CRNote where CreditID in (select CreditID from #tmpI where invdate > @Lastinventoryupload)
	END  
	--select @MaxInvDate=max(invdate) from #tmpI
	Select ActivityCode--,'Close Day need to be done till '+ cast(Convert(Nvarchar(10),@MaxInvDate,103) as nvarchar(50)) 
	from #TMPOut
	Drop table #CLOActivitycode
	Drop Table #CRNote
	Drop Table #TMPOut
	Drop Table #tmpI
END
