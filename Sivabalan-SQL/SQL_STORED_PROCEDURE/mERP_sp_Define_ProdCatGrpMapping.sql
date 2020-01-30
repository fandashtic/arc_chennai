Create Procedure mERP_sp_Define_ProdCatGrpMapping
As
Begin
	Create table #tmpCatGrp(
	CG_Code	nVarchar(30) Collate SQL_Latin1_General_CP1_CI_AS, 
	CAT_Code nVarchar(30) Collate SQL_Latin1_General_CP1_CI_AS, 	
	CG_Name	nVarchar(30) Collate SQL_Latin1_General_CP1_CI_AS,
	Active Int)

	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR1','AT','GR1',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR1','BI','GR1',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR1','CF','GR1',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR1','ND','GR1',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR1','RT','GR1',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR1','SA','GR1',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR1','SI','GR1',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR1','SN','GR1',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR2','AG','GR2',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR2','CR','GR2',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR2','CU','GR2',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR2','MT','GR2',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR2','PR','GR2',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR2','SG','GR2',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR2','SH','GR2',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR2','TA','GR2',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR2','TS','GR2',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR2','WI','GR2',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR3','SX','GR3',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR4','CG','GR4',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR4','CI','GR4',1)
	Insert into #tmpCatGrp (CG_Code, CAT_Code, CG_Name, Active) Values ('GR4','SM','GR4',1)

	/*Insert Group Name if not Exists*/
	If exists(Select Distinct CG_Name, Active From #tmpCatGrp Where CG_Name Not in 
			  (Select GroupName from ProductCategoryGroupAbstract Where Active = 1 ))
	Begin 
	   Insert into ProductCategoryGroupAbstract(GroupName, Active, CreationDate)
	   Select Distinct CG_Name, Active, GetDate() From #tmpCatGrp Where CG_Name Not in 
			  (Select GroupName from ProductCategoryGroupAbstract Where Active = 1)
	   Update ProductCategoryGroupAbstract Set GroupCode = GroupID Where IsNull(GroupCode,'') = ''
	End

	/*To Update ProductCategoryGroupDetail Mapping*/
	Update PCGdtl Set PCGdtl.GroupID = PCGAbs.GroupID
	From ProductCategoryGroupDetail PCGDtl, ProductCategoryGroupAbstract PCGAbs, 
	#tmpCatGrp tmpCG, ItemCategories ICat
	Where ICat.[Level] = 2 And ICat.Active = 1 And ICat.Category_Name = tmpCG.CAT_Code
	And tmpCG.CG_Name = PCGAbs.GroupName
	And ICat.CategoryId = PCGDtl.CategoryId

	/*To Insert ProductCategoryGroupDetail Mapping which exists Item_Categories and not exists in ProductCategoryGroupDetail*/
	If Exists (Select Distinct ICat.CategoryId, ICat.Category_Name From ItemCategories ICat, #tmpCatGrp tmpCG
			   Where ICat.[Level] = 2 And ICat.Active = 1 And  ICat.Category_Name = tmpCG.Cat_Code 
			   And ICat.CategoryID not in (Select Distinct CategoryID From ProductCategoryGroupDetail))
	Begin
	  Insert into ProductCategoryGroupDetail
	  Select PCGAbs.GroupID, ICat.CategoryID
	  From ProductCategoryGroupAbstract PCGAbs, #tmpCatGrp tmpCG, ItemCategories ICat
	  Where ICat.[Level] = 2 And ICat.Active = 1 And ICat.Category_Name = tmpCG.CAT_Code  And tmpCG.CG_Name = PCGAbs.GroupName
		And ICat.CategoryId not in (Select CategoryID from ProductCategoryGroupDetail)
	End

	Drop table #tmpCatGrp
End
