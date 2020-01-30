
CREATE Function mERP_fn_CheckSchemeOutlet(@SchemeID Int, @OutletCode nVarchar(255))
Returns @SchInfo Table(QPS Int, GroupID Int)
As
Begin

	Declare @CustChannel nVarchar(255)
	Declare @TMDField4 nVarchar(255)

	Declare @QPS Int
	Declare @OlMapId int
	Declare @OlChannel nVarchar(255)
	Declare @OlOutlettype nVarchar(255)
	Declare @OlLoyalty nVarchar(255)
	

	Select @CustChannel = isNull(ChannelDesc,'') , @TMDField4 = (Select isNull(TMDMas.TMDValue,'') 
	From  Cust_TMD_Master TMDMas ,Cust_TMD_Details TMDDet
	Where TMDMas.TMDCtlPos = 6 And TMDMas.TMDID = TMDDet.TMDID And TMDDet.CustomerID = C.CustomerID)
	From Customer  C,Customer_Channel CH
	Where C.CustomerID = @OutletCode 
	And CH.ChannelType = C.ChannelType

/* Begin: New functionality Implemented based on OLClass Mapping */
	Select @OlMapId = OLClassID from  tbl_Merp_OlclassMapping where CustomerID = @OutletCode and Active =1
	Select @OlChannel = Channel_TYpe_desc, @OlOutlettype = Outlet_Type_desc, @OlLoyalty= SubOutlet_Type_desc
	From tbl_merp_Olclass where ID = @OlMapId
/* End: New functionality Implemented based on OLClass Mapping */

