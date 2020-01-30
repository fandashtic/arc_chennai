create function mERP_fn_Handle_OutletPoints(@InvId Int,@QPS int = 0,@Mode int = 0,@nSchemeId int = 0)
returns @tbl_merp_outletpoints_NONQPS  table(   [ID] [Int] IDENTITY(1,1) NOT NULL, 
	[InvoiceID] [int] NULL,
	[SchemeID] [int] NULL,
	[SlabId] [int] NULL,
	[OutletCode] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Points] [decimal](18, 6) NULL,
	[Rate] [decimal](18, 6) NULL,	
	[CreationDate] [datetime] NULL DEFAULT (getdate()),
	[QPS] [INT] NULL,
	[Status] [int] NULL
) 
as
Begin
declare @Outlet nvarchar(255) 
declare @InvDate datetime
declare @InvValue decimal(18,6)
declare @TaxValue decimal(18,6)
declare @OldInvId Int 
declare @SchemeID as int
declare @Slabid as int
declare @Onward as decimal(18,6)
declare @AccrualPoints as decimal(18,6)
declare @UnitRate as decimal(18,6)
declare @SKUCount as int
Declare @OLClass nVarchar(255)
Declare @Channel nVarchar(255)
Declare @CreationDate datetime
Declare @SKUCode nvarchar(255)
Declare @Quantity decimal(18,6)
Declare @Category  nvarchar(255)
Declare @SubCat  nvarchar(255)
Declare @MarKetSKU  nvarchar(255)
Declare @ItemValue decimal(18,6)
declare @UOM int
Declare @UOM1_Conversion decimal(18,6)
Declare @UOM2_Conversion decimal(18,6)

Declare @UOM1_Qty decimal(18,6)
Declare @UOM2_Qty decimal(18,6)
Declare @UOM_Conversion decimal(18,6)
Declare @GroupID int
Declare @TempInvId int
Declare @InvType int
Declare @OlMapId Int
Declare @OlLoyalty nVarchar(255)

--declare @Outlet nvarchar(255)
--declare @InvDate datetime
--set dateformat dmy
--set @outlet = ''
--declare @tbl_merp_outletpoints_NONQPS table
--(
--    [ID] [Int] IDENTITY(1,1) NOT NULL, 
--	[InvoiceID] [int] NULL,
--	[SchemeID] [int] NULL,
--	[SlabId] [int] NULL,
--	[OutletCode] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
--	[Points] [decimal](18, 6) NULL,
--	[Rate] [decimal](18, 6) NULL,	
--	[CreationDate] [datetime] NULL DEFAULT (getdate()),
--	[QPS] [INT] NULL,
--	[Status] [int] NULL
--) 


--If @Mode = 1 -- To calculate the points freshly and removing the old points calculated
--	Delete from tbl_merp_outletpoints_NONQPS where schemeid = @nschemeid and InvoiceId = @InvId

select @InvDate = Invoicedate,@Outlet = CustomerID,@InvValue=NetValue,
@TaxValue=TotalTaxApplicable,@InvType =InvoiceType,@CreationDate=CreationTime --case when Invoicetype=3 then InvoiceReference else 0 end 
from InvoiceAbstract where Invoiceid=@InvId and InvoiceType in (1,3,4)

If Isnull(@InvType,0) = 0
	goto exitHandle
select @SKUCount=count(*) from InvoiceDetail where InvoiceID = @InvID
set @TempInvId = @InvId
If @InvType = 3
Begin
Declare @i Int
Set @i = 1
While @i <> 0
Begin
	If (Select IsNull(InvoiceReference, 0) From InvoiceAbstract Where InvoiceID = @TempInvId And InvoiceType = 1) = 0
	Begin
		Set @i = 0
		Select @InvDate=InvoiceDate, @oldInvId=InvoiceID From InvoiceAbstract Where InvoiceID = @TempInvId
	End
	Else
		Select @TempInvID = InvoiceReference From InvoiceAbstract Where InvoiceID = @TempInvId
