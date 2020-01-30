Create Procedure mERP_sp_CSDisplay_IsValidCustomerChannel(@CUSTOMERID nvarchar(50), @CustomerType nVarchar(250))
As
Begin
  Declare @ExistanceCount INT
  SET @ExistanceCount = 0 
  Declare @ConfigVal Int
  Set @ConfigVal = 0 
  Select @ConfigVal = IsNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode Like 'DISP_SCH_OLCLS_BUDGET'
  If @ConfigVal = 0 
    Begin
    Select @ExistanceCount = Count(Cus.CustomerID)
    From Customer Cus, Customer_Channel CusChn
    Where Cus.CustomerCategory Not In (4,5) And 
     Cus.ChannelType = CusChn.ChannelType And
     CusChn.ChannelDesc = @CustomerType And
     Cus.CustomerID = @CUSTOMERID
    End
  Else
    Begin
    Select @ExistanceCount = Count(Cus.CustomerID)
    From Customer Cus, tbl_mERP_OLClass OLC, tbl_mERP_OLClassMapping OLM
    Where Cus.CustomerCategory Not In (4,5) And
     Cus.CustomerID = OLM.CustomerID And 
     OLM.CustomerID = @CUSTOMERID And 
     OLM.OLClassID = OLC.ID	And 
     OLM.Active = 1 And 
     OLC.Outlet_Type_Desc = @CustomerType
    End
   Select @ExistanceCount
End
