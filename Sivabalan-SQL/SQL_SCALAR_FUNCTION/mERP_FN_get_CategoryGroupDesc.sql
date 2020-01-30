Create Function mERP_FN_get_CategoryGroupDesc (@InvoiceID int,@CategoryGroup nvarchar(2000))
Returns nvarchar(2000)
AS
BEGIN
	Declare @Delimeter Char(1)  
	Declare @ReturnValue nvarchar(2000)
	Declare @finalvalue nvarchar(2000)
	Declare @rowno  int
	Declare @maxRow int
	Declare @tmpCat Table(RowID int identity(1,1),CatGroup nvarchar(2000))

	set @Delimeter = '|'
	Set @rowno=1
	Set @ReturnValue=''

	insert into @tmpCat(CatGroup) select * from dbo.sp_SplitIn2Rows(@CategoryGroup,@Delimeter)
	select @maxRow = count(*) from @tmpCat

	if (select count(*) from @tmpCat) > 1
		Delete from @tmpCat where CatGroup = (Select GroupName from ProductCategoryGroupAbstract where GroupName='GR2')
	while @rowno < = @maxRow
	BEGIN
		if exists (select * from @tmpCat where rowid=@rowno)
		BEGIN
			if (Select count(GroupName) from ProductCategoryGroupAbstract where 
							   GroupID in (Select GroupId from InvoiceDetail where Invoiceid= @InvoiceID)	
							   And GroupName = (Select CatGroup from @tmpCat where rowid= @rowno)) <> 0
			BEGIN
				set @ReturnValue = @ReturnValue+'|'+(Select GroupName from ProductCategoryGroupAbstract where 
				GroupID in (Select GroupId from InvoiceDetail where Invoiceid= @InvoiceID)	
				And GroupName = (Select CatGroup from @tmpCat where rowid= @rowno))
			END
			set @rowno =@rowno + 1
		END
		ELSE
			set @rowno =@rowno + 1
	END

	set @Finalvalue = ''
	if (isnull(@ReturnValue,'')) <> ''
		set @Finalvalue = @CategoryGroup --right(@ReturnValue,len(@ReturnValue)-1)
	return @Finalvalue
END
