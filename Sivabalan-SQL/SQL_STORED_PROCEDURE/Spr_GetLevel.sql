CREATE PROCEDURE Spr_GetLevel (@level int)
AS

declare @X int

BEGIN
declare GetLevel cursor for select categoryid from itemcategories where level= @level
open GetLevel
fetch from GetLevel into @X
while @@fetch_status = 0
Begin
	Exec Spr_GetCategoryID @X
fetch next from GetLevel into @X
end
close GetLevel
deallocate GetLevel

END

