Create Function fn_V_Asset_Outlet()          
Returns @FinalOutput Table (CustomerID nvarchar(20)  COLLATE SQL_Latin1_General_CP1_CI_AS,DSID int,Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
AssetNumber nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,AssetTypeID int,AssetType nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
AssetStatus nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)
BEGIN

	Declare @Output Table (CustomerID nvarchar(20)  COLLATE SQL_Latin1_General_CP1_CI_AS,DSID int,Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	AssetNumber nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,AssetTypeID int,AssetType nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	AssetStatus nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Declare @TmpDivision table(GroupID int,GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,Division nvarchar(255) 
	COLLATE SQL_Latin1_General_CP1_CI_AS)
	Declare @TmpDSType table(DSTypeID int,GroupID int)
	Declare @tmpDSDetails Table(DSTypeID int,SalesmanID int)
	Declare @HHDS Table (SalesmanID int,CustomerID nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)

	--Declare @Output Table (CustomerID nvarchar(20)  COLLATE SQL_Latin1_General_CP1_CI_AS,DSID int,Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,AssetNumber nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	--AssetTypeID int,AssetType nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,AssetStatus nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Declare @AssetAbs Table (AssetID int,CustomerID nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,AssetNumber nVarchar(50) 
	COLLATE SQL_Latin1_General_CP1_CI_AS, AssetType nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	AssetTypeID int, AssetStatus nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


	/* For getting Divisions and corresponding Category Groups */
	If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
	BEGIN
		insert into @TmpDivision (GroupID,GroupName,Division)
		Select distinct PCGA.GroupID,PCGA.GroupName, IC3.Category_Name
		From ItemCategories IC1, ItemCategories IC2, ItemCategories IC3,ProductCategoryGroupAbstract PCGA, 
		Items I,tblCGDivMapping CGDIV
		Where CGDIV.Division = IC3.Category_Name
		  And IC3.CategoryID = IC2.ParentID 
		  And IC2.CategoryID = IC1.ParentID 
		  And IC1.CategoryID = I.CategoryID
		  And I.Active = 1 
		  And CGDIV.CategoryGroup = PCGA.GroupName
		  And IC3.Category_Name in (Select distinct Category From AssetMaster)
	END
	ELSE
	BEGIN
		insert into @TmpDivision (GroupID,GroupName,Division)
		select distinct P.GroupID,O.GroupName,O.Division from OCGItemMaster O,ProductCategoryGroupAbstract P
		where P.GroupName=O.GroupName And
		Isnull(OCGType,0) = 1 And 
		isnull(Active,0) = 1	
		And O.Division in (Select distinct Category From AssetMaster)

	END

	/* For getting DStypes for Divisions and corresponding Category Groups */
	Insert into @TmpDSType(DSTypeID,GroupID)
	Select distinct DSTypeID,GroupID from tbl_mERP_DSTypeCGMapping where Active = 1 and GroupID in (select Distinct GroupID from @TmpDivision)

	/* For getting DS for DStypes, Divisions and corresponding Category Groups */
	Insert into @tmpDSDetails (DSTypeID,SalesmanID)
	Select Distinct DStypeID,SalesmanID From DSType_Details where DStypeID in (select DStypeID from DSType_Master where 
	 ( Case when DSTypeName = 'DSType' then 
				(Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') 
			  Else IsNull(OCGtype, 0) 
			  End ) = IsNull(OCGtype, 0)
		and Active = 1 and DSTypeCtlPos=1)
	And DStypeID in (Select DSTypeID from @TmpDSType)

	/* For handheld salesmen */
	Insert into @HHDS (SalesmanID,CustomerID)
	Select S.SalesmanID,C.CustomerID From 
	Beat_Salesman BS, Salesman S, Beat B,Customer C,DSType_Details dd, DSType_Master dm
	Where 
	DM.DSTypeCTLPos = 2 And
	DD.DSTypeCTLPos = 2 And
	isnull(B.Active,0) = 1 And
	isnull(Dm.Active,0)=1 And 
	isnull(C.Active,0) = 1 And
	DM.DSTypeValue = 'Yes' And
	DD.SalesmanID =S.SalesmanID And
	S.SalesmanId = BS.SalesmanId And 
	dd.DSTypeID = dm.DSTypeID And 
	C.CustomerID = BS.CustomerID And 
	isnull(S.Active,0) = 1 And 
	B.BeatId = BS.BeatId And 
	S.SalesmanID in (select SalesmanID from @tmpDSDetails)

	/* Mapping the Asset Master Categoy with salesman*/
	Insert into @Output (CustomerID,DSID,Division,AssetNumber,AssetTypeID,AssetType,AssetStatus)
	Select distinct HH.CustomerID,HH.SalesmanID,Div.Division,NULL,NULL,NULL,NULL from @HHDS HH,@tmpDSDetails DSDetails,@TmpDSType DStype,
	@TmpDivision Div,AssetMaster AM
	Where HH.SalesmanID=DSDetails.SalesmanID And
	DStype.DSTypeID=DSDetails.DSTypeID And
	Div.GroupID =DStype.GroupID And
	Div.Division=AM.Category

	/*Get the latest record from AssetAbstract table based on Identity Column*/
	/* Below scenario is handled
	If Customer A is mapped with 3 salesmen. Each salesmen handling seperate category groups
	In asset master, same asset type ID defined for 2 categories
	In this case, both the categories should be considered
	*/
	Insert into @AssetAbs(AssetID,CustomerID,AssetNumber,AssetTypeID,AssetType,Division)
	Select max(AA.AssetID),AA.CustomerID,AA.AssetNumber,AA.AssetTypeID,AA.AssetType,AM.Category from AssetAbstract AA
	Left Outer Join AssetMaster AM On  isnull(AA.AssetTypeID,0)=isnull(AM.AssetTypeID,0) And isnull(AA.AssetType,'') = isnull(AM.AssetType,'')
	Group by CustomerID,AssetNumber,AA.AssetType,AA.AssetTypeID,AM.Category

--	Update TempA set Division =AM.Category from @AssetAbs TempA,AssetMaster AM
--	Where TempA.AssetTypeID=AM.AssetTypeID
--	And TempA.AssetType=AM.AssetType

	/* Update the latest Asset Number, Asset Status and Asset Type in the temporary table*/
	Update TmpAbs set TmpAbs.AssetNumber=AA.AssetNumber,TmpAbs.AssetStatus=AA.AssetStatus,TmpAbs.AssetTypeID=AA.AssetTypeID,TmpAbs.AssetType=AA.AssetType 
	From @AssetAbs TmpAbs,AssetAbstract AA
	where TmpAbs.AssetID=AA.AssetID

	/* Update the AsstType and ID based on the category*/
--	Update O Set O.AssetTypeID=AA.AssetTypeID,O.AssetType=AA.AssetType from @Output O,@AssetAbs AA
--	where O.CustomerID=AA.CustomerID And
--	O.Division=AA.Division

	Insert into @FinalOutput (CustomerID,DSID,Division,AssetNumber,AssetTypeID,AssetType,AssetStatus)
	Select A.CustomerID,O.DSID,A.Division,A.AssetNumber,A.AssettypeID ,A.Assettype,A.AssetStatus From @Output O,@AssetAbs A
	Where --A.AssetTypeID *=O.AssetTypeID
	--And 
	isnull(O.CustomerID,'')=isnull(A.CustomerID,'')
	And isnull(O.Division,'')=isnull(A.Division,'')
	And A.Assettype is not null
	and A.AssetNumber is not null
--	And O.DSID in (select DSID from AssetDetail AD where AD.AssetID = A.AssetID)
		
	
	/* If asset number alone is available and asset type is not defined */
--	Insert into @FinalOutput (CustomerID,DSID,Division,AssetNumber,AssetTypeID,AssetType,AssetStatus)
--	Select distinct A.CustomerID,O.DSID,NULL,A.AssetNumber,NULL,NULL,A.AssetStatus From @Output O,@AssetAbs A
--	Where 
--	A.CustomerID *= O.CustomerID
--	And A.AssetTypeID is null and A.AssetNumber is not null

	/* As per ITC, If asset type is not defined then all salesman corresponding to that Customer should be listed irresecpective of asset master */ 
	Declare @TempOutput Table (CustomerID nvarchar(20)  COLLATE SQL_Latin1_General_CP1_CI_AS,DSID int,Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	AssetNumber nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,AssetTypeID int,AssetType nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	AssetStatus nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

	Insert into @TempOutput (CustomerID,DSID,Division,AssetNumber,AssetTypeID,AssetType,AssetStatus)
	Select distinct BS.CustomerID,BS.SalesmanID,NULL,F.AssetNumber,NULL,NULL,F.AssetStatus From 
	Beat_Salesman BS, Salesman S, Beat B,Customer C,DSType_Details dd, DSType_Master dm,@AssetAbs F
	Where 
	DM.DSTypeCTLPos = 2 And
	DD.DSTypeCTLPos = 2 And
	isnull(B.Active,0) = 1 And
	isnull(Dm.Active,0)=1 And 
	isnull(C.Active,0) = 1 And
	DM.DSTypeValue = 'Yes' And
	DD.SalesmanID =S.SalesmanID And
	S.SalesmanId = BS.SalesmanId And 
	dd.DSTypeID = dm.DSTypeID And 
	C.CustomerID = BS.CustomerID And 
	isnull(S.Active,0) = 1 And 
	B.BeatId = BS.BeatId And
	C.CustomerID = F.CustomerID And
	BS.CustomerID = F.CustomerID And
	F.AssetTypeID is null and F.AssetNumber is not null And
	F.Division is null
	

	/* considering the customers and DSID combination which are not available in the @FinalOutput table to avoid duplication*/
	Insert into @FinalOutput (CustomerID,DSID,Division,AssetNumber,AssetTypeID,AssetType,AssetStatus)
	Select distinct O.CustomerID,O.DSID,NULL,O.AssetNumber,NULL,NULL,O.AssetStatus From @TempOutput O
	Where cast(O.CustomerID as nvarchar(25)) + cast(O.DSID as nvarchar(25))+ cast(O.AssetNumber as nvarchar(50)) 
	not in (select cast(F.CustomerID as nvarchar(25)) + cast(F.DSID as nvarchar(25))+cast(F.AssetNumber as nvarchar(50)) from @FinalOutput F)

	/* As per ITC whatever data available in AssetAbstract should be consider
	Insert into @FinalOutput (CustomerID,DSID,Division,AssetNumber,AssetTypeID,AssetType,AssetStatus)
	Select O.CustomerID,O.DSID,O.Division,NULL,NULL ,NULL,NULL From @Output O where O.Assettype is NULL and O.AssetTypeID is null
	and O.CustomerID not in (select distinct CustomerID from @AssetAbs where AssetNumber is not null and AssetTypeID is null and Division is null)
	*/

	RETURN
END
