Create Procedure mERP_sp_ProcessGGDR(@RecdID Int)
As
Begin
	Set dateformat dmy
	/* Process GGDROutlet Start: */
	
	Declare @FromDate as Nvarchar(10)
	Declare @ToDate as Nvarchar(10)
	Declare @OutletID as Nvarchar(15)
	Declare @ErrorOutletID as Nvarchar(15)
	Declare @ErrorMsg as Nvarchar(4000)
	--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'mERP_sp_ProcessGGDR Start'	
	--Declare @TmpOCGValidation as table (CustomerID Nvarchar(15)COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	Create table  #TmpOCGValidation (CustomerID Nvarchar(15)COLLATE SQL_Latin1_General_CP1_CI_AS NULL)
	
	If (Select Top 1 isnull(Flag,0) from tbl_merp_Configabstract Where ScreenCode = 'OCGDS') = 1
	Begin
		Insert into #TmpOCGValidation (CustomerID)
		select OutletID from Recd_GGDROutlet Where RecDocID = @RecdID And isnull(CatGroup,'') <> ''
	End
	
	Set @ErrorMsg = ''
	
	Declare Cur_ErrOCG Cursor for
	Select Distinct OutletID From Recd_GGDROutlet Where RecDocID = @RecdID And OutletID In (Select Distinct CustomerID From #TmpOCGValidation)
	Open Cur_ErrOCG
	Fetch from Cur_ErrOCG into @ErrorOutletID
	While @@fetch_status =0
		Begin
			Update Recd_GGDROutlet Set Status = 2 Where RecDocID = @RecdID And OutletID = @ErrorOutletID
			Set @ErrorMsg = 'Customerid : ' + cast(@ErrorOutletID as Nvarchar)+ ' is Invalid CategoryGorup Mapped.'
			Exec mERP_sp_Update_GGDRErrorStatus @RecdID,@ErrorMsg
			Fetch Next from Cur_ErrOCG into @ErrorOutletID
		End
	Close Cur_ErrOCG
	Deallocate Cur_ErrOCG
	
 /* Validate CustomerID Start: */

	Update Recd_GGDROutlet Set Status = 2 Where RecDocID = @RecdID And OutletID Not In (Select Distinct CustomerID From Customer)
	
	Set @ErrorMsg = ''
	
	Declare Cur_ErrOutlet Cursor for
	Select Distinct OutletID From Recd_GGDROutlet Where RecDocID = @RecdID And isnull(Status,0) = 2
	Open Cur_ErrOutlet
	Fetch from Cur_ErrOutlet into @ErrorOutletID
	While @@fetch_status =0
		Begin
			Set @ErrorMsg = 'Customerid : ' + cast(@ErrorOutletID as Nvarchar)+ ' is Invalid / Not Available.'
			Exec mERP_sp_Update_GGDRErrorStatus @RecdID,@ErrorMsg
			Fetch Next from Cur_ErrOutlet into @ErrorOutletID
		End
	Close Cur_ErrOutlet
	Deallocate Cur_ErrOutlet
	
	/* Validate CustomerID End */

	/* Validate Unique for Each DS / DS type / Category Group combination Start: */

	Declare @U_OutletID as Nvarchar(15)
	Declare @U_TmpOutletID as Nvarchar(15)
	Declare @U_TmpFromDate as Nvarchar(10)
	Declare @U_TmpTodate as Nvarchar(10)

	Create Table #TmpUniQueCatGroup (
			FromDate Nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			ToDate Nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			OutletID Nvarchar(15)COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			OutletStatus Nvarchar(15)COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			CatGroup Nvarchar(10)COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			OCG Nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
			Cnt Int)

	--Declare Cur_U Cursor for
	--Select OutletID From Recd_GGDROutlet Where RecDocID = @RecdID And isnull(Status,0) = 0
	--Open Cur_U
	--Fetch from Cur_U into @U_OutletID
	--While @@fetch_status =0
	--	Begin
	--		Truncate Table #TmpUniQueCatGroup
	--		Insert Into #TmpUniQueCatGroup (FromDate,ToDate,OutletID,OutletStatus,CatGroup,OCG,Cnt)
	--		select FromDate,ToDate,OutletID,OutletStatus,CatGroup,OCG,0 From Recd_GGDROutlet 
	--		Where RecDocID = @RecdID And isnull(Status,0) = 0 And OutletID = @U_OutletID
			
	--		If (Select Count(*) From #TmpUniQueCatGroup Where Isnull(CatGroup,'') <> '') > 0 
	--		Begin
	--			Update T set T.Cnt = S.Cnt From #TmpUniQueCatGroup T, 
	--			(Select FromDate,ToDate,OutletID,CatGroup,Count(OutletID) Cnt From Recd_GGDROutlet 
	--			Where RecDocID = @RecdID And isnull(Status,0) = 0 And OutletID = @U_OutletID Group By FromDate,ToDate,OutletID,CatGroup) S
	--			Where T.FromDate = S.FromDate
	--			And T.ToDate = S.ToDate
	--			And T.OutletID = S.OutletID
	--			And T.CatGroup = S.CatGroup
	--			And isnull(T.Cnt,0) <> 2
	--		End
			
	--		If (Select Count(*) From #TmpUniQueCatGroup Where Isnull(OCG,'') <> '') > 0
	--		Begin
	--			Update T set T.Cnt = S.Cnt From #TmpUniQueCatGroup T, 
	--			(Select FromDate,ToDate,OutletID,OCG,Count(OutletID) Cnt From Recd_GGDROutlet 
	--			Where RecDocID = @RecdID And isnull(Status,0) = 0 And OutletID = @U_OutletID Group By FromDate,ToDate,OutletID,OCG) S
	--			Where T.FromDate = S.FromDate
	--			And T.ToDate = S.ToDate
	--			And T.OutletID = S.OutletID
	--			And T.OCG = S.OCG
	--			And isnull(T.Cnt,0) <> 2
	--		End
			
	--		Delete From #TmpUniQueCatGroup Where isnull(Cnt,0) = 1
			
	--		If (Select Count(*) From #TmpUniqueCatGroup) <> 0
	--		Begin
	--			Declare Cur_Err Cursor for
	--			Select Distinct FromDate,Todate,OutletID From #TmpUniqueCatGroup
	--			Open Cur_Err
	--			Fetch from Cur_Err into @U_TmpFromDate,@U_TmpToDate,@U_TmpOutletID
	--			While @@fetch_status =0
	--				Begin
	--					Set @ErrorMsg = 'FromDate : '+ cast(@U_TmpFromDate as Nvarchar) + ',ToDate : '+ cast(@U_TmpToDate as Nvarchar) + ',Customerid : ' + cast(@U_TmpOutletID as Nvarchar)+  ' [DS/DStype/CategoryGroup/OCG/OutletStatus] combination is not Unique'
	--					Exec mERP_sp_Update_GGDRErrorStatus @RecdID,@ErrorMsg
	--					Update Recd_GGDROutlet Set Status = 2 Where RecDocID = @RecdID And OutletID = @U_TmpOutletID And FromDate = @U_TmpFromDate And Todate = @U_TmpToDate 
	--					Set @ErrorMsg = ''
	--					Fetch Next from Cur_Err into @U_TmpFromDate,@U_TmpToDate,@U_TmpOutletID
	--				End
	--			Close Cur_Err
	--			Deallocate Cur_Err
	--		End
			
	--		Fetch Next from Cur_U into @U_OutletID
	--	End
	--Close Cur_U
	--Deallocate Cur_U

	--Start Changes For Unique check Optimizing1
		Truncate Table #TmpUniQueCatGroup
		Insert Into #TmpUniQueCatGroup (FromDate,ToDate,OutletID,OutletStatus,CatGroup,OCG,Cnt)
		select FromDate,ToDate,OutletID,OutletStatus,CatGroup,OCG,0 From Recd_GGDROutlet 
		Where RecDocID = @RecdID And isnull(Status,0) = 0 --And OutletID = @U_OutletID

		If (Select Count(*) From #TmpUniQueCatGroup Where Isnull(CatGroup,'') <> '') > 0 
		Begin
			Update T set T.Cnt = S.Cnt From #TmpUniQueCatGroup T, 
			(Select FromDate,ToDate,OutletID,CatGroup,Count(OutletID) Cnt From Recd_GGDROutlet 
			Where RecDocID = @RecdID And isnull(Status,0) = 0 --And OutletID = @U_OutletID 
			Group By FromDate,ToDate,OutletID,CatGroup) S
			Where T.FromDate = S.FromDate
			And T.ToDate = S.ToDate
			And T.OutletID = S.OutletID
			And T.CatGroup = S.CatGroup
			And isnull(T.Cnt,0) <> 2
		End

		If (Select Count(*) From #TmpUniQueCatGroup Where Isnull(OCG,'') <> '') > 0
		Begin
			Update T set T.Cnt = S.Cnt From #TmpUniQueCatGroup T, 
			(Select FromDate,ToDate,OutletID,OCG,Count(OutletID) Cnt From Recd_GGDROutlet 
			Where RecDocID = @RecdID And isnull(Status,0) = 0 --And OutletID = @U_OutletID 
			Group By FromDate,ToDate,OutletID,OCG) S
			Where T.FromDate = S.FromDate
			And T.ToDate = S.ToDate
			And T.OutletID = S.OutletID
			And T.OCG = S.OCG
			And isnull(T.Cnt,0) <> 2
		End
		
		Delete From #TmpUniQueCatGroup Where isnull(Cnt,0) = 1

		If (Select Count(*) From #TmpUniqueCatGroup) <> 0
		Begin
			Declare Cur_Err Cursor for
			Select Distinct FromDate,Todate,OutletID From #TmpUniqueCatGroup
			Open Cur_Err
			Fetch from Cur_Err into @U_TmpFromDate,@U_TmpToDate,@U_TmpOutletID
			While @@fetch_status =0
				Begin
					Set @ErrorMsg = 'FromDate : '+ cast(@U_TmpFromDate as Nvarchar) + ',ToDate : '+ cast(@U_TmpToDate as Nvarchar) + ',Customerid : ' + cast(@U_TmpOutletID as Nvarchar)+  ' [DS/DStype/CategoryGroup/OCG/OutletStatus] combination is not Unique'
					Exec mERP_sp_Update_GGDRErrorStatus @RecdID,@ErrorMsg
					Update Recd_GGDROutlet Set Status = 2 Where RecDocID = @RecdID And OutletID = @U_TmpOutletID And FromDate = @U_TmpFromDate And Todate = @U_TmpToDate 
					Set @ErrorMsg = ''
					Fetch Next from Cur_Err into @U_TmpFromDate,@U_TmpToDate,@U_TmpOutletID
				End
			Close Cur_Err
			Deallocate Cur_Err
		End
	
	--End Changes For Unique check Optimizing1
	
	Drop Table #TmpUniQueCatGroup

	/* Validate Unique for Each DS / DS type / Category Group combination End. */
	
	--Declare Cur_Data Cursor for
	--Select Distinct FromDate,ToDate,OutletID From Recd_GGDROutlet Where RecDocID = @RecdID And isnull(Status,0) = 0
	--Open Cur_Data
	--Fetch from Cur_Data into @FromDate,@ToDate,@OutletID
	--While @@fetch_status =0
	--	Begin
	--		If Exists (Select Top 1 * From GGDROutlet Where FromDate = @FromDate And ToDate = @ToDate And OutletID = @OutletID) 
	--		Begin
	--			Delete From GGDROutlet Where FromDate = @FromDate And ToDate = @ToDate And OutletID = @OutletID
	--		End

	--		Insert Into GGDROutlet (RecDocID,FromDate,ToDate,OutletID,OutletStatus,Target,TargetUOM,CatGroup,OCG,PMCatGroup,ProdDefnID,Active,CreationDate,IsReceived)
	--		Select @RecdID,FromDate,ToDate,OutletID,OutletStatus,Target,TargetUOM,CatGroup,OCG,PMCatGroup,ProdDefnID,Active,Getdate(),1 From Recd_GGDROutlet
	--		Where RecDocID = @RecdID And isnull(Status,0) = 0 And OutletID = @OutletID And FromDate = @FromDate And ToDate = @ToDate
			
	--		Update GGDROutlet set LastProcessedDate= dateadd(d,-1,dbo.fn_ReturnDateforPeriod (FromDate)) Where 
	--		RecDocID = @RecdID And OutletID = @OutletID And FromDate = @FromDate And ToDate = @ToDate And 
	--		isnull(LastProcessedDate,'')=''

	--		Update Recd_GGDROutlet Set Status = 1 Where RecDocID = @RecdID And isnull(Status,0) = 0 And OutletID = @OutletID And FromDate = @FromDate And ToDate = @ToDate

	--		update G Set ReportFromDate=dbo.fn_ReturnDateforPeriod(G.FromDate) from GGDROutlet G
	--		Where ReportFromDate is null
	
	--		update G Set ReportToDate=DateAdd(d,-1,dateAdd(m,1,dbo.fn_ReturnDateforPeriod(G.ToDate))) from GGDROutlet G
	--		Where ReportToDate is null

	--		Fetch Next from Cur_Data into @FromDate,@ToDate,@OutletID
	--	End
	--Close Cur_Data
	--Deallocate Cur_Data

	/* Process GGDROutlet End. */

	-- Start Process GGDROutlet Optimizing2
	
	--Declare Cur_Data Cursor for
	--Select Distinct FromDate,ToDate,OutletID From Recd_GGDROutlet Where RecDocID = @RecdID And isnull(Status,0) = 0
	--Open Cur_Data
	--Fetch from Cur_Data into @FromDate,@ToDate,@OutletID
	--While @@fetch_status =0
	--	Begin
			
			--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'mERP_sp_ProcessGGDR GGDROutlet Start'	
			
			--If Exists (Select Top 1 * From Recd_GGDROutlet RO
			--Join GGDROutlet O On RO.FromDate  =  O.FromDate And RO.ToDate = O.ToDate And RO.OutletID = O.OutletID
			--Where RO.RecDocID = @RecdID And isnull(Status,0) = 0)
			--Begin
				Delete O From GGDROutlet O
				Join Recd_GGDROutlet RO On RO.FromDate  =  O.FromDate And RO.ToDate = O.ToDate --And RO.OutletID = O.OutletID
				And RO.RecDocID = @RecdID And isnull(RO.Status,0) = 0
			--End

			Insert Into GGDROutlet (RecDocID,FromDate,ToDate,OutletID,OutletStatus,Target,TargetUOM,CatGroup,OCG,PMCatGroup,ProdDefnID,Active,CreationDate,IsReceived,Flag)
			Select @RecdID,FromDate,ToDate,OutletID,OutletStatus,Target,TargetUOM,CatGroup,OCG,PMCatGroup,ProdDefnID,Active,Getdate(),1,Flag From Recd_GGDROutlet
			Where RecDocID = @RecdID And isnull(Status,0) = 0 --And OutletID = @OutletID And FromDate = @FromDate And ToDate = @ToDate
			
			Update GGDROutlet set LastProcessedDate= dateadd(d,-1,dbo.fn_ReturnDateforPeriod (FromDate)) Where 
			RecDocID = @RecdID And --OutletID = @OutletID And FromDate = @FromDate And ToDate = @ToDate And 
			isnull(LastProcessedDate,'')=''

			Update Recd_GGDROutlet Set Status = 1 Where RecDocID = @RecdID And isnull(Status,0) = 0 --And OutletID = @OutletID And FromDate = @FromDate And ToDate = @ToDate

			update G Set ReportFromDate=dbo.fn_ReturnDateforPeriod(G.FromDate) from GGDROutlet G
			Where ReportFromDate is null
	
			update G Set ReportToDate=DateAdd(d,-1,dateAdd(m,1,dbo.fn_ReturnDateforPeriod(G.ToDate))) from GGDROutlet G
			Where ReportToDate is null

	--		Fetch Next from Cur_Data into @FromDate,@ToDate,@OutletID
	--	End
	--Close Cur_Data
	--Deallocate Cur_Data	
	
	-- End Process GGDROutlet Optimizing2

	/* Process GGDRProduct Start: */
	--Declare @ProdDefnIDList as Table (ProdDefnID Int)
	--Create Table #ProdDefnIDList (ProdDefnID Int)
	--Declare @ProdDefnIDListDetails as Nvarchar(4000)
	--Declare @P_ProdDefnID as Int
	--Declare @Tmp_ProdDefnID as Int

	--Declare Cur_P_Data Cursor for
	--Select ProdDefnID From Recd_GGDRProduct Where RecDocID = @RecdID And Isnull(Status,0) = 0
	--Open Cur_P_Data
	--Fetch from Cur_P_Data into @P_ProdDefnID
	--While @@fetch_status =0
	--	Begin

	--		If exists (Select top 1 ProdDefnID From GGDRProduct Where ProdDefnID = @P_ProdDefnID) 
	--		Begin
	--			Delete From GGDRProduct Where ProdDefnID = @P_ProdDefnID
	--		End

	--		Insert Into GGDRProduct (RecDocID,ProdDefnID,Products,IsExcluded,ProdCatLevel,ProductFlag,Target,TargetUOM,CreationDate)
	--		Select @RecdID,ProdDefnID,Products,IsExcluded,ProdCatLevel,ProductFlag,Target,TargetUOM,Getdate() 
	--		From Recd_GGDRProduct Where RecDocID = @RecdID And Isnull(Status,0) = 0 And ProdDefnID = @P_ProdDefnID
 
	--		Insert Into @ProdDefnIDList (ProdDefnID) Select @P_ProdDefnID

	--		Update Recd_GGDRProduct Set Status = 1 Where RecDocID = @RecdID And Isnull(Status,0) = 0 And ProdDefnID = @P_ProdDefnID

	--		Fetch Next from Cur_P_Data into @P_ProdDefnID
	--	End
	--Close Cur_P_Data
	--Deallocate Cur_P_Data

	/* Process GGDRProduct End */
	
	-- Start Process GGDRProduct Optimizing3

			--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'mERP_sp_ProcessGGDR GGDRProduct Start'	
			
				--If exists (Select top 1 ProdDefnID From GGDRProduct Where ProdDefnID in (Select ProdDefnID From Recd_GGDRProduct Where RecDocID = @RecdID And Isnull(Status,0) = 0)) 
				--Begin
				--	Delete From GGDRProduct Where ProdDefnID in (Select ProdDefnID From Recd_GGDRProduct Where RecDocID = @RecdID And Isnull(Status,0) = 0)
				--End
				Select ProdDefnID=ProdDefnID Into #TmpProdDefnID From Recd_GGDRProduct Where RecDocID = @RecdID And Isnull(Status,0) = 0
				Select ProdDefnID=ProdDefnID Into #tmp4Del From GGDRProduct Where ProdDefnID in (Select ProdDefnID From #TmpProdDefnID )
				 
				If exists (Select top 1 ProdDefnID From #tmp4Del) 
				Begin
				--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'mERP_sp_ProcessGGDR GGDRProduct Start0'	
					Delete From GGDRProduct Where ProdDefnID in (Select ProdDefnID From #tmp4Del)
				End
				if object_id('tempdb..#TmpProdDefnID') is not null
					Drop table #TmpProdDefnID
				if object_id('tempdb..#tmp4Del') is not null
					Drop table #tmp4Del

				Insert Into GGDRProduct (RecDocID,ProdDefnID,Products,IsExcluded,ProdCatLevel,ProductFlag,Target,TargetUOM,CreationDate,Points)
				Select @RecdID,ProdDefnID,Products,IsExcluded,ProdCatLevel,ProductFlag,Target,TargetUOM,Getdate(),Points
				From Recd_GGDRProduct Where RecDocID = @RecdID And Isnull(Status,0) = 0 --And ProdDefnID = @P_ProdDefnID
	 
				--Insert Into #ProdDefnIDList (ProdDefnID) Select ProdDefnID From Recd_GGDRProduct Where RecDocID = @RecdID And Isnull(Status,0) = 0

				Update Recd_GGDRProduct Set Status = 1 Where RecDocID = @RecdID And Isnull(Status,0) = 0 --And ProdDefnID = @P_ProdDefnID

	-- End Process GGDRProduct Optimizing3

	/* Delete Unwanted product Defenation */

	Delete From GGDRProduct Where ProdDefnID Not in (Select Distinct ProdDefnID from GGDROutlet)
	--Delete From #ProdDefnIDList Where ProdDefnID Not in (Select Distinct ProdDefnID from GGDROutlet)
	--Exec mERP_sp_Update_GGDRErrorStatus @RecdID,'mERP_sp_ProcessGGDR End'	
	/* Data Postiong for Received ProdDefnID's*/

--	Declare Cur_List Cursor for
--	Select Distinct ProdDefnID From @ProdDefnIDList
--	Open Cur_List
--	Fetch from Cur_List into @Tmp_ProdDefnID
--	While @@fetch_status =0
--		Begin
			
----			If isnull(@ProdDefnIDListDetails,'') <> ''
----			Begin 
----				Set @ProdDefnIDListDetails = @ProdDefnIDListDetails + ',' + Cast(@Tmp_ProdDefnID as Nvarchar)
----			End
----			Else
----			Begin 
----				Set @ProdDefnIDListDetails = Cast(@Tmp_ProdDefnID as Nvarchar)
----			End
--			Exec Sp_GetGGDRProductList @Tmp_ProdDefnID 
			
--			Fetch Next from Cur_List into @Tmp_ProdDefnID
--		End
--	Close Cur_List
--	Deallocate Cur_List

--	Declare @OCG int
--	Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' And ScreenName ='OperationalCategoryGroup'
	
--	--Declare @TmpExItems As Table (ProdDefnID Int,Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)	
--	Create Table #TmpExItems (ProdDefnID Int,Product_Code Nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL)	
	
--	Delete From TmpGGDRSKUDetails Where ProdDefnID In (select Distinct ProdDefnID From #ProdDefnIDList)		
	
--	If @OCG = 1
--	Begin
--		Insert Into #TmpExItems(ProdDefnID,Product_Code)		
--		Select GGP.ProdDefnID, OCGP.SystemSKU 
--		From OCGItemMaster OCGP
--		Join GGDRProduct GGP On GGP.Products = (Case 
--		When GGP.ProdCatLevel = 2 Then OCGP.Division 
--		When GGP.ProdCatLevel = 3 Then OCGP.SubCategory 
--		When GGP.ProdCatLevel = 4 Then OCGP.MarketSKU 
--		When GGP.ProdCatLevel = 5 Then OCGP.SystemSKU End)  And IsNull(GGP.IsExcluded,0) = 1		
--		Where GGP.ProdDefnID  In (select Distinct ProdDefnID From #ProdDefnIDList)		
--		And IsNull(OCGP.Exclusion,0) = 0		
		
--		Insert Into TmpGGDRSKUDetails (ProdDefnID, CategoryGroup, Division, SubCategory, MarketSKU, Product_Code)
--		Select GGP.ProdDefnID, OCGP.GroupName, OCGP.Division, OCGP.SubCategory, OCGP.MarketSKU , OCGP.SystemSKU  
--		From OCGItemMaster OCGP
--		Join GGDRProduct GGP On GGP.Products = (Case When GGP.Products = 'ALL' Then GGP.Products Else (Case 
--		When GGP.ProdCatLevel = 2 Then OCGP.Division 
--		When GGP.ProdCatLevel = 3 Then OCGP.SubCategory 
--		When GGP.ProdCatLevel = 4 Then OCGP.MarketSKU 
--		When GGP.ProdCatLevel = 5 Then OCGP.SystemSKU End) End)  And IsNull(GGP.IsExcluded,0) = 0
--		Where GGP.ProdDefnID  In (select Distinct ProdDefnID From #ProdDefnIDList)		
--		And IsNull(OCGP.Exclusion,0) = 0
--		And OCGP.SystemSKU Not In (Select Product_Code From #TmpExItems Where ProdDefnID = GGP.ProdDefnID)
--	End
--	Else -- @OCG = 0
--	Begin
--		Insert Into #TmpExItems(ProdDefnID,Product_Code)		
--		Select GGP.ProdDefnID, SysSKU.Product_Code 
--		From Items SysSKU
--		Join ItemCategories MSKU On MSKU.CategoryID = SysSKU.CategoryID And MSKU.Level = 4
--		Join ItemCategories SubCat On SubCat.CategoryID = MSKU.ParentID  And SubCat.Level = 3
--		Join ItemCategories Div On Div.CategoryID = SubCat.ParentID And Div.Level = 2		
--		Join GGDRProduct GGP On GGP.Products = (Case 
--		When GGP.ProdCatLevel = 2 Then Div.Category_Name 
--		When GGP.ProdCatLevel = 3 Then SubCat.Category_Name 
--		When GGP.ProdCatLevel = 4 Then MSKU.Category_Name  
--		When GGP.ProdCatLevel = 5 Then SysSKU.Product_Code End)  And IsNull(GGP.IsExcluded,0) = 1
--		Where GGP.ProdDefnID  In (select Distinct ProdDefnID From #ProdDefnIDList)				
		
--		Insert Into TmpGGDRSKUDetails (ProdDefnID, CategoryGroup, Division, SubCategory, MarketSKU, Product_Code)
--		Select GGP.ProdDefnID, CGDiv.CategoryGroup  ,	Div.Category_Name , SubCat.Category_Name , MSKU.Category_Name ,  SysSKU.Product_Code 
--		From Items SysSKU
--		Join ItemCategories MSKU On MSKU.CategoryID = SysSKU.CategoryID And MSKU.Level = 4
--		Join ItemCategories SubCat On SubCat.CategoryID = MSKU.ParentID  And SubCat.Level = 3
--		Join ItemCategories Div On Div.CategoryID = SubCat.ParentID And Div.Level = 2
--		Join tblCGDivMapping CGDiv On CGDiv.Division = Div.Category_Name 
--		Join GGDRProduct GGP On GGP.Products = (Case When GGP.Products = 'ALL'  Then GGP.Products Else (Case 
--		When GGP.ProdCatLevel = 2 Then Div.Category_Name 
--		When GGP.ProdCatLevel = 3 Then SubCat.Category_Name 
--		When GGP.ProdCatLevel = 4 Then MSKU.Category_Name  
--		When GGP.ProdCatLevel = 5 Then SysSKU.Product_Code End)  End)  And IsNull(GGP.IsExcluded,0) = 0
--		Where GGP.ProdDefnID  In (select Distinct ProdDefnID From #ProdDefnIDList)		
--		And SysSKU.Product_Code Not In (Select Product_Code From #TmpExItems Where ProdDefnID = GGP.ProdDefnID)		
--	End


----	Exec Sp_GetGGDRProductList @ProdDefnIDListDetails

--Update Recd_GGDR Set Status = 1 Where ID = @RecdID 

/* GGRR-FRITFITC-72: For Invoke Final GGRRData Posting Process. */

--Exec Sp_PreparePendingGGRRFinalData

--If Exists(Select Top 1 'X' From PendingGGRRFinalDataPost)
--Begin
--	Update SetUp set GGRRDaycloseFlag = 1
--End

End
