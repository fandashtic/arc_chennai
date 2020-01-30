CREATE Procedure mERP_sp_GetInvDispatch_SchSlabDetails
(@SchemeID Int,@BaseQty Decimal(18,6),@UOM1Qty Decimal(18,6),
@UOM2Qty Decimal(18,6),@Amount Decimal(18,6), @OutletID as nvarchar(30)=N'',@GroupID Int = -1, @TaxAmt as Decimal(18,6)=0
)
As
Begin
		    Create Table #tmpSlab(SlabType Int,UOM Int,SlabStart Decimal(18,6),SlabEnd Decimal(18,6),
			Freeuom Int,Onward Decimal(18,6),SlabID Int,Volume Decimal(18,6),Value Decimal(18,6))
			
			
				Insert Into #tmpSlab
				--check for Quantity Based slab
				Select SlabType,isNull(UOM,0) As UOM,SlabStart,SlabEnd,isNull(FreeUOM,0) as FreeUOM,
				isNull(Onward,0) as Onward,SlabID,isNull(Volume,0),isNull(Value,0)
				From 
				tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeSlabDetail SSLAB
				Where SA.SchemeID = @SchemeID And
				SA.SchemeID = SSLAB.SchemeID And
				SSLAB.UOM = 1 And  SSLAB.slabtype<>3 and 
				SSLAB.GroupID =  @GroupID And
				(@BaseQty Between SlabStart And SlabEnd)And
				@BaseQty >= isNull(OnWard,0)
				
				Union
				

				Select SlabType,isNull(UOM,0) As UOM,SlabStart,SlabEnd,isNull(FreeUOM,0) as FreeUOM,
				isNull(Onward,0) as Onward,SlabID,isNull(Volume,0),isNull(Value,0)
				From 
				tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeSlabDetail SSLAB
				Where SA.SchemeID = @SchemeID And
				SA.SchemeID = SSLAB.SchemeID And
				SSLAB.UOM = 2 And SSLAB.slabtype<>3 and   
				SSLAB.GroupID =  @GroupID And
				(@UOM1Qty Between SlabStart And SlabEnd) And
				@UOM1Qty >= isNull(OnWard,0)
				
				Union
				
				Select SlabType,isNull(UOM,0) As UOM,SlabStart,SlabEnd,isNull(FreeUOM,0) as FreeUOM,
				isNull(Onward,0) as Onward,SlabID,isNull(Volume,0),isNull(Value,0)
				From 
				tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeSlabDetail SSLAB
				Where SA.SchemeID = @SchemeID And
				SA.SchemeID = SSLAB.SchemeID And
				SSLAB.UOM = 3 And  SSLAB.slabtype<>3 and 
				SSLAB.GroupID =  @GroupID And
				(@UOM2Qty Between SlabStart And SlabEnd) And
				@UOM2Qty >= isNull(OnWard,0)
				
				Union 
				
				Select SlabType,isNull(UOM,0) As UOM,SlabStart,SlabEnd,isNull(FreeUOM,0) as FreeUOM,
				isNull(Onward,0) as Onward,SlabID,isNull(Volume,0),isNull(Value,0)
				From 
				tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemeSlabDetail SSLAB
				Where SA.SchemeID = @SchemeID And
				SA.SchemeID = SSLAB.SchemeID And
				SSLAB.UOM = 4 And SSLAB.slabtype<>3 and   
				SSLAB.GroupID =  @GroupID And
				(@TaxAmt Between SlabStart And SlabEnd)	And 	
				@TaxAmt >= isNull(OnWard,0)
			
			Select Top 1 * From #tmpSlab Order By SlabID

End
