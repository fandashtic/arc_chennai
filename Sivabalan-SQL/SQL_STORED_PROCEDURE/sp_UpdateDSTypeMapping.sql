
	Create Procedure sp_UpdateDSTypeMapping
	AS
	Begin
	Declare @DSTypeID Int
	Declare @GR1 nVarchar(255)
	Declare @GR2 nVarchar(255)
	Declare @GR3 nVarchar(255)
	Declare @GR4 nVarchar(255) 
	--Declare @GR5 nVarchar(255) 


	Select @GR1 = GroupID From ProductCategoryGroupAbstract Where GroupName = 'GR1'
	Select @GR2 = GroupID From ProductCategoryGroupAbstract Where GroupName = 'GR2'
	Select @GR3 = GroupID From ProductCategoryGroupAbstract Where GroupName = 'GR3'
	Select @GR4 = GroupID From ProductCategoryGroupAbstract Where GroupName = 'GR4'
	--Select @GR5 = GroupID From ProductCategoryGroupAbstract Where GroupName = 'GR5'

	If Exists(select * from DSType_master where DSTypeCode='01')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='01'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping (DSTypeID,GroupID,Active,CreationDate,ModifiedDate)  
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active )  
			Values('01','Grocery 1 Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
			Values(@DSTypeID,@GR1,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='02')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='02'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
--				Values(@DSTypeID,@GR5,0,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active )  
			Values('02','Grocery 2 Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
			Values(@DSTypeID,@GR2,1,GetDate(),null)
	--	insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
	--		Values(@DSTypeID,@GR5,1,GetDate(),null)
	End

	If Exists(select * from DSType_master where DSTypeCode='03')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='03'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active )  
			Values('03','Grocery 3 Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
			Values(@DSTypeID,@GR3,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='04')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='04'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active )  
			Values('04','Grocery 1 Ds FCF','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
			Values(@DSTypeID,@GR1,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='05')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='05'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active )  
			Values('05','Grocery 2 Ds PG&C','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
			Values(@DSTypeID,@GR2,1,GetDate(),null)
--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='06')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='06'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active )  
			Values('06','Common Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='07')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='07'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End

	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('07','Common Trade Loyalty Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )  
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='08')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='08'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('08','SWD Ds Exclusive FMCG','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End

	If Exists(select * from DSType_master where DSTypeCode='09')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='09'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('09','SWD Ds Exclusive Tobacco','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR4,1,GetDate(),null)
	End

	If Exists(select * from DSType_master where DSTypeCode='10')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='10'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				 Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
				 Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
--				 Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End

	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			 Values('10','SWD Ds DUAL','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			 Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
			 Values(@DSTypeID,@GR4,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
--			 Values(@DSTypeID,@GR5,1,GetDate(),null)
	End

	If Exists(select * from DSType_master where DSTypeCode='11')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='11'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('11','SWD Ds Shubh Labh ','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End

	If Exists(select * from DSType_master where DSTypeCode='12')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='12'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
				 Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('12','ISS Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
			 Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR4,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End

	If Exists(select * from DSType_master where DSTypeCode='13')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='13'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('13','Chemist/Cosmetic Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR3,1,GetDate(),null)
--
--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR4,1,GetDate(),null)
--
--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='14')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='14'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('14','Consumption Centre Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR4,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='15')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='15'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('15','Key Accounts Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR4,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='16')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='16'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3) 
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
				 Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				 Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('16','Convenience Ds CDM','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
			 Values(@DSTypeID,@GR3,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			 Values(@DSTypeID,@GR4,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End

	If Exists(select * from DSType_master where DSTypeCode='17')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='17'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('17','Convenience Ds Non-CDM','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR4,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End

	If Exists(select * from DSType_master where DSTypeCode='18')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='18'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
				 Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
				 Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
--				 Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin
		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active )
			 Values('18','Village Convenience Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
			 Values(@DSTypeID,@GR3,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
			 Values(@DSTypeID,@GR4,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate )
--			 Values(@DSTypeID,@GR5,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='19')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='19'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin

		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('19','HoReCa Ds','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR4,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End


	If Exists(select * from DSType_master where DSTypeCode='20')
	Begin
		select @DSTypeID = DSTypeID from DSType_master where DSTypeCode='20'
		Delete From tbl_mERP_DSTypeCGMapping Where DSTypeID = @DSTypeID

--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR1)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR1,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR2)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR2,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR3)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR3,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR4)
--		Begin
			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
				Values(@DSTypeID,@GR4,1,GetDate(),null)
--		End
--		If Not Exists(select * from tbl_mERP_DSTypeCGMapping where DSTypeID=@DSTypeID And GroupID = @GR5)
--		Begin
--			insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--				Values(@DSTypeID,@GR5,1,GetDate(),null)
--		End
	End
	Else
	Begin

		insert Into DSType_master ( DSTypeCode,DSTypeValue,DSTypeName,DSTypeCtlPos,Active ) 
			Values('20','Pilot Salesman','DSType',1,1)
		Select @DSTypeID = @@Identity
		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR1,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR2,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR3,1,GetDate(),null)

		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
			Values(@DSTypeID,@GR4,1,GetDate(),null)

--		insert Into tbl_mERP_DSTypeCGMapping ( DSTypeID,GroupID,Active,CreationDate,ModifiedDate ) 
--			Values(@DSTypeID,@GR5,1,GetDate(),null)
	End
	End
