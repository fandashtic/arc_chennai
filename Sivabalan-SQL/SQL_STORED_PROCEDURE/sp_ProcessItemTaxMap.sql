CREATE Procedure sp_ProcessItemTaxMap (@ProcessFlag Int = 0)
As
Begin
	Set DateFormat DMY
	Declare @OpeningDate DateTime
	Declare @LastCloseDay DateTime
	Declare @LastTranDay DateTime
	Declare @GSTEnable Int
	
	Select Top 1 @OpeningDate = Openingdate, @LastCloseDay = LastInventoryUpload, @LastTranDay = TransactionDate From Setup
  
	Select @GSTEnable = Isnull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled' 

	Create Table #Recd_ItemsTaxMap(Recd_MapID Int, XML_DocID Int,
		Product_Code nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS Not Null,
		CS_Sal_TaxID Int Not Null, STaxCode Int, STaxEffectiveFrom DateTime, SEffectiveFrom DateTime, SEffectiveTo DateTime, ProdLastSalDt  DateTime, SStatus Int,
		CS_Pur_TaxID Int Not Null, PTaxCode Int, PTaxEffectiveFrom DateTime, PEffectiveFrom DateTime, PEffectiveTo DateTime, ProdLastPurDt  DateTime,	PStatus Int,
		OpeningDt DateTime,SetupTranDt DateTime,DayCloseDt DateTime,Active Int)

	--Select 10001,@OpeningDate,@LastTranDay,@LastCloseDay,* From Recd_ItemTaxMapping Where IsNull(Status,0) = 0
	
	Insert Into #Recd_ItemsTaxMap (Recd_MapID,XML_DocID,Product_Code,CS_Sal_TaxID,CS_Pur_TaxID,Active,OpeningDt,SetupTranDt,DayCloseDt)
	Select ID, xmlDocNumber, ProductCode, CS_SalesTaxCode, CS_PurcahseTaxCode, Active,@OpeningDate,@LastTranDay,@LastCloseDay From Recd_ItemTaxMapping 
	Where IsNull(Status,0) = 0 And @ProcessFlag = 1
	
	Declare @ErrorID Int
	Declare @XmlDocNumber Int
	Declare @Product_Code nVarChar(15)
	Declare @TransactionType nVarChar(255)
	Declare @ErrMessage nVarChar(4000)
	Declare @KeyValue nVarChar(255)
	Set @TransactionType = 'Received Item Tax Mapping'

	/*1.Exists Product code Validation*/
	/* Error Starts */
	Declare Error Cursor For Select  XML_DocID,Product_Code From #Recd_ItemsTaxMap Where Product_Code Not In (Select Product_Code From Items)
	Open Error
	Fetch from Error into  @XmlDocNumber, @Product_Code
	While @@FETCH_STATUS =0
	BEGIN
		Set @KeyValue = 'Recd_ItemTaxMapping Table Xml Number = ' + Convert(nVarchar,@XmlDocNumber) 
		Set @ErrMessage ='Product code not found in Items master for Product code='  +  @Product_Code
		Update Recd_ItemTaxMapping Set Status = 8 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code	
		Delete From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code 
		--Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) 
		--	Select @TransactionType, @ErrMessage, @KeyValue, GetDate() 
		Fetch Next from Error into  @XmlDocNumber, @Product_Code 
	END
	Close Error
	Deallocate Error
	/* Error Ends */

	/*2.Exists tax CS_Taxcode Validation*/
	/* Error Starts */
	Declare Error Cursor For Select  XML_DocID,Product_Code From #Recd_ItemsTaxMap Where CS_Sal_TaxID Not In (Select CS_TaxCode From Tax Where IsNull(CS_TaxCode,0)>0)
	Open Error
	Fetch from Error into  @XmlDocNumber, @Product_Code
	While @@FETCH_STATUS =0
	BEGIN
		Set @KeyValue = 'Recd_ItemTaxMapping Table Xml Number = ' + Convert(nVarchar,@XmlDocNumber) 
		Set @ErrMessage ='Sales Tax Code not found in tax master for Product code='  +  @Product_Code
		Update Recd_ItemTaxMapping Set Status = 8 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code	
		Delete From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code 
		--Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) 
		--	Select @TransactionType, @ErrMessage, @KeyValue, GetDate() 
		Fetch Next from Error into  @XmlDocNumber, @Product_Code 
	END
	Close Error
	Deallocate Error
	/* Error Ends */

	/*3.Exists tax CS_Taxcode Validation*/
	/* Error Starts */
	Declare Error Cursor For Select  XML_DocID,Product_Code From #Recd_ItemsTaxMap Where CS_Pur_TaxID Not In (Select CS_TaxCode From Tax Where IsNull(CS_TaxCode,0)>0)
	Open Error
	Fetch from Error into  @XmlDocNumber, @Product_Code
	While @@FETCH_STATUS =0
	BEGIN
		Set @KeyValue = 'Recd_ItemTaxMapping Table Xml Number = ' + Convert(nVarchar,@XmlDocNumber) 
		Set @ErrMessage ='Purchase Tax Code not found in tax master for Product code='  +  @Product_Code
		Update Recd_ItemTaxMapping Set Status = 8 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code	
		Delete From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code 
		Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) 
			Select @TransactionType, @ErrMessage, @KeyValue, GetDate() 
		Fetch Next from Error into  @XmlDocNumber, @Product_Code 
	END
	Close Error
	Deallocate Error
	/* Error Ends */

	/*4.Exists tax CS_Taxcode Validation*/
	/* Error Starts */
	Declare Error Cursor For Select  XML_DocID,Product_Code From #Recd_ItemsTaxMap Where CS_Sal_TaxID Not In 
	(Select CS_TaxCode From Tax Where IsNull(GSTFlag,0) = 1 And IsNull(CS_TaxCode,0)>0)
	Open Error
	Fetch from Error into  @XmlDocNumber, @Product_Code
	While @@FETCH_STATUS =0
	BEGIN
		Set @KeyValue = 'Recd_ItemTaxMapping Table Xml Number = ' + Convert(nVarchar,@XmlDocNumber) 
		Set @ErrMessage ='Sales Tax Code GSTFlag is 0 in tax master is invalid for Product code='  +  @Product_Code
		Update Recd_ItemTaxMapping Set Status = 64 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code	
		Delete From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code 
		Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) 
			Select @TransactionType, @ErrMessage, @KeyValue, GetDate() 
		Fetch Next from Error into  @XmlDocNumber, @Product_Code 
	END
	Close Error
	Deallocate Error
	/* Error Ends */

	/*5.Exists tax CS_Taxcode Validation*/
	/* Error Starts */
	Declare Error Cursor For Select  XML_DocID,Product_Code From #Recd_ItemsTaxMap Where CS_Pur_TaxID Not In 
	(Select CS_TaxCode From Tax Where  IsNull(GSTFlag,0) = 1 And IsNull(CS_TaxCode,0)>0)
	Open Error
	Fetch from Error into  @XmlDocNumber, @Product_Code
	While @@FETCH_STATUS =0
	BEGIN
		Set @KeyValue = 'Recd_ItemTaxMapping Table Xml Number = ' + Convert(nVarchar,@XmlDocNumber) 
		Set @ErrMessage ='Purchase Tax Code GSTFlag is 0 in tax master is invalid for Product code='  +  @Product_Code
		Update Recd_ItemTaxMapping Set Status = 64 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code	
		Delete From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code 
		Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) 
			Select @TransactionType, @ErrMessage, @KeyValue, GetDate() 
		Fetch Next from Error into  @XmlDocNumber, @Product_Code 
	END
	Close Error
	Deallocate Error
	/* Error Ends */
	
	--/*6.Sales tax Duplication CS_Taxcode Validation*/
	--/* Error Starts */
	--Declare Error Cursor For Select  XML_DocID,Product_Code From #Recd_ItemsTaxMap 
	--Group By XML_DocID, Product_Code, CS_Sal_TaxID Having Count(*) > 1
	--Open Error
	--Fetch from Error into @XmlDocNumber, @Product_Code
	--While @@FETCH_STATUS =0
	--BEGIN
	--	Set @KeyValue = 'Recd_ItemTaxMapping Table Xml Number = ' + Convert(nVarchar,@XmlDocNumber) 
	--	Set @ErrMessage ='Duplicate Sales Tax received for Product code='  +  @Product_Code
	--	Update Recd_ItemTaxMapping Set Status = 64 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code	
	--	Delete From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code 
	--	Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) 
	--		Select @TransactionType, @ErrMessage, @KeyValue, GetDate() 
	--	Fetch Next from Error into @XmlDocNumber, @Product_Code 
	--END
	--Close Error
	--Deallocate Error
	--/* Error Ends */

	--/*7.Purchase tax Duplication CS_Taxcode Validation*/
	--/* Error Starts */
	--Declare Error Cursor For Select  XML_DocID,Product_Code From #Recd_ItemsTaxMap  
	--Group By XML_DocID, Product_Code, CS_Pur_TaxID Having Count(*) > 1
	--Open Error
	--Fetch from Error into @XmlDocNumber, @Product_Code
	--While @@FETCH_STATUS =0
	--BEGIN
	--	Set @KeyValue = 'Recd_ItemTaxMapping Table Xml Number = ' + Convert(nVarchar,@XmlDocNumber) 
	--	Set @ErrMessage ='Duplicate Purchase Tax received for Product code='  +  @Product_Code
	--	Update Recd_ItemTaxMapping Set Status = 64 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code	
	--	Delete From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code 
	--	Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) 
	--		Select @TransactionType, @ErrMessage, @KeyValue, GetDate() 
	--	Fetch Next from Error into @XmlDocNumber, @Product_Code 
	--END
	--Close Error
	--Deallocate Error
	--/* Error Ends */
	
	Update RT Set PTaxCode = Tax_Code, PTaxEffectiveFrom = EffectiveFrom From #Recd_ItemsTaxMap RT Join Tax T On T.CS_TaxCode = RT.CS_Pur_TaxID
	Update RT Set STaxCode = Tax_Code, STaxEffectiveFrom = EffectiveFrom From #Recd_ItemsTaxMap RT Join Tax T On T.CS_TaxCode = RT.CS_Sal_TaxID
	
	Create Table #tmpItems(ItemID Int Identity(1,1),ItemCode nVarChar (15)  COLLATE SQL_Latin1_General_CP1_CI_AS)
	
	Insert Into #tmpItems (ItemCode) Select Distinct Product_Code from #Recd_ItemsTaxMap
	
	Create Table #tmpItemTrans(TransID Int,ItemCode nVarChar (15)  COLLATE SQL_Latin1_General_CP1_CI_AS,TransDate DateTime)
	Insert Into #tmpItemTrans (TransID, ItemCode, TransDate)
	Select 1,Product_Code,Max(BillDate) From BillAbstract BA Join BillDetail BD On BD.BillID = BA.BillID
	Where BD.Product_Code In (Select ItemCode From #tmpItems)
	Group By Product_Code
	Union
	Select 2,Product_Code,Max(AdjustmentDate) From AdjustmentReturnAbstract ARA Join AdjustmentReturnDetail ARD On ARA.AdjustmentID = ARD.AdjustmentID
	Where ARD.Product_Code In (Select ItemCode From #tmpItems)
	Group By Product_Code
	Union
	Select 3,Product_Code,Max(DocumentDate) From StockTransferInAbstract STIA Join StockTransferInDetail STID On STIA.DocSerial = STID.DocSerial
	Where STID.Product_Code In (Select ItemCode From #tmpItems)
	Group By Product_Code
	Union
	Select 4,Product_Code,Max(AdjustmentDate) From StockAdjustmentAbstract SAA Join StockAdjustment SAD On SAA.AdjustmentID = SAD.SerialNO
	Where SAD.Product_Code In (Select ItemCode From #tmpItems)
	Group By Product_Code
	Union
	Select 6,Product_Code,Max(InvoiceDate) From InvoiceAbstract IA Join InvoiceDetail ID On ID.InvoiceID = IA.InvoiceID
	Where ID.Product_Code In (Select ItemCode From #tmpItems)
	Group By Product_Code
	Union
	Select 7,Product_Code,Max(DocumentDate) From StockTransferOutAbstract STOA Join StockTransferOutDetail STOD On STOA.DocSerial = STOD.DocSerial
	Where STOD.Product_Code In (Select ItemCode From #tmpItems)
	Group By Product_Code
	Union
	Select 8,Product_Code,Max(AdjustmentDate) From StockAdjustmentAbstract SAA Join StockAdjustment SA On SAA.AdjustmentID = SA.SerialNO
	Where SA.Product_Code In (Select ItemCode From #tmpItems)
	Group By Product_Code
	
	Order By Product_Code
	
	--Union 
	--Select 9,Product_Code,Max(SEffectiveFrom) From ItemsSTaxMap STax
	--Where STax.Product_Code In (Select ItemCode From #tmpItems)
	--Group By Product_Code
	--Union
	--Select 4,Product_Code,Max(PEffectiveFrom) From ItemsPTaxMap PTax
	--Where PTax.Product_Code In (Select ItemCode From #tmpItems)
	--Group By Product_Code
	
	--Select * from ItemsSTaxMap
	--Select * from ItemsPTaxMap

	Create Table #tmpItemsSTran(ItemID Int Identity(1,1),ItemCode nVarChar (15)  COLLATE SQL_Latin1_General_CP1_CI_AS,TransDate DateTime)	
	
	Insert Into #tmpItemsSTran (ItemCode, TransDate)
	Select ItemCode, Max(TransDate) From  #tmpItemTrans Where TransID in (4,6,7,8) Group By ItemCode 
	
	Update RT Set ProdLastSalDt = TransDate From #Recd_ItemsTaxMap  RT Join  #tmpItemsSTran IT On IT.ItemCode= RT.Product_Code
	
	--Drop Table #tmpItemsSTran
	
	Create Table #tmpItemsPTran(ItemID Int Identity(1,1),ItemCode nVarChar (15)  COLLATE SQL_Latin1_General_CP1_CI_AS,TransDate DateTime)
	
	Insert Into #tmpItemsPTran (ItemCode, TransDate)
	Select ItemCode, Max(TransDate) From #tmpItemTrans Where TransID in (1,2,3,4) Group By ItemCode 
	
	Update RT Set ProdLastPurDt = TransDate From #Recd_ItemsTaxMap  RT Join  #tmpItemsPTran IT On IT.ItemCode= RT.Product_Code	
	
	--Drop Table #tmpItemsPTran
	
	Update #Recd_ItemsTaxMap Set ProdLastSalDt = OpeningDt-1 Where ProdLastSalDt Is Null
	Update #Recd_ItemsTaxMap Set ProdLastPurDt = OpeningDt-1 Where ProdLastPurDt Is Null
	
	Update #Recd_ItemsTaxMap  Set SEffectiveFrom = STaxEffectiveFrom Where STaxEffectiveFrom > ProdLastSalDt
	Update #Recd_ItemsTaxMap  Set SEffectiveFrom = ProdLastSalDt + 1   Where STaxEffectiveFrom <= ProdLastSalDt

	Update #Recd_ItemsTaxMap  Set PEffectiveFrom = PTaxEffectiveFrom Where PTaxEffectiveFrom > ProdLastPurDt
	Update #Recd_ItemsTaxMap  Set PEffectiveFrom = ProdLastPurDt + 1   Where PTaxEffectiveFrom <= ProdLastPurDt

	--Select Recd_MapID, XML_DocID, Product_Code,
	--CS_Sal_TaxID, STaxCode, STaxEffectiveFrom, SEffectiveFrom , SEffectiveTo , ProdLastSalDt, SStatus ,
	----CS_Pur_TaxID, PTaxCode, PTaxEffectiveFrom, PEffectiveFrom , PEffectiveTo, ProdLastPurDt, PStatus,
	--OpeningDt ,SetupTranDt ,DayCloseDt ,Active from #Recd_ItemsTaxMap 

	--Select XML_DocID=-1,MapID,Recd_MapID,Product_Code, STaxCode, SEffectiveFrom, SEffectiveTo From ItemsSTaxMap 
	--Where Product_Code In (Select ItemCode From #tmpItems) And SEffectiveTo Is Null
	--Union
	--Select XML_DocID,Min(Recd_MapID),Min(Recd_MapID), Product_Code, STaxCode,SEffectiveFrom , SEffectiveTo From #Recd_ItemsTaxMap
	--Group By XML_DocID, Product_Code, STaxCode,SEffectiveFrom , SEffectiveTo 
	--Order By Product_Code,XML_DocID,SEffectiveFrom

	Declare @EffDt DateTime
	Declare @TaxCodes nVarChar(255)
	
	/*6.Two different Sales Taxs have same Effective from date Validation*/
	/* Error Starts */	
	Declare Error Cursor For Select  A.XML_DocID,A.Product_Code,A.SEffectiveFrom From 
	(Select Distinct XML_DocID,Product_Code,CS_Sal_TaxID,SEffectiveFrom From #Recd_ItemsTaxMap Where Active = 1) A
	Group By A.XML_DocID,A.Product_Code,A.SEffectiveFrom Having Count(*) > 1	
	Open Error
	Fetch from Error into  @XmlDocNumber, @Product_Code, @EffDt
	While @@FETCH_STATUS =0
	BEGIN
		Set @KeyValue = 'Recd_ItemTaxMapping Table Xml Number = ' + Convert(nVarchar,@XmlDocNumber) 
		Set @TaxCodes = ''
		Select @TaxCodes = @TaxCodes + '-' + Convert(nVarchar,CS_Sal_TaxID) From #Recd_ItemsTaxMap
		Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code And SEffectiveFrom = @EffDt
		Set @ErrMessage ='Two different Sales Taxs '+  IsNull(@TaxCodes,'') +'- are Mapped with same Effective from date [' + Convert(nVarChar,@EffDt) + '] for Product code='  +  @Product_Code		
		Update Recd_ItemTaxMapping Set Status = 64 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code	
		Delete From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code 
		Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) 
			Select @TransactionType, @ErrMessage, @KeyValue, GetDate() 
		Fetch Next from Error into  @XmlDocNumber, @Product_Code, @EffDt 
	END
	Close Error
	Deallocate Error
	/* Error Ends */

	/*7.Two different Purchase Taxs have same Effective from date Validation*/
	/* Error Starts */	
	Declare Error Cursor For Select  A.XML_DocID,A.Product_Code,A.SEffectiveFrom From 
	(Select Distinct XML_DocID,Product_Code,CS_Pur_TaxID,SEffectiveFrom From #Recd_ItemsTaxMap Where Active = 1) A
	Group By A.XML_DocID,A.Product_Code,A.SEffectiveFrom Having Count(*) > 1	
	Open Error
	Fetch from Error into  @XmlDocNumber, @Product_Code, @EffDt
	While @@FETCH_STATUS =0
	BEGIN
		Set @KeyValue = 'Recd_ItemTaxMapping Table Xml Number = ' + Convert(nVarchar,@XmlDocNumber) 
		Set @TaxCodes = ''
		Select @TaxCodes = @TaxCodes + '-' + Convert(nVarchar,CS_Sal_TaxID) From #Recd_ItemsTaxMap
		Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code And SEffectiveFrom = @EffDt
		Set @ErrMessage ='Two different Purchase Taxs '+  IsNull(@TaxCodes,'') +'- are Mapped with same Effective from date [' + Convert(nVarChar,@EffDt) + '] for Product code='  +  @Product_Code		
		Update Recd_ItemTaxMapping Set Status = 64 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code	
		Delete From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code 
		Insert Into tbl_mERP_RecdErrMessages (TransactionType,ErrMessage,KeyValue,ProcessDate) 
			Select @TransactionType, @ErrMessage, @KeyValue, GetDate() 
		Fetch Next from Error into  @XmlDocNumber, @Product_Code, @EffDt 
	END
	Close Error
	Deallocate Error
	/* Error Ends */

	--Select '#Recd_ItemsTaxMap', * From #Recd_ItemsTaxMap

Declare @CurTaxID Int

Declare @NewTaxFrDt DateTime
Declare @NewTaxID Int
Declare @ItemSalDt DateTime
Declare @ItemPurDt DateTime

Declare @Recd_MapID	 Int

Declare @MinFrmDt DateTime

Declare @OFlag Int	
Declare @NFlag Int
Declare @PreMapID Int	
Declare @PreOFlag Int

	--Create Table #tmpSTaxMap4ItemX(XML_DocID Int,Product_Code nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
	--CS_Sal_TaxID Int, STaxCode Int, STaxEffectiveFrom DateTime, SEffectiveFrom DateTime, SEffectiveTo DateTime, NSEffectiveTo DateTime, ProdLastSalDt  DateTime, SStatus Int,Active Int,
	--MapID Int,Recd_MapID Int,OFlag Int, NFlag Int, ORemove Int, NRemove Int, OUpdate Int, NInsert Int, NewStatus Int
	--)
	
Declare EachXMLItems Cursor For Select XML_DocID,Product_Code From #Recd_ItemsTaxMap Group By XML_DocID,Product_Code
Open EachXMLItems
Fetch From EachXMLItems Into @XmlDocNumber,@Product_Code 
While @@Fetch_Status = 0
Begin	
	
	IF (Select Count(*) From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code) = 0
		Goto NextXMLItems
	
	---Item Sale Tax Process
	
	Select @NewTaxFrDt = SEffectiveFrom,@ItemSalDt = ProdLastSalDt From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code
	
	Select Top 1 @ItemSalDt =  TransDate From #tmpItemsSTran IT Where IT.ItemCode= @Product_Code
	
	If object_id('tempdb..#tmpSTaxMap4Item') is not null
		Drop Table #tmpSTaxMap4Item
	
	Create Table #tmpSTaxMap4Item (
	XML_DocID Int,Product_Code nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CS_Sal_TaxID Int, STaxCode Int, STaxEffectiveFrom DateTime, SEffectiveFrom DateTime, SEffectiveTo DateTime, NSEffectiveTo DateTime, ProdLastSalDt  DateTime, SStatus Int,Active Int,
	MapID Int,Recd_MapID Int,OFlag Int, NFlag Int, ORemove Int, NRemove Int, OUpdate Int, NInsert Int, NewStatus Int
	)
	
	If Not Exists(Select @Product_Code From ItemsSTaxMap Where Product_Code = @Product_Code)
		If Exists(Select IsNull(Sale_Tax,0) From Items Where IsNull(Sale_Tax,0)>0 And Product_Code = @Product_Code)
			Insert Into ItemsSTaxMap (Recd_MapID,Product_Code, STaxCode, SEffectiveFrom)
				Select 0,Product_Code, Sale_Tax, @OpeningDate From Items Where IsNull(Sale_Tax,0)>0 And Product_Code = @Product_Code
			
	Insert Into #tmpSTaxMap4Item (XML_DocID,OFlag,MapID,Recd_MapID,Product_Code,STaxCode,SEffectiveFrom,SEffectiveTo,ProdLastSalDt,Active)
	Select @XmlDocNumber,1, MapID,Recd_MapID, @Product_Code,  STaxCode, SEffectiveFrom, SEffectiveTo,@ItemSalDt ,-1 From ItemsSTaxMap 
	Where Product_Code = @Product_Code And IsNull(SEffectiveTo,GetDate()) >= @ItemSalDt
	
	--Insert Into #tmpSTaxMap4Item (XML_DocID,NFlag,MapID,Recd_MapID,Product_Code,STaxCode,SEffectiveFrom,SEffectiveTo,ProdLastSalDt,Active,NewStatus)
	--Select @XmlDocNumber,1,-1, Recd_MapID,Product_Code ,  STaxCode, SEffectiveFrom, SEffectiveTo,ProdLastSalDt ,Active , 1
	--From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code And Active = 0	
	
	Insert Into #tmpSTaxMap4Item (XML_DocID,NFlag,MapID,Recd_MapID,Product_Code,CS_Sal_TaxID,STaxCode,SEffectiveFrom,SEffectiveTo,ProdLastSalDt,Active,NewStatus)
	Select @XmlDocNumber,1,-1, Recd_MapID,Product_Code , CS_Sal_TaxID, STaxCode, SEffectiveFrom, SEffectiveTo,ProdLastSalDt ,Active , 1
	From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code And Active = 1
	Order By SEffectiveFrom	
	
	Set @MinFrmDt = Null
	Select @MinFrmDt = Min(SEffectiveFrom) From #tmpSTaxMap4Item Where NFlag = 1 And Active = 1
	
	Update #tmpSTaxMap4Item Set ORemove = 1 Where SEffectiveFrom >= @MinFrmDt And OFlag = 1 And Active = -1
	
	Delete From ItemsSTaxMap Where MapID In 
	(Select MapID From #tmpSTaxMap4Item Where Product_Code = @Product_Code And ORemove = 1 And Active =-1 And OFlag = 1)
	
	Update #tmpSTaxMap4Item Set NRemove = 1 Where SEffectiveFrom > ProdLastSalDt And OFlag = 1 And Active = -1 And 
	STaxCode In (Select STaxCode From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code And Active = 0)
	
	--Delete From ItemsSTaxMap Where 
	--STaxCode In (Select STaxCode From #tmpSTaxMap4Item Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code And NRemove = 1)
	
	Update Recd_ItemTaxMapping Set Status = 4 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code And Active = 0
	
	If Not Exists(Select 'x' From #tmpSTaxMap4Item 
		Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code  And Active = 1 And IsNull(ORemove,0) = 0 And IsNull(NRemove,0) = 0)
	Begin
		Update ItemsSTaxMap Set SEffectiveTo = Null, ModifyDate = GetDate()  Where Product_Code = @Product_Code And 
		MapID = IsNull((Select Top 1 MapID From ItemsSTaxMap Where Product_Code = @Product_Code And IsNull(SEffectiveTo,GetDate()) >= @ItemSalDt Order By SEffectiveFrom Desc),0)
		GoTo NextXMLItemsP
	End
		
	Declare EachTaxItem Cursor For 	
	Select Case When OFlag = 1 Then MapID Else Recd_MapID End, STaxCode, SEffectiveFrom, ProdLastSalDt , OFlag, NFlag	From #tmpSTaxMap4Item 
	Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code  And (Active = -1 Or Active = 1) And IsNull(ORemove,0) = 0 And IsNull(NRemove,0) = 0
	Order By SEffectiveFrom
	
	Open EachTaxItem	
	
	Fetch From EachTaxItem Into @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemSalDt, @OFlag, @NFlag
	Set @PreMapID = Null
	Set @CurTaxID = Null
	while @@Fetch_Status = 0
	Begin		
		
		If IsNull(@CurTaxID,0) <> 0 And @CurTaxID = @NewTaxID And @NFlag = 1
		Begin
			Update Recd_ItemTaxMapping Set Status = 2 Where ID = @Recd_MapID
			Update #tmpSTaxMap4Item Set NewStatus = 2 Where Recd_MapID = @Recd_MapID
		End
		
		Set @CurTaxID = @NewTaxID
		
		Fetch Next From EachTaxItem Into  @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemSalDt , @OFlag, @NFlag
	End
	Close EachTaxItem
	DeAllocate EachTaxItem	
	
	Declare EachTaxItem Cursor For 	
	Select Case When OFlag = 1 Then MapID Else Recd_MapID End, STaxCode, SEffectiveFrom, ProdLastSalDt , OFlag, NFlag	From #tmpSTaxMap4Item 
	Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code  And (Active = -1 Or Active = 1) And IsNull(ORemove,0) = 0 And IsNull(NRemove,0) = 0 And IsNull(NewStatus,0) <> 2
	Order By SEffectiveFrom
	
	Open EachTaxItem	
	
	Fetch From EachTaxItem Into @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemSalDt, @OFlag, @NFlag
	Set @PreMapID = Null
	Set @CurTaxID = Null
	while @@Fetch_Status = 0
	Begin
		
		If IsNull(@PreMapID,0) <> 0
			If @PreOFlag = 1
				Update #tmpSTaxMap4Item Set NSEffectiveTo = @NewTaxFrDt - 1 Where MapID = @PreMapID
			Else
				Update #tmpSTaxMap4Item Set NSEffectiveTo = @NewTaxFrDt - 1 Where Recd_MapID = @PreMapID		
		
		Set @PreOFlag = @OFlag
		Set @PreMapID = @Recd_MapID
		
		Fetch Next From EachTaxItem Into  @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemSalDt , @OFlag, @NFlag
	End
	Close EachTaxItem
	DeAllocate EachTaxItem		
	
	/*Validation After Date Calcualtion */
	
	Update ISTM  Set SEffectiveTo = ISTM1.NSEffectiveTo, ModifyDate = GetDate() 
	From ItemsSTaxMap ISTM Join #tmpSTaxMap4Item ISTM1 On ISTM1.MapID = ISTM.MapID 
	And ISTM1.OFlag = 1 And IsNull(ISTM1.ORemove,0) = 0 And IsNull(ISTM1.NRemove,0) = 0 And ISTM1.Active = -1

	Declare EachTaxItem Cursor For 	
	Select Recd_MapID, STaxCode, SEffectiveFrom, ProdLastSalDt , OFlag, NFlag	From #tmpSTaxMap4Item 
	Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code  And Active = 1 And NFlag = 1 And IsNull(ORemove,0) = 0 And IsNull(NRemove,0) = 0 And IsNull(NewStatus,0) = 1
	Order By SEffectiveFrom
	
	Open EachTaxItem		
	
	Fetch From EachTaxItem Into @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemSalDt, @OFlag, @NFlag
	while @@Fetch_Status = 0
	Begin
		Insert Into ItemsSTaxMap (Recd_MapID, Product_Code, STaxCode,CS_TaxCode, SEffectiveFrom,SEffectiveTo)
		Select Recd_MapID, Product_Code, STaxCode,CS_Sal_TaxID, SEffectiveFrom, NSEffectiveTo
		From #tmpSTaxMap4Item Where Recd_MapID = @Recd_MapID
		
		Update Recd_ItemTaxMapping Set Status = 1, AlertCount =1 Where ID = @Recd_MapID

		If @GSTEnable = 1 And (Select SEffectiveFrom From #tmpSTaxMap4Item Where Recd_MapID = @Recd_MapID) <= GetDate()
		Begin
			If IsNull((Select Top 1 STaxCode From #tmpSTaxMap4Item Where Recd_MapID = @Recd_MapID),0) > 0
			Update Items Set Sale_Tax = (Select Top 1 STaxCode From #tmpSTaxMap4Item Where Recd_MapID = @Recd_MapID) 
			Where Product_Code = @Product_Code
		End
		
		Fetch Next From EachTaxItem Into  @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemSalDt , @OFlag, @NFlag
	End
	Close EachTaxItem
	DeAllocate EachTaxItem	

	Insert Into TraceSTaxMap4Item (XML_DocID,Product_Code,CS_Sal_TaxID,STaxCode,STaxEffectiveFrom,SEffectiveFrom,SEffectiveTo,NSEffectiveTo,
	ProdLastSalDt,SStatus,Active,MapID,Recd_MapID,OFlag,NFlag,ORemove,NRemove,OUpdate,NInsert,NewStatus)
	Select XML_DocID,Product_Code,CS_Sal_TaxID,STaxCode,STaxEffectiveFrom,SEffectiveFrom,SEffectiveTo,NSEffectiveTo,
	ProdLastSalDt,SStatus,Active,MapID,Recd_MapID,OFlag,NFlag,ORemove,NRemove,OUpdate,NInsert,NewStatus
	From #tmpSTaxMap4Item
	
	--Select * from Recd_ItemsTaxMap
	--Select * from ItemsSTaxMap
	NextXMLItemsP:	
	---Item Purchase Tax Process

	Select @NewTaxFrDt = PEffectiveFrom,@ItemPurDt = ProdLastPurDt From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code
	
	Select Top 1 @ItemPurDt =  TransDate From #tmpItemsPTran IT Where IT.ItemCode= @Product_Code
	
	If object_id('tempdb..#tmpPTaxMap4Item') is not null
		Drop Table #tmpPTaxMap4Item
	
	Create Table #tmpPTaxMap4Item (
	XML_DocID Int,Product_Code nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,	
	CS_Pur_TaxID Int , PTaxCode Int, PTaxEffectiveFrom DateTime, PEffectiveFrom DateTime, PEffectiveTo DateTime, NPEffectiveTo DateTime, ProdLastPurDt  DateTime,PStatus Int,Active Int,
	MapID Int,Recd_MapID Int,OFlag Int, NFlag Int, ORemove Int, NRemove Int, OUpdate Int, NInsert Int, NewStatus Int
	)
	
	If Not Exists(Select @Product_Code From ItemsPTaxMap Where Product_Code = @Product_Code)
		If Exists(Select IsNull(TaxSuffered,0) From Items Where IsNull(TaxSuffered,0)>0 And Product_Code = @Product_Code)
			Insert Into ItemsPTaxMap (Recd_MapID,Product_Code, PTaxCode, PEffectiveFrom)
				Select 0,Product_Code, TaxSuffered, @OpeningDate From Items Where IsNull(TaxSuffered,0)>0 And Product_Code = @Product_Code
	
	Insert Into #tmpPTaxMap4Item (XML_DocID,OFlag,MapID,Recd_MapID,Product_Code,PTaxCode,PEffectiveFrom,PEffectiveTo,ProdLastPurDt,Active)
	Select @XmlDocNumber,1, MapID,Recd_MapID, @Product_Code,  PTaxCode, PEffectiveFrom, PEffectiveTo,@ItemPurDt ,-1 From ItemsPTaxMap 
	Where Product_Code = @Product_Code And IsNull(PEffectiveTo,GetDate()) >= @ItemPurDt
	
	--Insert Into #tmpPTaxMap4Item (XML_DocID,NFlag,MapID,Recd_MapID,Product_Code,STaxCode,SEffectiveFrom,SEffectiveTo,ProdLastSalDt,Active,NewStatus)
	--Select @XmlDocNumber,1,-1, Recd_MapID,Product_Code ,  STaxCode, SEffectiveFrom, SEffectiveTo,ProdLastSalDt ,Active , 1
	--From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code And Active = 0	
	
	Insert Into #tmpPTaxMap4Item (XML_DocID,NFlag,MapID,Recd_MapID,Product_Code,CS_Pur_TaxID,PTaxCode,PEffectiveFrom,PEffectiveTo,ProdLastPurDt,Active,NewStatus)
	Select @XmlDocNumber,1,-1, Recd_MapID,Product_Code ,CS_Pur_TaxID , PTaxCode, PEffectiveFrom, PEffectiveTo,ProdLastSalDt ,Active , 1
	From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code And Active = 1
	Order By PEffectiveFrom	
	
	Set @MinFrmDt = Null
	Select @MinFrmDt = Min(PEffectiveFrom) From #tmpPTaxMap4Item Where NFlag = 1 And Active = 1
	
	Update #tmpPTaxMap4Item Set ORemove = 1 Where PEffectiveFrom >= @MinFrmDt And OFlag = 1 And Active = -1
	
	Delete From ItemsPTaxMap Where MapID In 
	(Select MapID From #tmpPTaxMap4Item Where Product_Code = @Product_Code And ORemove = 1 And Active =-1 And OFlag = 1)
	
	Update #tmpPTaxMap4Item Set NRemove = 1 Where PEffectiveFrom > ProdLastPurDt And OFlag = 1 And Active = -1 And 
	PTaxCode In (Select PTaxCode From #Recd_ItemsTaxMap Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code And Active = 0)
	
	--Delete From ItemsPTaxMap Where 
	--PTaxCode In (Select PTaxCode From #tmpPTaxMap4Item Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code And NRemove = 1)
	
	Update Recd_ItemTaxMapping Set Status = 4 Where xmlDocNumber = @XmlDocNumber And ProductCode = @Product_Code And Active = 0

	If Not Exists(Select 'x' From #tmpPTaxMap4Item 
		Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code  And Active = 1 And IsNull(ORemove,0) = 0 And IsNull(NRemove,0) = 0)
	Begin
		Update ItemsPTaxMap Set PEffectiveTo = Null, ModifyDate = GetDate()  Where Product_Code = @Product_Code And 
		MapID = IsNull((Select Top 1 MapID From ItemsPTaxMap Where Product_Code = @Product_Code And IsNull(PEffectiveTo,GetDate()) >= @ItemPurDt Order By PEffectiveFrom Desc),0)
		GoTo NextXMLItems
	End
	
	Declare EachTaxItem Cursor For 	
	Select Case When OFlag = 1 Then MapID Else Recd_MapID End, PTaxCode, PEffectiveFrom, ProdLastPurDt , OFlag, NFlag	From #tmpPTaxMap4Item 
	Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code  And (Active = -1 Or Active = 1) And IsNull(ORemove,0) = 0 And IsNull(NRemove,0) = 0
	Order By PEffectiveFrom
	
	Open EachTaxItem	
	
	Fetch From EachTaxItem Into @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemPurDt, @OFlag, @NFlag
	Set @PreMapID = Null
	Set @CurTaxID = Null
	while @@Fetch_Status = 0
	Begin		
		
		If IsNull(@CurTaxID,0) <> 0 And @CurTaxID = @NewTaxID And @NFlag = 1
		Begin
			Update Recd_ItemTaxMapping Set Status = 2 Where ID = @Recd_MapID
			Update #tmpPTaxMap4Item Set NewStatus = 2 Where Recd_MapID = @Recd_MapID
		End
		
		Set @CurTaxID = @NewTaxID
		
		Fetch Next From EachTaxItem Into  @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemPurDt , @OFlag, @NFlag
	End
	Close EachTaxItem
	DeAllocate EachTaxItem	
	
	Declare EachTaxItem Cursor For 	
	Select Case When OFlag = 1 Then MapID Else Recd_MapID End, PTaxCode, PEffectiveFrom, ProdLastPurDt , OFlag, NFlag	From #tmpPTaxMap4Item 
	Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code  And (Active = -1 Or Active = 1) And IsNull(ORemove,0) = 0 And IsNull(NRemove,0) = 0 And IsNull(NewStatus,0) <> 2
	Order By PEffectiveFrom
	
	Open EachTaxItem	
	
	Fetch From EachTaxItem Into @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemPurDt, @OFlag, @NFlag
	Set @PreMapID = Null
	Set @CurTaxID = Null
	while @@Fetch_Status = 0
	Begin
		
		If IsNull(@PreMapID,0) <> 0
			If @PreOFlag = 1
				Update #tmpPTaxMap4Item Set NPEffectiveTo = @NewTaxFrDt - 1 Where MapID = @PreMapID
			Else
				Update #tmpPTaxMap4Item Set NPEffectiveTo = @NewTaxFrDt - 1 Where Recd_MapID = @PreMapID		
		
		Set @PreOFlag = @OFlag
		Set @PreMapID = @Recd_MapID
		
		Fetch Next From EachTaxItem Into  @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemPurDt , @OFlag, @NFlag
	End
	Close EachTaxItem
	DeAllocate EachTaxItem		
	
	/*Validation After Date Calcualtion */
	
	Update ISTM  Set PEffectiveTo = ISTM1.NPEffectiveTo  , ModifyDate = GetDate() 
	From ItemsPTaxMap ISTM Join #tmpPTaxMap4Item ISTM1 On ISTM1.MapID = ISTM.MapID 
	And ISTM1.OFlag = 1 And IsNull(ISTM1.ORemove,0) = 0 And IsNull(ISTM1.NRemove,0) = 0 And ISTM1.Active = -1

	Declare EachTaxItem Cursor For 	
	Select Recd_MapID, PTaxCode, PEffectiveFrom, ProdLastPurDt , OFlag, NFlag	From #tmpPTaxMap4Item 
	Where XML_DocID = @XmlDocNumber And Product_Code = @Product_Code  And Active = 1 And NFlag = 1 And IsNull(ORemove,0) = 0 And IsNull(NRemove,0) = 0 And IsNull(NewStatus,0) = 1
	Order By PEffectiveFrom
	
	Open EachTaxItem		
	
	Fetch From EachTaxItem Into @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemPurDt, @OFlag, @NFlag
	while @@Fetch_Status = 0
	Begin
		Insert Into ItemsPTaxMap (Recd_MapID, Product_Code, PTaxCode,CS_TaxCode, PEffectiveFrom,PEffectiveTo)
		Select Recd_MapID, Product_Code, PTaxCode, CS_Pur_TaxID, PEffectiveFrom, NPEffectiveTo
		From #tmpPTaxMap4Item Where Recd_MapID = @Recd_MapID
		
		Update Recd_ItemTaxMapping Set Status = 1, AlertCount =1 Where ID = @Recd_MapID
		
		If @GSTEnable = 1 And (Select PEffectiveFrom From #tmpPTaxMap4Item Where Recd_MapID = @Recd_MapID) <= GetDate()
		Begin
			If IsNull((Select Top 1 PTaxCode From #tmpPTaxMap4Item Where Recd_MapID = @Recd_MapID),0) > 0
			Update Items Set TaxSuffered = (Select Top 1 PTaxCode From #tmpPTaxMap4Item Where Recd_MapID = @Recd_MapID) 
			Where Product_Code = @Product_Code
		End
		
		Fetch Next From EachTaxItem Into  @Recd_MapID, @NewTaxID, @NewTaxFrDt, @ItemPurDt , @OFlag, @NFlag
	End
	Close EachTaxItem
	DeAllocate EachTaxItem	

	Insert Into TracePTaxMap4Item (
			  XML_DocID,Product_Code,CS_Pur_TaxID,PTaxCode,PTaxEffectiveFrom,PEffectiveFrom,PEffectiveTo,NPEffectiveTo,
			  ProdLastPurDt,PStatus,Active,MapID,Recd_MapID,OFlag,NFlag,ORemove,NRemove,OUpdate,NInsert,NewStatus)
	Select XML_DocID,Product_Code,CS_Pur_TaxID,PTaxCode,PTaxEffectiveFrom,PEffectiveFrom,PEffectiveTo,NPEffectiveTo,
			  ProdLastPurDt,PStatus,Active,MapID,Recd_MapID,OFlag,NFlag,ORemove,NRemove,OUpdate,NInsert,NewStatus
	From #tmpPTaxMap4Item

	--Select * from Recd_ItemsTaxMap
	--Select * from ItemsPTaxMap	

	NextXMLItems:
	--If object_id('tempdb..#tmpSTaxMap4Item') is not null	
	--	Begin
	--	--Select XML_DocID,MapID ,Recd_MapID ,OFlag , NFlag , ORemove , NRemove , OUpdate , NInsert , NewStatus, * from #tmpSTaxMap4Item	
	--	Insert Into #tmpSTaxMap4ItemX Select * From #tmpSTaxMap4Item
	--	End
	--If object_id('tempdb..#tmpPTaxMap4Item') is not null	
	--	Begin
	--	--Select XML_DocID,MapID ,Recd_MapID ,OFlag , NFlag , ORemove , NRemove , OUpdate , NInsert , NewStatus, * from #tmpPTaxMap4Item	
	--	Insert Into #tmpPTaxMap4ItemX Select * From #tmpPTaxMap4Item
	--	End	
	Fetch Next From EachXMLItems Into @XmlDocNumber,@Product_Code 
End
Close EachXMLItems
DeAllocate EachXMLItems
--Select XML_DocID,MapID ,Recd_MapID ,OFlag , NFlag , ORemove , NRemove , OUpdate , NInsert , NewStatus, * from #tmpSTaxMap4ItemX
--Select XML_DocID,MapID ,Recd_MapID ,OFlag , NFlag , ORemove , NRemove , OUpdate , NInsert , NewStatus, * from #tmpPTaxMap4ItemX

--Select Recd_MapID, XML_DocID, Product_Code,
----CS_Sal_TaxID, STaxCode, STaxEffectiveFrom, SEffectiveFrom , SEffectiveTo , ProdLastSalDt, SStatus ,
--CS_Pur_TaxID, PTaxCode, PTaxEffectiveFrom, PEffectiveFrom , PEffectiveTo, ProdLastPurDt, PStatus,
--OpeningDt ,SetupTranDt ,DayCloseDt ,Active from #Recd_ItemsTaxMap 

--	Select * from #Recd_ItemsTaxMap 
--	Select * from #tmpItemTrans	

	Drop Table #Recd_ItemsTaxMap 
	Drop Table #tmpItemTrans
	Drop Table #tmpItems
	Drop Table #tmpItemsSTran
	Drop Table #tmpItemsPTran	
	--Drop Table #tmpSTaxMap4ItemX
	--Drop Table #tmpPTaxMap4ItemX
End
