CREATE PROCEDURE [sp_update_CustomerPoints]        
 (@InvoiceID int,@Type int)        
AS        
begin   

	declare @DefinitionType int        
	declare @CustomerID nvarchar(15)        
	declare @Points decimal(18,6)        
	declare @InvType int        
	declare @OldPoints decimal(18,6)        
	declare @TrackPoints int        
	declare @DocSerial int        
	Declare @IsAllCustomer int  

	select @CustomerID=customerID,@InvType=InvoiceType from InvoiceAbstract where InvoiceID=@InvoiceID        
  
	if @CustomerID='0'         
		goto NoCust        
--	exec mERP_sp_Handle_OutletPoints @InvoiceID
	select @TrackPoints=isnull(TrackPoints,0) from customer where CustomerID=@CustomerID        

	if @TrackPoints=0         
		goto NoCust        


	--The Latest Active Definition Specific to a customer will be chosen    
	select @DocSerial=IsNull(max(PA.DocSerial),0) from PointsCustomer PC,PointsAbstract  PA    
	where (CustomerID=@CustomerID or PA.Customer=0) And PC.Docserial=PA.DocSerial And PA.Active=1    

	If @DocSerial = 0 Or @DocSerial < (Select Max(PointsAbstract.DocSerial) From PointsAbstract Where Customer =  0 And Active = 1)
	--The Latest Active Definition for AllCustomers will be chosen     	
		Select @DocSerial = Max(PointsAbstract.DocSerial) From PointsAbstract Where Customer =  0 And Active = 1	   

	if @Type=0  --Insertion        
	begin        
		--select @DefinitionType=DefinitionType from PointsAbstract where Active=1    
		select @DefinitionType=DefinitionType from PointsAbstract where  DocSerial=@DocSerial And Active=1          
		select @Points=dbo.fn_GetPoints(@DefinitionType,@InvoiceID,@DocSerial)     
		update invoiceAbstract set CustomerPoints=@Points where InvoiceID=@InvoiceID        
		if @InvType=1 or @InvType=2         
		Begin      
			if @InvType = 2       
			Begin      
				if Exists(select CustomerPoints from InvoiceAbstract where InvoiceID=(select InvoiceReference from invoiceabstract where InvoiceID=@InvoiceID))      
				Begin      
					select @OldPoints= CustomerPoints from InvoiceAbstract where InvoiceID=(select InvoiceReference from invoiceabstract where InvoiceID=@InvoiceID)        
					 Update customer set CollectedPoints=isnull(CollectedPoints,0) - @OldPoints where CustomerID= @CustomerID        
				End      
			End      
			Update customer set CollectedPoints=isnull(CollectedPoints,0) + @Points where CustomerID= @CustomerID        
		End      

		if @InvType=3         
		begin        
			select @OldPoints= CustomerPoints from InvoiceAbstract where InvoiceID=(select InvoiceReference from invoiceabstract where InvoiceID=@InvoiceID)        
			Update customer set CollectedPoints=isnull(CollectedPoints,0) - @OldPoints where CustomerID= @CustomerID        
			Update customer set CollectedPoints=isnull(CollectedPoints,0) + @Points where CustomerID= @CustomerID        
		end        
	if @InvType=4 or @InvType=5 or @InvType=6        
	Update customer set CollectedPoints=isnull(CollectedPoints,0) - @Points where CustomerID= @CustomerID        
	end        
	else if @Type=1 --Cancel        
	begin        
		select @OldPoints= CustomerPoints from InvoiceAbstract where InvoiceID=@InvoiceID        
		Update customer set CollectedPoints=isnull(CollectedPoints,0) - @OldPoints where CustomerID= @CustomerID         
	end        
NoCust:        
end        








