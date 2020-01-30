Create Procedure mERP_sp_ProcessPM(@REC_PMID Int)
As
Begin

/* Abstract parameter */
Declare @CPM_PMID Int
Declare @CPM_PMCode nVarchar(50)
Declare @CPM_Description nVarchar(100)
Declare @CPM_Groups nVarchar(50)
Declare @CPM_Period nVarchar(15)
Declare @CPM_Active int
Declare @Status Int
Declare @PMID Int

Declare @Errmessage nVarchar(255)
Declare @ProcessDate Datetime
Declare @KeyValue nVarchar(255)

Select @ProcessDate = GetDate()

Set @PMID = 0
Set @Errmessage = ''

/* DsType  */
Declare @REC_DSID Int
Declare @CMP_DSType nVarchar(100)
Declare @CPM_MaxPoints Decimal(18,6)

Declare @DSID Int

Declare @FlagCursor Int

/* Param */
Declare @REC_ParamID Int
Declare @CPM_DSID Int
Declare @CPM_Frequency nVarchar(10)
Declare @CPM_ParamMaxPoints Decimal(18,6)
Declare @CPM_ParameterType nVarchar(50)
Declare @CPM_isFocusParameter nVarchar(5)
Declare @CPM_isFocusID Int
Declare @ParamID Int
Declare @ExistingPMID Int
Declare @GrowthPercentage decimal(18,6)
Declare @Cutoff_Percentage Decimal(18,6)
Declare @CPM_DependentParamID Int
Declare @DependentCutoff Decimal(18,6)
Declare @TargetType Int
Declare @ComparisonType Int

Create Table #tmpRecId(Id Int Identity(1,1),RecID Int)

Set @ExistingPMID = 0

/*Abstract Begins */
Select @CPM_PMID = CPM_PMID ,@CPM_PMCode = CPM_PMCode,@CPM_Description = CPM_Description,
@CPM_Period = CPM_Period,@CPM_Groups = CPM_Groups,@CPM_Active = isNull(CPM_Active,0),@Status = isNull(Status,0)
From tbl_mERP_Recd_PMMaster Where REC_PMID = @REC_PMID


If IsNull(@CPM_PMID, 0) = 0
Begin
Set @Errmessage = 'Received PMID Value should not be 0'
Set @KeyValue = 'Received PMID : ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

If IsNull(@CPM_PMCode, '') = ''
Begin
Set @Errmessage = 'Performance Metrics Code has Null Value'
Set @KeyValue = 'Received PMID : ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

If isNull(@CPM_Description,'') = ''
Begin
Set @Errmessage = 'Performance Metrics Description has Null Value'
Set @KeyValue = 'Received PMID : ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

If (@CPM_Active <> 1 And @CPM_Active <> 0)
Begin
Set @Errmessage = 'Active must be either 0 Or 1'
Set @KeyValue = 'Received PMID : ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

If @CPM_Active = 1
Begin
If (Select Count(PMCode) From tbl_mERP_PMMaster Where PMCode = @CPM_PMCode And Active = 1 And Status = 1) >= 1
Begin
Select Top 1 @ExistingPMID = PMID From tbl_mERP_PMMaster Where PMCode = @CPM_PMCode And Active = 1 And Status = 1
If (Select count(TargetDefnID) From tbl_mERP_PMetric_TargetDefn Where PMID = @ExistingPMID And Active = 1) >=1
Begin
--Set @Errmessage = 'Received PMID should be unique'
Set @Errmessage = 'Performance Metrics already exists and target defined for it, hence cannot be overwritten'
Set @KeyValue = 'Received PMID : ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End
Else
Begin
/*If Target Not Defined then overwrite the already existing one */
Update tbl_mERP_PMMaster Set Active = 0 , status = 3 Where PMCode = @CPM_PMCode And Active = 1
End
End
Else If (Select Count(PMCode) From tbl_mERP_PMMaster Where PMCode = @CPM_PMCode And Active = 0 And Status = 2) >= 1
Begin
/* A dropped Performance Metrics cannot be activated again */
Set @Errmessage = 'Performance Metrics already exists in the Drop state and hence cannot be activated again'
Set @KeyValue = 'Received PMID : ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End
End
Else If @CPM_Active = 0
Begin
If (Select Count(PMCode) From tbl_mERP_PMMaster Where PMCode = @CPM_PMCode And Active = 1 And Status = 1) = 0
Begin
Set @Errmessage = 'Performance Metrics does not exist in the active state and hence cannot be dropped.'
Set @KeyValue = 'Received PMID : ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End
End

