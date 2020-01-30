CREATE Procedure sp_ProcessGSTax (@ProcessFlag Int = 0)
As
Begin
--Set Flag value for the blow perpouse
--1 - Inserted
--2 - Already CS_TaxCode Exists
--3 - Already Tax_Description Exists
--64 - Error in data
Set DateFormat DMY
Declare @ErrorID Int
Declare @ErrCompID Int
Declare @TransactionType nVarChar(255)
Declare @ErrMessage nVarChar(4000)
Declare @KeyValue nVarChar(255)
Set @TransactionType = 'Received Tax'
Declare @ExistsTaxID Int
Declare @GSTEnableDate DateTime
Select Top 1  @GSTEnableDate = GSTDateEnabled From Setup

If Exists (Select 'x' From Recd_Tax Where IsNull(Flag,0) = 0 And @ProcessFlag = 1)
Begin

Select *,TaxCSCodeID=0,TaxDescID=0 Into #tmpRecd_Tax From Recd_Tax Where IsNull(Flag,0) = 0
Select *,CompLevel = 0 Into #tmpRecd_TaxComponents From Recd_TaxComponents Where TaxID In (Select ID From #tmpRecd_Tax)

Update A Set A.TaxCSCodeID = T.Tax_Code From #tmpRecd_Tax A Join Tax T On T.CS_TaxCode = A.CS_TaxCode

Update A Set A.TaxDescID = T.Tax_Code From #tmpRecd_Tax A Join Tax T On T.Tax_Description = A.TaxDescription

/*0.Tax EffectiveFromDate is less than GSTax Enable Date Validation*/
/* Error Starts */
Declare Error Cursor For Select  ID From #tmpRecd_Tax Where IsNull(GSTFlag,0) <> 1
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax GSTFlag value is  0. Unable to process.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue, GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*1.Tax EffectiveFromDate is less than GSTax Enable Date Validation*/
/* Error Starts */
Declare Error Cursor For Select  ID From #tmpRecd_Tax Where IsNull(GSTFlag,0) = 1 And EffectiveFromDate < @GSTEnableDate
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax EffectiveFromDate is less than GSTax Enable Date. Unable to process.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue, GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*2.Exists tax CS_Taxcode and Tax_Description mismatch Validation*/
/* Error Starts */
Declare Error Cursor For Select  ID From #tmpRecd_Tax Where IsNull(TaxCSCodeID,0) > 0 And IsNull(TaxDescID,0) > 0 And IsNull(TaxCSCodeID,0) <> IsNull(TaxDescID,0)
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Cs_Code and TaxDescription are already exists for two diffrent taxes. Unable to process.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue, GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*3.Exists tax CS_Taxcode is already used in transactions Validation*/
/* Error Starts */
Declare Error Cursor For Select  ID,TaxCSCodeID From #tmpRecd_Tax Where IsNull(TaxCSCodeID,0) > 0
Open Error
Fetch from Error into @ErrorID, @ExistsTaxID
While @@FETCH_STATUS =0
BEGIN
If EXISTS ( SELECT TOP 1 Tax_Code From InvoiceTaxComponents Where Tax_Code = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 TaxID From InvoiceDetail Where TaxID = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 TaxCode From Batch_Products Where TaxCode = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 GRNTaxID From Batch_Products Where GRNTaxID = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 Tax_Code From BillTaxComponents Where Tax_Code = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 TaxCode From BillDetail Where TaxCode = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 Tax_Code From STITaxComponents Where Tax_Code = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 Tax_Code From STOTaxComponents Where Tax_Code = @ExistsTaxID)
Begin
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Cs_Code  is  already exists and used in transactions. Tax cannot be modified.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue, GetDate()
End
Fetch Next from Error into @ErrorID, @ExistsTaxID
END
Close Error
Deallocate Error
/* Error Ends */

