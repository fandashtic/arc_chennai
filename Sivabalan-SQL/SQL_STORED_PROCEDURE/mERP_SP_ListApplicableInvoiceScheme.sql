Create Procedure mERP_SP_ListApplicableInvoiceScheme
(
@OutletID nVarchar(255),
@InvoiceAmt Decimal(18,6),
@InvoiceDate DateTime,
@SKUCount Int)
As
Begin

	Declare @OLClass nVarchar(255)
	Declare @Channel nVarchar(255)
	Declare @SchemeID Int
	Declare @SchemeDesc nVarchar(255)
	Declare @GroupID Int

	Select @Channel = ChannelDesc From Customer_Channel CC, Customer C
		 Where C.CustomerID = @OutletID
		 And CC.ChannelType = C.ChannelType

	Select @OLClass = CM.TMDValue From Cust_TMD_Master CM, Cust_TMD_Details CD 
			Where CM.TMDID = CD.TMDID
			And CD.CustomerID = @OutletID
			And CM.TMDCtlPos = 6

	Create Table #tmpScheme(SchemeID Int, Description nVarchar(255), GroupID Int)

	Insert Into #tmpScheme Select SA.SchemeID, SA.Description, Min(SO.GroupID)
	From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeOutlet 
	SO,
	tbl_mERP_SchemeChannel SC, tbl_mERP_SchemeOutletClass SOC
	Where SA.Active  = 1
	And SA.ApplicableOn = 2
	And SA.SKUCount <= @SKUCount
	And dbo.StripTimeFromDate(@InvoiceDate) Between dbo.StripTimeFromDate(SA.ActiveFrom) And dbo.StripTimeFromDate(SA.ActiveTo)
	And SA.SchemeID = SO.SchemeID
	And SO.QPS = 0 --Direct Scheme
	And (SO.OutletID = @OutletID Or SO.OutletID = N'ALL')
	And SO.SchemeID = SC.SchemeID
	And SO.GroupID = SC.GroupID
	And (SC.Channel = @Channel Or SC.Channel = N'ALL')
	And SO.SchemeID = SOC.SchemeID
	And SO.GroupID = SOC.GroupID
	And (SOC.OutletClass = @OLClass Or SOC.OutletClass = N'ALL')
	Group By SA.SchemeID, SA.Description

	Select SABS.SchemeID,CS_RecSchID,ActivityCode,SABS.Description,--case when SchemeType=1 then 'SP' when SchemeType=2 then 'CP' else '' end,
	--case when ApplicableOn=1 Then 'Line' when ApplicableOn=2 then 'Invoice' else '' end,
	ActiveFrom,ActiveTo,GroupID
	From tbl_mERP_schemeAbstract SABS,#tmpScheme T
	Where SABS.SchemeID in (select distinct SchemeID from #tmpScheme) And
	SABS.SchemeID = T.SchemeID 


End
