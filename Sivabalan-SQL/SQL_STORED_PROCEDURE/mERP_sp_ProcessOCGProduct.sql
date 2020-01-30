Create Procedure mERP_sp_ProcessOCGProduct(@REC_OCGID Int)
As
Begin
	Declare @ErrorStatus as Int
	Declare @ErrorMessage as Nvarchar(4000)
	Declare @D_OCGCode as Nvarchar(15)

	--Validate OCG Name:
	If (Select Count(*) From Recd_OCG_Product Where  RecdID = @REC_OCGID and Isnull(OCGCode,'') = '') > 0
		Begin
			Set @ErrorStatus =1
			Set @ErrorMessage = 'Unable To Process Blank OCGCode'
			Exec mERP_sp_Update_OCGErrorStatus @REC_OCGID,@ErrorMessage
			Update Recd_OCG_Product Set status = 2 Where RecdID = @REC_OCGID and Isnull(OCGCode,'') = ''
		End

	--Validate ProductCategoryName Name:
	If (Select Count(*) From Recd_OCG_Product Where  RecdID = @REC_OCGID and Isnull(ProductCategoryName,'') = '') > 0
		Begin
			Set @ErrorStatus =1
			Set @ErrorMessage = 'Unable To Process Blank ProductCategoryName'
			Exec mERP_sp_Update_OCGErrorStatus @REC_OCGID,@ErrorMessage
			Update Recd_OCG_Product Set status = 2 Where RecdID = @REC_OCGID and Isnull(ProductCategoryName,'') = ''
		End
				
	--Validate Level:				
	If (Select Count(*) From Recd_OCG_Product Where  RecdID = @REC_OCGID and Isnull(Level,0) = 0) > 0
		Begin
			Set @ErrorStatus =1
			Set @ErrorMessage = 'Invalid Level'
			Exec mERP_sp_Update_OCGErrorStatus @REC_OCGID,@ErrorMessage
			Update Recd_OCG_Product Set status = 2 Where RecdID = @REC_OCGID And Isnull(Level,0) = 0 
		End

--	Declare @szProductCategoryName as Nvarchar(200)
--	Declare @szLevel  as Int
--	Declare @Cur_validateLevel Cursor 
--	Set @Cur_validateLevel = Cursor for
--	Select Distinct ProductCategoryName,Isnull(Level,0) From Recd_OCG_Product Where  RecdID = @REC_OCGID And Isnull(status,0) = 0
--	Open @Cur_validateLevel
--	Fetch Next from @Cur_validateLevel into @szProductCategoryName,@szLevel
--	While @@fetch_status =0
--		Begin
--			If @szLevel <> 5
--				Begin
--					If Not Exists(select 'X' from ItemCategories Where Category_Name = @szProductCategoryName and Level = @szLevel)
--						Begin
--							Set @ErrorStatus =1
--							Set @ErrorMessage = 'Category Not Available In MERP Or Invalid Level Received for [' + cast(@szProductCategoryName as Nvarchar(255)) + '] in Recd_OCG_Product table RecdID: ' + cast(@REC_OCGID as Nvarchar(255))
--							Exec mERP_sp_Update_OCGErrorStatus @REC_OCGID,@ErrorMessage
--							Update Recd_OCG_Product Set status = 2 Where RecdID = @REC_OCGID And ProductCategoryName = @szProductCategoryName And Level = @szLevel
--							Goto SkipProduct
--						End
--				End

--			If @szLevel = 5
--				Begin
--					If Not Exists(select 'X' from Items Where Product_Code = @szProductCategoryName)
--						Begin
--							Set @ErrorStatus =1
--							Set @ErrorMessage = 'Item Not Available In MERP Or Invalid Level Received for [' + cast(@szProductCategoryName as Nvarchar(255)) + '] in Recd_OCG_Product table RecdID: ' + cast(@REC_OCGID as Nvarchar(255))
--							Exec mERP_sp_Update_OCGErrorStatus @REC_OCGID,@ErrorMessage
--							Update Recd_OCG_Product Set status = 2 Where RecdID = @REC_OCGID And ProductCategoryName = @szProductCategoryName And Level = @szLevel
--							Goto SkipProduct
--						End		
--				End
--SkipProduct:
--		Fetch Next from @Cur_validateLevel into @szProductCategoryName,@szLevel
--		End
--	Close @Cur_validateLevel
--	Deallocate @Cur_validateLevel

--*********************************************************************************************************************************************
	Declare CurOCGCode Cursor for
	Select Distinct OCGCode from Recd_OCG_Product Where isnull(status,0) = 0 And RecdID = @REC_OCGID
	Open CurOCGCode
	Fetch from CurOCGCode into @D_OCGCode
	While @@fetch_status =0
		Begin
			Delete From OCG_Product Where OCGCode = @D_OCGCode
			Insert Into OCG_Product(RECDID,OCGCode,ProductCategoryName,Level,Exclusion)
			select @REC_OCGID,OCGCode,ProductCategoryName,Level,Exclusion From Recd_OCG_Product Where OCGCode = @D_OCGCode and isnull(status,0) = 0 And RecdID = @REC_OCGID
			Update Recd_OCG_Product Set Status = 1 Where Isnull(Status,0) = 0 And RecdID = @REC_OCGID And OCGCode = @D_OCGCode
			Fetch Next from CurOCGCode into @D_OCGCode
		End
	Close CurOCGCode
	Deallocate CurOCGCode
End
-- ********************************************************************************************************************************************
