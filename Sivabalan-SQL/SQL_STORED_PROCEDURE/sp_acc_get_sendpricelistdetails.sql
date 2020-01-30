CREATE Procedure sp_acc_get_sendpricelistdetails 
(@DetailsReqd INT,@Existing INT,@DocumentID INT,@SendPriceListDate Datetime = null)
As
SET DATEFORMAT DMY
/*
	@DetailsReqd = 1 - Customer / Branch Details
	@DetailsReqd = 2 - Itemdetails

	If @Existing = 1 then get the details from already Sent Price List Table
	If @Existing = 0 then Get the details from PriceList tables
	If @Existing = 0 then @DocumentID refers to PriceListID
*/
if @DetailsReqd = 0
Begin
	/* No @Existing = 0 mode coz , the Price List descirirtion has to be keyed in by the user */
	if @Existing = 1
	Begin
		Select PL.PriceListName as PriceListName,SPL.PriceListID as PriceListID from PriceList PL , SendPriceList SPL
		Where PL.PriceListID = SPL.PriceListID
		and SPL.DocumentID = @DocumentID
	End
End
Else if @DetailsReqd = 1
Begin
	If @Existing = 0 
	Begin
		if (Select PriceListFor from PRICELIST Where PriceListID = @DocumentID) = 0
		Begin
			Select PLB.BranchID,C.Company_Name as Branch_Name from 
			PriceListBranch PLB,Customer C
			Where PLB.BranchID = C.CustomerID
			and PLB.PriceListID = @DocumentID
		End
		Else
		Begin
			Select PLB.BranchID,W.Warehouse_Name as Branch_Name from 
			PriceListBranch PLB,Warehouse W
			Where PLB.BranchID = W.WarehouseID
			and PLB.PriceListID = @DocumentID
		End
	End
	Else if @Existing = 1 
	Begin
		if (Select PriceListFor from SendPriceList Where DocumentID = @DocumentID) = 0
		Begin
			Select SPLB.BranchID,C.Company_Name as Branch_Name from 
			SendPriceListBranch SPLB,Customer C
			Where SPLB.BranchID = C.CustomerID
			and SPLB.DocumentID = @DocumentID
		End
		Else
		Begin
			Select SPLB.BranchID,W.Warehouse_Name as Branch_Name from 
			SendPriceListBranch SPLB,Warehouse W
			Where SPLB.BranchID = W.WarehouseID
			and SPLB.DocumentID = @DocumentID
		End
	End
