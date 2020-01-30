Create Procedure mERP_SP_GetQuoCustomer(@ChannelID as nvarchar(2000),@OutletID as nvarchar(2000) ) 
As Declare @Delimeter as char(1) 
Begin 
Set @Delimeter = char(15) 
Create table #TmpChannel(ChannelType nvarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS) 
Insert into #TmpChannel select * from dbo.sp_splitIn2Rows(@ChannelID,@Delimeter) 
Create table #TmpOutLet(OutletType nvarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS) 

If @OutletID = '' 
Begin    
    Declare Cur_Channel Cursor for Select ChannelType from #TmpChannel
    Open  Cur_Channel
    Fetch Next from Cur_Channel into @ChannelID
    While @@Fetch_Status=0
    Begin 
		if Exists(select * from tbl_merp_QuotChannelDetail where Channel_Type_Desc=@ChannelID and Outlet_Type_Desc<>'All' and Active=1)
		Begin
			 insert into #TmpOutLet select Distinct Outlet_Type_Desc from tbl_merp_QuotChannelDetail
			 where Channel_Type_Desc=@ChannelID and Active=1
		End
		Else if Exists(select * from tbl_merp_QuotChannelDetail where Channel_Type_Desc=@ChannelID and Outlet_Type_Desc='All' and Active=1)
		Begin
			insert into #TmpOutLet select Distinct Outlet_Type_Desc from tbl_merp_OLClass
			where Channel_Type_Desc=@ChannelID and Outlet_Type_Active=1
		End
		Else if Exists(select * from tbl_merp_QuotChannelDetail QC,tbl_merp_OLClass OL 
						 where QC.Channel_Type_Desc='All' And OL.Channel_Type_Desc=@ChannelID And
						 QC.Outlet_Type_Desc=OL.Outlet_Type_Desc and QC.Active=1 and OL.Outlet_Type_Active=1)    
		Begin
			insert into #TmpOutLet select Distinct OL.Outlet_Type_Desc from tbl_merp_QuotChannelDetail QC,tbl_merp_OLClass OL 
			 where QC.Channel_Type_Desc='All' And OL.Channel_Type_Desc=@ChannelID And
			 QC.Outlet_Type_Desc=OL.Outlet_Type_Desc and QC.Active=1 and OL.Outlet_Type_Active=1
		End
		Else
		   insert into #TmpOutLet select Distinct Outlet_Type_Desc from tbl_merp_OLClass
			where Channel_Type_Desc=@ChannelID and Outlet_Type_Active=1

        Fetch Next from Cur_Channel into @ChannelID
    End
    Close Cur_Channel
    Deallocate Cur_Channel  
	select distinct C.CustomerID,C.Company_name
	from Customer C, tbl_merp_OLClass OL, tbl_merp_OLClassMapping OLM
	where C.CustomerID = OLM.CustomerID
	and OL.Channel_Type_Desc in (Select ChannelType from #TmpChannel)
    and OL.Outlet_Type_Desc in (Select OutletType from #TmpOutLet)
	And OL.Channel_Type_Active = 1
	And OL.Outlet_Type_Active = 1
	And OL.ID = OLM.OLClassID
	And OLM.Active = 1
	And C.Active=1 order by C.Company_name  
    
End
Else
Begin
	Insert into #TmpOutLet select * from dbo.sp_splitIn2Rows(@OutletID,@Delimeter) 

	select distinct C.CustomerID,C.Company_name from Customer C, tbl_merp_OLClass OL, tbl_merp_OLClassMapping OLM
	where C.CustomerID = OLM.CustomerID
	And OL.Channel_Type_Desc in (Select ChannelType from #TmpChannel) 
	And OL.Outlet_Type_Desc in (Select OutletType from #TmpOutLet) 
	And OL.Channel_Type_Active = 1
    And OL.Outlet_Type_Active = 1
	And OL.ID = OLM.OLClassID
	And OLM.Active = 1
	And C.Active=1 order by C.Company_name
End
Truncate Table #TmpChannel Drop table #TmpChannel 
End
