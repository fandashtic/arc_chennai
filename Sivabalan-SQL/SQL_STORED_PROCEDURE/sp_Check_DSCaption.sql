CREATE Procedure sp_Check_DSCaption(@Caption as nVarchar(1000))  
As  
Begin  
 Declare @cnt integer,@dsCaption  nVarchar(100),@dsTmpCaption as nVarchar(100),@returnValue Integer  
 Declare @Delimeter as nVarchar

 Set @Caption = Substring(@Caption,2,len(@Caption))  
 Set @Delimeter = char(15) 
  
 set @cnt = 1  
 Create Table #tmpCaption(ID1 Integer Identity(1,1),DScaption nVarchar(100)) 
 
 Insert Into #tmpCaption Select * from dbo.sp_SplitIn2Rows(@Caption,@Delimeter)  

  
	Set	@returnValue = 1
	Set	@dsTmpCaption = ''
	While  @cnt <= 6   
	Begin  
		Select  @dsTmpCaption = DScaption From #tmpCaption Where ID1 = @cnt  
		if @cnt = 1 
			if @dsTmpCaption <> isNull((Select LabelName From DSTypeLabel Where ControlPos = 1 ),'')  Set @returnValue = 0 
		if @cnt = 2 
			if @dsTmpCaption <> isNull((Select LabelName From DSTypeLabel Where ControlPos = 2 ),'')  Set @returnValue = 0 
		if @cnt = 3 
			if @dsTmpCaption <> isNull((Select LabelName From DSTypeLabel Where ControlPos = 3 ),'')  Set @returnValue = 0 
		if @cnt = 4 
			if @dsTmpCaption <> isNull((Select LabelName From DSTypeLabel Where ControlPos = 4 ),'')  Set @returnValue = 0 
		if @cnt = 5 
			if @dsTmpCaption <> isNull((Select LabelName From DSTypeLabel Where ControlPos = 5 ),'')  Set @returnValue = 0 
		if @cnt = 6 
			if @dsTmpCaption <> isNull((Select LabelName From DSTypeLabel Where ControlPos = 6 ),'')  Set @returnValue = 0 
		set @cnt = @cnt + 1 
		Set	@dsTmpCaption = ''
	End
	select  @returnValue  
	Drop table #tmpCaption   
End  
