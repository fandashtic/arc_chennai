Create Function fin_cat (@OLevel Int, @P_Code nvarchar(20))
Returns Int
Begin
Declare @Cat Int, @DLevel Int
Select @Cat = CategoryID From Items Where Product_Code = @P_Code
Select @DLevel = [Level] From ItemCategories Where CategoryID = @Cat
While @DLevel > @OLevel 
Begin
 Select @Cat = ParentID From ItemCategories Where CategoryID = @Cat
 Select @DLevel = [Level] From ItemCategories Where CategoryID = @Cat
End
If @OLevel = @DLevel 
Set @Cat = @Cat
Else
Set @Cat = 0
Return @Cat
End


