Create Procedure SP_get_ItemsTaxDetails(@Hierarchy int,@Map int,@Category nvarchar(Max))
AS
BEGIN
	Create Table #tmpItems(MAPID Int,
	Product_Code nvarchar(255),
	Product_Name nVarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,
	Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	PTax_Code Int,
	PCS_TaxCode nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	PTax_Desc nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS, 
	PEffectiveFrm datetime,PEffectiveTo datetime,PTax_Active int,
	STax_Code int,SCS_TaxCode nVarchar(25)  COLLATE SQL_Latin1_General_CP1_CI_AS,
	STax_Desc nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,
	 SEffectiveFrm datetime,SEffectiveTo datetime,STax_Active int
	)
	Create table #tmpRecMapID(Product_Code nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,Recd_MapID int)
	
	Create table #tmpFinalTax(Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Recd_MapID int,
	PTaxCode int,PEffectiveFrm datetime,PEffectiveTo datetime,
	STaxCode int,SEffectiveFrm datetime,SEffectiveTo datetime)
	
	create table #tmpCat(CatID int)
	Create TABLE #tmpHItems(Product_Code nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,Category_Name nvarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS)
	DECLARE @Delimeter as Char(1)      
	Declare @Openingdate as datetime 
	select @Openingdate = Isnull(Openingdate,GETDATE()) from Setup 
	SET @Delimeter=',' 	
	insert into #tmpCat(CatID)
	Select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)   
	
	If @Hierarchy = 0
		Begin
			Insert into #tmpHItems (Product_Code,Category_Name)
			Select Product_Code,Div.Category_Name  from Items I
			Join ItemCategories MS On Ms.Categoryid = I.Categoryid and MS.Level = 4  
			Join ItemCategories SC On MS.ParentID = SC.Categoryid and SC.Level = 3 
			Join ItemCategories Div On SC.ParentID = Div.Categoryid and Div.Level = 2 And Div.Categoryid in (select Distinct CatID from #tmpCat)
		End
	Else if @Hierarchy = 1
	Begin
			Insert into #tmpHItems (Product_Code,Category_Name)
			Select Product_Code,Div.Category_Name from Items I
			Join ItemCategories MS On Ms.Categoryid = I.Categoryid and MS.Level = 4  
			Join ItemCategories SC On MS.ParentID = SC.Categoryid and SC.Level = 3 And SC.Categoryid in (select Distinct CatID from #tmpCat) 
			Join ItemCategories Div On SC.ParentID = Div.Categoryid and Div.Level = 2 
	End
	Else If @Hierarchy = 2
	Begin 
			Insert into #tmpHItems (Product_Code,Category_Name)
			Select Product_Code,Div.Category_Name from Items I
			Join ItemCategories MS On Ms.Categoryid = I.Categoryid and MS.Level = 4  And MS.Categoryid in (select Distinct CatID from #tmpCat) 
			Join ItemCategories SC On MS.ParentID = SC.Categoryid and SC.Level = 3 
			Join ItemCategories Div On SC.ParentID = Div.Categoryid and Div.Level = 2 
	End	
	
	--If @Map = 1
	--Begin
	--		Insert into #tmpItems (Product_Code ,Product_Name,PTax_Code ,PCS_TaxCode ,PTax_Desc ,PEffectiveFrm ,PEffectiveTo ,PTax_Active ,
	--			STax_Code ,SCS_TaxCode ,STax_Desc ,SEffectiveFrm ,SEffectiveTo,STax_Active  )
	--		Select Product_Code,ProductName,isnull(PT.Tax_Code,'')  ,isnull(PT.CS_TaxCode,0),isnull(PT.Tax_Description,''),
	--		PT.EffectiveFrom,PT.EffectiveFrom,0 as PActive,  
	--		isnull(ST.Tax_Code,0),isnull(ST.CS_TaxCode,0),isnull(ST.Tax_Description,''), 
	--		ST.EffectiveFrom,ST.EffectiveFrom,0 as SActive from Items I
	--		left join Tax  PT On I.Sale_Tax = PT.Tax_Code left join Tax ST On I.TaxSuffered = ST.Tax_Code 
	--		where I.Product_Code in(select Distinct Product_Code from #tmpHItems)
			
	--		Select Product_Code ,Product_Name,PTax_Code ,PCS_TaxCode =CONVERT(nvarchar,Case when PCS_TaxCode > 0  then PCS_TaxCode Else '' End) ,PTax_Desc ,
	--		PEffectiveFrm = convert(varchar(10),PEffectiveFrm,103)  ,PEffectiveTo=convert(varchar(10),PEffectiveTo,103) , PTax_Active ,
	--		STax_Code ,SCS_TaxCode =CONVERT(nvarchar,Case when SCS_TaxCode > 0  then SCS_TaxCode Else '' End)  ,STax_Desc ,SEffectiveFrm=convert(varchar(10),SEffectiveFrm,103) ,
	--		SEffectiveTo=convert(varchar(10),SEffectiveTo,103),STax_Active  from #tmpItems
			
	--End
	--Else
	--Begin			

	If @Map = 1
	Begin
		Insert into #tmpRecMapID (Product_Code, Recd_MapID)
		Select Product_Code, Recd_MapID  From ItemsSTaxMap 
		Where Product_Code in (select Distinct Product_Code from #tmpHItems)
		And GetDate() Between SEffectiveFrom	And IsNull(SEffectiveTo,GetDate())
		Group By Product_Code, Recd_MapID
		Union
		Select Product_Code, Recd_MapID  From ItemsPTaxMap 
		Where Product_Code in(select Distinct Product_Code from #tmpHItems)
		And GetDate() Between PEffectiveFrom	And IsNull(PEffectiveTo,GetDate())
		Group By Product_Code, Recd_MapID
		order by Product_Code,Recd_MapID 			
	End
	Else
	Begin
		Insert into #tmpRecMapID (Product_Code, Recd_MapID)
		Select Product_Code, Recd_MapID  From ItemsSTaxMap Where Product_Code in (select Distinct Product_Code from #tmpHItems)
		Group By Product_Code, Recd_MapID
		Union
		Select Product_Code, Recd_MapID  From ItemsPTaxMap Where Product_Code in(select Distinct Product_Code from #tmpHItems)
		Group By Product_Code, Recd_MapID
		order by Product_Code,Recd_MapID 		
	End	
		
		Insert into #tmpFinalTax(Product_Code, Recd_MapID)
		Select Product_Code, Recd_MapID  From #tmpRecMapID
		
		--Update F  set F.PTaxCode=PT.PTaxCode , F.PEffectiveFrm=PT.PEffectiveFrom , F.PEffectiveTo =PT.PEffectiveTo 
		--From #tmpFinalTax F,ItemsPTaxMap PT,#tmpRecMapID T where F.Recd_MapID =PT.Recd_MapID 
		--And PT.Recd_MapID =T.Recd_MapID and F.Recd_MapID =T.Recd_MapID And F.Product_Code =PT.Product_Code
		
		Update F Set  F.PTaxCode=PT.PTaxCode , F.PEffectiveFrm=PT.PEffectiveFrom , F.PEffectiveTo =PT.PEffectiveTo 
		From #tmpFinalTax F Join ItemsPTaxMap PT On PT.Recd_MapID = F.Recd_MapID And PT.Product_Code = F.Product_Code
		
		--Update F  set F.STaxCode=ST.STaxCode , F.SEffectiveFrm=ST.SEffectiveFrom , F.SEffectiveTo =ST.SEffectiveTo 
		--from #tmpFinalTax F,ItemsSTaxMap ST,#tmpRecMapID T where F.Recd_MapID =ST.Recd_MapID 
		--And ST.Recd_MapID =T.Recd_MapID and F.Recd_MapID =T.Recd_MapID And F.Product_Code = ST.Product_Code 		
		
		Update F Set  F.STaxCode=ST.STaxCode , F.SEffectiveFrm=ST.SEffectiveFrom , F.SEffectiveTo =ST.SEffectiveTo 
		From #tmpFinalTax F Join ItemsSTaxMap ST On ST.Recd_MapID = F.Recd_MapID And ST.Product_Code = F.Product_Code

		Insert Into #tmpItems (MAPID,
		Product_Code ,Product_Name,Category_Name ,
		PTax_Code ,PCS_TaxCode ,PTax_Desc ,PEffectiveFrm ,PEffectiveTo ,
		STax_Code ,SCS_TaxCode ,STax_Desc ,SEffectiveFrm ,SEffectiveTo 
		)
		Select 0,IT.Product_Code,IT.ProductName,TempI.Category_Name ,
		PT.CS_TaxCode,IT.TaxSuffered  ,isnull(PT.Tax_Description,''), @Openingdate  ,CAST(null as datetime), 
		ST.CS_TaxCode, IT.Sale_Tax ,isnull(ST.Tax_Description,''),  @Openingdate ,CAST(null as datetime) 
		From Items IT join (select Distinct Product_Code,Category_Name from #tmpHItems) as TempI on IT.Product_Code = TempI.Product_Code  
		Left join Tax PT On IT.TaxSuffered   = PT.Tax_Code 
		Left join Tax ST On IT.Sale_Tax   = ST.Tax_Code  
		--Where IT.Product_Code in(select Distinct Product_Code from #tmpHItems)
		Where IT.Product_Code not in(select Distinct Product_Code from #tmpFinalTax)
		
		Union 
		Select I.Recd_MapID,IT.Product_Code,IT.ProductName,TempI.Category_Name ,
		I.PTaxCode ,PT.CS_TaxCode,isnull(PT.Tax_Description,''), I.PEffectiveFrm ,I.PEffectiveTo, 
		I.STaxCode,ST.CS_TaxCode,isnull(ST.Tax_Description,''),  I.SEffectiveFrm ,I.SEffectiveTo
		From #tmpFinalTax I join Items IT on I.Product_Code =IT.Product_Code 
		join (select Distinct Product_Code,Category_Name from #tmpHItems) as TempI on IT.Product_Code = TempI.Product_Code 
		Left join Tax PT On I.PTaxCode  = PT.Tax_Code 
		Left join Tax ST On I.STaxCode  = ST.Tax_Code 
		--Where IT.Product_Code in(select Distinct Product_Code from #tmpHItems)
		
		update #tmpItems  set PTax_Active =1 where PCS_TaxCode > 0 and GETDATE() between IsNull(PEffectiveFrm,GETDATE()) And IsNull(PEffectiveTo,GETDATE())
		update #tmpItems  set STax_Active =1 where SCS_TaxCode > 0 and GETDATE() between isnull(SEffectiveFrm,GETDATE()) And IsNull(SEffectiveTo,GETDATE())
		
		--If @Map = 1
		--Select Product_Code ,Product_Name,PTax_Code ,PCS_TaxCode =CONVERT(nvarchar,Case when PCS_TaxCode > 0  then PCS_TaxCode Else '' End),PTax_Desc ,
		--PEffectiveFrm = convert(varchar(10),PEffectiveFrm,103)  ,PEffectiveTo=convert(varchar(10),PEffectiveTo,103 ), PTax_Active ,
		--STax_Code ,SCS_TaxCode = CONVERT(nvarchar,Case when SCS_TaxCode > 0  then SCS_TaxCode Else '' End) ,STax_Desc ,SEffectiveFrm=convert(varchar(10),SEffectiveFrm,103) ,
		--SEffectiveTo=convert(varchar(10),SEffectiveTo,103),STax_Active  from #tmpItems Where PTax_Active = 1 Or STax_Active = 1
		--Order By Product_Code,PEffectiveFrm,SEffectiveFrm
		--Else
		Select Product_Code ,Product_Name,
		PTax_Code ,PCS_TaxCode =CONVERT(nvarchar,Case when PCS_TaxCode > 0  then PCS_TaxCode Else '' End),PTax_Desc ,
		PEffectiveFrm = convert(varchar(10),PEffectiveFrm,103), PEffectiveTo=isnull(convert(varchar(10),PEffectiveTo,103 ),''), PTax_Active ,
		STax_Code ,SCS_TaxCode = CONVERT(nvarchar,Case when SCS_TaxCode > 0  then SCS_TaxCode Else '' End) ,STax_Desc ,
		SEffectiveFrm=isnull(convert(varchar(10),SEffectiveFrm,103),''), 
		SEffectiveTo=isnull(convert(varchar(10),SEffectiveTo,103),''),
		STax_Active  
		From #tmpItems
		--Order By Product_Code,PEffectiveFrm,SEffectiveFrm
		Order By Category_Name ,Product_Code,PEffectiveFrm,SEffectiveFrm
	--End
	drop table #tmpItems
	drop table #tmpRecMapID
	drop table #tmpFinalTax
	drop table #tmpCat
	drop table #tmpHItems
END
