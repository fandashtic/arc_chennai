Create Procedure mERP_sp_Find_RebateID
(
 @Invoicedate as DATETIME,                              
 @OutletID as nvarchar(30)=N'',                            
 @CreationDate as nVarchar(50) = N''
)  
As
Begin
	Set Dateformat dmy
--	Declare @CustChannel As nVarchar(255)
--	Declare @TMDField4  As nVarchar(255)
	Declare @RebateIDS nVarchar(2000)
	Declare @RebateID As Int


	Declare @OlMapId int
	Declare @OlChannel nVarchar(255)
	Declare @OlOutlettype nVarchar(255)
	Declare @OlLoyalty nVarchar(255)
	Declare @CDate Datetime
	Set @CDate = Cast(@CreationDate as Datetime)
	
	
	Create Table #tmpScheme(SchemeID Int,GroupID Int)

	/* Below changes are done to avoid stripdatefromtime function to improve performance*/
	If @CDate='01 jan 1900'
		Select @CDate = GetDate()
	
	--Set @CreationDate = Cast(@CreationDate as Datetime)
			
												 
	/* Begin: Commented Old Scheme functionality of customerchannel  as New functionality based on OLClass Mapping Implemented */	
	--	Select 
	--			@CustChannel = isNull(ChannelDesc,'') , 
	--			@TMDField4 = (Select isNull(TMDMas.TMDValue,'') From  Cust_TMD_Master TMDMas ,Cust_TMD_Details TMDDet 
	--						 Where TMDMas.TMDCtlPos = 6 And TMDMas.TMDID = TMDDet.TMDID And TMDDet.CustomerID = C.CustomerID)
	--    From 
	--			Customer  C,Customer_Channel CH
	--	Where 
	--			C.CustomerID = @OutletID And
	--			CH.ChannelType = C.ChannelType 
	/* End: Commented Old Scheme functionality of customerchannel as New functionality based on OLClass Mapping Implemented */			


	/* Begin: New functionality Implemented based on OLClass Mapping */

	Select @OlMapId = isNull(OLClassID,0) from  tbl_Merp_OlclassMapping where CustomerID = @OutletID and Active =1

	Select
		 @OlChannel = isNull(Channel_Type_desc,''), 
		 @OlOutlettype = isNull(Outlet_Type_desc,''),
		 @OlLoyalty = isNull(SubOutlet_Type_desc,'')
	From 
		tbl_merp_Olclass 
	where 
		ID = @OlMapId

	/* End: New functionality Implemented based on OLClass Mapping */


	Insert Into #tmpScheme
	Select Distinct S.SchemeID,Min(SO.GroupID)
	From 
		tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,
		tbl_mERP_SchemeOutletClass  SOLC , tbl_mERP_SchemeLoyaltyList SLList
	Where
		S.SchemeType in (5) and 
		(Cast((Convert(Nvarchar(10),@invoicedate,103)) as DateTime) Between ActiveFrom And ActiveTo) And
		(Cast((Convert(Nvarchar(10),@CDate,103)) as DateTime) Between ActiveFrom And ExpiryDate) And
		Active = 1 And
		S.ApplicableOn = 1 And --1  means ItemBased Scheme
		S.ItemGroup = 1 And
		SO.QPS = 0 And  ---0 - Direct Scheme
		S.SchemeID = SC.SchemeID And
		SC.GroupID = SO.GroupID And
		S.SchemeID = SO.SchemeID And
--		(SC.Channel = @CustChannel Or SC.Channel = N'All')  And 
		S.SchemeID = SOLC.SchemeID And
		SOLC.GroupID = SO.GroupID And
--		(SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All') 
		S.SchemeID = SLList.SchemeID And
		SLList.GroupID = SO.GroupID And
		(SC.Channel = @OlChannel Or SC.Channel = N'All')  And 
		(SOLC.OutLetClass = @OlOutlettype Or SOLC.OutLetClass = N'All')  And
		(SO.OutletID = @OutletID Or SO.OutletID = N'All')  And
		(SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')
	Group By S.SchemeID



	Set @RebateIDS = ''
	If (Select Count(*) From #tmpScheme)= 0 
		Set @RebateIDS = '-1'
	Else
	Begin
--		Declare CurSchemeID Cursor For
--		Select Distinct SchemeID From #tmpScheme Order By SchemeID
--		Open CurSchemeID
--		Fetch From CurSchemeID Into @RebateID
--		While @@Fetch_Status = 0
--		Begin
--			If ltrim(rtrim(@RebateIDS)) = ''
--				Set @RebateIDS = Cast(@RebateID as nVarchar)
--			Else
--				Set @RebateIDS = Cast(@RebateIDS as nVarchar(2000)) + ',' + Cast(@RebateID as nVarchar(100))
--			
--			Fetch Next From CurSchemeID Into @RebateID	
--		End
--		Close CurSchemeID
--		Deallocate CurSchemeID
		Select @RebateIDS = Cast(@RebateIDS as nVarchar(2000)) + ',' + Cast(SchemeID as nVarchar(1000)) From #tmpScheme
		Select @RebateIDS = Substring(@RebateIDS,2,Len(@RebateIDS))
	End
		
	Select @RebateIDS


	Drop Table #tmpScheme
End