If (isNull(@CPM_Groups,'') = '' )
Begin
Set @Errmessage = 'Category Group cannot be empty'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

If (@CPM_Groups <> 'GR1|GR3' And @CPM_Groups <> 'GR2' And @CPM_Groups <> 'GR1' And  @CPM_Groups <> 'GR3')
Begin
Set @Errmessage = 'Category Group should be either GR1|GR3 Or GR1 or GR2 or GR3'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

/* validate period Begins*/

If isNull(@CPM_Period,N'') = N''
Begin
Set @Errmessage = 'Period cannot be Null.Every Metrics should be defined for a particular period'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

if Len(Ltrim(Rtrim(@CPM_Period))) > 8
Begin
Set @Errmessage = 'Invalid Period for the Performance Metrics' + '' + cast(@CPM_Period as nVarchar(10))
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

If isDate(Cast(('01' + '-' + @CPM_Period) as nVarchar(15))) = 0
Begin
Set @Errmessage = 'Invalid Date' + '' + cast(@CPM_Period as nVarchar(15))
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

/* validate period Begins */

If @CPM_Active = 0
Begin
--Drop the Scheme
Update tbl_mERP_PMMaster Set Active = 0 ,Status = 2 Where PMCode = @CPM_PMCode
Set @Errmessage = N'Drop'
Goto skip
End
Else
Insert Into tbl_mERP_PMMaster(REC_PMID ,CPM_PMID,PMCode,Description,CGGroups,Period,Active,Status)
Values (@REC_PMID,@CPM_PMID ,@CPM_PMCode,@CPM_Description,@CPM_Groups,@CPM_Period,@CPM_Active,1)

Select @PMID = @@Identity

If @PMID = 0
Begin
Set @Errmessage = 'Error in Inserting Perfomance Metrics'
Set @KeyValue = 'Received PMID : ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

/*Abstract Ends */

/* Atleast One DSType should be there for each PM */
If (Select Count(REC_DSID) From tbl_mERP_Recd_PMDSType Where REC_PMID = @REC_PMID) = 0
Begin
Set @Errmessage = 'Atleast one  DSType should be defined for the PM'
Set @KeyValue = 'Received PMID : ' + Cast(@CPM_PMID as nVarchar(10))
Goto skip
End

Set @FlagCursor = 0

/* DS Starts */
Declare @CMP_DSTypeID as Int
Declare Cur_DSType Cursor For
Select REC_DSID , CPM_DSType,CPM_MaxPoints,CPM_DSTypeID From tbl_mERP_Recd_PMDSType Where REC_PMID = @REC_PMID
Open Cur_DSType
Fetch From Cur_DSType Into @REC_DSID , @CMP_DSType,@CPM_MaxPoints,@CMP_DSTypeID
While @@Fetch_Status = 0
Begin
If isNull(@CMP_DSType,'') = ''
Begin
Set @Errmessage = 'DSType should not have null value'
Set @KeyValue = 'Received PMID : ' + Cast(@CPM_PMID as nVarchar(10))
Set @FlagCursor = 1
Goto skip
End

--		If (@CPM_MaxPoints = 0 Or @CPM_MaxPoints < 0)
--		Begin
--			Set @Errmessage = 'Maximum Points Must be greater than Zero for a DsType'
--			Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
--			Set @FlagCursor = 1
--			Goto skip
--		End

Insert Into tbl_mERP_PMDSType(REC_DSID ,PMID,DSType,MaxPoints,CPM_PMID,CPM_DSTypeID)
Values(@REC_DSID,@PMID,@CMP_DSType,@CPM_MaxPoints,@CPM_PMID,@CMP_DSTypeID)

Select @DSID  = @@Identity

