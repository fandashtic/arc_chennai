Create Procedure mERP_SP_ChkCustomerQuotChannel(@CustlID as nvarchar(200))   
As Declare @Delimeter as char(1)   
Begin   
If (@CustlID <> '')  
Begin 
Declare @flag as int
Declare @tblFlag as int


	Select @flag = IsNull(Flag,0) from tbl_merp_ConfigAbstract where screenCode = 'QCC01'

	If Exists (select * from dbo.sysobjects where Xtype = 'U' and Name = 'tbl_merp_OLClass')
		If Exists (select * from dbo.sysobjects where Xtype = 'U' and Name = 'tbl_merp_OLClassMapping')
			Set @tblFlag = 1
		Else
			Set @tblFlag = 0
	Else
		Set @tblFlag = 0
 

	If @Flag = 1 And @tblFlag = 1
	Begin
		If Exists (Select * from tbl_merp_OLClassMapping where CustomerID = @CustlID )   
			If Exists (  
				Select * from tbl_mERP_QuotChannelDetail RC, tbl_merp_OLClass OL  
				where RC.Active = 1  
				And OL.ID = (Select Max(OLClassID) from tbl_merp_OLClassMapping where CustomerID = @CustlID and Active = 1)  
				And (RC.Channel_Type_Code = OL.Channel_Type_Code  Or RC.Channel_Type_Code = N'All')
				And (RC.Outlet_Type_Code = OL.Outlet_Type_Code Or RC.Outlet_Type_Code = N'All')
				And OL.Channel_Type_Active = 1
                And OL.Outlet_Type_Active = 1)
				Select 1
			Else
				Select 0
		Else  
			Select 0 
	End
	Else
    Begin
		If Exists (Select * from Customer C, Customer_Channel CC, tbl_mERP_QuotChannelDetail RC 
						where C.CustomerID = @CustlID
						And C.ChannelType = CC.ChannelType  
						And (CC.ChannelDesc = RC.Channel_Type_Desc Or RC.Channel_Type_Desc = N'All')
						And C.Active = 1
						And RC.Active = 1)   
			Select 1
		Else  
			Select 0 
	End
End  
End  