If ((Select Count(*) From tbl_mERP_SchemeLoyaltyList Where SchemeID = @SchemeID) > 0)
Begin
	If Exists (Select Distinct S.SchemeID
		From tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,
		tbl_mERP_SchemeOutletClass  SOLC, tbl_mERP_SchemeLoyaltyList SLList
		Where S.SchemeID = @SchemeID
		And S.SchemeID = SO.SchemeID 
		And (SO.OutletID = @OutletCode Or SO.OutletID = N'All')  
		And SO.QPS = 0 
		And S.SchemeID = SC.SchemeID 
		And SC.GroupID = SO.GroupID 
--		And (SC.Channel = @CustChannel Or SC.Channel = N'All')  
		And (SC.Channel = @OlChannel Or SC.Channel = N'All')
		And S.SchemeID = SOLC.SchemeID 
		And SOLC.GroupID = SO.GroupID 
--		And (SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All')
		And (SOLC.OutLetClass = @OlOutlettype Or SOLC.OutLetClass = N'All')
		And S.SchemeID = SLList.SchemeID
		And SLList.GroupID = SO.GroupID
		And (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')
		Group By S.SchemeID)



		Insert Into @SchInfo Select 0, SO.GroupID
				From tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,
				tbl_mERP_SchemeOutletClass  SOLC, tbl_mERP_SchemeLoyaltyList SLList
				Where S.SchemeID = @SchemeID
				And S.SchemeID = SO.SchemeID 
				And (SO.OutletID = @OutletCode Or SO.OutletID = N'All')  
				And SO.QPS = 0 
				And S.SchemeID = SC.SchemeID 
				And SC.GroupID = SO.GroupID 
--				And (SC.Channel = @CustChannel Or SC.Channel = N'All')  
				And (SC.Channel = @OlChannel Or SC.Channel = N'All')
				And S.SchemeID = SOLC.SchemeID 
				And SOLC.GroupID = SO.GroupID 
--				And (SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All')
				And (SOLC.OutLetClass = @OlOutlettype Or SOLC.OutLetClass = N'All')
				And S.SchemeID = SLList.SchemeID
				And SLList.GroupID = SO.GroupID
				And (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')
				

	Else If Exists (Select Distinct S.SchemeID
		From tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,
		tbl_mERP_SchemeOutletClass  SOLC, tbl_mERP_SchemeLoyaltyList SLList
		Where S.SchemeID = @SchemeID
		And S.SchemeID = SO.SchemeID 
		And (SO.OutletID = @OutletCode Or SO.OutletID = N'All')  
		And SO.QPS = 1
		And S.SchemeID = SC.SchemeID 
		And SC.GroupID = SO.GroupID 
--		And (SC.Channel = @CustChannel Or SC.Channel = N'All')  
		And (SC.Channel = @OlChannel Or SC.Channel = N'All')
		And S.SchemeID = SOLC.SchemeID 
		And SOLC.GroupID = SO.GroupID 
--		And (SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All')
		And (SOLC.OutLetClass = @OlOutlettype Or SOLC.OutLetClass = N'All')
		And S.SchemeID = SLList.SchemeID
		And SLList.GroupID = SO.GroupID
		And (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')
		Group By S.SchemeID)

		Insert Into @SchInfo Select 1, SO.GroupID
				From tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,
				tbl_mERP_SchemeOutletClass  SOLC, tbl_mERP_SchemeLoyaltyList SLList
				Where S.SchemeID = @SchemeID
				And S.SchemeID = SO.SchemeID 
				And (SO.OutletID = @OutletCode Or SO.OutletID = N'All')  
				And SO.QPS = 1
				And S.SchemeID = SC.SchemeID 
				And SC.GroupID = SO.GroupID 
--				And (SC.Channel = @CustChannel Or SC.Channel = N'All')  
				And (SC.Channel = @OlChannel Or SC.Channel = N'All')
				And S.SchemeID = SOLC.SchemeID 
				And SOLC.GroupID = SO.GroupID 
--				And (SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All')
				And (SOLC.OutLetClass = @OlOutlettype Or SOLC.OutLetClass = N'All')
				And S.SchemeID = SLList.SchemeID
				And SLList.GroupID = SO.GroupID
				And (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')

	Else
		Insert Into @SchInfo Select 2, 0
End
Else
Begin
	If Exists (Select Distinct S.SchemeID
		From tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,
		tbl_mERP_SchemeOutletClass  SOLC
		Where S.SchemeID = @SchemeID
		And S.SchemeID = SO.SchemeID 
		And (SO.OutletID = @OutletCode Or SO.OutletID = N'All')  
		And SO.QPS = 0 
		And S.SchemeID = SC.SchemeID 
		And SC.GroupID = SO.GroupID 
		And (SC.Channel = @CustChannel Or SC.Channel = N'All')  
		And S.SchemeID = SOLC.SchemeID 
		And SOLC.GroupID = SO.GroupID 
		And (SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All')
		Group By S.SchemeID)



		Insert Into @SchInfo Select 0, SO.GroupID
				From tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,
				tbl_mERP_SchemeOutletClass  SOLC
				Where S.SchemeID = @SchemeID
				And S.SchemeID = SO.SchemeID 
				And (SO.OutletID = @OutletCode Or SO.OutletID = N'All')  
				And SO.QPS = 0 
				And S.SchemeID = SC.SchemeID 
				And SC.GroupID = SO.GroupID 
				And (SC.Channel = @CustChannel Or SC.Channel = N'All')  
				And S.SchemeID = SOLC.SchemeID 
				And SOLC.GroupID = SO.GroupID 
				And (SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All')
			

	Else If Exists (Select Distinct S.SchemeID
		From tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,
		tbl_mERP_SchemeOutletClass  SOLC
		Where S.SchemeID = @SchemeID
		And S.SchemeID = SO.SchemeID 
		And (SO.OutletID = @OutletCode Or SO.OutletID = N'All')  
		And SO.QPS = 1
		And S.SchemeID = SC.SchemeID 
		And SC.GroupID = SO.GroupID 
		And (SC.Channel = @CustChannel Or SC.Channel = N'All')  
		And S.SchemeID = SOLC.SchemeID 
		And SOLC.GroupID = SO.GroupID 
		And (SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All')
		Group By S.SchemeID)

		Insert Into @SchInfo Select 1, SO.GroupID
				From tbl_mERP_SchemeAbstract S ,tbl_mERP_SchemeOutlet SO ,tbl_mERP_SchemeChannel SC ,
				tbl_mERP_SchemeOutletClass  SOLC, tbl_mERP_SchemeLoyaltyList SLList
				Where S.SchemeID = @SchemeID
				And S.SchemeID = SO.SchemeID 
				And (SO.OutletID = @OutletCode Or SO.OutletID = N'All')  
				And SO.QPS = 1
				And S.SchemeID = SC.SchemeID 
				And SC.GroupID = SO.GroupID 
				And (SC.Channel = @CustChannel Or SC.Channel = N'All')  
				And S.SchemeID = SOLC.SchemeID 
				And SOLC.GroupID = SO.GroupID 
				And (SOLC.OutLetClass = @TMDField4 Or SOLC.OutLetClass = N'All')
				And S.SchemeID = SLList.SchemeID
				And SLList.GroupID = SO.GroupID
				And (SLList.LoyaltyName = @OlLoyalty Or SLList.LoyaltyName = N'All')

	Else
		Insert Into @SchInfo Select 2, 0

End

	Return 
End

