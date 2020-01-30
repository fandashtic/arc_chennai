
CREATE PROCEDURE spr_list_category_items(@CATEGORYID int)
AS
Declare @YES As NVarchar(50)
Declare @NO As NVarchar(50)
Set @YES = dbo.LookupDictionaryItem(N'Yes',Default)
Set @NO = dbo.LookupDictionaryItem(N'No',Default)

SELECT Product_Code, "Item Code" = Product_Code, "Item Name" = ProductName,
	Description, 
	"Track Batches" = CASE Virtual_Track_Batches WHEN 1 THEN @YES ELSE @NO END, 
	"Track PKD" = CASE TrackPKD WHEN 1 THEN @YES ELSE @NO END FROM Items 
WHERE CategoryID = @CATEGORYID AND Active = 1

