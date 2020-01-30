Create Procedure mERP_SP_GetQuoOutletType(@ChannelID as nvarchar(2000)) 
As Declare @Delimeter as char(1) 
Begin 
	Declare @QChannel nVarchar(550)
    Declare @QOutlet nVarchar(550)
	Set @Delimeter = char(15) 

	Create table #TmpOutlet(Outlet_Type_Code nvarchar(200), Outlet_Type_Desc nvarchar(200)) 
	Create table #TmpChannel(ChannelType nvarchar(200)) 
	Insert into #TmpChannel select * from dbo.sp_splitIn2Rows(@ChannelID,@Delimeter) 

	Declare Cur_QChannel  Cursor For 
		Select ChannelType From #TmpChannel 

	Open Cur_QChannel
	Fetch Next From Cur_QChannel Into @QChannel
	While @@Fetch_Status = 0
	Begin
	     if Exists(select * from tbl_merp_QuotChannelDetail where Channel_Type_Desc=@QChannel and Outlet_Type_Desc<> N'All' and Active=1)
		Begin
			 insert into #TmpOutLet select Distinct Outlet_Type_Code,Outlet_Type_Desc from tbl_merp_QuotChannelDetail
			 where Channel_Type_Desc=@QChannel and Active=1
		End
		Else if Exists(select * from tbl_merp_QuotChannelDetail where Channel_Type_Desc=@QChannel and Outlet_Type_Desc= N'All' and Active=1)
		Begin
			insert into #TmpOutLet select Distinct Outlet_Type_Code,Outlet_Type_Desc from tbl_merp_OLClass
			where Channel_Type_Desc=@QChannel and Outlet_Type_Active=1
		End
		Else if Exists(select * from tbl_merp_QuotChannelDetail QC,tbl_merp_OLClass OL 
						 where QC.Channel_Type_Desc=N'All' And OL.Channel_Type_Desc=@QChannel And
						 QC.Outlet_Type_Desc=OL.Outlet_Type_Desc and QC.Active=1 and OL.Outlet_Type_Active=1)    
		Begin
			insert into #TmpOutLet select Distinct OL.Outlet_Type_Code,OL.Outlet_Type_Desc from tbl_merp_QuotChannelDetail QC,tbl_merp_OLClass OL 
			 where QC.Channel_Type_Desc=N'All' And OL.Channel_Type_Desc=@QChannel And
			 QC.Outlet_Type_Desc=OL.Outlet_Type_Desc and QC.Active=1 and OL.Outlet_Type_Active=1
		End
		Else
		   insert into #TmpOutLet select Distinct Outlet_Type_Code, Outlet_Type_Desc from tbl_merp_OLClass
			where Channel_Type_Desc=@QChannel and Outlet_Type_Active=1

		Fetch Next From Cur_QChannel Into @QChannel
	End

	Close Cur_QChannel
    Deallocate Cur_QChannel

	Select Distinct Outlet_Type_Desc, Outlet_Type_Desc from #TmpOutlet
	Truncate Table #TmpOutlet Drop table #TmpOutlet 
	Truncate Table #TmpChannel Drop table #TmpChannel 
End
