CREATE PROCEDURE sp_cancel_MultipleGRN_bill(@BILL int, @Remarks nvarchar(100)= N'', @UserName nvarchar(20)= N'', @CancelDate datetime = Null)    
AS    
DECLARE @Status int    
DECLARE @GRNID nvarchar(255)    
Declare @PaymentID Int    
Declare @ItemCode as nvarchar(50)  
Declare @Batch_Code as Int
Declare @BillDate as DateTime
Declare @LOCALITY Int
Declare @IS_VAT_ITEM Int

IF NOT EXISTS (Select BillID From BillAbstract Where BillID = @BILL)    
BEGIN    
	SELECT 0    
	GOTO THEEND    
END    

SELECT @Status = Status, @GRNID = GRNID, @PaymentID = PaymentID     
From BillAbstract Where BillID = @BILL    

Create table #Temp (grnid int)                
Insert Into #Temp Select * from dbo.sp_SplitIn2Rows(@GRNID,',')
--Exec ('Insert Into #Temp Select GRNID FROm GrnAbstract Where GRNID in (' + @GRNID + ')')      

IF @Status = 0    
Begin
	--Get the Old Bill batches taxamount and deduct it in openingdetails
	Select @Locality=IsNull(Locality,0) from Vendors Where VendorID in (Select VendorId from BillAbstract Where BillID=@Bill)
	Select Top 1 @BillDate=BillDate From BillAbstract Where GRNID = @GRNID Order By BillId
	DECLARE GetOldBillBatches CURSOR KEYSET FOR  
	Select Product_Code, Batch_Code From Batch_Products Where GRN_ID in (Select GRNID from #Temp) And Quantity>0 
	Open GetOldBillBatches  
	Fetch From GetOldBillBatches Into @ItemCode, @Batch_Code   
	While @@Fetch_Status = 0  
	Begin
		--Updating TaxSuff Percentage in OpeningDetails
		Select @IS_VAT_ITEM = IsNull(Vat,0) from Items Where Product_Code=@ItemCode
		If Exists (Select * From SysColumns Where Name = N'PTS' And ID = (Select ID From Sysobjects Where Name = N'Items'))  
			If @LOCALITY = 2 AND @IS_VAT_ITEM = 1
				Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @ItemCode, @Batch_Code, 1, 1, 1
			Else
				Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @ItemCode, @Batch_Code, 1, 0, 1
		Else
			If @LOCALITY = 2 AND @IS_VAT_ITEM = 1
				Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @BillDate, @ItemCode, @Batch_Code, 1, 1, 1
			Else
				Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @BillDate, @ItemCode, @Batch_Code, 1, 0, 1	

		--Here we are coping the GRN Tax details into Batch Tax Details
		Update Batch_Products Set TaxSuffered = GRNTaxsuffered, ApplicableOn = GRNApplicableOn, PartOfPercentage = GRNPartOff Where Batch_Code=@Batch_Code

		If Exists (Select * From SysColumns Where Name = N'PTS' And ID = (Select ID From Sysobjects Where Name = N'Items'))  
			If @LOCALITY = 2 AND @IS_VAT_ITEM = 1
				Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @ItemCode, @Batch_Code, 0, 1, 1
			Else
				Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @ItemCode, @Batch_Code, 0, 0, 1
		Else
			If @LOCALITY = 2 AND @IS_VAT_ITEM = 1
				Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @BillDate, @ItemCode, @Batch_Code, 0, 1, 1
			Else
				Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @BillDate, @ItemCode, @Batch_Code, 0, 0, 1	

		Fetch Next From GetOldBillBatches Into @ItemCode, @Batch_Code
	End
	Close GetOldBillBatches
	Deallocate GetOldBillBatches

	If @PaymentID Is Not Null   
	Begin  
		Exec dbo.sp_Cancel_Payment @PaymentID    
		Exec dbo.sp_ChangeStatus_AdjRef_BillCancel @Bill  
	End  

	Update BillAbstract Set Status = Status | 192, Balance = 0,Remarks = @Remarks,CancelUserName = @UserName,CancelDate = @CancelDate Where BillID = @BILL    
	Update GRNAbstract Set GRNStatus = GRNStatus & (~128) Where GRNID in (select grnid from #Temp)    
--	Update GRNAbstract Set GRNStatus = GRNStatus & (~128), BillID = Null, NewBillID = Null Where GRNID in (select grnid from #Temp)    
	drop table #temp           
	SELECT 1    
END    
ELSE    
BEGIN  
   drop table #temp           
   SELECT 0    
END  

THEEND:   
  




