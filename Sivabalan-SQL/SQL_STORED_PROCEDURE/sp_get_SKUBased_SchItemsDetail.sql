Create Procedure sp_get_SKUBased_SchItemsDetail(@SchemeID Int,@SchemeCode as nVarchar(255),
@SlabType Int,@SlabID Int,@ItemCode as nVarchar(30), @Mode Int = 0)  
As
Begin
	Declare @UOM1_CONV as Decimal(18,6)       
	Declare @UOM2_CONV as Decimal(18,6) 
	
	Select @UOM1_CONV = UOM1_Conversion,  @UOM2_CONV = UOM2_Conversion From Items Where Product_code = @ItemCode  
	
	If @SlabType = 3 -- ItemBased Free Item Scheme
	Begin
		If @Mode = 1 -- For VanLoading Slip QPS consideration
		Begin
		Select 
				SSLAB.SchemeID,
				(Case IsNull(UOM,0)         
					When 1 then SlabStart        
					When 2 then SlabStart * @UOM1_CONV      
					When 3 then SlabStart * @UOM2_CONV 
					When 4 then SlabStart
				 End 
				) StartValue,
				(Case IsNull(UOM,0)         
					When 1 then SlabEnd        
					When 2 then SlabEnd * @UOM1_CONV      
					When 3 then SlabEnd * @UOM2_CONV 
					When 4 then SlabEnd        
					End 
				) EndValue,

--				(Case IsNull(FreeUOM,0)         
--					When 1 then Volume         
--					When 2 then Volume * IsNull((Select IsNull(Uom1_conversion,1) From Items Where Product_code = FreeSKU.SKUCode),1)        
--					When 3 then Volume * IsNull((Select IsNull(Uom2_conversion,1) From Items Where Product_code = FreeSKU.SKUCode),1) End 
--				) FreeValue  ,
				isNull(Volume,0),
				'' as SKUCode,isNull(UOM,0) As UOM, isNull(FreeUOM,0) as FreeUOM,
				(Case IsNull(UOM,0)         
					When 1 then isNull(Onward,0)
					When 2 then isNull(Onward,0) * @UOM1_CONV      
					When 3 then isNull(Onward,0) * @UOM2_CONV 
					When 4 then isNull(Onward,0)
				End
				) Onward,isNull(SlabType,0) as SlabType
		From 
			tbl_mERP_SchemeSlabDetail SSLAB, tbl_mERP_SchemeOutlet SO
		Where 
			SSLAB.SchemeID = @SchemeID And
			SSLAB.SlabID = @SlabID And
			SSLAB.SlabType = @SlabType And
            SSLAB.GroupID = SO.GroupID And 
            SSLAB.SchemeID = SO.SchemeID And
            SO.QPS = 0 
        End
        Else
        Begin
		Select 
				SchemeID,
				(Case IsNull(UOM,0)         
					When 1 then SlabStart        
					When 2 then SlabStart * @UOM1_CONV      
					When 3 then SlabStart * @UOM2_CONV 
					When 4 then SlabStart
				 End 
				) StartValue,
				(Case IsNull(UOM,0)         
					When 1 then SlabEnd        
					When 2 then SlabEnd * @UOM1_CONV      
					When 3 then SlabEnd * @UOM2_CONV 
					When 4 then SlabEnd        
					End 
				) EndValue,

--				(Case IsNull(FreeUOM,0)         
--					When 1 then Volume         
--					When 2 then Volume * IsNull((Select IsNull(Uom1_conversion,1) From Items Where Product_code = FreeSKU.SKUCode),1)        
--					When 3 then Volume * IsNull((Select IsNull(Uom2_conversion,1) From Items Where Product_code = FreeSKU.SKUCode),1) End 
--				) FreeValue  ,
				isNull(Volume,0),
				'' as SKUCode,isNull(UOM,0) As UOM, isNull(FreeUOM,0) as FreeUOM,
				(Case IsNull(UOM,0)         
					When 1 then isNull(Onward,0)
					When 2 then isNull(Onward,0) * @UOM1_CONV      
					When 3 then isNull(Onward,0) * @UOM2_CONV 
					When 4 then isNull(Onward,0)
				End
				) Onward,isNull(SlabType,0) as SlabType
		From 
			tbl_mERP_SchemeSlabDetail SSLAB
		Where 
			SSLAB.SchemeID = @SchemeID And
			SSLAB.SlabID = @SlabID And
			SSLAB.SlabType = @SlabType 
		End	
	End
	Else if (@SlabType = 1 Or @SlabType = 2)
	Begin
		--Item Based Amount And Percentage schemes 
		Select 
				SchemeID,
				(Case IsNull(UOM,0)         
					When 1 then SlabStart        
					When 2 then SlabStart * @UOM1_CONV      
					When 3 then SlabStart * @UOM2_CONV 
					When 4 then SlabStart        
					End 
				) StartValue,
				(Case IsNull(UOM,0)         
					When 1 then SlabEnd        
					When 2 then SlabEnd * @UOM1_CONV      
					When 3 then SlabEnd * @UOM2_CONV 
					When 4 then SlabEnd        
					End 
				) EndValue,
				Value As FreeValue  ,
				'' as SKUCode,isNull(UOM,0) As UOM, isNull(FreeUOM,0) as FreeUOM  ,
				(Case IsNull(UOM,0)         
					When 1 then isNull(Onward,0)
					When 2 then isNull(Onward,0) * @UOM1_CONV      
					When 3 then isNull(Onward,0) * @UOM2_CONV  
					When 4 then isNull(Onward,0)
				End
				) Onward,isNull(SlabType,0) as SlabType
		From 
			tbl_mERP_SchemeSlabDetail SSLAB
		Where 
			SSLAB.SchemeID = @SchemeID And
			SSLAB.SlabID = @SlabID And
			SSLAB.SlabType = @SlabType 
	End
End