If (Select Count(REC_ParamID)  From tbl_mERP_Recd_PMParam Where REC_DSID = @REC_DSID) = 0
Begin
Set @Errmessage = 'Parameter Details not defined for DSType'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 1
Goto skip
End

Declare @CMP_ParamID as Int
Declare Cur_Param Cursor For
Select REC_ParamID,CPM_DSID,CPM_Frequency,CPM_MaxPoints,CPM_ParameterType,CPM_isFocusParameter,GrowthPercentage,CPM_ParamID,Cutoff_Percentage,Dependent_CPM_ParamID,Dependent_Cutoff,TargetParameterType,ComparisonType
From tbl_mERP_Recd_PMParam
Where REC_DSID = @REC_DSID
Open Cur_Param
Fetch From  Cur_Param Into @REC_ParamID,@CPM_DSID,@CPM_Frequency,@CPM_ParamMaxPoints,@CPM_ParameterType,@CPM_isFocusParameter,@GrowthPercentage,@CMP_ParamID,@Cutoff_Percentage,@CPM_DependentParamID,@DependentCutoff,@TargetType,@ComparisonType
While @@Fetch_Status = 0
Begin
If (@CPM_DSID = 0 Or @CPM_DSID < 0)
Begin
Set @Errmessage = 'DSID In parameter detail Cannot be Zero Or Empty'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

If (isNull(@CPM_Frequency,'') = '')
Begin
Set @Errmessage = 'Parameter Frequency cannot be empty'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

Declare @FrequencyID Int
Set @FrequencyID = 0
Select @FrequencyID = ID From tbl_mERP_PMFrequency Where Frequency = @CPM_Frequency

If isNull(@FrequencyID,0) = 0
Begin
Set @Errmessage = 'Invalid Parameter Frequency , Frequency should be Daily or  Monthly'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

If isNull(@CPM_ParameterType,'') = ''
Begin
Set @Errmessage = 'Parameter Type should not be Null'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

If @CPM_ParameterType = N'Business Achievement'
Begin
/* MaxPoints should be greater than zero only for Business Achievement */
If (@CPM_ParamMaxPoints = 0 Or @CPM_ParamMaxPoints < 0)
Begin
Set @Errmessage = 'Param Maximum Points should be greater than 0 for Business Achievement '
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End
End

If @CPM_ParameterType = N'TOTAL LINES CUT'
Begin
/* MaxPoints should be greater than zero for Total Lines Cut(TLC) */
If (@CPM_ParamMaxPoints = 0 Or @CPM_ParamMaxPoints < 0)
Begin
Set @Errmessage = 'Param Maximum Points should be greater than 0 for TOTAL LINES CUT '
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End
End

/* Total Bills Cut Max Points Checked*/
If @CPM_ParameterType = N'Total Bills Cut'
Begin
/* MaxPoints should be greater than zero for Total Bills Cut */
If (@CPM_ParamMaxPoints = 0 Or @CPM_ParamMaxPoints < 0)
Begin
Set @Errmessage = 'Param Maximum Points should be greater than 0 for Total Bills Cut '
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End
End

/* Blockbuster Max Points Checked*/
If @CPM_ParameterType = N'Blockbuster'
Begin
/* MaxPoints should be greater than zero for Blockbuster */
If (@CPM_ParamMaxPoints = 0 Or @CPM_ParamMaxPoints < 0)
Begin
Set @Errmessage = 'Param Maximum Points should be greater than 0 for Blockbuster '
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End
End

/* UOB (Unique Outlet Billed) Max Points Checked*/
If @CPM_ParameterType = N'UOB'
Begin
/* MaxPoints should be greater than zero for UOB */
If (@CPM_ParamMaxPoints = 0 Or @CPM_ParamMaxPoints < 0)
Begin
Set @Errmessage = 'Param Maximum Points should be greater than 0 for UOB '
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End
End

Declare @ParamTypeID Int
Set @ParamTypeID = 0
Select @ParamTypeID = ID From tbl_mERP_PMParamType Where ParamType = @CPM_ParameterType
If isNull(@ParamTypeID,0) = 0
Begin
Set @Errmessage = 'Invalid Parameter Type ,it should be either Lines Cut,Bills Cut,TOTAL LINES CUT,NUMERIC OUTLET ACH or Business Achievement, Toatl Bills Cut, Blockbuster,Gate-UOB,Gate-Days Worked,UOB,Winner SKU, Depend-Days Worked'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

