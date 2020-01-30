CREATE Procedure mERP_sp_Update_RCSValues
(
@CustID nVarChar(15),
@RCSHead nVarchar(50),
@RCSValue nVarChar(50),
@RCSPos Integer =0
)
AS
Begin
Declare @TMDID Integer
Declare @MerchandiseID Integer

Declare @TMDIDValuePosOne Integer
Declare @TMDIDValuePosOne1 Integer
Declare @TMDIDValuePosOne2 Integer
Declare @TMDIDValuePostwo Integer

If @CustID <> '' and (@RCSHead <> '' or @RCSPos <> 0) 
Begin

 If @RCSPos = 0
 Begin
	If @RCSHead = 'RCSOutletID'
		Set @RCSPos = 1
	Else If @RCSHead = 'Merchandise'
		Set @RCSPos = 2
	Else
		Select @RCSPos = Min(TMDCtlPos) From Cust_TMD_Master where TMDName = @RCSHead
 End

 If @RCSHead = '' and @RCSPos > 2
 Begin
	Select @RCSHead = IsNull(Min(TMDName),'') from Cust_TMD_Master where TMDCtlPos = @RCSPos
 End

 If @RCSHead = ''
 Begin
	If @RCSPos = 3
		Set @RCSHead = 'Active in RCS'
	If @RCSPos = 4
		Set @RCSHead = 'Field2'
	If @RCSPos = 5
		Set @RCSHead = 'Field3'
	If @RCSPos = 6
		Set @RCSHead = 'Field4'
	If @RCSPos = 7
		Set @RCSHead = 'Field5'
	If @RCSPos = 8
		Set @RCSHead = 'Field6'
	If @RCSPos = 9
		Set @RCSHead = 'Field7'
	If @RCSPos = 10
		Set @RCSHead = 'Field8'
	If @RCSPos = 11
		Set @RCSHead = 'Field9'
	If @RCSPos = 12
		Set @RCSHead = 'Field10'
	If @RCSPos = 13
		Set @RCSHead = 'Field11'
	If @RCSPos = 14
		Set @RCSHead = 'Field12'
	If @RCSPos = 15
		Set @RCSHead = 'Field13'
 End

-- begin New Code
-- Req:  If RCSID Exists then Active in RCS should be Yes. Only When Yes (Case Sensitive) is available in Cust_TMD_MASTER
--       If RCSID Not Exists then Active in RCS should be No. Only When No (Case Sensitive) is available in Cust_TMD_MASTER
If @RCSPos = 1 and IsNull(@RCSValue,'') = ''
 Begin
	Select @TMDIDValuePosOne  = TMDID From Cust_TMD_master Where TMDValue = 'No' and TMDCtlPOs = 3
	If (IsNull(@TMDIDValuePosOne,0)) <> 0
		If Exists (Select CustomerID from Cust_TMD_Details Where CustomerID = @CustID and TMDCtlPos = 3)
			Update Cust_TMD_Details Set TMDID = @TMDIDValuePosOne Where CustomerID = @CustID and TMDCtlPos = 3
		Else	
			Insert Into Cust_TMD_Details Values(@CustID, 3, @TMDIDValuePosOne)  
	Else
		Delete from Cust_TMD_Details Where CustomerID = @CustID and TMDCtlPos = 3
 End
Else If @RCSPos = 1 and IsNull(@RCSValue,'') <> ''
Begin
	Select @TMDIDValuePosOne  = TMDID From Cust_TMD_master Where TMDValue = 'Yes' and TMDCtlPOs = 3
	If (IsNull(@TMDIDValuePosOne,0)) <> 0
		If Exists (Select CustomerID from Cust_TMD_Details Where CustomerID = @CustID and TMDCtlPos = 3)
			Update Cust_TMD_Details Set TMDID = @TMDIDValuePosOne Where CustomerID = @CustID and TMDCtlPos = 3
		Else	
			Insert Into Cust_TMD_Details Values(@CustID, 3, @TMDIDValuePosOne)  
	Else
	
		If Not Exists (Select TMDID From Cust_TMD_master Where TMDValue = 'Yes' and TMDCtlPOs = 3) 
			Insert into Cust_TMD_master(TMDName, TMDValue, TMDCtlPos, Active) 
			Values('Active in RCS', 'Yes', 3, 1)

		If Not Exists (Select TMDID From Cust_TMD_master Where TMDValue = 'No' and TMDCtlPOs = 3) 
	  		Insert into Cust_TMD_master(TMDName, TMDValue, TMDCtlPos, Active) 
		Values('Active in RCS', 'No', 3, 1)

		Select @TMDIDValuePosOne1  = TMDID From Cust_TMD_master Where TMDValue = 'Yes' and TMDCtlPOs = 3
		Select @TMDIDValuePosOne2  = TMDID From Cust_TMD_master Where TMDValue = 'No' and TMDCtlPOs = 3
		If IsNull(@TMDIDValuePosOne1, 0) <> 0 
		begin
			If Not Exists (Select CustomerID from Cust_TMD_Details Where CustomerID = @CustID and TMDCtlPos = 3)
				Insert Into Cust_TMD_Details Values(@CustID, 3, @TMDIDValuePosOne1) 
		End	
			
		If IsNull(@TMDIDValuePosOne2, 0) <> 0 
		Begin
			If Not Exists (Select CustomerID from Cust_TMD_Details Where CustomerID = @CustID and TMDCtlPos = 3)
			Insert Into Cust_TMD_Details Values(@CustID, 3, @TMDIDValuePosOne2) 
		End