/*4.Exists tax CS_Taxcode is already used in transactions Validation*/
/* Error Starts */
Declare Error Cursor For Select  ID,TaxDescID From #tmpRecd_Tax Where IsNull(TaxDescID,0) > 0
Open Error
Fetch from Error into @ErrorID, @ExistsTaxID
While @@FETCH_STATUS =0
BEGIN
If EXISTS ( SELECT TOP 1 Tax_Code From InvoiceTaxComponents Where Tax_Code = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 TaxID From InvoiceDetail Where TaxID = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 TaxCode From Batch_Products Where TaxCode = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 GRNTaxID From Batch_Products Where GRNTaxID = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 Tax_Code From BillTaxComponents Where Tax_Code = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 TaxCode From BillDetail Where TaxCode = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 Tax_Code From STITaxComponents Where Tax_Code = @ExistsTaxID) Or
EXISTS ( SELECT TOP 1 Tax_Code From STOTaxComponents Where Tax_Code = @ExistsTaxID)
Begin
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax TaxDescription is  already exists and used in transactions. Tax cannot be modified.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue, GetDate()
End
Fetch Next from Error into @ErrorID, @ExistsTaxID
END
Close Error
Deallocate Error
/* Error Ends */

--/*Exists tax CS_Taxcode Validation*/
--/* Error Starts */
--Declare Error Cursor For Select  ID From #tmpRecd_Tax Where CS_TaxCode In (Select CS_TaxCode From Tax)
--Open Error
--Fetch from Error into @ErrorID
--While @@FETCH_STATUS =0
--BEGIN
--	--Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
--	--Set @ErrMessage ='Tax already exists'
--	Update Recd_Tax Set Flag = 2 Where ID = @ErrorID
--	Update Recd_TaxComponents Set Flag = 2 Where TaxID = @ErrorID
--	Delete From #tmpRecd_Tax Where ID = @ErrorID
--	Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
--	--Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
--	--	Select @TransactionType, @ErrMessage, @KeyValue, GetDate()
--	Fetch Next from Error into @ErrorID
--END
--Close Error
--Deallocate Error
--/* Error Ends */

--/*Exists tax Tax_Description Validation*/
--/* Error Starts */
--Declare Error Cursor For Select  ID From #tmpRecd_Tax Where TaxDescription In (Select Tax_Description From Tax)
--Open Error
--Fetch from Error into @ErrorID
--While @@FETCH_STATUS =0
--BEGIN
--	--Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
--	--Set @ErrMessage ='Tax already exists'
--	Update Recd_Tax Set Flag = 3 Where ID = @ErrorID
--	Update Recd_TaxComponents Set Flag = 3 Where TaxID = @ErrorID
--	Delete From #tmpRecd_Tax Where ID = @ErrorID
--	Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
--	--Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
--	--	Select @TransactionType, @ErrMessage, @KeyValue		, GetDate()
--	Fetch Next from Error into @ErrorID
--END
--Close Error
--Deallocate Error
--/* Error Ends */

/*5.Compnents exists Validation*/
/* Error Starts */
Declare Error Cursor For Select  ID From #tmpRecd_Tax Where ID Not In (Select TaxID From #tmpRecd_TaxComponents)
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component not found'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		, GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*6.Compnents duplication Validation*/
/* Error Starts */
Declare Error Cursor For Select Distinct TaxID From #tmpRecd_TaxComponents	Group By TaxId, ComponentDescription, TaxType Having Count(*) > 1
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component - Duplicate component found.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*1A.ComponentType - Compnents Validation*/
/* Error Starts */
Declare Error Cursor For Select Distinct TaxID From #tmpRecd_TaxComponents Where ComponentType Not In  ('Percentage','Amount')
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component - ComponentType have wrong value. Value Must be Percentage/Amount.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*1B.ComponentType - Amount must applicable on = UOM Validation*/
/* Error Starts */
Declare Error Cursor For Select Distinct TaxID From #tmpRecd_TaxComponents Where ComponentType = 'Amount' And ApplicableOnDesc <> 'UOM'
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component - ComponentType = Amount is Applicable on UOM Only.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

--May be  ApplicableonComp = CS_ComponentCode
--	/*2A.ApplicableonComp	 - Compnents Validation component name and it's ApplicableonComp not same*/
/* Error Starts */
Declare Error Cursor For Select Distinct TaxID from #tmpRecd_TaxComponents Where ApplicableonComp = ComponentDescription
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component - Component name and ApplicableonComp are same.It is not valid.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		, GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