End
else if @DetailsReqd = 2
Begin
	If @Existing = 0 
	Begin
		Declare @MaxPriceListDate Datetime
		Declare @PriceListCnt INT
		Declare @Cust_BR INT

		select @Cust_BR = PriceListFor from PriceList where PriceListID = @DocumentID

		Select 	@MaxPriceListDate = isnull(Max(PriceListDate),@SendPriceListDate) 
		from 	SendPriceList 
		where 	PriceListId = @DocumentID and PriceListDate <= @SendPriceListDate
		and PriceListFor = @Cust_BR

		Select 	@PriceListCnt = count(1) from SendPriceList 
		where 	PriceListDate = @MaxPriceListDate and PriceListFor = @Cust_BR
		and PriceListID = @DocumentID

		CREATE TABLE #ItemDetails
		(Row_Num INT identity,Product_Code nVarChar(50),ProductName nVarChar(255),
		PTS Decimal(18,6), PTR Decimal(18,6),
		ECP Decimal(18,6), Purchase_Price Decimal(18,6),
		Sale_Price Decimal(18,6), MRP Decimal(18,6),
		Company_Price Decimal(18,6),Tax_Suffered nVarChar(255), Tax_Applicable nVarChar(255))

		If @PriceListCnt > 0 
		Begin
			Declare @ItemCode nVarChar(255)
			/* Process:
				1.Get the ItemCodes available in PriceListItem basis the PricelistID
				2.Create a Cursor on the Above
				3.Check if any entry available in SendPriceListItem for the Particular Item code 
				  and for a Particular Customer / Branch
				4.If available Get the TOP row.
				5.If not available get the details from Item Master
				This is applicable only for New Price List sending .For existing get the details 
				from the Send Price List Item Table
			*/
			Declare Items Cursor  for
			Select Product_Code from PriceListItem
			Where PriceListID = @DocumentID
			Open Items
			Fetch from Items INTo @ItemCode
			While @@Fetch_Status = 0 
			Begin
				if (Select count(1) from SendPriceListItem where Product_Code = @ItemCode 
					and DocumentID in (Select DocumentID from SendPriceList where 
					PriceListFor = @Cust_BR and PriceListDate = @MaxPriceListDate)) > 0 
				Begin
					Insert INTo #ItemDetails
					(Product_Code ,PTS ,PTR ,ECP ,Purchase_Price ,Sale_Price , 
					MRP ,Company_Price ,Tax_Suffered ,Tax_Applicable ,ProductName)
					Select Top 1 SPL.Product_Code, SPL.PTS, SPL.PTR, SPL.ECP, SPL.PurchasePrice, 
					SPL.SellingPrice, SPL.MRP, SPL.SpecialPrice, -- SPL.TaxSuffered, SPL.TaxApplicable ,
					isnull((Select Tax_Description from Tax where Tax_Code in 
					(Select TaxSuffered from PriceListItem 
					Where PriceListId = @DocumentID and Product_Code = @ItemCode)),N''),
					isnull((Select Tax_Description from Tax where Tax_Code in 
					(Select TaxApplicable from PriceListItem 
					Where PriceListId = @DocumentID and Product_Code = @ItemCode)),N''),
					I.ProductName
					from SendPriceListItem SPL,Items I
					Where DocumentID in (Select DocumentID from SendPriceList where 
					PriceListFor = @Cust_BR) and SPL.Product_Code = @ItemCode
					and SPL.Product_Code = I.Product_Code
					Order by DocumentID Desc
				End
				Else
				Begin
					Insert INTo #ItemDetails
					(Product_Code ,PTS ,PTR ,ECP ,Purchase_Price ,Sale_Price , 
					MRP ,Company_Price ,Tax_Suffered ,Tax_Applicable ,ProductName)
					Select PLI.Product_Code,
					I.PTS,I.PTR,I.ECP,I.Purchase_Price,I.Sale_Price,I.MRP,I.Company_Price as "Special_Price",
					isnull((Select Tax_Description from Tax where Tax_Code = PLI.TaxSuffered),N'') as "Tax_Suffered",
					isnull((Select Tax_Description from Tax where Tax_Code = PLI.TaxApplicable),N'') as "Tax_Applicable",
					I.ProductName
					From PriceListItem PLI,Items I
					where 
					PLI.PriceListID = @DocumentID
					and PLI.Product_Code = @ItemCode
					and PLI.Product_Code = I.Product_Code
				End
	  		FETCH NEXT FROM Items INTO @ItemCode
			End
			Select Product_Code, ProductName, PTS, PTR, ECP, Purchase_Price,
			Sale_Price, MRP, Company_Price as "Special_Price", Tax_Suffered, Tax_Applicable from 
			#ItemDetails order by Row_Num
			CLOSE Items                
			DEALLOCATE Items
		End
		Else
		Begin
			Insert INTo #ItemDetails
			(Product_Code ,PTS ,PTR ,ECP ,Purchase_Price ,Sale_Price , 
			MRP ,Company_Price ,Tax_Suffered ,Tax_Applicable ,ProductName)
			Select PLI.Product_Code,
			I.PTS,I.PTR,I.ECP,I.Purchase_Price,I.Sale_Price,I.MRP,I.Company_Price as "Special_Price",
			isnull((Select Tax_Description from Tax where Tax_Code = PLI.TaxSuffered),N'') as "Tax_Suffered",
			isnull((Select Tax_Description from Tax where Tax_Code = PLI.TaxApplicable),N'') as "Tax_Applicable",
			I.ProductName
			From PriceListItem PLI,Items I
			where 
			PLI.PriceListID = @DocumentID
			and PLI.Product_Code = I.Product_Code

			Select Product_Code, ProductName, PTS, PTR, ECP, Purchase_Price,
			Sale_Price, MRP, Company_Price as "Special_Price", Tax_Suffered, Tax_Applicable from 
			#ItemDetails order by Row_Num
		End
		Drop Table #ItemDetails
	End
	Else if @Existing = 1
	Begin
		Select I.ProductName,SPLI.Product_Code,
		SPLI.PTS, SPLI.PTR, SPLI.ECP, SPLI.PurchasePrice as "Purchase_Price", 
		SPLI.SellingPrice as "Sale_Price", SPLI.MRP,SPLI.SpecialPrice as "Special_Price",
		isnull((Select Tax_Description from Tax where Tax_Code = SPLI.TaxSuffered),N'') as "Tax_Suffered",
		isnull((Select Tax_Description from Tax where Tax_Code = SPLI.TaxApplicable),N'') as "Tax_Applicable"
		From SendPriceListItem SPLI,Items I
		where 
		SPLI.DocumentID = @DocumentID
		and SPLI.Product_Code = I.Product_Code
	End
End