End
End
--If @OldInvid > 0
--	select @CreationDate = Min(Invoicedate) from InvoiceAbstract where DocumentID =(select DocumentID from InvoiceAbstract where invoiceID =@OldInvid)
--else
--	set @CreationDate = @InvDate


/*
Select @Channel = ChannelDesc From Customer_Channel CC, Customer C
	 Where C.CustomerID = @Outlet
	 And CC.ChannelType = C.ChannelType

Select @OLClass = isnull(CM.TMDValue,'All') From Cust_TMD_Master CM, Cust_TMD_Details CD 
		Where CM.TMDID = CD.TMDID
		And CD.CustomerID = @Outlet
		And CM.TMDCtlPos = 6
Select @OLClass = IsNull(@OLClass,'All')
*/
/*	Select @OlMapId = isNull(OLClassID,0) from  tbl_Merp_OlclassMapping where CustomerID = @Outlet and Active =1

	Select
		 @Channel = isNull(Channel_Type_desc,''), 
		 @OLClass = isNull(Outlet_Type_desc,''),
		 @OlLoyalty = isNull(SubOutlet_Type_desc,'')
	From 
		tbl_merp_Olclass 
	where 
		ID = @OlMapId
*/
Declare @TmpScheme table (Schemeid int ,GroupId int,schemeType int) --schemetype to main 1-Invoice base, 2-Item base or 3-Item base Spl cat
Declare @TmpInvScheme table (Schemeid int,SlabId int,Uom int,Onward decimal(18,6),AccrualPoints decimal(18,6),UnitRate decimal(18,6),Quantity decimal(18,6))
Declare @TmpSKU table (ProductCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS default '',Quantity decimal(18,6) default 0,SaleAmount decimal(18,6) default 0,TaxAmount decimal(18,6) default 0,Amount decimal(18,6) default 0,UOM1_Conversion decimal(18,6) default 0,UOM2_Conversion decimal(18,6) default 0,MarKetSKU nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SubCategoryID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SubCat nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,CategoryID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Category nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Uom1_Qty decimal(18,6) default 0,Uom2_Qty decimal(18,6) default 0)

--Item Base Scheme
Insert into @TmpSKU (ProductCode ,Quantity ,SaleAmount,TaxAmount ,Amount) (
Select Product_Code "ProductCode",Sum(Quantity) Quantity ,sum(Quantity * SalePrice) SaleAmount,Sum(TaxAmount) TaxAmount,sum(Amount) Amount from InvoiceDetail where InvoiceId= @InvId 
and Isnull(FlagWord,0) = 0 group by Product_code )

update @TmpSKU set T.MarketSKU = Cat.Category_Name,T.SubCategoryID = Cat.ParentID  From @TmpSKU T, ItemCategories Cat,Items I Where Cat.CategoryID = I.CategoryID and I.Product_Code=T.ProductCode
--Select @MarKetSKU = Category_Name,@SubCategoryID = ParentID From ItemCategories Where CategoryID = 
--(Select CategoryID From Items Where Product_Code = @SKUCode)

Update @TmpSKU set T.SubCat=Cat.Category_Name,T.CategoryId=Cat.ParentId from @TmpSKU T,ItemCategories cat where cat.CategoryId=T.SubCategoryID
--Select 	@SubCat = Category_Name,@CategoryID = ParentID From ItemCategories Where CategoryID = @SubCategoryID
update @TmpSKU set T.Category = Cat.Category_Name from @TmpSKU T,ItemCategories cat where cat.CategoryId=T.CategoryID
--Select 	@Category = Category_Name  From ItemCategories Where CategoryID = @CategoryID
Update @TmpSKU set  T.UOM1_Conversion = IsNull(I.UOM1_Conversion,1), T.UOM2_Conversion = IsNull(I.UOM2_Conversion,1) From @TmpSKU T,Items I Where T.Productcode = I.Product_code
Update @TmpSKU set  T.UOM1_Qty = T.Quantity / IsNull(I.UOM1_Conversion,1), T.UOM2_Qty = T.Quantity/IsNull(I.UOM2_Conversion,1) From @TmpSKU T,Items I Where T.Productcode = I.Product_code