If isNull(@CPM_isFocusParameter,'') = N''
Begin
Set @Errmessage = 'Is Focus Parameter should not be Null'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

If (isNull(@CPM_isFocusParameter,'') <> 'Yes' And  isNull(@CPM_isFocusParameter,'') <> 'No')
Begin
Set @Errmessage = 'Is Focus Parameter should be either Yes or No'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

If @CPM_isFocusParameter = N'Yes'
Set @CPM_isFocusID = 1
Else
Set @CPM_isFocusID = 0

Insert Into tbl_mERP_PMParam(REC_ParamID,DSTypeID,CPM_DSID,Frequency,MaxPoints,ParameterType,isFocusParameter,GrowthPercentage,CPM_PMID,CPM_ParamID,Cutoff_Percentage,Dependent_CPM_ParamID,Dependent_Cutoff,TargetParameterType,ComparisonType)
Values (@REC_ParamID,@DSID,@CPM_DSID,@FrequencyID,@CPM_ParamMaxPoints,@ParamTypeID,@CPM_isFocusID,@GrowthPercentage,@CPM_PMID,@CMP_ParamID,@Cutoff_Percentage,@CPM_DependentParamID,@DependentCutoff,@TargetType,@ComparisonType )


Select @ParamID = @@Identity

If (Select Count(REC_ParamFocusID) From tbl_mERP_Recd_PMParamFocus Where REC_ParamID = @REC_ParamID) = 0
Begin
Set @Errmessage = 'Invalid Parameter Focus Detail.Focus Parameter not defined for the Parameter'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

If (Select Count(REC_ParamSlabID) From tbl_mERP_Recd_PMParamSlab Where REC_ParamID = @REC_ParamID) = 0
Begin
Set @Errmessage = 'Invalid Slab Detail.Slab details not defined for the Parameter'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

Create Table #TempFocus (CPM_Product_Level Nvarchar(255),REC_ParamID Int)
Insert into #TempFocus (CPM_Product_Level,REC_ParamID)
Select Distinct CPM_Product_Level,REC_ParamID From tbl_mERP_Recd_PMParamFocus Where REC_ParamID = @REC_ParamID

Create Table #tmpParamValue(ParamID Int,LevelCount Int)
Insert into #tmpParamValue(ParamID,LevelCount)
Select Distinct REC_ParamID, Count(CPM_Product_Level) From #TempFocus
Group By REC_ParamID

Delete from #tmpParamValue Where LevelCount = 1