End
		
-- End: New Code

-- Update RCSOutlet ID to customer master
 If @RCSPos = 1 
 Begin
	Update Customer Set RCSOutletID = @RCSValue Where CustomerID = @CustID
 End


	-- Insert customer Merchandise detail with exists validation
 If @RCSPos = 2 and @RCSValue <> ''
 Begin
	if Not Exists (Select Merchandise from Merchandise where Merchandise = @RCSValue)
	Begin
		Insert into Merchandise (Merchandise,Active) values (@RCSValue,1)
	End
	Select @MerchandiseID = MerchandiseID from Merchandise where Merchandise = @RCSValue
	if Not Exists (Select MerchandiseID from CustMerchandise 
									where CustomerID = @CustID and MerchandiseID = @MerchandiseID)
	Begin
		Insert into CustMerchandise (CustomerID,MerchandiseID) values (@CustID,@MerchandiseID)
	End
 End

---- Insert and Updation for HandHeldDS

 If @RCSPos = 3 and @RCSValue <> ''  
 Begin  
 If Not Exists (Select TMDValue from Cust_TMD_Master  
         Where TMDName = @RCSHead and TMDValue = @RCSValue and TMDCtlPos = @RCSPos)  
 Begin  
  Insert into Cust_TMD_Master (TMDName,TMDValue,TMDCtlPos,Active)   
         values (@RCSHead,@RCSValue,@RCSPos,1)  
 End  
  
 Select @TMDID = TMDID from Cust_TMD_Master   
 Where TMDName = @RCSHead and TMDValue = @RCSValue and TMDCtlPos = @RCSPos  
   
 If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustID  
    And TMDCtlPos = @RCSPos)  
 Begin  
	Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustID,@RCSPos,@TMDID)  
 End  
 Else  
 Begin  
	Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustID and TMDCtlPos = @RCSPos  
 End  
 End  

 -- Insert and modification for other RCS Valus (8 combobox and 5 textbox)

 If @RCSPos >= 4 and @RCSPos <= 15 and @RCSValue <> ''
 Begin
	If Not Exists (Select TMDValue from Cust_TMD_Master
									Where TMDName = @RCSHead and TMDValue = @RCSValue and TMDCtlPos = @RCSPos)
	Begin
		Insert into Cust_TMD_Master (TMDName,TMDValue,TMDCtlPos,Active) 
												values (@RCSHead,@RCSValue,@RCSPos,1)
	End

	Select @TMDID = TMDID from Cust_TMD_Master 
	Where TMDName = @RCSHead and TMDValue = @RCSValue and TMDCtlPos = @RCSPos
	
	If Not Exists (Select CustomerID from Cust_TMD_Details where CustomerID = @CustID
									And TMDCtlPos = @RCSPos)
	Begin
		Insert Into Cust_TMD_Details (CustomerID,TMDCtlPos,TMDID) values (@CustID,@RCSPos,@TMDID)
	End
	Else
	Begin
		Update Cust_TMD_Details Set TMDID = @TMDID Where CustomerID = @CustID and TMDCtlPos = @RCSPos
	End
 End

 If @RCSPos >= 11 and @RCSPos <= 15 and @RCSValue = ''
 Begin
	Delete from Cust_TMD_Details where  CustomerID = @CustID and TMDCtlPos = @RCSPos
 End

End

End
