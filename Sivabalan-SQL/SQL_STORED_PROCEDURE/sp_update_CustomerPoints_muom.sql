CREATE PROCEDURE [sp_update_CustomerPoints_muom]        
 (@InvoiceID int,@Type int)        
AS        
Begin   

	Declare @DefinitionType int        
	Declare @CustomerID nvarchar(15)        
	Declare @Points decimal(18,6)        
	Declare @InvType int        
	Declare @OldPoints decimal(18,6)        
	Declare @TrackPoints int        
	Declare @DocSerial int        
	Declare @IsAllCustomer int  

	Select @CustomerID=customerID,@InvType=InvoiceType from InvoiceAbstract where InvoiceID=@InvoiceID        
  
	If @CustomerID='0'         
		Goto NoCust        

	Select @TrackPoints=isnull(TrackPoints,0) from customer where CustomerID=@CustomerID        

	If @TrackPoints=0         
		Goto NoCust        

	--The Latest Active Definition Specific to a customer will be chosen    
	Select @DocSerial=IsNull(max(PA.DocSerial),0) from PointsCustomer PC,PointsAbstract  PA    
	Where (CustomerID=@CustomerID or PA.Customer=0) And PC.Docserial=PA.DocSerial And PA.Active=1    

	If @DocSerial = 0 Or @DocSerial < (Select Max(PointsAbstract.DocSerial) From PointsAbstract Where Customer =  0 And Active = 1)
	--The Latest Active Definition for AllCustomers will be chosen     	
		Select @DocSerial = Max(PointsAbstract.DocSerial) From PointsAbstract Where Customer =  0 And Active = 1	   

	If @Type=0  --Insertion        
	Begin        
		--select @DefinitionType=DefinitionType from PointsAbstract where Active=1    
		Select @DefinitionType=DefinitionType from PointsAbstract where  DocSerial=@DocSerial And Active=1          
		Select @Points=dbo.fn_GetPoints_MUOM(@DefinitionType,@InvoiceID,@DocSerial)   	-- Introduced fn_GetPoints_MUOM
		Update invoiceAbstract set CustomerPoints=@Points where InvoiceID=@InvoiceID        
		If @InvType=1 or @InvType=2         
		Begin      
			If @InvType = 2       
			Begin      
				If Exists(select CustomerPoints from InvoiceAbstract where InvoiceID=(select InvoiceReference from invoiceabstract where InvoiceID=@InvoiceID))      
				Begin      
					Select @OldPoints= CustomerPoints from InvoiceAbstract where InvoiceID=(select InvoiceReference from invoiceabstract where InvoiceID=@InvoiceID)        
					Update customer set CollectedPoints=isnull(CollectedPoints,0) - @OldPoints where CustomerID= @CustomerID        
				End      
			End      
			Update customer set CollectedPoints=isnull(CollectedPoints,0) + @Points where CustomerID= @CustomerID        
		End      

		If @InvType=3         
		Begin        
			Select @OldPoints= CustomerPoints from InvoiceAbstract where InvoiceID=(select InvoiceReference from invoiceabstract where InvoiceID=@InvoiceID)        
			Update customer set CollectedPoints=isnull(CollectedPoints,0) - @OldPoints where CustomerID= @CustomerID        
			Update customer set CollectedPoints=isnull(CollectedPoints,0) + @Points where CustomerID= @CustomerID        
		End        
	If @InvType=4 or @InvType=5 or @InvType=6        
	Update customer set CollectedPoints=isnull(CollectedPoints,0) - @Points where CustomerID= @CustomerID        
	End        
	Else if @Type=1 --Cancel        
	Begin        
		Select @OldPoints= CustomerPoints from InvoiceAbstract where InvoiceID=@InvoiceID        
		Update customer set CollectedPoints=isnull(CollectedPoints,0) - @OldPoints where CustomerID= @CustomerID         
	End        
NoCust:        
End        

