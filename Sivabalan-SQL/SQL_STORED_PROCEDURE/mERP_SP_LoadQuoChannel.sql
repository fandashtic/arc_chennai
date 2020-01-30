Create Procedure mERP_SP_LoadQuoChannel
As
Begin 

	Create Table #tmpChannel
	(  
		ChannelDesc  NVarChar(1000) COLLATE SQL_Latin1_General_CP1_CI_AS  
	)  

	Declare @QchnnlDesc nVarchar(550)
	Declare Cur_QChannel  Cursor For 
		Select Channel_Type_Desc From tbl_mERP_QuotChannelDetail Where Active = 1
	Open Cur_QChannel
	Fetch Next From Cur_QChannel Into @QchnnlDesc
	While @@Fetch_Status = 0
	Begin

	   If (@QchnnlDesc <> N'All') 
			Insert into #tmpChannel 
				Select Distinct QC.Channel_Type_Desc from Customer_Channel CC, tbl_mERP_QuotChannelDetail QC
				Where QC.Active = 1
				And CC.ChannelDesc = QC.Channel_Type_Desc
                And QC.Channel_Type_Desc = @QchnnlDesc
				And CC.Active = 1
	   Else if (@QchnnlDesc = N'All')
			Insert into #tmpChannel 
				Select Distinct ChannelDesc from Customer_Channel
				Where Active = 1

	   Fetch Next From Cur_QChannel Into @QchnnlDesc
	End
	Close Cur_QChannel
	Deallocate Cur_QChannel
	
    Select Distinct ChannelDesc, ChannelDesc from #tmpChannel
    Drop table #tmpChannel
End
