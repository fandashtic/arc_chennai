Create Procedure mERP_sp_InsertRecdChannelMarginDet
( @RecdID int=0,@RecdMarginID int=0, @Name nVArchar(255)= NULL, @Catlevel nVarchar(510)= NULL, @Percentage Decimal(18,6)= 0, @RegFlag nVarchar(30) = NULL,  @ChnlTypeCode nVarchar(255)= NULL)
As
Insert into tbl_mERP_RecdChannelMarginDetail ( RecdID, RecdDetID, ChannelTypeCode, RegFlag, CategoryName, Categorylevel, MarginPercentage ) 
Values (@RecdID, @RecdMarginID, @ChnlTypeCode, @RegFlag, @Name, @Catlevel, @Percentage  )
