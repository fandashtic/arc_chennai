Create Procedure mERP_sp_isOLClassMapped(
@CustID nVarchar(500),
@Channel nVarchar(255),@Outlet nVarchar(255),
@Loyalty nVarchar(255)
)
As
Begin
	Declare @Mappedchannel as nVarchar(255)
	Declare @MappedOutlet as nVarchar(255)
	Declare @MappedLoyalty as nVarchar(255)


	Select @Mappedchannel = Channel_Type_Desc,@MappedOutlet = Outlet_Type_Desc,
	@MappedLoyalty = SubOutlet_Type_Desc
	From tbl_mERP_OLClassMapping OCMap, Customer CM, tbl_mERP_OLClass OCMas
	Where 
	CM.CustomerID = @CustID And
	CM.CustomerCategory = 2  And
	CM.CustomerID = OCMap.CustomerID And   
	OCMas.ID = OCMap.OLClassID  And
	OCMap.Active = 1    

	

	iF isNull(@Mappedchannel,'') = '' And isNull(@MappedOutlet,'') = '' And isNull(@MappedLoyalty,'') = ''
		Select 1,'','',''
	Else
	Begin
		If @Mappedchannel <> @Channel Or @MappedOutlet <> @Outlet Or @MappedLoyalty <> @Loyalty
			Select 0,@Mappedchannel,@MappedOutlet,@MappedLoyalty
		Else  If @Mappedchannel = @Channel And @MappedOutlet = @Outlet  And @MappedLoyalty = @Loyalty
			Select 1,'','',''
	End 
	


End

