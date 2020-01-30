CREATE PROCEDURE sp_update_category(@CATEGORYID int,    
        @DESCRIPTION nvarchar(255),    
        @PARENTID int,    
        @TRACK_INVENTORY int,    
        @CAPTURE_PRICE int,    
        @ACTIVE int 
)    
AS    
DECLARE @STATUS int
DECLARE @PREV int

Select @PREV = Active From ItemCategories Where CategoryID = @CATEGORYID
UPDATE ItemCategories SET Description = @DESCRIPTION,    
     ParentID = @PARENTID,    
     Track_Inventory = @TRACK_INVENTORY,    
     Price_Option = @CAPTURE_PRICE,    
     Active = @ACTIVE,
     ModifiedDate = GetDate()
WHERE CategoryID = @CATEGORYID 
IF @ACTIVE = 0 
BEGIN
	Exec Spr_GetCategoryID_ActiveDeactive @CATEGORYID, @STATUS output
	IF @STATUS = 0 Update ItemCategories Set Active = @PREV Where CategoryID = @CATEGORYID
END

