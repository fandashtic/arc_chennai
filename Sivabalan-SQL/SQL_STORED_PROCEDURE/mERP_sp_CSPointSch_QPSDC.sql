Create Procedure mERP_sp_CSPointSch_QPSDC(@LeastSchEntryDate datetime, @LastDayClose datetime)
as
Begin
	/*Point Scheme QPS data posting*/
	--Last Invoiced date
	Declare @TransDate Datetime 
	Select @TransDate = TransactionDate From Setup 
	Declare @LastInvDate DateTime 
	Select @LastInvDate = Case IsNull(Max(InvoiceDate),'') When '' Then GETDATE() Else Max(InvoiceDate) End  
		From InvoiceAbstract where InvoiceType In (1,2,3) And (Status & 128)=0    

	--Cur_SchInfo values
	Declare @SchID Int
	Declare @PayoutID int
	Declare @PayoutFrom DateTime 
	Declare @PayoutTo DateTime 
	Declare @ApplicableOn Int 
	Declare @ItemGrp Int 
	Declare @ActiveFrom DateTime 
	Declare @ActiveTo DateTime 
	Declare @ExpiryDate DateTime 
	--Cur_SlabInfo values
	Declare @SlabGrpID Int
	Declare @SlabID Int 
	Declare @SlabUOM int 
	Declare @SlabOnward Decimal(18,6)
	Declare @SlabValue Decimal(18,6)
	Declare @UnitRate Decimal(18,6)
	Declare @SlabStart Decimal(18,6)
	Declare @SlabEnd Decimal(18,6)

	Declare Cur_SchInfo Cursor For
	Select Distinct SchAbs.SchemeID, SchPP.ID, SchPP.PayoutPeriodFrom, SchPP.PayoutPeriodTo,
	SchAbs.ApplicableOn , SchAbs.ItemGroup, SchAbs.ActiveFrom, SchAbs.ActiveTo, SchAbs.ExpiryDate
	From tbl_mERP_SchemeAbstract SchAbs, tbl_mERP_SchemeOutlet SchOtl, tbl_mERP_SchemePayoutPeriod SchPP
	Where SchAbs.SchemeID = SchOtl.SchemeID And 
	  SchAbs.SchemeID = SchPP.SchemeID And 
	  dbo.StripTimeFromDate(SchPP.PayoutPeriodTo) <= @LastDayClose And
	  dbo.StripTimeFromDate(SchPP.PayoutPeriodTo) <= dbo.StripTimeFromDate(@LastInvDate) And
	  dbo.StripTimeFromDate(SchPP.PayoutPeriodFrom) >= dbo.StripTimeFromDate(@LeastSchEntryDate) and 
	  SchOtl.QPS = 1 And SchAbs.Active = 1 And 
	  SchPP.Active = 1 And SchPP.Status & 128= 0 And SchPP.ClaimRFA = 0 And
	  SchAbs.SchemeType = 4
	Open Cur_SchInfo 
	Fetch Next From Cur_SchInfo into @SchID, @PayoutID, @PayoutFrom, @PayoutTo, @ApplicableOn, @ItemGrp, @ActiveFrom, @ActiveTo, @ExpiryDate
	While (@@Fetch_status = 0)
		Begin
				
			--Get the Customer Scope
			Declare @SchemeOutlet table (CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupID Int,Qps Int)
			Delete from @SchemeOutlet
			Insert into @SchemeOutlet (CustomerID,GroupID,Qps)
			select CustomerId,GroupID,QPS from dbo.mERP_fn_GetSchemeOutletDetails(@SchID) Where QPS = 1 

			--To delete the data if already exists
			Delete from tbl_mERP_CSOutletPointAbstract Where SchemeID = @SchID and PayoutId = @PayoutID and QPS = 1 

			Delete from tbl_mERP_CSOutletPointDetail 
			Where SchemeID = @SchID and PayoutId = @PayoutID and GroupId in (
				Select Distinct SSG.SubGroupID from tbl_mERP_SchemeOutlet SOL, tbl_mERP_SchemeSubGroup SSG
				Where SOL.SchemeID = @SchID and SOL.SchemeID = SSG.SchemeID and  SOL.GroupID = SSG.SubGroupId and SOL.QPS = 1)


			If @ApplicableOn = 2	--Invoice based scheme
			Begin
				--Point scheme Detail data
				Insert into tbl_mERP_CSOutletPointDetail(SchemeId, PayoutID, GroupId, InvoiceID, InvoiceDate, InvoiceType, OutletCode, Product_Code,BaseUOMQty,Uom1Qty,Uom2Qty,SaleAmount,TaxAmount,Amount, InvCreationTime)
				Select @SchID, @PayoutID, SchCust.GroupId, IA.InvoiceID, IA.InvoiceDate, IA.InvoiceType, IA.CustomerId, ID.Product_Code, Sum(ID.Quantity) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) BaseUOMQty, 
				Sum(ID.Quantity / IsNull(I.UOM1_Conversion,1)) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) UOM1Qty, 
				Sum(ID.Quantity / IsNull(I.UOM2_Conversion,1)) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) UOM2Qty, 
				Sum(ID.Quantity * ID.SalePrice) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) SaleAmount, 
				Sum(ID.TaxAmount) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) TaxAmount, 
				Sum(ID.Amount) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) Amount, IA.CreationTime
				From InvoiceAbstract IA,  InvoiceDetail ID, Items I, @SchemeOutlet SchCust
				Where IA.InvoiceID = ID.InvoiceID And IA.InvoiceType in(1,3,4) and IA.Status & 128 = 0 And Isnull(ID.FlagWord,0) = 0 
				And dbo.StripTimeFromDate(IA.Invoicedate) between @ActiveFrom and @ActiveTo
				And dbo.StripTimeFromDate(IA.Invoicedate) between dbo.StripTimeFromDate(@PayoutFrom) and dbo.StripTimeFromDate(@PayoutTo)
				And I.Product_Code = ID.Product_Code
				And SchCust.CustomerID = IA.CustomerID
				Group by SchCust.GroupId, IA.InvoiceID, IA.InvoiceDate, IA.InvoiceType, IA.CustomerId, ID.Product_Code, IA.CreationTime
			End
			Else if @ApplicableOn = 1 -- Item Based 
			Begin
				--Product Scope			
				Declare @SchemeProducts as Table(SchemeID Int, Product_Code  nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,GroupID Int)
				Delete from @SchemeProducts
				Insert into @SchemeProducts(SchemeID, Product_Code)
				Select SchemeID, Product_Code From dbo.mERP_fn_Get_CSSku(@SchID)

				--Point Scheme Detail data
				Insert into tbl_mERP_CSOutletPointDetail(SchemeId, PayoutID, GroupId, InvoiceID, InvoiceDate, InvoiceType, OutletCode, Product_Code,BaseUOMQty,Uom1Qty,Uom2Qty,SaleAmount,TaxAmount,Amount, InvCreationTime)
				Select @SchID, @PayoutID, SchCust.GroupId, IA.InvoiceID, IA.InvoiceDate, IA.InvoiceType, IA.CustomerId, ID.Product_Code, Sum(ID.Quantity) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) BaseUOMQty, 
				Sum(ID.Quantity / IsNull(I.UOM1_Conversion,1)) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) UOM1Qty, 
				Sum(ID.Quantity / IsNull(I.UOM2_Conversion,1)) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) UOM2Qty, 
				Sum(ID.Quantity * ID.SalePrice) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) SaleAmount, 
				Sum(ID.TaxAmount) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) TaxAmount, 
				Sum(ID.Amount) * (Case IA.InvoiceType When 4 Then -1 Else 1 End) Amount, IA.CreationTime
				From InvoiceAbstract IA,  InvoiceDetail ID, Items I, @SchemeOutlet SchCust, @SchemeProducts SchProd	
				Where IA.InvoiceID = ID.InvoiceID And IA.InvoiceType in(1,3,4) and IA.Status & 128 = 0 And Isnull(ID.FlagWord,0) = 0 
				And dbo.StripTimeFromDate(IA.Invoicedate) between @ActiveFrom and @ActiveTo
				And dbo.StripTimeFromDate(IA.Invoicedate) between dbo.StripTimeFromDate(@PayoutFrom) and dbo.StripTimeFromDate(@PayoutTo)
				And I.Product_Code = SchProd.Product_code 
				And SchProd.Product_code = ID.Product_Code
				And SchCust.CustomerID = IA.CustomerID
				Group by SchCust.GroupId, IA.InvoiceID, IA.InvoiceDate, IA.InvoiceType, IA.CustomerId, ID.Product_Code, IA.CreationTime
			End

			--Invoice Based Sch
			If @ApplicableOn = 2 
			Begin
				--Slabwise Points calculation
				Set @SlabGrpID  = 0 
				Set @SlabID = 0 
				Set @SlabUOM = 0  
				Set @SlabOnward = 0 
				Set @SlabValue = 0 
				Set @UnitRate = 0 
				Set @SlabStart = 0 
				Set @SlabEnd = 0 

				Declare Cur_SlabInfo Cursor For 
				Select GroupID, SlabID, UOM, Onward, [Value], UnitRate, SlabStart, SlabEnd
				From tbl_mERP_SchemeSlabDetail 
				Where SchemeID = @SChID 
				Open Cur_SlabInfo
				Fetch Next From Cur_SlabInfo into @SlabGrpID, @SlabID, @SlabUOM , @SlabOnward, @SlabValue, @UnitRate, @SlabStart, @SlabEnd
				While (@@Fetch_Status = 0)
				Begin
					Insert into tbl_mERP_CSOutletPointAbstract(SchemeId, PayoutID, QPS, SlabID, OutletCode,  Points, Rate, TransactionDate)
					Select SchemeID, @PayoutID, 1, @SlabID, OutletCode, 
							(Case  @SlabOnward When 0 Then @SlabValue Else Cast((Sum(Amount)/@SlabOnward) as Int) * @SlabValue End) as Points, @UnitRate, @TransDate
					From tbl_mERP_CSOutletPointDetail CSPD, @SchemeOutlet C
					Where SchemeID = @SchId and PayoutID = @payoutID and CSPD.GroupID = @SlabGrpID and OutletCode = CustomerID
					Group by SchemeID, PayoutID, CSPD.GroupID, OutletCode
					Having Sum(Amount) between @SlabStart and @SlabEnd
					Fetch Next From Cur_SlabInfo into @SlabGrpID, @SlabID, @SlabUOM , @SlabOnward, @SlabValue, @UnitRate, @SlabStart, @SlabEnd	
				End
				Close Cur_SlabInfo
				Deallocate Cur_SlabInfo 
			End
			Else if @ApplicableOn = 1	--Item based schemes
			Begin

				--Slab base Points calculation
				Set @SlabGrpID  = 0 
				Set @SlabID = 0 
				Set @SlabUOM = 0  
				Set @SlabOnward = 0 
				Set @SlabValue = 0 
				Set @UnitRate = 0 
				Set @SlabStart = 0 
				Set @SlabEnd = 0 
				Declare Cur_SlabInfo Cursor For 
				Select GroupID, SlabID, UOM, Onward, [Value], UnitRate, SlabStart, SlabEnd
				From tbl_mERP_SchemeSlabDetail 
				Where SchemeID = @SChID 
				Open Cur_SlabInfo
				Fetch Next From Cur_SlabInfo into @SlabGrpID, @SlabID, @SlabUOM , @SlabOnward, @SlabValue, @UnitRate, @SlabStart, @SlabEnd
				While (@@Fetch_Status = 0)
				Begin
					If @SlabUOM = 4 --Value Based 
						Begin
							If @ItemGrp = 1	-- Item based
								Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate)
								Select SchemeID, @PayoutID, 1, @SlabID, OutletCode,  
										(Case  @SlabOnward When 0 Then @SlabValue Else Cast((Sum(Amount)/@SlabOnward) as Int) * @SlabValue End) as Points, @UnitRate, @TransDate
								From tbl_mERP_CSOutletPointDetail CSPD,  @SchemeOutlet
								Where SchemeID = @SchId and PayoutID = @payoutID and CSPD.GroupID = @SlabGrpID and OutletCode = CustomerID
								Group by OutletCode, SchemeID, PayoutID, CSPD.GroupId, OutletCode, Product_Code
								Having Sum(Amount) between @SlabStart and @SlabEnd
							Else If @ItemGrp = 2 --Spl Category
								Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate)
								Select SchemeID, PayoutID, 1, @SlabID, OutletCode,  
										(Case  @SlabOnward When 0 Then @SlabValue Else Cast((Sum(Amount)/@SlabOnward) as Int) * @SlabValue End) as Points, @UnitRate, @TransDate
								From tbl_mERP_CSOutletPointDetail CSPD, @SchemeOutlet
								Where SchemeID = @SchId and PayoutID = @payoutID and CSPD.GroupID = @SlabGrpID and OutletCode = CustomerID
								Group by OutletCode, SchemeID, PayoutID, CSPD.GroupId, OutletCode
								Having Sum(Amount) between @SlabStart and @SlabEnd
						End
					Else --Quantity based
						Begin
							If @ItemGrp = 1	-- Item based
								Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate)
								Select SchemeID, @PayoutID, 1, @SlabID, OutletCode, 
										(Case @SlabOnward When 0 Then (Case @SlabUOM when 1 then Sum(BaseUOMQty) when 2 then Sum(UOM1Qty) else Sum(UOM2Qty) End)
										Else Cast(((case @SlabUOM when 1 then Sum(BaseUOMQty) when 2 then Sum(Uom1QTY) else Sum(UOM2Qty) end)/@SlabOnward) as Int) * @SlabValue End) as Points, @UnitRate, @TransDate
								From tbl_mERP_CSOutletPointDetail CSPD, @SchemeOutlet
								Where SchemeID = @SchId and PayoutID = @payoutID and CSPD.GroupID = @SlabGrpID and OutletCode = CustomerID
								Group by OutletCode, SchemeID, PayoutID, CSPD.GroupId, OutletCode, Product_Code
								Having (Case @SlabUOM when 1 then Sum(BaseUOMQty) when 2 then Sum(UOM1Qty) else Sum(UOM2Qty) End) Between @SlabStart and @SlabEnd
							Else If @ItemGrp = 2 --Spl Category
								Insert into tbl_mERP_CSOutletPointAbstract(SchemeID, PayoutID,	QPS, SlabID, OutletCode, Points, Rate, TransactionDate)
								Select SchemeID, @PayoutID, 1, @SlabID, OutletCode, 
										(Case @SlabOnward When 0 Then (Case @SlabUOM when 1 then Sum(BaseUOMQty) when 2 then Sum(UOM1Qty) else Sum(UOM2Qty) End)
										Else Cast(((case @SlabUOM when 1 then Sum(BaseUOMQty) when 2 then Sum(Uom1QTY) else Sum(UOM2Qty) end)/@SlabOnward) as Int) * @SlabValue End) as Points, @UnitRate, @TransDate
								From tbl_mERP_CSOutletPointDetail CSPD, @SchemeOutlet
								Where SchemeID = @SchId and PayoutID = @payoutID and CSPD.GroupID = @SlabGrpID and OutletCode = CustomerID
								Group by OutletCode, SchemeID, PayoutID, CSPD.GroupId, OutletCode
								Having (Case @SlabUOM when 1 then Sum(BaseUOMQty) when 2 then Sum(UOM1Qty) else Sum(UOM2Qty) End) Between @SlabStart and @SlabEnd
						End 
					Fetch Next From Cur_SlabInfo into @SlabGrpID, @SlabID, @SlabUOM , @SlabOnward, @SlabValue, @UnitRate, @SlabStart, @SlabEnd	
				End
				Close Cur_SlabInfo
				Deallocate Cur_SlabInfo 
			End
			Update tbl_mERP_SchemePayoutPeriod Set Status = 128 Where ID= @PayoutID and SchemeID = @SchID
			Fetch Next From Cur_SchInfo into @SchID, @PayoutID, @PayoutFrom, @PayoutTo, @ApplicableOn, @ItemGrp, @ActiveFrom, @ActiveTo, @ExpiryDate  
		End
	Close Cur_SchInfo
	Deallocate Cur_SchInfo
End