--	/*2B.ApplicableonComp	other then price is exists - Compnents Validation*/
--/* Error Starts */
Declare Error Cursor For
Select Distinct TaxID from #tmpRecd_TaxComponents A
Where A.ApplicableonComp <> 'Price'
And A.ApplicableonComp Not In (Select B.ComponentDescription From #tmpRecd_TaxComponents B Where B.TaxID = A.TaxID And A.TaxType = B.TaxType)
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage = 'Tax Component - Tax on Tax - ApplicableonComp is not found with in this Tax and TaxType.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		, GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

--	/*2C.ApplicableonComp	other then price is exists - Compnents Validation*/
--/* Error Starts */
Declare Error Cursor For
Select Distinct TaxID from #tmpRecd_TaxComponents A
Where A.ApplicableonComp <> 'Price' And ComponentType <> 'Percentage'
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage = 'Tax Component - Tax on Tax - component type must be percentage.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*2D.ApplicableonComp	other then price is exists - Compnents Validation*/
/* Error Starts */
Declare Error Cursor For
Select Distinct A.TaxID From (Select distinct TaxID from #tmpRecd_TaxComponents)  A
Left Join #tmpRecd_TaxComponents B On A.TaxID = B.TaxID And B.ApplicableonComp = 'Price'
Group By A.TaxID Having Count(B.TaxID) = 0
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage = 'Tax Component - must atleast one componet need to have ApplicableOnComp = Price.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*3.ApplicableOn	 - Compnents Validation*/
/* Error Starts */
Declare Error Cursor For Select Distinct TaxID from #tmpRecd_TaxComponents Where ApplicableOnDesc Not In  ('Price','PTS','PTR','ECP','SPPrice','MRP','UOM')
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component - ApplicableOn have wrong value. Value Must be Price/PTS/PTR/ECP/SPPrice/MRP/UOM .'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*4A.ApplicableUOM	 - Compnents Validation*/
/* Error Starts */
Declare Error Cursor For Select Distinct TaxID from #tmpRecd_TaxComponents
Where ApplicableOnDesc = 'UOM' And (IsNull(ApplicableUOM,'') = '' Or IsNull(ApplicableUOM,'') Not In ('Base UOM','UOM1','UOM2'))
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component - ApplicableOnDesc value is UOM but ApplicableUOM is empty value or not have Base UOM/UOM1/UOM2.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

--/*4B.ApplicableUOM	 - Compnents Validation*/
--/* Error Starts */
Declare Error Cursor For Select Distinct TaxID from #tmpRecd_TaxComponents
Where ApplicableOnDesc <> 'UOM' And IsNull(ApplicableUOM,'') <> ''
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component - ApplicableOnDesc have other then UOM value but ApplicableUOM have some value is not valid.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
--/* Error Ends */

/*5.TaxType	 - Compnents Validation*/
/* Error Starts */
Declare Error Cursor For Select Distinct TaxID from #tmpRecd_TaxComponents Where TaxType Not In  ('Intra State','Inter State')
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component - TaxType have wrong value. Value Must be Intra State/Inter State.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*6.PartOff  - Compnents Validation*/
/* Error Starts */
Declare Error Cursor For Select Distinct TaxID from #tmpRecd_TaxComponents Where IsNull(PartOff,0) <= 0
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component - PartOff have wrong value. Value Must be greater then 0.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*7.FirstPoint - Compnents Validation*/
/* Error Starts */
Declare Error Cursor For Select Distinct TaxID from #tmpRecd_TaxComponents Where IsNull(FirstPoint,0) Not In (0,1)
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage ='Tax Component - FirstPoint have wrong value. Value Must be 0 Or 1[FirstPoint].'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

/*101.TaxType	 - Compnents Level Validation*/
/* Error Starts */
Declare @CLevel Int
Declare @FoundErr Int
Declare Error Cursor For
Select Distinct TaxID from #tmpRecd_TaxComponents A
Open Error
Fetch from Error into @ErrorID
While @@FETCH_STATUS =0
BEGIN
Set @CLevel = 1
Set @FoundErr = 0
Update #tmpRecd_TaxComponents Set CompLevel = @CLevel Where TaxType = 'Intra State' And ApplicableonComp = 'Price' And TaxID = @ErrorID

While Exists(Select 'x' From #tmpRecd_TaxComponents A Where A.TaxType = 'Intra State' And A.ApplicableonComp <> 'Price'  And A.TaxID = @ErrorID
And ApplicableonComp in 	(Select B.ComponentDescription From #tmpRecd_TaxComponents B Where B.CompLevel = @CLevel  And B.TaxType = A.TaxType And B.TaxID = @ErrorID)
) And @FoundErr = 0
Begin
IF Exists(Select 'x' From #tmpRecd_TaxComponents A Where  A.TaxType = 'Intra State' And A.ApplicableonComp <> 'Price' And IsNull(CompLevel,0) <> 0  And A.TaxID = @ErrorID
And A.ApplicableonComp In (Select B.ComponentDescription From #tmpRecd_TaxComponents B Where B.CompLevel = @CLevel  And B.TaxType = A.TaxType And B.TaxID = @ErrorID)
)
Begin
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage = 'Tax Component - Tax on Tax - Cyclic Intra State components declared/improper Intra State components.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Set @FoundErr = 1
End
Else
Update A Set CompLevel = @CLevel + 1 From #tmpRecd_TaxComponents A Where A.TaxType = 'Intra State' And A.ApplicableonComp <> 'Price'  And A.TaxID = @ErrorID
And A.ApplicableonComp In (Select B.ComponentDescription From #tmpRecd_TaxComponents B Where B.CompLevel = @CLevel  And B.TaxType = A.TaxType And B.TaxID = @ErrorID)

Set @CLevel = @CLevel + 1

If @CLevel  > (Select Count(*) From #tmpRecd_TaxComponents A Where A.TaxType = 'Intra State' And A.TaxID = @ErrorID)  + 1
GoTo NextTaxInterID
End

NextTaxInterID:

Set @CLevel = 1
Set @FoundErr = 0
Update #tmpRecd_TaxComponents Set CompLevel = @CLevel Where TaxType = 'Inter State' And ApplicableonComp = 'Price' And TaxID = @ErrorID

While Exists(Select 'x' From #tmpRecd_TaxComponents A Where A.TaxType = 'Inter State' And A.ApplicableonComp <> 'Price'  And A.TaxID = @ErrorID
And ApplicableonComp in 	(Select B.ComponentDescription From #tmpRecd_TaxComponents B Where B.CompLevel = @CLevel  And B.TaxType = A.TaxType And B.TaxID = @ErrorID)
) And @FoundErr = 0
Begin
IF Exists(Select 'x' From #tmpRecd_TaxComponents A Where  A.TaxType = 'Inter State' And A.ApplicableonComp <> 'Price' And IsNull(CompLevel,0) <> 0  And A.TaxID = @ErrorID
And A.ApplicableonComp In (Select B.ComponentDescription From #tmpRecd_TaxComponents B Where B.CompLevel = @CLevel  And B.TaxType = A.TaxType And B.TaxID = @ErrorID)
)
Begin
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage = 'Tax Component - Tax on Tax - Cyclic Inter State components declared/improper Inter State components.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Set @FoundErr = 1
End
Else
Update A Set CompLevel = @CLevel + 1 From #tmpRecd_TaxComponents A Where A.TaxType = 'Inter State' And A.ApplicableonComp <> 'Price'  And A.TaxID = @ErrorID
And A.ApplicableonComp In (Select B.ComponentDescription From #tmpRecd_TaxComponents B Where B.CompLevel = @CLevel  And B.TaxType = A.TaxType And B.TaxID = @ErrorID)

Set @CLevel = @CLevel + 1

If @CLevel  > (Select Count(*) From #tmpRecd_TaxComponents A Where A.TaxType = 'Inter State' And A.TaxID = @ErrorID)  + 1
GoTo NextTaxID
End

NextTaxID:

IF Exists(Select 'x' From #tmpRecd_TaxComponents A Where IsNull(CompLevel,0) = 0  And A.TaxID = @ErrorID)
Begin
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@ErrorID)
Set @ErrMessage = 'Tax Component - Tax on Tax - improper components Declaration/Cyclic component declaration.'
Update Recd_Tax Set Flag = 64 Where ID = @ErrorID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @ErrorID
Delete From #tmpRecd_Tax Where ID = @ErrorID
Delete From #tmpRecd_TaxComponents Where TaxID = @ErrorID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue		,GetDate()
Set @FoundErr = 1
End

Fetch Next from Error into @ErrorID
END
Close Error
Deallocate Error
/* Error Ends */

Declare @NewTaxID Int
Declare @NewCompID Int
Declare @ApplicableonCompID Int
Declare @GSTCompID Int

Declare @RecdTaxID Int
Declare @CS_TaxCode Int
Declare @TaxDescription nVarChar(255)
Declare @EffectiveFromDt Datetime
Declare @GSTFlag Int
Declare @UpdateFlag Int

Declare @CS_TaxCompCode Int
Declare @TaxCompDesc nVarChar(255)
Declare @ComponentType nVarChar(50)
Declare @Rate Decimal(18,6)
Declare @ApplicableonComp nVarChar(50)
Declare @ApplicableOnDesc nVarChar(50)
Declare @ApplicableUOM nVarChar(50)
Declare @TaxType	 nVarChar(50)
Declare @GSTComponent nVarChar(255)
Declare @PartOff Decimal(18,6)
Declare @FirstPoint Int

Declare @IntraTax Decimal(18,6)
Declare @InterTax Decimal(18,6)
Declare @TaxOnTax Decimal(18,6)
Declare @SP_Percentage  Decimal(18,6)
Declare @TaxOnComp Int
Declare @CompLevel Int
Declare @RegStatus Int

Declare @TaxCSCodeID Int
Declare @TaxDescID Int

-- Accounts Careation
Declare @PayableAccID Int
Declare @ReceivableAccID Int
Declare @ReceivableOnDCAccID Int
Declare @PayableAcc nVarChar(255)
Declare @ReceivableAcc nVarChar(255)
Declare @ReceivableOnDCAcc nVarChar(255)

Create Table #tmpRecdTax (RecdTaxID Int,CS_TaxCode Int,TaxDescription nVarChar (255)  COLLATE SQL_Latin1_General_CP1_CI_AS,
EffectiveFromDate DateTime, GSTFlag Int,Intra_Percentage  Decimal(18,6),Inter_Percentage Decimal(18,6))
Insert Into #tmpRecdTax (RecdTaxID, CS_TaxCode, TaxDescription,EffectiveFromDate, GSTFlag, Intra_Percentage, Inter_Percentage)
Select ID, CS_TaxCode, TaxDescription, EffectiveFromDate,GSTFlag, Intra_Percentage, Inter_Percentage From #tmpRecd_Tax Where IsNull(Flag,0) = 0
Declare Tax_cursor CURSOR FOR Select RecdTaxID, CS_TaxCode, TaxDescription, EffectiveFromDate,GSTFlag, Intra_Percentage, Inter_Percentage From #tmpRecdTax
Open Tax_cursor
FETCH Next from Tax_cursor into @RecdTaxID, @CS_TaxCode, @TaxDescription, @EffectiveFromDt, @GSTFlag, @IntraTax ,  @InterTax
While @@FETCH_STATUS=0
BEGIN
--Set @IntraTax = 0
--Set @InterTax = 0

If Not Exists (Select 'x' From Tax Where CS_TaxCode = @CS_TaxCode Or Tax_Description = @TaxDescription)
--If IsNull(@TaxCSCodeID,0) = 0 And IsNull(@TaxDescID,0) = 0
Begin
Insert Into Tax (CS_TaxCode, Tax_Description, EffectiveFrom,GSTFlag,Percentage,CST_Percentage)
Select CS_TaxCode, TaxDescription, EffectiveFromDate, GSTFlag,Intra_Percentage,Inter_Percentage From Recd_Tax Where ID = @RecdTaxID
Set @NewTaxID = @@Identity
Set @UpdateFlag = 1
End
Else If Exists (Select 'x' From Tax Where IsNull(CS_TaxCode,0) = @CS_TaxCode)
--Else If IsNull(@TaxCSCodeID,0) > 0
Begin
Select @TaxCSCodeID = Tax_Code From Tax Where IsNull(CS_TaxCode,0) = @CS_TaxCode

If EXISTS ( SELECT TOP 1 Tax_Code From InvoiceTaxComponents Where Tax_Code = @TaxCSCodeID) Or
EXISTS ( SELECT TOP 1 TaxID From InvoiceDetail Where TaxID = @TaxCSCodeID) Or
EXISTS ( SELECT TOP 1 TaxCode From Batch_Products Where TaxCode = @TaxCSCodeID) Or
EXISTS ( SELECT TOP 1 GRNTaxID From Batch_Products Where GRNTaxID = @TaxCSCodeID) Or
EXISTS ( SELECT TOP 1 Tax_Code From BillTaxComponents Where Tax_Code = @TaxCSCodeID) Or
EXISTS ( SELECT TOP 1 TaxCode From BillDetail Where TaxCode = @TaxCSCodeID) Or
EXISTS ( SELECT TOP 1 Tax_Code From STITaxComponents Where Tax_Code = @TaxCSCodeID) Or
EXISTS ( SELECT TOP 1 Tax_Code From STOTaxComponents Where Tax_Code = @TaxCSCodeID)
Begin
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@RecdTaxID)
Set @ErrMessage ='Tax Cs_Code  is  already exists and used in transactions. Tax cannot be modified.'
Update Recd_Tax Set Flag = 64 Where ID = @RecdTaxID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @RecdTaxID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue, GetDate()
GoTo NextTax
End
Else
Begin
Update Tax Set CS_TaxCode = @CS_TaxCode, Tax_Description = @TaxDescription, EffectiveFrom = @EffectiveFromDt, GSTFlag =  @GSTFlag
, Percentage =  @IntraTax , CST_Percentage =  @InterTax
Where Tax_Code = @TaxCSCodeID
Set @NewTaxID = @TaxCSCodeID
Set @UpdateFlag = 2
Delete From TaxComponents Where Tax_Code = @NewTaxID
End
End
Else If Exists (Select 'x' From Tax Where Tax_Description = @TaxDescription)
--Else If IsNull(@TaxDescID,0) > 0
Begin
Select @TaxDescID = Tax_Code From Tax Where Tax_Description = @TaxDescription

If EXISTS ( SELECT TOP 1 Tax_Code From InvoiceTaxComponents Where Tax_Code = @TaxDescID) Or
EXISTS ( SELECT TOP 1 TaxID From InvoiceDetail Where TaxID = @TaxDescID) Or
EXISTS ( SELECT TOP 1 TaxCode From Batch_Products Where TaxCode = @TaxDescID) Or
EXISTS ( SELECT TOP 1 GRNTaxID From Batch_Products Where GRNTaxID = @TaxDescID) Or
EXISTS ( SELECT TOP 1 Tax_Code From BillTaxComponents Where Tax_Code = @TaxDescID) Or
EXISTS ( SELECT TOP 1 TaxCode From BillDetail Where TaxCode = @TaxDescID) Or
EXISTS ( SELECT TOP 1 Tax_Code From STITaxComponents Where Tax_Code = @TaxDescID) Or
EXISTS ( SELECT TOP 1 Tax_Code From STOTaxComponents Where Tax_Code = @TaxDescID)
Begin
Set @KeyValue = 'Recd_Tax Table ID = ' + Convert(nVarchar,@RecdTaxID)
Set @ErrMessage ='Tax TaxDescription is  already exists and used in transactions. Tax cannot be modified.'
Update Recd_Tax Set Flag = 64 Where ID = @RecdTaxID
Update Recd_TaxComponents Set Flag = 64 Where TaxID = @RecdTaxID
Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate)
Select @TransactionType, @ErrMessage, @KeyValue, GetDate()
GoTo NextTax
End
Else
Begin
Update Tax Set CS_TaxCode = @CS_TaxCode, Tax_Description = @TaxDescription, EffectiveFrom = @EffectiveFromDt, GSTFlag =  @GSTFlag
, Percentage =  @IntraTax , CST_Percentage =  @InterTax
Where Tax_Code = @TaxDescID
Set @NewTaxID = @TaxDescID
Set @UpdateFlag = 3
Delete From TaxComponents Where Tax_Code = @NewTaxID
End
End

Declare TaxComp_cursor CURSOR FOR
Select CS_ComponentCode, ComponentDescription, ComponentType, Rate, ApplicableonComp, ApplicableOnDesc, ApplicableUOM, TaxType, GSTComponent, PartOff,FirstPoint, CompLevel,CS_RegisterStatus
From #tmpRecd_TaxComponents Where TaxID =  @RecdTaxID And ApplicableonComp = 'Price'
Union
Select CS_ComponentCode, ComponentDescription, ComponentType, Rate, ApplicableonComp, ApplicableOnDesc, ApplicableUOM, TaxType, GSTComponent, PartOff,FirstPoint, CompLevel,CS_RegisterStatus
From #tmpRecd_TaxComponents Where TaxID =  @RecdTaxID And ApplicableonComp <> 'Price'
Order By CompLevel
Open TaxComp_cursor
FETCH Next from TaxComp_cursor Into @CS_TaxCompCode, @TaxCompDesc, @ComponentType,
@Rate, @ApplicableonComp, @ApplicableOnDesc, @ApplicableUOM, @TaxType , @GSTComponent, @PartOff,@FirstPoint,@CompLevel,@RegStatus
While @@FETCH_STATUS=0
BEGIN
If Not Exists (Select 'x' From TaxComponentDetail Where CS_ComponentCode = @CS_TaxCompCode And TaxComponent_desc = @TaxCompDesc)
Begin
Insert Into TaxComponentDetail (TaxComponent_desc,CS_ComponentCode,GSTFlag) Select @TaxCompDesc, @CS_TaxCompCode, @GSTFlag
Set @NewCompID = @@Identity
End
Else
Select @NewCompID = TaxComponent_code From TaxComponentDetail
Where CS_ComponentCode = @CS_TaxCompCode And TaxComponent_desc = @TaxCompDesc

If IsNull(@GSTFlag,0) = 1 And IsNull(@Rate,0) > 0
Begin
Set @PayableAcc = @TaxCompDesc + ' Output'--' Payable (Output Tax)'

If Exists(Select [AccountName] From AccountsMaster Where [AccountName]= @PayableAcc)
Begin
Select @PayableAccID = AccountID From AccountsMaster Where [AccountName]= @PayableAcc
Update TaxComponentDetail Set OutputAccID = @PayableAccID
Where TaxComponent_code = @NewCompID And IsNull(OutputAccID,0) = 0
End
Else
Begin
--New Accounts Creating
--Insert Into AccountsMaster([AccountName],[GroupID],[Active],[Fixed],[DefaultGroupID])
--Values (@PayableAcc,8,1,1,17)
Insert Into AccountsMaster([AccountName],[GroupID],[Active],[Fixed]) Values (@PayableAcc,74,1,1)
Set @PayableAccID = @@Identity
Update TaxComponentDetail Set OutputAccID = @PayableAccID Where TaxComponent_code = @NewCompID
End

Set @ReceivableAcc = @TaxCompDesc + ' Input'--' Receivable (Input Tax Credit)'

If Exists(Select [AccountName] From AccountsMaster Where [AccountName]= @ReceivableAcc)
Begin
Select @ReceivableAccID = AccountID From AccountsMaster Where [AccountName]= @ReceivableAcc
Update TaxComponentDetail Set InputAccID = @ReceivableAccID
Where TaxComponent_code = @NewCompID And IsNull(InputAccID,0) = 0
End
Else
Begin
--New Accounts Creating
--Insert Into AccountsMaster([AccountName],[GroupID],[Active],[Fixed],[DefaultGroupID])
--Values (@ReceivableAcc,73,1,1,73)
Insert Into AccountsMaster([AccountName],[GroupID],[Active],[Fixed]) Values (@ReceivableAcc,75,1,1)
Set @ReceivableAccID = @@Identity
Update TaxComponentDetail Set InputAccID = @ReceivableAccID Where TaxComponent_code = @NewCompID
End

--Set @ReceivableOnDCAcc = @TaxCompDesc + ' Input on Dc'--' Receivable on DC'

--If Exists(Select [AccountName] From AccountsMaster Where [AccountName]= @ReceivableOnDCAcc)
--Begin
--	Select @ReceivableOnDCAccID = AccountID From AccountsMaster Where [AccountName]= @ReceivableOnDCAcc
--	Update TaxComponentDetail Set InputOnDCAccID = @ReceivableOnDCAccID Where TaxComponent_code = @NewCompID
--End
--Else
--Begin
--	--New Accounts Creating
--	Insert Into AccountsMaster([AccountName],[GroupID],[Active],[Fixed],[DefaultGroupID])
--	Values (@ReceivableOnDCAcc,73,1,1,73)
--	Set @ReceivableOnDCAccID = @@Identity
--	Update TaxComponentDetail Set InputOnDCAccID = @ReceivableOnDCAccID Where TaxComponent_code = @NewCompID
--End
End

If Not Exists (Select 'x' From GSTComponent Where GSTComponentDesc=@GSTComponent)
Begin
Select @GSTCompID = IsNull(Max(GSTComponentCode),0) + 1 From GSTComponent
Insert Into GSTComponent (GSTComponentCode,GSTComponentDesc)  Values (@GSTCompID,@GSTComponent)
End
Else
Select @GSTCompID = GSTComponentCode From GSTComponent Where GSTComponentDesc=@GSTComponent

IF @ApplicableonComp <> 'Price'
Select @ApplicableonCompID = CS_ComponentCode From #tmpRecd_TaxComponents Where TaxID =  @RecdTaxID And ComponentDescription = @ApplicableonComp
Else
Set @ApplicableonCompID= 0

Insert Into TaxComponents (Tax_Code, TaxComponent_code, Tax_percentage, ApplicableOn, --SP_Percentage, LST_Flag,
CS_ComponentCode, ComponentType, ApplicableonComp, ApplicableOnCode, ApplicableUOM, CSTaxType, GSTComponentCode,PartOff,FirstPoint, CompLevel,RegisterStatus)
Select @NewTaxID, @NewCompID, @Rate, @ApplicableonComp , --0, Case When @TaxType = 'Intra State' Then 1 Else 2 End,
@CS_TaxCompCode, 	Case when @ComponentType = 'Amount' Then 2 Else 1 End, @ApplicableonCompID,
Case When @ApplicableOnDesc = 'Price' Then 1 When @ApplicableOnDesc='PTS' Then 2 When @ApplicableOnDesc='PTR' Then 3 When @ApplicableOnDesc='ECP' Then 4
When @ApplicableOnDesc='SPPrice' Then 5 When @ApplicableOnDesc='MRP' Then 6 When @ApplicableOnDesc='UOM' Then 7 Else 0 End,
Case When @ApplicableUOM = 'Base UOM' Then 1 When @ApplicableUOM='UOM1' Then 2 When @ApplicableUOM='UOM2' then 3 Else 0 End,
Case When @TaxType = 'Intra State' Then 1 Else 2 End, @GSTCompID,@PartOff, @FirstPoint,@CompLevel,@RegStatus

--If @TaxType = 'Intra State'
--	Set @IntraTax = @IntraTax + @Rate

--If @TaxType = 'Inter State'
--	Set @InterTax = @InterTax + @Rate

FETCH Next from TaxComp_cursor Into @CS_TaxCompCode, @TaxCompDesc, @ComponentType,
@Rate, @ApplicableonComp, @ApplicableOnDesc, @ApplicableUOM, @TaxType , @GSTComponent, @PartOff ,@FirstPoint,@CompLevel,@RegStatus
END
CLOSE TaxComp_cursor
DEALLOCATE TaxComp_cursor

--Update Tax Set Percentage = @IntraTax Where Tax_Code = @NewTaxID
--Update Tax Set CST_Percentage = @InterTax Where Tax_Code = @NewTaxID

Update Recd_Tax Set Flag = @UpdateFlag Where ID = @RecdTaxID And IsNull(Flag,0) = 0
Update Recd_TaxComponents Set Flag = @UpdateFlag Where TaxID = @RecdTaxID
If @UpdateFlag = 1
Update Recd_Tax Set AlertCount = 1 Where ID = @RecdTaxID And IsNull(AlertCount,0) = 0

NextTax:

FETCH NEXT FROM Tax_cursor INTO @RecdTaxID,@CS_TaxCode, @TaxDescription, @EffectiveFromDt, @GSTFlag , @IntraTax ,  @InterTax
END
CLOSE Tax_cursor
DEALLOCATE Tax_cursor
Drop Table #tmpRecd_Tax
Drop Table #tmpRecdTax
Drop Table #tmpRecd_TaxComponents

End
End