If Exists (Select * From #tmpParamValue)
Begin
Declare @ParamIDNew as Nvarchar(255)
Declare @clu Cursor
Set @clu = Cursor for
select Distinct cast(ParamID as Nvarchar) From #tmpParamValue
Open @clu
Fetch Next from @clu into @ParamIDNew
While @@fetch_status =0
Begin
Set @Errmessage = 'More than One ProducLevel Found in Rec_ParamID (' + @ParamIDNew + ')'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Fetch Next from @clu into @ParamIDNew
End
Close @clu
Deallocate @clu
End

Drop Table #TempFocus
Drop Table #tmpParamValue

/* If the Parameter is Focus Param ProductLevel should be 0 and PrdoductCode sould be All*/
if @CPM_isFocusID = 0
Begin
If (Select Count(REC_ParamFocusID) From tbl_mERP_Recd_PMParamFocus Where REC_ParamID = @REC_ParamID And CPM_Product_Code <> N'All') > 0
Begin
Set @Errmessage = 'Invalid Parameter Focus Detail.For Non Focus parameter  ProductCode should be All'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

If (Select Count(REC_ParamFocusID) From tbl_mERP_Recd_PMParamFocus Where REC_ParamID = @REC_ParamID  And CPM_Product_Code = N'All') = 0
Begin
Set @Errmessage = 'Invalid Parameter Focus Detail.For Non Focus parameter  ProductCode should be All'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End
End

if @CPM_isFocusID = 1
Begin
If (Select Count(REC_ParamFocusID) From tbl_mERP_Recd_PMParamFocus Where REC_ParamID = @REC_ParamID And (CPM_Product_Level = '' Or CPM_Product_Code = N'All')) > 0
Begin
Set @Errmessage = 'Invalid Parameter Focus Detail.For Focus parameter ProductLevel should not be null and ProductCode should not be All'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

Declare @Counter Int
Declare @i as Int
Declare @Prod_Code nVarchar(100)
Declare @Prod_Level nvarchar(50)

Declare @PMProductName nvarchar(500)

Set @i = 1
Truncate Table #tmpRecId
Insert Into #tmpRecId
Select REC_ParamFocusID From tbl_mERP_Recd_PMParamFocus  Where  REC_ParamID = @REC_ParamID

Select @Counter = Count(ID) From #tmpRecId
While @i <= @counter
Begin
Select @Prod_Code = N'' , @Prod_Level = 0
Select @Prod_Code = CPM_Product_Code , @Prod_Level = CPM_Product_Level,@PMProductName = PMProductName From tbl_mERP_Recd_PMParamFocus
Where  REC_ParamID = @REC_ParamID And REC_ParamFocusID = (Select RecId From #tmpRecId Where ID = @i)

If (@Prod_Level <> 'Division' And @Prod_Level <> 'Subcategory' And @Prod_Level <> 'MarketSKU' And @Prod_Level <> 'SKU')
Begin
Set @Errmessage = 'Invalid Parameter Focus Detail.Product Level should be either Division or Subcategory or MarketSKU or SKU' + Cast(@CPM_isFocusID as nvarchar(10))
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

If (Isnull(@PMProductName,'') = N'')
Begin
Set @Errmessage = 'Invalid Parameter Focus Detail.PMProductName Shoule Not Blank' + Cast(@CPM_isFocusID as nvarchar(10))
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

Set @i = @i + 1
End /* End of While */
End/*End of isFocus param */

Insert Into tbl_mERP_PMParamFocus(REC_ParamFocusID,ParamID,ProdCat_Level,ProdCat_Code,PMProductName,Min_Qty,UOM,TargetThreshold)
Select  REC_ParamFocusID,@ParamID,
(Case @CPM_isFocusID When 1 Then
(Case CPM_Product_Level
When N'Division' Then 2
When N'Subcategory' Then 3
When N'MarketSKU' Then 4
When N'SKU'  Then 5 End) When 0 Then 0 End),
(Case @CPM_isFocusID When 1 Then  CPM_Product_Code When 0 Then 'All' End),PMProductName,Min_Qty,UOM,TargetThreshold
From tbl_mERP_Recd_PMParamFocus Where REC_ParamID = @REC_ParamID


Truncate Table #tmpRecId

/* Validation for Slab Begin */
Set @i = 1
Insert Into #tmpRecId
Select REC_ParamSlabID From tbl_mERP_Recd_PMParamSlab  Where  REC_ParamID = @REC_ParamID

Declare @Slab_UOM nVarchar(50)
Declare @Slab_Start Decimal(18,6)
Declare @Slab_End Decimal(18,6)
Declare @Slab_Every_Qty Decimal(18,6)
Declare @Slab_Given_As nVarchar(50)
Declare @Slab_Value Decimal(18,6)

Set @Counter = 0
Select @Counter = Count(ID) From #tmpRecId
While @i <= @counter
Begin
Select @Slab_UOM = N'',@Slab_Start = 0 , @Slab_End = 0 ,
@Slab_Every_Qty = 0,@Slab_Given_As = N'' ,@Slab_Value = 0

Select @Slab_UOM = isNull(SLAB_UOM,'') ,@Slab_Start = isNull(SLAB_START,0) , @Slab_End = isNull(SLAB_END,0) ,
@Slab_Every_Qty = isNull(SLAB_EVERY_QTY,0) ,@Slab_Given_As = isNull(SLAB_GIVEN_AS,'') ,@Slab_Value = isNull(SLAB_VALUE,0)
From tbl_mERP_Recd_PMParamSlab Where REC_ParamSlabID = (Select RecId From #tmpRecId Where ID = @i)

--				If (@Slab_UOM <> N'Points' And @Slab_UOM <>'Percentage')
--				Begin
--					Set @Errmessage = 'Invalid Slab Detail.Slab UOM should be either Points or Percentage'
--					Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
--					Set @FlagCursor = 2
--					Goto skip
--				End

If (@Slab_Given_As <> N'Points' And @Slab_Given_As <>'Percentage')
Begin
Set @Errmessage = 'Invalid Slab Detail.Slab Geiven As should be either Points or Percentage'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

If (@Slab_Start < 0)
Begin
Set @Errmessage = 'Invalid Slab Detail.Slab Start should not be less than 0'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End
If (@Slab_End < 0)
Begin
Set @Errmessage = 'Invalid Slab Detail.Slab End should not be less than 0'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End
If (@Slab_Every_Qty < 0)
Begin
Set @Errmessage = 'Invalid Slab Detail.Slab Every Quantity should not be less than 0'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End
If (@Slab_Value < 0)
Begin
Set @Errmessage = 'Invalid Slab Detail.Slab Value should not be less than 0'
Set @KeyValue = 'Received PMID : DSType - ' + Cast(@CPM_PMID as nVarchar(10)) + ' : ' + Cast(@CMP_DSType as nVarchar(10))
Set @FlagCursor = 2
Goto skip
End

Set @i = @i + 1
End

Insert Into tbl_mERP_PMParamSlab(REC_ParamSlabID,ParamID,SLAB_UOM,SLAB_START,SLAB_END,SLAB_EVERY_QTY,
SLAB_GIVEN_AS,SLAB_VALUE,AbsoluteTarget)
Select REC_ParamSlabID,@ParamID,Slab_UOM,
Slab_Start,Slab_End,Slab_Every_Qty,(Case Slab_Given_As When N'Points' Then 1 When N'Percentage' Then 2 Else 0 End),
Slab_Value, AbsoluteTarget From tbl_mERP_Recd_PMParamSlab
Where REC_ParamID = @REC_ParamID

/* Validation for Slab End */


Set @REC_ParamID = 0
Set @CPM_DSID = 0
Set @CPM_Frequency = N''
Set @CPM_ParamMaxPoints = 0
Set @CPM_ParameterType = N''
Set @CPM_isFocusParameter = N''
Set @GrowthPercentage=0

Fetch Next From  Cur_Param Into @REC_ParamID,@CPM_DSID,@CPM_Frequency,@CPM_ParamMaxPoints,@CPM_ParameterType,@CPM_isFocusParameter,@GrowthPercentage,@CMP_ParamID,@Cutoff_Percentage,@CPM_DependentParamID,@DependentCutoff,@TargetType,@ComparisonType
End
Close Cur_Param
Deallocate Cur_Param

Set @REC_DSID = 0
Set @CMP_DSType = N''
Set @CPM_Groups = N''
Set @CPM_MaxPoints = 0
Fetch Next From Cur_DSType Into @REC_DSID , @CMP_DSType,@CPM_MaxPoints,@CMP_DSTypeID
End
Close Cur_DSType
Deallocate Cur_DSType
/* DS Ends */

Skip:
Drop Table #tmpRecId
If @FlagCursor = 1
Begin
Close Cur_DSType
Deallocate Cur_DSType
End
Else If @FlagCursor = 2
Begin
Close Cur_Param
Deallocate Cur_Param
Close Cur_DSType
Deallocate Cur_DSType
End

If isNull(@Errmessage,'') = N'Drop'
Begin
Update tbl_mERP_Recd_PMMaster Set Status =  32 Where  REC_PMID = @REC_PMID
Select 999999999,''
End
Else If isNull(@Errmessage,'') <> ''
Begin
Update tbl_mERP_Recd_PMMaster Set Status = Status | 64 Where  REC_PMID = @REC_PMID
Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)
Values('ITCPM', @Errmessage,  @KeyValue, @ProcessDate)
Select -1,@Errmessage
End
Else
Begin
Update tbl_mERP_Recd_PMMaster Set Status =  32 Where  REC_PMID = @REC_PMID
Select isNull(@PMID,0),''
End

/*For Re-process PMOutlet */
Exec mERP_sp_ProcessOLTPM 0,1

End
