Create Procedure mERP_SP_GetQuoChannel(@QType Int = 1)
As
Begin 

	Create Table #tmpChannel
	(  
		ChannelCode   NVarChar(550) COLLATE SQL_Latin1_General_CP1_CI_AS,  
		ChannelDesc  NVarChar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS  
	)  

	Declare @Qchnnlcode nVarchar(550)
    Declare @Qoutletcode nVarchar(550)
	Declare Cur_QChannel  Cursor For 
		Select Channel_Type_Code, Outlet_Type_Code From tbl_mERP_QuotChannelDetail Where Active = 1 and IsNull(QuotationType,1) = @QType
	Open Cur_QChannel
	Fetch Next From Cur_QChannel Into @Qchnnlcode, @Qoutletcode
	While @@Fetch_Status = 0
	Begin

	   If (@Qchnnlcode <> N'All') and (@Qoutletcode <> N'All')
			Insert into #tmpChannel 
				Select Distinct OL.Channel_Type_Code, OL.Channel_Type_Desc from tbl_merp_olclass OL
					Where OL.Channel_Type_Code = @Qchnnlcode
					And OL.Outlet_Type_Code = @Qoutletcode 
					And OL.Channel_Type_Active = 1
					And OL.Outlet_Type_Active = 1
	   Else if (@Qchnnlcode = N'All') and (@Qoutletcode <> N'All')
			Insert into #tmpChannel 
				Select Distinct OL.Channel_Type_Code, OL.Channel_Type_Desc from tbl_merp_olclass OL
					Where OL.Outlet_Type_Code = @Qoutletcode 
					And OL.Channel_Type_Active = 1
					And OL.Outlet_Type_Active = 1
	   Else if (@Qchnnlcode <> N'All') and (@Qoutletcode = N'All') 
			Insert into #tmpChannel 
				Select Distinct OL.Channel_Type_Code, OL.Channel_Type_Desc from tbl_merp_olclass OL
					Where OL.Channel_Type_Code = @Qchnnlcode
					And OL.Channel_Type_Active = 1
					And OL.Outlet_Type_Active = 1
	   Else if (@Qchnnlcode = N'All') and (@Qoutletcode = N'All') 
			Insert into #tmpChannel 
				Select Distinct OL.Channel_Type_Code, OL.Channel_Type_Desc from tbl_merp_olclass OL Where
					OL.Channel_Type_Active = 1
					And OL.Outlet_Type_Active = 1

	   Fetch Next From Cur_QChannel Into @Qchnnlcode, @Qoutletcode
	End
	Close Cur_QChannel
	Deallocate Cur_QChannel   
	
    Select Distinct ChannelDesc, ChannelDesc from #tmpChannel
    Drop table #tmpChannel
End