if @Mode = 1
Begin
--Applicable Schemes
/*Old */
--Insert into @TmpScheme
--select SA.SchemeID,Min(SO.GroupID),Case When (SA.ApplicableOn = 2) then 1 When (SA.ApplicableOn = 1 and SA.ItemGroup = 1) then 2 else 3 End
--from tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeOutlet SO,
--tbl_mERP_SchemeChannel SC, tbl_mERP_SchemeOutletClass SOC,tbl_mERP_SchemeSlabDetail SS ,
--tbl_mERP_SchemeLoyaltyList SLList
--where SA.SchemeType=4 and SA.Active = 1 and SA.SchemeId = @nSchemeId
----and SA.SKUCount <= @SKUCount 
----and SA.SchemeFrom<= @InvDate and SA.ExpiryDate >=@InvDate
--And (dbo.StripTimeFromDate(@InvDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ActiveTo) )
--And (dbo.stripTimeFromDate(@CreationDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ExpiryDate)) 
--And SA.SchemeId = SS.SchemeID 
--and SS.SlabType = 5
----and (SS.SlabStart < = @InvValue and SS.SlabEnd >= @InvValue)
--And SA.SchemeID = SO.SchemeID
--And SO.QPS = @QPS --Direct Scheme
--And (SO.OutletID = @Outlet Or SO.OutletID = N'ALL')
--And SO.SchemeID = SC.SchemeID
--And SO.GroupID = SC.GroupID
--And (SC.Channel = @Channel Or SC.Channel = N'ALL')
--And SO.SchemeID = SOC.SchemeID 
--And SO.GroupID = SOC.GroupID
--And (SOC.OutletClass = @OLClass Or SOC.OutletClass = N'ALL')
--And SA.SchemeID = SLList.SchemeID 
--And SLList.GroupID = SO.GroupID 
--And (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')
--group by SA.SchemeID ,SA.ApplicableOn,SA.ItemGroup

/*New*/
Insert into @TmpScheme
Select Distinct S.SchemeID,So.GroupID,Case When (S.ApplicableOn = 2) then 1 When (S.ApplicableOn = 1 and S.ItemGroup = 1) then 2 else 3 End
	From 
		tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,  tbl_mERP_SchemeChannel SC ,
		tbl_mERP_SchemeOutletClass  SOLC, tbl_mERP_SchemeLoyaltyList SLList,tbl_Merp_OlclassMapping OLM,
		tbl_merp_Olclass OL,Customer C
	Where 
		S.SCHEMEID = @nSchemeID AND		
		S.Active = 1 And
		S.SchemeType = 4 and
		C.CustomerID = @Outlet And
		C.CustomerID = OLM.CustomerID And
		--C.ACTIVE = 1 AND
		OLM.OLClassID = OL.ID And
		OLM.Active = 1 And 
		S.SchemeID = SO.SchemeID And
		SO.QPS = @QPS And
		(SO.OutletID = C.CustomerID Or SO.OutletID = N'All')  
		And S.SchemeID = SC.SchemeID And
		SC.GroupID = SO.GroupID And
		(SC.Channel = OL.Channel_Type_Desc Or SC.Channel = N'All')  And 
		S.SchemeID = SOLC.SchemeID And
		SOLC.GroupID = SO.GroupID And
		(SOLC.OutLetClass = OL.Outlet_Type_Desc Or SOLC.OutLetClass = N'All')  And
		S.SchemeID = SLList.SchemeID And
		SLList.GroupID = SO.GroupID And
		(SLList.LoyaltyName = OL.SubOutlet_Type_Desc Or SLList.LoyaltyName = N'All')
	Group By S.SchemeID,S.ApplicableOn,S.ItemGroup,SO.GroupID,C.CustomerID,So.QPS
End
--ELse
--Begin
--Insert into @TmpScheme
--select SA.SchemeID,Min(SO.GroupID),Case When (SA.ApplicableOn = 2) then 1 When (SA.ApplicableOn = 1 and SA.ItemGroup = 1) then 2 else 3 End
--from tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeOutlet SO,
--tbl_mERP_SchemeChannel SC, tbl_mERP_SchemeOutletClass SOC,tbl_mERP_SchemeSlabDetail SS 
--where SA.SchemeType=4 and SA.Active = 1 --and SA.ApplicableOn = 2 
----and SA.SKUCount <= @SKUCount 
----and SA.SchemeFrom<= @InvDate and SA.ExpiryDate >=@InvDate
--And (dbo.StripTimeFromDate(@InvDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ActiveTo) )
--And (dbo.stripTimeFromDate(@CreationDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ExpiryDate)) 
--And SA.SchemeId = SS.SchemeID 
--and SS.SlabType = 5
----and (SS.SlabStart < = @InvValue and SS.SlabEnd >= @InvValue)
--And SA.SchemeID = SO.SchemeID
--And SO.QPS = @QPS --Direct Scheme
--And (SO.OutletID = @Outlet Or SO.OutletID = N'ALL')
--And SO.SchemeID = SC.SchemeID
--And SO.GroupID = SC.GroupID
--And (SC.Channel = @Channel Or SC.Channel = N'ALL')
--And SO.SchemeID = SOC.SchemeID 
--And SO.GroupID = SOC.GroupID
--And (SOC.OutletClass = @OLClass Or SOC.OutletClass = N'ALL')
--group by SA.SchemeID ,SA.ApplicableOn,SA.ItemGroup
--End

--*************************For Invoice Based scheme******************
Insert into @TmpInvScheme
select SS.SchemeID,SS.Slabid,SS.UOM,SS.Onward ,SS.[Value] ,SS.UnitRate ,0
from @tmpScheme TS,tbl_mERP_SchemeAbstract SA,tbl_mERP_SchemeSlabDetail SS 
where TS.SchemeID=SA.SchemeID and TS.SchemeType = 1 
and SA.SchemeID=SS.SchemeID and SA.SKUCount <= @SKUCount and
(SlabStart <= @InvValue and SlabEnd >=@InvValue)

DECLARE Crsr CURSOR FOR
select Distinct SchemeID,Slabid,UOM,Onward ,AccrualPoints ,UnitRate from @TmpInvScheme 
OPEN Crsr
FETCH NEXT FROM Crsr into @SchemeID,@Slabid,@UOM,@Onward,@AccrualPoints ,@UnitRate
WHILE (@@FETCH_STATUS <> -1)
Begin
	if @Onward = 0
		Begin
		if @Mode = 1 
			insert into @tbl_merp_outletpoints_NONQPS (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
			values (@InvId,@SchemeId,@SlabId,@Outlet,@AccrualPoints,@UnitRate,0,@QPS)
--		else
--			insert into tbl_mERP_OutletPoints (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
--			values (@InvId,@SchemeId,@SlabId,@Outlet,@AccrualPoints,@UnitRate,0,@QPS)
		End
	else
		Begin
		if @Mode  = 1			
			insert into @tbl_merp_outletpoints_NONQPS (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
			values (@InvId,@SchemeId,@SlabId,@Outlet,(cast( @InvValue/@Onward as Int) * @AccrualPoints),@UnitRate,0,@QPS)					
--		else
--			insert into tbl_mERP_OutletPoints (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
--			values (@InvId,@SchemeId,@SlabId,@Outlet,(cast( @InvValue/@Onward as Int) * @AccrualPoints),@UnitRate,0,@QPS)					
		End 

FETCH NEXT FROM Crsr into @SchemeID,@Slabid,@UOM,@Onward,@AccrualPoints ,@UnitRate
End
Close CrSr
Deallocate CrSr

Delete from @TmpInvScheme


Declare @tmpSchProdScope Table (SchemeID Int,ProductScopeID Int)

--Declare @SchemeID Int

--******************************For Item based schemes****************
Declare @ScopeID Int		
Declare Cur_SKU Cursor for
Select ProductCode,sum(Quantity),Category,SubCat,MarKetSKU,sum(Amount),Max(UOM1_CONVERSION),Max(UOM2_CONVERSION) from @tmpSKU group by ProductCode,Category,SubCat,MarKetSKU
Open Cur_SKU 
Fetch Next From Cur_SKU Into @SKUCode,@Quantity,@Category,@SubCat,@MarKetSKU,@ItemValue,@UOM1_CONVERSION,@UOM2_CONVERSION
While @@Fetch_Status = 0
Begin
		delete from @tmpInvScheme
		Delete from @tmpSchProdScope
		Declare Cur_SchemeID  Cursor For 
		Select SchemeID From @tmpScheme where SchemeType = 2
		Open Cur_SchemeID
		Fetch Next From Cur_SchemeID Into @SchemeID
		While @@Fetch_Status = 0
		Begin
			Declare Cur_ScopeID Cursor For
			Select ProductScopeID From tbl_mERP_SchemeProductScopeMap Where SchemeID = @SchemeID
			Open Cur_ScopeID
			Fetch Next From Cur_ScopeID Into @ScopeID
			While @@Fetch_Status = 0
			Begin
				Insert Into @tmpSchProdScope
				Select @SchemeID,Cat.ProductScopeID
				From
					 tbl_mERP_SchCategoryScope Cat,tbl_mERP_SchSubCategoryScope SubCat,
					 tbl_mERP_SchMarketSKUScope MarSKU,tbl_mERP_SchSKUCodeScope SKU
				Where 
					 Cat.ProductScopeID = SubCat.ProductScopeID And
					 SubCat.ProductScopeID = MarSKU.ProductScopeID And
					 MarSKU.ProductScopeID = SKU.ProductScopeID And
					 Cat.ProductScopeID = @ScopeID And
					 (Cat.Category = @Category Or Cat.Category = 'All') And
					 (SubCat.SubCategory = @SubCat Or SubCat.SubCategory = 'All') And
					 (MarSKU.MarketSKU = @MarKetSKU Or MarSKU.MarketSKU = 'All') And
					 (SKU.SKUCode = @SKUCode Or SKU.SKUCode = 'All') 
				Fetch Next From Cur_ScopeID Into @ScopeID
			End
			Close Cur_ScopeID
			Deallocate Cur_ScopeID
			Fetch Next From Cur_SchemeID Into @SchemeID
		End
		Close Cur_SchemeID
		Deallocate Cur_SchemeID
	
	--Delete from @tmpSlab
	--SlabType 0 - ItemBased Amount,1 - ItemBased Pecentage, 2 - ItemBased FreeItem
	Insert Into @tmpInvScheme (SchemeId,SlabId,UOM,Onward,AccrualPoints,UnitRate,Quantity)
	Select Distinct
		SAbs.SchemeID,SSLAB.SLABID,SSLAB.UOM,SSLAB.Onward,SSLAB.[Value],SSLAB.UnitRate,@Quantity
	From 
		tbl_mERP_SchemeAbstract SAbs, tbl_mERP_SchemeSlabDetail SSLAB,@tmpScheme T
	Where
		SAbs.SchemeID In(Select SchemeID From @tmpSchProdScope) And
		SAbs.SchemeID = T.SchemeID And
		T.SchemeType = 2 And
		SAbs.SchemeID = SSLAB.SchemeID And
		SSLAB.GroupID = T.GroupID And
		SSLAB.UOM IN(1,2,3) And  ---Quantity based slab
		 (@Quantity between           
				  (Case IsNull(SSLAB.UOM,0)           
				  When 1 then SSLAB.SlabStart           
				  When 2 then SSLAB.SlabStart * @UOM1_Conversion          
				  When 3 then SSLAB.SlabStart * @UOM2_Conversion 
				  End) and           
				  (Case IsNull(SSLAB.UOM,0)           
				  When 1 then SSLAB.SlabEnd           
				  When 2 then SSLAB.SlabEnd * @UOM1_Conversion          
				  When 3 then SSLAB.SlabEnd * @UOM2_Conversion End
				  )
		   )  And
		@Quantity >= (Case IsNull(SSLAB.Onward,0) When 0 Then 0 Else (Case IsNull(SSLAB.UOM,0)
			      When 1 then SSLAB.Onward           
				  When 2 then SSLAB.Onward* @UOM1_Conversion          
				  When 3 then SSLAB.Onward* @UOM2_Conversion 
				  End)	End)
	Order By Uom
			
	Insert Into @tmpInvScheme (SchemeId,SlabId,UOM,Onward,AccrualPoints,UnitRate,Quantity)
	Select Distinct
		SAbs.SchemeID,SSLAB.SLABID,SSLAB.UOM,SSLAB.Onward,SSLAB.[Value],SSLAB.UnitRate,@Quantity		
	From 
		tbl_mERP_SchemeAbstract SAbs, tbl_mERP_SchemeSlabDetail SSLAB,@tmpScheme T --,@tmpSKU SKU
	Where
		SAbs.SchemeID In(Select SchemeID From @tmpSchProdScope) And
		SAbs.SchemeID = T.SchemeID And
		T.SchemeType = 2 And
		--SAbs.ApplicableOn = 1 and SAbs.ItemGroup = 1 And
		SAbs.SchemeID = SSLAB.SchemeID And
		SSLAB.GroupID = T.GroupID And
		SSLAB.UOM = 4 And			
		(SSLAB.SlabStart<=@ItemValue  and SSLAB.SlabEnd >=@ItemValue ) 		

	--
	
	DECLARE Crsr CURSOR FOR
	select Distinct SchemeID,Slabid,UOM,Onward ,AccrualPoints ,UnitRate from @TmpInvScheme 
	OPEN Crsr
	FETCH NEXT FROM Crsr into @SchemeID,@Slabid,@UOM,@Onward,@AccrualPoints ,@UnitRate
	WHILE (@@FETCH_STATUS <> -1)
	Begin
		if @Onward = 0
			Begin
			--For flat point we need not to worry about the quantity value or item value.
			if @Mode =1 
				insert into @tbl_merp_outletpoints_NONQPS (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
				values (@InvId,@SchemeId,@SlabId,@Outlet,@AccrualPoints,@UnitRate,0,@QPS)		
--			else
--				insert into tbl_mERP_OutletPoints (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
--				values (@InvId,@SchemeId,@SlabId,@Outlet,@AccrualPoints,@UnitRate,0,@QPS)
			End
		else --For every
			Begin			
			if (@UOM = 4) 
				Begin
				if @Mode = 1
					insert into @tbl_merp_outletpoints_NONQPS (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
					values (@InvId,@SchemeId,@SlabId,@Outlet,((cast(@ItemValue/@Onward as int)) * @AccrualPoints),@UnitRate,0,@QPS)					
--				else
--					insert into tbl_mERP_OutletPoints (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
--					values (@InvId,@SchemeId,@SlabId,@Outlet,((cast(@ItemValue/@Onward as int)) * @AccrualPoints),@UnitRate,0,@QPS)					
				End
			else				
				Begin								
				if @UOM = 2 
					set @Uom_Conversion = @UOM1_Conversion
				else if @UOM = 3
					set @Uom_Conversion = @UOM2_Conversion
				else
					set @Uom_Conversion = 1				
				if @Mode = 1
					insert into @tbl_merp_outletpoints_NONQPS (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
					values (@InvId,@SchemeId,@SlabId,@Outlet, cast( (@Quantity/(@Onward*@UOM_conversion)) as Int) * @AccrualPoints,@UnitRate,0,@QPS)					
--				else
--					insert into tbl_mERP_OutletPoints (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
--					values (@InvId,@SchemeId,@SlabId,@Outlet, cast( (@Quantity/(@Onward*@UOM_conversion)) as Int) * @AccrualPoints,@UnitRate,0,@QPS)					
				End
			End 
	
	FETCH NEXT FROM Crsr into @SchemeID,@Slabid,@UOM,@Onward,@AccrualPoints ,@UnitRate
	End
	Close CrSr
	Deallocate CrSr


Fetch Next From Cur_SKU Into @SKUCode,@Quantity,@Category,@SubCat,@MarKetSKU,@ItemValue,@UOM1_CONVERSION,@UOM2_CONVERSION
End
Close Cur_SKU
Deallocate Cur_SKU
--End Item Base Schemes


--For Spl Category schemes
Declare Cur_SchemeID  Cursor For 
Select SchemeID,GroupId From @tmpScheme where SchemeType = 3
Open Cur_SchemeID
Fetch Next From Cur_SchemeID Into @SchemeID,@GroupID
While @@Fetch_Status = 0
Begin
	delete from @tmpInvScheme
	Declare Cur_SKU Cursor for
	select Sum(x.Quantity),Sum(x.Amount),Sum(x.UOM1_CONVERSION),Sum(x.UOM2_CONVERSION),Sum(x.Uom1_Qty) ,Sum(x.Uom2_Qty) from 
	(Select Sum(Quantity) Quantity,Sum(Amount) Amount,Sum(UOM1_CONVERSION) UOM1_CONVERSION,Sum(UOM2_CONVERSION) UOM2_CONVERSION,Sum(Uom1_Qty) UOM1_QTY,Sum(Uom2_Qty) UOM2_QTY from @tmpSKU where ProductCode in (Select Product_code from dbo.mERP_fn_Get_CSSku(@SchemeID)) group by ProductCode) x
	Open Cur_SKU 
	Fetch Next From Cur_SKU Into @Quantity,@ItemValue,@UOM1_CONVERSION,@UOM2_CONVERSION,@UOM1_QTY,@UOM2_QTY
	While @@Fetch_Status = 0
	Begin
		Insert Into @tmpInvScheme (SchemeId,SlabId,UOM,Onward,AccrualPoints,UnitRate,Quantity)
		Select Distinct
			@SchemeID,SSLAB.SLABID,SSLAB.UOM,SSLAB.Onward,SSLAB.[Value],SSLAB.UnitRate,@Quantity			
		From 
			tbl_mERP_SchemeSlabDetail SSLAB
		Where
			SSLAB.SchemeID = @SchemeID And --In(Select SchemeID From @tmpSchProdScope) And
			SSLAB.GroupID = @GroupID And
			SSLAB.UOM IN(1,2,3) And  ---Quantity based slab	SSLAB.SlabStart<=@ItemValue  and SSLAB.SlabEnd >=@ItemValue 	            
			(SSLAB.SlabStart <= Case sslab.uom when 1 then @Quantity when 2 then @Uom1_Qty else @uom2_qty End 
			and 
			SSLAB.SlabEnd >= Case sslab.uom when 1 then @Quantity when 2 then @Uom1_Qty else @uom2_qty End )
            --case when sslab.uom =1 then SSLAB.SlabStart<=@Quantity and SSLAB.SlabEnd>=@Quantity end
--			Case WHEN SSLAB.UOM=1 THEN @Quantity between SSLAB.SlabStart and SSLAB.SlabEnd 
--			  WHEN SSLAB.UOM=2 THEN @UOM1_Qty between SSLAB.SlabStart and SSLAB.SlabEnd 
--			  WHEN SSLAB.UOM=3 THEN @UOM2_Qty between SSLAB.SlabStart and SSLAB.SlabEnd 	
--			End			
		Order By Uom
				


		Insert Into @tmpInvScheme (SchemeId,SlabId,UOM,Onward,AccrualPoints,UnitRate,Quantity)
		Select Distinct
			@SchemeID,SSLAB.SLABID,SSLAB.UOM,SSLAB.Onward,SSLAB.[Value],SSLAB.UnitRate,@Quantity
		From 
			tbl_mERP_SchemeSlabDetail SSLAB --tbl_mERP_SchemeAbstract SAbs, tbl_mERP_SchemeSlabDetail SSLAB,@tmpScheme T --,@tmpSKU SKU
		Where
			SSLAB.SchemeID = @SchemeID And
			SSLAB.GroupID = @GroupID And
			SSLAB.UOM = 4 And	
			(SSLAB.SlabStart<=@ItemValue  and SSLAB.SlabEnd >=@ItemValue ) 		


		--
		DECLARE Crsr CURSOR FOR
		select Distinct Slabid,UOM,Onward ,AccrualPoints ,UnitRate from @TmpInvScheme 
		OPEN Crsr
		FETCH NEXT FROM Crsr into @Slabid,@UOM,@Onward,@AccrualPoints ,@UnitRate
		WHILE (@@FETCH_STATUS <> -1)
		Begin
			if @Onward = 0
				Begin
				--For flat point we need not to worry about the quantity value or item value.
				if @Mode = 1
					insert into @tbl_merp_outletpoints_NONQPS (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
					values (@InvId,@SchemeId,@SlabId,@Outlet,@AccrualPoints,@UnitRate,0,@QPS)
--				else
--					insert into tbl_mERP_OutletPoints (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
--					values (@InvId,@SchemeId,@SlabId,@Outlet,@AccrualPoints,@UnitRate,0,@QPS)
				End
			else --For every
				Begin			
				if (@UOM = 4) 
					Begin
					if @Mode = 1
						insert into @tbl_merp_outletpoints_NONQPS (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
						values (@InvId,@SchemeId,@SlabId,@Outlet,((cast(@ItemValue /@Onward as int)) * @AccrualPoints),@UnitRate,0,@QPS)					
--					else
--						insert into tbl_mERP_OutletPoints (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
--						values (@InvId,@SchemeId,@SlabId,@Outlet,((cast(@ItemValue /@Onward as int)) * @AccrualPoints),@UnitRate,0,@QPS)					
					End
				else				
					Begin								
--					if @UOM = 2 
--						set @Uom_Conversion = @UOM1_Conversion
--					else if @UOM = 3
--						set @Uom_Conversion = @UOM2_Conversion
--					else
--						set @Uom_Conversion = 1				
					if @Mode = 1
						insert into @tbl_merp_outletpoints_NONQPS (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
						values (@InvId,@SchemeId,@SlabId,@Outlet, cast(( ( case @UOM when 1 then @Quantity when 2 then @Uom1_QTY else @UOM2_qty end)/(@Onward)) as Int ) * @AccrualPoints,@UnitRate,0,@QPS)					
--					else
--						insert into tbl_mERP_OutletPoints (InvoiceId,SchemeId,SlabId,OutletCode,Points,Rate,Status,QPS) 
--						values (@InvId,@SchemeId,@SlabId,@Outlet, cast(( ( case @UOM when 1 then @Quantity when 2 then @Uom1_QTY else @UOM2_qty end)/(@Onward)) as Int ) * @AccrualPoints,@UnitRate,0,@QPS)					

					End
				End 

		FETCH NEXT FROM Crsr into @Slabid,@UOM,@Onward,@AccrualPoints ,@UnitRate
		End
		Close CrSr
		Deallocate CrSr


	Fetch Next From Cur_SKU Into @Quantity,@ItemValue,@UOM1_CONVERSION,@UOM2_CONVERSION,@UOM1_QTY,@UOM2_QTY
	End
	Close Cur_SKU
	Deallocate Cur_SKU

Fetch Next From Cur_SchemeID Into @SchemeID,@GroupID
End
Close Cur_SchemeID
Deallocate Cur_SchemeID


--End Spl Category schemes
if @InvType = 4
Begin
if @Mode = 1
	update @tbl_merp_outletpoints_NONQPS set Points = (Points * -1) where InvoiceId = @InvId and QPS=@QPS
--else
--	update tbl_mERP_OutletPoints set Points = (Points * -1) where InvoiceId = @InvId and QPS=@QPS
End

if (@OldInvId > 0)
Begin
if @Mode = 1
	update @tbl_merp_outletpoints_NONQPS set status = 1 where InvoiceId=@OldInvId and QPS=@QPS
--else
--	update tbl_mERP_OutletPoints set status = 1 where InvoiceId=@OldInvId and QPS=@QPS
End
--if (@QPS =0 and @mode = 0)
--Begin
--exec mERP_sp_Handle_OutletPoints @InvId,1
--End
--if @Mode = 1
--Begin
--Insert into tbl_merp_outletPoints_NonQPS (InvoiceID,SchemeID,SlabId,OutletCode,Points,Rate,CreationDate,QPS,Status)
--select InvoiceID,SchemeID,SlabId,OutletCode,Points,Rate,CreationDate,QPS,Status from tbl_merp_outletPoints where Invoiceid=@InvId and QPS=0
--End
exitHandle:
return 
End
